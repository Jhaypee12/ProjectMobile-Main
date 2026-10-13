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
  const CalendarPage({super.key, required this.role});
  final Role role;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Future<List<_CalEvent>> _future;

  bool get canManage => widget.role != Role.student;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_CalEvent>> _load() async {
    final raw = await ApiService.getEvents();
    return raw.map((j) => _CalEvent.fromJson(j)).toList();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _showForm({_CalEvent? existing}) async {
    final isEditing = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final typeCtrl = TextEditingController(text: existing?.type ?? 'Assignment');
    final dateCtrl = TextEditingController(text: existing?.date ?? '');
    String error = '';
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Event' : 'Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Type (Quiz / Assignment / Event)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Date (YYYY-MM-DD)'),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child:
                        Text(error, style: const TextStyle(color: red)),
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
                      if (titleCtrl.text.trim().isEmpty ||
                          dateCtrl.text.trim().isEmpty) {
                        setDialogState(() =>
                            error = 'Title and date are required');
                        return;
                      }
                      
                      final dateOk = RegExp(r'^\d{4}-\d{2}-\d{2}$')
                          .hasMatch(dateCtrl.text.trim());
                      if (!dateOk) {
                        setDialogState(() =>
                            error = 'Date must be YYYY-MM-DD');
                        return;
                      }
                      setDialogState(() => saving = true);
                      try {
                        if (isEditing) {
                          await ApiService.updateEvent(
                            existing.id,
                            title: titleCtrl.text.trim(),
                            type: typeCtrl.text.trim().isEmpty
                                ? 'Event'
                                : typeCtrl.text.trim(),
                            date: dateCtrl.text.trim(),
                          );
                        } else {
                          await ApiService.createEvent(
                            title: titleCtrl.text.trim(),
                            type: typeCtrl.text.trim().isEmpty
                                ? 'Event'
                                : typeCtrl.text.trim(),
                            date: dateCtrl.text.trim(),
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
                  : Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _remove(_CalEvent e) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${e.title}"?'),
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
      await ApiService.deleteEvent(e.id);
      await _refresh();
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $err')),
        );
      }
    }
  }

  void _showEventDetails(_CalEvent e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(e.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${e.type}'),
            const SizedBox(height: 4),
            Text('Date: ${e.date}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (canManage)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showForm(existing: e);
              },
              child: const Text('Edit'),
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
        child: FutureBuilder<List<_CalEvent>>(
          future: _future,
          builder: (context, snapshot) {
            final loading =
                snapshot.connectionState == ConnectionState.waiting;
            final events = snapshot.data ?? [];

            final baseDate = events.isNotEmpty
                ? (DateTime.tryParse(events.first.date) ?? DateTime.now())
                : DateTime.now();
            final year = baseDate.year;
            final month = baseDate.month;

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
                          'Calendar',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        if (canManage)
                          ElevatedButton.icon(
                            onPressed: () => _showForm(),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _monthLabel(year, month),
                      style: const TextStyle(color: darkText, fontSize: 15),
                    ),
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
                          'Could not load events.\n${snapshot.error}',
                          style: const TextStyle(color: red),
                        ),
                      )
                    else
                      _MonthGrid(
                        year: year,
                        month: month,
                        events: events,
                        onEventTap: _showEventDetails,
                        onEventDelete:
                            canManage ? (e) => _remove(e) : null,
                      ),
                  ],
                ),
              ),
            );
          },
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
    required this.events,
    required this.onEventTap,
    this.onEventDelete,
  });

  final int year;
  final int month;
  final List<_CalEvent> events;
  final ValueChanged<_CalEvent> onEventTap;
  final ValueChanged<_CalEvent>? onEventDelete;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leadingBlanks = firstDay.weekday % 7; 

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
                events: _eventsOnDay(d),
                onEventTap: onEventTap,
                onEventDelete: onEventDelete,
              ),
          ],
        ),
      ],
    );
  }

  List<_CalEvent> _eventsOnDay(int day) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
    return events.where((e) => e.date == prefix).toList();
  }
}

class _DayBox extends StatelessWidget {
  const _DayBox({
    required this.day,
    required this.events,
    required this.onEventTap,
    this.onEventDelete,
  });

  final int day;
  final List<_CalEvent> events;
  final ValueChanged<_CalEvent> onEventTap;
  final ValueChanged<_CalEvent>? onEventDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: cardBorder),
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
          for (final e in events)
            GestureDetector(
              onTap: () => onEventTap(e),
              onLongPress: onEventDelete == null
                  ? null
                  : () => onEventDelete!(e),
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: e.type.toLowerCase() == 'quiz' ? purple : blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  e.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalEvent {
  final String id;
  final String title;
  final String type;
  final String date;

  _CalEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
  });

  factory _CalEvent.fromJson(Map<String, dynamic> json) => _CalEvent(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        title: json['title'] ?? '',
        type: json['type'] ?? 'Event',
        date: json['date'] ?? '',
      );
}