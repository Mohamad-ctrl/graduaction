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

    _nameController =
        TextEditingController(text: widget.initialAddress?.name ?? '');
    _addressLine1Controller =
        TextEditingController(text: widget.initialAddress?.addressLine1 ?? '');
    _cityController =
        TextEditingController(text: widget.initialAddress?.city ?? '');
    _stateController =
        TextEditingController(text: widget.initialAddress?.state ?? '');
    _postalCodeController =
        TextEditingController(text: widget.initialAddress?.postalCode ?? '');
    _countryController =
        TextEditingController(text: widget.initialAddress?.country ?? 'UAE');
    _phoneController =
        TextEditingController(text: widget.initialAddress?.phone ?? '');
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // In a real app you’d read the signed-in user ID here.
      final userId = 'current_user_id';

      final address = Address(
        id: widget.initialAddress?.id ?? '',
        userId: userId,
        name: _nameController.text,
        addressLine1: _addressLine1Controller.text,
        addressLine2: '', // extend the form if you need line-2
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
        // ——— update ———
        await _userService.updateAddress(address);
        if (_isDefault) await _userService.setDefaultAddress(address.id);
      } else {
        // ——— add ———
        final newAddress = await _userService.addAddress(address);
        if (_isDefault) await _userService.setDefaultAddress(newAddress.id);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      // success dialog
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(widget.isEditing ? 'Address Updated' : 'Address Added'),
          content: Text(widget.isEditing
              ? 'Your address has been successfully updated.'
              : 'Your address has been successfully added.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context, true); // return success flag
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving address: $e')),
      );
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
                    _buildTextField(
                      controller: _nameController,
                      label: 'Address Name',
                      hint: 'e.g., Home, Work',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressLine1Controller,
                      label: 'Address Line 1',
                      hint: 'Enter your street address',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Enter your city',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _stateController,
                      label: 'State / Emirate',
                      hint: 'Enter your state or emirate',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _postalCodeController,
                      label: 'Postal Code',
                      hint: 'Enter your postal code',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (_) => null, // optional
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _countryController,
                      label: 'Country',
                      hint: 'Enter your country',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your phone',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v ?? false),
                      title: const Text('Set as default address'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 24),
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

  // simple helper to keep build() tidy
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator ??
          (value) =>
              (value == null || value.isEmpty) ? 'Please enter $label' : null,
    );
  }
}
