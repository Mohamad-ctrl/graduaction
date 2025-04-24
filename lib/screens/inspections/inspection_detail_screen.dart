// File: lib/screens/inspections/inspection_detail_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../constants/app_routes.dart';
import '../../services/inspection_service.dart';
import '../../services/delivery_service.dart';
import '../../models/inspection_request.dart';
import '../../models/inspection_report.dart';
import '../../utils/navigation.dart';

class InspectionDetailScreen extends StatefulWidget {
  const InspectionDetailScreen({super.key});

  @override
  State<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  final InspectionService _inspectionService = InspectionService();
  final DeliveryService _deliveryService = DeliveryService();
  bool _isLoading = false;
  InspectionRequest? _inspectionRequest;
  InspectionReport? _inspectionReport;
  String? _requestId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the inspection request ID from the route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String && args != _requestId) {
      _requestId = args;
      _loadInspectionDetails();
    } else if (_requestId == null) {
      // For demo purposes, use a placeholder ID
      _requestId = 'placeholder_inspection_id';
      _loadInspectionDetails();
    }
  }

  Future<void> _loadInspectionDetails() async {
    if (_requestId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = await _inspectionService.getInspectionRequest(_requestId!);
      final report = await _inspectionService.getInspectionReport(_requestId!);

      if (mounted) {
        setState(() {
          _inspectionRequest = request;
          _inspectionReport = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inspection details: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _approveForDelivery() async {
    if (_inspectionRequest == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real implementation, this would use the current user's ID
      const userId = 'current_user_id';

      final deliveryRequest = await _deliveryService.createDeliveryFromInspection(
        inspectionRequestId: _inspectionRequest!.id,
        userId: userId,
        itemName: _inspectionRequest!.itemName,
        itemDescription: _inspectionRequest!.itemDescription,
        pickupLocation: _inspectionRequest!.location ?? 'Unknown location',
        deliveryLocation: 'User address', // This would be the user's address in a real implementation
        price: _inspectionRequest!.price ?? 0.0,
      );

      if (deliveryRequest != null && mounted) {
        // Navigate to delivery detail screen
        NavigationUtils.navigateTo(
          context,
          AppRoutes.deliveryDetail,
          arguments: deliveryRequest.id,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create delivery request')),
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

  Future<void> _closeInspectionCase() async {
    if (_inspectionRequest == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _inspectionService.cancelInspectionRequest(_inspectionRequest!.id);

      if (success && mounted) {
        // Show success message and go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inspection case closed successfully')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to close inspection case')),
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
      appBar: const CustomAppBar(title: 'Inspection Details'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inspectionRequest == null
              ? const Center(child: Text('Inspection request not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Inspection request for ${_inspectionRequest!.itemName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Timeline Section
                      _buildTimelineStep(
                        context,
                        isActive: true,
                        title: 'Item inspection date and time:',
                        subtitle: '${_inspectionRequest!.inspectionDate.toString().substring(0, 16)} Dubai time',
                        description: 'The item will be inspected by one of our experienced agents at the agreed time and date with the seller.',
                      ),
                      _buildTimelineConnector(),
                      _buildTimelineStep(
                        context,
                        isActive: _inspectionRequest!.status.index >= InspectionStatus.inProgress.index,
                        title: 'Item being inspected',
                        subtitle: '',
                        description: 'Our agent is currently inspecting the item to ensure it meets the required standards and specifications.',
                      ),
                      _buildTimelineConnector(),
                      _buildTimelineStep(
                        context,
                        isActive: _inspectionRequest!.status.index >= InspectionStatus.completed.index,
                        title: 'Item inspection is completed',
                        subtitle: '',
                        description: 'The inspection process has been completed and the results are being compiled.',
                      ),
                      _buildTimelineConnector(),
                      _buildTimelineStep(
                        context,
                        isActive: _inspectionRequest!.status.index >= InspectionStatus.reportUploaded.index,
                        title: 'Inspection report uploaded',
                        subtitle: '',
                        description: 'The final inspection report has been uploaded and is available for review.',
                      ),

                      const SizedBox(height: 24),
                      
                      // Download Report Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _inspectionReport != null
                              ? () {
                                  // Add download report logic
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Downloading report...')),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _inspectionReport != null ? Colors.blue : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.black, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Download report'),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _inspectionRequest!.status.index >= InspectionStatus.completed.index
                                  ? _approveForDelivery
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _inspectionRequest!.status.index >= InspectionStatus.completed.index
                                    ? Colors.green
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.black, width: 1),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Approve for delivery'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _closeInspectionCase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.black, width: 1),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Close inspection case'),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Contact Section
                      Container(
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
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.phone,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Contact us at: 800 3939',
                              style: TextStyle(fontSize: 15),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required bool isActive,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circle indicator
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: isActive
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector() {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      width: 1,
      height: 30,
      color: Colors.grey,
    );
  }
}
