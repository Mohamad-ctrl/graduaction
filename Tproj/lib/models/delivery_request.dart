enum DeliveryStatus {
  pending,
  inProgress,
  completed,
  cancelled
}

class DeliveryRequest {
  final String id;
  final String userId;
  final String inspectionRequestId;
  final DeliveryStatus status;
  final DateTime deliveryDate;
  final String deliveryAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryRequest({
    required this.id,
    required this.userId,
    required this.inspectionRequestId,
    required this.status,
    required this.deliveryDate,
    required this.deliveryAddress,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryRequest.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryRequest(
      id: id,
      userId: map['userId'] ?? '',
      inspectionRequestId: map['inspectionRequestId'] ?? '',
      status: DeliveryStatus.values[map['status'] ?? 0],
      deliveryDate: map['deliveryDate']?.toDate() ?? DateTime.now(),
      deliveryAddress: map['deliveryAddress'] ?? '',
      notes: map['notes'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'inspectionRequestId': inspectionRequestId,
      'status': status.index,
      'deliveryDate': deliveryDate,
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  DeliveryRequest copyWith({
    String? id,
    String? userId,
    String? inspectionRequestId,
    DeliveryStatus? status,
    DateTime? deliveryDate,
    String? deliveryAddress,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      inspectionRequestId: inspectionRequestId ?? this.inspectionRequestId,
      status: status ?? this.status,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}