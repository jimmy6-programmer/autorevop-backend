import 'dart:io' show Platform;
import 'loading/loading_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'providers/translation_provider.dart';
import 'providers/cart_provider.dart';
import 'services/optimized_api_service.dart';
import 'pages/starting_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/first_onboarding_page.dart';
import 'pages/second_onboarding_page.dart';
import 'pages/mechanics_page.dart';
import 'pages/spare_parts_page.dart';
import 'pages/bookings_page.dart';
import 'pages/cart_page.dart';
import 'pages/detailing_page.dart';
import 'utils/auth_utils.dart';

// API Base URL configuration
String getApiBaseUrl() {
  return 'https://autorevop-backend.onrender.com'; // Production backend on Render
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload Lottie animation
  await precacheLottie();

  // Preload critical API data in background
  OptimizedApiService().preloadCriticalData();

  // Get SharedPreferences for onboarding and login status
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  final isLoggedIn = await AuthUtils.isLoggedIn();

  // Determine initial route
  String initialRoute;
  if (!hasSeenOnboarding) {
    initialRoute = '/';
  } else if (isLoggedIn) {
    initialRoute = '/home';
  } else {
    initialRoute = '/login';
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

Future<void> precacheLottie() async {
  final assetLottie = AssetLottie('assets/animations/loading.json');
  await assetLottie.load(); // Load the Lottie composition into memory
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  Route<dynamic> _generateRoute(RouteSettings settings) {
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
        page = ProfilePage();
        break;
      case '/mechanics':
        page = MechanicsPage();
        break;
      case '/spare_parts':
        page = SparePartsPage();
        break;
      case '/bookings':
        page = BookingsPage();
        break;
      case '/cart':
        page = const CartPage();
        break;
      case '/detailing':
        page = const DetailingPage();
        break;
      default:
        page = const StartingPage();
    }

    // Wrap the destination page in LoadingPageWrapper
    return PageRouteBuilder(
      pageBuilder: (context, _, __) =>
          LoadingPageWrapper(destinationPage: page),
      settings: settings,
      transitionDuration: Duration.zero, // Immediate transition
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        // Use English for system widgets since we don't have custom locales
        final effectiveLocale = const Locale('en');

        return ScreenUtilInit(
          designSize: const Size(375, 812), // iPhone X design size
          minTextAdapt: true,
          splitScreenMode: true,
          useInheritedMediaQuery: true,
          builder: (context, child) => Platform.isIOS
              ? ScaffoldMessenger(
                  child: CupertinoApp(
                    title: 'Auto RevOp',
                    debugShowCheckedModeBanner: false,
                    locale: effectiveLocale,
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('en'),
                      Locale('fr'),
                      Locale('rw'),
                      Locale('sw'),
                    ],
                    theme: const CupertinoThemeData(
                      primaryColor: CupertinoColors.activeBlue,
                    ),
                    initialRoute: initialRoute,
                    onGenerateRoute: _generateRoute,
                  ),
                )
              : MaterialApp(
                  title: 'Auto RevOp',
                  debugShowCheckedModeBanner: false,
                  locale: effectiveLocale,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'),
                    Locale('fr'),
                    Locale('rw'),
                    Locale('sw'),
                  ],
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    fontFamily: 'Roboto',
                  ),
                  initialRoute: initialRoute,
                  onGenerateRoute: _generateRoute,
                ),
        );
      },
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
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Show loading for 500ms
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
