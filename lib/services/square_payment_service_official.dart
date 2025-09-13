// SQUARE PAYMENT SERVICE - IMPLEMENTACIÓN OFICIAL
// Compatible con iOS, Android y Web

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class SquarePaymentServiceOfficial {
  // Configuración de Square (Sandbox)
  static const String _applicationId = 'sandbox-sq0idb-IsIJtKqx2OHdVJjYmg6puA';
  static const String _locationId = 'LZVTP0YQ9YQBB';
  static const String _backendUrl = 'https://cubalink23-backend.onrender.com/api/payments/process';

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

  /// Procesar pago - Usa Payment Links para experiencia segura
  static Future<SquarePaymentResult> processPayment({
    required double amount,
    required String description,
  }) async {
    try {
      print('💳 Iniciando flujo de pago con Square Payment Links...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      print('📝 Descripción: $description');

      return await _processPaymentWithLinks(
        amount: amount,
        description: description,
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

  /// Procesar pago con Payment Links
  static Future<SquarePaymentResult> _processPaymentWithLinks({
    required double amount,
    required String description,
  }) async {
    try {
      print('🌐 Creando Payment Link con Square...');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      print('📝 Descripción: $description');

      final body = {
        "amount": amount,
        "description": description,
        "location_id": _locationId,
        "email": "user@cubalink23.com",
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

        if (data['success'] == true && data['checkout_url'] != null) {
          print('✅ Payment Link creado exitosamente');
          print('🔗 Checkout URL: ${data['checkout_url']}');

          return SquarePaymentResult(
            success: true,
            transactionId: data['payment_id'] ?? 'square_${DateTime.now().millisecondsSinceEpoch}',
            message: 'Payment Link creado exitosamente',
            amount: amount,
            checkoutUrl: data['checkout_url'],
          );
        } else {
          print('❌ Error del backend: ${data['error']}');
          return SquarePaymentResult(
            success: false,
            transactionId: null,
            message: data['error'] ?? 'Error creando Payment Link',
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