import '../models/order_status.dart';
import '../models/cart_item.dart';

/// Servicio para detectar diferencias de entrega según las reglas del sistema
class DeliveryDetectionService {
  
  /// Detectar diferencias de entrega en productos del carrito
  static Future<DeliveryDetectionResult> detectDeliveryDifferences(List<CartItem> cartItems) async {
    if (cartItems.isEmpty) {
      return DeliveryDetectionResult(
        hasDifferences: false,
        deliveryInfos: [],
        cartItems: [],
        alertMessage: null,
      );
    }
    
    final deliveryInfos = _extractDeliveryInfos(cartItems);
    final hasDifferences = DeliveryInfo.hasDeliveryDifferences(deliveryInfos);
    
    return DeliveryDetectionResult(
      hasDifferences: hasDifferences,
      deliveryInfos: deliveryInfos,
      cartItems: cartItems,
      alertMessage: hasDifferences ? DeliveryInfo.generateDifferenceAlert(deliveryInfos) : null,
    );
  }
  
  /// Extraer información de entrega de los productos
  static List<DeliveryInfo> _extractDeliveryInfos(List<CartItem> items) {
    return items.map((item) {
      // Determinar tipo de envío basado en el vendedor
      ShippingType shippingType;
      int estimatedDays;
      
      final vendorId = item.vendorId ?? 'admin';
      
      if (vendorId == 'amazon') {
        shippingType = ShippingType.expressSystem;
        estimatedDays = 3; // Amazon: 2-3 días a bodega
      } else if (vendorId == 'walmart') {
        shippingType = ShippingType.expressSystem;
        estimatedDays = 3; // Walmart: 2-3 días a bodega
      } else if (vendorId == 'ebay') {
        shippingType = ShippingType.expressSystem;
        estimatedDays = 5; // eBay: 3-5 días a bodega
      } else if (vendorId == 'homedepot' || vendorId == 'home_depot') {
        shippingType = ShippingType.expressSystem;
        estimatedDays = 5; // Home Depot: 3-5 días a bodega
      } else if (vendorId == 'shein') {
        shippingType = ShippingType.expressSystem;
        estimatedDays = 14; // Shein: 1-2 semanas a bodega
      } else {
        // Productos de la tienda local
        shippingType = ShippingType.expressSystem;
        estimatedDays = 0; // Ya están en Cuba
      }
      
      return DeliveryInfo(
        vendorId: vendorId,
        vendorName: _getVendorDisplayName(vendorId),
        shippingType: shippingType,
        estimatedDays: estimatedDays,
        location: 'Cuba',
      );
    }).toList();
  }
  
  /// Obtener nombre de display del vendedor
  static String _getVendorDisplayName(String vendorId) {
    switch (vendorId.toLowerCase()) {
      case 'amazon':
        return 'Amazon';
      case 'walmart':
        return 'Walmart';
      case 'ebay':
        return 'eBay';
      case 'homedepot':
      case 'home_depot':
        return 'Home Depot';
      case 'shein':
        return 'Shein';
      case 'admin':
        return 'Tienda Local';
      default:
        return 'Vendedor Externo';
    }
  }
}

/// Resultado de la detección de diferencias de entrega
class DeliveryDetectionResult {
  final bool hasDifferences;
  final List<DeliveryInfo> deliveryInfos;
  final List<CartItem> cartItems;
  final String? alertMessage;
  
  const DeliveryDetectionResult({
    required this.hasDifferences,
    required this.deliveryInfos,
    required this.cartItems,
    this.alertMessage,
  });
}