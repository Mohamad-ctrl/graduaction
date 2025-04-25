import 'package:flutter/material.dart';
import '../../models/payment_method.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_app_bar.dart';

class PaymentMethodFormScreen extends StatefulWidget {
  final PaymentMethod? initialPaymentMethod;
  final bool isEditing;

  const PaymentMethodFormScreen({
    Key? key,
    this.initialPaymentMethod,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _PaymentMethodFormScreenState createState() => _PaymentMethodFormScreenState();
}

class _PaymentMethodFormScreenState extends State<PaymentMethodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  
  bool _isLoading = false;
  
  late TextEditingController _cardholderNameController;
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryDateController;
  late TextEditingController _cvvController;
  String _cardType = 'visa';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data if editing
    _cardholderNameController = TextEditingController(text: widget.initialPaymentMethod?.cardholderName ?? '');
    _cardNumberController = TextEditingController(text: widget.initialPaymentMethod?.cardNumber ?? '');
    _expiryDateController = TextEditingController(text: widget.initialPaymentMethod?.expiryDate ?? '');
    _cvvController = TextEditingController(text: widget.initialPaymentMethod?.cvv ?? '');
    _cardType = widget.initialPaymentMethod?.cardType ?? 'visa';
    _isDefault = widget.initialPaymentMethod?.isDefault ?? false;
  }

  @override
  void dispose() {
    _cardholderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _savePaymentMethod() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final paymentMethod = PaymentMethod(
          id: widget.initialPaymentMethod?.id ?? '',
          cardholderName: _cardholderNameController.text,
          cardNumber: _cardNumberController.text,
          expiryDate: _expiryDateController.text,
          cvv: _cvvController.text,
          cardType: _cardType,
          isDefault: _isDefault,
        );
        
        if (widget.isEditing && widget.initialPaymentMethod != null) {
          await _userService.updatePaymentMethod(paymentMethod);
          if (_isDefault) {
            await _userService.setDefaultPaymentMethod(paymentMethod.id);
          }
        } else {
          final newPaymentMethod = await _userService.addPaymentMethod(paymentMethod);
          if (_isDefault) {
            await _userService.setDefaultPaymentMethod(newPaymentMethod.id);
          }
        }
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Show confirmation dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(widget.isEditing ? 'Payment Method Updated' : 'Payment Method Added'),
              content: Text(
                widget.isEditing
                    ? 'Your payment method has been successfully updated.'
                    : 'Your payment method has been successfully added.'
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, true); // Return to previous screen with success result
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving payment method: ${e.toString()}')),
          );
        }
      }
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your card number';
    }
    
    // Remove spaces and dashes
    final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if it's a valid card number (simple validation)
    if (!RegExp(r'^[0-9]{13,19}$').hasMatch(cleanedValue)) {
      return 'Please enter a valid card number';
    }
    
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the expiry date';
    }
    
    // Check format (MM/YY)
    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(value)) {
      return 'Please enter a valid expiry date (MM/YY)';
    }
    
    // Check if the card is not expired
    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }
    
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the CVV';
    }
    
    // Check if it's a valid CVV (3-4 digits)
    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value)) {
      return 'Please enter a valid CVV';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.isEditing ? 'Edit Payment Method' : 'Add Payment Method',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card type selection
                    const Text(
                      'Card Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCardTypeOption('visa', 'Visa'),
                        const SizedBox(width: 16),
                        _buildCardTypeOption('mastercard', 'MasterCard'),
                        const SizedBox(width: 16),
                        _buildCardTypeOption('amex', 'American Express'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Cardholder name field
                    TextFormField(
                      controller: _cardholderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Cardholder Name',
                        hintText: 'Enter the name on your card',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the cardholder name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Card number field
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                        border: const OutlineInputBorder(),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            'assets/images/${_cardType}_icon.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                _cardType == 'visa'
                                    ? Icons.credit_card
                                    : _cardType == 'mastercard'
                                        ? Icons.credit_card
                                        : Icons.credit_card,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateCardNumber,
                      onChanged: (value) {
                        // Format card number with spaces
                        final cleanedValue = value.replaceAll(RegExp(r'\s'), '');
                        if (cleanedValue.length > 16) return;
                        
                        String formattedValue = '';
                        for (int i = 0; i < cleanedValue.length; i++) {
                          if (i > 0 && i % 4 == 0) {
                            formattedValue += ' ';
                          }
                          formattedValue += cleanedValue[i];
                        }
                        
                        if (formattedValue != value) {
                          _cardNumberController.value = TextEditingValue(
                            text: formattedValue,
                            selection: TextSelection.collapsed(offset: formattedValue.length),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Expiry date and CVV fields in a row
                    Row(
                      children: [
                        // Expiry date field
                        Expanded(
                          child: TextFormField(
                            controller: _expiryDateController,
                            decoration: const InputDecoration(
                              labelText: 'Expiry Date',
                              hintText: 'MM/YY',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: _validateExpiryDate,
                            onChanged: (value) {
                              // Format expiry date (MM/YY)
                              final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');
                              if (cleanedValue.length > 4) return;
                              
                              String formattedValue = '';
                              for (int i = 0; i < cleanedValue.length; i++) {
                                if (i == 2 && cleanedValue.length > 2) {
                                  formattedValue += '/';
                                }
                                formattedValue += cleanedValue[i];
                              }
                              
                              if (formattedValue != value) {
                                _expiryDateController.value = TextEditingValue(
                                  text: formattedValue,
                                  selection: TextSelection.collapsed(offset: formattedValue.length),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // CVV field
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            validator: _validateCVV,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Default payment method checkbox
                    CheckboxListTile(
                      title: const Text('Set as default payment method'),
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 24),
                    
                    // Save button
                    ElevatedButton(
                      onPressed: _savePaymentMethod,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.isEditing ? 'Update Payment Method' : 'Save Payment Method',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCardTypeOption(String type, String label) {
    final isSelected = _cardType == type;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _cardType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.indigo[900]! : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.indigo[50] : Colors.white,
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/images/${type}_icon.png',
                width: 40,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.credit_card,
                    size: 30,
                    color: isSelected ? Colors.indigo[900] : Colors.grey,
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.indigo[900] : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
