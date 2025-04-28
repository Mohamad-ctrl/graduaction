import 'package:flutter/material.dart';
import '../../models/delivery_request.dart';
import '../../services/delivery_service.dart';
import '../../widgets/admin_drawer.dart';

class AdminDeliveriesScreen extends StatefulWidget {
  const AdminDeliveriesScreen({Key? key}) : super(key: key);

  @override
  _AdminDeliveriesScreenState createState() => _AdminDeliveriesScreenState();
}

class _AdminDeliveriesScreenState extends State<AdminDeliveriesScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  
  bool _isLoading = true;
  List<DeliveryRequest> _deliveryRequests = [];
  String _filterStatus = 'all'; // 'all', 'pending', 'itemPickedUp', 'shipped', 'outForDelivery', 'delivered', 'cancelled'

  @override
  void initState() {
    super.initState();
    _loadDeliveryRequests();
  }

  Future<void> _loadDeliveryRequests() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final requests = await _deliveryService.getAllDeliveryRequests();
      
      if (mounted) {
        setState(() {
          _deliveryRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading delivery requests: ${e.toString()}')),
        );
      }
    }
  }

  List<DeliveryRequest> get _filteredRequests {
    return _deliveryRequests.where((request) {
      // Filter by status
      if (_filterStatus != 'all' && _getStatusString(request.status) != _filterStatus) {
        return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Deliveries'),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeliveryRequests,
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter options
                Container(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status Filter',
                      border: OutlineInputBorder(),
                    ),
                    value: _filterStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('All Statuses'),
                      ),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'itemPickedUp',
                        child: Text('Item Picked Up'),
                      ),
                      DropdownMenuItem(
                        value: 'shipped',
                        child: Text('Shipped'),
                      ),
                      DropdownMenuItem(
                        value: 'outForDelivery',
                        child: Text('Out for Delivery'),
                      ),
                      DropdownMenuItem(
                        value: 'delivered',
                        child: Text('Delivered'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value!;
                      });
                    },
                  ),
                ),
                
                // Request count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Showing ${_filteredRequests.length} delivery requests',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          _showAssignAgentDialog();
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Assign Agent'),
                      ),
                    ],
                  ),
                ),
                
                // Request list
                Expanded(
                  child: _filteredRequests.isEmpty
                      ? const Center(
                          child: Text('No delivery requests found matching the filter'),
                        )
                      : ListView.builder(
                          itemCount: _filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = _filteredRequests[index];
                            return _buildRequestCard(request);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildRequestCard(DeliveryRequest request) {
    // Define colors based on status
    Color statusColor;
    IconData statusIcon;
    
    switch (request.status) {
      case DeliveryStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case DeliveryStatus.itemPickedUp:
        statusColor = Colors.blue;
        statusIcon = Icons.directions_run;
        break;
      case DeliveryStatus.shipped:
        statusColor = Colors.indigo;
        statusIcon = Icons.local_shipping;
        break;
      case DeliveryStatus.outForDelivery:
        statusColor = Colors.purple;
        statusIcon = Icons.directions_bike;
        break;
      case DeliveryStatus.delivered:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case DeliveryStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      // Handle potentially remaining old statuses if needed, or default
      case DeliveryStatus.inProgress:
      case DeliveryStatus.completed:
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            statusIcon,
            color: statusColor,
          ),
        ),
        title: Text(
          request.itemName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request ID: ${request.id.substring(0, min(8, request.id.length))}...'),
            Text(
              'Status: ${_getStatusText(request.status)}',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            _showUpdateStatusDialog(request);
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Item Description', request.itemDescription),
                _buildInfoRow('Pickup Location', request.pickupLocation),
                _buildInfoRow('Delivery Location', request.deliveryLocation),
                _buildInfoRow('Created At', _formatDate(request.createdAt)),
                _buildInfoRow('Updated At', _formatDate(request.updatedAt)),
                _buildInfoRow('Assigned Agent', request.deliveryAgentId ?? 'Not assigned'),
                
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _showUpdateStatusDialog(request);
                      },
                      icon: const Icon(Icons.update),
                      label: const Text('Update Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAssignAgentDialog(request: request);
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Assign Agent'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        onExpansionChanged: (isExpanded) {
          // You can add analytics or other logic here
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showUpdateStatusDialog(DeliveryRequest request) {
    String selectedStatus = _getStatusString(request.status);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Delivery Status'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Current Status: ${_getStatusText(request.status)}'),
                    const SizedBox(height: 16),
                    const Text('Select New Status:'),
                    RadioListTile<String>(
                      title: const Text('Pending'),
                      value: 'pending',
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Item Picked Up'),
                      value: 'itemPickedUp',
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Shipped'),
                      value: 'shipped',
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Out for Delivery'),
                      value: 'outForDelivery',
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Delivered'),
                      value: 'delivered',
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Cancelled'),
                      value: 'cancelled',
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateRequestStatus(request, selectedStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  String _getStatusString(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'pending';
      case DeliveryStatus.itemPickedUp:
        return 'itemPickedUp';
      case DeliveryStatus.shipped:
        return 'shipped';
      case DeliveryStatus.outForDelivery:
        return 'outForDelivery';
      case DeliveryStatus.delivered:
        return 'delivered';
      case DeliveryStatus.cancelled:
        return 'cancelled';
      // Handle potentially remaining old statuses if needed, or default
      case DeliveryStatus.inProgress:
      case DeliveryStatus.completed:
      default:
        return 'unknown'; // Added default return
    }
  }

  String _getStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'PENDING';
      case DeliveryStatus.itemPickedUp:
        return 'ITEM PICKED UP';
      case DeliveryStatus.shipped:
        return 'SHIPPED';
      case DeliveryStatus.outForDelivery:
        return 'OUT FOR DELIVERY';
      case DeliveryStatus.delivered:
        return 'DELIVERED';
      case DeliveryStatus.cancelled:
        return 'CANCELLED';
      // Handle potentially remaining old statuses if needed, or default
      case DeliveryStatus.inProgress:
      case DeliveryStatus.completed:
      default:
        return 'UNKNOWN'; // Added default return
    }
  }

  Future<void> _updateRequestStatus(DeliveryRequest request, String newStatusString) async {
    final newStatus = _getDeliveryStatusFromString(newStatusString);
    if (request.status == newStatus) {
      return; // No change needed
    }
    
    try {
      await _deliveryService.updateDeliveryStatus(request.id, newStatus);
      
      // Reload requests to update the list
      _loadDeliveryRequests();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Delivery request status updated to ${_getStatusText(newStatus)}'
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  DeliveryStatus _getDeliveryStatusFromString(String statusString) {
    switch (statusString) {
      case 'pending':
        return DeliveryStatus.pending;
      case 'itemPickedUp':
        return DeliveryStatus.itemPickedUp;
      case 'shipped':
        return DeliveryStatus.shipped;
      case 'outForDelivery':
        return DeliveryStatus.outForDelivery;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'cancelled':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.pending; // Default to pending if string is unknown
    }
  }

  void _showAssignAgentDialog({DeliveryRequest? request}) {
    // TODO: Implement agent assignment logic (requires AgentService and agent list)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agent assignment functionality not yet implemented')),
    );
  }
  
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
