import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'translations.dart';

class SuccessPage extends StatefulWidget {
   final String? location;
   final String? phone;
   final String? vehicleBrand;
   final String? selectedLanguage;

   const SuccessPage({super.key, this.location, this.phone, this.vehicleBrand, this.selectedLanguage});

   @override
   _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
   String _selectedLanguage = 'English'; // Default language

   @override
   void initState() {
     super.initState();
     _selectedLanguage = widget.selectedLanguage ?? 'English';
   }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoPageScaffold(
            backgroundColor: CupertinoColors.white,
            navigationBar: CupertinoNavigationBar(
              transitionBetweenRoutes: false,
              backgroundColor: CupertinoColors.white,
            ),
            child: SafeArea(
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
                          repeat:
                              true, // Keep as true for looping success animation
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        translations[_selectedLanguage]?['success'] ?? 'Success',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Message
                      Text(
                        translations[_selectedLanguage]?['successMessage'] ??
                        "We truly appreciate the time you took to contact us. "
                        "Our team will be assisting you very shortly.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Location
                      if (widget.location != null && widget.location!.isNotEmpty)
                        Text(
                          "${translations[_selectedLanguage]?['deliveryLocation'] ?? 'Delivery Location'}: ${widget.location}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      if (widget.location != null && widget.location!.isNotEmpty)
                        const SizedBox(height: 8),
                      // Phone
                      if (widget.phone != null && widget.phone!.isNotEmpty)
                        Text(
                          "${translations[_selectedLanguage]?['contactNumber'] ?? 'Contact Number'}: ${widget.phone}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      if (widget.phone != null && widget.phone!.isNotEmpty)
                        const SizedBox(height: 8),
                      // Vehicle Brand
                      if (widget.vehicleBrand != null && widget.vehicleBrand!.isNotEmpty)
                        Text(
                          "${translations[_selectedLanguage]?['vehicleBrand'] ?? 'Vehicle Brand'}: ${widget.vehicleBrand}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      const SizedBox(height: 40),
                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          onPressed: () {
                            // For iOS, pop back to the home tab (which is the root of the tab view)
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                          child: Text(
                            translations[_selectedLanguage]?['returnToHome'] ?? 'Return to Home',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
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
                          repeat:
                              true, // Keep as true for looping success animation
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        translations[_selectedLanguage]?['success'] ?? 'Success',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Message
                      Text(
                        translations[_selectedLanguage]?['successMessage'] ??
                        "We truly appreciate the time you took to contact us. "
                        "Our team will be assisting you very shortly.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      // Location
                      if (widget.location != null && widget.location!.isNotEmpty)
                        Text(
                          "${translations[_selectedLanguage]?['deliveryLocation'] ?? 'Delivery Location'}: ${widget.location}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      if (widget.location != null && widget.location!.isNotEmpty)
                        const SizedBox(height: 8),
                      // Phone
                      if (widget.phone != null && widget.phone!.isNotEmpty)
                        Text(
                          "${translations[_selectedLanguage]?['contactNumber'] ?? 'Contact Number'}: ${widget.phone}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      if (widget.phone != null && widget.phone!.isNotEmpty)
                        const SizedBox(height: 8),
                      // Vehicle Brand
                      if (widget.vehicleBrand != null && widget.vehicleBrand!.isNotEmpty)
                        Text(
                          "${translations[_selectedLanguage]?['vehicleBrand'] ?? 'Vehicle Brand'}: ${widget.vehicleBrand}",
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
                            // For Android, clear navigation stack and go to home
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Text(
                            translations[_selectedLanguage]?['returnToHome'] ?? 'Return to Home',
                            style: const TextStyle(
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

