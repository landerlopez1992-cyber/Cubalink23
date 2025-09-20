class WalmartProduct {
  final String productId;
  final String title;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? currency;
  final double? rating;
  final int? reviewCount;
  final List<String> images;
  final String? weight;
  final double? weightKg; // Peso numérico en kilogramos
  final Map<String, dynamic>? dimensions;
  final String? category;
  final bool isAvailable;
  final String? brand;
  final List<String>? features;
  final String? color;
  final String? size;
  final String vendor; // Siempre será "Walmart"
  final String vendorLogo;

  WalmartProduct({
    required this.productId,
    required this.title,
    this.description,
    required this.price,
    this.originalPrice,
    this.currency = 'USD',
    this.rating,
    this.reviewCount,
    required this.images,
    this.weight,
    this.weightKg,
    this.dimensions,
    this.category,
    this.isAvailable = true,
    this.brand,
    this.features,
    this.color,
    this.size,
    this.vendor = 'Walmart',
    this.vendorLogo = 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Walmart_logo.svg/200px-Walmart_logo.svg.png',
  });

  factory WalmartProduct.fromJson(Map<String, dynamic> json) {
    // Manejo seguro de precios
    double parsePrice(dynamic priceValue) {
      if (priceValue == null) return 0.0;
      if (priceValue is double) return priceValue;
      if (priceValue is int) return priceValue.toDouble();
      if (priceValue is String) {
        // Remover símbolos de moneda y parsear
        String cleanPrice = priceValue.replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(cleanPrice) ?? 0.0;
      }
      return 0.0;
    }

    // Manejo seguro de imágenes
    List<String> parseImages(dynamic imageValue) {
      if (imageValue == null) return [];
      if (imageValue is List) {
        return imageValue.map((img) => img.toString()).toList();
      }
      if (imageValue is String) {
        return [imageValue];
      }
      return [];
    }

    // Manejo seguro de features/características
    List<String> parseFeatures(dynamic featuresValue) {
      if (featuresValue == null) return [];
      if (featuresValue is List) {
        return featuresValue.map((feature) => feature.toString()).toList();
      }
      return [];
    }

    // Manejo seguro de dimensiones y peso
    Map<String, dynamic>? parseDimensions(dynamic dimValue) {
      if (dimValue is Map<String, dynamic>) return dimValue;
      return null;
    }
    
    // Manejo seguro de peso numérico
    double? parseWeightKg(dynamic weightValue) {
      if (weightValue == null) return null;
      if (weightValue is double) return weightValue;
      if (weightValue is int) return weightValue.toDouble();
      if (weightValue is String) {
        // Extraer número del peso (ej: "1.5 kg" -> 1.5)
        String cleanWeight = weightValue.toLowerCase()
            .replaceAll('kg', '')
            .replaceAll('g', '')
            .replaceAll(',', '.')
            .trim();
        double? weight = double.tryParse(cleanWeight);
        if (weight != null) {
          // Si el peso original contenía "g" (gramos), convertir a kg
          if (weightValue.toLowerCase().contains('g') && !weightValue.toLowerCase().contains('kg')) {
            return weight / 1000; // Convertir gramos a kilogramos
          }
          return weight;
        }
      }
      return null;
    }

    return WalmartProduct(
      productId: json['product_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['product_title']?.toString() ?? json['title']?.toString() ?? 'Producto sin título',
      description: json['product_description']?.toString() ?? json['description']?.toString(),
      price: parsePrice(json['product_price'] ?? json['price']),
      originalPrice: parsePrice(json['product_original_price'] ?? json['original_price']),
      currency: json['currency']?.toString() ?? 'USD',
      rating: json['product_star_rating'] != null ? double.tryParse(json['product_star_rating'].toString()) : 
              json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      reviewCount: json['product_num_ratings'] != null ? int.tryParse(json['product_num_ratings'].toString()) : 
                   json['review_count'] != null ? int.tryParse(json['review_count'].toString()) : null,
      images: parseImages(json['product_photo'] ?? json['images'] ?? json['image']),
      weight: json['weight']?.toString(),
      weightKg: parseWeightKg(json['weight']),
      dimensions: parseDimensions(json['dimensions']),
      category: json['category']?.toString() ?? json['product_category']?.toString(),
      isAvailable: json['is_available'] ?? json['in_stock'] ?? true,
      brand: json['brand']?.toString() ?? json['product_brand']?.toString(),
      features: parseFeatures(json['features']),
      color: json['color']?.toString(),
      size: json['size']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'title': title,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'currency': currency,
      'rating': rating,
      'review_count': reviewCount,
      'images': images,
      'weight': weight,
      'weight_kg': weightKg,
      'dimensions': dimensions,
      'category': category,
      'is_available': isAvailable,
      'brand': brand,
      'features': features,
      'color': color,
      'size': size,
      'vendor': vendor,
      'vendor_logo': vendorLogo,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  // Getter para obtener la imagen principal
  String get mainImage {
    return images.isNotEmpty ? images.first : 'https://via.placeholder.com/300x300/E0E0E0/666666?text=Walmart';
  }

  // Getter para verificar si tiene descuento
  bool get hasDiscount {
    return originalPrice != null && originalPrice! > price;
  }

  // Getters de compatibilidad para walmart_shopping_screen.dart
  String get id => productId;
  String get imageUrl => mainImage;
  int get reviewsCount => reviewCount ?? 0;
  String get url => 'https://www.walmart.com/ip/$productId';

  // Getter para calcular el porcentaje de descuento
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  // Getter para formato de precio
  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Getter para formato de precio original
  String? get formattedOriginalPrice {
    if (originalPrice == null) return null;
    return '\$${originalPrice!.toStringAsFixed(2)}';
  }

  // Getter para rating con estrellas
  String get starsDisplay {
    if (rating == null) return '☆☆☆☆☆';
    int fullStars = rating!.floor();
    bool hasHalfStar = (rating! - fullStars) >= 0.5;
    
    String stars = '★' * fullStars;
    if (hasHalfStar) stars += '☆';
    stars += '☆' * (5 - fullStars - (hasHalfStar ? 1 : 0));
    
    return stars;
  }

  // Getter para peso formateado
  String get formattedWeight {
    if (weight == null || weight!.isEmpty) return 'Peso no especificado';
    return weight!;
  }

  // Método para obtener porcentaje de descuento (compatibilidad)
  double getDiscountPercentage() {
    return discountPercentage;
  }

  // Método para obtener peso estimado en kg (compatibilidad)
  double? getEstimatedWeightKg() {
    return weightKg;
  }

  // Métodos de compatibilidad para walmart_shopping_screen.dart
  String getFormattedPrice() => formattedPrice;
  String? getFormattedOriginalPrice() => formattedOriginalPrice;

  // Método para verificar si el producto es válido
  bool get isValid {
    return productId.isNotEmpty && title.isNotEmpty && price > 0;
  }

  @override
  String toString() {
    return 'WalmartProduct(productId: $productId, title: $title, price: $price, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalmartProduct && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}