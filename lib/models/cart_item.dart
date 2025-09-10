class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;
  final String type; // 'amazon', 'recharge', etc.
  final String? description;
  final dynamic weight; // Puede ser double (peso real) o String (peso con texto/desconocido)
  final String? category;
  final Map<String, dynamic>? additionalData;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.type,
    this.description,
    this.weight,
    this.category,
    this.additionalData,
  });

  // Getter para obtener vendorId basado en el tipo o additionalData
  String? get vendorId {
    // Primero intentar obtenerlo de additionalData
    if (additionalData != null && additionalData!['vendorId'] != null) {
      return additionalData!['vendorId'] as String;
    }
    
    // Si no está en additionalData, usar el tipo como vendorId
    return type;
  }

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
    String? type,
    String? description,
    dynamic weight,
    String? category,
    Map<String, dynamic>? additionalData,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      category: category ?? this.category,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'type': type,
      'description': description,
      'weight': weight,
      'category': category,
      'additionalData': additionalData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      quantity: json['quantity'] ?? 1,
      type: json['type'] ?? 'unknown',
      description: json['description'],
      weight: json['weight'], // Mantener como dynamic
      category: json['category'],
      additionalData: json['additionalData'],
    );
  }
}