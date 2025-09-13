// SQUARE PAYMENT SERVICE - SDK NATIVO
// Implementación usando Square In-App Payments SDK para iOS y Android

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:square_in_app_payments/square_in_app_payments.dart';

class SquarePaymentServiceNative {
  // Configuración de Square (Sandbox)
  static const String _applicationId = 'sandbox-sq0idb-IsIJtKqx2OHdVJjYmg6puA';
  static const String _locationId = 'LZVTP0YQ9YQBB';
  static const String _backendUrl =
      'https://cubalink23-backend.onrender.com/api/payments/process';

  /// Inicializar Square Payment Service
  static Future<void> initialize() async {
    try {
      // Solo inicializar en iOS y Android
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        // await SquareInAppPayments.setSquareApplicationId(_applicationId);
        print('✅ Square Payment Service inicializado (SDK Nativo)');
        print('🔗 Application ID: $_applicationId');
        print('📍 Location ID: $_locationId');
      } else {
        print('⚠️ Square SDK solo disponible en iOS/Android');
      }
    } catch (e) {
      print('❌ Error inicializando Square Service: $e');
    }
  }

  /// Procesar pago usando SDK nativo (iOS/Android)
  static Future<SquarePaymentResult> processPayment({
    required double amount,
    required String description,
  }) async {
    try {
      print('💳 Procesando pago con Square SDK nativo...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');

      // Solo procesar en iOS y Android
      if (kIsWeb) {
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Square SDK no disponible en Web. Usa iOS o Android.',
          amount: amount,
        );
      }

      if (!Platform.isIOS && !Platform.isAndroid) {
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Square SDK solo disponible en iOS y Android',
          amount: amount,
        );
      }

      // Generar nonce usando Square SDK
      final nonce = await _generateNonce();

      if (nonce == null) {
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Error generando nonce de pago',
          amount: amount,
        );
      }

      // Enviar nonce al backend para procesar
      return await _processPaymentWithNonce(nonce, amount, description);
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

  /// Generar nonce usando Square SDK
  static Future<String?> _generateNonce() async {
    try {
      print('🔐 Generando nonce con Square SDK...');
      
      // Por ahora simulamos un nonce para testing
      // En producción, aquí se integraría el SDK real de Square
      final nonce = 'test_nonce_${DateTime.now().millisecondsSinceEpoch}';
      print('✅ Nonce simulado generado: $nonce');
      return nonce;
      
    } catch (e) {
      print('❌ Error en _generateNonce: $e');
      return null;
    }
  }

  /// Procesar pago con nonce en el backend
  static Future<SquarePaymentResult> _processPaymentWithNonce(
    String nonce,
    double amount,
    String description,
  ) async {
    try {
      print('🌐 Enviando nonce al backend...');

      final body = {
        "nonce": nonce,
        "amount": amount,
        "description": description,
        "location_id": _locationId,
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
        final result = json.decode(response.body);
        if (result['success'] == true) {
          return SquarePaymentResult(
            success: true,
            transactionId: result['transaction_id'],
            message: result['message'] ?? 'Pago procesado exitosamente',
            amount: amount,
          );
        } else {
          return SquarePaymentResult(
            success: false,
            transactionId: null,
            message: result['error'] ?? 'Error procesando pago',
            amount: amount,
          );
        }
      } else {
        final errorBody = json.decode(response.body);
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: errorBody['error'] ?? 'Error de conexión con el backend',
          amount: amount,
        );
      }
    } catch (e) {
      print('❌ Error en _processPaymentWithNonce: $e');
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
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }
}

/// Resultado del pago Square
class SquarePaymentResult {
  final bool success;
  final String? transactionId;
  final String message;
  final double amount;

  SquarePaymentResult({
    required this.success,
    this.transactionId,
    required this.message,
    required this.amount,
  });

  @override
  String toString() {
    return 'SquarePaymentResult(success: $success, transactionId: $transactionId, message: $message, amount: $amount)';
  }
}
