import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants/app_routes.dart';
import 'services/auth_service.dart';
import 'services/agent_service.dart';
import 'services/supabase_storage_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  
  // Initialize Supabase for storage with the provided credentials
  await SupabaseStorageService.initialize(
    supabaseUrl: 'https://tuggaocvhaxbelzerfuu.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1Z2dhb2N2aGF4YmVsemVyZnV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyNDQ3MTIsImV4cCI6MjA2MDgyMDcxMn0.JxXDYzRREs6CyVleyWVKBPIJsVKVJVP_YFlVFv4se8k',
  );
  print('Supabase initialized with actual credentials');
  
    // Reset and create mock agents for testing the admin panel
    final agentService = AgentService();
    const int numberOfMockAgents = 15; // Define how many agents to create
    try {
      await agentService.resetAndCreateMockAgents(numberOfMockAgents);
      print("Successfully reset and created $numberOfMockAgents mock agents");
    } catch (e) {
      print("Error resetting/creating mock agents: $e");
    }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check & Deliver',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        primaryColor: Colors.indigo[900],
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo[900],
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[900],
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.indigo[900]!, width: 2),
          ),
        ),
      ),
      initialRoute: AppRoutes.splash, // Start with the splash screen
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  String _determineInitialRoute() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return AppRoutes.home;
    }
    return AppRoutes.login;
  }
}
