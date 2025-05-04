// File: lib/services/agent_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agent.dart';

class AgentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'agents';

  // ──────────────────────────  CREATE  ──────────────────────────

  /// Used by the *Add Agent* form: build an agent from primitives.
  Future<Agent> addAgent({
    required String firstName,
    required String lastName,
    required int    age,
    required String email,
    required String phone,
    required String type, // 'inspector' | 'delivery'
  }) async {
    final now = FieldValue.serverTimestamp();

    final data = {
      'name'          : '$firstName $lastName',   // legacy field
      'firstName'     : firstName,
      'lastName'      : lastName,
      'age'           : age,
      'email'         : email,
      'phone'         : phone,
      'type'          : type,
      'isActive'      : true,
      'rating'        : 0.0,
      'completedJobs' : 0,
      'location'      : const GeoPoint(0, 0),
      'createdAt'     : now,
      'updatedAt'     : now,
    };

    final doc = await _firestore.collection(_collection).add(data);
    final snap = await doc.get();
    return Agent.fromMap(snap.data()!, snap.id);
  }

  /// Legacy helper that accepts a fully-formed [Agent] object.
  Future<Agent> createAgent(Agent agent) async {
    final ref = await _firestore
        .collection(_collection)
        .add(agent.copyWith(updatedAt: DateTime.now()).toMap());
    return agent.copyWith(id: ref.id);
  }

  // ───────────────────────────  READ  ───────────────────────────

  Future<List<Agent>> getAgents() async {
    final snap = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Agent.fromMap(d.data(), d.id)).toList();
  }

  Future<Agent?> getAgentById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    return doc.exists ? Agent.fromMap(doc.data()!, doc.id) : null;
  }

  Future<List<Agent>> getActiveAgents() async {
    final snap = await _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map((d) => Agent.fromMap(d.data(), d.id)).toList();
  }

  Future<List<Agent>> getAgentsByType(String type) async {
    final snap = await _firestore
        .collection(_collection)
        .where('type', isEqualTo: type)
        .get();
    return snap.docs.map((d) => Agent.fromMap(d.data(), d.id)).toList();
  }

  // ──────────────────────────  UPDATE  ──────────────────────────

  Future<void> updateAgent(Agent agent) async {
    await _firestore.collection(_collection).doc(agent.id).update(
          agent.copyWith(updatedAt: DateTime.now()).toMap(),
        );
  }

  Future<void> updateAgentStatus(String agentId, bool isActive) async {
    await _firestore.collection(_collection).doc(agentId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAgentLocation(String agentId, GeoPoint location) async {
    await _firestore.collection(_collection).doc(agentId).update({
      'location': location,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ──────────────────────────  DELETE  ──────────────────────────

  Future<void> deleteAgent(String agentId) async {
    await _firestore.collection(_collection).doc(agentId).delete();
  }

  // ───────────────────────  MOCK / DEMO  ───────────────────────

  Future<List<Agent>> getAgentsInUAE() async => getAgents(); // placeholder

  Future<void> createMockAgents() async {
    // keep / expand your original mock-data logic here if you need it
  }
}
