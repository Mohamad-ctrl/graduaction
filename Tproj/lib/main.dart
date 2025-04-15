// File: lib/main.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'constants/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/orders_screen.dart';
import 'screens/home/profile_screen.dart';
import 'screens/account/account_center_screen.dart';
import 'screens/account/change_password_screen.dart';
import 'screens/inspections/inspection_request_screen.dart';
import 'screens/inspections/inspection_detail_screen.dart';
import 'screens/inspections/delivery_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check & Deliver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          // Updated TextTheme API for newer Flutter versions
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // was headline1
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87), // was bodyText1
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.orders: (context) => const OrdersScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.accountCenter: (context) => const AccountCenterScreen(),
        AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
        AppRoutes.inspectionRequest: (context) => const InspectionRequestScreen(),
        AppRoutes.inspectionDetail: (context) => const InspectionDetailScreen(),
        AppRoutes.deliveryDetail: (context) => const DeliveryDetailScreen(),
      },
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a delay before navigating to the login screen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF1E3A5F), // Dark blue background from Figma
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Check & Deliver',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
