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

  InspectionReport copyWith({
    String? id,
    String? inspectionRequestId,
    String? agentId,
    DateTime? inspectionDate,
    String? itemCondition,
    bool? itemMatchesDescription,
    List<String>? images,
    String? comments,
    Map<String, dynamic>? additionalDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InspectionReport(
      id: id ?? this.id,
      inspectionRequestId: inspectionRequestId ?? this.inspectionRequestId,
      agentId: agentId ?? this.agentId,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      itemCondition: itemCondition ?? this.itemCondition,
      itemMatchesDescription: itemMatchesDescription ?? this.itemMatchesDescription,
      images: images ?? this.images,
      comments: comments ?? this.comments,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum InspectionReportStatus {
  pending,
  approved,
  rejected,
  completed
}

class InspectionReportRequest {
  final String id;
  final String userId;
  final String vehicleId;
  final InspectionReportStatus status;
  final DateTime requestedDate;
  final DateTime? scheduledDate;
  final String? inspectorId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InspectionReportRequest({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.status,
    required this.requestedDate,
    this.scheduledDate,
    this.inspectorId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InspectionReportRequest.fromMap(Map<String, dynamic> map, String id) {
    return InspectionReportRequest(
      id: id,
      userId: map['userId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      status: InspectionReportStatus.values[map['status'] ?? 0],
      requestedDate: map['requestedDate']?.toDate() ?? DateTime.now(),
      scheduledDate: map['scheduledDate']?.toDate(),
      inspectorId: map['inspectorId'],
      notes: map['notes'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'status': status.index,
      'requestedDate': requestedDate,
      'scheduledDate': scheduledDate,
      'inspectorId': inspectorId,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  InspectionReportRequest copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    InspectionReportStatus? status,
    DateTime? requestedDate,
    DateTime? scheduledDate,
    String? inspectorId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InspectionReportRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      status: status ?? this.status,
      requestedDate: requestedDate ?? this.requestedDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      inspectorId: inspectorId ?? this.inspectorId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
