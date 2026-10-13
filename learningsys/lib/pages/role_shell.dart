import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../role.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/ui.dart';
import 'admin/announcements_page.dart';
import 'admin/courses_page.dart';
import 'shared/assessments_page.dart';
import 'shared/calendar_page.dart';
import 'shared/dashboard_page.dart';
import 'student/my_learning_page.dart';
import 'teacher/gradebook_page.dart';
import 'teacher/my_courses_page.dart';

class _Tab {
  const _Tab(this.label, this.icon, this.page);
  final String label;
  final IconData icon;
  final Widget page;
}

class RoleShell extends StatefulWidget {
  const RoleShell({super.key, required this.role, this.user});

  final Role role;

  final AppUser? user;

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  String get _initials {
    final u = widget.user;
    if (u == null) return widget.role.initials;
    final f = u.firstName.isNotEmpty ? u.firstName[0].toUpperCase() : '';
    final l = u.lastName.isNotEmpty ? u.lastName[0].toUpperCase() : '';
    final result = '$f$l';
    return result.isEmpty ? widget.role.initials : result;
  }

  void _openProfile() {
    Navigator.of(context).pushNamed(
      '/profile',
      arguments: {'role': widget.role, 'user': widget.user},
    );
  }

  List<_Tab> _tabs() {
    switch (widget.role) {
      case Role.student:
        return [
          _Tab(
            'Dashboard',
            Icons.dashboard_rounded,
            DashboardPage(
              role: Role.student,
              user: widget.user,
              onNavigate: _go,
            ),
          ),
          const _Tab('My Learning', Icons.school_rounded, MyLearningPage()),
          const _Tab('Assessments', Icons.assignment_rounded,
              AssessmentsPage(role: Role.student)),
          const _Tab('Calendar', Icons.calendar_month_rounded,
              CalendarPage(role: Role.student)),
        ];
      case Role.teacher:
        return [
          _Tab(
            'Dashboard',
            Icons.dashboard_rounded,
            DashboardPage(
              role: Role.teacher,
              user: widget.user,
              onNavigate: _go,
            ),
          ),
          const _Tab('My Courses', Icons.menu_book_rounded, MyCoursesPage()),
          const _Tab('Assessments', Icons.assignment_rounded,
              AssessmentsPage(role: Role.teacher)),
          const _Tab('Gradebook', Icons.grading_rounded, GradebookPage()),
          const _Tab('Calendar', Icons.calendar_month_rounded,
              CalendarPage(role: Role.teacher)),
        ];
      case Role.admin:
        return [
          _Tab(
            'Dashboard',
            Icons.dashboard_rounded,
            DashboardPage(
              role: Role.admin,
              user: widget.user,
              onNavigate: _go,
            ),
          ),
          const _Tab(
              'Courses', Icons.library_books_rounded, AdminCoursesPage()),
          const _Tab('Assessments', Icons.assignment_rounded,
              AssessmentsPage(role: Role.admin)),
          const _Tab('Announcements', Icons.campaign_rounded,
              AnnouncementsPage()),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    final tabs = _tabs();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${role.label} portal',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 13)),
                        Text(
                          tabs[_index].label,
                          style: GoogleFonts.bricolageGrotesque(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _openProfile,
                    child: AppAvatar(_initials, size: 44),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: [for (final t in tabs) t.page],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppNavBar(
        items: [for (final t in tabs) NavItem(t.label, t.icon)],
        selectedIndex: _index,
        onSelected: _go,
      ),
    );
  }
}