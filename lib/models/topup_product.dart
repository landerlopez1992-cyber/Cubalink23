/// Modelo para productos de recarga telefónica de DingConnect
class TopupProduct {
  final String id;
  final String name;
  final String description;
  final double localAmount;
  final String localCurrency;
  final double wholesalePrice;
  final double retailPrice;
  final String currency;
  final String countryIso;
  final String operatorCode;
  final String operatorName;
  final String productType;
  final Map<String, dynamic>? regions;
  final bool isAvailable;

  TopupProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.localAmount,
    required this.localCurrency,
    required this.wholesalePrice,
    required this.retailPrice,
    required this.currency,
    required this.countryIso,
    required this.operatorCode,
    required this.operatorName,
    required this.productType,
    this.regions,
    this.isAvailable = true,
  });

  factory TopupProduct.fromJson(Map<String, dynamic> json) {
    return TopupProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      localAmount: (json['local_amount'] ?? 0).toDouble(),
      localCurrency: json['local_currency'] ?? 'USD',
      wholesalePrice: (json['wholesale_price'] ?? 0).toDouble(),
      retailPrice: (json['retail_price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      countryIso: json['country_iso'] ?? '',
      operatorCode: json['operator_code'] ?? '',
      operatorName: json['operator_name'] ?? '',
      productType: json['product_type'] ?? 'topup',
      regions: json['regions'],
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'local_amount': localAmount,
      'local_currency': localCurrency,
      'wholesale_price': wholesalePrice,
      'retail_price': retailPrice,
      'currency': currency,
      'country_iso': countryIso,
      'operator_code': operatorCode,
      'operator_name': operatorName,
      'product_type': productType,
      'regions': regions,
      'is_available': isAvailable,
    };
  }

  /// Obtener precio formateado para mostrar al usuario
  String get formattedPrice => '\$${retailPrice.toStringAsFixed(2)}';

  /// Obtener monto local formateado
  String get formattedLocalAmount => '$localCurrency ${localAmount.toStringAsFixed(2)}';

  /// Obtener descripción completa del producto
  String get fullDescription => '$operatorName - $name ($formattedLocalAmount)';

  @override
  String toString() {
    return 'TopupProduct{id: $id, name: $name, operatorName: $operatorName, retailPrice: $retailPrice}';
  }
}

/// Modelo para operadores telefónicos
class TopupOperator {
  final String code;
  final String name;
  final String countryIso;
  final String countryName;
  final List<String>? regions;
  final bool isAvailable;

  TopupOperator({
    required this.code,
    required this.name,
    required this.countryIso,
    required this.countryName,
    this.regions,
    this.isAvailable = true,
  });

  factory TopupOperator.fromJson(Map<String, dynamic> json) {
    return TopupOperator(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      countryIso: json['country_iso'] ?? '',
      countryName: json['country_name'] ?? '',
      regions: json['regions']?.cast<String>(),
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'country_iso': countryIso,
      'country_name': countryName,
      'regions': regions,
      'is_available': isAvailable,
    };
  }

  @override
  String toString() {
    return 'TopupOperator{code: $code, name: $name, countryName: $countryName}';
  }
}

/// Modelo para países disponibles
class TopupCountry {
  final String iso;
  final String name;
  final String currencyCode;
  final String currencyName;
  final String flag;
  final List<String>? regions;
  final bool isAvailable;

  TopupCountry({
    required this.iso,
    required this.name,
    required this.currencyCode,
    required this.currencyName,
    required this.flag,
    this.regions,
    this.isAvailable = true,
  });

  factory TopupCountry.fromJson(Map<String, dynamic> json) {
    return TopupCountry(
      iso: json['iso'] ?? '',
      name: json['name'] ?? '',
      currencyCode: json['currency_code'] ?? 'USD',
      currencyName: json['currency_name'] ?? 'US Dollar',
      flag: json['flag'] ?? '🏳️',
      regions: json['regions']?.cast<String>(),
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iso': iso,
      'name': name,
      'currency_code': currencyCode,
      'currency_name': currencyName,
      'flag': flag,
      'regions': regions,
      'is_available': isAvailable,
    };
  }

  /// Obtener nombre completo con bandera
  String get displayName => '$flag $name';

  @override
  String toString() {
    return 'TopupCountry{iso: $iso, name: $name, currencyCode: $currencyCode}';
  }
}

/// Modelo para transacciones de recarga
class TopupTransaction {
  final String id;
  final String phoneNumber;
  final String productId;
  final String productName;
  final double amount;
  final String currency;
  final String status;
  final String countryIso;
  final String operatorCode;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? distributorRef;
  final Map<String, dynamic>? metadata;

  TopupTransaction({
    required this.id,
    required this.phoneNumber,
    required this.productId,
    required this.productName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.countryIso,
    required this.operatorCode,
    required this.createdAt,
    this.completedAt,
    this.distributorRef,
    this.metadata,
  });

  factory TopupTransaction.fromJson(Map<String, dynamic> json) {
    return TopupTransaction(
      id: json['id'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'pending',
      countryIso: json['country_iso'] ?? '',
      operatorCode: json['operator_code'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      distributorRef: json['distributor_ref'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'product_id': productId,
      'product_name': productName,
      'amount': amount,
      'currency': currency,
      'status': status,
      'country_iso': countryIso,
      'operator_code': operatorCode,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'distributor_ref': distributorRef,
      'metadata': metadata,
    };
  }

  /// Obtener monto formateado
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  /// Verificar si la transacción está completada
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Verificar si la transacción está pendiente
  bool get isPending => status.toLowerCase() == 'pending';

  /// Verificar si la transacción falló
  bool get isFailed => status.toLowerCase() == 'failed';

  /// Obtener color del estado
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'green';
      case 'pending':
        return 'orange';
      case 'failed':
        return 'red';
      default:
        return 'grey';
    }
  }

  @override
  String toString() {
    return 'TopupTransaction{id: $id, phoneNumber: $phoneNumber, amount: $amount, status: $status}';
  }
}





