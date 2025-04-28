import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/address.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_app_bar.dart';

class AddressFormScreen extends StatefulWidget {
  final Address? initialAddress;
  final bool isEditing;

  const AddressFormScreen({
    Key? key,
    this.initialAddress,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _AddressFormScreenState createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  
  bool _isLoading = false;
  
  late TextEditingController _nameController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _phoneController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data if editing
    _nameController = TextEditingController(text: widget.initialAddress?.name ?? '');
    _addressLine1Controller = TextEditingController(text: widget.initialAddress?.addressLine1 ?? '');
    _cityController = TextEditingController(text: widget.initialAddress?.city ?? '');
    _stateController = TextEditingController(text: widget.initialAddress?.state ?? '');
    _postalCodeController = TextEditingController(text: widget.initialAddress?.postalCode ?? '');
    _countryController = TextEditingController(text: widget.initialAddress?.country ?? 'UAE');
    _phoneController = TextEditingController(text: widget.initialAddress?.phone ?? '');
    _isDefault = widget.initialAddress?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // TODO: Fetch current userId from UserService
        final userId = 'current_user_id'; // Replace with actual userId fetching logic
        
        final address = Address(
          id: widget.initialAddress?.id ?? '',
          userId: userId,
          name: _nameController.text,
          addressLine1: _addressLine1Controller.text,
          addressLine2: '', // Add logic for addressLine2 if needed
          city: _cityController.text,
          state: _stateController.text,
          country: _countryController.text,
          postalCode: _postalCodeController.text,
          phone: _phoneController.text,
          isDefault: _isDefault,
          createdAt: widget.initialAddress?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        if (widget.isEditing && widget.initialAddress != null) {
          // TODO: Fix once user_service.dart is provided
          await _userService.updateAddress(address.id, address.toMap());
          if (_isDefault) {
            await _userService.setDefaultAddress(address.id);
          }
        } else {
          final newAddress = await _userService.addAddress(address.toMap());
          if (_isDefault) {
            await _userService.setDefaultAddress(newAddress.id);
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
              title: Text(widget.isEditing ? 'Address Updated' : 'Address Added'),
              content: Text(
                widget.isEditing
                    ? 'Your address has been successfully updated.'
                    : 'Your address has been successfully added.'
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
            SnackBar(content: Text('Error saving address: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.isEditing ? 'Edit Address' : 'Add New Address',
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
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Address Name',
                        hintText: 'e.g., Home, Work, etc.',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an address name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Address Line 1 field
                    TextFormField(
                      controller: _addressLine1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address Line 1',
                        hintText: 'Enter your street address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your street address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // City field
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        hintText: 'Enter your city',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // State field
                    TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State/Emirate',
                        hintText: 'Enter your state or emirate',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your state or emirate';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Postal Code field
                    TextFormField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Postal Code',
                        hintText: 'Enter your postal code',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Country field
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        hintText: 'Enter your country',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your country';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        border: OutlineInputBorder(),
                        prefixText: '+971 ',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Default address checkbox
                    CheckboxListTile(
                      title: const Text('Set as default address'),
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
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.isEditing ? 'Update Address' : 'Save Address',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}