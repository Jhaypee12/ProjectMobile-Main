import 'package:flutter/material.dart';

import '../../services/api_service.dart';

const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);

class MyLearningPage extends StatefulWidget {
  const MyLearningPage({super.key});

  @override
  State<MyLearningPage> createState() => _MyLearningPageState();
}

class _MyLearningPageState extends State<MyLearningPage> {
  late Future<List<_Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _loadCourses();
  }

  Future<List<_Course>> _loadCourses() async {
    final raw = await ApiService.getCourses();
    return raw.map((json) => _Course.fromJson(json)).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _coursesFuture = _loadCourses();
    });
    await _coursesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<_Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 56, color: darkText),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load courses.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: darkText),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return const Center(child: Text('No courses yet.'));
          }

          final average = courses.map((c) => c.score).reduce((a, b) => a + b) /
              courses.length;

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
                        'My Learning',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _termGrades(context, courses, average),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: purple,
                          side: const BorderSide(color: purple),
                        ),
                        child: const Text('Term Grades'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  for (final c in courses) ...[
                    _CourseCard(course: c),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Course {
  final String name;
  final String instructor;
  final String grade;
  final int score;
  final String description;

  _Course({
    required this.name,
    required this.instructor,
    required this.grade,
    required this.score,
    required this.description,
  });

  factory _Course.fromJson(Map<String, dynamic> json) => _Course(
        name: json['name'] ?? 'Untitled course',
        instructor: json['instructor'] ?? 'Unknown',
        grade: json['grade'] ?? '-',
        score: (json['score'] is int)
            ? json['score'] as int
            : int.tryParse('${json['score']}') ?? 0,
        description: json['description'] ?? '',
      );
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final _Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: purple,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            course.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Instructor: ${course.instructor}',
            style: const TextStyle(color: darkText, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            'Grade: ${course.grade} (${course.score}%)',
            style: const TextStyle(color: darkText, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showDetails(context, course),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Course Details',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showDetails(BuildContext context, _Course course) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(course.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.description),
          const SizedBox(height: 12),
          Text('Instructor: ${course.instructor}'),
          const SizedBox(height: 4),
          Text('Grade: ${course.grade} (${course.score}%)'),
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

void _termGrades(
    BuildContext context, List<_Course> courses, double average) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Term Grades'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text('Subject',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Text('Score',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Text('Grade',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(),
            for (final c in courses)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(c.name)),
                    Expanded(
                      child:
                          Text('${c.score}%', textAlign: TextAlign.center),
                    ),
                    Expanded(
                      child: Text(c.grade, textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text('Average',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: Text(
                      '${average.toStringAsFixed(2)}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Expanded(child: Text('')),
                ],
              ),
            ),
          ],
        ),
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