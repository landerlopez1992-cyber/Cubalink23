class Order {
  final String id;
  final String userId;
  final String orderNumber;
  final List<OrderItem> items;
  final OrderAddress shippingAddress;
  final String shippingMethod;
  final double subtotal;
  final double shippingCost;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? estimatedDelivery;
  final String? zellePaymentProof;
  final Map<String, dynamic>? metadata;

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.items,
    required this.shippingAddress,
    required this.shippingMethod,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
    this.updatedAt,
    this.estimatedDelivery,
    this.zellePaymentProof,
    this.metadata,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      shippingAddress: OrderAddress.fromJson(json['shipping_address'] ?? {}),
      shippingMethod: json['shipping_method'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingCost: (json['shipping_cost'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      orderStatus: json['order_status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      estimatedDelivery: json['estimated_delivery'] != null ? DateTime.tryParse(json['estimated_delivery']) : null,
      zellePaymentProof: json['zelle_payment_proof'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_number': orderNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'shipping_address': shippingAddress.toJson(),
      'shipping_method': shippingMethod,
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'total': total,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
      'zelle_payment_proof': zellePaymentProof,
      'metadata': metadata,
    };
  }
  
  /// Enhanced toMap() for database operations with cart items
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'order_number': orderNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'shipping_address': shippingAddress.toJson(),
      // Campos individuales para shipping address (mejor acceso en DB)
      // 'customer_name': shippingAddress.recipient, // REMOVED - no existe en Supabase
      // 'customer_phone': shippingAddress.phone, // REMOVED - no existe en Supabase
      'shipping_recipient': shippingAddress.recipient,
      'shipping_phone': shippingAddress.phone,
      'shipping_street': shippingAddress.address,
      'shipping_city': shippingAddress.city,
      'shipping_province': shippingAddress.province,
      'shipping_method': shippingMethod,
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'total': total,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
      'zelle_payment_proof': zellePaymentProof,
      'tracking_number': null, // Se puede agregar después
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      // Agregar items del carrito para crear order_items
      'cart_items': items.map((item) => {
        'product_id': item.productId,
        'product_name': item.name,
        'product_price': item.price,
        'quantity': item.quantity,
        'product_type': item.type == 'amazon' ? 'amazon' : 'store',
        'weight_lb': _getItemWeightFromType(item.type, item.category),
        'selected_size': null, // Se puede agregar después
        'selected_color': null, // Se puede agregar después
        'amazon_asin': item.type == 'amazon' ? item.productId : null,
        'amazon_data': item.type == 'amazon' ? {'category': item.category} : null,
      }).toList(),
    };
  }

  // Helper method to get weight from item type
  double _getItemWeightFromType(String? type, String? category) {
    if (type == 'amazon') {
      // Peso estimado basado en categoría de Amazon
      switch (category?.toLowerCase()) {
        case 'electronics': return 2.0;
        case 'books': return 0.5;
        case 'clothing': return 0.3;
        case 'home': return 1.5;
        default: return 1.0;
      }
    }
    return 0.5; // Peso por defecto para productos de tienda
  }

  Order copyWith({
    String? id,
    String? userId,
    String? orderNumber,
    List<OrderItem>? items,
    OrderAddress? shippingAddress,
    String? shippingMethod,
    double? subtotal,
    double? shippingCost,
    double? total,
    String? paymentMethod,
    String? paymentStatus,
    String? orderStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? estimatedDelivery,
    String? zellePaymentProof,
    Map<String, dynamic>? metadata,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      zellePaymentProof: zellePaymentProof ?? this.zellePaymentProof,
      metadata: metadata ?? this.metadata,
    );
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final String category;
  final String type; // 'amazon' or 'recharge'

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.category,
    required this.type,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      category: json['category'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'quantity': quantity,
      'category': category,
      'type': type,
    };
  }

  double get totalPrice => price * quantity;
}

class OrderAddress {
  final String recipient;
  final String phone;
  final String address;
  final String city;
  final String province;

  OrderAddress({
    required this.recipient,
    required this.phone,
    required this.address,
    required this.city,
    required this.province,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      recipient: json['recipient'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipient': recipient,
      'phone': phone,
      'address': address,
      'city': city,
      'province': province,
    };
  }

  String get fullAddress => '$address, $city, $province';
}