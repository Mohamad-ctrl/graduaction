class User {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final List<String> addresses;
  final List<String> paymentMethods;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    this.addresses = const [],
    this.paymentMethods = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // UI (admin dashboard) expects .name
  String get name => username;

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      addresses: List<String>.from(map['addresses'] ?? []),
      paymentMethods: List<String>.from(map['paymentMethods'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'profileImageUrl': profileImageUrl,
        'addresses': addresses,
        'paymentMethods': paymentMethods,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  User copyWith({
    String? username,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    List<String>? addresses,
    List<String>? paymentMethods,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
