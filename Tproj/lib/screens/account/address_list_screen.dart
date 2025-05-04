import 'package:flutter/material.dart';

import '../../models/address.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_app_bar.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final UserService _userService = UserService();

  bool _isLoading = true;
  List<Address> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      final list = await _userService.getUserAddresses();
      if (!mounted) return;
      setState(() {
        _addresses = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading addresses: $e')),
      );
    }
  }

  /* ─────────────── actions ─────────────── */
  Future<void> _deleteAddress(String id) async {
    await _userService.deleteAddress(id);
    _loadAddresses();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address deleted')),
    );
  }

  Future<void> _setDefaultAddress(String id) async {
    await _userService.setDefaultAddress(id);
    _loadAddresses();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default address updated')),
    );
  }

  /* ─────────────────────────────────────── */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Addresses',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : _buildAddressList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo[900],
        onPressed: () async {
          final added = await Navigator.pushNamed(context, '/address/add');
          if (added == true) _loadAddresses();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /* ─────────────── UI helpers ─────────────── */

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No Addresses Found',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text('Add your first address to get started',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                final added =
                    await Navigator.pushNamed(context, '/address/add');
                if (added == true) _loadAddresses();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Address'),
            ),
          ],
        ),
      );

  Widget _buildAddressList() => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        itemBuilder: (_, i) {
          final a = _addresses[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        a.isDefault ? Colors.indigo[100] : Colors.grey[200],
                    child: Icon(Icons.location_on,
                        color:
                            a.isDefault ? Colors.indigo[900] : Colors.grey[700]),
                  ),
                  title: Row(
                    children: [
                      Text(a.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      if (a.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Default',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                      '${a.street}, ${a.city}, ${a.state}, ${a.country}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showAddressOptions(a),
                  ),
                  onTap: () => _showAddressDetails(a),
                ),
                if (!a.isDefault)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _setDefaultAddress(a.id),
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

  /* ─────────────── bottom-sheet helpers ─────────────── */

  void _showAddressOptions(Address address) => showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () async {
                  Navigator.pop(context);
                  final updated = await Navigator.pushNamed(
                    context,
                    '/address/edit',
                    arguments: address,
                  );
                  if (updated == true) _loadAddresses();
                },
              ),
              if (!address.isDefault)
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('Set as Default'),
                  onTap: () {
                    Navigator.pop(context);
                    _setDefaultAddress(address.id);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAddress(address.id);
                },
              ),
            ],
          ),
        ),
      );

  void _showAddressDetails(Address a) => showModalBottomSheet(
        context: context,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        a.isDefault ? Colors.indigo[100] : Colors.grey[200],
                    child: Icon(Icons.location_on,
                        color:
                            a.isDefault ? Colors.indigo[900] : Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(a.name,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            if (a.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.indigo[900],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('Default',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${a.street}, ${a.city}, ${a.state}, ${a.country}',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDetailRow('Street', a.street),
              _buildDetailRow('City', a.city),
              _buildDetailRow('State / Emirate', a.state),
              _buildDetailRow('ZIP / Postal Code', a.zip),
              _buildDetailRow('Country', a.country),
              _buildDetailRow('Phone', a.phone ?? '-'),
            ],
          ),
        ),
      );

  Widget _buildDetailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Text(value.isEmpty ? 'Not provided' : value)),
          ],
        ),
      );
}
