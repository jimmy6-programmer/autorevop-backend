import 'package:flutter/material.dart';
import 'loading_page.dart';

class NavigationManager {
  static Future<void> navigateWithLoading(
    BuildContext context,
    Widget destinationPage, {
    bool replace = false,
  }) async {
    // Schedule navigation after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;

      // Push the loading page without animation to avoid flicker
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, _, __) => const LoadingPage(),
          transitionDuration: Duration.zero, // Immediate transition
        ),
      );

      // Simulate a brief delay to show the loading animation
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to the destination page
      if (replace) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context); // Remove loading page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        }
      }
    });
  }

  // Helper method for pushReplacement
  static Future<void> replaceWithLoading(
    BuildContext context,
    Widget destinationPage,
  ) {
    return navigateWithLoading(context, destinationPage, replace: true);
  }

  // Helper method for pop and push
  static Future<void> popAndPushWithLoading(
    BuildContext context,
    Widget destinationPage,
  ) async {
    if (context.mounted) {
      Navigator.pop(context); // Pop current page
      await navigateWithLoading(context, destinationPage);
    }
  }
}