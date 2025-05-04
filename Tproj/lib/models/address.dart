class Address {
  final String id;
  final String userId;
  final String name;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? phone;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.phone,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// aliases expected by several UI widgets
  String get street => addressLine1;
  String get zip    => postalCode;

  factory Address.fromMap(Map<String, dynamic> map, String id) => Address(
        id: id,
        userId: map['userId'] ?? '',
        name: map['name'] ?? '',
        addressLine1: map['addressLine1'] ?? '',
        addressLine2: map['addressLine2'],
        city: map['city'] ?? '',
        state: map['state'] ?? '',
        country: map['country'] ?? '',
        postalCode: map['postalCode'] ?? '',
        phone: map['phone'],
        isDefault: map['isDefault'] ?? false,
        createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
        updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'phone': phone,
        'isDefault': isDefault,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  Address copyWith({
    String? id,
    String? userId,
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? phone,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
