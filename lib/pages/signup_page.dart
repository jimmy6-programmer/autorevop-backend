import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../widgets/adaptive_button.dart';
import '../utils/api_utils.dart'; // For getApiBaseUrl
// For authentication utilities

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
  String? selectedCountry;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false; // Track Terms and Conditions acceptance

  // Show Terms and Conditions dialog
  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Terms and Conditions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome to Auto RevOp',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'By using our automotive marketplace application, you agree to the following terms and conditions:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '1. User Responsibilities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• You must provide accurate and complete information when creating your account.\n'
                  '• You are responsible for maintaining the confidentiality of your account credentials.\n'
                  '• You agree to use the application only for lawful purposes.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '2. Service Usage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Our platform connects users with automotive service providers and spare parts.\n'
                  '• We strive to provide accurate information but cannot guarantee the quality of services.\n'
                  '• Users should verify service provider credentials and reviews before booking.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '3. Privacy and Data Protection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• We collect and process personal information in accordance with our Privacy Policy.\n'
                  '• Your data is stored securely and used only for providing our services.\n'
                  '• We do not share your personal information with third parties without your consent.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '4. Payment and Transactions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• All payments are processed securely through our payment partners.\n'
                  '• You agree to pay for services booked through our platform.\n'
                  '• Refunds are subject to the service provider\'s cancellation policy.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '5. Limitation of Liability',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Auto RevOp acts as a platform connecting users with service providers.\n'
                  '• We are not responsible for the quality or outcome of services provided.\n'
                  '• Our liability is limited to the amount paid for services through our platform.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '6. Account Termination',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• We reserve the right to suspend or terminate accounts that violate these terms.\n'
                  '• Users may delete their accounts at any time.\n'
                  '• Upon termination, your right to use the service ceases immediately.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  'By agreeing to these terms, you acknowledge that you have read, understood, and accept all the conditions outlined above.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _acceptTerms = true;
                });
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Agree'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signup() async {
    // Check if terms are accepted
    if (!_acceptTerms) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Terms Required!',
          message: 'Please accept the Terms and Conditions to continue.',
          contentType: ContentType.warning,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

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
        // Note: Signup doesn't automatically log the user in
        // They need to login separately

        if (Platform.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Success!'),
                content: Text('Account created successfully. Please login.'),
                actions: [
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/login');
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
              message: 'Account created successfully. Please login.',
              contentType: ContentType.success,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushNamed(context, '/login');
          });
        }
      } catch (e) {
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
      try {
        final data = json.decode(response.body);
        if (Platform.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Failed!'),
                content: Text(
                  data['message'] ?? 'Signup failed. Please try again.',
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
              message: data['message'] ?? 'Signup failed. Please try again.',
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
                      SizedBox(height: 10),
                      Text(
                        'Welcome New User👋',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Create an account to get started.',
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      CupertinoTextField(
                        controller: _nameController,
                        placeholder: 'Full Name',
                        placeholderStyle: TextStyle(color: Colors.black),
                        style: TextStyle(color: Colors.black),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1.0),
                          ),
                        ),
                        prefix: Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Icon(
                            CupertinoIcons.person,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        padding: EdgeInsets.all(16.0),
                      ),
                      SizedBox(height: 15),
                      CupertinoTextField(
                        controller: _emailController,
                        placeholder: 'Email Address',
                        placeholderStyle: TextStyle(color: Colors.black),
                        style: TextStyle(color: Colors.black),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1.0),
                          ),
                        ),
                        prefix: Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Icon(
                            CupertinoIcons.mail,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        padding: EdgeInsets.all(16.0),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 15),
                      CupertinoTextField(
                        controller: _phoneController,
                        placeholder: 'Phone (Optional)',
                        placeholderStyle: TextStyle(color: Colors.black),
                        style: TextStyle(color: Colors.black),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1.0),
                          ),
                        ),
                        prefix: Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Icon(
                            CupertinoIcons.phone,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        padding: EdgeInsets.all(16.0),
                        keyboardType: TextInputType.phone,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0),
                        child: Text(
                          'Optional – only needed if you request a service that requires this info.',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) => Container(
                              height: 250,
                              color: CupertinoColors.systemBackground,
                              child: CupertinoPicker(
                                itemExtent: 32.0,
                                onSelectedItemChanged: (int index) {
                                  setState(() {
                                    selectedCountry = [
                                      'Rwanda',
                                      'Kenya',
                                      'Tanzania',
                                      'Cameroon',
                                      'South Africa',
                                      'Cote d\'Ivoire',
                                      'Botswana',
                                      'Nigeria',
                                      'Ghana',
                                      'DRC',
                                    ][index];
                                  });
                                },
                                children: [
                                  Text('🇷🇼 Rwanda', style: TextStyle(color: Colors.black)),
                                  Text('🇰🇪 Kenya', style: TextStyle(color: Colors.black)),
                                  Text('🇹🇿 Tanzania', style: TextStyle(color: Colors.black)),
                                  Text('🇨🇲 Cameroon', style: TextStyle(color: Colors.black)),
                                  Text('🇿🇦 South Africa', style: TextStyle(color: Colors.black)),
                                  Text('🇨🇮 Cote d\'Ivoire', style: TextStyle(color: Colors.black)),
                                  Text('🇧🇼 Botswana', style: TextStyle(color: Colors.black)),
                                  Text('🇳🇬 Nigeria', style: TextStyle(color: Colors.black)),
                                  Text('🇬🇭 Ghana', style: TextStyle(color: Colors.black)),
                                  Text('🇨🇩 DRC', style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.globe,
                                color: CupertinoColors.systemGrey,
                              ),
                              SizedBox(width: 16),
                              Text(
                                selectedCountry ?? 'Select your country',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0),
                        child: Text(
                          'Optional – only needed if you request a service that requires this info.',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      CupertinoTextField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        placeholderStyle: TextStyle(color: Colors.black),
                        style: TextStyle(color: Colors.black),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1.0),
                          ),
                        ),
                        prefix: Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Icon(
                            CupertinoIcons.lock,
                            color: CupertinoColors.systemGrey,
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
                      SizedBox(height: 15),
                      CupertinoTextField(
                        controller: _confirmPasswordController,
                        placeholder: 'Confirm Password',
                        placeholderStyle: TextStyle(color: Colors.black),
                        style: TextStyle(color: Colors.black),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1.0),
                          ),
                        ),
                        prefix: Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Icon(
                            CupertinoIcons.lock,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        suffix: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          child: Icon(
                            _obscureConfirmPassword
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        padding: EdgeInsets.all(16.0),
                        obscureText: _obscureConfirmPassword,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      SizedBox(height: 20),
                      // Terms and Conditions Checkbox
                      Row(
                        children: [
                          CupertinoCheckbox(
                            value: _acceptTerms,
                            onChanged: (bool? value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.label,
                                ),
                                children: [
                                  const TextSpan(text: 'I accept the '),
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: const TextStyle(
                                      color: CupertinoColors.activeBlue,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showTermsAndConditions,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      adaptiveButton('Signup', _signup, isEnabled: _acceptTerms),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              'Login',
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
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(
                          CupertinoIcons.person,
                          color: Colors.grey,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(17, 131, 192, 1),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(
                          CupertinoIcons.mail,
                          color: Colors.grey,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(17, 131, 192, 1),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _phoneController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Phone (Optional)',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(
                          CupertinoIcons.phone,
                          color: Colors.grey,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(17, 131, 192, 1),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                        fillColor: Colors.white,
                        filled: true,
                        helperText: 'Optional – only needed if you request a service that requires this info.',
                        helperStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                    value: selectedCountry,
                    style: TextStyle(color: Colors.black),
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Country (Optional)',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(
                        CupertinoIcons.globe,
                        color: Colors.grey,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(17, 131, 192, 1),
                          width: 2.0,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(16.0),
                      fillColor: Colors.white,
                      filled: true,
                      helperText: 'Optional – only needed if you request a service that requires this info.',
                      helperStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                      items: [
                        DropdownMenuItem(
                          value: 'Rwanda',
                          child: Row(children: [Text('🇷🇼 ', style: TextStyle(color: Colors.black)), Text('Rwanda', style: TextStyle(color: Colors.black))]),
                        ),
                        DropdownMenuItem(
                          value: 'Kenya',
                          child: Row(children: [Text('🇰🇪 ', style: TextStyle(color: Colors.black)), Text('Kenya', style: TextStyle(color: Colors.black))]),
                        ),
                        DropdownMenuItem(
                          value: 'Tanzania',
                          child: Row(
                            children: [Text('🇹🇿 ', style: TextStyle(color: Colors.black)), Text('Tanzania', style: TextStyle(color: Colors.black))],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Cameroon',
                          child: Row(children: [Text('🇨🇲 ', style: TextStyle(color: Colors.black)), Text('Cameroon', style: TextStyle(color: Colors.black))]),
                        ),
                        DropdownMenuItem(
                          value: 'South Africa',
                          child: Row(children: [Text('🇿🇦 ', style: TextStyle(color: Colors.black)), Text('South Africa', style: TextStyle(color: Colors.black))]),
                        ),
                        DropdownMenuItem(
                          value: 'Cote d\'Ivoire',
                          child: Row(children: [Text('🇨🇮 ', style: TextStyle(color: Colors.black)), Text('Cote d\'Ivoire', style: TextStyle(color: Colors.black))]),
                        ),
                        DropdownMenuItem(
                          value: 'Botswana',
                          child: Row(children: [Text('🇧🇼 ', style: TextStyle(color: Colors.black)), Text('Botswana', style: TextStyle(color: Colors.black))]),
                        ),
                        DropdownMenuItem(
                          value: 'Nigeria',
                          child: Row(children: [Text('🇳🇬 ', style: TextStyle(color: Colors.black)), Text('Nigeria', style: TextStyle(color: Colors.black))]),
                        ),
                        DropdownMenuItem(
                          value: 'Ghana',
                          child: Row(children: [Text('🇬🇭 ', style: TextStyle(color: Colors.black)), Text('Ghana', style: TextStyle(color: Colors.black))]),
                        ),
                        DropdownMenuItem(
                          value: 'DRC',
                          child: Row(children: [Text('🇨🇩 ', style: TextStyle(color: Colors.black)), Text('DRC', style: TextStyle(color: Colors.black))]),
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
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
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
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(17, 131, 192, 1),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _confirmPasswordController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(
                          CupertinoIcons.lock,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(17, 131, 192, 1),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      obscureText: _obscureConfirmPassword,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      SizedBox(height: 20),
                      // Terms and Conditions Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (bool? value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                children: [
                                  const TextSpan(text: 'I accept the '),
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showTermsAndConditions,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      adaptiveButton('Signup', _signup, isEnabled: _acceptTerms),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
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
