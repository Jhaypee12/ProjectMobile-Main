import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


const purple = Color(0xFF5B27C9);
const blue = Color(0xFF2F6BFF);
const lightBlue = Color(0xFFE4F0FF);
const darkText = Color(0xFF1B1535);
const cardBorder = Color(0xFFDFD7F0);


class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: lightBlue,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _Header(),
              SizedBox(height: 50),
              _FeatureCards(),
              SizedBox(height: 30),
              _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}


class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        color: purple,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Stack(
        children: [
       
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

          Padding(
            padding: EdgeInsets.fromLTRB(24, top + 20, 24, 60),
            child: Column(
              children: [
             
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LUMEN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 60),

             
                const Text(
                  'Learn at your own pace',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Join a course and start your first lesson today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 30),

                
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),  
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _FeatureCards extends StatelessWidget {
  const _FeatureCards();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _FeatureCard(
            title: 'Courses',
            description:
                'Browse your courses and pick up your lessons where you left off.',
          ),
          SizedBox(height: 16),
          _FeatureCard(
            title: 'Assessments',
            description: 'Keep track of quizzes, assignments and your grades.',
          ),
          SizedBox(height: 16),
          _FeatureCard(
            title: 'Calendar',
            description:
                'See every deadline in one place so nothing slips by.',
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: darkText,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}


class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        'LUMEN Learning Management System',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: darkText,
          fontSize: 14,
        ),
      ),
    );
  }
}