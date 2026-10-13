import 'package:flutter/material.dart';

import '../../role.dart';
import '../../services/api_service.dart';

const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);
const red = Color(0xFFD32F2F);

class AssessmentsPage extends StatefulWidget {
  const AssessmentsPage({super.key, required this.role});
  final Role role;

  @override
  State<AssessmentsPage> createState() => _AssessmentsPageState();
}

class _AssessmentsPageState extends State<AssessmentsPage> {
  bool get canManage => widget.role != Role.student;

  List<_Assessment> _items = [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ApiService.getAssessments();
      if (!mounted) return;
      setState(() {
        _items = raw.map((j) => _Assessment.fromJson(j)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _load();
  }

  void _showDetails(_Assessment a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(a.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Course: ${a.course}'),
            Text('Type: ${a.type}'),
            Text('Due: ${a.due}'),
            if (a.section.isNotEmpty) Text('Section: ${a.section}'),
            if (a.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(a.description),
            ],
            const SizedBox(height: 4),
            Text('Status: ${a.status}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showForm({_Assessment? existing}) async {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final courseCtrl = TextEditingController(text: existing?.course ?? '');
    final typeCtrl = TextEditingController(text: existing?.type ?? 'Quiz');
    final dueCtrl = TextEditingController(text: existing?.due ?? '');
    final sectionCtrl = TextEditingController(text: existing?.section ?? '');
    final descCtrl =
        TextEditingController(text: existing?.description ?? '');
    String status = existing?.status ?? 'Pending';
    String error = '';
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Assessment' : 'Add Assessment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseCtrl,
                  decoration: const InputDecoration(labelText: 'Course'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeCtrl,
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dueCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Due (YYYY-MM-DD)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sectionCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Section (optional)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'Not started', child: Text('Not started')),
                    DropdownMenuItem(
                        value: 'Submitted', child: Text('Submitted')),
                    DropdownMenuItem(value: 'Graded', child: Text('Graded')),
                  ],
                  onChanged: (v) => setDialogState(() => status = v!),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child:
                        Text(error, style: const TextStyle(color: red)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty ||
                          courseCtrl.text.trim().isEmpty) {
                        setDialogState(
                            () => error = 'Name and course are required');
                        return;
                      }
                      setDialogState(() => saving = true);
                      try {
                        if (isEditing) {
                          await ApiService.updateAssessment(
                            existing.id,
                            name: nameCtrl.text.trim(),
                            course: courseCtrl.text.trim(),
                            type: typeCtrl.text.trim(),
                            due: dueCtrl.text.trim(),
                            status: status,
                            description: descCtrl.text.trim(),
                            section: sectionCtrl.text.trim(),
                          );
                        } else {
                          await ApiService.createAssessment(
                            name: nameCtrl.text.trim(),
                            course: courseCtrl.text.trim(),
                            type: typeCtrl.text.trim(),
                            due: dueCtrl.text.trim(),
                            status: status,
                            description: descCtrl.text.trim(),
                            section: sectionCtrl.text.trim(),
                          );
                        }
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        await _refresh();
                      } catch (e) {
                        setDialogState(() {
                          error = e
                              .toString()
                              .replaceFirst('Exception: ', '');
                          saving = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
              ),
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _remove(_Assessment a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Assessment'),
        content: Text('Delete "${a.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService.deleteAssessment(a.id);
      await _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Assessments',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    if (canManage)
                      ElevatedButton.icon(
                        onPressed: () => _showForm(),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: cardBorder),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _error != null
                          ? Text(
                              'Could not load assessments.\n$_error',
                              style: const TextStyle(color: red),
                            )
                          : _items.isEmpty
                              ? const Text('No assessments yet.')
                              : Column(
                                  children: [
                                    for (final a in _items)
                                      Padding(
                                        padding: const EdgeInsets
                                            .symmetric(vertical: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              a.name,
                                              style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: darkText,
                                              ),
                                            ),
                                            Text(
                                              '${a.course} • ${a.type} • ${a.due}',
                                              style: const TextStyle(
                                                  color: darkText,
                                                  fontSize: 13),
                                            ),
                                            Text(
                                              'Status: ${a.status}',
                                              style: const TextStyle(
                                                  color: darkText,
                                                  fontSize: 13),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 8,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      _showDetails(a),
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                    backgroundColor: blue,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                  child:
                                                      const Text('Details'),
                                                ),
                                                if (canManage) ...[
                                                  OutlinedButton(
                                                    onPressed: () =>
                                                        _showForm(
                                                            existing: a),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          purple,
                                                      side: const BorderSide(
                                                          color: purple),
                                                    ),
                                                    child:
                                                        const Text('Edit'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        _remove(a),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: red,
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    child: const Text(
                                                        'Delete'),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const Divider(
                                                height: 24,
                                                color: cardBorder),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Assessment {
  final String id;
  final String name;
  final String course;
  final String type;
  final String due;
  final String status;
  final String description;
  final String section;

  _Assessment({
    required this.id,
    required this.name,
    required this.course,
    required this.type,
    required this.due,
    required this.status,
    required this.description,
    required this.section,
  });

  factory _Assessment.fromJson(Map<String, dynamic> json) => _Assessment(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: json['name'] ?? '',
        course: json['course'] ?? '',
        type: json['type'] ?? '',
        due: json['due'] ?? '',
        status: json['status'] ?? 'Pending',
        description: json['description'] ?? '',
        section: json['section'] ?? '',
      );
}