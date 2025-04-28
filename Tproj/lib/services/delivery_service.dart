import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_request.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DeliveryRequest?> createDeliveryRequest({
    required String userId,
    String? inspectionRequestId,
    required String itemName,
    required String itemDescription,
    required DateTime estimatedDeliveryDate,
    required String pickupLocation,
    required String deliveryLocation,
    required double price,
    String? notes,
  }) async {
    try {
      final requestData = DeliveryRequest(
        id: '',
        userId: userId,
        inspectionRequestId: inspectionRequestId,
        itemName: itemName,
        itemDescription: itemDescription,
        requestDate: DateTime.now(),
        estimatedDeliveryDate: estimatedDeliveryDate,
        status: DeliveryStatus.pending,
        pickupLocation: pickupLocation,
        deliveryLocation: deliveryLocation,
        price: price,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('deliveryRequests').add(requestData.toMap());
      return requestData.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating delivery request: $e');
      return null;
    }
  }

  // Get all delivery requests for a user
  Future<List<DeliveryRequest>> getUserDeliveries(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('deliveryRequests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => DeliveryRequest.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting user deliveries: $e');
      return [];
    }
  }

  Stream<List<DeliveryRequest>> getUserDeliveryRequests(String userId) {
    return _firestore
        .collection('deliveryRequests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DeliveryRequest.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<DeliveryRequest?> getDeliveryRequest(String requestId) async {
    try {
      final doc = await _firestore.collection('deliveryRequests').doc(requestId).get();
      if (doc.exists) {
        return DeliveryRequest.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting delivery request: $e');
      return null;
    }
  }

  Future<bool> updateDeliveryRequest({
    required String requestId,
    String? itemName,
    String? itemDescription,
    DateTime? estimatedDeliveryDate,
    DeliveryStatus? status,
    String? pickupLocation,
    String? deliveryLocation,
    double? price,
    String? trackingNumber,
    String? notes,
  }) async {
    try {
      final requestRef = _firestore.collection('deliveryRequests').doc(requestId);
      final requestDoc = await requestRef.get();
      
      if (!requestDoc.exists) return false;
      
      final request = DeliveryRequest.fromMap(requestDoc.data()!, requestDoc.id);
      final updatedRequest = request.copyWith(
        itemName: itemName,
        itemDescription: itemDescription,
        estimatedDeliveryDate: estimatedDeliveryDate,
        status: status,
        pickupLocation: pickupLocation,
        deliveryLocation: deliveryLocation,
        price: price,
        trackingNumber: trackingNumber,
        notes: notes,
        updatedAt: DateTime.now(),
      );
      
      await requestRef.update(updatedRequest.toMap());
      return true;
    } catch (e) {
      print('Error updating delivery request: $e');
      return false;
    }
  }

  Future<DeliveryRequest?> createDeliveryFromInspection({
    required String inspectionRequestId,
    required String userId,
    required String itemName,
    required String itemDescription,
    required String pickupLocation,
    required String deliveryLocation,
    required double price,
  }) async {
    try {
      final estimatedDeliveryDate = DateTime.now().add(const Duration(days: 7));
      return createDeliveryRequest(
        userId: userId,
        inspectionRequestId: inspectionRequestId,
        itemName: itemName,
        itemDescription: itemDescription,
        estimatedDeliveryDate: estimatedDeliveryDate,
        pickupLocation: pickupLocation,
        deliveryLocation: deliveryLocation,
        price: price,
      );
    } catch (e) {
      print('Error creating delivery from inspection: $e');
      return null;
    }
  }

  Future<bool> updateDeliveryStatus(String requestId, DeliveryStatus status) async {
    return updateDeliveryRequest(
      requestId: requestId,
      status: status,
    );
  }

  Future<bool> cancelDeliveryRequest(String requestId) async {
    try {
      await updateDeliveryRequest(
        requestId: requestId,
        status: DeliveryStatus.cancelled,
      );
      return true;
    } catch (e) {
      print('Error cancelling delivery request: $e');
      return false;
    }
  }

  Future<bool> addTrackingNumber(String requestId, String trackingNumber) async {
    return updateDeliveryRequest(
      requestId: requestId,
      trackingNumber: trackingNumber,
    );
  }

  Future<List<DeliveryRequest>> getAllDeliveryRequests() async {
    try {
      final snapshot = await _firestore.collection('deliveryRequests').get();
      return snapshot.docs.map((doc) => DeliveryRequest.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting all delivery requests: $e');
      return [];
    }
  }

  Future<bool> assignAgentToDelivery(String requestId, String agentId) async {
    try {
      await _firestore.collection('deliveryRequests').doc(requestId).update({
        'deliveryAgentId': agentId,
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error assigning agent to delivery: $e');
      return false;
    }
  }
}
