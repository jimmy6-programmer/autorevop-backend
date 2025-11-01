import 'dart:io' show Platform;
import 'package:auto_revop/pages/forgotpassword_page.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../widgets/adaptive_button.dart';
import '../utils/api_utils.dart'; // For getApiBaseUrl
import '../utils/auth_utils.dart'; // For authentication utilities

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${getApiBaseUrl()}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        final token = data['token'];
        final userId = data['user']?['_id'] ?? data['user']?['id'] ?? '';
        final email = data['user']?['email'] ?? _emailController.text;
        final name = data['user']?['name'];
        final phone = data['user']?['phone'];
        final country = data['user']?['country'];

        // Store authentication data using AuthUtils
        await AuthUtils.setAuthData(token, userId, email, name: name, phone: phone, country: country);

        setState(() {
          _isLoading = false;
        });

        if (Platform.isIOS) {
          // For iOS, show success dialog and navigate
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Success!'),
                content: Text('Login successful.'),
                actions: [
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, '/home');
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
              message: 'Login successful.',
              contentType: ContentType.success,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/home');
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

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
    } else {
      setState(() {
        _isLoading = false;
      });

      try {
        final data = json.decode(response.body);
        if (Platform.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Failed!'),
                content: Text(
                  data['message'] ??
                      'Login failed. Please check your credentials.',
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
              title: 'Failed!',
              message:
                  data['message'] ??
                  'Login failed. Please check your credentials.',
              contentType: ContentType.failure,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoPageScaffold(
            backgroundColor: Colors.white,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/ic_launcher.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 40),
                      Text(
                        'Welcome Back 👋',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Login to your account to get started.',
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      CupertinoTextField(
                        controller: _emailController,
                        placeholder: 'Email Address',
                        placeholderStyle: TextStyle(color: Colors.black),
                        style: TextStyle(color: Colors.black),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 235, 233, 233),
                        ),
                        prefix: Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Icon(
                            CupertinoIcons.mail,
                            color: const Color.fromARGB(255, 35, 35, 35),
                          ),
                        ),
                        padding: EdgeInsets.all(16.0),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 15),
                      CupertinoTextField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        placeholderStyle: TextStyle(color: Colors.black),
                        style: TextStyle(color: Colors.black),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 235, 233, 233),
                        ),
                        prefix: Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Icon(
                            CupertinoIcons.lock,
                            color: const Color.fromARGB(255, 35, 35, 35),
                          ),
                        ),
                        suffix: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        padding: EdgeInsets.all(16.0),
                        obscureText: _obscurePassword,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16.0, top: 8.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      adaptiveButton('Login', _login, isLoading: _isLoading),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/ic_launcher.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Welcome Back 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Login to your account to get started.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(
                          CupertinoIcons.mail,
                          color: Colors.grey,
                        ),
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(17, 131, 192, 1),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(
                          CupertinoIcons.lock,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(17, 131, 192, 1),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 16.0, top: 8.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    adaptiveButton('Login', _login, isLoading: _isLoading),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
