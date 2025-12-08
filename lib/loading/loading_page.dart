import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          height: 180,
          child: Lottie.asset(
            'assets/animations/loading.json',
            repeat: true,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}