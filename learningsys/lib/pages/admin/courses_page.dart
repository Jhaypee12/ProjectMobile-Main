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
            const SizedBox(height: 4),
            Text('Enrolled: ${c.students.length}'),
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
              else
                for (final c in _courses) ...[
                  _CourseCard(
                    course: c,
                    onShowDetails: () => _showDetails(c),
                    onEdit: () => _showForm(existing: c),
                    onDelete: () => _remove(c),
                  ),
                  const SizedBox(height: 16),
                ],
            ],
          ),
        ),
      ),
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
  bool _expanded = false;

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
          
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Instructor: ${c.instructor}  •  ${c.grade} (${c.score}%)',
                    style: const TextStyle(color: darkText, fontSize: 13.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${c.students.length} student${c.students.length == 1 ? '' : 's'} enrolled',
                    style: const TextStyle(color: darkText, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, color: cardBorder),
                        const SizedBox(height: 14),
                        Text(
                          'Students (${c.students.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: darkText,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (c.students.isEmpty)
                          const Text(
                            'No students enrolled yet.',
                            style:
                                TextStyle(color: darkText, fontSize: 13),
                          )
                        else
                          for (final s in c.students)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: purple,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.fullName.isEmpty
                                              ? '(unnamed)'
                                              : s.fullName,
                                          style: const TextStyle(
                                            color: darkText,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          s.email,
                                          style: const TextStyle(
                                            color: darkText,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        const SizedBox(height: 16),
                        Wrap(
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
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
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

  _Course({
    required this.id,
    required this.name,
    required this.instructor,
    required this.description,
    required this.grade,
    required this.score,
    required this.students,
  });

  factory _Course.fromJson(Map<String, dynamic> json) {
    final rawEnrolled = json['enrolledStudentIds'];
    final parsed = <_Student>[];
    if (rawEnrolled is List) {
      for (final item in rawEnrolled) {
        if (item is Map) {
         parsed.add(_Student.fromJson(Map<String, dynamic>.from(item)));
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
      students: parsed,
    );
  }
}

class _Student {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  _Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory _Student.fromJson(Map<String, dynamic> json) => _Student(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        email: json['email'] ?? '',
      );
}