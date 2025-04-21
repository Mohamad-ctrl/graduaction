// File: lib/models/inspection_request.dart
enum InspectionStatus {
  pending,
  scheduled,
  inProgress,
  completed,
  reportUploaded,
  cancelled
}

class InspectionRequest {
  final String id;
  final String userId;
  final String itemName;
  final String itemDescription;
  final DateTime requestDate;
  final DateTime inspectionDate;
  final String? agentId;
  final InspectionStatus status;
  final String? location;
  final double? price;
  final String? sellerContact;
  final List<String>? images;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InspectionRequest({
    required this.id,
    required this.userId,
    required this.itemName,
    required this.itemDescription,
    required this.requestDate,
    required this.inspectionDate,
    this.agentId,
    required this.status,
    this.location,
    this.price,
    this.sellerContact,
    this.images,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create an InspectionRequest from a map (e.g., from Firestore)
  factory InspectionRequest.fromMap(Map<String, dynamic> map, String id) {
    return InspectionRequest(
      id: id,
      userId: map['userId'] ?? '',
      itemName: map['itemName'] ?? '',
      itemDescription: map['itemDescription'] ?? '',
      requestDate: map['requestDate']?.toDate() ?? DateTime.now(),
      inspectionDate: map['inspectionDate']?.toDate() ?? DateTime.now(),
      agentId: map['agentId'],
      status: InspectionStatus.values[map['status'] ?? 0],
      location: map['location'],
      price: map['price']?.toDouble(),
      sellerContact: map['sellerContact'],
      images: map['images'] != null ? List<String>.from(map['images']) : null,
      notes: map['notes'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert InspectionRequest to a map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'requestDate': requestDate,
      'inspectionDate': inspectionDate,
      'agentId': agentId,
      'status': status.index,
      'location': location,
      'price': price,
      'sellerContact': sellerContact,
      'images': images,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a copy of InspectionRequest with some fields updated
  InspectionRequest copyWith({
    String? itemName,
    String? itemDescription,
    DateTime? inspectionDate,
    String? agentId,
    InspectionStatus? status,
    String? location,
    double? price,
    String? sellerContact,
    List<String>? images,
    String? notes,
    DateTime? updatedAt,
  }) {
    return InspectionRequest(
      id: this.id,
      userId: this.userId,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      requestDate: this.requestDate,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      agentId: agentId ?? this.agentId,
      status: status ?? this.status,
      location: location ?? this.location,
      price: price ?? this.price,
      sellerContact: sellerContact ?? this.sellerContact,
      images: images ?? this.images,
      notes: notes ?? this.notes,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
