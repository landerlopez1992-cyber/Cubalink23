/// Servicio para calcular costos de envío basados en peso y destino
/// POLÍTICAS DE LA EMPRESA:
/// - Express: Máximo 70lb por artículo, $5/lb
/// - Si > 70lb pero divisible en múltiples maletines: Express $5/lb
/// - Si > 70lb y no divisible: Marítimo obligatorio $2.50/lb
class ShippingCalculator {
  // Límites de peso por tipo de envío (en libras)
  static const double _expressMaxWeightLb = 70.0; // 70 libras máximo por maletín
  
  // Tarifas por libra (en USD)
  static const double _expressRatePerLb = 5.00;    // $5 por libra para express
  static const double _maritimeRatePerLb = 2.50;   // $2.50 por libra para marítimo
  
  // Tarifas por destino (multiplicador)
  static const Map<String, double> _destinationRates = {
    'cuba': 1.0,      // Cuba (base)
    'miami': 0.8,     // Miami (más barato)
    'other': 1.2,     // Otros destinos
  };
  
  /// Calcular costo de envío basado en peso y destino
  static ShippingCalculation calculateShipping({
    required double weightLb, // Peso en libras
    required String destination,
    String shippingType = 'express',
    String? vendorId,
    bool isDivisible = false, // Si el producto se puede dividir en múltiples maletines
  }) {
    // Validar peso
    if (weightLb <= 0) {
      return ShippingCalculation(
        baseCost: 0.0,
        totalCost: 0.0,
        weightCategory: WeightCategory.light,
        shippingType: shippingType,
        estimatedDays: 0,
        isValid: false,
        errorMessage: 'Peso inválido',
      );
    }
    
    // Determinar categoría de peso
    final weightCategory = _getWeightCategory(weightLb);
    
    // Determinar tipo de envío basado en políticas de la empresa
    final actualShippingType = _determineShippingType(weightLb, isDivisible, shippingType);
    
    // Calcular costo base según políticas de la empresa
    double baseCost = _calculateBaseCostByCompanyPolicy(weightLb, actualShippingType, isDivisible);
    
    // Aplicar multiplicador de destino
    final destinationMultiplier = _destinationRates[destination] ?? 1.0;
    double totalCost = baseCost * destinationMultiplier;
    
    // Aplicar descuentos por vendedor
    if (vendorId != null) {
      totalCost = _applyVendorDiscount(totalCost, vendorId);
    }
    
    return ShippingCalculation(
      baseCost: baseCost,
      totalCost: totalCost,
      weightCategory: weightCategory,
      shippingType: actualShippingType,
      estimatedDays: _getEstimatedDays(actualShippingType, destination, vendorId, zipCode: '33470'),
      isValid: true,
      weightLb: weightLb,
      isDivisible: isDivisible,
      maletinesNeeded: _calculateMaletinesNeeded(weightLb, isDivisible),
    );
  }
  
  /// Calcular costo de envío para múltiples productos
  static ShippingCalculation calculateBulkShipping({
    required List<ProductWeight> products,
    required String destination,
    String shippingType = 'express',
  }) {
    double totalWeight = 0.0;
    double totalBaseCost = 0.0;
    WeightCategory maxCategory = WeightCategory.light;
    
    for (final product in products) {
      // Convertir kg a libras si es necesario
      final weightLb = product.weightKg * 2.20462;
      totalWeight += weightLb;
      
      final calculation = calculateShipping(
        weightLb: weightLb,
        destination: destination,
        shippingType: shippingType,
        vendorId: product.vendorId,
      );
      
      if (!calculation.isValid) {
        return calculation; // Retornar error si algún producto no es válido
      }
      
      totalBaseCost += calculation.baseCost;
      if (product.weightCategory.index > maxCategory.index) {
        maxCategory = product.weightCategory;
      }
    }
    
    // Aplicar descuento por volumen
    final volumeDiscount = _getVolumeDiscount(products.length);
    final discountedCost = totalBaseCost * (1.0 - volumeDiscount);
    
    // Aplicar multiplicador de destino
    final destinationMultiplier = _destinationRates[destination] ?? 1.0;
    final totalCost = discountedCost * destinationMultiplier;
    
    return ShippingCalculation(
      baseCost: totalBaseCost,
      totalCost: totalCost,
      weightCategory: maxCategory,
      shippingType: shippingType,
      estimatedDays: _getEstimatedDays(shippingType, destination, null),
      isValid: true,
      volumeDiscount: volumeDiscount,
      productCount: products.length,
    );
  }
  
  /// Determinar categoría de peso (en libras)
  static WeightCategory _getWeightCategory(double weightLb) {
    if (weightLb <= 1.0) return WeightCategory.light;      // < 1 lb
    if (weightLb <= 10.0) return WeightCategory.medium;    // 1-10 lb
    if (weightLb <= 30.0) return WeightCategory.heavy;     // 10-30 lb
    if (weightLb <= 70.0) return WeightCategory.oversized; // 30-70 lb
    return WeightCategory.freight;                         // > 70 lb
  }
  
  /// Determinar tipo de envío basado en políticas de la empresa
  static String _determineShippingType(double weightLb, bool isDivisible, String requestedType) {
    // Si el peso es <= 70lb, puede ser express
    if (weightLb <= _expressMaxWeightLb) {
      return 'express';
    }
    
    // Si el peso es > 70lb pero es divisible, puede ser express
    if (isDivisible) {
      return 'express';
    }
    
    // Si el peso es > 70lb y no es divisible, debe ser marítimo
    return 'maritime';
  }
  
  /// Calcular costo base según políticas de la empresa
  static double _calculateBaseCostByCompanyPolicy(double weightLb, String shippingType, bool isDivisible) {
    switch (shippingType) {
      case 'express':
        // $5 por libra para express
        return weightLb * _expressRatePerLb;
      case 'maritime':
        // $2.50 por libra para marítimo
        return weightLb * _maritimeRatePerLb;
      default:
        return weightLb * _expressRatePerLb;
    }
  }
  
  /// Calcular número de maletines necesarios
  static int _calculateMaletinesNeeded(double weightLb, bool isDivisible) {
    if (weightLb <= _expressMaxWeightLb) {
      return 1; // Un solo maletín
    }
    
    if (isDivisible) {
      // Calcular cuántos maletines de 70lb se necesitan
      return (weightLb / _expressMaxWeightLb).ceil();
    }
    
    // Si no es divisible y > 70lb, va por barco (no maletines)
    return 0;
  }
  
  /// Calcular costo base por peso (método legacy - usar _calculateBaseCostByCompanyPolicy)
  static double _calculateBaseCost(double weightLb, WeightCategory category) {
    return _calculateBaseCostByCompanyPolicy(weightLb, 'express', false);
  }
  
  /// Aplicar descuentos por vendedor
  static double _applyVendorDiscount(double cost, String vendorId) {
    switch (vendorId.toLowerCase()) {
      case 'amazon':
        return cost * 0.9; // 10% descuento Amazon
      case 'walmart':
        return cost * 0.95; // 5% descuento Walmart
      case 'admin':
      case 'system':
        return cost * 0.8; // 20% descuento productos de tienda
      default:
        return cost;
    }
  }
  
  /// Aplicar descuentos por tipo de envío
  static double _applyShippingTypeDiscount(double cost, String shippingType) {
    switch (shippingType) {
      case 'express':
        return cost * 1.5; // 50% más caro para express
      case 'standard':
        return cost; // Precio base
      case 'freight':
        return cost * 0.8; // 20% descuento para envío de carga
      default:
        return cost;
    }
  }
  
  /// Obtener días estimados de entrega total (vendedor + envío a Cuba)
  static int _getEstimatedDays(String shippingType, String destination, String? vendorId, {String? zipCode = '33470'}) {
    // Tiempo de entrega desde vendedor hasta nuestra bodega
    final vendorDeliveryDays = _getVendorDeliveryDays(vendorId, zipCode: zipCode);
    
    // Tiempo de envío desde bodega a Cuba
    final shippingToCubaDays = _getShippingToCubaDays(shippingType, destination);
    
    // Total = tiempo vendedor + tiempo envío a Cuba
    return vendorDeliveryDays + shippingToCubaDays;
  }
  
  /// Obtener días de entrega desde el vendedor hasta nuestra bodega (zip code 33470)
  static int _getVendorDeliveryDays(String? vendorId, {String? zipCode = '33470'}) {
    if (vendorId == null || vendorId == 'admin' || vendorId == 'system') {
      return 0; // Productos de la tienda ya están en Cuba
    }
    
    // Tiempos específicos para zip code 33470 (nuestra bodega)
    switch (vendorId.toLowerCase()) {
      case 'amazon':
        return _getAmazonDeliveryDays(zipCode);
      case 'walmart':
        return _getWalmartDeliveryDays(zipCode);
      case 'ebay':
        return _getEbayDeliveryDays(zipCode);
      case 'homedepot':
      case 'home_depot':
        return _getHomeDepotDeliveryDays(zipCode);
      case 'shein':
        return _getSheinDeliveryDays(zipCode);
      default:
        return 5; // Vendedores genéricos: 3-7 días (promedio 5)
    }
  }
  
  /// Tiempos de entrega de Amazon para zip code 33470
  static int _getAmazonDeliveryDays(String? zipCode) {
    if (zipCode == '33470') {
      return 2; // Amazon Prime: 1-2 días a nuestra bodega
    }
    return 3; // Amazon estándar: 2-3 días
  }
  
  /// Tiempos de entrega de Walmart para zip code 33470
  static int _getWalmartDeliveryDays(String? zipCode) {
    if (zipCode == '33470') {
      return 2; // Walmart+: 1-2 días a nuestra bodega
    }
    return 3; // Walmart estándar: 2-3 días
  }
  
  /// Tiempos de entrega de eBay para zip code 33470
  static int _getEbayDeliveryDays(String? zipCode) {
    if (zipCode == '33470') {
      return 3; // eBay: 2-3 días a nuestra bodega
    }
    return 4; // eBay estándar: 3-5 días
  }
  
  /// Tiempos de entrega de Home Depot para zip code 33470
  static int _getHomeDepotDeliveryDays(String? zipCode) {
    if (zipCode == '33470') {
      return 3; // Home Depot: 2-3 días a nuestra bodega
    }
    return 4; // Home Depot estándar: 3-5 días
  }
  
  /// Tiempos de entrega de Shein para zip code 33470
  static int _getSheinDeliveryDays(String? zipCode) {
    if (zipCode == '33470') {
      return 7; // Shein: 5-7 días a nuestra bodega
    }
    return 10; // Shein estándar: 1-2 semanas
  }
  
  /// Obtener días de envío desde bodega a Cuba
  static int _getShippingToCubaDays(String shippingType, String destination) {
    if (destination != 'cuba') {
      return 1; // Si no es Cuba, asumir 1 día
    }
    
    switch (shippingType) {
      case 'express':
        return 3; // Express: 3-8 días (promedio 3)
      case 'maritime':
        return 21; // Marítimo: 4-6 semanas (promedio 21 días)
      default:
        return 7;
    }
  }
  
  /// Obtener descuento por volumen
  static double _getVolumeDiscount(int productCount) {
    if (productCount >= 10) return 0.15; // 15% descuento
    if (productCount >= 5) return 0.10;  // 10% descuento
    if (productCount >= 3) return 0.05;  // 5% descuento
    return 0.0;
  }
  
  /// Validar si un producto se puede enviar
  static bool canShipProduct({
    required double weightKg,
    required String shippingType,
    String? productType,
  }) {
    // Convertir kg a libras
    final weightLb = weightKg * 2.20462;
    
    // Verificar límite de peso según políticas de la empresa
    if (shippingType == 'express' && weightLb > _expressMaxWeightLb) {
      return false; // No se puede enviar express si > 70lb
    }
    
    // Verificar restricciones por tipo de producto
    if (productType != null) {
      final restrictedTypes = ['hazardous', 'liquid', 'fragile'];
      if (restrictedTypes.contains(productType.toLowerCase())) {
        return shippingType == 'freight'; // Solo envío de carga
      }
    }
    
    return true;
  }
  
  /// Obtener tipo de envío recomendado
  static String getRecommendedShippingType(double weightKg, String? productType) {
    if (weightKg <= 1.0) return 'express';
    if (weightKg <= 5.0) return 'standard';
    if (weightKg <= 20.0) return 'freight';
    
    // Productos pesados requieren envío especial
    if (productType == 'hazardous' || productType == 'liquid') {
      return 'freight';
    }
    
    return 'freight';
  }
}

/// Categorías de peso
enum WeightCategory {
  light,      // < 0.5kg
  medium,     // 0.5kg - 1kg
  heavy,      // 1kg - 2kg
  oversized,  // 2kg - 5kg
  freight,    // > 5kg
}

/// Resultado del cálculo de envío
class ShippingCalculation {
  final double baseCost;
  final double totalCost;
  final WeightCategory weightCategory;
  final String shippingType;
  final int estimatedDays;
  final bool isValid;
  final String? errorMessage;
  final double? volumeDiscount;
  final int? productCount;
  final double? weightLb; // Peso en libras
  final bool? isDivisible; // Si el producto se puede dividir
  final int? maletinesNeeded; // Número de maletines necesarios
  
  const ShippingCalculation({
    required this.baseCost,
    required this.totalCost,
    required this.weightCategory,
    required this.shippingType,
    required this.estimatedDays,
    required this.isValid,
    this.errorMessage,
    this.volumeDiscount,
    this.productCount,
    this.weightLb,
    this.isDivisible,
    this.maletinesNeeded,
  });
  
  /// Obtener descripción de la categoría de peso
  String get weightCategoryDescription {
    switch (weightCategory) {
      case WeightCategory.light:
        return 'Ligero (< 1 lb)';
      case WeightCategory.medium:
        return 'Medio (1-10 lb)';
      case WeightCategory.heavy:
        return 'Pesado (10-30 lb)';
      case WeightCategory.oversized:
        return 'Voluminoso (30-70 lb)';
      case WeightCategory.freight:
        return 'Carga (> 70 lb)';
    }
  }
  
  /// Obtener descripción del tipo de envío
  String get shippingTypeDescription {
    switch (shippingType) {
      case 'express':
        return 'Envío Express (Avión)';
      case 'maritime':
        return 'Envío Marítimo (Barco)';
      default:
        return 'Envío Estándar';
    }
  }
  
  /// Formatear costo para mostrar
  String get formattedCost {
    return '\$${totalCost.toStringAsFixed(2)}';
  }
  
  /// Formatear días estimados
  String get formattedDays {
    if (estimatedDays == 1) return '1 día';
    return '$estimatedDays días';
  }
  
  /// Obtener información detallada de tiempos de entrega
  String get detailedDeliveryInfo {
    if (weightLb == null) return formattedDays;
    
    final vendorDays = ShippingCalculator._getVendorDeliveryDays(null, zipCode: '33470');
    final shippingDays = ShippingCalculator._getShippingToCubaDays(shippingType, 'cuba');
    
    if (vendorDays == 0) {
      return 'Entrega inmediata + $shippingDays días de envío = $estimatedDays días total';
    } else {
      return '$vendorDays días del vendedor (zip 33470) + $shippingDays días de envío = $estimatedDays días total';
    }
  }
  
  /// Obtener información de maletines
  String get maletinesInfo {
    if (maletinesNeeded == null || maletinesNeeded == 0) {
      return 'Envío por barco (no maletines)';
    } else if (maletinesNeeded == 1) {
      return '1 maletín de 70 lb';
    } else {
      return '$maletinesNeeded maletines de 70 lb cada uno';
    }
  }
}

/// Información de peso de un producto
class ProductWeight {
  final String productId;
  final double weightKg;
  final WeightCategory weightCategory;
  final String? vendorId;
  final String? productType;
  
  const ProductWeight({
    required this.productId,
    required this.weightKg,
    required this.weightCategory,
    this.vendorId,
    this.productType,
  });
}

/// Servicio para calcular costos reales de productos incluyendo envío y taxes
class ProductCostCalculator {
  // Zip code de nuestra bodega
  static const String _warehouseZipCode = '33470';
  
  /// Calcular precio final del producto incluyendo envío y taxes
  static ProductFinalPrice calculateFinalPrice({
    required double basePrice,
    required String vendorId,
    required double weightLb, // Peso en libras
    String? zipCode,
  }) {
    final actualZipCode = zipCode ?? _warehouseZipCode;
    
    // Obtener costos de envío del vendedor
    final vendorShipping = _getVendorShippingCost(vendorId, weightLb, actualZipCode);
    
    // Obtener taxes del vendedor
    final vendorTaxes = _getVendorTaxes(vendorId, basePrice, actualZipCode);
    
    // Calcular precio final
    final finalPrice = basePrice + vendorShipping + vendorTaxes;
    
    return ProductFinalPrice(
      basePrice: basePrice,
      shippingCost: vendorShipping,
      taxes: vendorTaxes,
      finalPrice: finalPrice,
      vendorId: vendorId,
      zipCode: actualZipCode,
    );
  }
  
  /// Obtener costo de envío del vendedor
  static double _getVendorShippingCost(String vendorId, double weightLb, String zipCode) {
    switch (vendorId.toLowerCase()) {
      case 'amazon':
        return _getAmazonShippingCost(weightLb, zipCode);
      case 'walmart':
        return _getWalmartShippingCost(weightLb, zipCode);
      case 'ebay':
        return _getEbayShippingCost(weightLb, zipCode);
      case 'homedepot':
      case 'home_depot':
        return _getHomeDepotShippingCost(weightLb, zipCode);
      case 'shein':
        return _getSheinShippingCost(weightLb, zipCode);
      default:
        return 0.0; // Vendedores genéricos: sin costo de envío
    }
  }
  
  /// Obtener taxes del vendedor
  static double _getVendorTaxes(String vendorId, double basePrice, String zipCode) {
    switch (vendorId.toLowerCase()) {
      case 'amazon':
        return _getAmazonTaxes(basePrice, zipCode);
      case 'walmart':
        return _getWalmartTaxes(basePrice, zipCode);
      case 'ebay':
        return _getEbayTaxes(basePrice, zipCode);
      case 'homedepot':
      case 'home_depot':
        return _getHomeDepotTaxes(basePrice, zipCode);
      case 'shein':
        return _getSheinTaxes(basePrice, zipCode);
      default:
        return 0.0; // Vendedores genéricos: sin taxes
    }
  }
  
  /// Costos de envío de Amazon
  static double _getAmazonShippingCost(double weightLb, String zipCode) {
    if (zipCode == _warehouseZipCode) {
      // Amazon Prime: envío gratis para nuestra bodega
      return 0.0;
    }
    
    // Amazon estándar: $5.99 para envíos estándar
    return 5.99;
  }
  
  /// Taxes de Amazon
  static double _getAmazonTaxes(double basePrice, String zipCode) {
    if (zipCode == _warehouseZipCode) {
      // Florida: 6% sales tax
      return basePrice * 0.06;
    }
    return 0.0;
  }
  
  /// Costos de envío de Walmart
  static double _getWalmartShippingCost(double weightLb, String zipCode) {
    if (zipCode == _warehouseZipCode) {
      // Walmart+: envío gratis para nuestra bodega
      return 0.0;
    }
    
    // Walmart estándar: $5.99 para envíos estándar
    return 5.99;
  }
  
  /// Taxes de Walmart
  static double _getWalmartTaxes(double basePrice, String zipCode) {
    if (zipCode == _warehouseZipCode) {
      // Florida: 6% sales tax
      return basePrice * 0.06;
    }
    return 0.0;
  }
  
  /// Costos de envío de eBay
  static double _getEbayShippingCost(double weightLb, String zipCode) {
    if (zipCode == _warehouseZipCode) {
      // eBay: envío variable, promedio $3.99
      return 3.99;
    }
    
    // eBay estándar: $4.99 para envíos estándar
    return 4.99;
  }
  
  /// Taxes de eBay
  static double _getEbayTaxes(double basePrice, String zipCode) {
    if (zipCode == _warehouseZipCode) {
      // Florida: 6% sales tax
      return basePrice * 0.06;
    }
    return 0.0;
  }
  
  /// Costos de envío de Home Depot
  static double _getHomeDepotShippingCost(double weightLb, String zipCode) {
    if (zipCode == _warehouseZipCode) {
      // Home Depot: envío gratis para pedidos > $45
      return 0.0;
    }
    
    // Home Depot estándar: $5.99 para envíos estándar
    return 5.99;
  }
  
  /// Taxes de Home Depot
  static double _getHomeDepotTaxes(double basePrice, String zipCode) {
    if (zipCode == _warehouseZipCode) {
      // Florida: 6% sales tax
      return basePrice * 0.06;
    }
    return 0.0;
  }
  
  /// Costos de envío de Shein
  static double _getSheinShippingCost(double weightLb, String zipCode) {
    if (zipCode == _warehouseZipCode) {
      // Shein: envío gratis para pedidos > $29
      return 0.0;
    }
    
    // Shein estándar: $3.99 para envíos estándar
    return 3.99;
  }
  
  /// Taxes de Shein
  static double _getSheinTaxes(double basePrice, String zipCode) {
    if (zipCode == _warehouseZipCode) {
      // Florida: 6% sales tax
      return basePrice * 0.06;
    }
    return 0.0;
  }
}

/// Precio final del producto incluyendo todos los costos
class ProductFinalPrice {
  final double basePrice;
  final double shippingCost;
  final double taxes;
  final double finalPrice;
  final String vendorId;
  final String zipCode;
  
  const ProductFinalPrice({
    required this.basePrice,
    required this.shippingCost,
    required this.taxes,
    required this.finalPrice,
    required this.vendorId,
    required this.zipCode,
  });
  
  /// Formatear precio base
  String get formattedBasePrice => '\$${basePrice.toStringAsFixed(2)}';
  
  /// Formatear costo de envío
  String get formattedShippingCost => '\$${shippingCost.toStringAsFixed(2)}';
  
  /// Formatear taxes
  String get formattedTaxes => '\$${taxes.toStringAsFixed(2)}';
  
  /// Formatear precio final
  String get formattedFinalPrice => '\$${finalPrice.toStringAsFixed(2)}';
  
  /// Obtener descripción de costos
  String get costBreakdown {
    if (shippingCost == 0 && taxes == 0) {
      return 'Precio final: $formattedFinalPrice';
    }
    
    return 'Precio: $formattedBasePrice + Envío: $formattedShippingCost + Taxes: $formattedTaxes = $formattedFinalPrice';
  }
}
