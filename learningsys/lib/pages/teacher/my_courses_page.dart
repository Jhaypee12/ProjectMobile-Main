import 'package:flutter/material.dart';

import '../../services/api_service.dart';

const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);
const red = Color(0xFFD32F2F);

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key, this.user});
  final AppUser? user;

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  List<_Course> _courses = [];
  bool _loading = true;
  Object? _error;

  String get _myFullName {
    final u = widget.user;
    if (u == null) return '';
    return '${u.firstName} ${u.lastName}'.trim();
  }

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
      final all = raw.map((j) => _Course.fromJson(j)).toList();

      final me = _myFullName.toLowerCase();
      final mine = me.isEmpty
          ? all
          : all
              .where((c) => c.instructor.toLowerCase() == me)
              .toList();

      if (!mounted) return;
      setState(() {
        _courses = mine;
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

  void _showInfo(_Course c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(c.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.code.isNotEmpty) ...[
              Text('Code: ${c.code}'),
              const SizedBox(height: 4),
            ],
            Text('Instructor: ${c.instructor}'),
            const SizedBox(height: 4),
            Text('Students enrolled: ${c.studentCount}'),
            if (c.description.isNotEmpty) ...[
              const SizedBox(height: 12),
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

  Future<void> _showAnnounce(_Course c) async {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    String error = '';
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Post Announcement\n${c.name}'),
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
                  controller: msgCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Message'),
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
                      if (titleCtrl.text.trim().isEmpty ||
                          msgCtrl.text.trim().isEmpty) {
                        setDialogState(() =>
                            error = 'Title and message are required');
                        return;
                      }
                      setDialogState(() => saving = true);
                      try {
                        final today = DateTime.now()
                            .toIso8601String()
                            .split('T')
                            .first;
                        await ApiService.createAnnouncement(
                          title: titleCtrl.text.trim(),
                          message: msgCtrl.text.trim(),
                          course: c.name,
                          section: '',
                          date: today,
                        );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Announcement posted to ${c.name}'),
                              backgroundColor: purple,
                            ),
                          );
                        }
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
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
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
                const Text(
                  'My Courses',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 20),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  Text(
                    'Could not load courses.\n$_error',
                    style: const TextStyle(color: red),
                  )
                else if (_courses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'You have no courses assigned yet.',
                      style: TextStyle(color: darkText, fontSize: 14),
                    ),
                  )
                else
                  for (final c in _courses) ...[
                    _TeacherCourseCard(
                      course: c,
                      onInfo: () => _showInfo(c),
                      onAnnounce: () => _showAnnounce(c),
                    ),
                    const SizedBox(height: 16),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Course card (no student list)
// ---------------------------------------------------------------------------

class _TeacherCourseCard extends StatelessWidget {
  const _TeacherCourseCard({
    required this.course,
    required this.onInfo,
    required this.onAnnounce,
  });

  final _Course course;
  final VoidCallback onInfo;
  final VoidCallback onAnnounce;

  @override
  Widget build(BuildContext context) {
    final c = course;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purple banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: purple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.code.isNotEmpty ? '${c.name} (${c.code})' : c.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${c.studentCount} student${c.studentCount == 1 ? '' : 's'} enrolled',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: onInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Course Information',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onAnnounce,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Post Announcement',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Description block
          if (c.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                c.description,
                style: const TextStyle(color: darkText, fontSize: 13.5),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class _Course {
  final String id;
  final String name;
  final String code;
  final String instructor;
  final String description;
  final int studentCount;

  _Course({
    required this.id,
    required this.name,
    required this.code,
    required this.instructor,
    required this.description,
    required this.studentCount,
  });

  factory _Course.fromJson(Map<String, dynamic> json) {
    final enrolled = json['enrolledStudentIds'];
    int count = 0;
    if (enrolled is List) count = enrolled.length;

    return _Course(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? 'Untitled',
      code: json['code'] ?? '',
      instructor: json['instructor'] ?? 'Unknown',
      description: json['description'] ?? '',
      studentCount: count,
    );
  }
}