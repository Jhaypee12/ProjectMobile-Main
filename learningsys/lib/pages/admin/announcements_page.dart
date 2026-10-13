import 'package:flutter/material.dart';

import '../../services/api_service.dart';

const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);
const red = Color(0xFFD32F2F);

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key, this.canManage = true});
  final bool canManage;

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  late Future<List<_Announcement>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_Announcement>> _load() async {
    final raw = await ApiService.getAnnouncements();
    return raw.map((j) => _Announcement.fromJson(j)).toList();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  void _showDetails(_Announcement a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(a.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.message),
            const SizedBox(height: 12),
            Text('Course: ${a.course}'),
            if (a.section.isNotEmpty) Text('Section: ${a.section}'),
            const SizedBox(height: 4),
            Text('Posted: ${a.date}'),
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

  Future<void> _showForm({_Announcement? existing}) async {
    final isEditing = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final messageCtrl = TextEditingController(text: existing?.message ?? '');
    final courseCtrl = TextEditingController(text: existing?.course ?? 'ALL');
    final sectionCtrl = TextEditingController(text: existing?.section ?? '');
    String error = '';
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Announcement' : 'Post Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Course (use "ALL" for everyone)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sectionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Section (optional)',
                  ),
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
                      if (titleCtrl.text.trim().isEmpty ||
                          messageCtrl.text.trim().isEmpty) {
                        setDialogState(
                            () => error = 'Title and message are required');
                        return;
                      }
                      setDialogState(() => saving = true);
                      try {
                        final today = DateTime.now()
                            .toIso8601String()
                            .split('T')
                            .first;
                        if (isEditing) {
                          await ApiService.updateAnnouncement(
                            existing.id,
                            title: titleCtrl.text.trim(),
                            message: messageCtrl.text.trim(),
                            course: courseCtrl.text.trim().isEmpty
                                ? 'ALL'
                                : courseCtrl.text.trim(),
                            section: sectionCtrl.text.trim(),
                            date: today,
                          );
                        } else {
                          await ApiService.createAnnouncement(
                            title: titleCtrl.text.trim(),
                            message: messageCtrl.text.trim(),
                            course: courseCtrl.text.trim().isEmpty
                                ? 'ALL'
                                : courseCtrl.text.trim(),
                            section: sectionCtrl.text.trim(),
                            date: today,
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
                  : Text(isEditing ? 'Save' : 'Post'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _remove(_Announcement a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Announcement'),
        content: Text('Are you sure you want to remove "${a.title}"?'),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService.deleteAnnouncement(a.id);
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
      child: FutureBuilder<List<_Announcement>>(
        future: _future,
        builder: (context, snapshot) {
          final loading =
              snapshot.connectionState == ConnectionState.waiting;
          final items = snapshot.data ?? [];

          return RefreshIndicator(
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
                        'Announcements',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      if (widget.canManage)
                        ElevatedButton.icon(
                          onPressed: () => _showForm(),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Post',
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
                      color: purple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COURSE ANNOUNCEMENTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Updates and notices from your courses.',
                          style:
                              TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Could not load announcements.\n${snapshot.error}',
                        style: const TextStyle(color: red),
                      ),
                    )
                  else if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No announcements yet.'),
                    )
                  else
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
                          for (final a in items)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${a.course} • ${a.date}',
                                    style: const TextStyle(
                                        color: darkText, fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _showDetails(a),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Details'),
                                      ),
                                      if (widget.canManage) ...[
                                        OutlinedButton(
                                          onPressed: () =>
                                              _showForm(existing: a),
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
                                          onPressed: () => _remove(a),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: red,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Remove'),
                                        ),
                                      ],
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
          );
        },
      ),
    );
  }
}

class _Announcement {
  final String id;
  final String title;
  final String message;
  final String course;
  final String section;
  final String date;

  _Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.course,
    required this.section,
    required this.date,
  });

  factory _Announcement.fromJson(Map<String, dynamic> json) => _Announcement(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        course: json['course'] ?? 'ALL',
        section: json['section'] ?? '',
        date: json['date'] ?? '',
      );
}