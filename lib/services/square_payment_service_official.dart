// SQUARE IN-APP PAYMENTS SDK - IMPLEMENTACIÓN OFICIAL
// Usando el SDK oficial de Square para Flutter

import 'package:square_in_app_payments/square_in_app_payments.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SquarePaymentServiceOfficial {
  // Configuración de Square (Sandbox)
  static const String _applicationId = 'sandbox-sq0idb-IsIJtKqx2OHdVJjYmg6puA';
  static const String _locationId = 'LZVTP0YQ9YQBB';
  static const String _backendUrl =
      'https://cubalink23-backend.onrender.com/api/payments/process';

  /// Inicializar Square In-App Payments SDK
  static Future<void> initialize() async {
    try {
      await SquareInAppPayments.setSquareApplicationId(_applicationId);
      print('✅ Square In-App Payments SDK inicializado correctamente');
      print('🔗 Application ID: $_applicationId');
      print('📍 Location ID: $_locationId');
    } catch (e) {
      print('❌ Error inicializando Square SDK: $e');
      rethrow;
    }
  }

  /// Procesar pago usando el SDK oficial de Square
  static Future<SquarePaymentResult> processPayment({
    required double amount,
    required String description,
  }) async {
    try {
      print('💳 Iniciando flujo de pago con Square In-App Payments SDK...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      print('📝 Descripción: $description');

      // 1. Iniciar el flujo de entrada de tarjeta
      final cardEntryResult = await SquareInAppPayments.startCardEntryFlow(
        collectPostalCode: false,
      );

      if (cardEntryResult is CardEntryResult) {
        print('✅ Tarjeta ingresada exitosamente');
        print('🔑 Nonce obtenido: ${cardEntryResult.nonce}');

        // 2. Enviar el nonce al backend para procesar el pago
        final paymentResult = await _processPaymentWithNonce(
          nonce: cardEntryResult.nonce,
          amount: amount,
          description: description,
        );

        return paymentResult;
      } else if (cardEntryResult is CardEntryCancelResult) {
        print('❌ Usuario canceló el ingreso de tarjeta');
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Pago cancelado por el usuario',
          amount: amount,
        );
      } else {
        print('❌ Error en el flujo de entrada de tarjeta');
        return SquarePaymentResult(
          success: false,
          transactionId: null,
          message: 'Error en el flujo de entrada de tarjeta',
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

  /// Procesar pago con nonce en el backend
  static Future<SquarePaymentResult> _processPaymentWithNonce({
    required String nonce,
    required double amount,
    required String description,
  }) async {
    try {
      print('🌐 Enviando nonce al backend para procesar pago...');
      print('🔑 Nonce: $nonce');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');

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
        final data = json.decode(response.body);

        if (data['success'] == true) {
          print('✅ Pago procesado exitosamente');
          print('🔗 Transaction ID: ${data['transaction_id']}');

          return SquarePaymentResult(
            success: true,
            transactionId: data['transaction_id'],
            message: 'Pago procesado exitosamente',
            amount: amount,
          );
        } else {
          print('❌ Error del backend: ${data['error']}');
          return SquarePaymentResult(
            success: false,
            transactionId: null,
            message: data['error'] ?? 'Error procesando pago',
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
      print('❌ Error enviando nonce al backend: $e');
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
      await SquareInAppPayments.setSquareApplicationId(_applicationId);
      return true;
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

  SquarePaymentResult({
    required this.success,
    required this.transactionId,
    required this.message,
    required this.amount,
  });

  @override
  String toString() {
    return 'SquarePaymentResult(success: $success, transactionId: $transactionId, message: $message, amount: $amount)';
  }
}
