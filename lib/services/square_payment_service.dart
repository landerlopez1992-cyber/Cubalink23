// Servicio híbrido que combina implementación directa y wrapper oficial
// Preserva funcionalidad completa de Square con seguridad mejorada

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'square_payment_service_official.dart' as official;

export 'square_payment_service_official.dart' show SquarePaymentResult;

class SquarePaymentService {
  // Credenciales de Square Sandbox (VÁLIDAS)
  static const String _locationId = 'LZVTP0YQ9YQBB';
  static const String _accessToken = 'EAAAl4WnC2APxLhZXN1HJrn5CPWQGd-wXe_PpQm6vPvdOBHj1xWINxP3s7uOpvYO';
  static const String _environment = 'sandbox';
  static const String _baseUrl = 'https://connect.squareupsandbox.com';

  /// Initialize Square Payment Service (HÍBRIDO)
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
        print('✅ Square inicializado correctamente (Híbrido)');
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

  /// Procesar pago REAL con Square (HÍBRIDO)
  static Future<SquarePaymentResult> processPayment({
    required double amount,
    required String description,
    String? cardLast4,
    String? cardType,
    String? cardHolderName,
  }) async {
    try {
      print('💳 Procesando pago REAL con Square (Híbrido)...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      if (cardLast4 != null) print('💳 Tarjeta: $cardType ****$cardLast4');
      if (cardHolderName != null) print('👤 Titular: $cardHolderName');
      
      // ========== PROCESAR PAGO REAL CON SQUARE API ==========
      final paymentResult = await _processRealSquarePayment(
        amount: amount,
        description: description,
      );

      if (paymentResult['success']) {
        print('✅ Payment Link creado exitosamente');
        print('💳 Transaction ID: ${paymentResult['transaction_id']}');
        print('🔗 Checkout URL: ${paymentResult['checkout_url']}');
        
        return SquarePaymentResult(
          success: true,
          transactionId: paymentResult['transaction_id'],
          message: 'Payment Link creado. Redirigiendo a Square...',
          amount: amount,
          checkoutUrl: paymentResult['checkout_url'],
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

  /// Procesar pago real con Square API - LLAMADA DIRECTA
  static Future<Map<String, dynamic>> _processRealSquarePayment({
    required double amount,
    required String description,
  }) async {
    try {
      print('💳 Procesando pago REAL con Square API - LLAMADA DIRECTA...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      
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
      final body = {
        "quick_pay": {
          "name": description,
          "price_money": {
            "amount": (amount * 100).round(), // Convertir a centavos
            "currency": "USD"
          },
          "location_id": _locationId,
          if (returnUrl != null) "redirect_url": returnUrl,
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
        
        // Usar 'url' que es lo que Square realmente devuelve
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