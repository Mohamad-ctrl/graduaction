import 'package:flutter/material.dart';
import '../../models/payment_method.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_app_bar.dart';

class PaymentMethodListScreen extends StatefulWidget {
  const PaymentMethodListScreen({Key? key}) : super(key: key);

  @override
  _PaymentMethodListScreenState createState() => _PaymentMethodListScreenState();
}

class _PaymentMethodListScreenState extends State<PaymentMethodListScreen> {
  final UserService _userService = UserService();
  
  bool _isLoading = true;
  List<PaymentMethod> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final paymentMethods = await _userService.getUserPaymentMethods();
      
      if (mounted) {
        setState(() {
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
          SnackBar(content: Text('Error loading payment methods: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deletePaymentMethod(String paymentMethodId) async {
    try {
      await _userService.deletePaymentMethod(paymentMethodId);
      
      // Reload payment methods
      _loadPaymentMethods();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment method deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting payment method: ${e.toString()}')),
      );
    }
  }

  Future<void> _setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      await _userService.setDefaultPaymentMethod(paymentMethodId);
      
      // Reload payment methods
      _loadPaymentMethods();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default payment method updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating default payment method: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Payment Methods',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paymentMethods.isEmpty
              ? _buildEmptyState()
              : _buildPaymentMethodList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/payment/add');
          if (result == true) {
            _loadPaymentMethods();
          }
        },
        backgroundColor: Colors.indigo[900],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment Methods Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first payment method to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/payment/add');
              if (result == true) {
                _loadPaymentMethods();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Payment Method'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[900],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _paymentMethods.length,
      itemBuilder: (context, index) {
        final paymentMethod = _paymentMethods[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              ListTile(
                leading: _buildCardTypeIcon(paymentMethod.cardType, paymentMethod.isDefault),
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatCardNumber(paymentMethod.cardNumber),
                    ),
                    Text(
                      'Expires: ${paymentMethod.expiryDate}',
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showPaymentMethodOptions(paymentMethod);
                  },
                ),
                onTap: () {
                  _showPaymentMethodDetails(paymentMethod);
                },
              ),
              if (!paymentMethod.isDefault)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _setDefaultPaymentMethod(paymentMethod.id);
                        },
                        child: const Text('Set as Default'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardTypeIcon(String cardType, bool isDefault) {
    return CircleAvatar(
      backgroundColor: isDefault
          ? Colors.indigo[100]
          : Colors.grey[200],
      child: Image.asset(
        'assets/images/${cardType}_icon.png',
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.credit_card,
            color: isDefault
                ? Colors.indigo[900]
                : Colors.grey[700],
          );
        },
      ),
    );
  }

  String _getCardTypeLabel(String cardType) {
    switch (cardType) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'MasterCard';
      case 'amex':
        return 'American Express';
      default:
        return 'Credit Card';
    }
  }

  String _formatCardNumber(String cardNumber) {
    // Show only last 4 digits
    if (cardNumber.length >= 4) {
      final lastFour = cardNumber.substring(cardNumber.length - 4);
      return '•••• •••• •••• $lastFour';
    }
    return cardNumber;
  }

  void _showPaymentMethodDetails(PaymentMethod paymentMethod) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCardTypeIcon(paymentMethod.cardType, paymentMethod.isDefault),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _getCardTypeLabel(paymentMethod.cardType),
                              style: const TextStyle(
                                fontSize: 18,
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
                        const SizedBox(height: 4),
                        Text(
                          _formatCardNumber(paymentMethod.cardNumber),
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailRow('Cardholder Name', paymentMethod.cardholderName),
              _buildDetailRow('Card Number', _formatCardNumber(paymentMethod.cardNumber)),
              _buildDetailRow('Expiry Date', paymentMethod.expiryDate),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/payment/edit',
                        arguments: paymentMethod,
                      ).then((result) {
                        if (result == true) {
                          _loadPaymentMethods();
                        }
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (!paymentMethod.isDefault)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _setDefaultPaymentMethod(paymentMethod.id);
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Set as Default'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(paymentMethod);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'Not provided' : value),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodOptions(PaymentMethod paymentMethod) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Payment Method'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/payment/edit',
                    arguments: paymentMethod,
                  ).then((result) {
                    if (result == true) {
                      _loadPaymentMethods();
                    }
                  });
                },
              ),
              if (!paymentMethod.isDefault)
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('Set as Default'),
                  onTap: () {
                    Navigator.pop(context);
                    _setDefaultPaymentMethod(paymentMethod.id);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Payment Method', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(paymentMethod);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(PaymentMethod paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text(
          'Are you sure you want to delete this ${_getCardTypeLabel(paymentMethod.cardType)} card ending in ${paymentMethod.cardNumber.substring(paymentMethod.cardNumber.length - 4)}?'
          '${paymentMethod.isDefault ? ' This is your default payment method.' : ''}'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePaymentMethod(paymentMethod.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
