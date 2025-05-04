// File: lib/screens/inspections/inspection_request_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../constants/app_routes.dart';
import '../../services/inspection_service.dart';
import '../../models/inspection_request.dart';
import '../../utils/navigation.dart';

class InspectionRequestScreen extends StatefulWidget {
  const InspectionRequestScreen({super.key});

  @override
  State<InspectionRequestScreen> createState() => _InspectionRequestScreenState();
}

class _InspectionRequestScreenState extends State<InspectionRequestScreen> {
  final InspectionService _inspectionService = InspectionService();
  bool _isLoading = false;
  List<InspectionRequest> _inspectionRequests = [];
  
  // Form controllers
  final _itemNameController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _inspectionDateController = TextEditingController();
  final _locationController = TextEditingController();
  final _sellerContactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _loadInspectionRequests();
  }
  
  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _inspectionDateController.dispose();
    _locationController.dispose();
    _sellerContactController.dispose();
    super.dispose();
  }
  
  Future<void> _loadInspectionRequests() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // In a real implementation, this would use the current user's ID
      // For now, we'll use a placeholder user ID
      const userId = 'current_user_id';
      
      // This would normally be a stream subscription
      // For simplicity, we're using a future here
      final requests = await _inspectionService.getUserInspectionRequests(userId).first;
      
      if (mounted) {
        setState(() {
          _inspectionRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inspection requests: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<void> _submitInspectionRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Parse the inspection date
      final inspectionDate = DateTime.parse(_inspectionDateController.text);
      
      // In a real implementation, this would use the current user's ID
      const userId = 'current_user_id';
      
      final request = await _inspectionService.createInspectionRequest(
        userId: userId,
        itemName: _itemNameController.text,
        itemDescription: _itemDescriptionController.text,
        inspectionDate: inspectionDate,
        location: _locationController.text,
        sellerContact: _sellerContactController.text,
      );
      
      if (request != null && mounted) {
        // Close the form
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inspection request submitted successfully')),
        );
        
        // Reload the inspection requests
        _loadInspectionRequests();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit inspection request')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Inspection Requests'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // New Request Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Show new inspection request form
                      _showNewRequestForm(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Inspection Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Inspection Requests List
                  if (_inspectionRequests.isEmpty)
                    const Center(
                      child: Text(
                        'No inspection requests yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  else
                    ..._inspectionRequests.map((request) => Column(
                      children: [
                        _buildRequestCard(
                          context,
                          title: request.itemName,
                          date: request.requestDate.toString().substring(0, 10),
                          icon: _getIconForItem(request.itemName),
                          onTap: () => Navigator.pushNamed(
                            context, 
                            AppRoutes.inspectionDetail,
                            arguments: request.id,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )).toList(),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  void _showNewRequestForm(BuildContext context) {
    // Reset form controllers
    _itemNameController.clear();
    _itemDescriptionController.clear();
    _inspectionDateController.clear();
    _locationController.clear();
    _sellerContactController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Inspection Request',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _itemDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Item Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _inspectionDateController,
                decoration: InputDecoration(
                  labelText: 'Preferred Inspection Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        _inspectionDateController.text = date.toString().substring(0, 10);
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the inspection date';
                  }
                  try {
                    DateTime.parse(value);
                  } catch (e) {
                    return 'Please enter a valid date in YYYY-MM-DD format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sellerContactController,
                decoration: InputDecoration(
                  labelText: 'Seller Contact',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the seller contact';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitInspectionRequest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SUBMIT REQUEST'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForItem(String itemName) {
    final lowerCaseName = itemName.toLowerCase();
    if (lowerCaseName.contains('car') || 
        lowerCaseName.contains('vehicle') || 
        lowerCaseName.contains('auto')) {
      return Icons.directions_car;
    } else if (lowerCaseName.contains('phone') || 
               lowerCaseName.contains('mobile') || 
               lowerCaseName.contains('device')) {
      return Icons.phone_android;
    } else if (lowerCaseName.contains('laptop') || 
               lowerCaseName.contains('computer') || 
               lowerCaseName.contains('pc')) {
      return Icons.laptop;
    } else if (lowerCaseName.contains('furniture') || 
               lowerCaseName.contains('chair') || 
               lowerCaseName.contains('table')) {
      return Icons.chair;
    } else if (lowerCaseName.contains('appliance') || 
               lowerCaseName.contains('kitchen') || 
               lowerCaseName.contains('refrigerator')) {
      return Icons.kitchen;
    } else if (lowerCaseName.contains('jewelry') || 
               lowerCaseName.contains('watch') || 
               lowerCaseName.contains('ring')) {
      return Icons.watch;
    } else if (lowerCaseName.contains('engine') || 
               lowerCaseName.contains('part') || 
               lowerCaseName.contains('mechanical')) {
      return Icons.engineering;
    } else {
      return Icons.inventory_2;
    }
  }

  Widget _buildRequestCard(BuildContext context, {
    required String title,
    required String date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requested on $date',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
