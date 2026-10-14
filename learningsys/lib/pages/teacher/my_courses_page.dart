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
  List<_TeacherCourse> _courses = [];
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

      final results = await Future.wait([
        ApiService.getCourses(),
        ApiService.getMyCourses(),
      ]);

      final coursesRaw = results[0];
      final mycoursesRaw = results[1];

      final me = _myFullName.toLowerCase();
      final myCoursesFromList = me.isEmpty
          ? <Map<String, dynamic>>[]
          : coursesRaw
              .where((c) =>
                  (c['instructor'] ?? '').toString().toLowerCase() == me)
              .toList();

      final myNames = myCoursesFromList
          .map((c) => (c['name'] ?? '').toString().toLowerCase().trim())
          .toSet();

      final mine = <_TeacherCourse>[];
      for (final m in mycoursesRaw) {
        final name = (m['name'] ?? '').toString().toLowerCase().trim();
        if (myNames.contains(name)) {
          mine.add(_TeacherCourse.fromJson(m));
        }
      }

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

  void _showInfo(_TeacherCourse c) {
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
            Text('Students enrolled: ${c.students.length}'),
            if (c.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(c.description),
            ],
            if (c.modules.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Modules: ${c.modules.length}'),
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

  Future<void> _showAnnounce(_TeacherCourse c) async {
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


class _TeacherCourseCard extends StatefulWidget {
  const _TeacherCourseCard({
    required this.course,
    required this.onInfo,
    required this.onAnnounce,
  });

  final _TeacherCourse course;
  final VoidCallback onInfo;
  final VoidCallback onAnnounce;

  @override
  State<_TeacherCourseCard> createState() => _TeacherCourseCardState();
}

class _TeacherCourseCardState extends State<_TeacherCourseCard> {
  bool _studentsExpanded = true;
  bool _modulesExpanded = true;

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

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
                  '${c.students.length} student${c.students.length == 1 ? '' : 's'} enrolled',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: widget.onInfo,
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
                      onPressed: widget.onAnnounce,
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

          _SectionToggle(
            title: 'Students (${c.students.length})',
            expanded: _studentsExpanded,
            onTap: () =>
                setState(() => _studentsExpanded = !_studentsExpanded),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _studentsExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: c.students.isEmpty
                        ? const Text(
                            'No students enrolled yet.',
                            style: TextStyle(color: darkText, fontSize: 13),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 16,
                              headingRowHeight: 36,
                              dataRowHeight: 44,
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: darkText,
                                fontSize: 12.5,
                              ),
                              dataTextStyle: const TextStyle(
                                color: darkText,
                                fontSize: 12.5,
                              ),
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Section')),
                                DataColumn(label: Text('Score')),
                                DataColumn(label: Text('Grade')),
                              ],
                              rows: [
                                for (final s in c.students)
                                  DataRow(cells: [
                                    DataCell(Text(s.name)),
                                    DataCell(Text(s.email)),
                                    DataCell(Text(
                                        s.section.isEmpty ? '—' : s.section)),
                                    DataCell(Text('${s.score}%')),
                                    DataCell(Text(
                                        s.grade.isEmpty ? '—' : s.grade)),
                                  ]),
                              ],
                            ),
                          ),
                  )
                : const SizedBox(width: double.infinity),
          ),

          if (c.modules.isNotEmpty) ...[
            const Divider(height: 1, color: cardBorder),
            _SectionToggle(
              title: 'Course Content (${c.modules.length})',
              expanded: _modulesExpanded,
              onTap: () =>
                  setState(() => _modulesExpanded = !_modulesExpanded),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: _modulesExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final m in c.modules)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.title,
                                    style: const TextStyle(
                                      color: darkText,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    m.content,
                                    style: const TextStyle(
                                      color: darkText,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionToggle extends StatelessWidget {
  const _SectionToggle({
    required this.title,
    required this.expanded,
    required this.onTap,
  });

  final String title;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ),
            Icon(
              expanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              color: purple,
            ),
          ],
        ),
      ),
    );
  }
}


class _TeacherCourse {
  final String id;
  final String name;
  final String code;
  final String description;
  final List<_EnrolledStudent> students;
  final List<_Module> modules;

  _TeacherCourse({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.students,
    required this.modules,
  });

  factory _TeacherCourse.fromJson(Map<String, dynamic> json) {
    final rawStudents = json['students'];
    final parsedStudents = <_EnrolledStudent>[];
    if (rawStudents is List) {
      for (final s in rawStudents) {
        if (s is Map) {
          parsedStudents
              .add(_EnrolledStudent.fromJson(Map<String, dynamic>.from(s)));
        }
      }
    }

    final rawModules = json['modules'];
    final parsedModules = <_Module>[];
    if (rawModules is List) {
      for (final m in rawModules) {
        if (m is Map) {
          parsedModules.add(_Module.fromJson(Map<String, dynamic>.from(m)));
        }
      }
    }

    return _TeacherCourse(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? 'Untitled',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      students: parsedStudents,
      modules: parsedModules,
    );
  }
}

class _EnrolledStudent {
  final String id;
  final String name;
  final String email;
  final String section;
  final int score;
  final String grade;

  _EnrolledStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.section,
    required this.score,
    required this.grade,
  });

  factory _EnrolledStudent.fromJson(Map<String, dynamic> json) {
    final studentField = json['student'];
    String sid = '';
    String name = '(unknown)';
    String email = '';
    if (studentField is Map) {
      sid = (studentField['_id'] ?? '').toString();
      final f = studentField['firstName'] ?? '';
      final l = studentField['lastName'] ?? '';
      name = '$f $l'.trim();
      if (name.isEmpty) name = '(unknown)';
      email = (studentField['email'] ?? '').toString();
    } else if (studentField != null) {
      sid = studentField.toString();
    }

    return _EnrolledStudent(
      id: sid,
      name: name,
      email: email,
      section: json['section'] ?? '',
      score: (json['score'] is int)
          ? json['score'] as int
          : int.tryParse('${json['score']}') ?? 0,
      grade: json['grade'] ?? '',
    );
  }
}

class _Module {
  final String title;
  final String content;

  _Module({required this.title, required this.content});

  factory _Module.fromJson(Map<String, dynamic> json) => _Module(
        title: json['title'] ?? '',
        content: json['content'] ?? '',
      );
}