#!/usr/bin/env dart
// Script de prueba para transacción de \$5.00 con tarjeta de éxito

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🚀 PRUEBA DE TRANSACCIÓN REAL - \$5.00');
  print('👤 Usuario: Lander Lopez');
  print('💳 Tarjeta: Visa de éxito (4111 1111 1111 1111)');
  print('=' * 60);
  
  // Credenciales de Square Sandbox
  const String accessToken = 'EAAAl4WnC2APxLhZXN1HJrn5CPWQGd-wXe_PpQm6vPvdOBHj1xWINxP3s7uOpvYO';
  const String locationId = 'LZVTP0YQ9YQBB';
  const String baseUrl = 'https://connect.squareupsandbox.com';
  
  try {
    // 1. Verificar conexión con Square
    print('\n1️⃣ Verificando conexión con Square...');
    final locationsResponse = await _makeRequest(
      'GET',
      '$baseUrl/v2/locations',
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Square-Version': '2024-12-01',
      },
    );
    
    if (locationsResponse['statusCode'] == 200) {
      print('✅ Conexión con Square exitosa');
      final data = jsonDecode(locationsResponse['body']);
      final locations = data['locations'] as List;
      if (locations.isNotEmpty) {
        final location = locations.first;
        print('📍 Location: ${location['name']} (${location['id']})');
        print('🏪 Address: ${location['address']['address_line_1']}');
      }
    } else {
      print('❌ Error conectando con Square: ${locationsResponse['statusCode']}');
      return;
    }
    
    // 2. Crear Payment Link de \$5.00
    print('\n2️⃣ Creando Payment Link de \$5.00...');
    final paymentLinkBody = {
      "quick_pay": {
        "name": "Recarga de saldo Cubalink23 - Lander Lopez",
        "price_money": {
          "amount": 500, // \$5.00 en centavos
          "currency": "USD"
        },
        "location_id": locationId,
        "description": "Recarga de saldo para usuario Lander Lopez"
      }
    };
    
    print('📤 Enviando request a Square...');
    print('💰 Monto: \$5.00 (500 centavos)');
    print('👤 Usuario: Lander Lopez');
    print('🏪 Location ID: $locationId');
    
    final paymentLinkResponse = await _makeRequest(
      'POST',
      '$baseUrl/v2/online-checkout/payment-links',
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Square-Version': '2024-12-01',
      },
      body: jsonEncode(paymentLinkBody),
    );
    
    print('\n📡 Respuesta de Square:');
    print('Status Code: ${paymentLinkResponse['statusCode']}');
    print('Response Body: ${paymentLinkResponse['body']}');
    
    if (paymentLinkResponse['statusCode'] == 200) {
      final data = jsonDecode(paymentLinkResponse['body']);
      final paymentLink = data['payment_link'];
      
      print('\n✅ Payment Link creado exitosamente!');
      print('🔗 Payment Link ID: ${paymentLink['id']}');
      print('🌐 Checkout URL: ${paymentLink['url']}');
      print('📝 Nombre: ${paymentLink['quick_pay']['name']}');
      print('💰 Monto: \$${(paymentLink['quick_pay']['price_money']['amount'] / 100).toStringAsFixed(2)}');
      print('🏪 Location: ${paymentLink['quick_pay']['location_id']}');
      
      // 3. Información para verificar en Square Console
      print('\n3️⃣ INFORMACIÓN PARA VERIFICAR EN SQUARE CONSOLE:');
      print('=' * 60);
      print('🔍 Ve a: https://developer.squareup.com/apps/sq0idp-yCkbpE8f6v71c3F-N7Y10g/log');
      print('📊 Busca por:');
      print('   - Payment Link ID: ${paymentLink['id']}');
      print('   - Amount: \$5.00');
      print('   - User: Lander Lopez');
      print('   - API: Checkout');
      print('   - Endpoint: POST /v2/online-checkout/payment-links');
      print('=' * 60);
      
      // 4. Instrucciones para completar el pago
      print('\n4️⃣ INSTRUCCIONES PARA COMPLETAR EL PAGO:');
      print('=' * 60);
      print('1. Abre esta URL en tu navegador:');
      print('   ${paymentLink['url']}');
      print('');
      print('2. Usa una tarjeta de prueba de éxito:');
      print('   💳 Visa: 4111 1111 1111 1111');
      print('   📅 Expiry: Cualquier fecha futura');
      print('   🔒 CVV: Cualquier 3 dígitos');
      print('   👤 Name: Lander Lopez');
      print('');
      print('3. Completa el pago en Square');
      print('4. Verifica los logs en Square Console');
      print('=' * 60);
      
    } else {
      print('❌ Error creando Payment Link:');
      print('Status: ${paymentLinkResponse['statusCode']}');
      print('Error: ${paymentLinkResponse['body']}');
    }
    
  } catch (e) {
    print('❌ Error en la prueba: $e');
  }
  
  print('\n${'=' * 60}');
  print('🏁 PRUEBA COMPLETADA');
  print('📊 Revisa los logs en Square Console para ver la transacción');
}

Future<Map<String, dynamic>> _makeRequest(
  String method,
  String url,
  {Map<String, String>? headers, String? body}
) async {
  final client = HttpClient();
  
  try {
    final uri = Uri.parse(url);
    final request = await client.openUrl(method, uri);
    
    // Agregar headers
    if (headers != null) {
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });
    }
    
    // Agregar body si existe
    if (body != null) {
      request.write(body);
    }
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    return {
      'statusCode': response.statusCode,
      'body': responseBody,
    };
  } finally {
    client.close();
  }
}
