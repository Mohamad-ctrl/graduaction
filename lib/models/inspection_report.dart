// File: lib/models/inspection_report.dart
class InspectionReport {
  final String id;
  final String inspectionRequestId;
  final String agentId;
  final DateTime inspectionDate;
  final String itemCondition;
  final bool itemMatchesDescription;
  final List<String> images;
  final String comments;
  final Map<String, dynamic> additionalDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  InspectionReport({
    required this.id,
    required this.inspectionRequestId,
    required this.agentId,
    required this.inspectionDate,
    required this.itemCondition,
    required this.itemMatchesDescription,
    required this.images,
    required this.comments,
    required this.additionalDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create an InspectionReport from a map (e.g., from Firestore)
  factory InspectionReport.fromMap(Map<String, dynamic> map, String id) {
    return InspectionReport(
      id: id,
      inspectionRequestId: map['inspectionRequestId'] ?? '',
      agentId: map['agentId'] ?? '',
      inspectionDate: map['inspectionDate']?.toDate() ?? DateTime.now(),
      itemCondition: map['itemCondition'] ?? '',
      itemMatchesDescription: map['itemMatchesDescription'] ?? false,
      images: List<String>.from(map['images'] ?? []),
      comments: map['comments'] ?? '',
      additionalDetails: Map<String, dynamic>.from(map['additionalDetails'] ?? {}),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert InspectionReport to a map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'inspectionRequestId': inspectionRequestId,
      'agentId': agentId,
      'inspectionDate': inspectionDate,
      'itemCondition': itemCondition,
      'itemMatchesDescription': itemMatchesDescription,
      'images': images,
      'comments': comments,
      'additionalDetails': additionalDetails,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a copy of InspectionReport with some fields updated
  InspectionReport copyWith({
    String? id, // Added id parameter
    String? itemCondition,
    bool? itemMatchesDescription,
    List<String>? images,
    String? comments,
    Map<String, dynamic>? additionalDetails,
    DateTime? updatedAt,
  }) {
    return InspectionReport(
      id: id ?? this.id, // Use provided id or current id
      inspectionRequestId: this.inspectionRequestId,
      agentId: this.agentId,
      inspectionDate: this.inspectionDate,
      itemCondition: itemCondition ?? this.itemCondition,
      itemMatchesDescription: itemMatchesDescription ?? this.itemMatchesDescription,
      images: images ?? this.images,
      comments: comments ?? this.comments,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
