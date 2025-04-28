import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  
  bool _isLoading = true;
  List<Address> _addresses = [];
  List<PaymentMethod> _paymentMethods = [];
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final addresses = await _userService.getUserAddresses();
      final paymentMethods = await _userService.getUserPaymentMethods();
      
      if (mounted) {
        setState(() {
          _addresses = addresses;
          _paymentMethods = paymentMethods;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile data: ${e.toString()}')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Profile',
        showBackButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
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
  
  Widget _buildProfileHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.indigo[100],
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.indigo[900],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                        future: _userService.getCurrentUser(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text('Loading...');
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          final user = snapshot.data;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.username ?? 'User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'email@example.com',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.phoneNumber ?? '+971 XX XXX XXXX',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/account');
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigo[900],
                side: BorderSide(color: Colors.indigo[900]!),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Addresses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/address/list')
                    .then((_) => _loadUserData());
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _addresses.isEmpty
            ? EmptyStateWidget(
                icon: Icons.location_off,
                title: 'No Addresses Found',
                message: 'Add your first address to get started',
                buttonText: 'Add Address',
                onButtonPressed: () {
                  Navigator.pushNamed(context, '/address/add')
                      .then((_) => _loadUserData());
                },
              )
            : Card(
                elevation: 2,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _addresses.length > 2 ? 2 : _addresses.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: address.isDefault
                            ? Colors.indigo[100]
                            : Colors.grey[200],
                        child: Icon(
                          Icons.location_on,
                          color: address.isDefault
                              ? Colors.indigo[900]
                              : Colors.grey[700],
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            address.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo[900],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '${address.addressLine1}, ${address.city}, ${address.state}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/address/edit',
                          arguments: address,
                        ).then((_) => _loadUserData());
                      },
                    );
                  },
                ),
              ),
        if (_addresses.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/address/add')
                    .then((_) => _loadUserData());
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Address'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigo[900],
                side: BorderSide(color: Colors.indigo[900]!),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/payment/list')
                    .then((_) => _loadUserData());
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _paymentMethods.isEmpty
            ? EmptyStateWidget(
                icon: Icons.credit_card_off,
                title: 'No Payment Methods Found',
                message: 'Add your first payment method to get started',
                buttonText: 'Add Payment Method',
                onButtonPressed: () {
                  Navigator.pushNamed(context, '/payment/add')
                      .then((_) => _loadUserData());
                },
              )
            : Card(
                elevation: 2,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _paymentMethods.length > 2 ? 2 : _paymentMethods.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final paymentMethod = _paymentMethods[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: paymentMethod.isDefault
                            ? Colors.indigo[100]
                            : Colors.grey[200],
                        child: Icon(
                          Icons.credit_card,
                          color: paymentMethod.isDefault
                              ? Colors.indigo[900]
                              : Colors.grey[700],
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            _getCardTypeLabel(paymentMethod.cardType),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (paymentMethod.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo[900],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        _formatCardNumber(paymentMethod.cardNumber),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/payment/edit',
                          arguments: paymentMethod,
                        ).then((_) => _loadUserData());
                      },
                    );
                  },
                ),
              ),
        if (_paymentMethods.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/payment/add')
                    .then((_) => _loadUserData());
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Payment Method'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigo[900],
                side: BorderSide(color: Colors.indigo[900]!),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.indigo[900],
                ),
                title: const Text('Account Center'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/account');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Colors.indigo[900],
                ),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/account/password');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.red[700],
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red[700],
                  ),
                ),
                onTap: () {
                  _showLogoutConfirmation();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _logout() async {
    try {
      // Call auth service logout method
      // await _authService.logout();
      
      // Navigate to login screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }
  
  String _getCardTypeLabel(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      case 'discover':
        return 'Discover';
      default:
        return cardType;
    }
  }
  
  String _formatCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;
    
    return '•••• •••• •••• ${cardNumber.substring(cardNumber.length - 4)}';
  }
}
