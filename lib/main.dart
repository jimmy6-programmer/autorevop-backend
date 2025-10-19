import 'dart:io' show Platform;
import 'package:auto_solutions/loading/loading_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_solutions/pages/translations.dart';
import 'package:auto_solutions/pages/starting_page.dart';
import 'package:auto_solutions/pages/login_page.dart';
import 'package:auto_solutions/pages/signup_page.dart';
import 'package:auto_solutions/pages/home_page.dart';
import 'package:auto_solutions/pages/profile_page.dart';
import 'package:auto_solutions/pages/first_onboarding_page.dart';
import 'package:auto_solutions/pages/second_onboarding_page.dart';
import 'package:auto_solutions/pages/mechanics_page.dart';
import 'package:auto_solutions/pages/spare_parts_page.dart';
import 'package:auto_solutions/pages/bookings_page.dart';

// API Base URL configuration
String getApiBaseUrl() {
  return 'https://autorevop-backend.onrender.com'; // Production backend on Render
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // Preload Lottie animation
  await precacheLottie();

  runApp(MyApp(initialRoute: hasSeenOnboarding ? '/login' : '/'));
}

Future<void> precacheLottie() async {
  final assetLottie = AssetLottie('assets/animations/loading.json');
  await assetLottie.load(); // Load the Lottie composition into memory
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  Route<dynamic> _generateRoute(RouteSettings settings) {
    // Default language for translations
    const String defaultLanguage = 'English';
    final Map<String, String> defaultTranslations = translations[defaultLanguage]!;

    Widget page;

    switch (settings.name) {
      case '/':
        page = const StartingPage();
        break;
      case '/onboarding1':
        page = const FirstOnboardingPage();
        break;
      case '/onboarding2':
        page = const SecondOnboardingPage();
        break;
      case '/login':
        page = const LoginPage();
        break;
      case '/signup':
        page = const SignupPage();
        break;
      case '/home':
        page = const HomePage();
        break;
      case '/profile':
        page = ProfilePage(translations: defaultTranslations);
        break;
      case '/mechanics':
        page = MechanicsPage(translations: defaultTranslations);
        break;
      case '/spare_parts':
        page = SparePartsPage(translations: defaultTranslations);
        break;
      case '/bookings':
        page = BookingsPage(translations: defaultTranslations);
        break;
      default:
        page = const StartingPage();
    }

    // Wrap the destination page in LoadingPageWrapper
    return PageRouteBuilder(
      pageBuilder: (context, _, __) => LoadingPageWrapper(destinationPage: page),
      settings: settings,
      transitionDuration: Duration.zero, // Immediate transition
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoApp(
            title: 'Mechanic Service App',
            debugShowCheckedModeBanner: false,
            theme: const CupertinoThemeData(
              primaryColor: CupertinoColors.activeBlue,
            ),
            initialRoute: initialRoute,
            onGenerateRoute: _generateRoute,
          )
        : MaterialApp(
            title: 'Mechanic Service App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Roboto',
            ),
            initialRoute: initialRoute,
            onGenerateRoute: _generateRoute,
          );
  }
}

// Widget to handle loading animation before showing the destination page
class LoadingPageWrapper extends StatefulWidget {
  final Widget destinationPage;

  const LoadingPageWrapper({super.key, required this.destinationPage});

  @override
  State<LoadingPageWrapper> createState() => _LoadingPageWrapperState();
}

class _LoadingPageWrapperState extends State<LoadingPageWrapper> {
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    // Schedule navigation to the destination page after showing loading
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 500)); // Show loading for 500ms
      if (mounted) {
        setState(() {
          _showLoading = false; // Switch to destination page
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showLoading ? const LoadingPage() : widget.destinationPage;
  }
}