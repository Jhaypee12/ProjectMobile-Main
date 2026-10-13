import 'package:flutter/material.dart';

import '../role.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Role _role = Role.student;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  String get _subtitle => switch (_role) {
        Role.student => 'Log in to pick up your lessons where you left off.',
        Role.teacher => 'Log in to manage your courses and grading.',
        Role.admin => 'Log in to manage courses, people and announcements.',
      };

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      showToast(context, 'Please enter your email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await ApiService.login(
        email,
        password,
        _role.name.toUpperCase(),
      );

      if (!mounted) return;

      final route = switch (user.role.toUpperCase()) {
        'ADMIN' => '/admin',
        'TEACHER' => '/teacher',
        _ => '/student',
      };

      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false, arguments: user);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      showToast(context, msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: _subtitle,
      children: [
        const Text('Log in as',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),

        _RoleSelector(
          value: _role,
          onChanged: (r) => setState(() => _role = r),
        ),
        const SizedBox(height: 20),

        AppTextField(
          label: 'Email',
          hint: 'you@school.edu',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          controller: _emailCtrl,
        ),
        const SizedBox(height: 18),

        AppTextField(
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          controller: _passwordCtrl,
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () =>
                showAppModal(context, (_) => const ForgotPasswordModal()),
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.purple,
              ),
            ),
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 8),

        PrimaryButton(
          label: _isLoading ? 'Logging in…' : 'Log in',
          onPressed: _isLoading ? null : _login,
        ),
        const SizedBox(height: 20),

        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('New to $appName?',
                  style: const TextStyle(color: AppColors.muted)),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/register'),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.value, required this.onChanged});

  final Role value;
  final ValueChanged<Role> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purpleSoft, width: 1.2),
      ),
      child: Row(
        children: [
          for (final r in Role.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: r == value ? AppColors.purple : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        r.icon,
                        size: 17,
                        color: r == value ? Colors.white : AppColors.purple,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        r.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: r == value ? Colors.white : AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}