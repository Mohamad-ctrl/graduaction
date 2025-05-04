import 'package:flutter/material.dart';
import '../constants/app_routes.dart';

/// Re-usable bottom navigation bar.
/// Pass the index of the tab that should appear selected on the
/// screen that is showing the bar.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  /// A tidy map that keeps the switch-statement out of onTap.
  static const _destinations = <String>[
    AppRoutes.home,              // 0 – Home
    AppRoutes.inspectionRequest, // 1 – Inspections
    AppRoutes.deliveriesRequests,            // 2 – Deliveries (list / “Orders”)
    AppRoutes.profile,           // 3 – Profile
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.indigo[900],
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home),            label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search),          label: 'Inspections'),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping),  label: 'Deliveries'),
        BottomNavigationBarItem(icon: Icon(Icons.person),          label: 'Profile'),
      ],
      onTap: (index) {
        // Avoid rebuilding the same page.
        // if (index == currentIndex) return;

        // Push-and-replace so the back-stack stays clean.
        Navigator.pushReplacementNamed(context, _destinations[index]);
      },
    );
  }
}
