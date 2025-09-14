/// Modelo para manejar los estados de órdenes según las reglas del sistema Cubalink23
class OrderStatus {
  static const String created = 'Orden Creada';
  static const String processing = 'Procesando Orden';
  static const String accepted = 'Aceptar Orden';
  static const String inTransit = 'Orden en Tránsito';
  static const String inDelivery = 'Orden en Reparto';
  static const String delivered = 'Orden Entregada';
  static const String cancelled = 'Orden Cancelada';
  
  /// Obtener el siguiente estado según el tipo de envío
  static String getNextStatus(String currentStatus, ShippingType shippingType, bool isVendorOrder) {
    switch (currentStatus) {
      case created:
        return processing;
      case processing:
        if (shippingType == ShippingType.expressSystem || 
            shippingType == ShippingType.expressVendor) {
          return accepted;
        } else if (shippingType == ShippingType.vendor) {
          return inDelivery; // Vendedor maneja directamente
        } else if (shippingType == ShippingType.maritime) {
          return inTransit; // Solo admin maneja
        }
        break;
      case accepted:
        return inTransit;
      case inTransit:
        return inDelivery;
      case inDelivery:
        return delivered;
    }
    return currentStatus;
  }
  
  /// Verificar si se puede cambiar a un estado específico
  static bool canChangeToStatus(String currentStatus, String targetStatus, ShippingType shippingType, bool isVendorOrder) {
    // Reglas específicas según el tipo de envío
    if (shippingType == ShippingType.maritime && !isVendorOrder) {
      // Solo administrador puede manejar envío marítimo
      return true;
    }
    
    if (shippingType == ShippingType.vendor && isVendorOrder) {
      // Vendedor maneja todos los estados
      return true;
    }
    
    // Flujo normal para envío express
    final validTransitions = {
      created: [processing, cancelled],
      processing: [accepted, cancelled],
      accepted: [inTransit, cancelled],
      inTransit: [inDelivery, cancelled],
      inDelivery: [delivered, cancelled],
      delivered: [],
      cancelled: []
    };
    
    return validTransitions[currentStatus]?.contains(targetStatus) ?? false;
  }
  
  /// Obtener el color del estado para la UI
  static String getStatusColor(String status) {
    switch (status) {
      case created:
        return '#6c757d'; // Gris
      case processing:
        return '#ffc107'; // Amarillo
      case accepted:
        return '#17a2b8'; // Azul
      case inTransit:
        return '#007bff'; // Azul primario
      case inDelivery:
        return '#fd7e14'; // Naranja
      case delivered:
        return '#28a745'; // Verde
      case cancelled:
        return '#dc3545'; // Rojo
      default:
        return '#6c757d';
    }
  }
  
  /// Obtener el ícono del estado para la UI
  static String getStatusIcon(String status) {
    switch (status) {
      case created:
        return '📝';
      case processing:
        return '⚙️';
      case accepted:
        return '✅';
      case inTransit:
        return '🚚';
      case inDelivery:
        return '🏍️';
      case delivered:
        return '📦';
      case cancelled:
        return '❌';
      default:
        return '❓';
    }
  }
}

/// Tipos de envío según las reglas del sistema
enum ShippingType {
  expressSystem,    // Envío Express (Sistema/Admin) - Para productos Amazon
  expressVendor,    // Envío Express (Vendedor) - Vendedor usa repartidores de la app
  vendor,           // Envío Vendedor - Vendedor entrega personalmente
  maritime,         // Envío Barco - Solo administrador maneja
}

/// Información de entrega para detección de diferencias
class DeliveryInfo {
  final String vendorId;
  final String vendorName;
  final ShippingType shippingType;
  final int estimatedDays;
  final String location;
  
  const DeliveryInfo({
    required this.vendorId,
    required this.vendorName,
    required this.shippingType,
    required this.estimatedDays,
    required this.location,
  });
  
  /// Verificar si hay diferencias significativas de entrega
  static bool hasDeliveryDifferences(List<DeliveryInfo> deliveryInfos) {
    if (deliveryInfos.length <= 1) return false;
    
    // Verificar diferentes vendedores
    final uniqueVendors = deliveryInfos.map((info) => info.vendorId).toSet();
    if (uniqueVendors.length > 1) return true;
    
    // Verificar diferentes tipos de envío
    final uniqueShippingTypes = deliveryInfos.map((info) => info.shippingType).toSet();
    if (uniqueShippingTypes.length > 1) return true;
    
    // Verificar diferencias significativas en tiempo (más de 7 días)
    final times = deliveryInfos.map((info) => info.estimatedDays).toList();
    final maxTime = times.reduce((a, b) => a > b ? a : b);
    final minTime = times.reduce((a, b) => a < b ? a : b);
    
    return (maxTime - minTime) > 7;
  }
  
  /// Generar mensaje de alerta para diferencias de entrega
  static String generateDifferenceAlert(List<DeliveryInfo> deliveryInfos) {
    // Removed unused variables: uniqueVendors, uniqueShippingTypes
    
    String message = "Sus productos tienen diferentes tiempos de entrega:\n\n";
    
    for (final info in deliveryInfos) {
      message += "• ${info.vendorName}: ${info.estimatedDays} días (${_getShippingTypeName(info.shippingType)})\n";
    }
    
    message += "\n¿Desea continuar con pedidos separados?";
    
    return message;
  }
  
  static String _getShippingTypeName(ShippingType type) {
    switch (type) {
      case ShippingType.expressSystem:
        return "Envío Express (Sistema)";
      case ShippingType.expressVendor:
        return "Envío Express (Vendedor)";
      case ShippingType.vendor:
        return "Envío Vendedor";
      case ShippingType.maritime:
        return "Envío Marítimo";
    }
  }
}
