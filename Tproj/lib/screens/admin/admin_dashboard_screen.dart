import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/admin_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final UserService _userService = UserService();
  User? _currentUser;
  bool _isLoading = true;
  
  // Statistics
  int _totalInspections = 0;
  int _pendingInspections = 0;
  int _totalDeliveries = 0;
  int _pendingDeliveries = 0;
  int _totalAgents = 0;
  int _activeAgents = 0;

  @override
  void initState() {
    super.initState();
    _loadUserAndStats();
  }

  Future<void> _loadUserAndStats() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load current user
      final user = await _userService.getCurrentUser();
      
      // Load statistics
      final stats = await _fetchStatistics();
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _totalInspections = stats['totalInspections'] ?? 0;
          _pendingInspections = stats['pendingInspections'] ?? 0;
          _totalDeliveries = stats['totalDeliveries'] ?? 0;
          _pendingDeliveries = stats['pendingDeliveries'] ?? 0;
          _totalAgents = stats['totalAgents'] ?? 0;
          _activeAgents = stats['activeAgents'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: ${e.toString()}')),
        );
      }
    }
  }

  Future<Map<String, int>> _fetchStatistics() async {
    // Fetch statistics from Firestore
    final inspectionsSnapshot = await FirebaseFirestore.instance.collection('inspectionRequests').get();
    final deliveriesSnapshot = await FirebaseFirestore.instance.collection('deliveryRequests').get();
    final agentsSnapshot = await FirebaseFirestore.instance.collection('agents').get();
    
    final pendingInspections = inspectionsSnapshot.docs
        .where((doc) => doc.data()['status'] == 'pending')
        .length;
    
    final pendingDeliveries = deliveriesSnapshot.docs
        .where((doc) => doc.data()['status'] == 'pending')
        .length;
    
    final activeAgents = agentsSnapshot.docs
        .where((doc) => doc.data()['isActive'] == true)
        .length;
    
    return {
      'totalInspections': inspectionsSnapshot.docs.length,
      'pendingInspections': pendingInspections,
      'totalDeliveries': deliveriesSnapshot.docs.length,
      'pendingDeliveries': pendingDeliveries,
      'totalAgents': agentsSnapshot.docs.length,
      'activeAgents': activeAgents,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.indigo[900],
      ),
      drawer: const AdminDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin welcome card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.indigo[100],
                              radius: 30,
                              child: Icon(
                                Icons.admin_panel_settings,
                                size: 30,
                                color: Colors.indigo[900],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${_currentUser?.name ?? 'Admin'}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Admin Dashboard',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Statistics section
                    const Text(
                      'System Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Statistics cards in a grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          title: 'Total Inspections',
                          value: _totalInspections.toString(),
                          icon: Icons.search,
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          title: 'Pending Inspections',
                          value: _pendingInspections.toString(),
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          title: 'Total Deliveries',
                          value: _totalDeliveries.toString(),
                          icon: Icons.local_shipping,
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          title: 'Pending Deliveries',
                          value: _pendingDeliveries.toString(),
                          icon: Icons.delivery_dining,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Agents section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Agents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/admin/agents');
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Agent statistics
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Agents',
                            value: _totalAgents.toString(),
                            icon: Icons.people,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Active Agents',
                            value: _activeAgents.toString(),
                            icon: Icons.person_pin_circle,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Map preview
                    const Text(
                      'Agent Locations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Map card
                    Card(
                      elevation: 4,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed('/admin/map');
                          },
                          child: Stack(
                            children: [
                              // Static preview removed – show a grey map icon instead.
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Center(
                                  child: Icon(Icons.map, size: 60, color: Colors.grey),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Agent Map',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_activeAgents active agents in UAE',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/admin/map');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo[900],
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('View Map'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: 'Manage Inspections',
                            icon: Icons.assignment,
                            onPressed: () {
                              Navigator.of(context).pushNamed('/admin/inspections');
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            label: 'Manage Deliveries',
                            icon: Icons.local_shipping,
                            onPressed: () {
                              Navigator.of(context).pushNamed('/admin/deliveries');
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: 'Manage Agents',
                            icon: Icons.people,
                            onPressed: () {
                              Navigator.of(context).pushNamed('/admin/agents');
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            label: 'View Map',
                            icon: Icons.map,
                            onPressed: () {
                              Navigator.of(context).pushNamed('/admin/map');
                            },
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo[900],
        elevation: 2,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
