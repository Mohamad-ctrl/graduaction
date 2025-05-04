import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../models/delivery_request.dart';
import '../../services/delivery_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';

class DeliveriesRequestScreen extends StatefulWidget {
  const DeliveriesRequestScreen({Key? key}) : super(key: key);

  @override
  State<DeliveriesRequestScreen> createState() => _DeliveriesRequestScreenState();
}

class _DeliveriesRequestScreenState extends State<DeliveriesRequestScreen> {
  final _deliveryService = DeliveryService();
  final _auth = fb_auth.FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final _itemNameCtrl        = TextEditingController();
  final _itemDescCtrl        = TextEditingController();
  final _pickupCtrl          = TextEditingController();
  final _deliveryCtrl        = TextEditingController();
  final _priceCtrl           = TextEditingController();

  bool _isLoading = true;
  List<DeliveryRequest> _deliveries = [];

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Not logged-in');
      final list = await _deliveryService.getUserDeliveries(uid);   // :contentReference[oaicite:0]{index=0}:contentReference[oaicite:1]{index=1}
      if (mounted) setState(() { _deliveries = list; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  /*────────────────────────  UI  ────────────────────────*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Delivery Requests'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDeliveries,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ───── New request button
                    ElevatedButton.icon(
                      onPressed: () => _showNewRequestSheet(context),
                      icon: const Icon(Icons.add),
                      label: const Text('New Delivery Request'),
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

                    // ───── List
                    if (_deliveries.isEmpty)
                      const Center(
                        child: Text('No delivery requests yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      )
                    else
                      ..._deliveries
                          .map((d) => _buildCard(context, d))
                          .toList(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildCard(BuildContext ctx, DeliveryRequest d) {
    final statusColor = _getStatusColor(d.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        onTap: () => Navigator.pushNamed(ctx, '/delivery/detail', arguments: d.id),
        title: Text(d.itemName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('Est. delivery: ${_format(d.estimatedDeliveryDate)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor[300]!),
          ),
          child: Text(_statusText(d.status),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor[700])),
        ),
      ),
    );
  }

  /*────────────────────  Bottom-sheet form  ────────────────────*/

  void _showNewRequestSheet(BuildContext ctx) {
    _itemNameCtrl.clear();
    _itemDescCtrl.clear();
    _pickupCtrl.clear();
    _deliveryCtrl.clear();
    _priceCtrl.clear();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('New Delivery Request',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                _buildText(_itemNameCtrl, 'Item name'),
                const SizedBox(height: 12),
                _buildText(_itemDescCtrl, 'Item description', maxLines: 3),
                const SizedBox(height: 12),
                _buildText(_pickupCtrl, 'Pickup location'),
                const SizedBox(height: 12),
                _buildText(_deliveryCtrl, 'Delivery location'),
                const SizedBox(height: 12),
                _buildText(_priceCtrl, 'Proposed price (AED)',
                    keyboard: TextInputType.number),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitRequest,
                    child: const Text('SUBMIT REQUEST'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildText(TextEditingController c, String label,
      {int maxLines = 1, TextInputType? keyboard}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context); // close sheet
    final uid = _auth.currentUser!.uid;

    final ok = await _deliveryService.createDeliveryRequest(
      userId: uid,
      itemName: _itemNameCtrl.text.trim(),
      itemDescription: _itemDescCtrl.text.trim(),
      pickupLocation: _pickupCtrl.text.trim(),
      deliveryLocation: _deliveryCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 7)),
    );                                                                       // :contentReference[oaicite:2]{index=2}:contentReference[oaicite:3]{index=3}

    if (ok != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery request submitted')),
      );
      _loadDeliveries();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed – try again')),
      );
    }
  }

  /*────────────────────  helpers  ────────────────────*/

  String _format(DateTime d) => '${d.day}/${d.month}/${d.year}';

  MaterialColor _getStatusColor(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.pending:           return Colors.orange;
      case DeliveryStatus.itemPickedUp:      return Colors.blue;
      case DeliveryStatus.shipped:           return Colors.indigo;
      case DeliveryStatus.outForDelivery:    return Colors.purple;
      case DeliveryStatus.delivered:         return Colors.green;
      case DeliveryStatus.inProgress:        return Colors.blue;
      case DeliveryStatus.completed:         return Colors.green;
      case DeliveryStatus.cancelled:         return Colors.red;
    }
  }

  String _statusText(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.pending:           return 'Pending';
      case DeliveryStatus.itemPickedUp:      return 'Picked up';
      case DeliveryStatus.shipped:           return 'Shipped';
      case DeliveryStatus.outForDelivery:    return 'Out for delivery';
      case DeliveryStatus.delivered:         return 'Delivered';
      case DeliveryStatus.inProgress:        return 'In progress';
      case DeliveryStatus.completed:         return 'Completed';
      case DeliveryStatus.cancelled:         return 'Cancelled';
    }
  }

  @override
  void dispose() {
    _itemNameCtrl.dispose();
    _itemDescCtrl.dispose();
    _pickupCtrl.dispose();
    _deliveryCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }
}
