/// 🕐 Configuración de delays para pagos
class PaymentConfig {
  // Delay después del pago exitoso antes de reservar en Duffel
  // Tiempo para que los fondos lleguen a tu tarjeta desde Square
  static const int FUNDS_DELAY_SECONDS = 90; // 1.5 minutos
  
  // Delay para procesamiento de pago (simulado)
  static const int PAYMENT_PROCESSING_DELAY_SECONDS = 2;
  
  // Mensajes para el usuario
  static const String WAITING_FUNDS_MESSAGE = 'Esperando confirmación de fondos...';
  static const String PROCESSING_PAYMENT_MESSAGE = 'Procesando pago...';
  
  // Configuración de métodos de pago Duffel
  static const String DUFFEL_PAYMENT_METHOD_CARD = 'card'; // Tarjeta fija del admin
  static const String DUFFEL_PAYMENT_METHOD_BALANCE = 'balance'; // Balance Duffel
  static const String DUFFEL_PAYMENT_METHOD_HOLD = 'hold'; // Mantener reserva
}

/// Configuración de Square sin secretos (solo IDs públicos o flags)
class SquarePublicConfig {
  static const String applicationIdSandbox = 'sandbox-sq0idb-IsIJtKqx2OHdVJjYmg6puA';
  static const String applicationIdProduction = '';
  static const String locationIdSandbox = 'LZVTP0YQ9YQBB';
  static const String locationIdProduction = '';

  /// Backend que procesa pagos y genera Payment Links (no exponer tokens aquí)
  static const String backendProcessPaymentUrl =
      'https://cubalink23-backend.onrender.com/api/payments/process';
}
