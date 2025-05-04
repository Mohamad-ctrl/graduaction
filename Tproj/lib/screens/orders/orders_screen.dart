import 'package:flutter/material.dart';
import '../../models/inspection_request.dart';
import '../../models/delivery_request.dart';
import '../../services/inspection_service.dart';
import '../../services/delivery_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../constants/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InspectionService _inspectionService = InspectionService();
  final DeliveryService _deliveryService = DeliveryService();
  
  List<InspectionRequest> _inspections = [];
  List<DeliveryRequest> _deliveries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final inspections = await _inspectionService.getUserInspections(userId);
        final deliveries = await _deliveryService.getUserDeliveries(userId);
        
        setState(() {
          _inspections = inspections;
          _deliveries = deliveries;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Orders'),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.indigo[900],
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.indigo[900],
            tabs: const [
              Tab(text: 'Inspections'),
              Tab(text: 'Deliveries'),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInspectionsList(),
                      _buildDeliveriesList(),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildInspectionsList() {
    if (_inspections.isEmpty) {
      return EmptyStateWidget(
        message: 'You have no inspection requests yet',
        icon: Icons.search,
        buttonText: 'Request Inspection',
        onButtonPressed: () {
          Navigator.pushNamed(context, AppRoutes.inspectionRequest);
        },
        title: 'No Inspections',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _inspections.length,
      itemBuilder: (context, index) {
        final inspection = _inspections[index];
        return _buildInspectionCard(inspection);
      },
    );
  }

  Widget _buildDeliveriesList() {
    if (_deliveries.isEmpty) {
      return EmptyStateWidget(
        message: 'You have no delivery requests yet',
        icon: Icons.local_shipping,
        title: 'No Deliveries',
        buttonText: 'Request Delivery',
        onButtonPressed: () {
          // Navigate to delivery request screen if available
          // For now, just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Delivery request feature coming soon')),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _deliveries.length,
      itemBuilder: (context, index) {
        final delivery = _deliveries[index];
        return _buildDeliveryCard(delivery);
      },
    );
  }

  Widget _buildInspectionCard(InspectionRequest inspection) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.inspectionDetail,
            arguments: inspection.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Inspection #${inspection.id.substring(0, min(inspection.id.length, 6))}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(inspection.status.toString().split('.').last),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Date', inspection.inspectionDate.toString().substring(0, 10)),
              _buildInfoRow('Location', inspection.location ?? 'Not specified'),
              _buildInfoRow('Item', inspection.itemDescription),
              const SizedBox(height: 8),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.inspectionDetail,
                        arguments: inspection.id,
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(DeliveryRequest delivery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.deliveryDetail,
            arguments: delivery.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery #${delivery.id.substring(0, min(delivery.id.length, 6))}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(delivery.status.toString().split('.').last),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('From', delivery.pickupLocation),
              _buildInfoRow('To', delivery.deliveryLocation),
              _buildInfoRow('Item', delivery.itemDescription),
              const SizedBox(height: 8),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.deliveryDetail,
                        arguments: delivery.id,
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    
    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange;
        break;
      case 'scheduled':
        backgroundColor = Colors.blue;
        break;
      case 'inprogress':
        backgroundColor = Colors.purple;
        break;
      case 'completed':
        backgroundColor = Colors.green;
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  // Helper function to get minimum of two integers
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
