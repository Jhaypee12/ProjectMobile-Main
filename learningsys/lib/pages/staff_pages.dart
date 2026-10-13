import 'package:flutter/material.dart';

import '../role.dart';
import '../theme.dart';
import '../widgets/calendar_view.dart';
import '../widgets/common.dart';
import '../widgets/ui.dart';


typedef _Course = ({String name, int students, double progress, String grade});
typedef _Student = ({String name, String initials, double progress, String grade});
typedef _Task = ({String title, String course, String due, int done, int total});
typedef _Sub = ({String student, String task, String when, bool graded});

const List<_Course> _courses = [
  (name: 'Intro to Data Analysis ', students: 42, progress: 0.71, grade: 'B+'),
  (name: 'Statistics for Everyone', students: 38, progress: 0.55, grade: 'B'),
  (name: 'Academic Writing Essentials', students: 31, progress: 0.84, grade: 'A-'),
  (name: 'UX Design Foundations', students: 36, progress: 0.66, grade: 'B+'),
  (name: 'Project Management Basics', students: 35, progress: 0.48, grade: 'B-'),
];

const List<_Student> _students = [
  (name: 'Ana Cruz', initials: 'AC', progress: 0.82, grade: 'A-'),
  (name: 'Leo Alvarez', initials: 'LA', progress: 0.64, grade: 'B'),
  (name: 'Priya Nair', initials: 'PN', progress: 0.91, grade: 'A'),
  (name: 'Jun Reyes', initials: 'JR', progress: 0.38, grade: 'C+'),
  (name: 'Sam Okafor', initials: 'SO', progress: 0.73, grade: 'B+'),
];

const List<_Task> _assignments = [
  (title: 'Data cleaning worksheet', course: 'Intro to Data Analysis', due: 'Oct 5', done: 31, total: 42),
  (title: 'Project proposal', course: 'UX Design Foundations', due: 'Oct 9', done: 22, total: 36),
  (title: 'Essay draft', course: 'Academic Writing Essentials', due: 'Oct 21', done: 9, total: 31),
];

const List<_Task> _quizzes = [
  (title: 'Quiz 3: Pivot tables', course: 'Intro to Data Analysis', due: 'Oct 7', done: 0, total: 42),
  (title: 'Midterm quiz', course: 'Statistics for Everyone', due: 'Oct 16', done: 0, total: 38),
  (title: 'Quiz 2: Descriptive stats', course: 'Statistics for Everyone', due: 'Sep 30', done: 36, total: 38),
];

const List<_Sub> _subs = [
  (student: 'Ana Cruz', task: 'Data cleaning worksheet', when: 'Oct 3, 9:14 PM', graded: false),
  (student: 'Leo Alvarez', task: 'Project proposal', when: 'Oct 3, 6:40 PM', graded: false),
  (student: 'Priya Nair', task: 'Data cleaning worksheet', when: 'Oct 2, 4:05 PM', graded: true),
  (student: 'Sam Okafor', task: 'Essay draft', when: 'Oct 2, 1:22 PM', graded: false),
];

const List<({String title, String meta, IconData icon})> _lessons = [
  (title: 'Welcome and course outline', meta: 'Video, 6 min', icon: Icons.play_circle_outline_rounded),
  (title: 'Reading: Spreadsheet basics', meta: 'PDF, 12 pages', icon: Icons.picture_as_pdf_outlined),
  (title: 'Lesson 3: Cleaning messy data', meta: 'Video, 18 min', icon: Icons.play_circle_outline_rounded),
  (title: 'Practice quiz', meta: '10 questions', icon: Icons.quiz_outlined),
];

String _pct(double v) => '${(v * 100).round()}%';

void _courseStats(BuildContext context, _Course c) {
  showDetails(
    context,
    icon: Icons.insights_rounded,
    title: 'Course statistics',
    subtitle: c.name,
    extra: AppProgress(value: c.progress),
    rows: [
      ('Students', '${c.students}'),
      ('Average progress', _pct(c.progress)),
      ('Average grade', c.grade),
      ('Submission rate', '91%'),
      ('Completion rate', '64%'),
    ],
  );
}

void _studentProgress(BuildContext context, _Student s, {VoidCallback? onGrades}) {
  showDetails(
    context,
    icon: Icons.person_outline_rounded,
    title: 'Student progress',
    subtitle: s.name,
    extra: AppProgress(value: s.progress),
    rows: [
      ('Course', 'Intro to Data Analysis'),
      ('Progress', _pct(s.progress)),
      ('Lessons', '${(s.progress * 12).round()} of 12'),
      ('Current grade', s.grade),
      ('Last active', 'Today, 8:42 AM'),
    ],
    primaryLabel: onGrades == null ? null : 'View grades',
    onPrimary: onGrades,
  );
}

void _gradeDetails(BuildContext context, _Student s) {
  showDetails(
    context,
    icon: Icons.grade_outlined,
    title: 'Grade details',
    subtitle: s.name,
    rows: [
      ('Assignment 1', '90/100'),
      ('Quiz 2', '8/10'),
      ('Midterm', '84/100'),
      ('Final grade', s.grade),
    ],
  );
}

void _feedbackForm(BuildContext context, String student) {
  showFormModal(
    context,
    icon: Icons.chat_bubble_outline_rounded,
    title: 'Send feedback',
    subtitle: student,
    fields: const [
      FieldSpec('Feedback', Icons.edit_outlined,
          hint: 'Write a short note', lines: 4),
    ],
    submitLabel: 'Send feedback',
    toast: 'Feedback sent (UI only for now)',
  );
}

void _taskDetails(BuildContext context, _Task t, {required bool quiz, VoidCallback? onSubmissions}) {
  showDetails(
    context,
    icon: quiz ? Icons.quiz_outlined : Icons.assignment_outlined,
    title: quiz ? 'Quiz details' : 'Assignment details',
    subtitle: t.title,
    extra: AppProgress(value: t.done / t.total),
    rows: [
      ('Course', t.course),
      ('Due', t.due),
      (quiz ? 'Attempts' : 'Submitted', '${t.done} of ${t.total}'),
      (quiz ? 'Time limit' : 'Points', quiz ? '30 min' : '100'),
    ],
    primaryLabel: quiz ? null : 'View submissions',
    onPrimary: onSubmissions,
  );
}

void _newTask(BuildContext context, {required bool quiz}) {
  showFormModal(
    context,
    icon: quiz ? Icons.quiz_outlined : Icons.assignment_add,
    title: quiz ? 'New quiz' : 'New assignment',
    fields: [
      FieldSpec('Title', Icons.title_rounded, hint: quiz ? 'Quiz 4: Sampling' : 'Assignment title'),
      const FieldSpec('Course', Icons.menu_book_outlined, hint: 'Choose a course'),
      const FieldSpec('Due date', Icons.event_outlined, hint: 'Oct 30, 11:59 PM'),
      if (!quiz)
        const FieldSpec('Instructions', Icons.notes_rounded,
            hint: 'What should students do?', lines: 3),
    ],
    submitLabel: 'Continue',
    onDone: () => showConfirmModal(
      context,
      icon: Icons.send_rounded,
      title: quiz ? 'Publish quiz?' : 'Publish assignment?',
      message: 'Students in the course will be notified right away.',
      confirmLabel: 'Publish',
      toast: 'Published (UI only for now)',
    ),
  );
}


class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key, required this.role, required this.onNavigate});
  final Role role;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final pending = _subs.where((s) => !s.graded).take(3);
    return PageList(
      children: [
        SummaryCard(
          title: 'Pending submissions',
          value: '24',
          caption: role == Role.admin
              ? 'across all 5 courses'
              : 'waiting for your review',
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
                child: StatTile(
                    icon: Icons.menu_book_rounded, value: '5', label: 'Courses')),
            SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    icon: Icons.groups_rounded, value: '182', label: 'Students')),
            SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    icon: Icons.trending_up_rounded,
                    value: '86%',
                    label: 'Avg grade')),
          ],
        ),
        SectionTitle('Course overview',
            actionLabel: 'See all', onAction: () => onNavigate(1)),
        for (final c in _courses.take(3))
          NavTile(
            icon: Icons.menu_book_rounded,
            title: c.name,
            subtitle: '${c.students} students',
            trailing: Pill(_pct(c.progress)),
            onTap: () => _courseStats(context, c),
          ),
        SectionTitle('Pending submissions',
            actionLabel: 'Assessments', onAction: () => onNavigate(2)),
        for (final s in pending)
          NavTile(
            icon: Icons.inbox_outlined,
            title: s.student,
            subtitle: s.task,
            trailing: const Pill('To grade', tone: PillTone.solid),
            onTap: () => showDetails(
              context,
              icon: Icons.inbox_outlined,
              title: 'Submission details',
              subtitle: s.student,
              rows: [
                ('Assignment', s.task),
                ('Submitted', s.when),
                ('File', 'worksheet.pdf'),
                ('Status', 'Waiting for grade'),
              ],
              primaryLabel: 'Grade submission',
              onPrimary: () => onNavigate(2),
            ),
          ),
        const SectionTitle('Upcoming deadlines'),
        for (final t in _assignments.take(2))
          NavTile(
            icon: Icons.flag_outlined,
            title: t.title,
            subtitle: '${t.course}, ${t.due}',
            onTap: () => showDetails(
              context,
              icon: Icons.event_note_rounded,
              title: 'Upcoming activity',
              subtitle: t.title,
              rows: [
                ('Course', t.course),
                ('Due', t.due),
                ('Submitted so far', '${t.done} of ${t.total}'),
              ],
            ),
          ),
        const SectionTitle('Recent activity'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.line),
                InkWell(
                  onTap: () => _studentProgress(context, _students[i]),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        AppAvatar(_students[i].initials,
                            size: 38,
                            color: i.isEven ? AppColors.purple : AppColors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            [
                              '${_students[i].name} completed Lesson 4',
                              '${_students[i].name} submitted Project proposal',
                              '${_students[i].name} finished Quiz 2',
                            ][i],
                            style: const TextStyle(fontSize: 14.5),
                          ),
                        ),
                        Text(['2h', '5h', '1d'][i],
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}


class StaffCourses extends StatefulWidget {
  const StaffCourses({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  State<StaffCourses> createState() => _StaffCoursesState();
}

class _StaffCoursesState extends State<StaffCourses> {
  int _tab = 0;

  void _announce() {
    showFormModal(
      context,
      icon: Icons.campaign_outlined,
      title: 'Course announcement',
      subtitle: 'Sent to every student in the course',
      fields: const [
        FieldSpec('Title', Icons.title_rounded, hint: 'Midterm schedule'),
        FieldSpec('Message', Icons.notes_rounded,
            hint: 'Write your announcement', lines: 4),
      ],
      submitLabel: 'Post announcement',
      toast: 'Announcement posted (UI only for now)',
    );
  }

  void _editCourse(String name) {
    showFormModal(
      context,
      icon: Icons.edit_outlined,
      title: 'Edit course',
      subtitle: name,
      fields: const [
        FieldSpec('Course title', Icons.title_rounded),
        FieldSpec('Description', Icons.notes_rounded, lines: 3),
      ],
      submitLabel: 'Save changes',
      toast: 'Saved (UI only for now)',
    );
  }

  void _courseInfo(_Course c) {
    showDetails(
      context,
      icon: Icons.menu_book_rounded,
      title: 'Course information',
      subtitle: c.name,
      rows: [
        ('Instructor', 'Dr. Maya Santos'),
        ('Students', '${c.students}'),
        ('Lessons', '12'),
        ('Schedule', 'Mon and Wed, 9:00 AM'),
        ('Status', 'Active'),
      ],
      primaryLabel: widget.isAdmin ? 'Edit course' : 'Post announcement',
      onPrimary: widget.isAdmin ? () => _editCourse(c.name) : _announce,
    );
  }

  void _lessonPreview(({String title, String meta, IconData icon}) l) {
    showDetails(
      context,
      icon: l.icon,
      title: 'Preview',
      subtitle: '${l.title}, ${l.meta}',
      extra: PreviewBox(l.icon),
      primaryLabel: widget.isAdmin ? 'Mark as complete' : null,
      onPrimary: () => showConfirmModal(
        context,
        icon: Icons.check_circle_outline_rounded,
        title: 'Mark lesson as complete?',
        message: '${l.title} will show as complete for this course.',
        confirmLabel: 'Mark complete',
        toast: 'Lesson marked complete',
      ),
    );
  }

  void _enroll() {
    showFormModal(
      context,
      icon: Icons.person_add_alt_1_rounded,
      title: 'Enroll a student',
      fields: const [
        FieldSpec('Student email', Icons.mail_outline_rounded,
            hint: 'student@school.edu'),
        FieldSpec('Course', Icons.menu_book_outlined, hint: 'Choose a course'),
      ],
      submitLabel: 'Enroll student',
      onDone: () => showConfirmModal(
        context,
        icon: Icons.how_to_reg_rounded,
        title: 'Enrollment confirmed',
        message: 'The student can now see the course in My Learning.',
        confirmLabel: 'Done',
        single: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = widget.isAdmin;
    return PageList(
      children: [
        FilterChips(
          labels: const ['Courses', 'Students', 'Content'],
          selected: _tab,
          onSelected: (i) => setState(() => _tab = i),
        ),
        if (_tab == 0) ...[
          PrimaryButton(
            label: admin ? 'New course' : 'Post announcement',
            onPressed: admin
                ? () => showFormModal(
                      context,
                      icon: Icons.library_add_outlined,
                      title: 'New course',
                      fields: const [
                        FieldSpec('Course title', Icons.title_rounded),
                        FieldSpec('Instructor', Icons.person_outline_rounded),
                        FieldSpec('Description', Icons.notes_rounded, lines: 3),
                      ],
                      submitLabel: 'Create course',
                      toast: 'Course created (UI only for now)',
                    )
                : _announce,
          ),
          const SizedBox(height: 16),
          for (final c in _courses)
            NavTile(
              icon: Icons.menu_book_rounded,
              title: c.name,
              subtitle: '${c.students} students',
              trailing: Pill(c.grade, tone: PillTone.done),
              onTap: () => _courseInfo(c),
            ),
        ],
        if (_tab == 1) ...[
          if (admin) ...[
            PrimaryButton(label: 'Enroll student', onPressed: _enroll),
            const SizedBox(height: 16),
          ],
          for (var i = 0; i < _students.length; i++)
            NavTile(
              leading: AppAvatar(_students[i].initials,
                  color: i.isEven ? AppColors.purple : AppColors.blue),
              title: _students[i].name,
              subtitle: '${_pct(_students[i].progress)} complete',
              trailing: Pill(_students[i].grade, tone: PillTone.done),
              onTap: () => _studentProgress(
                context,
                _students[i],
                onGrades: () => _gradeDetails(context, _students[i]),
              ),
            ),
        ],
        if (_tab == 2)
          for (final l in _lessons)
            NavTile(
              icon: l.icon,
              title: l.title,
              subtitle: l.meta,
              onTap: () => _lessonPreview(l),
            ),
      ],
    );
  }
}


class StaffAssessments extends StatefulWidget {
  const StaffAssessments({super.key});

  @override
  State<StaffAssessments> createState() => _StaffAssessmentsState();
}

class _StaffAssessmentsState extends State<StaffAssessments> {
  int _tab = 0;

  void _grade(_Sub s) {
    showDetails(
      context,
      icon: Icons.inbox_outlined,
      title: 'Assignment submission',
      subtitle: s.student,
      rows: [
        ('Assignment', s.task),
        ('Submitted', s.when),
        ('File', 'submission.pdf'),
        ('Status', s.graded ? 'Graded' : 'Waiting for grade'),
      ],
      primaryLabel: s.graded ? null : 'Grade submission',
      onPrimary: () => showFormModal(
        context,
        icon: Icons.grading_rounded,
        title: 'Grade submission',
        subtitle: '${s.student}, ${s.task}',
        fields: const [
          FieldSpec('Score', Icons.looks_one_outlined, hint: '90 / 100'),
          FieldSpec('Feedback', Icons.chat_bubble_outline_rounded,
              hint: 'Write a short note', lines: 3),
        ],
        submitLabel: 'Save grade',
        onDone: () => showConfirmModal(
          context,
          icon: Icons.check_circle_outline_rounded,
          title: 'Grade saved',
          message: '${s.student} has been notified.',
          confirmLabel: 'Done',
          single: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageList(
      children: [
        FilterChips(
          labels: const ['Assignments', 'Quizzes', 'Submissions', 'Results'],
          selected: _tab,
          onSelected: (i) => setState(() => _tab = i),
        ),
        if (_tab == 0 || _tab == 1) ...[
          PrimaryButton(
            label: _tab == 0 ? 'New assignment' : 'New quiz',
            onPressed: () => _newTask(context, quiz: _tab == 1),
          ),
          const SizedBox(height: 16),
          for (final t in (_tab == 0 ? _assignments : _quizzes))
            NavTile(
              icon: _tab == 0 ? Icons.assignment_outlined : Icons.quiz_outlined,
              title: t.title,
              subtitle: '${t.course}, due ${t.due}',
              trailing: Pill('${t.done}/${t.total}'),
              onTap: () => _taskDetails(
                context,
                t,
                quiz: _tab == 1,
                onSubmissions: () => setState(() => _tab = 2),
              ),
            ),
        ],
        if (_tab == 2)
          for (final s in _subs)
            NavTile(
              icon: Icons.inbox_outlined,
              title: s.student,
              subtitle: s.task,
              trailing: s.graded
                  ? const Pill('Graded', tone: PillTone.done)
                  : const Pill('To grade', tone: PillTone.solid),
              onTap: () => _grade(s),
            ),
        if (_tab == 3)
          for (final t in [..._assignments, ..._quizzes])
            NavTile(
              icon: Icons.bar_chart_rounded,
              title: t.title,
              subtitle: t.course,
              trailing: const Pill('Avg 86%'),
              onTap: () => showDetails(
                context,
                icon: Icons.bar_chart_rounded,
                title: 'Results',
                subtitle: t.title,
                rows: const [
                  ('Average', '86%'),
                  ('Highest', '98%'),
                  ('Lowest', '54%'),
                  ('Passed', '34 of 38'),
                ],
              ),
            ),
      ],
    );
  }
}


class GradebookPage extends StatefulWidget {
  const GradebookPage({super.key});

  @override
  State<GradebookPage> createState() => _GradebookPageState();
}

class _GradebookPageState extends State<GradebookPage> {
  int _course = 0;

  void _submissionDetails(_Student s) {
    showDetails(
      context,
      icon: Icons.fact_check_outlined,
      title: 'Submission details',
      subtitle: '${s.name}, ${_courses[_course].name}',
      rows: [
        ('Assignment 1', '90/100'),
        ('Quiz 2', '8/10'),
        ('Midterm', '84/100'),
        ('Final grade', s.grade),
      ],
      primaryLabel: 'Send feedback',
      onPrimary: () => _feedbackForm(context, s.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _courses[_course];
    return PageList(
      children: [
        FilterChips(
          labels: [for (final c in _courses) c.name],
          selected: _course,
          onSelected: (i) => setState(() => _course = i),
        ),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Class average',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('${_pct(c.progress + 0.15)}  (${c.grade})',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 22)),
                    const SizedBox(height: 10),
                    AppProgress(value: c.progress + 0.15),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Course grades'),
        for (var i = 0; i < _students.length; i++)
          NavTile(
            leading: AppAvatar(_students[i].initials,
                color: i.isEven ? AppColors.purple : AppColors.blue),
            title: _students[i].name,
            subtitle: '${_pct(_students[i].progress)} overall',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Pill(_students[i].grade, tone: PillTone.done),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Send feedback',
                  onPressed: () => _feedbackForm(context, _students[i].name),
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      size: 20, color: AppColors.blue),
                ),
              ],
            ),
            onTap: () => _submissionDetails(_students[i]),
          ),
      ],
    );
  }
}


class TeacherCalendar extends StatelessWidget {
  const TeacherCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageList(
      children: [
        CalendarView(
          kinds: [
            EventKind.deadline,
            EventKind.quiz,
            EventKind.submission,
            EventKind.meeting,
          ],
          events: [
            CalEvent(5, EventKind.submission, 'Worksheet submissions close',
                'Intro to Data Analysis', '11:59 PM'),
            CalEvent(7, EventKind.quiz, 'Quiz 3: Pivot tables',
                'Intro to Data Analysis', '10:00 AM'),
            CalEvent(9, EventKind.deadline, 'Midterm grades due',
                'Statistics for Everyone', '5:00 PM'),
            CalEvent(12, EventKind.meeting, 'Department meeting',
                'Faculty room', '3:00 PM'),
            CalEvent(14, EventKind.submission, 'Wireframe review closes',
                'UX Design Foundations', '11:59 PM'),
            CalEvent(16, EventKind.quiz, 'Midterm quiz',
                'Statistics for Everyone', '2:00 PM'),
            CalEvent(19, EventKind.meeting, 'Parent and teacher call',
                'Online', '4:30 PM'),
            CalEvent(23, EventKind.deadline, 'Essay feedback due',
                'Academic Writing Essentials', '9:00 AM'),
          ],
        ),
      ],
    );
  }
}


class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  static const _items = [
    ('Campus closed on Oct 12', 'Oct 2, 2026', 'Everyone',
        'The campus and online classes are closed for the holiday. Deadlines due that day move to Oct 13.'),
    ('Midterm schedule is live', 'Sep 30, 2026', 'Students',
        'Your midterm dates are now on the calendar. Check each course for the room or link.'),
    ('Grade submission window', 'Sep 28, 2026', 'Teachers',
        'Midterm grades must be entered by Oct 9 at 5:00 PM.'),
  ];

  void _form(BuildContext context, {String? title}) {
    showFormModal(
      context,
      icon: Icons.campaign_outlined,
      title: title == null ? 'New announcement' : 'Edit announcement',
      fields: const [
        FieldSpec('Title', Icons.title_rounded),
        FieldSpec('Audience', Icons.groups_outlined, hint: 'Everyone'),
        FieldSpec('Message', Icons.notes_rounded,
            hint: 'Write your announcement', lines: 4),
      ],
      submitLabel: title == null ? 'Publish' : 'Save changes',
      toast: 'Saved (UI only for now)',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageList(
      children: [
        PrimaryButton(
            label: 'New announcement', onPressed: () => _form(context)),
        const SectionTitle('System announcements'),
        for (final a in _items)
          NavTile(
            icon: Icons.campaign_outlined,
            title: a.$1,
            subtitle: a.$2,
            trailing: Pill(a.$3),
            onTap: () => showDetails(
              context,
              icon: Icons.event_note_rounded,
              title: 'Date details',
              subtitle: a.$1,
              body: a.$4,
              rows: [
                ('Posted', a.$2),
                ('Audience', a.$3),
                ('Status', 'Published'),
              ],
              primaryLabel: 'Edit announcement',
              onPrimary: () => _form(context, title: a.$1),
            ),
          ),
      ],
    );
  }
}