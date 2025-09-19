// SQUARE PAYMENT SERVICE - IMPLEMENTACIÓN OFICIAL
// Compatible con iOS, Android y Web

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'square_webview_service.dart';

class SquarePaymentServiceOfficial {
  // Configuración de Square (Sandbox)
  static const String _applicationId = 'sandbox-sq0idb-IsIJtKqx2OHdVJjYmg6puA';
  static const String _locationId = 'LZVTP0YQ9YQBB';
  static const String _backendUrl = 'https://cubalink23-payments.onrender.com';

  /// Inicializar Square Payment Service
  static Future<void> initialize() async {
    try {
      print('✅ Square Payment Service inicializado');
      print('🔗 Application ID: $_applicationId');
      print('📍 Location ID: $_locationId');
    } catch (e) {
      print('❌ Error inicializando Square Service: $e');
    }
  }

  /// Procesar pago - Con WebView para tokenización REAL
  static Future<SquarePaymentResult> processPayment({
    required BuildContext context,
    required double amount,
    required String description,
    String? cardLast4,
    String? cardType,
    String? cardHolderName,
    String? customerId,
    String? cardId,
  }) async {
    try {
      print('💳 Procesando pago con Square...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      print('📝 Descripción: $description');

      final amountCents = (amount * 100).round();
      final userId = customerId ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
      print('👤 Customer ID para WebView: $userId');

      // ⚠️ TEMPORAL: Las tarjetas de Supabase NO son válidas para Square
      // Necesitamos crear tarjetas reales en Square primero
      print('⚠️ Tarjetas de Supabase no son válidas para Square - usando WebView');
      
      // ✅ NUEVA TARJETA - Solo usar WebView para tarjetas nuevas
      print('🌐 Tarjeta nueva - usando WebView para tokenizar');

      // Si no tiene tarjeta guardada, abrir WebView para tokenizar
      print('🌐 Abriendo WebView para tokenización...');
      
      // ✅ SIEMPRE pre-llenar con tarjetas de prueba válidas de Square
      String prefillNumber, prefillExpiry, prefillCvv;
      
      if (cardType?.toLowerCase().contains('visa') == true) {
        prefillNumber = '4111 1111 1111 1111'; // Visa exitosa
        prefillExpiry = '12/25';
        prefillCvv = '123';
      } else if (cardType?.toLowerCase().contains('master') == true) {
        prefillNumber = '5105 1051 0510 5100'; // Mastercard exitosa
        prefillExpiry = '11/26';
        prefillCvv = '456';
      } else {
        // Por defecto usar Visa exitosa
        prefillNumber = '4111 1111 1111 1111';
        prefillExpiry = '12/25';
        prefillCvv = '123';
      }
      
      print('🎯 Pre-llenando: $cardType → $prefillNumber');
      print('🌐 Usando WebView con backend REAL: https://cubalink23-payments.onrender.com');
      
      final result = await SquareWebViewService.openTokenizeSheet(
        context: context,
        amountCents: amountCents,
        customerId: userId,
        note: description,
        cardNumber: prefillNumber,
        cardExpiry: prefillExpiry,
        cardCvv: prefillCvv,
      );

      if (result == null) {
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Pago cancelado por el usuario',
          amount: amount,
        );
      }

      final success = result['status'] == 'COMPLETED';
      print('🎯 Resultado WebView: $result');
      print('📊 Success: $success');
      print('💬 Message: ${result['message']}');
      
      return SquarePaymentResult(
        success: success,
        transactionId: result['payment_id'] ?? result['id'], // Probar ambos campos
        message: result['message'] ?? (success ? 'Pago exitoso' : 'Pago fallido'),
        amount: amount,
      );
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

  /// Procesar pago con nonce específico
  static Future<SquarePaymentResult> _processPaymentWithNonce({
    required double amount,
    required String description,
    required String nonce,
  }) async {
    try {
      print('🌐 Procesando pago con nonce: $nonce');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      print('📝 Descripción: $description');

      final body = {
        "nonce": nonce,
        "amount_cents": (amount * 100).round(),
        "currency": "USD",
        "note": description,
      };

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📡 Backend Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Si hay status COMPLETED, es exitoso
        if (data['status'] == 'COMPLETED') {
          print('✅ Pago exitoso: ${data['id']}');
          return SquarePaymentResult(
            success: true,
            transactionId: data['id'],
            message: 'Pago procesado exitosamente',
            amount: amount,
          );
        } else {
          // Si hay status pero no es COMPLETED, es error
          print('❌ Pago fallido: ${data['status']}');
          return SquarePaymentResult(
            success: false,
            transactionId: null,
            message: 'Pago fallido: ${data['status']}',
            amount: amount,
          );
        }
      } else {
        // Error HTTP - extraer mensaje de Square
        String errorMessage = 'Error procesando pago';
        if (data['error'] != null && data['error']['errors'] != null) {
          final errors = data['error']['errors'] as List;
          if (errors.isNotEmpty) {
            final firstError = errors.first;
            final code = firstError['code'];
            final detail = firstError['detail'];
            
            // Mensajes amigables según el código de error
            switch (code) {
              case 'GENERIC_DECLINE':
                errorMessage = 'Tu tarjeta fue declinada. Intenta con otra tarjeta.';
                break;
              case 'INSUFFICIENT_FUNDS':
                errorMessage = 'Fondos insuficientes en tu tarjeta.';
                break;
              case 'CVV_FAILURE':
                errorMessage = 'El código CVV es incorrecto.';
                break;
              case 'EXPIRED_CARD':
                errorMessage = 'Tu tarjeta ha expirado.';
                break;
              default:
                errorMessage = detail ?? code ?? errorMessage;
            }
          }
        }

        print('❌ Error HTTP ${response.statusCode}: $errorMessage');
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: errorMessage,
          amount: amount,
        );
      }
    } catch (e) {
      print('💥 Error en _processPaymentWithNonce: $e');
      return SquarePaymentResult(
        success: false,
        transactionId: null,
        message: 'Error de conexión: $e',
        amount: amount,
      );
    }
  }

  /// Procesar pago con Payment Links (método original - mantener para compatibilidad)
  static Future<SquarePaymentResult> _processPaymentWithLinks({
    required double amount,
    required String description,
  }) async {
    try {
      print('🌐 Creando Payment Link con Square...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      print('📝 Descripción: $description');

      final body = {
        "nonce": "cnon:card-nonce-ok", // Tarjeta de prueba exitosa
        "amount_cents": (amount * 100).round(),
        "currency": "USD",
        "note": description,
      };

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📡 Backend Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'COMPLETED') {
          print('✅ Pago procesado exitosamente');
          print('🆔 Transaction ID: ${data['id']}');

          return SquarePaymentResult(
            success: true,
            transactionId: data['id'],
            message: 'Pago procesado exitosamente',
            amount: amount,
          );
        } else {
          print('❌ Error del backend: ${data['status']}');
          return SquarePaymentResult(
            success: false,
            transactionId: null,
            message: 'Error procesando pago: ${data['status']}',
            amount: amount,
          );
        }
      } else {
        print('❌ Error del backend: ${response.statusCode}');
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Error del servidor: ${response.statusCode}',
          amount: amount,
        );
      }
    } catch (e) {
      print('❌ Error creando Payment Link: $e');
      return SquarePaymentResult(
        success: false,
        transactionId: null,
        message: 'Error de conexión: $e',
        amount: amount,
      );
    }
  }

  /// Cobrar tarjeta guardada (Card on File) - SIN FORMULARIO
  static Future<Map<String, dynamic>> _chargeCardOnFile({
    required String customerId,
    required String cardId,
    required int amountCents,
    String note = 'CubaLink23',
  }) async {
    try {
      print('💳 Cobrando Card on File...');
      print('👤 Customer: $customerId');
      print('💳 Card: $cardId');
      print('💰 Amount: $amountCents cents');

      final response = await http.post(
        Uri.parse('https://cubalink23-payments.onrender.com/api/payments/charge-card-on-file'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_id': customerId,
          'card_id': cardId,
          'amount': amountCents,
          'currency': 'USD',
          'note': note,
        }),
      );

      final data = json.decode(response.body);
      print('📨 Respuesta Card on File: $data');

      return data;
    } catch (e) {
      print('❌ Error Card on File: $e');
      return {
        'ok': false,
        'square': {'error': 'Error de conexión: $e'}
      };
    }
  }

  /// Verificar si Square está disponible
  static Future<bool> isSquareAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('https://cubalink23-backend.onrender.com/api/health'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Square no está disponible: $e');
      return false;
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

/// Crear Payment Link - MÉTODO SIMPLE Y DIRECTO
class SquarePaymentLinks {
  static Future<Map<String, dynamic>> createPaymentLink({
    required double amount,
    required String currency,
    required String note,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://cubalink23-payments.onrender.com/api/payment-links/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (amount * 100).round(),
          'currency': currency,
          'note': note,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'checkoutUrl': data['payment_url'],
          'paymentLinkId': data['payment_link_id'],
          'transactionId': data['payment_link_id'],
          'amount': amount,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Error creando payment link',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }
}