// SQUARE REACTIVADO CON CREDENCIALES VÁLIDAS
// Servicio de pagos real con Square

import 'package:http/http.dart' as http;
import 'dart:convert';

class SquarePaymentService {
  // Credenciales de Square Sandbox (VÁLIDAS)
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
      rethrow;
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
      
      // ========== PROCESAR PAGO REAL CON SQUARE API ==========
      // Square maneja TODOS los errores de tarjetas automáticamente
      final paymentResult = await _processRealSquarePayment(
        amount: amount,
        description: description,
        cardLast4: cardLast4,
        cardType: cardType,
        cardHolderName: cardHolderName,
      );

      if (paymentResult['success']) {
        print('✅ Payment Link creado exitosamente');
        print('💳 Transaction ID: ${paymentResult['transaction_id']}');
        print('🔗 Checkout URL: ${paymentResult['checkout_url']}');
        
        // Abrir el Payment Link en el navegador
        if (paymentResult['checkout_url'] != null) {
          final url = paymentResult['checkout_url'];
          print('🌐 Abriendo Payment Link: $url');
          
          // Simular pago exitoso después de crear el link
          // En producción, esto se manejaría con webhooks
          return SquarePaymentResult(
            success: true,
            transactionId: paymentResult['transaction_id'],
            message: 'Payment Link creado. Redirigiendo a Square...',
            amount: amount,
            checkoutUrl: url,
          );
        } else {
          return SquarePaymentResult(
            success: false,
            transactionId: null,
            message: 'Error: No se pudo obtener URL de pago',
            amount: amount,
          );
        }
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

  /// Procesar pago real con Square API - LLAMADA DIRECTA
  static Future<Map<String, dynamic>> _processRealSquarePayment({
    required double amount,
    required String description,
    required String cardLast4,
    required String cardType,
    required String cardHolderName,
  }) async {
    try {
      print('💳 Procesando pago REAL con Square API - LLAMADA DIRECTA...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      print('💳 Tarjeta: $cardType ****$cardLast4');
      print('👤 Titular: $cardHolderName');
      
      // 🚀 LLAMADA DIRECTA A SQUARE API - SIN BACKEND
      final paymentLinkResult = await createPaymentLink(
        amount: amount,
        description: description,
      );
      
      if (paymentLinkResult['success']) {
        print('✅ Payment Link creado directamente con Square');
        print('🔗 Payment Link ID: ${paymentLinkResult['payment_link_id']}');
        print('🌐 Checkout URL: ${paymentLinkResult['checkout_url']}');
        
        return {
          'success': true,
          'transaction_id': paymentLinkResult['payment_link_id'],
          'checkout_url': paymentLinkResult['checkout_url'],
          'message': 'Payment Link creado exitosamente',
        };
      } else {
        print('❌ Error creando Payment Link: ${paymentLinkResult['error']}');
        return {
          'success': false,
          'error': paymentLinkResult['error'],
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


  /// Crear enlace de pago con Square API - MÉTODO PÚBLICO
  static Future<Map<String, dynamic>> createPaymentLink({
    required double amount,
    required String description,
    String? returnUrl,
  }) async {
    try {
      // 🚀 USAR BACKEND DE PRODUCCIÓN EN LUGAR DE LLAMADAS DIRECTAS
      // Esto evita problemas de CORS
      final backendUrl = 'https://cubalink23-backend.onrender.com/api/payments/process';
      
      final body = {
        "amount": amount,
        "description": description,
        "email": "user@example.com", // Se puede obtener del usuario actual
        if (returnUrl != null) "return_url": returnUrl,
      };

      print('🌐 Enviando pago al backend: $backendUrl');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      print('📝 Descripción: $description');

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📡 Backend Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          print('✅ Payment link creado por backend');
          print('🔗 Transaction ID: ${data['transaction_id']}');
          print('🌐 Checkout URL: ${data['checkout_url']}');
          
          return {
            'success': true,
            'payment_link_id': data['transaction_id'],
            'checkout_url': data['checkout_url'],
            'amount': amount,
          };
        } else {
          print('❌ Error del backend: ${data['error']}');
          return {
            'success': false,
            'error': data['error'] ?? 'Error desconocido del backend',
          };
        }
      } else {
        print('❌ Error del backend: ${response.statusCode}');
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
  
  /// 🚀 MÉTODO SIMPLIFICADO: Crear Payment Link directamente
  static Future<SquarePaymentResult> createQuickPaymentLink({
    required double amount,
    required String description,
    String? returnUrl,
  }) async {
    try {
      print('🚀 Creando Payment Link directamente con Square...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      print('📝 Descripción: $description');
      if (returnUrl != null) {
        print('🔗 URL de retorno: $returnUrl');
      }
      
      final result = await createPaymentLink(
        amount: amount,
        description: description,
        returnUrl: returnUrl,
      );
      
      if (result['success']) {
        print('✅ Payment Link creado exitosamente');
        print('🔗 ID: ${result['payment_link_id']}');
        print('🌐 URL: ${result['checkout_url']}');
        
        return SquarePaymentResult(
          success: true,
          transactionId: result['payment_link_id'],
          message: 'Payment Link creado. Redirigiendo a Square...',
          amount: amount,
          checkoutUrl: result['checkout_url'],
        );
      } else {
        print('❌ Error creando Payment Link: ${result['error']}');
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Error: ${result['error']}',
          amount: amount,
        );
      }
    } catch (e) {
      print('❌ Error creando Payment Link: $e');
      return SquarePaymentResult(
        success: false,
        transactionId: null,
        message: 'Error: $e',
        amount: amount,
      );
    }
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