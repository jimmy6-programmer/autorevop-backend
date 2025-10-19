import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/adaptive_button.dart';

class FirstOnboardingPage extends StatelessWidget {
  const FirstOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: Lottie.asset('assets/animations/tracking.json'),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to Auto RevOp',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Discover trusted mechanics and automotive solutions.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            adaptiveButton("Next", () {
              Navigator.pushNamed(context, '/onboarding2');
            }),
          ],
        ),
      ),
    );
  }
}