import 'package:cloud_firestore/cloud_firestore.dart';

class Agent {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String type; // 'inspector' or 'delivery'
  final bool isActive;
  final GeoPoint location;
  final double rating;
  final int completedJobs;
  final DateTime createdAt;
  final DateTime updatedAt;

  Agent({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    required this.isActive,
    required this.location,
    required this.rating,
    required this.completedJobs,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Agent.fromMap(Map<String, dynamic> map, String id) {
    return Agent(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      type: map['type'] ?? 'inspector',
      isActive: map['isActive'] ?? false,
      location: map['location'] ?? const GeoPoint(0, 0),
      rating: (map['rating'] ?? 0.0).toDouble(),
      completedJobs: map['completedJobs'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'type': type,
      'isActive': isActive,
      'location': location,
      'rating': rating,
      'completedJobs': completedJobs,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Agent copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? type,
    bool? isActive,
    GeoPoint? location,
    double? rating,
    int? completedJobs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
