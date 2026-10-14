import 'package:flutter/material.dart';

import '../../role.dart';
import '../../services/api_service.dart';

const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);
const red = Color(0xFFD32F2F);

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.role, this.user});
  final Role role;
  final AppUser? user;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<_CalAssessment> _assessments = [];
  bool _loading = true;
  Object? _error;

  late int _year;
  late int _month;

  bool get canManage => widget.role != Role.student;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ApiService.getAssessments(
        studentId: widget.role == Role.student ? widget.user?.id : null,
      );
      if (!mounted) return;
      setState(() {
        _assessments = raw.map((j) => _CalAssessment.fromJson(j)).toList();
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

  void _prevMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year -= 1;
      } else {
        _month -= 1;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year += 1;
      } else {
        _month += 1;
      }
    });
  }

  void _showDetails(_CalAssessment a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(a.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.course.isNotEmpty) Text('Course: ${a.course}'),
            if (a.section.isNotEmpty) Text('Section: ${a.section}'),
            Text('Type: ${a.type}'),
            const SizedBox(height: 4),
            Text('Due: ${a.due}'),
            if (a.status.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Status: ${a.status}'),
            ],
            if (a.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(a.description),
            ],
            const SizedBox(height: 12),
            const Text(
              '(Manage on the Assessments page)',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: darkText,
                  fontSize: 12),
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
                  'Calendar',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    OutlinedButton(
                      onPressed: _prevMonth,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: purple,
                        side: const BorderSide(color: purple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Prev'),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _monthLabel(_year, _month),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _nextMonth,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: purple,
                        side: const BorderSide(color: purple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Next'),
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
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Could not load calendar.\n$_error',
                      style: const TextStyle(color: red),
                    ),
                  )
                else
                  _MonthGrid(
                    year: _year,
                    month: _month,
                    assessments: _assessments,
                    showSection: canManage,
                    onTap: _showDetails,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _monthLabel(int year, int month) {
  const names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${names[month - 1]} $year';
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.year,
    required this.month,
    required this.assessments,
    required this.showSection,
    required this.onTap,
  });

  final int year;
  final int month;
  final List<_CalAssessment> assessments;
  final bool showSection;
  final ValueChanged<_CalAssessment> onTap;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leadingBlanks = firstDay.weekday % 7;
    final today = DateTime.now();

    return Column(
      children: [
        Row(
          children: [
            for (final w in weekdays)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    w,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 0.55,
          children: [
            for (var i = 0; i < leadingBlanks; i++) const SizedBox(),
            for (var d = 1; d <= daysInMonth; d++)
              _DayBox(
                day: d,
                isToday: today.year == year &&
                    today.month == month &&
                    today.day == d,
                assessments: _assessmentsOnDay(d),
                showSection: showSection,
                onTap: onTap,
              ),
          ],
        ),
      ],
    );
  }

  List<_CalAssessment> _assessmentsOnDay(int day) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
    return assessments.where((a) => a.due == prefix).toList();
  }
}

class _DayBox extends StatelessWidget {
  const _DayBox({
    required this.day,
    required this.isToday,
    required this.assessments,
    required this.showSection,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final List<_CalAssessment> assessments;
  final bool showSection;
  final ValueChanged<_CalAssessment> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isToday ? purple : cardBorder,
          width: isToday ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$day',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: darkText,
              fontSize: 13,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final a in assessments)
                    GestureDetector(
                      onTap: () => onTap(a),
                      child: Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: a.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _label(a),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 9),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(_CalAssessment a) {
    final parts = <String>[];
    if (a.course.isNotEmpty) parts.add(a.course);
    parts.add(a.name);
    if (showSection && a.section.isNotEmpty) parts.add(a.section);
    return parts.join(' - ');
  }
}

class _CalAssessment {
  final String id;
  final String name;
  final String course;
  final String section;
  final String type;
  final String due;
  final String status;
  final String description;

  _CalAssessment({
    required this.id,
    required this.name,
    required this.course,
    required this.section,
    required this.type,
    required this.due,
    required this.status,
    required this.description,
  });

  factory _CalAssessment.fromJson(Map<String, dynamic> json) => _CalAssessment(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: json['name'] ?? '',
        course: json['course'] ?? '',
        section: json['section'] ?? '',
        type: json['type'] ?? 'Assignment',
        due: json['due'] ?? '',
        status: json['status'] ?? '',
        description: json['description'] ?? '',
      );

  Color get color => type.toLowerCase() == 'quiz' ? purple : blue;
}