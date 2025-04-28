import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/inspection_request.dart';
import '../models/inspection_report.dart';
import 'supabase_storage_service.dart';

class InspectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseStorageService _storageService = SupabaseStorageService();
  
  static const String _bucketName = 'inspection-images';

  Future<InspectionRequest?> createInspectionRequest({
    required String userId,
    required String itemName,
    required String itemDescription,
    required DateTime inspectionDate,
    String? location,
    String? sellerContact,
    List<String>? images,
    String? notes,
  }) async {
    try {
      final requestData = InspectionRequest(
        id: '',
        userId: userId,
        itemName: itemName,
        itemDescription: itemDescription,
        requestDate: DateTime.now(),
        inspectionDate: inspectionDate,
        status: InspectionStatus.pending,
        location: location,
        sellerContact: sellerContact,
        images: images,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('inspectionRequests').add(requestData.toMap());
      return requestData.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating inspection request: $e');
      return null;
    }
  }

  Stream<List<InspectionRequest>> getUserInspectionRequests(String userId) {
    return _firestore
        .collection('inspectionRequests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return InspectionRequest.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<InspectionRequest?> getInspectionRequest(String requestId) async {
    try {
      final doc = await _firestore.collection('inspectionRequests').doc(requestId).get();
      if (doc.exists) {
        return InspectionRequest.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting inspection request: $e');
      return null;
    }
  }

  Future<bool> updateInspectionRequest({
    required String requestId,
    String? itemName,
    String? itemDescription,
    DateTime? inspectionDate,
    InspectionStatus? status,
    String? location,
    String? sellerContact,
    List<String>? images,
    String? notes,
  }) async {
    try {
      final requestRef = _firestore.collection('inspectionRequests').doc(requestId);
      final requestDoc = await requestRef.get();
      
      if (!requestDoc.exists) return false;
      
      final request = InspectionRequest.fromMap(requestDoc.data()!, requestDoc.id);
      final updatedRequest = request.copyWith(
        itemName: itemName,
        itemDescription: itemDescription,
        inspectionDate: inspectionDate,
        status: status,
        location: location,
        sellerContact: sellerContact,
        images: images,
        notes: notes,
        updatedAt: DateTime.now(),
      );
      
      await requestRef.update(updatedRequest.toMap());
      return true;
    } catch (e) {
      print('Error updating inspection request: $e');
      return false;
    }
  }

  Future<List<String>> uploadInspectionImages(String requestId, List<File> images) async {
    try {
      final imageUrls = await _storageService.uploadFiles(
        bucketName: _bucketName,
        path: requestId,
        files: images,
      );
      return imageUrls;
    } catch (e) {
      print('Error uploading inspection images: $e');
      return [];
    }
  }

  Future<InspectionReport?> createInspectionReport({
    required String inspectionRequestId,
    required String agentId,
    required String itemCondition,
    required bool itemMatchesDescription,
    required List<String> images,
    required String comments,
    required Map<String, dynamic> additionalDetails,
  }) async {
    try {
      await updateInspectionRequest(
        requestId: inspectionRequestId,
        status: InspectionStatus.reportUploaded,
      );
      
      final reportData = InspectionReport(
        id: '',
        inspectionRequestId: inspectionRequestId,
        agentId: agentId,
        inspectionDate: DateTime.now(),
        itemCondition: itemCondition,
        itemMatchesDescription: itemMatchesDescription,
        images: images,
        comments: comments,
        additionalDetails: additionalDetails,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('inspectionReports').add(reportData.toMap());
      return reportData.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating inspection report: $e');
      return null;
    }
  }

  Future<InspectionReport?> getInspectionReport(String requestId) async {
    try {
      final querySnapshot = await _firestore
          .collection('inspectionReports')
          .where('inspectionRequestId', isEqualTo: requestId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return InspectionReport.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting inspection report: $e');
      return null;
    }
  }

  Future<bool> cancelInspectionRequest(String requestId) async {
    try {
      await updateInspectionRequest(
        requestId: requestId,
        status: InspectionStatus.cancelled,
      );
      return true;
    } catch (e) {
      print('Error cancelling inspection request: $e');
      return false;
    }
  }

  Future<List<InspectionRequest>> getAllInspectionRequests() async {
    try {
      final snapshot = await _firestore.collection('inspectionRequests').get();
      return snapshot.docs.map((doc) => InspectionRequest.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting all inspection requests: $e');
      return [];
    }
  }

  Future<bool> updateInspectionStatus(String requestId, InspectionStatus status) async {
    try {
      await _firestore.collection('inspectionRequests').doc(requestId).update({
        'status': status.index,
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error updating inspection status: $e');
      return false;
    }
  }

  Future<bool> assignAgentToInspection(String requestId, String agentId) async {
    try {
      await _firestore.collection('inspectionRequests').doc(requestId).update({
        'agentId': agentId,
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error assigning agent to inspection: $e');
      return false;
    }
  }
}