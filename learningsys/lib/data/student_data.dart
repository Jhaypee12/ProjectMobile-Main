import 'package:flutter/material.dart';


class StudentCourse {
  const StudentCourse(this.title, this.instructor, this.progress, this.grade,
      this.icon, this.done, this.total, this.lessons);
  final String title, instructor, grade;
  final double progress;
  final IconData icon;
  final int done, total;
  final List<(String, bool)> lessons;
}

const studentCourses = [
  StudentCourse('Intro to Data Analysis', 'Dr. Maya Santos', 0.58, 'A-',
      Icons.bar_chart_rounded, 7, 12, [
    ('Spreadsheet basics', true),
    ('Cleaning messy data', true),
    ('Pivot tables', false),
    ('Charts that communicate', false),
  ]),
  StudentCourse('UX Design Foundations', 'Leo Alvarez', 0.72, 'B+',
      Icons.palette_outlined, 13, 18, [
    ('Understanding users', true),
    ('Wireframing', true),
    ('Prototyping', false),
    ('Usability testing', false),
  ]),
  StudentCourse('Statistics for Everyone', 'Ana Cruz', 0.40, 'B',
      Icons.functions_rounded, 6, 16, [
    ('Describing data', true),
    ('Probability basics', true),
    ('Sampling', false),
    ('Hypothesis tests', false),
  ]),
  StudentCourse('Academic Writing Essentials', 'Prof. Jun Reyes', 0.90, 'A',
      Icons.edit_note_rounded, 9, 10, [
    ('Structuring an argument', true),
    ('Citing sources', true),
    ('Editing and revising', true),
    ('Final essay', false),
  ]),
];

class StudentItem {
  const StudentItem(this.title, this.course, this.isQuiz, this.status, this.due,
      [this.score]);
  final String title, course, status, due;
  final bool isQuiz;
  final String? score;
}

const studentItems = [
  StudentItem('Data cleaning worksheet', 'Intro to Data Analysis', false,
      'Pending', 'Oct 5, 11:59 PM'),
  StudentItem('Quiz 3: Pivot tables', 'Intro to Data Analysis', true, 'Pending',
      'Oct 7, 10:00 AM'),
  StudentItem('Project proposal', 'UX Design Foundations', false, 'Submitted',
      'Oct 9, 5:00 PM'),
  StudentItem('Wireframe review', 'UX Design Foundations', false, 'Pending',
      'Oct 14, 11:59 PM'),
  StudentItem('Midterm quiz', 'Statistics for Everyone', true, 'Pending',
      'Oct 16, 2:00 PM'),
  StudentItem('Pivot tables practice', 'Intro to Data Analysis', false,
      'Graded', 'Sep 28', '92/100'),
  StudentItem('Quiz 2: Descriptive stats', 'Statistics for Everyone', true,
      'Graded', 'Sep 30', '8/10'),
];