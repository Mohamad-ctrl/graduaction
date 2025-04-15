// File: lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../constants/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home', showBackButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            const Text(
              'Welcome Back, Mohamad!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  context,
                  Icons.search,
                  'New Inspection',
                  () {
                    Navigator.pushNamed(context, AppRoutes.inspectionRequest);
                  },
                ),
                _buildQuickActionButton(
                  context,
                  Icons.local_shipping,
                  'New Delivery',
                  () {
                    Navigator.pushNamed(context, AppRoutes.deliveryDetail);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Current Inspections Status
            const Text(
              'Current Inspections Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildStatusCard(
              context,
              'Inspection Reference: KC412D',
              [
                'Inspection Appointment Set',
                'Item Being Inspected',
                'Inspection Completed',
                'Inspection Report Uploaded',
              ],
              2, // Progress level (0-based index)
              () {
                Navigator.pushNamed(context, AppRoutes.inspectionDetail);
              },
            ),
            const SizedBox(height: 20),

            // Current Deliveries Status
            const Text(
              'Current Deliveries Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildStatusCard(
              context,
              'Delivery Reference: KC412D',
              [
                'Pick Up the Item',
                'Shipped',
                'Out for Delivery',
                'Delivered',
              ],
              1, // Progress level (0-based index)
              () {
                Navigator.pushNamed(context, AppRoutes.deliveryDetail);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  // Helper method to build quick action buttons
  Widget _buildQuickActionButton(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
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
            child: Icon(icon, size: 40, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Helper method to build status cards
  Widget _buildStatusCard(
    BuildContext context, 
    String title, 
    List<String> steps,
    int progressLevel,
    VoidCallback onMoreInfo,
  ) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: steps.asMap().entries.map((entry) {
              int index = entry.key;
              String step = entry.value;
              return Expanded(
                child: Column(
                  children: [
                    Icon(
                      index <= progressLevel ? Icons.check_circle : Icons.circle_outlined,
                      size: 12,
                      color: index <= progressLevel ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: index <= progressLevel ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onMoreInfo,
              child: const Text(
                'More Information',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
