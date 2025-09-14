import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cubalink23/models/walmart_product.dart';

class WalmartApiService {
  // Configuración EXACTA de la API según los datos proporcionados
  static const String _baseUrl = 'https://walmart-api4.p.rapidapi.com';
  static const String _apiHost = 'walmart-api4.p.rapidapi.com';
  static const String _apiKey = '43db5773a3msh2a82d305d0dbf5ap16f958jsna677a7d7e263';

  // Endpoints disponibles
  static const String _searchEndpoint = '/search';
  static const String _detailsEndpoint = '/details.php';

  // Headers estándar para todas las peticiones
  static Map<String, String> get _headers => {
        'X-RapidAPI-Host': _apiHost,
        'X-RapidAPI-Key': _apiKey,
        'Content-Type': 'application/json',
      };

  /// Buscar productos en Walmart usando la API Walmart API4
  /// [query] - Término de búsqueda (ej: "pantalón", "laptop", "iPhone")
  /// [page] - Página de resultados (opcional, default: 1)
  /// [category] - Categoría de productos (opcional)
  Future<List<WalmartProduct>> searchProducts({
    required String query,
    int page = 1,
    String? category,
  }) async {
    print('🔍 Iniciando búsqueda de productos Walmart: "$query"');
    
    try {
      print('📡 Buscando productos en Walmart API: "$query"');
      
      // Parámetros según la URL de ejemplo proporcionada
      Map<String, String> queryParams = {
        'q': query, // Parámetro de búsqueda
        'page': page.toString(),
      };

      // Agregar categoría si se especifica
      if (category != null && category.isNotEmpty && category != 'Todos') {
        queryParams['category'] = category;
      }

      // Construir la URL con parámetros
      Uri url = Uri.parse('$_baseUrl$_searchEndpoint').replace(
        queryParameters: queryParams,
      );

      print('🌐 URL de petición: $url');
      print('📋 Headers: $_headers');
      print('🔧 Query Parameters: $queryParams');

      // Realizar la petición HTTP con timeout
      final response = await http.get(url, headers: _headers)
        .timeout(const Duration(seconds: 10));

      print('📊 Status Code: ${response.statusCode}');
      if (response.body.length > 500) {
        print('📄 Response Body (primeros 500 caracteres): ${response.body.substring(0, 500)}...');
      } else {
        print('📄 Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        print('🏗️ Estructura de la respuesta: ${data.keys.toList()}');
        
        List<dynamic> productsJson = [];
        
        // Intentar diferentes estructuras de respuesta de RapidAPI
        if (data.containsKey('data')) {
          final responseData = data['data'];
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('products') && responseData['products'] is List) {
              productsJson = responseData['products'] as List<dynamic>;
            } else if (responseData.containsKey('results') && responseData['results'] is List) {
              productsJson = responseData['results'] as List<dynamic>;
            } else if (responseData.containsKey('items') && responseData['items'] is List) {
              productsJson = responseData['items'] as List<dynamic>;
            }
          } else if (responseData is List) {
            productsJson = responseData;
          }
        } else if (data.containsKey('products') && data['products'] is List) {
          productsJson = data['products'] as List<dynamic>;
        } else if (data.containsKey('results') && data['results'] is List) {
          productsJson = data['results'] as List<dynamic>;
        } else if (data.containsKey('items') && data['items'] is List) {
          productsJson = data['items'] as List<dynamic>;
        }
        
        print('📦 Productos JSON encontrados: ${productsJson.length}');
        
        if (productsJson.isNotEmpty) {
          print('🔍 Primer producto de ejemplo: ${productsJson.first}');
        }
        
        // Convertir a objetos WalmartProduct
        List<WalmartProduct> products = [];
        for (var productJson in productsJson) {
          try {
            if (productJson is Map<String, dynamic>) {
              final product = WalmartProduct.fromJson(productJson);
              products.add(product);
              print('✅ Producto agregado: ${product.title} - \$${product.price}');
            }
          } catch (e) {
            print('❌ Error procesando producto: $e');
            print('🔍 Producto problemático: $productJson');
          }
        }
        
        print('✅ Total productos procesados: ${products.length}');
        return products;
        
      } else {
        print('❌ Error en la petición Walmart API: ${response.statusCode}');
        print('📄 Error response: ${response.body}');
        print('🚫 NO se usarán datos demo - devolviendo lista vacía (API real solamente)');
        
        // NO usar datos demo - devolver lista vacía si API falla
        return [];
      }
      
    } catch (e) {
      print('❌ Error conectando con Walmart API: $e');
      print('🚫 NO se usarán datos demo - devolviendo lista vacía (solo productos reales)');
      
      // NO usar datos demo - devolver lista vacía si hay error de conexión
      return [];
    }
  }

  /// Obtener detalles de un producto específico
  /// [url] - URL del producto en Walmart
  Future<WalmartProduct?> getProductDetails(String url) async {
    print('🔍 Obteniendo detalles del producto: $url');
    
    try {
      // Codificar la URL del producto
      final encodedUrl = Uri.encodeComponent(url);
      
      // Construir la URL de detalles
      final requestUrl = '$_baseUrl$_detailsEndpoint?url=$encodedUrl';
      
      print('🌐 URL de petición detalles: $requestUrl');
      
      // Realizar la petición HTTP con timeout
      final response = await http.get(
        Uri.parse(requestUrl), 
        headers: _headers
      ).timeout(const Duration(seconds: 15));

      print('📊 Status Code detalles: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('🏗️ Estructura de detalles: ${data.keys.toList()}');
        
        // El producto puede estar directamente en data o anidado
        Map<String, dynamic> productData;
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          productData = data['data'];
        } else {
          productData = data;
        }
        
        final product = WalmartProduct.fromJson(productData);
        print('✅ Detalles obtenidos para: ${product.title}');
        return product;
        
      } else {
        print('❌ Error obteniendo detalles: ${response.statusCode}');
        return null;
      }
      
    } catch (e) {
      print('❌ Error obteniendo detalles del producto: $e');
      return null;
    }
  }

  // DATOS DEMO ELIMINADOS - Solo usar API real de Walmart
}