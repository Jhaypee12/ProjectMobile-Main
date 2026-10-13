import 'package:flutter/material.dart';
import '../services/api_service.dart';

const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  String message = '';
  bool isError = false;
  bool isSaving = false;

  Future<void> register() async {
    final firstName = firstNameCtrl.text.trim();
    final lastName = lastNameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;
    final confirm = confirmCtrl.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      setState(() {
        isError = true;
        message = 'Please fill in all fields';
      });
      return;
    }

    if (firstName.length < 3 || firstName.length > 20) {
      setState(() {
        isError = true;
        message = 'First name must be 3 to 20 characters';
      });
      return;
    }

    if (lastName.length < 3 || lastName.length > 20) {
      setState(() {
        isError = true;
        message = 'Last name must be 3 to 20 characters';
      });
      return;
    }

    if (!email.contains('@') || !email.contains('.') || email.length > 30) {
      setState(() {
        isError = true;
        message = 'Please enter a valid email';
      });
      return;
    }

    if (password.length < 8 || password.length > 16) {
      setState(() {
        isError = true;
        message = 'Password must be 8 to 16 characters';
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        isError = true;
        message = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      isSaving = true;
      message = '';
      isError = false;
    });

    try {
      await ApiService.register(firstName, lastName, email, password);

      if (!mounted) return;

      setState(() {
        isError = false;
        message = 'Account created';
      });

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
        arguments: email,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        isError = true;
        message = msg;
        isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x335B27C9),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 190,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(color: purple),
                        ),
                        Positioned(
                          top: -80,
                          right: -80,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: const BoxDecoration(
                              color: blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(30, 30, 30, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'LUMEN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Create your account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Join a course and start your first lesson today.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(30),
                    color: lightBlue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: firstNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'First name',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: lastNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Last name',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: confirmCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (message.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isError
                                  ? const Color(0xFFFFE5E5)
                                  : const Color(0xFFE5FFE5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              message,
                              style: TextStyle(
                                color: isError
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: isSaving ? null : register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isSaving ? 'Creating account…' : 'Register',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account? '),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                  context, '/login'),
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  color: purple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}