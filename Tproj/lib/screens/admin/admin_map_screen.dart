import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/agent.dart';
import '../../services/agent_service.dart';
import '../../widgets/admin_drawer.dart';

class AdminMapScreen extends StatefulWidget {
  const AdminMapScreen({Key? key}) : super(key: key);

  @override
  _AdminMapScreenState createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  final _agentService = AgentService();
  final _controller    = Completer<GoogleMapController>();
  bool _isLoading      = true;
  List<Agent> _agents  = [];
  Set<Marker> _markers = {};

  static const _initialCamera = CameraPosition(
    target: LatLng(24.4539, 54.3773), // Abu Dhabi
    zoom: 9,
  );

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() => _isLoading = true);
    try {
      _agents = await _agentService.getAgentsInUAE();
      _markers = _agents.map(_makeMarker).toSet();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading agents: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Marker _makeMarker(Agent a) {
    final hue = a.isActive
        ? (a.type == 'inspector'
            ? BitmapDescriptor.hueBlue
            : BitmapDescriptor.hueGreen)
        : BitmapDescriptor.hueRed;
    return Marker(
      markerId: MarkerId(a.id),
      position: LatLng(a.location.latitude, a.location.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: a.name,
        snippet: '${a.type.toUpperCase()} • ${a.isActive ? 'Active' : 'Inactive'}',
        onTap: () => _showDetails(a),
      ),
    );
  }

  void _showDetails(Agent a) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(a.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _infoRow('Email', a.email),
            _infoRow('Phone', a.phone),
            _infoRow('Rating', '${a.rating}/5'),
            _infoRow('Jobs', '${a.completedJobs}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _agentService.updateAgentStatus(a.id, !a.isActive);
                    _loadAgents();
                  },
                  icon: Icon(a.isActive ? Icons.pause : Icons.play_arrow),
                  label: Text(a.isActive ? 'Deactivate' : 'Activate'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _agentService.deleteAgent(a.id);
                    _loadAgents();
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Map'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAgents),
        ],
      ),
      drawer: const AdminDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _initialCamera,
              markers: _markers,
              onMapCreated: (c) => _controller.complete(c),
            ),
    );
  }
}
