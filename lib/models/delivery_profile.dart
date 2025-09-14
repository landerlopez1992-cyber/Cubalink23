// Removed cloud_firestore import - using Supabase instead

class DeliveryProfile {
  final String id;
  final String userId;
  final String? professionalPhotoUrl;
  final String? vehicleType;
  final String? licensePlate;
  final String? phone;
  final List<String> areasServed;
  final bool isActive;
  final double ratingAverage;
  final int totalRatings;
  final int totalDeliveries;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryProfile({
    required this.id,
    required this.userId,
    this.professionalPhotoUrl,
    this.vehicleType,
    this.licensePlate,
    this.phone,
    this.areasServed = const [],
    this.isActive = true,
    this.ratingAverage = 0.0,
    this.totalRatings = 0,
    this.totalDeliveries = 0,
    this.balance = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryProfile.fromJson(Map<String, dynamic> json) {
    return DeliveryProfile(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      professionalPhotoUrl: json['professional_photo_url'],
      vehicleType: json['vehicle_type'],
      licensePlate: json['license_plate'],
      phone: json['phone'],
      areasServed: json['areas_served'] != null 
          ? List<String>.from(json['areas_served']) 
          : [],
      isActive: json['is_active'] ?? true,
      ratingAverage: (json['rating_average'] ?? 0.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      totalDeliveries: json['total_deliveries'] ?? 0,
      balance: (json['balance'] ?? 0.0).toDouble(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'professional_photo_url': professionalPhotoUrl,
      'vehicle_type': vehicleType,
      'license_plate': licensePlate,
      'phone': phone,
      'areas_served': areasServed,
      'is_active': isActive,
      'rating_average': ratingAverage,
      'total_ratings': totalRatings,
      'total_deliveries': totalDeliveries,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DeliveryProfile copyWith({
    String? id,
    String? userId,
    String? professionalPhotoUrl,
    String? vehicleType,
    String? licensePlate,
    String? phone,
    List<String>? areasServed,
    bool? isActive,
    double? ratingAverage,
    int? totalRatings,
    int? totalDeliveries,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      professionalPhotoUrl: professionalPhotoUrl ?? this.professionalPhotoUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      licensePlate: licensePlate ?? this.licensePlate,
      phone: phone ?? this.phone,
      areasServed: areasServed ?? this.areasServed,
      isActive: isActive ?? this.isActive,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      totalRatings: totalRatings ?? this.totalRatings,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters útiles
  bool get hasPhoto => professionalPhotoUrl != null && professionalPhotoUrl!.isNotEmpty;
  bool get hasVehicle => vehicleType != null && vehicleType!.isNotEmpty;
  bool get hasLicensePlate => licensePlate != null && licensePlate!.isNotEmpty;
  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasAreas => areasServed.isNotEmpty;
  bool get hasBalance => balance > 0;
  bool get hasDeliveries => totalDeliveries > 0;
  bool get hasRatings => totalRatings > 0;
  
  String get displayName => 'Repartidor';
  String get ratingText => ratingAverage > 0 ? ratingAverage.toStringAsFixed(1) : 'Sin calificaciones';
  String get deliveriesText => totalDeliveries > 0 ? '$totalDeliveries entregas' : 'Sin entregas';
  String get balanceText => '\$${balance.toStringAsFixed(2)}';
  String get areasText => areasServed.isNotEmpty ? areasServed.join(', ') : 'Sin áreas asignadas';
  String get statusText => isActive ? 'Activo' : 'Inactivo';
  String get vehicleText => vehicleType != null ? vehicleType! : 'Sin vehículo';

  @override
  String toString() {
    return 'DeliveryProfile(id: $id, userId: $userId, isActive: $isActive, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
