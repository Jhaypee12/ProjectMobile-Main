import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/calendar_view.dart';
import '../widgets/common.dart';
import '../widgets/ui.dart';


class _Course {
  const _Course(this.title, this.instructor, this.progress, this.grade,
      this.icon, this.done, this.total, this.lessons);
  final String title, instructor, grade;
  final double progress;
  final IconData icon;
  final int done, total;
  final List<(String, bool)> lessons;
}

const _courses = [
  _Course('Intro to Data Analysis', 'Dr. Maya Santos', 0.58, 'A-',
      Icons.bar_chart_rounded, 7, 12, [
    ('Spreadsheet basics', true),
    ('Cleaning messy data', true),
    ('Pivot tables', false),
    ('Charts that communicate', false),
  ]),
  _Course('UX Design Foundations', 'Leo Alvarez', 0.72, 'B+',
      Icons.palette_outlined, 13, 18, [
    ('Understanding users', true),
    ('Wireframing', true),
    ('Prototyping', false),
    ('Usability testing', false),
  ]),
  _Course('Statistics for Everyone', 'Ana Cruz', 0.40, 'B',
      Icons.functions_rounded, 6, 16, [
    ('Describing data', true),
    ('Probability basics', true),
    ('Sampling', false),
    ('Hypothesis tests', false),
  ]),
  _Course('Academic Writing Essentials', 'Prof. Jun Reyes', 0.90, 'A',
      Icons.edit_note_rounded, 9, 10, [
    ('Structuring an argument', true),
    ('Citing sources', true),
    ('Editing and revising', true),
    ('Final essay', false),
  ]),
];

class _Item {
  const _Item(this.title, this.course, this.isQuiz, this.status, this.due,
      [this.score]);
  final String title, course, status, due;
  final bool isQuiz;
  final String? score;
}

const _items = [
  _Item('Data cleaning worksheet', 'Intro to Data Analysis', false, 'Pending',
      'Oct 5, 11:59 PM'),
  _Item('Quiz 3: Pivot tables', 'Intro to Data Analysis', true, 'Pending',
      'Oct 7, 10:00 AM'),
  _Item('Project proposal', 'UX Design Foundations', false, 'Submitted',
      'Oct 9, 5:00 PM'),
  _Item('Wireframe review', 'UX Design Foundations', false, 'Pending',
      'Oct 14, 11:59 PM'),
  _Item('Midterm quiz', 'Statistics for Everyone', true, 'Pending',
      'Oct 16, 2:00 PM'),
  _Item('Pivot tables practice', 'Intro to Data Analysis', false, 'Graded',
      'Sep 28', '92/100'),
  _Item('Quiz 2: Descriptive stats', 'Statistics for Everyone', true, 'Graded',
      'Sep 30', '8/10'),
];


void _courseDetails(BuildContext context, _Course c) {
  showDetails(
    context,
    icon: c.icon,
    title: c.title,
    subtitle: 'with ${c.instructor}',
    body:
        'Hands-on lessons, short quizzes and a final project. Work through the lessons in order and submit each assignment before its deadline.',
    extra: AppProgress(value: c.progress),
    rows: [
      ('Progress', '${(c.progress * 100).round()}% complete'),
      ('Lessons', '${c.done} of ${c.total} done'),
      ('Current grade', c.grade),
      ('Schedule', 'Mon and Wed, 9:00 AM'),
    ],
  );
}

void _assignmentDetails(BuildContext context, _Item item) {
  if (item.status == 'Pending') {
    showDetails(
      context,
      icon: item.isQuiz ? Icons.quiz_outlined : Icons.assignment_outlined,
      title: item.title,
      subtitle: item.course,
      body: item.isQuiz
          ? 'Answer all questions in one sitting. You have 2 attempts and the best score counts.'
          : 'Read the brief, complete the tasks and upload your work as a single file.',
      rows: [
        ('Due', item.due),
        ('Type', item.isQuiz ? 'Quiz' : 'Assignment'),
        ('Points', '100'),
        ('Status', item.status),
      ],
      primaryLabel: item.isQuiz ? 'Start quiz' : 'Submit work',
      onPrimary: () => item.isQuiz
          ? showToast(context, 'Quiz opens here later')
          : _submitWork(context, item),
    );
  } else {
    showDetails(
      context,
      icon: Icons.fact_check_outlined,
      title: item.isQuiz ? 'Attempt details' : 'Submission details',
      subtitle: item.title,
      rows: [
        ('Course', item.course),
        ('Submitted', item.due),
        (item.isQuiz ? 'Attempt' : 'File', item.isQuiz ? '1 of 2' : 'proposal.pdf'),
        ('Score', item.score ?? 'Waiting for grade'),
        ('Feedback', item.score == null ? 'Not yet available' : 'Clear and well organized.'),
      ],
    );
  }
}

void _submitWork(BuildContext context, _Item item) {
  showFormModal(
    context,
    icon: Icons.upload_file_rounded,
    title: 'Submit assignment',
    subtitle: item.title,
    extra: const UploadBox(),
    fields: const [
      FieldSpec('Comments', Icons.chat_bubble_outline_rounded,
          hint: 'Anything your teacher should know', lines: 3),
    ],
    submitLabel: 'Submit',
    toast: 'Submitted (UI only for now)',
  );
}


class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final upcoming = _items.where((i) => i.status == 'Pending').take(3);
    return PageList(
      children: [
        const SummaryCard(
          title: 'Overall progress',
          value: '68%',
          caption: '4 courses in progress',
          progress: 0.68,
        ),
        SectionTitle('Enrolled courses',
            actionLabel: 'See all', onAction: () => onNavigate(1)),
        for (final c in _courses.take(3))
          NavTile(
            icon: c.icon,
            title: c.title,
            subtitle: '${(c.progress * 100).round()}% complete',
            trailing: Pill(c.grade, tone: PillTone.done),
            onTap: () => _courseDetails(context, c),
          ),
        SectionTitle('Upcoming deadlines',
            actionLabel: 'Calendar', onAction: () => onNavigate(3)),
        for (final i in upcoming)
          NavTile(
            icon: i.isQuiz ? Icons.quiz_outlined : Icons.assignment_outlined,
            title: i.title,
            subtitle: 'Due ${i.due}',
            onTap: () => _assignmentDetails(context, i),
          ),
      ],
    );
  }
}


class MyLearningPage extends StatelessWidget {
  const MyLearningPage({super.key});

  void _termGrades(BuildContext context) {
    showDetails(
      context,
      icon: Icons.workspace_premium_outlined,
      title: 'Term grades',
      subtitle: 'Term 2, 2026',
      rows: [
        for (final c in _courses)
          (c.title, '${c.grade}  (${(c.progress * 100).round()}%)'),
        ('Term GPA', '3.6'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageList(
      children: [
        AppCard(
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Term 2, 2026',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    SizedBox(height: 2),
                    Text('4 enrolled courses',
                        style: TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ice,
                  foregroundColor: AppColors.purple,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                onPressed: () => _termGrades(context),
                child: const Text('Term grades',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SectionTitle('Enrolled courses'),
        for (final c in _courses)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CourseCard(course: c),
          ),
      ],
    );
  }
}

class _CourseCard extends StatefulWidget {
  const _CourseCard({required this.course});
  final _Course course;

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: AppColors.ice,
                            borderRadius: BorderRadius.circular(14)),
                        child: Icon(c.icon, color: AppColors.purple),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.5,
                                    height: 1.25)),
                            Text(c.instructor,
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 13)),
                          ],
                        ),
                      ),
                      Pill(c.grade, tone: PillTone.done),
                      const SizedBox(width: 4),
                      Icon(
                          _open
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: AppColors.purple),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppProgress(value: c.progress),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('${(c.progress * 100).round()}% complete',
                          style: const TextStyle(fontSize: 12.5)),
                      const Spacer(),
                      Text('${c.done} of ${c.total} lessons',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12.5)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        const Divider(height: 1, color: AppColors.line),
                        const SizedBox(height: 12),
                        for (final l in c.lessons)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Icon(
                                  l.$2
                                      ? Icons.check_circle_rounded
                                      : Icons.play_circle_outline_rounded,
                                  size: 20,
                                  color: l.$2
                                      ? AppColors.purple
                                      : AppColors.blue,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(l.$1,
                                        style: const TextStyle(fontSize: 14.5))),
                              ],
                            ),
                          ),
                        const SizedBox(height: 4),
                        GhostButton(
                          label: 'Course details',
                          onPressed: () => _courseDetails(context, c),
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

class StudentAssessments extends StatefulWidget {
  const StudentAssessments({super.key});

  @override
  State<StudentAssessments> createState() => _StudentAssessmentsState();
}

class _StudentAssessmentsState extends State<StudentAssessments> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final list = _items.where((i) {
      if (_tab == 1) return !i.isQuiz;
      if (_tab == 2) return i.isQuiz;
      return true;
    }).toList();

    return PageList(
      children: [
        const Row(
          children: [
            Expanded(
                child: StatTile(
                    icon: Icons.trending_up_rounded,
                    value: '89%',
                    label: 'Average score')),
            SizedBox(width: 12),
            Expanded(
                child: StatTile(
                    icon: Icons.pending_actions_rounded,
                    value: '4',
                    label: 'Still to do')),
          ],
        ),
        const SizedBox(height: 18),
        FilterChips(
          labels: const ['All', 'Assignments', 'Quizzes'],
          selected: _tab,
          onSelected: (i) => setState(() => _tab = i),
        ),
        for (final i in list)
          NavTile(
            icon: i.isQuiz ? Icons.quiz_outlined : Icons.assignment_outlined,
            title: i.title,
            subtitle: i.status == 'Graded' ? i.course : '${i.course}, due ${i.due}',
            trailing: switch (i.status) {
              'Graded' => Pill(i.score ?? '', tone: PillTone.solid),
              'Submitted' => const Pill('Submitted', tone: PillTone.done),
              _ => const Pill('Pending'),
            },
            onTap: () => _assignmentDetails(context, i),
          ),
      ],
    );
  }
}


class StudentCalendar extends StatelessWidget {
  const StudentCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageList(
      children: [
        CalendarView(
          kinds: [EventKind.deadline, EventKind.quiz, EventKind.assignment],
          events: [
            CalEvent(5, EventKind.assignment, 'Data cleaning worksheet',
                'Intro to Data Analysis', '11:59 PM'),
            CalEvent(7, EventKind.quiz, 'Quiz 3: Pivot tables',
                'Intro to Data Analysis', '10:00 AM'),
            CalEvent(9, EventKind.deadline, 'Project proposal due',
                'UX Design Foundations', '5:00 PM'),
            CalEvent(14, EventKind.assignment, 'Wireframe review',
                'UX Design Foundations', '11:59 PM'),
            CalEvent(16, EventKind.quiz, 'Midterm quiz',
                'Statistics for Everyone', '2:00 PM'),
            CalEvent(21, EventKind.deadline, 'Essay draft due',
                'Academic Writing Essentials', '9:00 AM'),
            CalEvent(21, EventKind.quiz, 'Quiz 4: Sampling',
                'Statistics for Everyone', '1:00 PM'),
            CalEvent(28, EventKind.assignment, 'Final project outline',
                'UX Design Foundations', '11:59 PM'),
          ],
        ),
      ],
    );
  }
}