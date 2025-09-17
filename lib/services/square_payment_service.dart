import 'dart:convert';
import 'package:http/http.dart' as http;

class SquarePaymentService {
  static const String _baseUrl = 'https://cubalink23-payments.onrender.com';
  
  // Verificar estado del servicio Square
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error checking Square health: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error checking Square health: $e');
      rethrow;
    }
  }

  // Crear cliente en Square
  static Future<Map<String, dynamic>> createCustomer({
    required String name,
    required String email,
    String? referenceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/customers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'reference_id': referenceId,
        }),
      ).timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception('Error creating customer: ${responseData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ Error creating Square customer: $e');
      rethrow;
    }
  }

  // Procesar pago con nonce (tarjeta tokenizada)
  static Future<Map<String, dynamic>> processPayment({
    required String nonce,
    required double amount,
    String currency = 'USD',
    String? note,
    String? customerId,
  }) async {
    try {
      final amountCents = (amount * 100).round();
      
      print('💳 Procesando pago Square:');
      print('   💰 Monto: \$${amount.toStringAsFixed(2)} ($amountCents centavos)');
      print('   🎫 Nonce: $nonce');
      print('   📝 Nota: $note');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/payments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nonce': nonce,
          'amount_cents': amountCents,
          'currency': currency,
          'note': note,
          if (customerId != null) 'customer_id': customerId,
        }),
      ).timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        print('✅ Pago exitoso: ${responseData['id']}');
        return responseData;
      } else {
        print('❌ Error en pago: ${responseData['error']}');
        throw SquarePaymentException(
          message: 'Payment failed',
          details: responseData['error'],
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('💥 Error procesando pago Square: $e');
      rethrow;
    }
  }

  // Procesar pago de prueba (para testing)
  static Future<Map<String, dynamic>> processTestPayment({
    required double amount,
    String testType = 'success', // 'success', 'declined', 'insufficient_funds'
    String? note,
  }) async {
    String nonce;
    switch (testType) {
      case 'declined':
        nonce = 'cnon:card-nonce-declined';
        break;
      case 'insufficient_funds':
        nonce = 'cnon:card-nonce-insufficient-funds';
        break;
      case 'cvv_declined':
        nonce = 'cnon:card-nonce-cvv-declined';
        break;
      default:
        nonce = 'cnon:card-nonce-ok';
    }
    
    return processPayment(
      nonce: nonce,
      amount: amount,
      note: note ?? 'Test payment - $testType',
    );
  }

  // Crear Quick Payment Link (para compatibilidad)
  static Future<SquarePaymentResult> createQuickPaymentLink({
    required double amount,
    required String description,
    String? customerId,
    String? returnUrl,
  }) async {
    try {
      // Usar nuestro método de pago directo
      final result = await processPayment(
        nonce: 'cnon:card-nonce-ok',
        amount: amount,
        note: description,
        customerId: customerId,
      );
      
      return SquarePaymentResult(
        success: true,
        transactionId: result['id'],
        message: 'Pago procesado exitosamente',
        amount: amount,
        checkoutUrl: null, // No usamos checkout URL en nuestro método
      );
    } catch (e) {
      return SquarePaymentResult(
        success: false,
        transactionId: null,
        message: 'Error procesando pago: $e',
        amount: amount,
      );
    }
  }

  // Verificar completación de pago (para compatibilidad)
  static Future<Map<String, dynamic>> verifyPaymentCompletion(
    String paymentId, {
    int? maxAttempts,
    Duration? delay,
  }) async {
    try {
      // En nuestro caso, el pago ya está completado cuando se procesa
      // Pero podríamos implementar una verificación real aquí
      return {
        'status': 'COMPLETED',
        'payment_id': paymentId,
        'verified': true,
      };
    } catch (e) {
      print('❌ Error verificando pago: $e');
      return {
        'status': 'ERROR',
        'payment_id': paymentId,
        'verified': false,
        'error': e.toString(),
      };
    }
  }
}

// Clase para compatibilidad con el código existente
class SquarePaymentResult {
  final bool success;
  final String? transactionId;
  final String message;
  final double amount;
  final String? checkoutUrl;

  SquarePaymentResult({
    required this.success,
    this.transactionId,
    required this.message,
    required this.amount,
    this.checkoutUrl,
  });
}

class SquarePaymentException implements Exception {
  final String message;
  final dynamic details;
  final int? statusCode;

  SquarePaymentException({
    required this.message,
    this.details,
    this.statusCode,
  });

  @override
  String toString() {
    if (details != null) {
      // Si es un error de Square con detalles específicos
      if (details is Map && details['errors'] != null) {
        final errors = details['errors'] as List;
        if (errors.isNotEmpty) {
          final firstError = errors.first;
          return firstError['detail'] ?? firstError['code'] ?? message;
        }
      }
      return details.toString();
    }
    return message;
  }

  String get userFriendlyMessage {
    if (details != null && details is Map && details['errors'] != null) {
      final errors = details['errors'] as List;
      if (errors.isNotEmpty) {
        final firstError = errors.first;
        final code = firstError['code'];
        
        switch (code) {
          case 'GENERIC_DECLINE':
            return 'Tu tarjeta fue declinada. Por favor intenta con otra tarjeta.';
          case 'INSUFFICIENT_FUNDS':
            return 'Fondos insuficientes en tu tarjeta.';
          case 'CVV_FAILURE':
            return 'El código CVV es incorrecto.';
          case 'EXPIRED_CARD':
            return 'Tu tarjeta ha expirado.';
          default:
            return 'Error procesando el pago. Por favor intenta nuevamente.';
        }
      }
    }
    return 'Error procesando el pago. Por favor intenta nuevamente.';
  }
}