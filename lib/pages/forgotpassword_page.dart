import 'package:auto_solutions/pages/resetpassword_page.dart';
import 'package:auto_solutions/widgets/adaptive_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../utils/api_utils.dart'; // For getApiBaseUrl

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  Future<void> _forgotPassword() async {
    final response = await http.post(
      Uri.parse('${getApiBaseUrl()}/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success!',
            message: data['message'] ?? 'Reset code sent to your email.',
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
          );
        });
      } catch (e) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Unexpected response from server.',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      try {
        final data = json.decode(response.body);
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Failed!',
            message: data['message'] ?? 'Failed to process request.',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } catch (e) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Server error or invalid response. Status: ${response.statusCode}',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

              // 🔒 Icon & Title
              Center(
                child: Column(
                  children: const [
                    Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                    SizedBox(height: 20),
                    Text(
                      "Forgot password?",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Enter your email to reset your password",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 📧 Email Input
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),

              // 🔘 Centered Button
              Center(
                child: adaptiveButton("Continue", _forgotPassword),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
