import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class SquareWebViewService {
  static const String _backendUrl = 'https://cubalink23-payments.onrender.com';

  /// Abre WebView embebido para tokenizar tarjeta y procesar pago
  static Future<Map<String, dynamic>?> openTokenizeSheet({
    required BuildContext context,
    required int amountCents,
    required String customerId,
    String currency = 'USD',
    String note = 'CubaLink23',
    String? cardNumber,
    String? cardExpiry,
    String? cardCvv,
  }) async {
    var urlString = '$_backendUrl/sdk/card'
        '?mode=pay&amount=$amountCents&currency=$currency'
        '&customer_id=${Uri.encodeComponent(customerId)}'
        '&note=${Uri.encodeComponent(note)}';
    
    // ✅ Pre-llenar datos si se proporcionan
    if (cardNumber != null) {
      urlString += '&prefill_number=${Uri.encodeComponent(cardNumber)}';
    }
    if (cardExpiry != null) {
      urlString += '&prefill_expiry=${Uri.encodeComponent(cardExpiry)}';
    }
    if (cardCvv != null) {
      urlString += '&prefill_cvv=${Uri.encodeComponent(cardCvv)}';
    }
    
    final url = Uri.parse(urlString);

    print('🌐 Abriendo WebView tokenización: $url');

    // Configurar WebView controller
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          print('🔄 WebView cargando: $url');
        },
        onPageFinished: (String url) {
          print('✅ WebView cargado: $url');
        },
        onWebResourceError: (WebResourceError error) {
          print('❌ WebView error: ${error.description}');
        },
      ))
      ..addJavaScriptChannel(
        'ReactNativeWebView',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            print('🔥 MENSAJE RECIBIDO EN FLUTTER: ${message.message}');
            final data = jsonDecode(message.message);
            print('📨 Mensaje parseado: $data');
            
            // Cerrar WebView y devolver resultado
            final result = data['data'] ?? data;
            print('🎯 Resultado final: $result');
            Navigator.of(context).pop(result);
          } catch (e) {
            print('❌ Error parseando mensaje: $e');
            print('❌ Mensaje original: ${message.message}');
            Navigator.of(context).pop({
              'status': 'FAILED',
              'error': 'Error parseando respuesta: $e'
            });
          }
        },
      )
      ..loadRequest(url);

    // Abrir WebView en modal
    return await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('🔒 Pago Final - ¿Estás seguro?'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop({
                  'status': 'CANCELLED',
                  'message': 'Usuario canceló el pago'
                });
              },
            ),
          ),
          body: WebViewWidget(controller: controller),
        ),
      ),
    );
  }

  /// Cobrar con tarjeta guardada (Card on File)
  static Future<Map<String, dynamic>> chargeCardOnFile({
    required String customerId,
    required String cardId,
    required int amountCents,
    String currency = 'USD',
    String note = 'CubaLink23',
  }) async {
    try {
      print('💳 Cobrando tarjeta guardada...');
      print('👤 Customer: $customerId');
      print('💳 Card: $cardId');
      print('💰 Monto: $amountCents cents');

      final response = await http.post(
        Uri.parse('$_backendUrl/api/payments'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'customer_id': customerId,
          'card_id': cardId,
          'amount_cents': amountCents,
          'currency': currency,
          'note': note,
        }),
      );

      final data = jsonDecode(response.body);
      print('📨 Respuesta backend: $data');

      return {
        'status': data['status'] ?? 'FAILED',
        'success': data['status'] == 'COMPLETED',
        'payment_id': data['payment_id'],
        'receipt_url': data['receipt_url'],
        'amount': data['amount'],
        'last4': data['last4'],
        'message': data['message'] ?? 'Pago procesado',
        'code': data['code'],
      };
    } catch (e) {
      print('❌ Error cobrando tarjeta guardada: $e');
      return {
        'status': 'FAILED',
        'success': false,
        'message': 'Error de conexión: $e',
        'code': 'CONNECTION_ERROR',
      };
    }
  }

  /// Obtener tarjetas guardadas del usuario
  static Future<List<Map<String, dynamic>>> getCustomerCards(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/cards/list?customer_id=$customerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['cards'] ?? []);
      } else {
        print('❌ Error obteniendo tarjetas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error obteniendo tarjetas: $e');
      return [];
    }
  }
}
