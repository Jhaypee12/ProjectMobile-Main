import 'package:flutter/material.dart';

import '../../role.dart';
import '../../services/api_service.dart';

const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);

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
  late Future<Map<String, dynamic>> _statsFuture;

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
    _statsFuture = ApiService.getStats();
  }

  Future<void> _refresh() async {
    setState(() => _statsFuture = ApiService.getStats());
    await _statsFuture;
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
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 20),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, $_greetingName!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _email,
                        style: const TextStyle(color: darkText, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Here's your overview for today.",
                        style: TextStyle(color: darkText, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<Map<String, dynamic>>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    final loading = snapshot.connectionState ==
                        ConnectionState.waiting;
                    final stats = snapshot.data ?? {};
                    final avg = loading
                        ? '—'
                        : '${(stats['averageGrade'] ?? 0)}%';
                    final enrolled =
                        loading ? '—' : '${stats['enrolledCourses'] ?? 0}';
                    final due = loading
                        ? '—'
                        : '${stats['dueThisWeek'] ?? 0}';

                    return Column(
                      children: [
                        _StatCard(
                          label: 'Average Grade',
                          value: avg,
                          background: purple,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        _StatCard(
                          label: 'Enrolled Courses',
                          value: enrolled,
                          background: blue,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        _StatCard(
                          label: 'Due This Week',
                          value: due,
                          background: Colors.white,
                          textColor: darkText,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Links',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Use the tabs below to explore courses, assessments, calendar, and more.',
                        style: TextStyle(color: darkText, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textColor, fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}