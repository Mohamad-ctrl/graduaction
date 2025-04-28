enum DeliveryStatus {
  pending,
  itemPickedUp, // Added
  shipped,      // Added
  outForDelivery, // Added
  delivered,    // Added
  inProgress,   // Kept existing, might need review if redundant
  completed,    // Kept existing, might need review if redundant
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
  final DeliveryStatus status;
  final String pickupLocation;
  final String deliveryLocation;
  final double price;
  final String? trackingNumber;
  final String? deliveryAgentId;
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
    required this.status,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.price,
    this.trackingNumber,
    this.deliveryAgentId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryRequest.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryRequest(
      id: id,
      userId: map["userId"] ?? "",
      inspectionRequestId: map["inspectionRequestId"],
      itemName: map["itemName"] ?? "",
      itemDescription: map["itemDescription"] ?? "",
      requestDate: map["requestDate"]?.toDate() ?? DateTime.now(),
      estimatedDeliveryDate: map["estimatedDeliveryDate"]?.toDate() ?? DateTime.now(),
      // Ensure status index is within bounds
      status: (map["status"] != null && map["status"] < DeliveryStatus.values.length) 
              ? DeliveryStatus.values[map["status"]]
              : DeliveryStatus.pending, // Default to pending if invalid
      pickupLocation: map["pickupLocation"] ?? "",
      deliveryLocation: map["deliveryLocation"] ?? "",
      price: (map["price"] ?? 0.0).toDouble(),
      trackingNumber: map["trackingNumber"],
      deliveryAgentId: map["deliveryAgentId"],
      notes: map["notes"],
      createdAt: map["createdAt"]?.toDate() ?? DateTime.now(),
      updatedAt: map["updatedAt"]?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "inspectionRequestId": inspectionRequestId,
      "itemName": itemName,
      "itemDescription": itemDescription,
      "requestDate": requestDate,
      "estimatedDeliveryDate": estimatedDeliveryDate,
      "status": status.index,
      "pickupLocation": pickupLocation,
      "deliveryLocation": deliveryLocation,
      "price": price,
      "trackingNumber": trackingNumber,
      "deliveryAgentId": deliveryAgentId,
      "notes": notes,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  DeliveryRequest copyWith({
    String? id,
    String? userId,
    String? inspectionRequestId,
    String? itemName,
    String? itemDescription,
    DateTime? requestDate,
    DateTime? estimatedDeliveryDate,
    DeliveryStatus? status,
    String? pickupLocation,
    String? deliveryLocation,
    double? price,
    String? trackingNumber,
    String? deliveryAgentId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      inspectionRequestId: inspectionRequestId ?? this.inspectionRequestId,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      requestDate: requestDate ?? this.requestDate,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      status: status ?? this.status,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      price: price ?? this.price,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      deliveryAgentId: deliveryAgentId ?? this.deliveryAgentId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
