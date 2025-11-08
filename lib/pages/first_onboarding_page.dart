import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/adaptive_button.dart';

class FirstOnboardingPage extends StatelessWidget {
  const FirstOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if device is tablet (larger screen)
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768; // Tablet width threshold

    // Responsive sizing for full-screen appearance on tablets
    final double animationHeight = isTablet ? 400 : 300;
    final double titleFontSize = isTablet ? 32 : 24;
    final double subtitleFontSize = isTablet ? 20 : 16;
    final double horizontalPadding = isTablet ? 64.0 : 32.0;
    final double maxWidth = isTablet ? 600 : double.infinity; // Constrain width on tablets

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: animationHeight,
                  child: Lottie.asset('assets/animations/tracking.json'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to Auto RevOp',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Discover trusted mechanics and automotive solutions.',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
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
        ),
      ),
    );
  }
}