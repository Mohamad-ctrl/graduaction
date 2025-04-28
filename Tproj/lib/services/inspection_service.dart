import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/inspection_request.dart'; // Defines InspectionRequest and InspectionStatus
import '../models/inspection_report.dart'; // Defines InspectionReport, InspectionReportRequest, InspectionReportStatus
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
      // Create the data map first, excluding the ID
      final requestDataMap = {
        'userId': userId,
        'itemName': itemName,
        'itemDescription': itemDescription,
        'requestDate': Timestamp.now(),
        'inspectionDate': Timestamp.fromDate(inspectionDate),
        'status': InspectionStatus.pending.index,
        'location': location,
        'sellerContact': sellerContact,
        'images': images,
        'notes': notes,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'agentId': null, // Ensure agentId is included, even if null
        'price': null,   // Ensure price is included, even if null
      };

      // Add the document to Firestore to get the ID
      final docRef = await _firestore.collection('inspectionRequests').add(requestDataMap);
      
      // Return the full InspectionRequest object using fromMap
      return InspectionRequest.fromMap(requestDataMap, docRef.id);
    } catch (e) {
      // print('Error creating inspection request: $e'); // Removed print
      return null;
    }
  }

  // Get all inspection requests for a user (Future-based)
  Future<List<InspectionRequest>> getUserInspections(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('inspectionRequests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => InspectionRequest.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      // print('Error getting user inspections: $e'); // Removed print
      return [];
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
      // print('Error getting inspection request: $e'); // Removed print
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
      
      // Create a map of fields to update, excluding null values
      final Map<String, dynamic> updateData = {};
      if (itemName != null) updateData['itemName'] = itemName;
      if (itemDescription != null) updateData['itemDescription'] = itemDescription;
      if (inspectionDate != null) updateData['inspectionDate'] = Timestamp.fromDate(inspectionDate);
      if (status != null) updateData['status'] = status.index;
      if (location != null) updateData['location'] = location;
      if (sellerContact != null) updateData['sellerContact'] = sellerContact;
      if (images != null) updateData['images'] = images;
      if (notes != null) updateData['notes'] = notes;
      
      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = Timestamp.now();
        await requestRef.update(updateData);
      }
      
      return true;
    } catch (e) {
      // print('Error updating inspection request: $e'); // Removed print
      return false;
    }
  }

  Future<List<String>> uploadInspectionImages(String requestId, List<File> images) async {
    try {
      final imageUrls = await _storageService.uploadFiles(
        bucketName: _bucketName,
        path: 'inspections/$requestId',
        files: images,
      );
      return imageUrls;
    } catch (e) {
      // print('Error uploading inspection images: $e'); // Removed print
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
      // Update the original request status
      await updateInspectionStatus(inspectionRequestId, InspectionStatus.reportUploaded);
      
      final reportDataMap = {
        'inspectionRequestId': inspectionRequestId,
        'agentId': agentId,
        'inspectionDate': Timestamp.now(),
        'itemCondition': itemCondition,
        'itemMatchesDescription': itemMatchesDescription,
        'images': images,
        'comments': comments,
        'additionalDetails': additionalDetails,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      final docRef = await _firestore.collection('inspectionReports').add(reportDataMap);
      
      // Fetch the created report to return the full object
      final reportDoc = await docRef.get();
      return InspectionReport.fromMap(reportDoc.data()!, reportDoc.id);

    } catch (e) {
      // print('Error creating inspection report: $e'); // Removed print
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
      // print('Error getting inspection report: $e'); // Removed print
      return null;
    }
  }

  Future<bool> cancelInspectionRequest(String requestId) async {
    try {
      await updateInspectionStatus(requestId, InspectionStatus.cancelled);
      return true;
    } catch (e) {
      // print('Error cancelling inspection request: $e'); // Removed print
      return false;
    }
  }

  // Method to get all inspection requests (potentially for admin)
  Future<List<InspectionRequest>> getAllInspectionRequests() async {
    try {
      final snapshot = await _firestore.collection('inspectionRequests').orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => InspectionRequest.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      // print('Error getting all inspection requests: $e'); // Removed print
      return [];
    }
  }

  // Method to update only the status of an inspection request
  Future<bool> updateInspectionStatus(String requestId, InspectionStatus status) async {
    try {
      await _firestore.collection('inspectionRequests').doc(requestId).update({
        'status': status.index,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      // print('Error updating inspection status: $e'); // Removed print
      return false;
    }
  }

  // Method to assign an agent to an inspection request
  Future<bool> assignAgentToInspection(String requestId, String agentId) async {
    try {
      await _firestore.collection('inspectionRequests').doc(requestId).update({
        'agentId': agentId,
        'status': InspectionStatus.scheduled.index, // Update status when assigning agent
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      // print('Error assigning agent to inspection: $e'); // Removed print
      return false;
    }
  }
}
