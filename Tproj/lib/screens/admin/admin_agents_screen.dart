import 'package:flutter/material.dart';
import '../../models/agent.dart';
import '../../services/agent_service.dart';
import '../../widgets/admin_drawer.dart';
import '../../constants/app_routes.dart';  

class AdminAgentsScreen extends StatefulWidget {
  const AdminAgentsScreen({Key? key}) : super(key: key);

  @override
  _AdminAgentsScreenState createState() => _AdminAgentsScreenState();
}

class _AdminAgentsScreenState extends State<AdminAgentsScreen> {
  final AgentService _agentService = AgentService();
  
  bool _isLoading = true;
  List<Agent> _agents = [];
  String _filterType = 'all'; // 'all', 'inspector', 'delivery'
  String _filterStatus = 'all'; // 'all', 'active', 'inactive'

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

  List<Agent> get _filteredAgents {
    return _agents.where((agent) {
      // Filter by type
      if (_filterType != 'all' && agent.type != _filterType) {
        return false;
      }
      
      // Filter by status
      if (_filterStatus == 'active' && !agent.isActive) {
        return false;
      }
      if (_filterStatus == 'inactive' && agent.isActive) {
        return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Agents'),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAgents,
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter options
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Agent Type',
                            border: OutlineInputBorder(),
                          ),
                          value: _filterType,
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Types'),
                            ),
                            DropdownMenuItem(
                              value: 'inspector',
                              child: Text('Inspectors'),
                            ),
                            DropdownMenuItem(
                              value: 'delivery',
                              child: Text('Delivery Agents'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _filterType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          value: _filterStatus,
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Status'),
                            ),
                            DropdownMenuItem(
                              value: 'active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'inactive',
                              child: Text('Inactive'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _filterStatus = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Agent count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Showing ${_filteredAgents.length} agents',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/admin/map');
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('View Map'),
                      ),
                    ],
                  ),
                ),
                
                // Agent list
                Expanded(
                  child: _filteredAgents.isEmpty
                      ? const Center(
                          child: Text('No agents found matching the filters'),
                        )
                      : ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 90), // ↙︎ gives space under FAB
                        itemCount: _filteredAgents.length,
                        itemBuilder: (context, index) {
                          final agent = _filteredAgents[index];
                          return _buildAgentCard(agent);
                          },
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

  Widget _buildAgentCard(Agent agent) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: agent.isActive 
              ? (agent.type == 'inspector' ? Colors.blue[100] : Colors.green[100])
              : Colors.red[100],
          child: Icon(
            agent.type == 'inspector' ? Icons.search : Icons.local_shipping,
            color: agent.isActive 
                ? (agent.type == 'inspector' ? Colors.blue : Colors.green)
                : Colors.red,
          ),
        ),
        title: Text(
          agent.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${agent.type.toUpperCase()} • Rating: ${agent.rating}/5.0',
            ),
            Text(
              agent.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: agent.isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                agent.isActive ? Icons.pause : Icons.play_arrow,
                color: agent.isActive ? Colors.red : Colors.green,
              ),
              onPressed: () {
                _toggleAgentStatus(agent);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/admin/agent/edit',
                  arguments: agent.id,
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/admin/agent/details',
            arguments: agent.id,
          );
        },
      ),
    );
  }

  Future<void> _toggleAgentStatus(Agent agent) async {
    try {
      await _agentService.updateAgentStatus(agent.id, !agent.isActive);
      
      // Reload agents to update the list
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
}
