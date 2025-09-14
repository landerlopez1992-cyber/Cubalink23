// Removed cloud_firestore import - using Supabase instead

class VendorRating {
  final String id;
  final String vendorId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorRating({
    required this.id,
    required this.vendorId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorRating.fromJson(Map<String, dynamic> json) {
    return VendorRating(
      id: json['id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      userId: json['user_id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
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
      'vendor_id': vendorId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  VendorRating copyWith({
    String? id,
    String? vendorId,
    String? userId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorRating(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters útiles
  bool get hasComment => comment != null && comment!.isNotEmpty;
  String get ratingText => '$rating/5';
  String get starsText => '⭐' * rating;
  bool get isHighRating => rating >= 4;
  bool get isLowRating => rating <= 2;

  @override
  String toString() {
    return 'VendorRating(id: $id, rating: $rating, hasComment: $hasComment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorRating && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
