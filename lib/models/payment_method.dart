// File: lib/models/payment_method.dart
enum PaymentMethodType {
  creditCard,
  debitCard,
  bankTransfer,
  wallet
}

class PaymentMethod {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String name;
  final String? cardNumber; // Last 4 digits only for security
  final String? cardHolderName;
  final String? expiryDate;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a PaymentMethod from a map (e.g., from Firestore)
  factory PaymentMethod.fromMap(Map<String, dynamic> map, String id) {
    return PaymentMethod(
      id: id,
      userId: map['userId'] ?? '',
      type: PaymentMethodType.values[map['type'] ?? 0],
      name: map['name'] ?? '',
      cardNumber: map['cardNumber'],
      cardHolderName: map['cardHolderName'],
      expiryDate: map['expiryDate'],
      isDefault: map['isDefault'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert PaymentMethod to a map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.index,
      'name': name,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'isDefault': isDefault,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a copy of PaymentMethod with some fields updated
  PaymentMethod copyWith({
    PaymentMethodType? type,
    String? name,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    bool? isDefault,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: this.id,
      userId: this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      isDefault: isDefault ?? this.isDefault,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
