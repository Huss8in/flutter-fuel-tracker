import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/fuel_provider.dart';
import 'providers/maintenance_provider.dart';
import 'providers/car_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/add_car_screen.dart';
import 'screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FuelTrackerApp());
}

class FuelTrackerApp extends StatelessWidget {
  const FuelTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppAuthProvider()),
        ChangeNotifierProvider(create: (context) => FuelProvider()),
        ChangeNotifierProvider(create: (context) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (context) => CarProvider()),
      ],
      child: MaterialApp(
        title: 'Fuel Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
        ),
        home: const InitialScreenWrapper(),
        routes: {
          '/home': (context) => const MainNavigationScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, child) {
        // If guest mode, show dashboard directly with dummy data
        if (authProvider.isGuestMode) {
          return const MainNavigationScreen();
        }

        // Otherwise, check Firebase auth state
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Show loading indicator while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If user is logged in, check if they have cars
            if (snapshot.hasData) {
              return const CarCheckWrapper();
            }

            // Otherwise, show login screen
            return const LoginScreen();
          },
        );
      },
    );
  }
}

class CarCheckWrapper extends StatefulWidget {
  const CarCheckWrapper({super.key});

  @override
  State<CarCheckWrapper> createState() => _CarCheckWrapperState();
}

class _CarCheckWrapperState extends State<CarCheckWrapper> {
  late Future<void> _fetchCarsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future only once when the widget is first created
    _fetchCarsFuture = Provider.of<CarProvider>(
      context,
      listen: false,
    ).fetchCars();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchCarsFuture,
      builder: (context, snapshot) {
        // Show loading while checking for cars
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Use Consumer to listen for changes in CarProvider
        return Consumer<CarProvider>(
          builder: (context, carProvider, child) {
            // If user has no cars, show onboarding
            if (carProvider.cars.isEmpty) {
              return const AddCarScreen(isOnboarding: true);
            }

            // User has cars, show main navigation
            return const MainNavigationScreen();
          },
        );
      },
    );
  }
}

class InitialScreenWrapper extends StatefulWidget {
  const InitialScreenWrapper({super.key});

  @override
  State<InitialScreenWrapper> createState() => _InitialScreenWrapperState();
}

class _InitialScreenWrapperState extends State<InitialScreenWrapper> {
  bool? _seenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show empty container or loading indicator while checking prefs
    if (_seenOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_seenOnboarding!) {
      return const OnboardingScreen();
    }

    return const AuthWrapper();
  }
}
