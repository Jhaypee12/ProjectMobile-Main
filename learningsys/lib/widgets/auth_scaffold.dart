import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import 'common.dart';

/// Shared layout for Login and Register:
/// split screen on wide displays, single column on phones.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.panelTitle,
    required this.panelBody,
    required this.form,
  });

  final String panelTitle;
  final String panelBody;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth >= 900;
          final formSide = _FormSide(form: form, showBrand: !wide);
          if (!wide) return formSide;
          return Row(
            children: [
              Expanded(
                flex: 5,
                child: _BrandPanel(title: panelTitle, body: panelBody),
              ),
              Expanded(flex: 6, child: formSide),
            ],
          );
        },
      ),
    );
  }
}

class _FormSide extends StatelessWidget {
  const _FormSide({required this.form, required this.showBrand});
  final Widget form;
  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.muted,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back to home'),
                ),
                const SizedBox(height: 24),
                if (showBrand) ...[
                  const BrandMark(),
                  const SizedBox(height: 28),
                ],
                form,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.title, required this.body});
  final String title;
  final String body;

  static const _points = [
    'Courses, quizzes and grades in one place',
    'Live classes with reminders',
    'Progress that follows you across devices',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.purple,
      child: Stack(
        children: [
          Positioned(
            right: -90,
            top: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.blue),
            ),
          ),
          Positioned(
            left: -70,
            bottom: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0x1FFFFFFF)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandMark(light: true),
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 44,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    body,
                    style: const TextStyle(
                        color: AppColors.iceDeep, fontSize: 17, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  for (final p in _points)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.ice, size: 20),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(p,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
