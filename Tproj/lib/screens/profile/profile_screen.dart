import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../constants/app_routes.dart';
import '../../models/address.dart';
import '../../models/payment_method.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final _auth = fb.FirebaseAuth.instance;

  bool _isLoading = true;
  List<Address> _addresses = [];
  List<PaymentMethod> _paymentMethods = [];
  bool _isAdmin = false;                  // ← NEW
  @override
  void initState() {
    super.initState();
    _checkAdmin();                        // ← NEW    
    _loadUserData();
  }
  Future<void> _checkAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final isAdm = await _userService.isUserAdmin(uid);
    if (mounted) setState(() => _isAdmin = isAdm);
    }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final addresses       = await _userService.getUserAddresses();
      final paymentMethods  = await _userService.getUserPaymentMethods();
      if (mounted) setState(() {
        _addresses       = addresses;
        _paymentMethods  = paymentMethods;
        _isLoading       = false;
      });
    } catch (e) {
      if (mounted) {
        _isLoading = false;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Profile', showBackButton: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildAddressSection(),
                    const SizedBox(height: 24),
                    _buildPaymentMethodsSection(),
                    const SizedBox(height: 24),
                    _buildAccountSettingsSection(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  // ───────────────── profile header ─────────────────
  Widget _buildProfileHeader() {
    final user = _auth.currentUser;
    return Row(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.indigo[100],
          child: Icon(Icons.person, size: 40, color: Colors.indigo[900]),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user?.displayName ?? 'User',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '-', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  // ───────────────── address list ─────────────────
  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Addresses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.addAddress)
                      .then((value) => _loadUserData()),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _addresses.isEmpty
            ? const EmptyStateWidget(
              message: 'No addresses yet',
              icon: Icons.location_off,
            )
            : Column(
                children: _addresses
                    .map((a) => ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(a.name),
                          subtitle: Text(
                              '${a.street}, ${a.city}, ${a.country}'),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  // ───────────────── payment methods ─────────────────
  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payment Methods',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addPaymentMethod)
                  .then((value) => _loadUserData()),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _paymentMethods.isEmpty
            ? const EmptyStateWidget(
              message: 'No payment methods yet',
              icon: Icons.credit_card_off,
            )
            : Column(
                children: _paymentMethods
                    .map((p) => ListTile(
                          leading: const Icon(Icons.credit_card),
                          title: Text('${p.cardType} •••• ${p.cardNumber.substring(p.cardNumber.length - 4)}'),
                          subtitle: Text('Expires ${p.expiryDate}'),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  // ───────────────── account settings (with new button) ─────────────────
  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Account Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.person, color: Colors.indigo[900]),
                title: const Text('Account Center'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/account'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.list_alt, color: Colors.indigo[900]),
                title: const Text('All My Requests'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
              ),
              const Divider(height: 1),
              if (_isAdmin) ...[
                ListTile(
                  leading : Icon(Icons.dashboard, color: Colors.indigo[900]),
                  title   : const Text('Admin Dashboard'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap   : () =>
                      Navigator.pushNamed(context, AppRoutes.adminDashboard),
                ),
                const Divider(height: 1),
              ],
              ListTile(
                leading: Icon(Icons.lock, color: Colors.indigo[900]),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/account/password'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red[700]),
                title: Text('Logout', style: TextStyle(color: Colors.red[700])),
                onTap: _showLogoutConfirmation,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────── logout helper ─────────────────
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              fb.FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (_) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
