import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../role.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.role, this.user});
  final Role role;
  final AppUser? user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _push = true;
  bool _emailReminders = true;

  String get _fullName {
    final u = widget.user;
    if (u != null && u.firstName.isNotEmpty) {
      return '${u.firstName} ${u.lastName}'.trim();
    }
    return widget.role.userName;
  }

  String get _email {
    final u = widget.user;
    if (u != null && u.email.isNotEmpty) return u.email;
    return widget.role.email;
  }

  String get _initials {
    final u = widget.user;
    if (u == null) return widget.role.initials;
    final f = u.firstName.isNotEmpty ? u.firstName[0].toUpperCase() : '';
    final l = u.lastName.isNotEmpty ? u.lastName[0].toUpperCase() : '';
    final result = '$f$l';
    return result.isEmpty ? widget.role.initials : result;
  }

  String get _idLabel => switch (widget.role) {
        Role.student => 'Student ID',
        Role.teacher => 'Department',
        Role.admin => 'Staff ID',
      };

  String get _idValue => switch (widget.role) {
        Role.student => '2026-04817',
        Role.teacher => 'Data and Computing',
        Role.admin => 'ST-0042',
      };

  void _editInfo() {
    showFormModal(
      context,
      icon: Icons.person_outline_rounded,
      title: 'Edit profile',
      fields: const [
        FieldSpec('Full name', Icons.badge_outlined),
        FieldSpec('Email', Icons.mail_outline_rounded),
        FieldSpec('Phone', Icons.phone_outlined, hint: '+63 900 000 0000'),
      ],
      submitLabel: 'Save changes',
      toast: 'Profile saved (UI only for now)',
    );
  }

  void _changePassword() {
    showFormModal(
      context,
      icon: Icons.lock_reset_rounded,
      title: 'Change password',
      subtitle: 'Choose something you have not used before.',
      fields: const [
        FieldSpec('Current password', Icons.lock_outline_rounded, password: true),
        FieldSpec('New password', Icons.lock_outline_rounded, password: true),
        FieldSpec('Confirm new password', Icons.lock_outline_rounded,
            password: true),
      ],
      submitLabel: 'Update password',
      toast: 'Password updated (UI only for now)',
    );
  }

  void _logOut() {
    showConfirmModal(
      context,
      icon: Icons.logout_rounded,
      title: 'Log out?',
      message: 'You will need to log in again with a new code.',
      confirmLabel: 'Log out',
      onConfirm: () => Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (route) => false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        title: Text('Profile',
            style: GoogleFonts.bricolageGrotesque(
                fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: PageList(
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  AppAvatar(_initials, size: 84),
                  const SizedBox(height: 14),
                  Text(_fullName,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 2),
                  Text(_email,
                      style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 12),
                  Pill(role.label, tone: PillTone.solid),
                ],
              ),
            ),
          ),
          SectionTitle('Profile information',
              actionLabel: 'Edit', onAction: _editInfo),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _InfoRow('Full name', _fullName),
                const Divider(height: 1, color: AppColors.line),
                _InfoRow('Email', _email),
                const Divider(height: 1, color: AppColors.line),
                _InfoRow('Phone', '+63 912 345 6789'),
                const Divider(height: 1, color: AppColors.line),
                _InfoRow(_idLabel, _idValue),
              ],
            ),
          ),
          const SectionTitle('Password'),
          NavTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change password',
            subtitle: 'Last changed 3 months ago',
            onTap: _changePassword,
          ),
          const SectionTitle('Account settings'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                SwitchListTile(
                  value: _push,
                  onChanged: (v) => setState(() => _push = v),
                  title: const Text('Push notifications'),
                  subtitle: const Text('Deadlines, grades and announcements'),
                ),
                const Divider(height: 1, color: AppColors.line),
                SwitchListTile(
                  value: _emailReminders,
                  onChanged: (v) => setState(() => _emailReminders = v),
                  title: const Text('Email reminders'),
                  subtitle: const Text('A daily summary at 8:00 AM'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          NavTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () => showToast(context, 'More languages come later'),
          ),
          const SizedBox(height: 14),
          GhostButton(label: 'Log out', onPressed: _logOut),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}