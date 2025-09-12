import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para integrar con DingConnect API
/// API de recargas globales para más de 500 operadores en 140+ países
class DingConnectService {
  // URL base según documentación de DingConnect
  static const String _baseUrl = 'https://api.dingconnect.com/api/v1';
  static const String _apiKey = '3UEw1j1nazb6NK1dhgRD3Z'; // API Key proporcionada por el usuario
  
  static DingConnectService? _instance;
  static DingConnectService get instance => _instance ??= DingConnectService._();
  DingConnectService._();

  /// Obtener API Key para mostrar (solo primeros caracteres)
  String get apiKeyPreview => '${_apiKey.substring(0, 8)}...';

  /// Headers con api_key en headers (método 1)
  Map<String, String> get _headersWithApiKey => {
    'api_key': _apiKey,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'TuRecargaApp/1.0',
  };

  /// Headers con Bearer token (método 2)
  Map<String, String> get _headersWithBearer => {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'TuRecargaApp/1.0',
  };

  /// Headers básicos sin autenticación
  Map<String, String> get _headersBasic => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'TuRecargaApp/1.0',
  };

  /// Verificar conectividad con la API de DingConnect probando múltiples métodos de autenticación
  Future<bool> testApiConnection() async {
    try {
      print('🧪 DingConnect: Verificando conectividad de la API...');
      print('🔑 API Key: $apiKeyPreview');
      print('🔗 Base URL: $_baseUrl');
      
      final testUrl = '$_baseUrl/products';
      
      // MÉTODO 1: Probar con api_key en headers
      print('🔄 Método 1: API key en headers...');
      var response = await http.get(
        Uri.parse(testUrl),
        headers: _headersWithApiKey,
      ).timeout(Duration(seconds: 15));

      print('🧪 Método 1 - Status: ${response.statusCode}');
      print('🧪 Método 1 - Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ DingConnect API conectada exitosamente (API key en headers)');
        return true;
      }

      // MÉTODO 2: Probar con Bearer token
      print('🔄 Método 2: Bearer token...');
      response = await http.get(
        Uri.parse(testUrl),
        headers: _headersWithBearer,
      ).timeout(Duration(seconds: 15));

      print('🧪 Método 2 - Status: ${response.statusCode}');
      print('🧪 Método 2 - Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ DingConnect API conectada exitosamente (Bearer token)');
        return true;
      }

      // MÉTODO 3: Probar con API key en query parameter
      print('🔄 Método 3: API key en query parameter...');
      response = await http.get(
        Uri.parse('$testUrl?api_key=$_apiKey'),
        headers: _headersBasic,
      ).timeout(Duration(seconds: 15));
      
      print('🧪 Método 3 - Status: ${response.statusCode}');
      print('🧪 Método 3 - Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ DingConnect API conectada exitosamente (API key en query)');
        return true;
      }

      // MÉTODO 4: Probar endpoint alternativo products
      print('🔄 Método 4: Probando endpoint products...');
      response = await http.get(
        Uri.parse('$testUrl?api_key=$_apiKey'),
        headers: _headersBasic,
      ).timeout(Duration(seconds: 15));
      
      print('🧪 Método 4 - Status: ${response.statusCode}');
      print('🧪 Método 4 - Body: ${response.body.length > 200 ? "${response.body.substring(0, 200)}..." : response.body}');
      
      if (response.statusCode == 200) {
        print('✅ DingConnect API conectada exitosamente (products endpoint)');
        return true;
      }
      
      print('❌ Todos los métodos de autenticación fallaron');
      print('   - API Key usado: $apiKeyPreview');
      print('   - Último status code: ${response.statusCode}');
      print('   - Último error: ${response.body}');
      
      return false;
    } catch (e) {
      print('❌ Error en test de conectividad: $e');
      return false;
    }
  }

  /// Obtener balance de la cuenta DingConnect
  Future<double> getAccountBalance() async {
    try {
      print('🔍 DingConnect: Obteniendo balance de cuenta...');
      
      // Intentar obtener balance desde account
      var response = await http.get(
        Uri.parse('$_baseUrl/account'),
        headers: _headersWithBearer,
      );

      print('📊 DingConnect Account Response: ${response.statusCode}');
      
      // Si falla con Bearer, intentar con query parameter
      if (response.statusCode == 401) {
        print('🔄 Intentando con API key en query parameter...');
        response = await http.get(
          Uri.parse('$_baseUrl/account?api_key=$_apiKey'),
          headers: _headersBasic,
        );
        print('📊 DingConnect Account Response (Query): ${response.statusCode}');
      }
      
      if (response.statusCode == 200) {
        print('📦 Response Body: ${response.body}');
        final data = json.decode(response.body);
        
        // Múltiples formatos posibles de respuesta
        double balance = 0.0;
        if (data is Map<String, dynamic>) {
          balance = (data['balance'] ?? data['AccountBalance'] ?? data['Balance'] ?? data['creditBalance'] ?? 0.0).toDouble();
        } else if (data is num) {
          balance = data.toDouble();
        }
        
        print('💰 Balance DingConnect: \$${balance.toStringAsFixed(2)}');
        return balance;
      } else {
        print('❌ Error obteniendo balance: ${response.statusCode} - ${response.body}');
        return 0.0;
      }
    } catch (e) {
      print('❌ Excepción obteniendo balance DingConnect: $e');
      return 0.0;
    }
  }

  /// Obtener lista de países disponibles
  Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      print('🌍 DingConnect: Obteniendo países disponibles...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/countries'),
        headers: _headersWithBearer,
      );

      print('🌍 DingConnect Countries Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final countries = List<Map<String, dynamic>>.from(data['countries'] ?? data['Items'] ?? data);
        
        print('✅ Países cargados: ${countries.length}');
        for (var country in countries.take(5)) {
          print('   🏴 ${country['Name']} (${country['IsoCode']})');
        }
        
        return countries;
      } else {
        print('❌ Error obteniendo países: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Excepción obteniendo países: $e');
      return [];
    }
  }

  /// Obtener productos disponibles para un país específico
  /// [countryCode] - Código ISO del país (ej: 'CU' para Cuba, 'US' para Estados Unidos)
  Future<List<Map<String, dynamic>>> getProducts({String? countryCode, List<String>? benefits}) async {
    try {
      print('📱 DingConnect: Obteniendo productos ${countryCode != null ? 'para $countryCode' : 'globales'}...');
      
      // Construir URL con parámetros según documentación
      String url = '$_baseUrl/products';
      List<String> queryParts = [];
      
      if (countryCode != null) {
        queryParts.add('country=$countryCode');
      }
      if (benefits != null && benefits.isNotEmpty) {
        for (String benefit in benefits) {
          queryParts.add('benefit=$benefit');
        }
      }
      
      // Construir URL con parámetros
      if (queryParts.isNotEmpty) {
        url += '?${queryParts.join('&')}';
      }
      
      print('🔗 URL de petición: $url');
      
      var response = await http.get(
        Uri.parse(url),
        headers: _headersWithBearer,
      ).timeout(Duration(seconds: 20));
      
      print('📱 DingConnect Products Response: ${response.statusCode}');
      
      // Si falla con Bearer, intentar con query parameter
      if (response.statusCode == 401) {
        print('🔄 Intentando con API key en query parameter...');
        String separator = url.contains('?') ? '&' : '?';
        url += '${separator}api_key=$_apiKey';
        
        response = await http.get(
          Uri.parse(url),
          headers: _headersBasic,
        ).timeout(Duration(seconds: 20));
        
        print('📱 DingConnect Products Response (Query): ${response.statusCode}');
      }
      
      print('📦 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Manejo según documentación DingConnect
        List<Map<String, dynamic>> products = [];
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('products') && data['products'] is List) {
            products = List<Map<String, dynamic>>.from(data['products']);
          } else if (data.containsKey('data') && data['data'] is List) {
            products = List<Map<String, dynamic>>.from(data['data']);
          } else if (data.containsKey('Items') && data['Items'] is List) {
            products = List<Map<String, dynamic>>.from(data['Items']);
          } else if (data.containsKey('result') && data['result'] is List) {
            products = List<Map<String, dynamic>>.from(data['result']);
          }
        } else if (data is List) {
          products = List<Map<String, dynamic>>.from(data);
        }
        
        print('✅ Productos reales cargados: ${products.length}');
        
        if (products.isNotEmpty) {
          // Mostrar información de los primeros productos para debug
          print('📋 Primeros productos encontrados:');
          for (var product in products.take(3)) {
            final productId = product['productId'] ?? product['id'] ?? 'N/A';
            final name = product['name'] ?? product['title'] ?? 'Producto';
            final value = product['value'] ?? product['amount'] ?? 0;
            final currency = product['currency'] ?? 'USD';
            final description = product['description'] ?? 'Sin descripción';
            
            print('   📦 $name: $value $currency - ID: $productId');
            print('      📝 $description');
          }
          
          return products;
        } else {
          print('⚠️ API respondió exitosamente pero no hay productos disponibles');
        }
      } else {
        print('❌ Error HTTP obteniendo productos: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
      }
    } catch (e) {
      print('❌ Excepción obteniendo productos: $e');
    }
    
    // ❌ NO HAY PRODUCTOS DEMO - SOLO PRODUCTOS REALES DE LA API
    print('❌ NO SE PUEDEN CARGAR PRODUCTOS REALES DE DINGCONNECT API');
    print('⚠️  Verifica la API Key y conectividad de red');
    return [];
  }

  /// Obtener productos específicos para Cuba
  Future<List<Map<String, dynamic>>> getCubaProducts() async {
    print('🇨🇺 DingConnect: Obteniendo productos para Cuba...');
    return await getProducts(countryCode: 'CU');
  }

  /// Crear orden de recarga según documentación DingConnect
  Future<Map<String, dynamic>?> createOrder({
    required String phoneNumber,
    required String productId,
    required double value,
    String? customerOrderId,
  }) async {
    try {
      print('📤 DingConnect: Creando orden para $phoneNumber...');
      print('   📦 Product ID: $productId');
      print('   💰 Value: $value');
      
      final body = {
        'productId': productId,
        'phoneNumber': phoneNumber,
        'value': value,
        'customerOrderId': customerOrderId ?? 'CL_${DateTime.now().millisecondsSinceEpoch}',
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: _headersWithBearer,
        body: json.encode(body),
      );
      
      print('📤 DingConnect Order Response: ${response.statusCode}');
      print('📤 Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        // Estructura de respuesta según documentación
        final orderId = data['orderId'] ?? data['id'];
        final status = data['status'] ?? 'PROCESSING';
        
        print('✅ Orden creada exitosamente!');
        print('   🎯 Order ID: $orderId');
        print('   📊 Status: $status');
        
        return {
          'success': true,
          'orderId': orderId,
          'status': status,
          'phoneNumber': phoneNumber,
          'productId': productId,
          'value': value,
          'customerOrderId': body['customerOrderId'],
          'message': 'Orden creada exitosamente',
          'data': data,
        };
      } else {
        print('❌ Error HTTP creando orden: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        
        String errorMessage = 'Error de conexión (${response.statusCode})';
        
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          print('❌ No se pudo parsear error response: $e');
        }
        
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ Excepción creando orden: $e');
      return {
        'success': false,
        'error': 'Error interno: $e',
      };
    }
  }
  
  /// Verificar estado de una orden
  Future<Map<String, dynamic>?> getOrderStatus(String orderId) async {
    try {
      print('🔍 DingConnect: Verificando estado de orden $orderId...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId'),
        headers: _headersWithBearer,
      );
      
      print('🔍 Order Status Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final status = data['status'] ?? 'UNKNOWN';
        print('📊 Order Status: $status');
        
        return {
          'success': true,
          'orderId': orderId,
          'status': status,
          'data': data,
        };
      } else {
        print('❌ Error verificando estado: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Error verificando estado de orden',
        };
      }
    } catch (e) {
      print('❌ Excepción verificando estado: $e');
      return {
        'success': false,
        'error': 'Error interno: $e',
      };
    }
  }
  
  /// Método legacy para compatibilidad
  Future<Map<String, dynamic>?> sendRecharge({
    required String phoneNumber,
    required String skuCode,
    required String countryCode,
    String? externalId,
  }) async {
    // Convertir skuCode a productId y usar createOrder
    return await createOrder(
      phoneNumber: phoneNumber,
      productId: skuCode,
      value: 0.0, // Valor será calculado por el servidor
      customerOrderId: externalId,
    );
  }

  /// Validar número de teléfono para un país específico
  Future<Map<String, dynamic>?> validatePhoneNumber(String phoneNumber, String countryCode) async {
    try {
      print('🔍 DingConnect: Validando número $phoneNumber para $countryCode...');
      
      // Usar endpoint de productos para validar el número
      final response = await http.get(
        Uri.parse('$_baseUrl/products?country=$countryCode&phoneNumber=$phoneNumber'),
        headers: _headersWithBearer,
      );
      
      print('🔍 DingConnect Validation Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data is List ? data : (data['products'] ?? []);
        
        if (products.isNotEmpty) {
          final product = products.first;
          final operatorName = product['operatorName'] ?? product['name'] ?? 'Operador';
          print('✅ Número válido para: $operatorName');
          
          return {
            'isValid': true,
            'provider': operatorName,
            'countryName': product['countryName'] ?? countryCode,
            'products': products,
          };
        } else {
          print('❌ No se encontraron productos para este número');
          return {
            'isValid': false,
            'error': 'Número no válido o no soportado',
          };
        }
      } else {
        print('❌ Error validando número: ${response.statusCode}');
        return {
          'isValid': false,
          'error': 'Error validando número',
        };
      }
    } catch (e) {
      print('❌ Excepción validando número: $e');
      return {
        'isValid': false,
        'error': 'Error interno: $e',
      };
    }
  }


  /// Formatear producto DingConnect para mostrar en UI
  static Map<String, dynamic> formatProductForUI(Map<String, dynamic> product) {
    // Manejo según estructura de documentación DingConnect
    final operatorName = product['operatorName'] ?? product['name'] ?? product['operator'] ?? 'Operador';
    
    final value = (product['value'] ?? product['amount'] ?? product['price'] ?? 0).toDouble();
    final currency = product['currency'] ?? 'USD';
    
    final benefits = List<String>.from(product['benefits'] ?? product['tags'] ?? []);
    final productId = product['productId'] ?? product['id'] ?? product['sku'] ?? '';
    final isDemo = product['demo'] == true || product['test'] == true;
    final description = product['description'] ?? product['name'] ?? '';
    
    // Determinar tipo de producto y icono
    String type = 'Recarga';
    String icon = '💰';
    
    if (benefits.contains('Data') || benefits.contains('data')) {
      type = 'Datos';
      icon = '📶';
    } else if (benefits.contains('SMS') || benefits.contains('sms')) {
      type = 'SMS';
      icon = '💬';
    } else if (benefits.contains('Voice') || benefits.contains('voice') || benefits.contains('Llamadas')) {
      type = 'Llamadas';
      icon = '📞';
    }
    
    // Si tiene múltiples servicios
    if (benefits.length > 1) {
      type = 'Combo';
      icon = '📱';
    }
    
    // Crear título con indicadores claros
    String title = '$icon $operatorName - $type';
    if (isDemo) {
      title = '🎭 $title (DEMO)';
    }
    
    // Crear descripción mejorada
    String finalDescription = description;
    if (finalDescription.isEmpty) {
      finalDescription = '${value.toStringAsFixed(0)} $currency';
      
      if (benefits.isNotEmpty) {
        finalDescription += ' • ${benefits.join(', ')}';
      }
    }
    
    return {
      'id': productId,
      'title': title,
      'description': finalDescription,
      'price': value,
      'currency': currency,
      'originalPrice': value > 0 ? value * 1.05 : 0, // Pequeño descuento simulado
      'discount': value > 0 ? 5 : 0,
      'provider': operatorName,
      'logoUrl': product['logoUrl'] ?? product['operatorLogo'],
      'benefits': benefits,
      'skuCode': productId, // Para compatibilidad
      'productId': productId,
      'sendValue': value,
      'receiveValue': value,
      'sendCurrency': currency,
      'receiveCurrency': currency,
      'countryIso': product['countryCode'] ?? product['country'] ?? 'CU',
      'validityDays': product['validity'] ?? 30,
      'isDemo': isDemo, // Indicador claro si es producto demo
      'isReal': !isDemo, // Indicador si es producto real de la API
    };
  }
}