import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para integración con DingConnect API
/// Maneja recargas telefónicas internacionales
class DingConnectService {
  // Singleton pattern
  static final DingConnectService _instance = DingConnectService._internal();
  factory DingConnectService() => _instance;
  static DingConnectService get instance => _instance;
  DingConnectService._internal();

  static const String _baseUrl = 'https://api.dingconnect.com';
  static const String _apiKey = 'FwWpRyjdmGx5svJAWx2M4N'; // API Key de DingConnect
  static const String _version = 'v1';
  
  // Headers estándar para todas las requests
  static Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Obtener productos disponibles para un país
  Future<Map<String, dynamic>> getProducts({
    String? countryIso,
    String? operatorCode,
  }) async {
    try {
      print('🌍 Obteniendo productos de DingConnect...');
      print('🏳️ País: $countryIso');
      print('📱 Operador: $operatorCode');
      
      String url = '$_baseUrl/$_version/products';
      
      // Agregar parámetros de consulta
      List<String> queryParams = [];
      if (countryIso != null) queryParams.add('country_iso=$countryIso');
      if (operatorCode != null) queryParams.add('operator_code=$operatorCode');
      
      if (queryParams.isNotEmpty) {
        url += '?' + queryParams.join('&');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      print('📡 DingConnect Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Productos obtenidos exitosamente');
        print('📊 Total productos: ${data['items']?.length ?? 0}');
        
        return {
          'success': true,
          'products': data['items'] ?? [],
          'message': 'Productos obtenidos exitosamente',
        };
      } else {
        print('❌ Error obteniendo productos: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error en getProducts: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Obtener operadores disponibles para un país
  static Future<Map<String, dynamic>> getOperators(String countryIso) async {
    try {
      print('📱 Obteniendo operadores para: $countryIso');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$_version/operators?country_iso=$countryIso'),
        headers: _headers,
      );
      
      print('📡 Operators Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Operadores obtenidos exitosamente');
        
        return {
          'success': true,
          'operators': data['items'] ?? [],
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
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Obtener países disponibles
  static Future<Map<String, dynamic>> getCountries() async {
    try {
      print('🌍 Obteniendo países disponibles...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$_version/countries'),
        headers: _headers,
      );
      
      print('📡 Countries Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Países obtenidos exitosamente');
        
        return {
          'success': true,
          'countries': data['items'] ?? [],
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
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Realizar una recarga telefónica
  static Future<Map<String, dynamic>> sendTopup({
    required String phoneNumber,
    required String productId,
    required double amount,
    String? distributorRef,
  }) async {
    try {
      print('📞 Enviando recarga...');
      print('📱 Número: $phoneNumber');
      print('🆔 Producto: $productId');
      print('💰 Monto: \$${amount.toStringAsFixed(2)}');
      
      final body = {
        'phone_number': phoneNumber,
        'product_id': productId,
        'distributor_ref': distributorRef ?? 'cubalink23_${DateTime.now().millisecondsSinceEpoch}',
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/$_version/send'),
        headers: _headers,
        body: json.encode(body),
      );
      
      print('📡 Send Topup Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Recarga enviada exitosamente');
        print('🆔 Transaction ID: ${data['id']}');
        
        return {
          'success': true,
          'transaction_id': data['id'],
          'status': data['status'],
          'amount': data['amount'],
          'phone_number': data['phone_number'],
          'message': 'Recarga enviada exitosamente',
          'data': data,
        };
      } else {
        print('❌ Error enviando recarga: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error en sendTopup: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Obtener estado de una transacción
  static Future<Map<String, dynamic>> getTransactionStatus(String transactionId) async {
    try {
      print('🔍 Verificando estado de transacción: $transactionId');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$_version/lookup/$transactionId'),
        headers: _headers,
      );
      
      print('📡 Transaction Status Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Estado obtenido: ${data['status']}');
        
        return {
          'success': true,
          'transaction_id': data['id'],
          'status': data['status'],
          'amount': data['amount'],
          'phone_number': data['phone_number'],
          'created_at': data['created_at'],
          'data': data,
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
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Obtener balance de la cuenta
  Future<Map<String, dynamic>> getAccountBalance() async {
    try {
      print('💰 Obteniendo balance de cuenta DingConnect...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$_version/account'),
        headers: _headers,
      );
      
      print('📡 Account Balance Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Balance obtenido: \$${data['balance']}');
        
        return {
          'success': true,
          'balance': data['balance'],
          'currency': data['currency'] ?? 'USD',
          'data': data,
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
        'error': 'Error de conexión: $e',
      };
    }
  }

  /// Validar número telefónico
  static bool isValidPhoneNumber(String phoneNumber) {
    // Remover espacios y caracteres especiales
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Debe tener al menos 7 dígitos y máximo 15
    // Puede empezar con + para código de país
    final regex = RegExp(r'^\+?[1-9]\d{6,14}$');
    
    return regex.hasMatch(cleanNumber);
  }

  /// Formatear número telefónico
  static String formatPhoneNumber(String phoneNumber) {
    // Remover espacios y caracteres especiales excepto +
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Obtener código de país desde número telefónico
  static String? getCountryCodeFromNumber(String phoneNumber) {
    final cleanNumber = formatPhoneNumber(phoneNumber);
    
    // Mapeo básico de códigos de país
    final countryCodes = {
      '+1': 'US', // Estados Unidos/Canadá
      '+53': 'CU', // Cuba
      '+34': 'ES', // España
      '+52': 'MX', // México
      '+57': 'CO', // Colombia
      '+58': 'VE', // Venezuela
      '+507': 'PA', // Panamá
    };
    
    for (final entry in countryCodes.entries) {
      if (cleanNumber.startsWith(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Validar número de teléfono
  Future<Map<String, dynamic>> validatePhoneNumber(String phoneNumber, String countryCode) async {
    try {
      // Simulación de validación
      print('📱 Validando número: $phoneNumber para $countryCode');
      
      // Por ahora retornamos siempre válido
      return {
        'success': true,
        'isValid': true,
        'message': 'Número válido'
      };
    } catch (e) {
      return {
        'success': false,
        'isValid': false,
        'message': 'Error validando número: $e'
      };
    }
  }

  /// Obtener estado de orden
  Future<Map<String, dynamic>> getOrderStatus(String orderId) async {
    try {
      print('📋 Obteniendo estado de orden: $orderId');
      
      // Por ahora retornamos un estado genérico
      return {
        'success': true,
        'status': 'completed',
        'message': 'Orden completada'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error obteniendo estado: $e'
      };
    }
  }

  /// Formatear producto para UI
  static Map<String, dynamic> formatProductForUI(dynamic product) {
    if (product is Map<String, dynamic>) {
      return product;
    }
    return {
      'title': 'Producto',
      'description': 'Descripción del producto',
      'price': 0.0
    };
  }
}
