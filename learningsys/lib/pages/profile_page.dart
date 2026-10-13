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
  
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  String get _fullName {
    final u = _user;
    if (u != null && u.firstName.isNotEmpty) {
      return '${u.firstName} ${u.lastName}'.trim();
    }
    return widget.role.userName;
  }

  String get _email {
    final u = _user;
    if (u != null && u.email.isNotEmpty) return u.email;
    return widget.role.email;
  }

  String get _initials {
    final u = _user;
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

  Future<void> _editInfo() async {
    if (_user == null) {
      showToast(context, 'No user loaded to edit');
      return;
    }

    final firstCtrl = TextEditingController(text: _user!.firstName);
    final lastCtrl = TextEditingController(text: _user!.lastName);
    final emailCtrl = TextEditingController(text: _user!.email);
    String error = '';
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstCtrl,
                  decoration: const InputDecoration(labelText: 'First name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lastCtrl,
                  decoration: const InputDecoration(labelText: 'Last name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child:
                        Text(error, style: const TextStyle(color: Colors.red)),
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
                      if (firstCtrl.text.trim().isEmpty ||
                          lastCtrl.text.trim().isEmpty ||
                          emailCtrl.text.trim().isEmpty) {
                        setDialogState(
                            () => error = 'All fields are required');
                        return;
                      }
                      setDialogState(() => saving = true);
                      try {
                        await ApiService.updateUser(
                          _user!.id,
                          firstName: firstCtrl.text.trim(),
                          lastName: lastCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          role: _user!.role,
                       
                        );

                        final fresh = await ApiService.getUsers();
                        final match = fresh.firstWhere(
                          (j) =>
                              (j['_id'] ?? j['id']).toString() == _user!.id,
                          orElse: () => <String, dynamic>{},
                        );
                        if (match.isNotEmpty && mounted) {
                          setState(() {
                            _user = AppUser.fromJson(match);
                          });
                        }

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        if (mounted) {
                          showToast(context, 'Profile updated');
                        }
                      } catch (e) {
                        setDialogState(() {
                          error =
                              e.toString().replaceFirst('Exception: ', '');
                          saving = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
              ),
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_user == null) {
      showToast(context, 'No user loaded');
      return;
    }

    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String error = '';
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentCtrl,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Current password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'New password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Confirm new password'),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child:
                        Text(error, style: const TextStyle(color: Colors.red)),
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
                      if (currentCtrl.text.isEmpty ||
                          newCtrl.text.isEmpty ||
                          confirmCtrl.text.isEmpty) {
                        setDialogState(
                            () => error = 'All fields are required');
                        return;
                      }
                      if (newCtrl.text.length < 8 ||
                          newCtrl.text.length > 16) {
                        setDialogState(() => error =
                            'Password must be 8 to 16 characters');
                        return;
                      }
                      if (newCtrl.text != confirmCtrl.text) {
                        setDialogState(
                            () => error = 'New passwords do not match');
                        return;
                      }
                      setDialogState(() => saving = true);
                      try {
                        await ApiService.changePassword(
                          userId: _user!.id,
                          currentPassword: currentCtrl.text,
                          newPassword: newCtrl.text,
                        );

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        if (mounted) {
                          showToast(context, 'Password updated');
                        }
                      } catch (e) {
                        setDialogState(() {
                          error =
                              e.toString().replaceFirst('Exception: ', '');
                          saving = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
              ),
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Update Password'),
            ),
          ],
        ),
      ),
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