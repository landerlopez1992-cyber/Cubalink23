/// 💳 Configuración para Square Payments Backend
/// 
/// Este archivo contiene la configuración para conectarse al backend
/// separado de Square (cubalink23-payments)
class SquarePaymentsConfig {
  // 🌐 URL del backend de Square (SEPARADO del de Duffel)
  static const String baseUrl = 'https://cubalink23-payments.onrender.com';
  
  // 📡 Endpoints del backend de Square
  static const String healthEndpoint = '/api/health';
  static const String processPaymentEndpoint = '/api/payments/process';
  static const String saveCardEndpoint = '/api/payments/cards/save';
  static const String chargeCardEndpoint = '/api/payments/cards/charge';
  
  // 🔑 Credenciales de Square (para tokenización en la app)
  // TODO: Configurar con las credenciales reales de Square Sandbox
  static const String squareApplicationId = 'sandbox-sq0idb-xxxxxxxxxxxxx';
  static const String squareLocationId = 'xxxxxxxxxxxxxxxxx';
  static const String squareEnvironment = 'sandbox'; // 'sandbox' o 'production'
  
  // ⏱️ Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration healthCheckTimeout = Duration(seconds: 10);
  
  // 🔒 Headers estándar
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// 🏥 Verificar si el backend de Square está activo
  static String get healthUrl => '$baseUrl$healthEndpoint';
  
  /// 💳 URL para procesar pagos
  static String get processPaymentUrl => '$baseUrl$processPaymentEndpoint';
  
  /// 💳 URL para guardar tarjetas
  static String get saveCardUrl => '$baseUrl$saveCardEndpoint';
  
  /// 💳 URL para cobrar tarjetas guardadas
  static String get chargeCardUrl => '$baseUrl$chargeCardEndpoint';
  
  /// 🔍 Verificar configuración
  static bool get isConfigured {
    return squareApplicationId.isNotEmpty && 
           squareLocationId.isNotEmpty &&
           baseUrl.isNotEmpty;
  }
  
  /// 📋 Obtener información de configuración
  static Map<String, dynamic> get configInfo {
    return {
      'baseUrl': baseUrl,
      'squareApplicationId': squareApplicationId,
      'squareLocationId': squareLocationId,
      'squareEnvironment': squareEnvironment,
      'isConfigured': isConfigured,
      'endpoints': {
        'health': healthEndpoint,
        'processPayment': processPaymentEndpoint,
        'saveCard': saveCardEndpoint,
        'chargeCard': chargeCardEndpoint,
      }
    };
  }
}
