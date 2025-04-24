import 'package:flutter/material.dart';
import '../models/delivery_request.dart';
import '../services/delivery_service.dart';
import '../widgets/admin_drawer.dart';

class AdminDeliveriesScreen extends StatefulWidget {
  const AdminDeliveriesScreen({Key? key}) : super(key: key);

  @override
  _AdminDeliveriesScreenState createState() => _AdminDeliveriesScreenState();
}

class _AdminDeliveriesScreenState extends State<AdminDeliveriesScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  
  bool _isLoading = true;
  List<DeliveryRequest> _deliveryRequests = [];
  String _filterStatus = 'all'; // 'all', 'pending', 'in_progress', 'completed', 'cancelled'

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
      if (_filterStatus != 'all' && request.status != _filterStatus) {
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
                        value: 'in_progress',
                        child: Text('In Progress'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
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
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.directions_run;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
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
          request.packageName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request ID: ${request.id.substring(0, 8)}...'),
            Text(
              'Status: ${request.status.toUpperCase()}',
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
                _buildInfoRow('Package Description', request.packageDescription),
                _buildInfoRow('Pickup Location', request.pickupLocation),
                _buildInfoRow('Delivery Location', request.deliveryLocation),
                _buildInfoRow('Created At', _formatDate(request.createdAt)),
                _buildInfoRow('Updated At', _formatDate(request.updatedAt)),
                _buildInfoRow('Assigned Agent', request.assignedAgentId ?? 'Not assigned'),
                
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
    String selectedStatus = request.status;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Delivery Status'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Current Status: ${request.status.toUpperCase()}'),
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
                    title: const Text('In Progress'),
                    value: 'in_progress',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Completed'),
                    value: 'completed',
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

  Future<void> _updateRequestStatus(DeliveryRequest request, String newStatus) async {
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
            'Delivery request status updated to ${newStatus.toUpperCase()}'
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

  void _showAssignAgentDialog({DeliveryRequest? request}) {
    // In a real app, you would fetch available agents from your database
    // For this example, we'll use mock data
    final mockAgents = [
      {'id': 'agent4', 'name': 'Ahmed Khan', 'type': 'delivery'},
      {'id': 'agent5', 'name': 'Fatima Al-Zahra', 'type': 'delivery'},
      {'id': 'agent6', 'name': 'Omar Yusuf', 'type': 'delivery'},
    ];
    
    String? selectedAgentId;
    DeliveryRequest? selectedRequest = request;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Assign Agent to Delivery'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedRequest == null) ...[
                    const Text('Select Delivery Request:'),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Delivery Request',
                      ),
                      items: _deliveryRequests
                          .where((r) => r.status == 'pending')
                          .map((r) => DropdownMenuItem(
                                value: r.id,
                                child: Text('${r.packageName} (${r.id.substring(0, 8)}...)'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRequest = _deliveryRequests.firstWhere((r) => r.id == value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (selectedRequest != null) ...[
                    Text('Assigning agent to: ${selectedRequest!.packageName}'),
                    const SizedBox(height: 16),
                  ],
                  
                  const Text('Select Agent:'),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Agent',
                    ),
                    items: mockAgents
                        .map((agent) => DropdownMenuItem(
                              value: agent['id'] as String,
                              child: Text(agent['name'] as String),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAgentId = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedRequest != null && selectedAgentId != null
                      ? () {
                          Navigator.pop(context);
                          _assignAgentToRequest(selectedRequest!.id, selectedAgentId!);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                  ),
                  child: const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _assignAgentToRequest(String requestId, String agentId) async {
    try {
      await _deliveryService.assignAgentToDelivery(requestId, agentId);
      
      // Reload requests to update the list
      _loadDeliveryRequests();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agent assigned successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning agent: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
