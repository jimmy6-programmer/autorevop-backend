import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessPage extends StatelessWidget {
  final String? location;
  final String? phone;
  final String? vehicleBrand;

  const SuccessPage({super.key, this.location, this.phone, this.vehicleBrand});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie success animation
                SizedBox(
                  height: 180,
                  child: Lottie.asset(
                    'assets/animations/success.json',
                    repeat: true, // Keep as true for looping success animation
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  "Success",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Message
                const Text(
                  "We truly appreciate the time you took to contact us. "
                  "Our team will be assisting you very shortly.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                // Location
                if (location != null && location!.isNotEmpty)
                  Text(
                    "Delivery Location: $location",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                if (location != null && location!.isNotEmpty) const SizedBox(height: 8),
                // Phone
                if (phone != null && phone!.isNotEmpty)
                  Text(
                    "Contact Number: $phone",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                if (phone != null && phone!.isNotEmpty) const SizedBox(height: 8),
                // Vehicle Brand
                if (vehicleBrand != null && vehicleBrand!.isNotEmpty)
                  Text(
                    "Vehicle Brand: $vehicleBrand",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                const SizedBox(height: 40),
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // Use named route to ensure LoadingPageWrapper is used
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Text(
                      "Return to Home",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}