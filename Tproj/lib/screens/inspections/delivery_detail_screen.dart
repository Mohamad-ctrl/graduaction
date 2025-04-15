// File: lib/screens/inspections/delivery_detail_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';

class DeliveryDetailScreen extends StatelessWidget {
  const DeliveryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Delivery Details & Tracking'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Delivery Request for a Kia Optima 2013',
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
              icon: Icons.calendar_today,
              title: 'Item pick up date and time:',
              subtitle: '21/04/2025 6:00PM Dubai time',
              isCompleted: true,
            ),
            _buildTimelineConnector(),
            _buildTimelineStep(
              context,
              icon: Icons.check_circle_outline,
              title: 'Item picked up',
              subtitle: '',
              isCompleted: true,
              description: 'The item has been picked up by our agent and is now heading to our warehouse to proceed to the shipping step!',
            ),
            _buildTimelineConnector(),
            _buildTimelineStep(
              context,
              icon: Icons.local_shipping,
              title: 'Item has been shipped',
              subtitle: '',
              isCompleted: false,
              description: 'The item has been shipped and is now heading to the destined country.',
            ),
            _buildTimelineConnector(),
            _buildTimelineStep(
              context,
              icon: Icons.directions_bus,
              title: 'Out for delivery',
              subtitle: '',
              isCompleted: false,
              description: 'Item is out for delivery and it will arrive to you soon!',
            ),
            _buildTimelineConnector(),
            _buildTimelineStep(
              context,
              icon: Icons.check_circle,
              title: 'Item delivered',
              subtitle: '',
              isCompleted: false,
              description: 'The item has been successfully delivered!',
            ),

            const SizedBox(height: 24),

            // Additional Information
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'More information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tracking Number: DXB78945612',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Estimated Delivery: 25/04/2025',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Delivery Address: Dubai Marina, Tower 5, Apartment 1204',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
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
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    String description = '',
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circle indicator
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.black : Colors.grey[600],
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? Colors.black : Colors.grey[600],
                  ),
                ),
              ],
              if (description.isNotEmpty && isCompleted) ...[
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
