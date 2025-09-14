// Removed cloud_firestore import - using Supabase instead

class VendorProfile {
  final String id;
  final String userId;
  final String companyName;
  final String? companyDescription;
  final String? companyLogoUrl;
  final String? storeCoverUrl;
  final String? businessAddress;
  final String? businessPhone;
  final String? businessEmail;
  final List<String> categories;
  final bool isVerified;
  final double ratingAverage;
  final int totalRatings;
  final int totalSales;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorProfile({
    required this.id,
    required this.userId,
    required this.companyName,
    this.companyDescription,
    this.companyLogoUrl,
    this.storeCoverUrl,
    this.businessAddress,
    this.businessPhone,
    this.businessEmail,
    this.categories = const [],
    this.isVerified = false,
    this.ratingAverage = 0.0,
    this.totalRatings = 0,
    this.totalSales = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) {
    return VendorProfile(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      companyName: json['company_name'] ?? '',
      companyDescription: json['company_description'],
      companyLogoUrl: json['company_logo_url'],
      storeCoverUrl: json['store_cover_url'],
      businessAddress: json['business_address'],
      businessPhone: json['business_phone'],
      businessEmail: json['business_email'],
      categories: json['categories'] != null 
          ? List<String>.from(json['categories']) 
          : [],
      isVerified: json['is_verified'] ?? false,
      ratingAverage: (json['rating_average'] ?? 0.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      totalSales: json['total_sales'] ?? 0,
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
      'company_name': companyName,
      'company_description': companyDescription,
      'company_logo_url': companyLogoUrl,
      'store_cover_url': storeCoverUrl,
      'business_address': businessAddress,
      'business_phone': businessPhone,
      'business_email': businessEmail,
      'categories': categories,
      'is_verified': isVerified,
      'rating_average': ratingAverage,
      'total_ratings': totalRatings,
      'total_sales': totalSales,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  VendorProfile copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? companyDescription,
    String? companyLogoUrl,
    String? storeCoverUrl,
    String? businessAddress,
    String? businessPhone,
    String? businessEmail,
    List<String>? categories,
    bool? isVerified,
    double? ratingAverage,
    int? totalRatings,
    int? totalSales,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      companyDescription: companyDescription ?? this.companyDescription,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      storeCoverUrl: storeCoverUrl ?? this.storeCoverUrl,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      categories: categories ?? this.categories,
      isVerified: isVerified ?? this.isVerified,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      totalRatings: totalRatings ?? this.totalRatings,
      totalSales: totalSales ?? this.totalSales,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters útiles
  bool get hasLogo => companyLogoUrl != null && companyLogoUrl!.isNotEmpty;
  bool get hasCover => storeCoverUrl != null && storeCoverUrl!.isNotEmpty;
  bool get hasDescription => companyDescription != null && companyDescription!.isNotEmpty;
  bool get hasContactInfo => businessPhone != null || businessEmail != null;
  bool get hasAddress => businessAddress != null && businessAddress!.isNotEmpty;
  
  String get displayName => companyName;
  String get ratingText => ratingAverage > 0 ? ratingAverage.toStringAsFixed(1) : 'Sin calificaciones';
  String get salesText => totalSales > 0 ? '$totalSales ventas' : 'Sin ventas';
  String get categoriesText => categories.isNotEmpty ? categories.join(', ') : 'Sin categorías';

  @override
  String toString() {
    return 'VendorProfile(id: $id, companyName: $companyName, isVerified: $isVerified, rating: $ratingAverage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
