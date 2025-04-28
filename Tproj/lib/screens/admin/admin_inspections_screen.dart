import 'package:flutter/material.dart';
import '../../models/inspection_request.dart';
import '../../services/inspection_service.dart';
import '../../widgets/admin_drawer.dart';

class AdminInspectionsScreen extends StatefulWidget {
  const AdminInspectionsScreen({Key? key}) : super(key: key);

  @override
  _AdminInspectionsScreenState createState() => _AdminInspectionsScreenState();
}

class _AdminInspectionsScreenState extends State<AdminInspectionsScreen> {
  final InspectionService _inspectionService = InspectionService();
  
  bool _isLoading = true;
  List<InspectionRequest> _inspectionRequests = [];
  String _filterStatus = 'all'; // 'all', 'pending', 'scheduled', 'inProgress', 'completed', 'reportUploaded', 'cancelled'

  @override
  void initState() {
    super.initState();
    _loadInspectionRequests();
  }

  Future<void> _loadInspectionRequests() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final requests = await _inspectionService.getAllInspectionRequests();
      
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

  List<InspectionRequest> get _filteredRequests {
    return _inspectionRequests.where((request) {
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
        title: const Text('Manage Inspections'),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInspectionRequests,
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
                        value: 'scheduled',
                        child: Text('Scheduled'),
                      ),
                      DropdownMenuItem(
                        value: 'inProgress',
                        child: Text('In Progress'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem(
                        value: 'reportUploaded',
                        child: Text('Report Uploaded'),
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
                        'Showing ${_filteredRequests.length} inspection requests',
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
                          child: Text('No inspection requests found matching the filter'),
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

  Widget _buildRequestCard(InspectionRequest request) {
    // Define colors based on status
    Color statusColor;
    IconData statusIcon;
    
    switch (request.status) {
      case InspectionStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case InspectionStatus.scheduled:
        statusColor = Colors.blue;
        statusIcon = Icons.calendar_today;
        break;
      case InspectionStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.directions_run;
        break;
      case InspectionStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case InspectionStatus.reportUploaded:
        statusColor = Colors.teal;
        statusIcon = Icons.upload_file;
        break;
      case InspectionStatus.cancelled:
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
                if (request.location != null) _buildInfoRow('Location', request.location!),
                if (request.sellerContact != null) _buildInfoRow('Seller Contact', request.sellerContact!),
                _buildInfoRow('Created At', _formatDate(request.createdAt)),
                _buildInfoRow('Updated At', _formatDate(request.updatedAt)),
                _buildInfoRow('Assigned Agent', request.agentId ?? 'Not assigned'),
                
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

  void _showUpdateStatusDialog(InspectionRequest request) {
    InspectionStatus selectedStatus = request.status;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Inspection Status'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Current Status: ${_getStatusText(request.status)}'),
                    const SizedBox(height: 16),
                    const Text('Select New Status:'),
                    RadioListTile<InspectionStatus>(
                      title: const Text('Pending'),
                      value: InspectionStatus.pending,
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<InspectionStatus>(
                      title: const Text('Scheduled'),
                      value: InspectionStatus.scheduled,
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<InspectionStatus>(
                      title: const Text('In Progress'),
                      value: InspectionStatus.inProgress,
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<InspectionStatus>(
                      title: const Text('Completed'),
                      value: InspectionStatus.completed,
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<InspectionStatus>(
                      title: const Text('Report Uploaded'),
                      value: InspectionStatus.reportUploaded,
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<InspectionStatus>(
                      title: const Text('Cancelled'),
                      value: InspectionStatus.cancelled,
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

  Future<void> _updateRequestStatus(InspectionRequest request, InspectionStatus newStatus) async {
    if (request.status == newStatus) {
      return; // No change needed
    }
    
    try {
      await _inspectionService.updateInspectionStatus(request.id, newStatus);
      
      // Reload requests to update the list
      _loadInspectionRequests();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Inspection request status updated to ${_getStatusText(newStatus)}'
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

  void _showAssignAgentDialog({InspectionRequest? request}) {
    // In a real app, you would fetch available agents from your database
    // For this example, we'll use mock data
    final mockAgents = [
      {'id': 'agent1', 'name': 'John Smith', 'type': 'inspector'},
      {'id': 'agent2', 'name': 'Sarah Johnson', 'type': 'inspector'},
      {'id': 'agent3', 'name': 'Mohammed Ali', 'type': 'inspector'},
    ];
    
    String? selectedAgentId;
    InspectionRequest? selectedRequest = request;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Assign Agent to Inspection'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedRequest == null) ...[
                    const Text('Select Inspection Request:'),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Inspection Request',
                      ),
                      items: _inspectionRequests
                          .where((r) => r.status == InspectionStatus.pending)
                          .map((r) => DropdownMenuItem(
                                value: r.id,
                                child: Text('${r.itemName} (${r.id.substring(0, min(8, r.id.length))}...)'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRequest = _inspectionRequests.firstWhere((r) => r.id == value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (selectedRequest != null) ...[
                    Text('Assigning agent to: ${selectedRequest!.itemName}'),
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
                          _assignAgentToRequest(selectedRequest!, selectedAgentId!);
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

  Future<void> _assignAgentToRequest(InspectionRequest request, String agentId) async {
    try {
      await _inspectionService.assignAgentToInspection(request.id, agentId);
      
      // Reload requests to update the list
      _loadInspectionRequests();
      
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
  
  // Helper method to convert InspectionStatus enum to string for filtering
  String _getStatusString(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.pending:
        return 'pending';
      case InspectionStatus.scheduled:
        return 'scheduled';
      case InspectionStatus.inProgress:
        return 'inProgress';
      case InspectionStatus.completed:
        return 'completed';
      case InspectionStatus.reportUploaded:
        return 'reportUploaded';
      case InspectionStatus.cancelled:
        return 'cancelled';
      default:
        return 'unknown';
    }
  }
  
  // Helper method to get display text for InspectionStatus
  String _getStatusText(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.pending:
        return 'PENDING';
      case InspectionStatus.scheduled:
        return 'SCHEDULED';
      case InspectionStatus.inProgress:
        return 'IN PROGRESS';
      case InspectionStatus.completed:
        return 'COMPLETED';
      case InspectionStatus.reportUploaded:
        return 'REPORT UPLOADED';
      case InspectionStatus.cancelled:
        return 'CANCELLED';
      default:
        return 'UNKNOWN';
    }
  }
  
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
