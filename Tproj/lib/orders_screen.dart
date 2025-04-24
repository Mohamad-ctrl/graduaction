// File: lib/screens/home/orders_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../constants/app_routes.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Orders', showBackButton: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  OrderItem(
                    title: 'Kia Optima 2013 Inspection',
                    date: '25 April 2025',
                    icon: Icons.directions_car,
                    statusColor: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.inspectionDetail),
                  ),
                  const SizedBox(height: 16),
                  OrderItem(
                    title: 'Siemens Cooking Range Inspection',
                    date: '15 March 2025',
                    icon: Icons.kitchen,
                    statusColor: Colors.green,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.inspectionDetail),
                  ),
                  const SizedBox(height: 16),
                  OrderItem(
                    title: 'Dodge Challenger 2018 Engine Inspection',
                    date: '02 February 2025',
                    icon: Icons.engineering,
                    statusColor: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.inspectionDetail),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

class OrderItem extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final Color statusColor;
  final VoidCallback onTap;

  const OrderItem({
    super.key,
    required this.title,
    required this.date,
    required this.icon,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
            Icon(icon, color: statusColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Requested on $date',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
