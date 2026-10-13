import 'package:flutter/material.dart';

import '../data/staff_data.dart';
import '../widgets/ui.dart';

void showStudentProgress(BuildContext context, StaffStudent s,
    {VoidCallback? onGrades}) {
  showDetails(
    context,
    icon: Icons.person_outline_rounded,
    title: 'Student progress',
    subtitle: s.name,
    extra: AppProgress(value: s.progress),
    rows: [
      ('Course', 'Intro to Data Analysis'),
      ('Progress', pct(s.progress)),
      ('Lessons', '${(s.progress * 12).round()} of 12'),
      ('Current grade', s.grade),
      ('Last active', 'Today, 8:42 AM'),
    ],
    primaryLabel: onGrades == null ? null : 'View grades',
    onPrimary: onGrades,
  );
}

void showGradeDetails(BuildContext context, StaffStudent s) {
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