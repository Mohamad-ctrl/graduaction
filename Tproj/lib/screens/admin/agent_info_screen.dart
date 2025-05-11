import 'package:flutter/material.dart';
import '../../models/agent.dart';
import '../../services/agent_service.dart';

class AgentInfoScreen extends StatefulWidget {
  final String agentId;
  const AgentInfoScreen({Key? key, required this.agentId}) : super(key: key);

  @override
  State<AgentInfoScreen> createState() => _AgentInfoScreenState();
}

class _AgentInfoScreenState extends State<AgentInfoScreen> {
  final _agentService = AgentService();
  bool _isLoading = true;
  Agent? _agent;

  @override
  void initState() {
    super.initState();
    _loadAgent();
  }

  Future<void> _loadAgent() async {
    final agent = await _agentService.getAgentById(widget.agentId);
    if (mounted) setState(() {
      _agent = agent;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Details'),
        backgroundColor: Colors.indigo[900],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _agent == null
              ? const Center(child: Text('Agent not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 24),
                      _sectionTitle('Contact'),
                      _infoRow(Icons.email, _agent!.email),
                      _infoRow(Icons.phone, _agent!.phone),
                      const SizedBox(height: 24),
                      _sectionTitle('Statistics'),
                      _infoRow(Icons.star, 'Rating: ${_agent!.rating}/5'),
                      _infoRow(Icons.check_circle,
                          'Completed Jobs: ${_agent!.completedJobs}'),
                      _infoRow(
                          Icons.location_on,
                          'Location: '
                          '${_agent!.location.latitude.toStringAsFixed(4)}, '
                          '${_agent!.location.longitude.toStringAsFixed(4)}'),
                      const SizedBox(height: 24),
                      _sectionTitle('Status'),
                      Chip(
                        label: Text(
                          _agent!.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                            _agent!.isActive ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _header() => Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: _agent!.isActive
                ? (_agent!.type == 'inspector'
                    ? Colors.blue[100]
                    : Colors.green[100])
                : Colors.red[100],
            child: Icon(
              _agent!.type == 'inspector'
                  ? Icons.search
                  : Icons.local_shipping,
              size: 34,
              color: _agent!.isActive
                  ? (_agent!.type == 'inspector'
                      ? Colors.blue
                      : Colors.green)
                  : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              _agent!.name,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _agent!.type.toUpperCase(),
              style: const TextStyle(color: Colors.grey),
            )
          ])
        ],
      );

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Icon(icon, size: 20, color: Colors.indigo[900]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ]),
      );
}
