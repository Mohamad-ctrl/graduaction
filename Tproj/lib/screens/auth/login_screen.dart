// File: lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';

import '../../constants/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/navigation.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_app_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading       = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signIn(
        email   : _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (user != null && mounted) {
        NavigationUtils.navigateAndRemoveUntil(context, AppRoutes.home);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Login', showBackButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ───── Logo ─────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color       : Colors.white,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow   : [BoxShadow(
                    color     : Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset    : const Offset(0, 5),
                  )],
                ),
                child: const Icon(Icons.local_shipping,
                    size: 70, color: Colors.blue),
              ),
              const SizedBox(height: 24),

              // ───── Email ─────
              TextFormField(
                controller : _emailController,
                decoration : InputDecoration(
                  labelText  : 'Email',
                  prefixIcon : const Icon(Icons.email),
                  border     : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator   : (v) => (v == null || v.isEmpty)
                    ? 'Please enter your email'
                    : (!Validators.isValidEmail(v))
                        ? 'Please enter a valid email'
                        : null,
              ),
              const SizedBox(height: 16),

              // ───── Password ─────
              TextFormField(
                controller : _passwordController,
                obscureText: _obscurePassword,
                decoration : InputDecoration(
                  labelText : 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please enter your password' : null,
              ),
              const SizedBox(height: 8),

              // ───── Forgot Password ─────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.forgotPassword),
                  child: const Text('Forgot Password?'),
                ),
              ),

              // ───── Login button ─────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape  : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'LOG IN',
                          style: TextStyle(
                            fontSize  : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),

              // ───── Sign-up link ─────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.signup),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
