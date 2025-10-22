import 'dart:io' show Platform;
import 'package:auto_revop/pages/resetpassword_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:auto_revop/widgets/adaptive_button.dart';
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
    // Check if widget is still mounted before proceeding
    if (!mounted) return;

    final response = await http.post(
      Uri.parse('${getApiBaseUrl()}/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': emailController.text}),
    );

    // Check again if widget is still mounted
    if (!mounted) return;

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);

        if (Platform.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Success!'),
                content: Text(
                  data['message'] ?? 'Reset code sent to your email.',
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text('Continue'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      // Navigate to reset password page
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const ResetPasswordPage(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
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

          // Navigate immediately to reset password page
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResetPasswordPage(),
                ),
              );
            }
          });
        }
      } catch (e) {
        if (mounted) {
          if (Platform.isIOS) {
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
          } else {
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
        }
      }
    } else {
      try {
        final data = json.decode(response.body);
        if (mounted) {
          if (Platform.isIOS) {
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: Text('Failed!'),
                  content: Text(data['message'] ?? 'Failed to process request.'),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            );
          } else {
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
          }
        }
      } catch (e) {
        if (mounted) {
          if (Platform.isIOS) {
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
          } else {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Error!',
                message:
                    'Server error or invalid response. Status: ${response.statusCode}',
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoPageScaffold(
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

                    // 🔒 Icon & Title
                    Center(
                      child: Column(
                        children: const [
                          Icon(
                            CupertinoIcons.lock,
                            size: 80,
                            color: CupertinoColors.activeBlue,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Enter your email to reset your password",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 📧 Email Input
                    CupertinoTextField(
                      controller: emailController,
                      placeholder: "Email",
                      padding: EdgeInsets.all(16.0),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 30),

                    // 🔘 Centered Button
                    Center(child: adaptiveButton("Continue", _forgotPassword)),
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
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
                          Icon(
                            Icons.lock_outline,
                            size: 80,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
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
                    Center(child: adaptiveButton("Continue", _forgotPassword)),
                  ],
                ),
              ),
            ),
          );
  }
}
