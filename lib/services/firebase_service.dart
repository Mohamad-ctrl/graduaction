// File: lib/services/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }
}
