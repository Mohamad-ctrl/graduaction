import 'package:flutter/material.dart';
import '../services/inspection_service.dart';
import '../services/delivery_service.dart';
import '../models/inspection_request.dart';
import '../models/delivery_request.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InspectionService _inspectionService = InspectionService();
  final DeliveryService _deliveryService = DeliveryService();
  
  bool _isLoading = true;
  List<InspectionRequest> _inspections = [];
  List<DeliveryRequest> _deliveries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final inspections = await _inspectionService.getUserInspectionRequests();
      final deliveries = await _deliveryService.getUserDeliveryRequests();
      
      if (mounted) {
        setState(() {
          _inspections = inspections;
          _deliveries = deliveries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Check & Deliver',
        showBackButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildInspectionSection(),
                    const SizedBox(height: 24),
                    _buildDeliverySection(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.indigo[900]!, Colors.indigo[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Check & Deliver',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your trusted partner for remote item inspection and secure delivery services.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatusCard(
                  'Inspections',
                  _inspections.length.toString(),
                  Colors.blue[100]!,
                  Colors.blue[900]!,
                ),
                const SizedBox(width: 12),
                _buildStatusCard(
                  'Deliveries',
                  _deliveries.length.toString(),
                  Colors.green[100]!,
                  Colors.green[900]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildActionButton(
              'Request\nInspection',
              Icons.search,
              Colors.blue,
              () {
                Navigator.pushNamed(context, '/inspection/request')
                    .then((_) => _loadData());
              },
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              'Track\nOrders',
              Icons.local_shipping,
              Colors.green,
              () {
                Navigator.pushNamed(context, '/orders');
              },
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              'My\nProfile',
              Icons.person,
              Colors.purple,
              () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, MaterialColor color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color[100]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color[700],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Inspections',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/orders');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _inspections.isEmpty
            ? EmptyStateWidget(
                icon: Icons.search_off,
                title: 'No Inspections Found',
                message: 'Request your first inspection to get started',
                buttonText: 'Request Inspection',
                onButtonPressed: () {
                  Navigator.pushNamed(context, '/inspection/request')
                      .then((_) => _loadData());
                },
              )
            : Column(
                children: _inspections
                    .take(2)
                    .map((inspection) => _buildInspectionCard(inspection))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildInspectionCard(InspectionRequest inspection) {
    // Calculate progress percentage based on status
    double progressPercentage = 0.0;
    switch (inspection.status) {
      case 'pending':
        progressPercentage = 0.2;
        break;
      case 'assigned':
        progressPercentage = 0.4;
        break;
      case 'in_progress':
        progressPercentage = 0.6;
        break;
      case 'inspected':
        progressPercentage = 0.8;
        break;
      case 'completed':
        progressPercentage = 1.0;
        break;
      default:
        progressPercentage = 0.0;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/inspection/detail',
            arguments: inspection.id,
          ).then((_) => _loadData());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      inspection.itemName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(inspection.status)[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(inspection.status)[300]!,
                      ),
                    ),
                    child: Text(
                      _getStatusText(inspection.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(inspection.status)[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Requested on: ${_formatDate(inspection.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progressPercentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(inspection.status)[500]!,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${inspection.id.substring(0, 8)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${(progressPercentage * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(inspection.status)[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Deliveries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/orders');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _deliveries.isEmpty
            ? EmptyStateWidget(
                icon: Icons.local_shipping_outlined,
                title: 'No Deliveries Found',
                message: 'Your deliveries will appear here after inspection',
                buttonText: 'View Orders',
                onButtonPressed: () {
                  Navigator.pushNamed(context, '/orders');
                },
              )
            : Column(
                children: _deliveries
                    .take(2)
                    .map((delivery) => _buildDeliveryCard(delivery))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildDeliveryCard(DeliveryRequest delivery) {
    // Calculate progress percentage based on status
    double progressPercentage = 0.0;
    switch (delivery.status) {
      case 'pending':
        progressPercentage = 0.2;
        break;
      case 'processing':
        progressPercentage = 0.4;
        break;
      case 'in_transit':
        progressPercentage = 0.6;
        break;
      case 'out_for_delivery':
        progressPercentage = 0.8;
        break;
      case 'delivered':
        progressPercentage = 1.0;
        break;
      default:
        progressPercentage = 0.0;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/delivery/detail',
            arguments: delivery.id,
          ).then((_) => _loadData());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      delivery.itemName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDeliveryStatusColor(delivery.status)[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getDeliveryStatusColor(delivery.status)[300]!,
                      ),
                    ),
                    child: Text(
                      _getDeliveryStatusText(delivery.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getDeliveryStatusColor(delivery.status)[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Delivery date: ${_formatDate(delivery.expectedDeliveryDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progressPercentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getDeliveryStatusColor(delivery.status)[500]!,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${delivery.id.substring(0, 8)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${(progressPercentage * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getDeliveryStatusColor(delivery.status)[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  MaterialColor _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.indigo;
      case 'inspected':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned';
      case 'in_progress':
        return 'In Progress';
      case 'inspected':
        return 'Inspected';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  MaterialColor _getDeliveryStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'in_transit':
        return Colors.indigo;
      case 'out_for_delivery':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getDeliveryStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'in_transit':
        return 'In Transit';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
