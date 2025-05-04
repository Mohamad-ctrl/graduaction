import 'package:flutter/material.dart';
import '../../models/user.dart' as app_models;

class SignupConfirmationScreen extends StatefulWidget {
  final app_models.User user;

  const SignupConfirmationScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SignupConfirmationScreenState createState() => _SignupConfirmationScreenState();
}

class _SignupConfirmationScreenState extends State<SignupConfirmationScreen> {
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    _startRedirectCountdown();
  }

  void _startRedirectCountdown() async {
    if (!_redirecting) {
      setState(() {
        _redirecting = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
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
            const Icon(Icons.check_circle_outline, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${widget.user.username}!',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Your account has been created successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Redirecting to home page...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
