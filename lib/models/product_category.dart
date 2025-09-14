class ProductCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int color; // Added color property
  final bool isActive;
  final int sortOrder;
  final List<ProductSubCategory> subCategories;

  ProductCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.color = 0xFF9E9E9E, // Default gray color
    this.isActive = true,
    this.sortOrder = 0,
    this.subCategories = const [],
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconName: json['iconName'] ?? json['icon_name'] ?? 'store',
      color: _parseColor(json['color']),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      sortOrder: json['sortOrder'] ?? json['sort_order'] ?? 0,
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((subCat) => ProductSubCategory.fromJson(subCat))
          .toList() ?? [],
    );
  }

  factory ProductCategory.fromMap(Map<String, dynamic> map) => ProductCategory.fromJson(map);

  static int _parseColor(dynamic colorValue) {
    if (colorValue is int) return colorValue;
    if (colorValue is String) {
      if (colorValue.startsWith('0x')) {
        return int.tryParse(colorValue) ?? 0xFF9E9E9E;
      } else {
        return int.tryParse('0x$colorValue') ?? 0xFF9E9E9E;
      }
    }
    return 0xFF9E9E9E; // Default gray
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'icon_name': iconName, // Snake case for Supabase
      'color': '0x${color.toRadixString(16).toUpperCase()}',
      'isActive': isActive,
      'is_active': isActive, // Snake case for Supabase
      'sortOrder': sortOrder,
      'sort_order': sortOrder, // Snake case for Supabase
      'subCategories': subCategories.map((subCat) => subCat.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() => toJson();
}

class ProductSubCategory {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final int sortOrder;

  ProductSubCategory({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory ProductSubCategory.fromJson(Map<String, dynamic> json) {
    return ProductSubCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  Map<String, dynamic> toMap() => toJson();
}