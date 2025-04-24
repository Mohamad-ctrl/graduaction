import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_routes.dart';
import 'services/auth_service.dart';
import 'services/agent_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Supabase for storage
  await initializeSupabase();
  
  // Create mock agents for testing the admin panel
  final agentService = AgentService();
  try {
    await agentService.createMockAgents();
    print('Mock agents created successfully');
  } catch (e) {
    print('Error creating mock agents: $e');
  }
  
  runApp(const MyApp());
}

Future<void> initializeSupabase() async {
  // Initialize Supabase client
  // This would be implemented with actual Supabase credentials
  print('Supabase initialized');
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
      initialRoute: _determineInitialRoute(),
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
