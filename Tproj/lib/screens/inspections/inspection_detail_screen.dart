// File: lib/screens/inspections/inspection_detail_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../constants/app_routes.dart';

class InspectionDetailScreen extends StatelessWidget {
  const InspectionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Inspection Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Inspection request for a Kia Optima 2013',
              style: TextStyle(
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
              subtitle: '21/04/2025 6:00PM Dubai time',
              description: 'The item will be inspected by one of our experienced agents at the agreed time and date with the seller.',
            ),
            _buildTimelineConnector(),
            _buildTimelineStep(
              context,
              isActive: true,
              title: 'Item being inspected',
              subtitle: '',
              description: 'Our agent is currently inspecting the item to ensure it meets the required standards and specifications.',
            ),
            _buildTimelineConnector(),
            _buildTimelineStep(
              context,
              isActive: false,
              title: 'Item inspection is completed',
              subtitle: '',
              description: 'The inspection process has been completed and the results are being compiled.',
            ),
            _buildTimelineConnector(),
            _buildTimelineStep(
              context,
              isActive: false,
              title: 'Inspection report uploaded',
              subtitle: '',
              description: 'The final inspection report has been uploaded and is available for review.',
            ),

            const SizedBox(height: 24),
            
            // Download Report Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add download report logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report will be available after inspection is completed')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
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
                    onPressed: () {
                      // Add approve for delivery logic
                      Navigator.pushNamed(context, AppRoutes.deliveryDetail);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
                    onPressed: () {
                      // Add close inspection case logic
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Close Inspection Case'),
                          content: const Text('Are you sure you want to close this inspection case?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Inspection case closed')),
                                );
                              },
                              child: const Text('Close Case'),
                            ),
                          ],
                        ),
                      );
                    },
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
