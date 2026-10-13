import 'package:flutter/material.dart';

import '../data/student_data.dart';
import '../widgets/common.dart';
import '../widgets/ui.dart';

void showCourseDetails(BuildContext context, StudentCourse c) {
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

void showAssignmentDetails(BuildContext context, StudentItem item) {
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
        (item.isQuiz ? 'Attempt' : 'File',
            item.isQuiz ? '1 of 2' : 'proposal.pdf'),
        ('Score', item.score ?? 'Waiting for grade'),
        ('Feedback',
            item.score == null ? 'Not yet available' : 'Clear and well organized.'),
      ],
    );
  }
}

void _submitWork(BuildContext context, StudentItem item) {
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