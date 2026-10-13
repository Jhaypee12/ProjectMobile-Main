import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import 'common.dart';
import 'ui.dart';

enum EventKind { deadline, quiz, assignment, submission, meeting }

extension EventKindInfo on EventKind {
  String get label => switch (this) {
        EventKind.deadline => 'Deadline',
        EventKind.quiz => 'Quiz',
        EventKind.assignment => 'Assignment',
        EventKind.submission => 'Submissions',
        EventKind.meeting => 'Meeting',
      };

  Color get color => switch (this) {
        EventKind.deadline => AppColors.purple,
        EventKind.quiz => AppColors.blue,
        EventKind.assignment => const Color(0xFF9B7DE8),
        EventKind.submission => const Color(0xFF9B7DE8),
        EventKind.meeting => AppColors.muted,
      };

  IconData get icon => switch (this) {
        EventKind.deadline => Icons.flag_rounded,
        EventKind.quiz => Icons.quiz_outlined,
        EventKind.assignment => Icons.assignment_outlined,
        EventKind.submission => Icons.inbox_outlined,
        EventKind.meeting => Icons.groups_outlined,
      };
}

class CalEvent {
  const CalEvent(this.day, this.kind, this.title, this.course, this.time);
  final int day;
  final EventKind kind;
  final String title, course, time;
}

/// Month grid for October 2026 (starts on a Thursday, today is the 4th).
class CalendarView extends StatefulWidget {
  const CalendarView({super.key, required this.events, required this.kinds});
  final List<CalEvent> events;
  final List<EventKind> kinds;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  static const _today = 4;
  static const _startOffset = 4; // Sunday-first, Oct 1 is a Thursday
  static const _days = 31;
  int _selected = _today;

  List<CalEvent> _on(int day) =>
      widget.events.where((e) => e.day == day).toList();

  void _openDay(int day) {
    setState(() => _selected = day);
    final items = _on(day);
    showDetails(
      context,
      icon: Icons.event_rounded,
      title: 'October $day, 2026',
      subtitle: items.isEmpty
          ? 'Nothing scheduled'
          : '${items.length} ${items.length == 1 ? 'item' : 'items'}',
      body: items.isEmpty ? 'This day is free.' : null,
      extra: items.isEmpty
          ? null
          : Column(children: [for (final e in items) _EventRow(event: e)]),
    );
  }

  Widget _cell(int day) {
    if (day < 1 || day > _days) {
      return const Expanded(child: SizedBox(height: 48));
    }
    final selected = day == _selected;
    final isToday = day == _today;
    final kinds = _on(day).map((e) => e.kind).toSet().take(3).toList();
    return Expanded(
      child: GestureDetector(
        onTap: () => _openDay(day),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: selected ? AppColors.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isToday && !selected
                ? Border.all(color: AppColors.purple, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$day',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.ink)),
              const SizedBox(height: 3),
              SizedBox(
                height: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final k in kinds)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? Colors.white : k.color,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final rows = ((_startOffset + _days) / 7).ceil();
    final upcoming = widget.events.where((e) => e.day >= _today).toList()
      ..sort((a, b) => a.day.compareTo(b.day));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => showToast(context, 'Other months come later'),
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: AppColors.purple),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('October 2026',
                          style: GoogleFonts.bricolageGrotesque(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  IconButton(
                    onPressed: () => showToast(context, 'Other months come later'),
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.purple),
                  ),
                ],
              ),
              Row(
                children: [
                  for (final d in weekdays)
                    Expanded(
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              for (var r = 0; r < rows; r++)
                Row(
                  children: [
                    for (var c = 0; c < 7; c++)
                      _cell(r * 7 + c - _startOffset + 1),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            for (final k in widget.kinds)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: k.color),
                  ),
                  const SizedBox(width: 6),
                  Text(k.label,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12.5)),
                ],
              ),
          ],
        ),
        const SectionTitle('Coming up'),
        for (final e in upcoming)
          NavTile(
            icon: e.kind.icon,
            accent: e.kind.color,
            title: e.title,
            subtitle: 'Oct ${e.day}, ${e.time}',
            trailing: Pill(e.kind.label),
            onTap: () => _openDay(e.day),
          ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});
  final CalEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.iceSoft, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(event.kind.icon, color: event.kind.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${event.course}, ${event.time}',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Pill(event.kind.label),
        ],
      ),
    );
  }
}