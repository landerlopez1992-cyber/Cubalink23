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
  static const String _backendUrl = 'https://cubalink23-payments.onrender.com/api/payments';

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

      // ⚠️ TEMPORAL: Siempre usar WebView hasta implementar Card on File correctamente
      // Las tarjetas guardadas en Supabase NO son tarjetas reales de Square
      print('🌐 Forzando WebView - tarjetas Supabase no son válidas para Square');

      // Si no tiene tarjeta guardada, abrir WebView para tokenizar
      print('🌐 Abriendo WebView para tokenización...');
      
      // ✅ Pre-llenar datos si se proporcionan (de tarjeta seleccionada)
      String? prefillNumber, prefillExpiry, prefillCvv;
      if (cardLast4 != null) {
        // Reconstruir número basado en tipo y last4
        if (cardType?.toLowerCase().contains('visa') == true) {
          prefillNumber = '4111 1111 1111 1111'; // Visa de prueba
        } else if (cardType?.toLowerCase().contains('master') == true) {
          prefillNumber = '5105 1051 0510 5100'; // Mastercard de prueba
        }
        prefillExpiry = '12/25'; // Fecha de prueba
        prefillCvv = '123'; // CVV de prueba
      }
      
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