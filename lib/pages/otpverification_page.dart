
import 'package:auto_revop/pages/resetpassword_page.dart';
import 'package:auto_revop/widgets/adaptive_button.dart';
import 'package:flutter/cupertino.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TextEditingController> otpControllers =
        List.generate(5, (index) => TextEditingController());

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 Back Button
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.back,
                  color: CupertinoColors.activeBlue,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 40),

              // 🔑 Icon & Title
              Center(
                child: Column(
                  children: const [
                    Icon(CupertinoIcons.lock_shield_fill, size: 80, color: CupertinoColors.activeBlue),
                    SizedBox(height: 20),
                    Text(
                      "Enter OTP",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Enter the 5-digit code sent to your email",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CupertinoColors.secondaryLabel),
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
                    child: CupertinoTextField(
                      controller: otpControllers[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      padding: EdgeInsets.all(12.0),
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
                    CupertinoPageRoute(builder: (context) => const ResetPasswordPage()),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // 🔄 Resend link
              Center(
                child: CupertinoButton(
                  onPressed: () {},
                  child: const Text(
                    "Resend Code",
                    style: TextStyle(color: CupertinoColors.activeBlue),
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
