import 'package:flutter/material.dart';


typedef StaffCourse = ({String name, int students, double progress, String grade});
typedef StaffStudent = ({String name, String initials, double progress, String grade});
typedef StaffTask = ({String title, String course, String due, int done, int total});
typedef StaffSubmission = ({String student, String task, String when, bool graded});
typedef StaffLesson = ({String title, String meta, IconData icon});

const List<StaffCourse> staffCourses = [
  (name: 'Intro to Data Analysis', students: 42, progress: 0.71, grade: 'B+'),
  (name: 'Statistics for Everyone', students: 38, progress: 0.55, grade: 'B'),
  (name: 'Academic Writing Essentials', students: 31, progress: 0.84, grade: 'A-'),
  (name: 'UX Design Foundations', students: 36, progress: 0.66, grade: 'B+'),
  (name: 'Project Management Basics', students: 35, progress: 0.48, grade: 'B-'),
];

const List<StaffStudent> staffStudents = [
  (name: 'Ana Cruz', initials: 'AC', progress: 0.82, grade: 'A-'),
  (name: 'Leo Alvarez', initials: 'LA', progress: 0.64, grade: 'B'),
  (name: 'Priya Nair', initials: 'PN', progress: 0.91, grade: 'A'),
  (name: 'Jun Reyes', initials: 'JR', progress: 0.38, grade: 'C+'),
  (name: 'Sam Okafor', initials: 'SO', progress: 0.73, grade: 'B+'),
];

const List<StaffTask> staffAssignments = [
  (title: 'Data cleaning worksheet', course: 'Intro to Data Analysis', due: 'Oct 5', done: 31, total: 42),
  (title: 'Project proposal', course: 'UX Design Foundations', due: 'Oct 9', done: 22, total: 36),
  (title: 'Essay draft', course: 'Academic Writing Essentials', due: 'Oct 21', done: 9, total: 31),
];

const List<StaffTask> staffQuizzes = [
  (title: 'Quiz 3: Pivot tables', course: 'Intro to Data Analysis', due: 'Oct 7', done: 0, total: 42),
  (title: 'Midterm quiz', course: 'Statistics for Everyone', due: 'Oct 16', done: 0, total: 38),
  (title: 'Quiz 2: Descriptive stats', course: 'Statistics for Everyone', due: 'Sep 30', done: 36, total: 38),
];

const List<StaffSubmission> staffSubmissions = [
  (student: 'Ana Cruz', task: 'Data cleaning worksheet', when: 'Oct 3, 9:14 PM', graded: false),
  (student: 'Leo Alvarez', task: 'Project proposal', when: 'Oct 3, 6:40 PM', graded: false),
  (student: 'Priya Nair', task: 'Data cleaning worksheet', when: 'Oct 2, 4:05 PM', graded: true),
  (student: 'Sam Okafor', task: 'Essay draft', when: 'Oct 2, 1:22 PM', graded: false),
];

const List<StaffLesson> staffLessons = [
  (title: 'Welcome and course outline', meta: 'Video, 6 min', icon: Icons.play_circle_outline_rounded),
  (title: 'Reading: Spreadsheet basics', meta: 'PDF, 12 pages', icon: Icons.picture_as_pdf_outlined),
  (title: 'Lesson 3: Cleaning messy data', meta: 'Video, 18 min', icon: Icons.play_circle_outline_rounded),
  (title: 'Practice quiz', meta: '10 questions', icon: Icons.quiz_outlined),
];

String pct(double v) => '${(v * 100).round()}%';