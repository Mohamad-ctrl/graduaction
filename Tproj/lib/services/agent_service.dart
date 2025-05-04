import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agent.dart';

class AgentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'agents';

  // UAE bounding box
  static const double _uaeMinLat = 22.5;
  static const double _uaeMaxLat = 26.0;
  static const double _uaeMinLon = 51.0;
  static const double _uaeMaxLon = 56.4;

  /// Create a new agent from primitive fields.
  Future<Agent> addAgent({
    required String firstName,
    required String lastName,
    required int    age,
    required String email,
    required String phone,
    required String type, // 'inspector' or 'delivery'
  }) async {
    final now = FieldValue.serverTimestamp();
    final data = {
      'name'          : '$firstName $lastName',
      'firstName'     : firstName,
      'lastName'      : lastName,
      'age'           : age,
      'email'         : email,
      'phone'         : phone,
      'type'          : type,
      'isActive'      : true,
      'rating'        : 0.0,
      'completedJobs' : 0,
      'location'      : _getRandomUaeCityLocation(),
      'createdAt'     : now,
      'updatedAt'     : now,
    };
    final docRef = await _firestore.collection(_collection).add(data);
    final snap   = await docRef.get();
    return Agent.fromMap(snap.data()!, snap.id);
  }

  Future<Agent?> getAgentById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    return doc.exists ? Agent.fromMap(doc.data()!, doc.id) : null;
  }

  Future<List<Agent>> getAgents() async {
    final snap = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Agent.fromMap(d.data(), d.id)).toList();
  }

  Future<List<Agent>> getActiveAgents() =>
      getAgents().then((list) => list.where((a) => a.isActive).toList());

  Future<List<Agent>> getAgentsByType(String type) =>
      getAgents().then((list) => list.where((a) => a.type == type).toList());

  Future<void> updateAgent(Agent agent) async {
    await _firestore
        .collection(_collection)
        .doc(agent.id)
        .update(agent.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> updateAgentStatus(String agentId, bool isActive) async {
    await _firestore.collection(_collection).doc(agentId).update({
      'isActive'  : isActive,
      'updatedAt' : FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAgentLocation(String agentId, GeoPoint location) async {
    await _firestore.collection(_collection).doc(agentId).update({
      'location'  : location,
      'updatedAt' : FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAgent(String agentId) async {
    await _firestore.collection(_collection).doc(agentId).delete();
  }

  /// Returns only those agents whose stored location is within the UAE box.
  Future<List<Agent>> getAgentsInUAE() async {
    final all = await getAgents();
    return all.where((a) => _isWithinUaeBounds(a.location)).toList();
  }

  bool _isWithinUaeBounds(GeoPoint loc) =>
      loc.latitude  .clamp(_uaeMinLat, _uaeMaxLat) == loc.latitude &&
      loc.longitude .clamp(_uaeMinLon, _uaeMaxLon) == loc.longitude;

  GeoPoint _getRandomUaeCityLocation() {
    // A few UAE city centers
    const cities = <GeoPoint>[
      GeoPoint(24.4539, 54.3773), // Abu Dhabi
      GeoPoint(25.2048, 55.2708), // Dubai
      GeoPoint(25.3463, 55.4209), // Sharjah
      GeoPoint(24.2075, 55.7447), // Al Ain
    ];
    final base = cities[Random().nextInt(cities.length)];
    const offset = 0.02; // ~2km
    final lat = (base.latitude  + (Random().nextDouble()*2 - 1)*offset)
        .clamp(_uaeMinLat, _uaeMaxLat);
    final lon = (base.longitude + (Random().nextDouble()*2 - 1)*offset)
        .clamp(_uaeMinLon, _uaeMaxLon);
    return GeoPoint(lat, lon);
  }

  /// Deletes all agents then creates [count] fresh mock agents.
  Future<void> resetAndCreateMockAgents(int count) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection(_collection).get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    for (var i = 0; i < count; i++) {
      await addAgent(
        firstName: 'Agent$i',
        lastName : 'Mock',
        age       : 25 + Random().nextInt(30),
        email     : 'agent$i@mock.com',
        phone     : '+97150000${i.toString().padLeft(4,'0')}',
        type      : i.isEven ? 'inspector' : 'delivery',
      );
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}
