import 'package:flutter/material.dart';

import '../../services/api_service.dart';

const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);
const red = Color(0xFFD93B3B);

class GradebookPage extends StatefulWidget {
  const GradebookPage({super.key});

  @override
  State<GradebookPage> createState() => _GradebookPageState();
}

class _GradebookPageState extends State<GradebookPage> {
  List<_Grade> _grades = [];
  bool _loading = true;
  Object? _error;
  List<AppUser> _students = [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadStudents();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ApiService.getGrades();
      if (!mounted) return;
      setState(() {
        _grades = raw.map((j) => _Grade.fromJson(j)).toList();
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

  Future<void> _loadStudents() async {
    try {
      final raw = await ApiService.getUsers();
      final users = raw.map((j) => AppUser.fromJson(j)).toList();
      if (mounted) {
        setState(() {
          _students = users
              .where((u) => u.role.toUpperCase() == 'STUDENT')
              .toList();
        });
      }
    } catch (_) {

    }
  }

  Future<void> _refresh() async {
    await _load();
  }

  double _average(List<_Grade> grades) {
    if (grades.isEmpty) return 0;
    var sum = 0.0;
    var count = 0;
    for (final g in grades) {
      if (g.total == 0) continue;
      sum += g.score / g.total * 100;
      count++;
    }
    return count == 0 ? 0 : sum / count;
  }

  void _showFeedback(_Grade g) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${g.studentName}'),
            const SizedBox(height: 4),
            Text('Submission: ${g.submission}'),
            const SizedBox(height: 4),
            Text('Course: ${g.course}'),
            const SizedBox(height: 4),
            Text('Score: ${g.score} / ${g.total}'),
            const SizedBox(height: 4),
            Text(
              'Feedback: ${g.feedback.isEmpty ? "No feedback yet" : g.feedback}',
            ),
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

  Future<void> _showForm({_Grade? existing}) async {
    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No students found. Add students first.')),
      );
      return;
    }

    final isEditing = existing != null;
    String? selectedStudentId = existing?.studentId;
    if (selectedStudentId != null &&
        !_students.any((s) => s.id == selectedStudentId)) {
      selectedStudentId = null;
    }
    selectedStudentId ??= _students.first.id;

    final courseCtrl = TextEditingController(text: existing?.course ?? '');
    final submissionCtrl =
        TextEditingController(text: existing?.submission ?? '');
    final scoreCtrl = TextEditingController(
        text: existing?.score.toString() ?? '0');
    final totalCtrl = TextEditingController(
        text: existing?.total.toString() ?? '100');
    final feedbackCtrl =
        TextEditingController(text: existing?.feedback ?? '');
    String error = '';
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Grade' : 'Add Grade'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedStudentId,
                  decoration: const InputDecoration(labelText: 'Student'),
                  items: [
                    for (final s in _students)
                      DropdownMenuItem(
                        value: s.id,
                        child: Text(s.fullName.isEmpty
                            ? s.email
                            : s.fullName),
                      ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selectedStudentId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Course (e.g. CS201)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: submissionCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Submission / Assessment'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: scoreCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Score'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: totalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: feedbackCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Feedback (optional)'),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(error,
                        style: const TextStyle(color: red)),
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
                      if (courseCtrl.text.trim().isEmpty ||
                          submissionCtrl.text.trim().isEmpty) {
                        setDialogState(() => error =
                            'Course and submission are required');
                        return;
                      }
                      final score = int.tryParse(scoreCtrl.text.trim());
                      final total = int.tryParse(totalCtrl.text.trim());
                      if (score == null || total == null) {
                        setDialogState(() =>
                            error = 'Score and total must be numbers');
                        return;
                      }
                      setDialogState(() => saving = true);
                      try {
                        if (isEditing) {
                          await ApiService.updateGrade(
                            existing.id,
                            course: courseCtrl.text.trim(),
                            studentId: selectedStudentId!,
                            submission: submissionCtrl.text.trim(),
                            score: score,
                            total: total,
                            feedback: feedbackCtrl.text.trim(),
                          );
                        } else {
                          await ApiService.createGrade(
                            course: courseCtrl.text.trim(),
                            studentId: selectedStudentId!,
                            submission: submissionCtrl.text.trim(),
                            score: score,
                            total: total,
                            feedback: feedbackCtrl.text.trim(),
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
                  : Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _remove(_Grade g) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Grade'),
        content: Text('Delete "${g.submission}" for ${g.studentName}?'),
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
      await ApiService.deleteGrade(g.id);
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
    final avg = _average(_grades);

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
                  'Gradebook',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: purple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'All Courses',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Class average: ${avg.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
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
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Course Grades',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showForm(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Add Grade'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                              child: CircularProgressIndicator()),
                        )
                      else if (_error != null)
                        Text(
                          'Could not load grades.\n$_error',
                          style: const TextStyle(color: red),
                        )
                      else if (_grades.isEmpty)
                        const Text('No grades yet.')
                      else
                        for (final g in _grades)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g.studentName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: darkText),
                                ),
                                Text(
                                  '${g.course} • ${g.submission} • ${g.score}/${g.total}',
                                  style: const TextStyle(
                                      color: darkText, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _showFeedback(g),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blue,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Feedback'),
                                    ),
                                    OutlinedButton(
                                      onPressed: () =>
                                          _showForm(existing: g),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: purple,
                                        side: const BorderSide(
                                            color: purple),
                                      ),
                                      child: const Text('Edit'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _remove(g),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: red,
                                        foregroundColor: Colors.white,
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
      ),
    );
  }
}

class _Grade {
  final String id;
  final String course;
  final String studentId;
  final String studentName;
  final String submission;
  final int score;
  final int total;
  final String feedback;

  _Grade({
    required this.id,
    required this.course,
    required this.studentId,
    required this.studentName,
    required this.submission,
    required this.score,
    required this.total,
    required this.feedback,
  });

  factory _Grade.fromJson(Map<String, dynamic> json) {

    final studentField = json['student'];
    String studentId = '';
    String studentName = '(unknown)';
    if (studentField is Map) {
      studentId = (studentField['_id'] ?? '').toString();
      final f = studentField['firstName'] ?? '';
      final l = studentField['lastName'] ?? '';
      studentName = '$f $l'.trim();
      if (studentName.isEmpty) {
        studentName = studentField['email'] ?? '(unknown)';
      }
    } else if (studentField != null) {
      studentId = studentField.toString();
    }

    return _Grade(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      course: json['course'] ?? '',
      studentId: studentId,
      studentName: studentName,
      submission: json['submission'] ?? '',
      score: (json['score'] is int)
          ? json['score'] as int
          : int.tryParse('${json['score']}') ?? 0,
      total: (json['total'] is int)
          ? json['total'] as int
          : int.tryParse('${json['total']}') ?? 0,
      feedback: json['feedback'] ?? '',
    );
  }
}