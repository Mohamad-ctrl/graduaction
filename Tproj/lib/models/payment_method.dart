import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethod {
  final String id;
  final String userId;
  final String cardType;
  final String cardNumber;
  final String cardholderName; // camel-case used by UI
  final String expiryDate;
  final String? cvv;           // new – UI needs it
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethod({
    required this.id,
    this.userId = '',
    required this.cardType,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    this.cvv,
    this.isDefault = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PaymentMethod.fromMap(Map<String, dynamic> map, String id) =>
      PaymentMethod(
        id: id,
        userId: map['userId'] ?? '',
        cardType: map['cardType'] ?? '',
        cardNumber: map['cardNumber'] ?? '',
        cardholderName: map['cardholderName'] ?? '',
        expiryDate: map['expiryDate'] ?? '',
        cvv: map['cvv'],
        isDefault: map['isDefault'] ?? false,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'cardType': cardType,
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'expiryDate': expiryDate,
        'cvv': cvv,
        'isDefault': isDefault,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  PaymentMethod copyWith({
    String? id,
    String? userId,
    String? cardType,
    String? cardNumber,
    String? cardholderName,
    String? expiryDate,
    String? cvv,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardType: cardType ?? this.cardType,
      cardNumber: cardNumber ?? this.cardNumber,
      cardholderName: cardholderName ?? this.cardholderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
