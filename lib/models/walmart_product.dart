class WalmartProduct {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final String? imageUrl;
  final List<String> images;
  final double rating;
  final int reviewsCount;
  final String brand;
  final String category;
  final bool inStock;
  final String url;
  final String itemId;
  final String usItemId;
  final String? weight;
  final Map<String, dynamic> additionalInfo;
  final DateTime? lastUpdated;

  WalmartProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    this.images = const [],
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.brand,
    required this.category,
    this.inStock = true,
    required this.url,
    required this.itemId,
    required this.usItemId,
    this.weight,
    this.additionalInfo = const {},
    this.lastUpdated,
  });

  factory WalmartProduct.fromJson(Map<String, dynamic> json) {
    // Handle different response formats from Walmart API
    return WalmartProduct(
      id: json['id']?.toString() ?? json['itemId']?.toString() ?? json['usItemId']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? json['productTitle'] ?? '',
      description: json['description'] ?? json['shortDescription'] ?? json['longDescription'] ?? '',
      price: _parsePrice(json['price']) ?? _parsePrice(json['currentPrice']) ?? _parsePrice(json['salePrice']) ?? 0.0,
      originalPrice: _parsePrice(json['originalPrice']) ?? _parsePrice(json['listPrice']),
      imageUrl: _getMainImage(json),
      images: _parseImages(json),
      rating: _parseDouble(json['rating']) ?? _parseDouble(json['averageRating']) ?? 0.0,
      reviewsCount: _parseInt(json['reviewsCount']) ?? _parseInt(json['numReviews']) ?? 0,
      brand: json['brand'] ?? json['brandName'] ?? json['manufacturer'] ?? 'Unknown',
      category: json['category'] ?? json['categoryPath'] ?? json['categoryTree'] ?? 'General',
      inStock: json['inStock'] ?? json['availabilityStatus'] == 'IN_STOCK' ?? json['stock'] == 'IN_STOCK' ?? true,
      url: json['url'] ?? json['productUrl'] ?? json['canonicalUrl'] ?? '',
      itemId: json['itemId']?.toString() ?? json['id']?.toString() ?? '',
      usItemId: json['usItemId']?.toString() ?? json['upc']?.toString() ?? '',
      weight: json['weight']?.toString() ?? json['shippingWeight']?.toString() ?? _extractWeight(json),
      additionalInfo: _parseAdditionalInfo(json),
      lastUpdated: DateTime.now(),
    );
  }

  static double? _parsePrice(dynamic price) {
    if (price == null) return null;
    if (price is num) return price.toDouble();
    if (price is String) {
      // Remove currency symbols and parse
      final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanPrice);
    }
    if (price is Map) {
      // Handle price objects like {"amount": 29.99, "currency": "USD"}
      final amount = price['amount'] ?? price['value'] ?? price['price'];
      if (amount is num) return amount.toDouble();
      if (amount is String) {
        final cleanPrice = amount.replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(cleanPrice);
      }
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _getMainImage(Map<String, dynamic> json) {
    // Try different image field names
    if (json['imageUrl'] != null) return json['imageUrl'];
    if (json['image'] != null) return json['image'];
    if (json['thumbnailImage'] != null) return json['thumbnailImage'];
    if (json['primaryImage'] != null) return json['primaryImage'];
    
    // Try images arrays
    final images = _parseImages(json);
    if (images.isNotEmpty) return images.first;
    
    return null;
  }

  static List<String> _parseImages(Map<String, dynamic> json) {
    final List<String> imageUrls = [];
    
    // Try different image field names and structures
    final imageFields = ['images', 'imageUrls', 'productImages', 'thumbnails'];
    
    for (final field in imageFields) {
      final imageData = json[field];
      if (imageData is List) {
        for (final item in imageData) {
          if (item is String) {
            imageUrls.add(item);
          } else if (item is Map) {
            // Handle image objects
            final url = item['url'] ?? item['src'] ?? item['link'] ?? item['large'] ?? item['medium'];
            if (url is String) imageUrls.add(url);
          }
        }
      }
    }
    
    // Also check single image fields
    final singleImageFields = ['imageUrl', 'image', 'thumbnailImage', 'primaryImage'];
    for (final field in singleImageFields) {
      final imageUrl = json[field];
      if (imageUrl is String && !imageUrls.contains(imageUrl)) {
        imageUrls.add(imageUrl);
      }
    }
    
    return imageUrls;
  }

  static String? _extractWeight(Map<String, dynamic> json) {
    // Try to extract weight from different fields
    final weightFields = ['weight', 'shippingWeight', 'itemWeight', 'packageWeight', 'dimensions'];
    
    for (final field in weightFields) {
      final value = json[field];
      if (value != null) {
        if (value is String) return value;
        if (value is Map) {
          final weight = value['weight'] ?? value['value'] ?? value['amount'];
          if (weight != null) return weight.toString();
        }
      }
    }
    
    // Try to extract from description or title
    final text = '${json['title'] ?? ''} ${json['description'] ?? ''}';
    final weightRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(lb|lbs|kg|g|oz|ounce|pound)', caseSensitive: false);
    final match = weightRegex.firstMatch(text);
    if (match != null) {
      return '${match.group(1)} ${match.group(2)}';
    }
    
    return null;
  }

  static Map<String, dynamic> _parseAdditionalInfo(Map<String, dynamic> json) {
    final Map<String, dynamic> additionalInfo = {};
    
    // Add relevant fields that might be useful
    final relevantFields = [
      'upc', 'isbn', 'ean', 'gtin', 'modelNumber', 'manufacturerPartNumber',
      'dimensions', 'size', 'color', 'style', 'material', 'features',
      'specifications', 'warranty', 'seller', 'marketplace', 'fulfillment'
    ];
    
    for (final field in relevantFields) {
      if (json[field] != null) {
        additionalInfo[field] = json[field];
      }
    }
    
    return additionalInfo;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'images': images,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'brand': brand,
      'category': category,
      'inStock': inStock,
      'url': url,
      'itemId': itemId,
      'usItemId': usItemId,
      'weight': weight,
      'additionalInfo': additionalInfo,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Calculate estimated weight in kg for shipping
  double getEstimatedWeightKg() {
    if (weight == null) return 0.5; // Default weight if not specified
    
    final weightStr = weight!.toLowerCase();
    final weightRegex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = weightRegex.firstMatch(weightStr);
    
    if (match != null) {
      final value = double.tryParse(match.group(1)!) ?? 0.5;
      
      if (weightStr.contains('kg')) {
        return value;
      } else if (weightStr.contains('lb') || weightStr.contains('pound')) {
        return value * 0.453592; // Convert lbs to kg
      } else if (weightStr.contains('oz') || weightStr.contains('ounce')) {
        return value * 0.0283495; // Convert oz to kg
      } else if (weightStr.contains('g') && !weightStr.contains('kg')) {
        return value / 1000; // Convert g to kg
      }
    }
    
    return 0.5; // Default weight
  }

  // Get discount percentage if available
  double? getDiscountPercentage() {
    if (originalPrice != null && originalPrice! > price && price > 0) {
      return ((originalPrice! - price) / originalPrice!) * 100;
    }
    return null;
  }

  // Check if product has good rating
  bool hasGoodRating() {
    return rating >= 4.0;
  }

  // Format price for display
  String getFormattedPrice() {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Format original price for display
  String? getFormattedOriginalPrice() {
    return originalPrice != null ? '\$${originalPrice!.toStringAsFixed(2)}' : null;
  }

  @override
  String toString() {
    return 'WalmartProduct(id: $id, title: $title, price: $price, brand: $brand)';
  }
}