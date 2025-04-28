class PaymentMethod {
  final String id;
  final String userId;
  final String cardType;  // Changed from PaymentMethodType to match profile_screen.dart usage
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.cardType,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map, String id) {
    return PaymentMethod(
      id: id,
      userId: map['userId'] ?? '',
      cardType: map['cardType'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      cardHolderName: map['cardHolderName'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      isDefault: map['isDefault'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cardType': cardType,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'isDefault': isDefault,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PaymentMethod copyWith({
    String? id,
    String? userId,
    String? cardType,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardType: cardType ?? this.cardType,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
