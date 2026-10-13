import 'package:flutter/material.dart';

import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/register_page.dart';
import 'pages/role_shell.dart';
import 'role.dart';
import 'services/api_service.dart';
import 'theme.dart';

void main() => runApp(const LumenApp());

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      builder: (context, child) => ColoredBox(
        color: AppColors.line,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: phoneMaxWidth),
            child: child,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/student': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as AppUser?;
          return RoleShell(role: Role.student, user: user);
        },
        '/teacher': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as AppUser?;
          return RoleShell(role: Role.teacher, user: user);
        },
        '/admin': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as AppUser?;
          return RoleShell(role: Role.admin, user: user);
        },
        '/profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;

          if (args is Map) {
            return ProfilePage(
              role: args['role'] as Role,
              user: args['user'] as AppUser?,
            );
          }
          if (args is Role) {
            return ProfilePage(role: args);
          }
          return const ProfilePage(role: Role.student);
        },
      },
    );
  }
}