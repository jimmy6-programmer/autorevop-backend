
import 'package:auto_revop/pages/resetpassword_page.dart';
import 'package:auto_revop/widgets/adaptive_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TextEditingController> otpControllers =
        List.generate(5, (index) => TextEditingController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 Back Button
              IconButton(
                icon: const Icon(CupertinoIcons.back, color: Colors.blue),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 40),

              // 🔑 Icon & Title
              Center(
                child: Column(
                  children: const [
                    Icon(Icons.vpn_key, size: 80, color: Colors.blue),
                    SizedBox(height: 20),
                    Text(
                      "Enter OTP",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Enter the 5-digit code sent to your email",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 🔢 OTP Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (index) => SizedBox(
                    width: 50,
                    child: TextField(
                      controller: otpControllers[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: const InputDecoration(counterText: ""),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 🔘 Centered Button
              Center(
                child: adaptiveButton("Continue", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // 🔄 Resend link
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Resend Code",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
