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
  
  /// Alias for toJson() for compatibility
  Map<String, dynamic> toMap() => toJson();

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