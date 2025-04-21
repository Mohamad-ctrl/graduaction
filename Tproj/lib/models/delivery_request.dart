// File: lib/models/delivery_request.dart
enum DeliveryStatus {
  pending,
  itemPickedUp,
  shipped,
  outForDelivery,
  delivered,
  cancelled
}

class DeliveryRequest {
  final String id;
  final String userId;
  final String? inspectionRequestId;
  final String itemName;
  final String itemDescription;
  final DateTime requestDate;
  final DateTime estimatedDeliveryDate;
  final String? deliveryAgentId;
  final DeliveryStatus status;
  final String pickupLocation;
  final String deliveryLocation;
  final double price;
  final String? trackingNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryRequest({
    required this.id,
    required this.userId,
    this.inspectionRequestId,
    required this.itemName,
    required this.itemDescription,
    required this.requestDate,
    required this.estimatedDeliveryDate,
    this.deliveryAgentId,
    required this.status,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.price,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a DeliveryRequest from a map (e.g., from Firestore)
  factory DeliveryRequest.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryRequest(
      id: id,
      userId: map['userId'] ?? '',
      inspectionRequestId: map['inspectionRequestId'],
      itemName: map['itemName'] ?? '',
      itemDescription: map['itemDescription'] ?? '',
      requestDate: map['requestDate']?.toDate() ?? DateTime.now(),
      estimatedDeliveryDate: map['estimatedDeliveryDate']?.toDate() ?? DateTime.now(),
      deliveryAgentId: map['deliveryAgentId'],
      status: DeliveryStatus.values[map['status'] ?? 0],
      pickupLocation: map['pickupLocation'] ?? '',
      deliveryLocation: map['deliveryLocation'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      trackingNumber: map['trackingNumber'],
      notes: map['notes'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert DeliveryRequest to a map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'inspectionRequestId': inspectionRequestId,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'requestDate': requestDate,
      'estimatedDeliveryDate': estimatedDeliveryDate,
      'deliveryAgentId': deliveryAgentId,
      'status': status.index,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'price': price,
      'trackingNumber': trackingNumber,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a copy of DeliveryRequest with some fields updated
  DeliveryRequest copyWith({
    String? itemName,
    String? itemDescription,
    DateTime? estimatedDeliveryDate,
    String? deliveryAgentId,
    DeliveryStatus? status,
    String? pickupLocation,
    String? deliveryLocation,
    double? price,
    String? trackingNumber,
    String? notes,
    DateTime? updatedAt,
  }) {
    return DeliveryRequest(
      id: this.id,
      userId: this.userId,
      inspectionRequestId: this.inspectionRequestId,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      requestDate: this.requestDate,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      deliveryAgentId: deliveryAgentId ?? this.deliveryAgentId,
      status: status ?? this.status,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      price: price ?? this.price,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
