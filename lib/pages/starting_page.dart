import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/adaptive_button.dart';

class StartingPage extends StatelessWidget {
  const StartingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Auto RevOp',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: Lottie.asset('assets/animations/handshake_car.json'),
            ),
            const SizedBox(height: 30),
            Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: Text(
                'Find mechanics & Products Anytime',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: Text(
                'Your ultimate automotive solution, connecting you with trusted experts and essential parts with ease',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            adaptiveButton("Get Started", () {
              Navigator.pushNamed(context, '/onboarding1');
            }),
          ],
        ),
      ),
    );
  }
}