// File: lib/screens/admin/admin_login_screen.dart
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  // Firebase services (still available for real admins)
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // --- 1) Hard-coded “admin / admin” shortcut --------------
    if (_emailController.text.trim() == 'admin' &&
        _passwordController.text == 'admin') {
      Navigator.of(context).pushReplacementNamed('/admin/dashboard');
      return;
    }

    // --- 2) Fallback to Firebase / Firestore check ----------
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (user != null) {
        final isAdmin = await _userService.isUserAdmin(user.id);

        if (isAdmin) {
          Navigator.of(context).pushReplacementNamed('/admin/dashboard');
        } else {
          _errorMessage = 'You do not have admin privileges.';
          await _authService.signOut();
        }
      } else {
        _errorMessage = 'Invalid email or password.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // relaxed validator so “admin” (not an email) is accepted
  String? _emailValidator(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your email / username';
    if (v != 'admin' &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
      return 'Please enter a valid email';
    }
    return null;
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
              Colors.indigo[900]!,
              Colors.indigo[800]!,
              Colors.indigo[400]!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Admin Login',
                style: TextStyle(color: Colors.white, fontSize: 40),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(27, 95, 225, .3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // ───────── email / username ─────────
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border:
                                      Border(bottom: BorderSide(color: Colors.grey[200]!)),
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    hintText: 'Admin Email or "admin"',
                                    border: InputBorder.none,
                                  ),
                                  validator: _emailValidator,
                                ),
                              ),
                              // ───────── password ─────────
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Password',
                                    border: InputBorder.none,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Please enter your password' : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[900],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  onPressed: _login,
                                  child: const Text(
                                    'Login as Admin',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 30),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushReplacementNamed('/login'),
                          child: const Text(
                            'Return to User Login',
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
