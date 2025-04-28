enum InspectionStatus {
  pending,
  approved,
  rejected,
  completed
}

class InspectionRequest {
  final String id;
  final String userId;
  final String vehicleId;
  final InspectionStatus status;
  final DateTime requestedDate;
  final DateTime? scheduledDate;
  final String? inspectorId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InspectionRequest({
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

  factory InspectionRequest.fromMap(Map<String, dynamic> map, String id) {
    return InspectionRequest(
      id: id,
      userId: map['userId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      status: InspectionStatus.values[map['status'] ?? 0],
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

  InspectionRequest copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    InspectionStatus? status,
    DateTime? requestedDate,
    DateTime? scheduledDate,
    String? inspectorId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InspectionRequest(
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