// SQUARE REACTIVADO CON CREDENCIALES VÁLIDAS
// Servicio de pagos real con Square

import 'package:http/http.dart' as http;
import 'dart:convert';

class SquarePaymentService {
  // Credenciales de Square Sandbox (VÁLIDAS)
  static const String _applicationId = 'sandbox-sq0idb-IsIJtKqx2OHdVJjYmg6puA';
  static const String _locationId = 'LZVTP0YQ9YQBB';
  static const String _accessToken = 'EAAAl4WnC2APxLhZXN1HJrn5CPWQGd-wXe_PpQm6vPvdOBHj1xWINxP3s7uOpvYO';
  static const String _environment = 'sandbox';
  static const String _baseUrl = 'https://connect.squareupsandbox.com';

  /// Initialize Square Payment Service (REACTIVADO)
  static Future<void> initialize() async {
    try {
      // Verificar conexión con Square
      final response = await http.get(
        Uri.parse('$_baseUrl/v2/locations'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
          'Square-Version': '2024-12-01',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Square inicializado correctamente');
        print('🔗 Conectado a: $_environment');
        print('📍 Location ID: $_locationId');
      } else {
        print('❌ Error inicializando Square: ${response.statusCode}');
        throw Exception('Error conectando con Square: ${response.body}');
      }
    } catch (e) {
      print('❌ Error inicializando Square: $e');
      throw e;
    }
  }

  /// Procesar pago REAL con Square
  static Future<SquarePaymentResult> processPayment({
    required double amount,
    required String description,
    required String cardLast4,
    required String cardType,
    required String cardHolderName,
  }) async {
    try {
      print('💳 Procesando pago REAL con Square...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      print('💳 Tarjeta: $cardType ****$cardLast4');
      print('👤 Titular: $cardHolderName');
      
      // ========== SIMULACIÓN DE TARJETAS DE ERROR ==========
      // Verificar si es una tarjeta de test que debe fallar
      if (cardLast4 == '0002') {
        print('❌ Tarjeta de test: Card declined');
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Your card was declined',
          amount: amount,
        );
      }
      
      if (cardLast4 == '9995') {
        print('❌ Tarjeta de test: Insufficient funds');
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Insufficient funds',
          amount: amount,
        );
      }
      
      if (cardLast4 == '0069') {
        print('❌ Tarjeta de test: Card expired');
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Your card has expired',
          amount: amount,
        );
      }
      
      if (cardLast4 == '0119') {
        print('❌ Tarjeta de test: Processing error');
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Processing error',
          amount: amount,
        );
      }
      
      // ========== PROCESAR PAGO REAL CON SQUARE API ==========
      final paymentResult = await _processRealSquarePayment(
        amount: amount,
        description: description,
        cardLast4: cardLast4,
        cardType: cardType,
        cardHolderName: cardHolderName,
      );

      if (paymentResult['success']) {
        print('✅ Pago procesado exitosamente');
        print('💳 Transaction ID: ${paymentResult['transaction_id']}');
        
        return SquarePaymentResult(
          success: true,
          transactionId: paymentResult['transaction_id'],
          message: 'Pago procesado exitosamente',
          amount: amount,
        );
      } else {
        print('❌ Error procesando pago: ${paymentResult['error']}');
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Error procesando pago: ${paymentResult['error']}',
          amount: amount,
        );
      }
    } catch (e) {
      print('❌ Error procesando pago: $e');
      return SquarePaymentResult(
        success: false,
        transactionId: null,
        message: 'Error procesando pago: $e',
        amount: amount,
      );
    }
  }

  /// Procesar pago real con Square API
  static Future<Map<String, dynamic>> _processRealSquarePayment({
    required double amount,
    required String description,
    required String cardLast4,
    required String cardType,
    required String cardHolderName,
  }) async {
    try {
      print('💳 Procesando pago REAL con Square API...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      print('💳 Tarjeta: $cardType ****$cardLast4');
      print('👤 Titular: $cardHolderName');
      
      // Llamar al backend para procesar pago real con Square
      final response = await http.post(
        Uri.parse('https://cubalink23-backend.onrender.com/api/payments/process'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'description': description,
          'card_last4': cardLast4,
          'card_type': cardType,
          'card_holder_name': cardHolderName,
        }),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Respuesta de Square API: $result');
        
        return {
          'success': result['success'] ?? false,
          'transaction_id': result['transaction_id'],
          'message': result['message'] ?? 'Pago procesado',
          'error': result['error'],
        };
      } else {
        print('❌ Error en respuesta del servidor: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error procesando pago real: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }


  /// Crear enlace de pago con Square API
  static Future<Map<String, dynamic>> _createPaymentLink({
    required double amount,
    required String description,
  }) async {
    try {
      final body = {
        "quick_pay": {
          "name": description,
          "price_money": {
            "amount": (amount * 100).round(), // Convertir a centavos
            "currency": "USD"
          },
          "location_id": _locationId
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/v2/online-checkout/payment-links'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
          'Square-Version': '2024-12-01',
        },
        body: json.encode(body),
      );

      print('📡 Square API Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final paymentLink = data['payment_link'];
        
        print('✅ Payment link creado: ${paymentLink['id']}');
        print('🔗 Checkout URL: ${paymentLink['url']}');
        print('🔗 Long URL: ${paymentLink['long_url']}');
        
        // Usar 'url' que es lo que Square realmente devuelve (como confirmamos en las pruebas)
        final checkoutUrl = paymentLink['url'] ?? paymentLink['long_url'] ?? 'URL no disponible';
        
        return {
          'success': true,
          'payment_link_id': paymentLink['id'],
          'checkout_url': checkoutUrl,
          'amount': amount,
        };
      } else {
        print('❌ Error de Square API: ${response.statusCode}');
        print('❌ Error body: ${response.body}');
        return {
          'success': false,
          'error': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }

  /// Obtener estado de un pago
  static Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v2/payments/$paymentId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
          'Square-Version': '2024-12-01',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'payment': data['payment'],
        };
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }
  
  /// Verificar completitud de pago con reintentos
  static Future<Map<String, dynamic>> verifyPaymentCompletion(
    String paymentId, {
    int maxAttempts = 10,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final result = await getPaymentStatus(paymentId);
        
        if (result['success']) {
          final payment = result['payment'];
          final status = payment['status'];
          
          // Si el pago está en estado final, retornar
          if (['COMPLETED', 'FAILED', 'CANCELED'].contains(status)) {
            return {
              'success': true,
              'status': status,
              'payment': payment,
            };
          }
        }
        
        print('🔄 Intento ${attempt + 1}: Pago $paymentId aún pendiente...');
        
        // Esperar antes del siguiente intento
        if (attempt < maxAttempts - 1) {
          await Future.delayed(delay);
        }
        
      } catch (e) {
        print('❌ Error verificando pago en intento ${attempt + 1}: $e');
      }
    }
    
    return {
      'success': false,
      'error': 'Timeout verificando completitud del pago',
    };
  }
  
  /// Crear cliente en Square
  static Future<Map<String, dynamic>> createCustomer({
    required String email,
    required String firstName,
    required String lastName,
    String? phone,
    Map<String, dynamic>? address,
  }) async {
    try {
      final body = {
        "given_name": firstName,
        "family_name": lastName,
        "email_address": email,
        if (phone != null) "phone_number": phone,
        if (address != null) "address": {
          "address_line_1": address['street'] ?? '',
          "locality": address['city'] ?? '',
          "administrative_district_level_1": address['state'] ?? '',
          "postal_code": address['zipCode'] ?? '',
          "country": address['country'] ?? 'US',
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/v2/customers'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
          'Square-Version': '2024-12-01',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final customer = data['customer'];
        
        return {
          'success': true,
          'customer_id': customer['id'],
          'email': customer['email_address'],
          'name': '${customer['given_name']} ${customer['family_name']}',
        };
      } else {
        return {
          'success': false,
          'error': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception: $e',
      };
    }
  }
  

}

/// Resultado del pago Square
class SquarePaymentResult {
  final bool success;
  final String? transactionId;
  final String message;
  final double amount;
  final String? checkoutUrl;

  SquarePaymentResult({
    required this.success,
    required this.transactionId,
    required this.message,
    required this.amount,
    this.checkoutUrl,
  });

  @override
  String toString() {
    return 'SquarePaymentResult(success: $success, transactionId: $transactionId, message: $message, amount: $amount, checkoutUrl: $checkoutUrl)';
  }
}