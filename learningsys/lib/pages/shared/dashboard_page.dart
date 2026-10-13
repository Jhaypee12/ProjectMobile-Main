import 'package:flutter/material.dart';

import '../../role.dart';
import '../../services/api_service.dart';

const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);
const red = Color(0xFFD32F2F);

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.role,
    required this.onNavigate,
    this.user,
  });

  final Role role;
  final ValueChanged<int> onNavigate;
  final AppUser? user;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<_DashboardData> _future;

  String get _greetingName {
    final u = widget.user;
    if (u != null && u.firstName.isNotEmpty) {
      return '${u.firstName} ${u.lastName}'.trim();
    }
    return switch (widget.role) {
      Role.student => 'Student',
      Role.teacher => 'Teacher',
      Role.admin => 'Admin',
    };
  }

  String get _email {
    final u = widget.user;
    if (u != null && u.email.isNotEmpty) return u.email;
    return widget.role.email;
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<_DashboardData> _load() async {
    final futures = <Future<dynamic>>[
      ApiService.getStats(),
      ApiService.getCourses(),
      ApiService.getAssessments(),
      ApiService.getAnnouncements(),
      ApiService.getGrades().catchError((_) => <Map<String, dynamic>>[]),
      ApiService.getEvents().catchError((_) => <Map<String, dynamic>>[]),
    ];

    if (widget.role == Role.admin) {
      futures.add(
        ApiService.getUsers().catchError((_) => <Map<String, dynamic>>[]),
      );
    }

    final results = await Future.wait(futures);

    var courses = results[1] as List<Map<String, dynamic>>;
    var grades = results[4] as List<Map<String, dynamic>>;

    if (widget.role == Role.teacher) {
      final myName = _greetingName;
      courses = courses
          .where((c) => (c['instructor'] ?? '').toString() == myName)
          .toList();

      final myCourseNames = <String>{};
      final myCourseCodes = <String>{};
      for (final c in courses) {
        final n = (c['name'] ?? '').toString().trim().toLowerCase();
        if (n.isNotEmpty) myCourseNames.add(n);
        final code = (c['code'] ?? '').toString().trim().toLowerCase();
        if (code.isNotEmpty) myCourseCodes.add(code);
      }

      grades = grades.where((g) {
        final gc = (g['course'] ?? '').toString().trim().toLowerCase();
        return myCourseNames.contains(gc) || myCourseCodes.contains(gc);
      }).toList();
    }

    return _DashboardData(
      stats: results[0] as Map<String, dynamic>,
      courses: courses,
      assessments: results[2] as List<Map<String, dynamic>>,
      announcements: results[3] as List<Map<String, dynamic>>,
      grades: grades,
      events: results[5] as List<Map<String, dynamic>>,
      users: widget.role == Role.admin
          ? results[6] as List<Map<String, dynamic>>
          : const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<_DashboardData>(
            future: _future,
            builder: (context, snapshot) {
              final loading =
                  snapshot.connectionState == ConnectionState.waiting;
              final data = snapshot.data;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.role == Role.admin
                          ? 'Admin Dashboard'
                          : 'Dashboard',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _WelcomeCard(name: _greetingName, email: _email),
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
                          'Could not load dashboard.\n${snapshot.error}',
                          style: const TextStyle(color: red),
                        ),
                      )
                    else if (data != null)
                      switch (widget.role) {
                        Role.admin => _AdminBody(
                            data: data,
                            onNavigate: widget.onNavigate,
                          ),
                        Role.teacher => _TeacherBody(
                            data: data,
                            onNavigate: widget.onNavigate,
                          ),
                        Role.student => _StudentBody(
                            data: data,
                            onNavigate: widget.onNavigate,
                          ),
                      },
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


class _DashboardData {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> assessments;
  final List<Map<String, dynamic>> announcements;
  final List<Map<String, dynamic>> grades;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> users;

  _DashboardData({
    required this.stats,
    required this.courses,
    required this.assessments,
    required this.announcements,
    required this.grades,
    required this.events,
    required this.users,
  });
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.name, required this.email});
  final String name;
  final String email;

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
          Text(
            'Welcome back, $name!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: darkText, fontSize: 13),
          ),
          const SizedBox(height: 6),
          const Text(
            "Here's your overview for today.",
            style: TextStyle(color: darkText, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

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
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
      ),
    );
  }
}

class _PrimarySmallButton extends StatelessWidget {
  const _PrimarySmallButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.background,
    required this.textColor,
  });

  final String label;
  final String value;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textColor, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


class _AdminBody extends StatelessWidget {
  const _AdminBody({required this.data, required this.onNavigate});

  final _DashboardData data;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final students =
        data.users.where((u) => u['role'] == 'STUDENT').toList();
    final teachers =
        data.users.where((u) => u['role'] == 'TEACHER').toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;

        final statsRow = Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total Students',
                value: '${students.length}',
                background: purple,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Total Teachers',
                value: '${teachers.length}',
                background: blue,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Total Courses',
                value: '${data.courses.length}',
                background: Colors.white,
                textColor: darkText,
              ),
            ),
          ],
        );

        final lower = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _teachersCard(teachers)),
                  const SizedBox(width: 16),
                  Expanded(child: _coursesCard(data.courses)),
                ],
              )
            : Column(
                children: [
                  _teachersCard(teachers),
                  const SizedBox(height: 16),
                  _coursesCard(data.courses),
                ],
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            statsRow,
            const SizedBox(height: 16),
            lower,
          ],
        );
      },
    );
  }

  Widget _teachersCard(List<Map<String, dynamic>> teachers) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Teachers'),
          if (teachers.isEmpty)
            const Text('No teachers yet.',
                style: TextStyle(color: darkText, fontSize: 13))
          else
            for (var i = 0; i < teachers.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              Builder(builder: (_) {
                final t = teachers[i];
                final name =
                    '${t['firstName'] ?? ''} ${t['lastName'] ?? ''}'.trim();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Unknown' : name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkText,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      (t['email'] ?? '').toString(),
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                );
              }),
            ],
        ],
      ),
    );
  }

  Widget _coursesCard(List<Map<String, dynamic>> courses) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Courses'),
          if (courses.isEmpty)
            const Text('No courses yet.',
                style: TextStyle(color: darkText, fontSize: 13))
          else
            for (var i = 0; i < courses.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              Builder(builder: (_) {
                final c = courses[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (c['name'] ?? 'Untitled').toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: darkText,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      (c['instructor'] ?? '').toString(),
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                );
              }),
            ],
        ],
      ),
    );
  }
}


class _TeacherBody extends StatelessWidget {
  const _TeacherBody({required this.data, required this.onNavigate});

  final _DashboardData data;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final pending = data.grades
        .where((g) => (g['feedback'] ?? '').toString().trim().isEmpty)
        .toList();

    final upcoming = List<Map<String, dynamic>>.from(data.assessments)
      ..sort((a, b) =>
          (a['due'] ?? '').toString().compareTo((b['due'] ?? '').toString()));
    final upcomingShown = upcoming.take(5).toList();

    final recentShown = data.announcements.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;

        final top = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _courseOverview()),
                  const SizedBox(width: 16),
                  Expanded(child: _pendingCard(pending)),
                ],
              )
            : Column(
                children: [
                  _courseOverview(),
                  const SizedBox(height: 16),
                  _pendingCard(pending),
                ],
              );

        final bottom = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _upcomingCard(upcomingShown)),
                  const SizedBox(width: 16),
                  Expanded(child: _recentCard(recentShown)),
                ],
              )
            : Column(
                children: [
                  _upcomingCard(upcomingShown),
                  const SizedBox(height: 16),
                  _recentCard(recentShown),
                ],
              );

        return Column(
          children: [
            top,
            const SizedBox(height: 16),
            bottom,
          ],
        );
      },
    );
  }

  Widget _courseOverview() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Course Overview'),
          if (data.courses.isEmpty)
            const Text('No courses assigned to you yet.',
                style: TextStyle(color: darkText, fontSize: 13))
          else
            for (var i = 0; i < data.courses.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _CourseRow(course: data.courses[i]),
            ],
        ],
      ),
    );
  }

  Widget _pendingCard(List<Map<String, dynamic>> pending) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader('Pending Submissions (${pending.length})'),
          if (pending.isEmpty)
            const Text('Nothing to grade.',
                style: TextStyle(color: darkText, fontSize: 13))
          else
            for (var i = 0; i < pending.take(5).length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _PendingRow(g: pending[i]),
            ],
          const SizedBox(height: 14),
          _PrimarySmallButton(
            label: 'OPEN GRADEBOOK',
            onPressed: () => onNavigate(3),
          ),
        ],
      ),
    );
  }

  Widget _upcomingCard(List<Map<String, dynamic>> upcoming) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Upcoming Deadlines'),
          if (upcoming.isEmpty)
            const Text('No upcoming deadlines.',
                style: TextStyle(color: darkText, fontSize: 13))
          else
            for (var i = 0; i < upcoming.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _DeadlineRow(a: upcoming[i]),
            ],
          const SizedBox(height: 14),
          _PrimarySmallButton(
            label: 'VIEW ALL',
            onPressed: () => onNavigate(2),
          ),
        ],
      ),
    );
  }

  Widget _recentCard(List<Map<String, dynamic>> recent) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Recent Activity'),
          if (recent.isEmpty)
            const Text('No recent activity.',
                style: TextStyle(color: darkText, fontSize: 13))
          else
            for (var i = 0; i < recent.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ActivityRow(a: recent[i]),
            ],
        ],
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({required this.course});
  final Map<String, dynamic> course;

  @override
  Widget build(BuildContext context) {
    final name = (course['name'] ?? 'Untitled').toString();
    final code = (course['code'] ?? '').toString();

    final enrolled = course['enrolledStudentIds'];
    int count = 0;
    if (enrolled is List) count = enrolled.length;

    return Text(
      '$name ${code.isNotEmpty ? '($code)' : ''} - $count students',
      style: const TextStyle(
        color: darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({required this.g});
  final Map<String, dynamic> g;

  @override
  Widget build(BuildContext context) {
    final student = g['student'];
    String studentName = 'Unknown';
    if (student is Map) {
      final f = student['firstName'] ?? '';
      final l = student['lastName'] ?? '';
      studentName = '$f $l'.trim();
      if (studentName.isEmpty) studentName = '(unknown)';
    }

    final course = (g['course'] ?? '').toString();
    final submission = (g['submission'] ?? '').toString();

    return Text(
      '$studentName - $submission ($course)',
      style: const TextStyle(color: darkText, fontSize: 13),
    );
  }
}

class _DeadlineRow extends StatelessWidget {
  const _DeadlineRow({required this.a});
  final Map<String, dynamic> a;

  @override
  Widget build(BuildContext context) {
    final name = (a['name'] ?? 'Untitled').toString();
    final course = (a['course'] ?? '').toString();
    final section = (a['section'] ?? '').toString();
    final due = (a['due'] ?? '').toString();

    final parts = <String>[];
    if (course.isNotEmpty) parts.add(course);
    parts.add(name);
    if (section.isNotEmpty) parts.add(section);
    if (due.isNotEmpty) parts.add('($due)');

    return Text(
      parts.join(' - '),
      style: const TextStyle(color: darkText, fontSize: 13.5),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.a});
  final Map<String, dynamic> a;

  @override
  Widget build(BuildContext context) {
    final title = (a['title'] ?? 'Untitled').toString();
    final course = (a['course'] ?? 'ALL').toString();
    final date = (a['date'] ?? '').toString();

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: darkText, fontSize: 13.5),
        children: [
          TextSpan(
            text: title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' - $course ($date)'),
        ],
      ),
    );
  }
}


class _StudentBody extends StatelessWidget {
  const _StudentBody({required this.data, required this.onNavigate});

  final _DashboardData data;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final avg = (data.stats['averageGrade'] ?? 0);
    final enrolled = (data.stats['enrolledCourses'] ?? 0);
    final due = (data.stats['dueThisWeek'] ?? 0);

    final upcoming = List<Map<String, dynamic>>.from(data.assessments)
      ..sort((a, b) =>
          (a['due'] ?? '').toString().compareTo((b['due'] ?? '').toString()));
    final upcomingShown = upcoming.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;

        final statsRow = Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Average Grade',
                value: '$avg%',
                background: purple,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Enrolled Courses',
                value: '$enrolled',
                background: blue,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Due This Week',
                value: '$due',
                background: Colors.white,
                textColor: darkText,
              ),
            ),
          ],
        );

        final lower = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _enrolledCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _upcomingCard(upcomingShown)),
                ],
              )
            : Column(
                children: [
                  _enrolledCard(),
                  const SizedBox(height: 16),
                  _upcomingCard(upcomingShown),
                ],
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            statsRow,
            const SizedBox(height: 16),
            lower,
          ],
        );
      },
    );
  }

  Widget _enrolledCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Enrolled Courses'),
          if (data.courses.isEmpty)
            const Text('No courses yet.',
                style: TextStyle(color: darkText, fontSize: 13))
          else
            for (var i = 0; i < data.courses.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Text(
                (data.courses[i]['name'] ?? 'Untitled').toString(),
                style: const TextStyle(color: darkText, fontSize: 14),
              ),
            ],
        ],
      ),
    );
  }

  Widget _upcomingCard(List<Map<String, dynamic>> upcoming) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Upcoming Assignment Deadlines'),
          if (upcoming.isEmpty)
            const Text('No upcoming deadlines.',
                style: TextStyle(color: darkText, fontSize: 13))
          else
            for (var i = 0; i < upcoming.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _DeadlineRow(a: upcoming[i]),
            ],
          const SizedBox(height: 14),
          _PrimarySmallButton(
            label: 'VIEW ALL',
            onPressed: () => onNavigate(3),
          ),
        ],
      ),
    );
  }
}