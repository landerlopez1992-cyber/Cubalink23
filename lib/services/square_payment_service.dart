// Wrapper seguro que delega en el servicio oficial basado en backend.
// Elimina cualquier uso de secretos en el cliente.

export 'square_payment_service_official.dart' show SquarePaymentResult;
import 'square_payment_service_official.dart' as official;

class SquarePaymentService {
  static Future<void> initialize() {
    return official.SquarePaymentServiceOfficial.initialize();
  }

  // Mantiene compatibilidad de firma; ignora datos de tarjeta en cliente.
  static Future<official.SquarePaymentResult> processPayment({
    required double amount,
    required String description,
    String? cardLast4,
    String? cardType,
    String? cardHolderName,
  }) {
    return official.SquarePaymentServiceOfficial.processPayment(
      amount: amount,
      description: description,
    );
  }

  static Future<official.SquarePaymentResult> createQuickPaymentLink({
    required double amount,
    required String description,
    String? returnUrl,
  }) {
    return official.SquarePaymentServiceOfficial.createQuickPaymentLink(
      amount: amount,
      description: description,
      returnUrl: returnUrl,
    );
  }
}
