import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../widgets/adaptive_button.dart';
import '../utils/api_utils.dart'; // For getApiBaseUrl

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  String? selectedCountry = 'Rwanda';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error!',
          message: 'Passwords do not match.',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final response = await http.post(
      Uri.parse('${getApiBaseUrl()}/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'phone': _phoneController.text,
        'country': selectedCountry,
      }),
    );

    if (response.statusCode == 201) {
      try {
        final data = json.decode(response.body);
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success!',
            message: 'Account created successfully. Please login.',
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamed(context, '/login');
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
            message: data['message'] ?? 'Signup failed. Please try again.',
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
              SizedBox(height: 10),
              Text(
                'Welcome New User👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Create an account to get started.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(CupertinoIcons.person, color: Colors.grey),
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(17, 131, 192, 1),
                      width: 2.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(16.0),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(CupertinoIcons.mail, color: Colors.grey),
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
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(CupertinoIcons.phone, color: Colors.grey),
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(17, 131, 192, 1),
                      width: 2.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(16.0),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: selectedCountry,
                decoration: InputDecoration(
                  labelText: 'Country',
                  prefixIcon: Icon(CupertinoIcons.globe, color: Colors.grey),
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(17, 131, 192, 1),
                      width: 2.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(16.0),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Rwanda',
                    child: Row(
                      children: [
                        Text('🇷🇼 '),
                        Text('Rwanda'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Kenya',
                    child: Row(
                      children: [
                        Text('🇰🇪 '),
                        Text('Kenya'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Tanzania',
                    child: Row(
                      children: [
                        Text('🇹🇿 '),
                        Text('Tanzania'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                  });
                },
              ),
              SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(CupertinoIcons.lock, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye, color: Colors.grey),
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
              SizedBox(height: 15),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(CupertinoIcons.lock, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
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
                obscureText: _obscureConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
              ),
              SizedBox(height: 30),
              adaptiveButton('Signup', _signup),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Login',
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