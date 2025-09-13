// SQUARE PAYMENT SERVICE - IMPLEMENTACIÓN CON PAYMENT LINKS
// Compatible con iOS, Android y Web

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'square_payment_service_native.dart';

class SquarePaymentServiceOfficial {
  // Configuración de Square (Sandbox)
  static const String _applicationId = 'sandbox-sq0idb-IsIJtKqx2OHdVJjYmg6puA';
  static const String _locationId = 'LZVTP0YQ9YQBB';
  static const String _backendUrl =
      'https://cubalink23-backend.onrender.com/api/payments/process';

  /// Inicializar Square Payment Service
  static Future<void> initialize() async {
    try {
      // Inicializar SDK nativo para iOS/Android
      await SquarePaymentServiceNative.initialize();
      print('✅ Square Payment Service inicializado (Híbrido)');
      print('🔗 Application ID: $_applicationId');
      print('📍 Location ID: $_locationId');
    } catch (e) {
      print('❌ Error inicializando Square Service: $e');
      // No rethrow para permitir que la app continúe
    }
  }

  /// Procesar pago - Híbrido: SDK nativo para iOS/Android, Payment Links para Web
  static Future<SquarePaymentResult> processPayment({
    required double amount,
    required String description,
  }) async {
    try {
      // Usar SDK nativo para iOS/Android
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        print('📱 Usando SDK nativo para iOS/Android');
        final result = await SquarePaymentServiceNative.processPayment(
          amount: amount,
          description: description,
        );
        return SquarePaymentResult(
          success: result.success,
          transactionId: result.transactionId,
          message: result.message,
          amount: result.amount,
        );
      }

      // Usar Payment Links para Web
      print('🌐 Usando Payment Links para Web');
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
        "email": "user@cubalink23.com", // Email requerido por el backend
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

          // Abrir el Payment Link
          final urlOpened = await _openCheckoutUrl(data['checkout_url']);

          if (urlOpened) {
            return SquarePaymentResult(
              success: true,
              transactionId: data['payment_id'],
              message: 'Payment Link abierto exitosamente',
              amount: amount,
              checkoutUrl: data['checkout_url'],
            );
          } else {
            return SquarePaymentResult(
              success: false,
              transactionId: null,
              message: 'No se pudo abrir el Payment Link',
              amount: amount,
            );
          }
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

  /// Abrir URL de checkout
  static Future<bool> _openCheckoutUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        print('❌ No se puede abrir la URL: $url');
        return false;
      }
    } catch (e) {
      print('❌ Error abriendo URL: $e');
      return false;
    }
  }

  /// Verificar si Square está disponible
  static Future<bool> isSquareAvailable() async {
    try {
      // Verificar conectividad básica
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
