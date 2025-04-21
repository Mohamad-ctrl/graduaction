// File: lib/main.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_service.dart';
import 'services/supabase_storage_service.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initializeFirebase();
  
  // Initialize Supabase
  await SupabaseStorageService.initialize(
    supabaseUrl: 'https://tuggaocvhaxbelzerfuu.supabase.co', // Replace with your Supabase URL
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1Z2dhb2N2aGF4YmVsemVyZnV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyNDQ3MTIsImV4cCI6MjA2MDgyMDcxMn0.JxXDYzRREs6CyVleyWVKBPIJsVKVJVP_YFlVFv4se8k', // Replace with your Supabase anon key
  );
  
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
    // Check if user is already logged in
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    // Simulate a delay for splash screen
    await Future.delayed(const Duration(seconds: 3));
    
    // Navigate to the appropriate screen based on authentication status
    // This will be implemented with Firebase Auth in the actual app
    Navigator.pushReplacementNamed(context, AppRoutes.login);
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
