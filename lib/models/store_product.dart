import 'dart:convert';

class StoreProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final String? subCategoryId;
  final String unit; // lb, kg, unidad, etc.
  final double weight; // peso en kg
  final bool isAvailable;
  final int stock;
  final List<String> availableProvinces; // Provincias donde se puede entregar
  final String deliveryMethod; // 'express' o 'barco'
  final Map<String, dynamic> additionalData;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StoreProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    this.subCategoryId,
    required this.unit,
    required this.weight,
    this.isAvailable = true,
    this.stock = 0,
    this.availableProvinces = const [],
    this.deliveryMethod = 'express',
    this.additionalData = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: _parseFirstImage(json['imageUrl'] ?? json['image_url'] ?? json['images']),
      categoryId: json['categoryId'] ?? json['category_id'] ?? json['category'] ?? '',
      subCategoryId: json['subCategoryId'] ?? json['subcategory_id'] ?? json['sub_category_id'] ?? json['subcategory'],
      unit: json['unit'] ?? 'unidad',
      weight: (json['weight'] ?? 0.0).toDouble(),
      isAvailable: json['isAvailable'] ?? json['is_active'] ?? json['is_available'] ?? true,
      stock: json['stock'] ?? 0,
      availableProvinces: _parseProvinces(json['availableProvinces'] ?? json['available_provinces']),
      deliveryMethod: _parseDeliveryMethod(json['deliveryMethod'] ?? json['delivery_method'] ?? json['metadata']),
      additionalData: _combineAdditionalData(json),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  factory StoreProduct.fromMap(Map<String, dynamic> map) => StoreProduct.fromJson(map);

  static List<String> _parseProvinces(dynamic provincesData) {
    if (provincesData == null) return [];
    if (provincesData is List) return List<String>.from(provincesData);
    if (provincesData is String) {
      try {
        // Try to parse as JSON array
        final decoded = jsonDecode(provincesData);
        if (decoded is List) return List<String>.from(decoded);
      } catch (_) {
        // If parsing fails, treat as single province
        return [provincesData];
      }
    }
    return [];
  }

  static Map<String, dynamic> _parseAdditionalData(dynamic additionalData) {
    if (additionalData == null) return {};
    if (additionalData is Map<String, dynamic>) return additionalData;
    if (additionalData is String) {
      try {
        final decoded = jsonDecode(additionalData);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }

  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;
    if (dateTime is DateTime) return dateTime;
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (_) {}
    }
    return null;
  }

  static String _parseFirstImage(dynamic imageData) {
    if (imageData == null) return '';
    if (imageData is String && imageData.isNotEmpty) return imageData;
    if (imageData is List && imageData.isNotEmpty) {
      return imageData.first.toString();
    }
    return '';
  }

  static String _parseDeliveryMethod(dynamic deliveryData) {
    if (deliveryData is String) return deliveryData;
    if (deliveryData is Map && deliveryData['delivery_method'] is String) {
      return deliveryData['delivery_method'];
    }
    return 'express';
  }

  static Map<String, dynamic> _combineAdditionalData(Map<String, dynamic> json) {
    final additionalData = _parseAdditionalData(json['additionalData'] ?? json['additional_data'] ?? json['metadata']);
    
    // Agregar datos de las columnas específicas si están disponibles
    if (json['available_sizes'] != null) {
      additionalData['sizes'] = _parseProvinces(json['available_sizes']);
    }
    if (json['available_colors'] != null) {
      additionalData['colors'] = _parseProvinces(json['available_colors']);
    }
    if (json['delivery_cost'] != null) {
      additionalData['deliveryCost'] = (json['delivery_cost'] ?? 0.0).toDouble();
    }
    
    return additionalData;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? null : id, // Don't include empty ID for Supabase inserts
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'image_url': imageUrl, // Snake case for Supabase
      'categoryId': categoryId,
      'category_id': categoryId, // Snake case for Supabase
      'subCategoryId': subCategoryId,
      'sub_category_id': subCategoryId, // Snake case for Supabase
      'unit': unit,
      'weight': weight,
      'isAvailable': isAvailable,
      'is_available': isAvailable, // Snake case for Supabase
      'stock': stock,
      'availableProvinces': availableProvinces,
      'available_provinces': jsonEncode(availableProvinces), // JSON string for Supabase
      'deliveryMethod': deliveryMethod,
      'delivery_method': deliveryMethod, // Snake case for Supabase
      'additionalData': additionalData,
      'additional_data': jsonEncode(additionalData), // JSON string for Supabase
      'createdAt': createdAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(), // Snake case for Supabase
      'updatedAt': updatedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(), // Snake case for Supabase
    };
  }

  Map<String, dynamic> toMap() => toJson();

  // Verificar si el producto se puede entregar en una provincia específica
  bool canDeliverTo(String province) {
    // Si no hay restricciones, se puede entregar a cualquier lado
    if (availableProvinces.isEmpty) return true;
    
    // Verificar si la provincia está en la lista
    return availableProvinces.contains(province);
  }

  StoreProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    String? subCategoryId,
    String? unit,
    double? weight,
    bool? isAvailable,
    int? stock,
    List<String>? availableProvinces,
    String? deliveryMethod,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      unit: unit ?? this.unit,
      weight: weight ?? this.weight,
      isAvailable: isAvailable ?? this.isAvailable,
      stock: stock ?? this.stock,
      availableProvinces: availableProvinces ?? this.availableProvinces,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}