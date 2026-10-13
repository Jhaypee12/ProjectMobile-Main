import 'package:flutter/material.dart';

import '../../services/api_service.dart';

const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);
const red = Color(0xFFD32F2F);

class AdminCoursesPage extends StatefulWidget {
  const AdminCoursesPage({super.key});

  @override
  State<AdminCoursesPage> createState() => _AdminCoursesPageState();
}

class _AdminCoursesPageState extends State<AdminCoursesPage> {
  List<_Course> _courses = [];
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
      final raw = await ApiService.getCourses();
      if (!mounted) return;
      setState(() {
        _courses = raw.map((j) => _Course.fromJson(j)).toList();
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

  void _showDetails(_Course c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(c.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instructor: ${c.instructor}'),
            const SizedBox(height: 4),
            Text('Grade: ${c.grade}'),
            const SizedBox(height: 4),
            Text('Score: ${c.score}%'),
            if (c.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(c.description),
            ],
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

  Future<void> _showForm({_Course? existing}) async {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final instructorCtrl =
        TextEditingController(text: existing?.instructor ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final gradeCtrl = TextEditingController(text: existing?.grade ?? '');
    final scoreCtrl =
        TextEditingController(text: existing?.score.toString() ?? '0');
    String error = '';
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Course' : 'New Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Course name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: instructorCtrl,
                  decoration: const InputDecoration(labelText: 'Instructor'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: gradeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Grade (e.g. A, B+)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: scoreCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Score (%)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(error, style: const TextStyle(color: red)),
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
                          instructorCtrl.text.trim().isEmpty) {
                        setDialogState(() => error =
                            'Course name and instructor are required');
                        return;
                      }
                      final score = int.tryParse(scoreCtrl.text.trim());
                      if (score == null) {
                        setDialogState(
                            () => error = 'Score must be a number');
                        return;
                      }
                      setDialogState(() => saving = true);
                      try {
                        if (isEditing) {
                          await ApiService.updateCourse(
                            existing.id,
                            name: nameCtrl.text.trim(),
                            instructor: instructorCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            grade: gradeCtrl.text.trim(),
                            score: score,
                          );
                        } else {
                          await ApiService.createCourse(
                            name: nameCtrl.text.trim(),
                            instructor: instructorCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            grade: gradeCtrl.text.trim(),
                            score: score,
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
                  : Text(isEditing ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _remove(_Course c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Delete "${c.name}"?'),
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
      await ApiService.deleteCourse(c.id);
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
    return SafeArea(
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
                    'Courses',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'New Course',
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
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: cardBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child:
                            Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      Text(
                        'Could not load courses.\n$_error',
                        style: const TextStyle(color: red),
                      )
                    else if (_courses.isEmpty)
                      const Text('No courses yet.')
                    else
                      for (final c in _courses)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkText,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${c.instructor} • ${c.grade} (${c.score}%)',
                                style: const TextStyle(
                                    color: darkText, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _showDetails(c),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: purple,
                                      side: const BorderSide(
                                          color: purple),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        const Text('Course Information'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () =>
                                        _showForm(existing: c),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: purple,
                                      side: const BorderSide(
                                          color: purple),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Edit'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _remove(c),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                              const Divider(
                                  height: 24, color: cardBorder),
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
    );
  }
}

class _Course {
  final String id;
  final String name;
  final String instructor;
  final String description;
  final String grade;
  final int score;

  _Course({
    required this.id,
    required this.name,
    required this.instructor,
    required this.description,
    required this.grade,
    required this.score,
  });

  factory _Course.fromJson(Map<String, dynamic> json) => _Course(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: json['name'] ?? 'Untitled',
        instructor: json['instructor'] ?? 'Unknown',
        description: json['description'] ?? '',
        grade: json['grade'] ?? '-',
        score: (json['score'] is int)
            ? json['score'] as int
            : int.tryParse('${json['score']}') ?? 0,
      );
}