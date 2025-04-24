import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agent.dart';

class AgentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'agents';

  // Get all agents
  Future<List<Agent>> getAgents() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => Agent.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting agents: $e');
      throw e;
    }
  }

  // Get agent by ID
  Future<Agent?> getAgentById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Agent.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting agent by ID: $e');
      throw e;
    }
  }

  // Get active agents
  Future<List<Agent>> getActiveAgents() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => Agent.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting active agents: $e');
      throw e;
    }
  }

  // Get agents by type
  Future<List<Agent>> getAgentsByType(String type) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('type', isEqualTo: type)
          .get();
      return snapshot.docs
          .map((doc) => Agent.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting agents by type: $e');
      throw e;
    }
  }

  // Create new agent
  Future<Agent> createAgent(Agent agent) async {
    try {
      final docRef = await _firestore.collection(_collection).add(agent.toMap());
      return agent.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating agent: $e');
      throw e;
    }
  }

  // Update agent
  Future<void> updateAgent(Agent agent) async {
    try {
      await _firestore.collection(_collection).doc(agent.id).update(
            agent.copyWith(updatedAt: DateTime.now()).toMap(),
          );
    } catch (e) {
      print('Error updating agent: $e');
      throw e;
    }
  }

  // Update agent status
  Future<void> updateAgentStatus(String agentId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(agentId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating agent status: $e');
      throw e;
    }
  }

  // Update agent location
  Future<void> updateAgentLocation(String agentId, GeoPoint location) async {
    try {
      await _firestore.collection(_collection).doc(agentId).update({
        'location': location,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating agent location: $e');
      throw e;
    }
  }

  // Delete agent
  Future<void> deleteAgent(String agentId) async {
    try {
      await _firestore.collection(_collection).doc(agentId).delete();
    } catch (e) {
      print('Error deleting agent: $e');
      throw e;
    }
  }

  // Get agents in UAE region (for mock data)
  Future<List<Agent>> getAgentsInUAE() async {
    try {
      // In a real app, you would use geolocation queries
      // For this example, we'll just return all agents
      return getAgents();
    } catch (e) {
      print('Error getting agents in UAE: $e');
      throw e;
    }
  }

  // Create mock agents for testing
  Future<void> createMockAgents() async {
    try {
      // Dubai coordinates
      final dubai = const GeoPoint(25.2048, 55.2708);
      // Abu Dhabi coordinates
      final abuDhabi = const GeoPoint(24.4539, 54.3773);
      // Sharjah coordinates
      final sharjah = const GeoPoint(25.3463, 55.4209);
      // Ajman coordinates
      final ajman = const GeoPoint(25.4111, 55.4354);
      
      final mockAgents = [
        Agent(
          id: 'agent1',
          name: 'John Smith',
          email: 'john.smith@example.com',
          phone: '+971501234567',
          type: 'inspector',
          isActive: true,
          location: dubai,
          rating: 4.8,
          completedJobs: 42,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Agent(
          id: 'agent2',
          name: 'Sarah Johnson',
          email: 'sarah.johnson@example.com',
          phone: '+971502345678',
          type: 'inspector',
          isActive: true,
          location: abuDhabi,
          rating: 4.5,
          completedJobs: 35,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Agent(
          id: 'agent3',
          name: 'Mohammed Ali',
          email: 'mohammed.ali@example.com',
          phone: '+971503456789',
          type: 'inspector',
          isActive: false,
          location: sharjah,
          rating: 4.2,
          completedJobs: 28,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Agent(
          id: 'agent4',
          name: 'Ahmed Khan',
          email: 'ahmed.khan@example.com',
          phone: '+971504567890',
          type: 'delivery',
          isActive: true,
          location: dubai,
          rating: 4.9,
          completedJobs: 56,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Agent(
          id: 'agent5',
          name: 'Fatima Al-Zahra',
          email: 'fatima.alzahra@example.com',
          phone: '+971505678901',
          type: 'delivery',
          isActive: true,
          location: abuDhabi,
          rating: 4.7,
          completedJobs: 48,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Agent(
          id: 'agent6',
          name: 'Omar Yusuf',
          email: 'omar.yusuf@example.com',
          phone: '+971506789012',
          type: 'delivery',
          isActive: false,
          location: ajman,
          rating: 4.3,
          completedJobs: 32,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      // Add each mock agent to Firestore
      for (final agent in mockAgents) {
        await _firestore.collection(_collection).doc(agent.id).set(agent.toMap());
      }
    } catch (e) {
      print('Error creating mock agents: $e');
      throw e;
    }
  }
}
