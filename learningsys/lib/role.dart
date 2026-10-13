import 'package:flutter/material.dart';

enum Role { student, teacher, admin }

extension RoleInfo on Role {
  String get label => switch (this) {
        Role.student => 'Student',
        Role.teacher => 'Teacher',
        Role.admin => 'Admin',
      };

  IconData get icon => switch (this) {
        Role.student => Icons.school_outlined,
        Role.teacher => Icons.co_present_outlined,
        Role.admin => Icons.admin_panel_settings_outlined,
      };

  String get route => '/$name';

  // Stock profile info until real accounts exist.
  String get userName => switch (this) {
        Role.student => 'Jamie Reyes',
        Role.teacher => 'Dr. Maya Santos',
        Role.admin => 'Marco Dela Cruz',
      };

  String get initials => switch (this) {
        Role.student => 'JR',
        Role.teacher => 'MS',
        Role.admin => 'MD',
      };

  String get email => switch (this) {
        Role.student => 'jamie.reyes@school.edu',
        Role.teacher => 'maya.santos@school.edu',
        Role.admin => 'marco.delacruz@school.edu',
      };
}