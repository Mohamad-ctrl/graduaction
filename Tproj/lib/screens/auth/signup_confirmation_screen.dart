import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class SignupConfirmationScreen extends StatefulWidget {
  final User user;

  const SignupConfirmationScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SignupConfirmationScreenState createState() => _SignupConfirmationScreenState();
}

class _SignupConfirmationScreenState extends State<SignupConfirmationScreen> {
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    // Start the countdown to redirect after 2 seconds
    _startRedirectCountdown();
  }

  void _startRedirectCountdown() async {
    if (!_redirecting) {
      setState(() {
        _redirecting = true;
      });
      
      // Wait for 2 seconds before redirecting
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // Navigate to home screen and remove all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.blue[900]!,
              Colors.blue[800]!,
              Colors.blue[400]!,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            // Success icon
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            // Welcome message
            Text(
              'Welcome, ${widget.user.name}!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Success message
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Your account has been created successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Redirecting message
            const Text(
              'Redirecting to home page...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
