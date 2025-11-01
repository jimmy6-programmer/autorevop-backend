import 'package:auto_revop/pages/login_page.dart';
import 'package:auto_revop/widgets/adaptive_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_utils.dart'; // For getApiBaseUrl

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _resetPassword() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final response = await http.post(
      Uri.parse(
        '${getApiBaseUrl()}/api/auth/reset-password/${tokenController.text}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'password': passwordController.text}),
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);

        // Show success dialog for iOS
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Success!'),
              content: Text('Password reset successfully.'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Error!'),
              content: Text('Unexpected response from server.'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    } else {
      try {
        final data = json.decode(response.body);
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Failed!'),
              content: Text(data['message'] ?? 'Reset failed.'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      } catch (e) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Error!'),
              content: Text(
                'Server error or invalid response. Status: ${response.statusCode}',
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
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

              // ✅ Icon & Title
              Center(
                child: Column(
                  children: const [
                    Icon(
                      CupertinoIcons.checkmark_seal_fill,
                      size: 80,
                      color: CupertinoColors.activeBlue,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Reset password",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Enter the 6-digit code sent to your email",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CupertinoColors.secondaryLabel),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 🔑 Code Field
              CupertinoTextField(
                controller: tokenController,
                placeholder: "Reset Code (6 digits)",
                placeholderStyle: TextStyle(color: Colors.black),
                style: TextStyle(color: Colors.black),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
                padding: EdgeInsets.all(16.0),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 15),

              // 🔑 Password Field
              CupertinoTextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                placeholder: "New password",
                placeholderStyle: TextStyle(color: Colors.black),
                style: TextStyle(color: Colors.black),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
                padding: EdgeInsets.all(16.0),
                suffix: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    _obscurePassword
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 15),

              // 🔑 Confirm Password Field
              CupertinoTextField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                placeholder: "Confirm password",
                placeholderStyle: TextStyle(color: Colors.black),
                style: TextStyle(color: Colors.black),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
                padding: EdgeInsets.all(16.0),
                suffix: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    _obscureConfirmPassword
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),

              // 🔘 Centered Reset Button with modern Snackbar
              Center(child: adaptiveButton("Reset Password", _resetPassword)),
              const SizedBox(height: 15),

              // 🔗 Link to login
              Center(
                child: CupertinoButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Know your password? Log in",
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
