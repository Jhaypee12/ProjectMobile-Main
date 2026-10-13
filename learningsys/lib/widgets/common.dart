import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}

/// Logo + project title.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: light ? Colors.white : AppColors.purple,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.auto_stories_rounded,
            size: 19,
            color: light ? AppColors.purple : Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          appName,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: light ? Colors.white : AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.background = AppColors.blue,
    this.foreground = Colors.white,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          minimumSize: const Size(0, 54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ice,
          foregroundColor: AppColors.purple,
          minimumSize: const Size(0, 54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.maxLines = 1,
    this.controller,
  });

  final String label;
  final String? hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextEditingController? controller;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  OutlineInputBorder _border(Color color, [double width = 1.2]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          maxLines: _obscure ? 1 : widget.maxLines,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppColors.muted),
            prefixIcon: Icon(widget.icon, color: AppColors.purple, size: 20),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.purple,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: _border(AppColors.purpleSoft, 1.2),
            enabledBorder: _border(AppColors.purpleSoft, 1.2),
            focusedBorder: _border(AppColors.purple, 1.6),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Auth screen layout: purple header + rounded sheet holding the form.
// ---------------------------------------------------------------------------

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.purple,
        body: Stack(
          children: [
            Positioned(
              right: -70,
              top: -70,
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.blue),
              ),
            ),
            Positioned.fill(
              child: Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Material(
                                color: AppColors.ice,
                                shape: const CircleBorder(),
                                child: IconButton(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                          '/', (route) => false),
                                  icon: const Icon(Icons.arrow_back_rounded,
                                      color: AppColors.purple),
                                ),
                              ),
                              const Spacer(),
                              const BrandMark(light: true),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            title,
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 34,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(subtitle,
                              style: const TextStyle(
                                  color: AppColors.iceDeep,
                                  fontSize: 15.5,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.ice,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: SafeArea(
                        top: false,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: children,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modals (bottom sheets)
// ---------------------------------------------------------------------------

Future<T?> showAppModal<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    constraints: const BoxConstraints(maxWidth: phoneMaxWidth),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            builder(ctx),
          ],
        ),
      ),
    ),
  );
}

class _ModalIcon extends StatelessWidget {
  const _ModalIcon(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.ice,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: AppColors.purple, size: 28),
    );
  }
}

class OtpField extends StatefulWidget {
  const OtpField({super.key});

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(6, (i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _controllers[i],
              focusNode: _nodes[i],
              autofocus: i == 0,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.bricolageGrotesque(
                  fontSize: 24, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.ice,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: _border(Colors.transparent, 0),
                enabledBorder: _border(Colors.transparent, 0),
                focusedBorder: _border(AppColors.blue, 2),
              ),
              onChanged: (v) {
                if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
                if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
              },
            ),
          ),
        );
      }),
    );
  }
}

/// Used for both Login OTP and Register OTP.
class OtpModal extends StatelessWidget {
  const OtpModal({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onVerified,
  });

  final String title;
  final String subtitle;
  final VoidCallback onVerified;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ModalIcon(Icons.mark_email_unread_outlined),
        const SizedBox(height: 20),
        Text(title, style: text.headlineSmall),
        const SizedBox(height: 8),
        Text(subtitle,
            style: const TextStyle(color: AppColors.muted, height: 1.5)),
        const SizedBox(height: 24),
        const OtpField(),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Verify code',
          onPressed: () {
            Navigator.of(context).pop();
            onVerified();
          },
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => showToast(context, 'A new code is on its way'),
            child: const Text("Didn't get a code? Resend"),
          ),
        ),
      ],
    );
  }
}

class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({super.key});

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (_sent) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ModalIcon(Icons.mark_email_read_outlined),
          const SizedBox(height: 20),
          Text('Check your inbox', style: text.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'We sent a reset link to your email. It stays valid for 30 minutes.',
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Back to log in',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ModalIcon(Icons.lock_reset_rounded),
        const SizedBox(height: 20),
        Text('Reset your password', style: text.headlineSmall),
        const SizedBox(height: 8),
        const Text(
          'Enter the email you signed up with and we will send you a link to choose a new password.',
          style: TextStyle(color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 24),
        const AppTextField(
          label: 'Email',
          hint: 'you@school.edu',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Send reset link',
          onPressed: () => setState(() => _sent = true),
        ),
      ],
    );
  }
}