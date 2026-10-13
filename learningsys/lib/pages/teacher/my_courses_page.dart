import 'package:flutter/material.dart';

const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = [
      _Course(
        name: 'Intro to Data Analysis',
        code: 'DATA101',
        description:
            'Learn the basics of data analysis using spreadsheets and charts.',
        students: [
          _Student('Maya', 'Santos', 'maya@school.edu', 92, 'A'),
          _Student('Leo', 'Alvarez', 'leo@school.edu', 85, 'B'),
        ],
        modules: [
          _Module('Week 1: Getting started', 'Introduction to spreadsheets.'),
          _Module('Week 2: Charts', 'Bar charts, line charts and pie charts.'),
        ],
      ),
      _Course(
        name: 'UX Design Foundations',
        code: 'UX201',
        description: 'A beginner course on designing user interfaces.',
        students: [
          _Student('Priya', 'Nair', 'priya@school.edu', 88, 'B'),
        ],
        modules: [
          _Module('Week 1: What is UX?', 'Understanding user experience.'),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: lightBlue,
      body: SafeArea(
        child: SingleChildScrollView(
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
              for (final c in courses) ...[
                _CourseBanner(course: c),
                const SizedBox(height: 20),
                _StudentsTable(course: c),
                const SizedBox(height: 20),
                _CourseContent(course: c),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Course {
  const _Course({
    required this.name,
    required this.code,
    required this.description,
    required this.students,
    required this.modules,
  });

  final String name;
  final String code;
  final String description;
  final List<_Student> students;
  final List<_Module> modules;
}

class _Student {
  const _Student(
    this.firstName,
    this.lastName,
    this.email,
    this.score,
    this.grade,
  );

  final String firstName;
  final String lastName;
  final String email;
  final int score;
  final String grade;
}

class _Module {
  const _Module(this.title, this.content);
  final String title;
  final String content;
}

class _CourseBanner extends StatelessWidget {
  const _CourseBanner({required this.course});
  final _Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: purple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${course.name} (${course.code})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${course.students.length} students enrolled',
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton(
                onPressed: () => _showInfo(context, course),
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
                onPressed: () => _showAnnounce(context, course),
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
    );
  }
}

class _StudentsTable extends StatelessWidget {
  const _StudentsTable({required this.course});
  final _Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Students',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 16),
          for (final s in course.students)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${s.firstName} ${s.lastName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkText,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.email,
                    style: const TextStyle(color: darkText, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Score: ${s.score}%',
                        style: const TextStyle(color: darkText, fontSize: 13),
                      ),
                      Text(
                        'Grade: ${s.grade}',
                        style: const TextStyle(color: darkText, fontSize: 13),
                      ),
                      OutlinedButton(
                        onPressed: () => _showGrade(context, course, s),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: purple,
                          side: const BorderSide(color: purple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text('Details'),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: cardBorder),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CourseContent extends StatelessWidget {
  const _CourseContent({required this.course});
  final _Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Course Content',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 16),
          for (final m in course.modules)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showLesson(context, m),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Preview Lesson',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Divider(height: 24, color: cardBorder),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

void _showInfo(BuildContext context, _Course course) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Course Information'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${course.name} (${course.code})',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(course.description),
          const SizedBox(height: 8),
          Text('Students enrolled: ${course.students.length}'),
          const SizedBox(height: 4),
          Text('Modules: ${course.modules.length}'),
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

void _showAnnounce(BuildContext context, _Course course) {
  final titleController = TextEditingController();
  final messageController = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Post Announcement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: messageController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Announcement posted')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Post'),
        ),
      ],
    ),
  );
}

void _showGrade(BuildContext context, _Course course, _Student s) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Grade Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student: ${s.firstName} ${s.lastName}'),
          const SizedBox(height: 4),
          Text('Email: ${s.email}'),
          const SizedBox(height: 4),
          Text('Course: ${course.name}'),
          const SizedBox(height: 4),
          Text('Score: ${s.score}%'),
          const SizedBox(height: 4),
          Text('Grade: ${s.grade}'),
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

void _showLesson(BuildContext context, _Module m) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(m.title),
      content: Text(m.content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}