// File: lib/services/inspection_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
// On mobile: dart:io File; on web: storage_client File stub
import 'dart:io' if (dart.library.html) 'package:storage_client/src/file_stub.dart';

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
        'agentId': null,
        'price': null,
      };

      final docRef = await _firestore
          .collection('inspectionRequests')
          .add(requestDataMap);

      return InspectionRequest.fromMap(requestDataMap, docRef.id);
    } catch (_) {
      return null;
    }
  }

  Future<List<InspectionRequest>> getUserInspections(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('inspectionRequests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((d) => InspectionRequest.fromMap(d.data(), d.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<InspectionRequest>> getUserInspectionRequests(String userId) {
    return _firestore
        .collection('inspectionRequests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => InspectionRequest.fromMap(d.data(), d.id))
            .toList());
  }

  Future<InspectionRequest?> getInspectionRequest(String requestId) async {
    try {
      final doc = await _firestore
          .collection('inspectionRequests')
          .doc(requestId)
          .get();
      return doc.exists
          ? InspectionRequest.fromMap(doc.data()!, doc.id)
          : null;
    } catch (_) {
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
      final ref = _firestore
          .collection('inspectionRequests')
          .doc(requestId);
      final doc = await ref.get();
      if (!doc.exists) return false;

      final updateData = <String, dynamic>{};
      if (itemName != null)          updateData['itemName'] = itemName;
      if (itemDescription != null)   updateData['itemDescription'] = itemDescription;
      if (inspectionDate != null)    updateData['inspectionDate'] = Timestamp.fromDate(inspectionDate);
      if (status != null)            updateData['status'] = status.index;
      if (location != null)          updateData['location'] = location;
      if (sellerContact != null)     updateData['sellerContact'] = sellerContact;
      if (images != null)            updateData['images'] = images;
      if (notes != null)             updateData['notes'] = notes;

      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = Timestamp.now();
        await ref.update(updateData);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> uploadInspectionImages(
      String requestId, List<File> images) async {
    try {
      final urls = await _storageService.uploadFiles(
        bucketName: _bucketName,
        path: 'inspections/$requestId',
        files: images,
      );
      return urls;
    } catch (_) {
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
      await updateInspectionStatus(
          inspectionRequestId, InspectionStatus.reportUploaded);

      final reportData = {
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

      final docRef = await _firestore
          .collection('inspectionReports')
          .add(reportData);
      final doc = await docRef.get();
      return InspectionReport.fromMap(doc.data()!, doc.id);
    } catch (_) {
      return null;
    }
  }

  Future<InspectionReport?> getInspectionReport(String requestId) async {
    try {
      final snap = await _firestore
          .collection('inspectionReports')
          .where('inspectionRequestId', isEqualTo: requestId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return InspectionReport.fromMap(doc.data(), doc.id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> cancelInspectionRequest(String requestId) async {
    return updateInspectionStatus(requestId, InspectionStatus.cancelled);
  }

  Future<List<InspectionRequest>> getAllInspectionRequests() async {
    try {
      final snap = await _firestore
          .collection('inspectionRequests')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((d) => InspectionRequest.fromMap(d.data(), d.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> updateInspectionStatus(
      String requestId, InspectionStatus status) async {
    try {
      await _firestore.collection('inspectionRequests').doc(requestId).update({
        'status': status.index,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> assignAgentToInspection(
      String requestId, String agentId) async {
    try {
      await _firestore.collection('inspectionRequests').doc(requestId).update({
        'agentId': agentId,
        'status': InspectionStatus.scheduled.index,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
