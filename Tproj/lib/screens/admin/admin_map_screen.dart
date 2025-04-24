import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../models/agent.dart';
import '../services/agent_service.dart';
import '../widgets/admin_drawer.dart';

class AdminMapScreen extends StatefulWidget {
  const AdminMapScreen({Key? key}) : super(key: key);

  @override
  _AdminMapScreenState createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final AgentService _agentService = AgentService();
  
  bool _isLoading = true;
  List<Agent> _agents = [];
  Set<Marker> _markers = {};
  
  // UAE centered map
  static const CameraPosition _uaePosition = CameraPosition(
    target: LatLng(24.4539, 54.3773), // Abu Dhabi coordinates
    zoom: 9,
  );

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final agents = await _agentService.getAgents();
      
      if (mounted) {
        setState(() {
          _agents = agents;
          _createMarkers();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading agents: ${e.toString()}')),
        );
      }
    }
  }

  void _createMarkers() {
    _markers = _agents.map((agent) {
      // Determine marker color based on agent type and status
      BitmapDescriptor markerIcon;
      
      if (agent.isActive) {
        markerIcon = agent.type == 'inspector' 
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      } else {
        markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      }
      
      return Marker(
        markerId: MarkerId(agent.id),
        position: LatLng(agent.location.latitude, agent.location.longitude),
        icon: markerIcon,
        infoWindow: InfoWindow(
          title: agent.name,
          snippet: '${agent.type.toUpperCase()} - ${agent.isActive ? 'Active' : 'Inactive'}',
          onTap: () {
            _showAgentDetails(agent);
          },
        ),
      );
    }).toSet();
  }

  void _showAgentDetails(Agent agent) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: agent.isActive 
                        ? Colors.green[100] 
                        : Colors.red[100],
                    child: Icon(
                      agent.type == 'inspector' 
                          ? Icons.search 
                          : Icons.local_shipping,
                      color: agent.isActive 
                          ? Colors.green 
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${agent.type.toUpperCase()} - ${agent.isActive ? 'Active' : 'Inactive'}',
                          style: TextStyle(
                            color: agent.isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildInfoRow('Email', agent.email),
              _buildInfoRow('Phone', agent.phone),
              _buildInfoRow('Rating', '${agent.rating}/5.0'),
              _buildInfoRow('Completed Jobs', agent.completedJobs.toString()),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleAgentStatus(agent);
                    },
                    icon: Icon(agent.isActive ? Icons.pause : Icons.play_arrow),
                    label: Text(agent.isActive ? 'Deactivate' : 'Activate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: agent.isActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(
                        '/admin/agent/details',
                        arguments: agent.id,
                      );
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('View Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _toggleAgentStatus(Agent agent) async {
    try {
      await _agentService.updateAgentStatus(agent.id, !agent.isActive);
      
      // Reload agents to update the map
      _loadAgents();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${agent.name} has been ${agent.isActive ? 'deactivated' : 'activated'}.'
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating agent status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Map'),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAgents,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _uaePosition,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Showing ${_agents.length} agents in UAE',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildLegendItem('Inspector', Colors.blue),
                          const SizedBox(width: 8),
                          _buildLegendItem('Delivery', Colors.green),
                          const SizedBox(width: 8),
                          _buildLegendItem('Inactive', Colors.red),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/admin/agent/add');
        },
        backgroundColor: Colors.indigo[900],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Agents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Show Inspectors'),
                    value: true, // Replace with actual filter state
                    onChanged: (value) {
                      // Implement filter logic
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Show Delivery Agents'),
                    value: true, // Replace with actual filter state
                    onChanged: (value) {
                      // Implement filter logic
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Show Inactive Agents'),
                    value: true, // Replace with actual filter state
                    onChanged: (value) {
                      // Implement filter logic
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Apply filters
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[900],
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
