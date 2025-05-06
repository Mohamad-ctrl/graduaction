import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:math'; // Import dart:math for min function
import '../../services/inspection_service.dart';
import '../../services/delivery_service.dart';
import '../../models/inspection_request.dart';
import '../../models/delivery_request.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/bottom_nav_bar.dart';

// Define breakpoints for responsive layout
const double kTabletBreakpoint = 600.0;
const double kDesktopBreakpoint = 1024.0;
const double kMaxContentWidth = 1200.0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InspectionService _inspectionService = InspectionService();
  final DeliveryService _deliveryService = DeliveryService();
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  bool _isLoading = true;
  List<InspectionRequest> _inspections = [];
  List<DeliveryRequest> _deliveries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return; // Check if the widget is still in the tree
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        // Consider navigating to login or showing an error message
        throw Exception('User not logged in');
      }

      // Fetch data concurrently
      final results = await Future.wait([
        _inspectionService.getUserInspections(userId),
        _deliveryService.getUserDeliveries(userId),
      ]);

      if (mounted) {
        setState(() {
          _inspections = results[0] as List<InspectionRequest>;
          _deliveries = results[1] as List<DeliveryRequest>;
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
    // Use LayoutBuilder to get screen constraints
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Check & Deliver',
        showBackButton: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine padding based on screen width
          final double horizontalPadding = constraints.maxWidth > kTabletBreakpoint ? 32.0 : 16.0;
          final bool isDesktop = constraints.maxWidth >= kDesktopBreakpoint;

          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  // Center the content and constrain its width on larger screens
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeCard(isDesktop),
                            const SizedBox(height: 24),
                            _buildQuickActions(constraints.maxWidth),
                            const SizedBox(height: 24),
                            _buildRecentActivitySection(isDesktop),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
        },
      ),
      // Keep BottomNavBar for now, could be replaced with NavigationRail for web later
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  // Adapt Welcome Card layout slightly for desktop if needed
  Widget _buildWelcomeCard(bool isDesktop) {
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
            Text(
              'Welcome to Check & Deliver',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your trusted partner for remote item inspection and secure delivery services.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70, // Slightly softer color
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // Use Wrap for status cards if they might overflow on smaller screens
            // Or keep Row if it's guaranteed to fit
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
                color: textColor.withOpacity(0.8),
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

  // Adapt Quick Actions layout
  Widget _buildQuickActions(double screenWidth) {
    // Use Wrap for better adaptability on different screen sizes
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
        Wrap(
          spacing: 12.0, // Horizontal spacing between items
          runSpacing: 12.0, // Vertical spacing between lines
          children: [
            _buildActionButton(
              'Request Inspection',
              Icons.search,
              Colors.blue,
              screenWidth,
              () {
                Navigator.pushNamed(context, '/inspection/request')
                    .then((_) => _loadData());
              },
            ),
            _buildActionButton(
              'Track Orders',
              Icons.local_shipping,
              Colors.green,
              screenWidth,
              () {
                Navigator.pushNamed(context, '/orders');
              },
            ),
            _buildActionButton(
              'My Profile',
              Icons.person,
              Colors.purple,
              screenWidth,
              () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ],
    );
  }

  // Adjust Action Button size based on screen width
  Widget _buildActionButton(String title, IconData icon, MaterialColor color, double screenWidth, VoidCallback onTap) {
    // Calculate width for the button, aiming for 3 buttons per row on mobile/tablet
    // and potentially more flexible layout on desktop via Wrap
    double buttonWidth = (screenWidth - (2 * 12.0) - (2 * (screenWidth > kTabletBreakpoint ? 32.0 : 16.0))) / 3; // Approximate width for 3 items
    // Ensure minimum width
    buttonWidth = max(buttonWidth, 100.0);

    return SizedBox(
      // Use SizedBox to suggest a width to the Wrap layout
      width: screenWidth > kTabletBreakpoint ? null : buttonWidth, // Let Wrap handle width on larger screens
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), // Adjust padding
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

  // Combine Inspection and Delivery sections for better structure
  Widget _buildRecentActivitySection(bool isDesktop) {
    // On desktop, potentially show sections side-by-side
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildInspectionSection(),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildDeliverySection(),
          ),
        ],
      );
    } else {
      // On smaller screens, stack them vertically
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInspectionSection(),
          const SizedBox(height: 24),
          _buildDeliverySection(),
        ],
      );
    }
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
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
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
                // Show more items on desktop if available
                children: _inspections
                    .take(3) // Show up to 3 items
                    .map((inspection) => _buildInspectionCard(inspection))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildInspectionCard(InspectionRequest inspection) {
    double progressPercentage = _calculateInspectionProgress(inspection.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent rounding
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/inspection/detail',
            arguments: inspection.id,
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start, // Align top
                children: [
                  Expanded(
                    child: Text(
                      inspection.itemName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2, // Allow two lines
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(inspection.status).shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(inspection.status).shade300,
                      ),
                    ),
                    child: Text(
                      _getStatusText(inspection.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(inspection.status).shade700,
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
                  _getStatusColor(inspection.status).shade500,
                ),
                minHeight: 6, // Slightly thicker bar
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${inspection.id.substring(0, min(8, inspection.id.length))}...',
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
                      color: _getStatusColor(inspection.status).shade700,
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
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
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
                    .take(3) // Show up to 3 items
                    .map((delivery) => _buildDeliveryCard(delivery))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildDeliveryCard(DeliveryRequest delivery) {
    double progressPercentage = _calculateDeliveryProgress(delivery.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/delivery/detail',
            arguments: delivery.id,
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      delivery.itemName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDeliveryStatusColor(delivery.status).shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getDeliveryStatusColor(delivery.status).shade300,
                      ),
                    ),
                    child: Text(
                      _getDeliveryStatusText(delivery.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getDeliveryStatusColor(delivery.status).shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Estimated delivery: ${_formatDate(delivery.estimatedDeliveryDate)}',
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
                  _getDeliveryStatusColor(delivery.status).shade500,
                ),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${delivery.id.substring(0, min(8, delivery.id.length))}...',
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
                      color: _getDeliveryStatusColor(delivery.status).shade700,
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

  // Helper methods for status, progress, color, text, date formatting
  double _calculateInspectionProgress(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.pending: return 0.2;
      case InspectionStatus.scheduled: return 0.4;
      case InspectionStatus.inProgress: return 0.6;
      case InspectionStatus.completed: return 0.8;
      case InspectionStatus.reportUploaded: return 1.0;
      case InspectionStatus.cancelled: return 0.0;
      default: return 0.0;
    }
  }

  double _calculateDeliveryProgress(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending: return 0.1;
      case DeliveryStatus.itemPickedUp: return 0.3;
      case DeliveryStatus.inProgress: return 0.5; // Added for consistency
      case DeliveryStatus.shipped: return 0.7;
      case DeliveryStatus.outForDelivery: return 0.9;
      case DeliveryStatus.delivered: return 1.0;
      case DeliveryStatus.completed: return 1.0; // Same as delivered
      case DeliveryStatus.cancelled: return 0.0;
      default: return 0.0;
    }
  }

  MaterialColor _getStatusColor(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.pending: return Colors.orange;
      case InspectionStatus.scheduled: return Colors.blue;
      case InspectionStatus.inProgress: return Colors.indigo;
      case InspectionStatus.completed: return Colors.green;
      case InspectionStatus.reportUploaded: return Colors.teal;
      case InspectionStatus.cancelled: return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(InspectionStatus status) {
    // Improved status text clarity
    switch (status) {
      case InspectionStatus.pending: return 'Pending';
      case InspectionStatus.scheduled: return 'Scheduled';
      case InspectionStatus.inProgress: return 'Inspecting';
      case InspectionStatus.completed: return 'Done';
      case InspectionStatus.reportUploaded: return 'Report Ready';
      case InspectionStatus.cancelled: return 'Cancelled';
      default: return 'Unknown';
    }
  }

  MaterialColor _getDeliveryStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending: return Colors.orange;
      case DeliveryStatus.itemPickedUp: return Colors.lightBlue;
      case DeliveryStatus.inProgress: return Colors.blue; // Added
      case DeliveryStatus.shipped: return Colors.indigo;
      case DeliveryStatus.outForDelivery: return Colors.purple;
      case DeliveryStatus.delivered: return Colors.green;
      case DeliveryStatus.completed: return Colors.green; // Same as delivered
      case DeliveryStatus.cancelled: return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getDeliveryStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending: return 'Pending Pickup';
      case DeliveryStatus.itemPickedUp: return 'Picked Up';
      case DeliveryStatus.inProgress: return 'In Transit'; // Added
      case DeliveryStatus.shipped: return 'Shipped';
      case DeliveryStatus.outForDelivery: return 'Out for Delivery';
      case DeliveryStatus.delivered: return 'Delivered';
      case DeliveryStatus.completed: return 'Completed'; // Same as delivered
      case DeliveryStatus.cancelled: return 'Cancelled';
      default: return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    // Consider using the intl package for more robust formatting
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}