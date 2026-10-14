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
  int _page = 0;

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
      final myCoursesRaw = results[1];

      final myByName = <String, Map<String, dynamic>>{};
      for (final m in myCoursesRaw) {
        final name = (m['name'] ?? '').toString().toLowerCase().trim();
        if (name.isNotEmpty) myByName[name] = m;
      }

      final list = <_Course>[];
      for (final c in coursesRaw) {
        final name = (c['name'] ?? '').toString();
        final key = name.toLowerCase().trim();
        final my = myByName[key];

        list.add(_Course.fromJson(
          c,
          students: my?['students'] as List?,
          modules: my?['modules'] as List?,
        ));
      }

      if (!mounted) return;
      setState(() {
        _courses = list;
        _loading = false;
        if (_page >= list.length && list.isNotEmpty) {
          _page = list.length - 1;
        }
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

  void _prevPage() {
    if (_page > 0) setState(() => _page -= 1);
  }

  void _nextPage() {
    if (_page < _courses.length - 1) setState(() => _page += 1);
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
            Text('Students enrolled: ${c.students.length}'),
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
                          error =
                              e.toString().replaceFirst('Exception: ', '');
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
    final total = _courses.length;
    final current = total == 0 ? null : _courses[_page];

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
                children: [
                  const Expanded(
                    child: Text(
                      'Courses',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
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
                const Text('No courses yet.')
              else if (current != null) ...[
                _CourseCard(
                  course: current,
                  onShowDetails: () => _showDetails(current),
                  onEdit: () => _showForm(existing: current),
                  onDelete: () => _remove(current),
                ),
                const SizedBox(height: 20),
                _Pagination(
                  page: _page,
                  total: total,
                  onPrev: _prevPage,
                  onNext: _nextPage,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int page;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: page == 0 ? null : onPrev,
          style: OutlinedButton.styleFrom(
            foregroundColor: purple,
            side: const BorderSide(color: purple),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('← Previous'),
        ),
        const SizedBox(width: 16),
        Text(
          'Page ${page + 1} of $total',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: page >= total - 1 ? null : onNext,
          style: OutlinedButton.styleFrom(
            foregroundColor: purple,
            side: const BorderSide(color: purple),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Next →'),
        ),
      ],
    );
  }
}

class _CourseCard extends StatefulWidget {
  const _CourseCard({
    required this.course,
    required this.onShowDetails,
    required this.onEdit,
    required this.onDelete,
  });

  final _Course course;
  final VoidCallback onShowDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _expanded = true;
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
                  c.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Instructor: ${c.instructor}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                if (c.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    c.description,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),

          _SectionToggle(
            title: 'Students (${c.students.length})',
            expanded: _expanded,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _expanded
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
                                    DataCell(Text(s.fullName.isEmpty
                                        ? '(unnamed)'
                                        : s.fullName)),
                                    DataCell(Text(s.email)),
                                    DataCell(Text(s.section.isEmpty
                                        ? '—'
                                        : s.section)),
                                    DataCell(Text('${s.score}%')),
                                    DataCell(Text(s.grade.isEmpty
                                        ? '—'
                                        : s.grade)),
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
                                  if (m.content.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      m.content,
                                      style: const TextStyle(
                                        color: darkText,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: widget.onShowDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: purple,
                    side: const BorderSide(color: purple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Course Information'),
                ),
                OutlinedButton(
                  onPressed: widget.onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: purple,
                    side: const BorderSide(color: purple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: widget.onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
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

class _Course {
  final String id;
  final String name;
  final String instructor;
  final String description;
  final String grade;
  final int score;
  final List<_Student> students;
  final List<_Module> modules;

  _Course({
    required this.id,
    required this.name,
    required this.instructor,
    required this.description,
    required this.grade,
    required this.score,
    required this.students,
    required this.modules,
  });

  factory _Course.fromJson(
    Map<String, dynamic> json, {
    List? students,
    List? modules,
  }) {
    final parsedStudents = <_Student>[];
    if (students != null) {
      for (final s in students) {
        if (s is Map) {
          parsedStudents
              .add(_Student.fromJson(Map<String, dynamic>.from(s)));
        }
      }
    }

    final parsedModules = <_Module>[];
    if (modules != null) {
      for (final m in modules) {
        if (m is Map) {
          parsedModules.add(_Module.fromJson(Map<String, dynamic>.from(m)));
        }
      }
    }

    return _Course(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? 'Untitled',
      instructor: json['instructor'] ?? 'Unknown',
      description: json['description'] ?? '',
      grade: json['grade'] ?? '-',
      score: (json['score'] is int)
          ? json['score'] as int
          : int.tryParse('${json['score']}') ?? 0,
      students: parsedStudents,
      modules: parsedModules,
    );
  }
}

class _Student {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String section;
  final int score;
  final String grade;

  _Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.section,
    required this.score,
    required this.grade,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory _Student.fromJson(Map<String, dynamic> json) {
    final studentField = json['student'];
    String sid = '';
    String firstName = '';
    String lastName = '';
    String email = '';
    if (studentField is Map) {
      sid = (studentField['_id'] ?? '').toString();
      firstName = (studentField['firstName'] ?? '').toString();
      lastName = (studentField['lastName'] ?? '').toString();
      email = (studentField['email'] ?? '').toString();
    } else if (studentField != null) {
      sid = studentField.toString();
    }

    return _Student(
      id: sid,
      firstName: firstName,
      lastName: lastName,
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