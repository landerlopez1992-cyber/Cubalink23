import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cubalink23/models/walmart_product.dart';

class WalmartApiService {
  // Configuración EXACTA de la API Walmart según los datos del proyecto ReactNative
  static const String _baseUrl = 'https://walmart-api4.p.rapidapi.com';
  static const String _apiHost = 'walmart-api4.p.rapidapi.com';
  static const String _apiKey = '43db5773a3msh2a82d305d0dbf5ap16f958jsna677a7d7e263';

  // Endpoints disponibles según las capturas
  static const String _searchEndpoint = '/search';
  static const String _productDetailsEndpoint = '/details.php';

  // Headers estándar para todas las peticiones
  static Map<String, String> get _headers => {
        'X-RapidAPI-Host': _apiHost,
        'X-RapidAPI-Key': _apiKey,
        'Content-Type': 'application/json',
      };

  /// Buscar productos en Walmart usando la API
  /// [query] - Término de búsqueda (ej: "knife", "laptop")
  /// [page] - Página de resultados (opcional, default: 1)
  /// [country] - País para la búsqueda (opcional, default: "US")
  Future<List<WalmartProduct>> searchProducts({
    required String query,
    int page = 1,
    String country = 'US',
  }) async {
    print('🔍 Iniciando búsqueda de productos Walmart: "$query"');
    
    try {
      print('🔍 Buscando productos en API Walmart: "$query"');
      
      // Parámetros EXACTOS según la URL de ejemplo de las capturas
      Map<String, String> queryParams = {
        'q': query, // Walmart usa 'q' en lugar de 'query'
        'page': page.toString(),
        'country': country.toUpperCase(),
      };

      // Construir la URL con parámetros
      Uri url = Uri.parse('$_baseUrl$_searchEndpoint').replace(
        queryParameters: queryParams,
      );

      print('📡 URL de petición: $url');
      print('🔑 Headers: $_headers');
      print('🔍 Query Parameters: $queryParams');

      // Realizar la petición HTTP con timeout
      final response = await http.get(url, headers: _headers)
        .timeout(const Duration(seconds: 15));

      print('📊 Status Code: ${response.statusCode}');
      if (response.body.length > 500) {
        print('📝 Response Body (primeros 500 caracteres): ${response.body.substring(0, 500)}...');
      } else {
        print('📝 Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        print('🔍 Estructura de la respuesta: ${data.keys.toList()}');
        
        List<dynamic> productsJson = [];
        
        // Intentar diferentes estructuras de respuesta de RapidAPI
        if (data.containsKey('data')) {
          final responseData = data['data'];
          if (responseData is List) {
            productsJson = responseData;
          } else if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('products') && responseData['products'] is List) {
              productsJson = responseData['products'] as List<dynamic>;
            } else if (responseData.containsKey('results') && responseData['results'] is List) {
              productsJson = responseData['results'] as List<dynamic>;
            }
          }
        } else if (data.containsKey('products') && data['products'] is List) {
          productsJson = data['products'] as List<dynamic>;
        } else if (data.containsKey('results') && data['results'] is List) {
          productsJson = data['results'] as List<dynamic>;
        }
        
        print('📦 Productos JSON encontrados: ${productsJson.length}');
        
        if (productsJson.isNotEmpty) {
          List<WalmartProduct> products = [];
          for (int i = 0; i < productsJson.length && i < 20; i++) {
            try {
              final productJson = productsJson[i] as Map<String, dynamic>;
              print('📄 Procesando producto ${i + 1}: ${productJson.keys.toList()}');
              
              // Crear producto con los datos disponibles
              final product = _createProductFromApiResponse(productJson);
              if (product != null) {
                products.add(product);
                print('✅ Producto agregado: ${product.title}');
              }
            } catch (e) {
              print('⚠️ Error procesando producto ${i + 1}: $e');
              continue;
            }
          }

          print('✅ Total productos procesados: ${products.length}');
          if (products.isNotEmpty) {
            return products;
          }
        } else {
          print('❌ No se encontraron productos en la respuesta');
          print('🔍 Claves disponibles: ${data.keys.toList()}');
        }

      } else if (response.statusCode == 429) {
        print('⚠️ Límite de peticiones excedido');
      } else if (response.statusCode == 401) {
        print('⚠️ API Key inválida o expirada');
      } else {
        print('⚠️ Error en la API: ${response.statusCode} - ${response.body}');
      }

    } catch (e) {
      print('❌ Error en búsqueda de productos: $e');
    }
    
    // NO usar datos demo - devolver lista vacía si API falla
    print('🚫 NO se usarán datos demo - devolviendo lista vacía (solo productos reales de Walmart API)');
    return [];
  }

  /// Obtener detalles específicos de un producto usando su URL
  /// [productUrl] - URL del producto en Walmart
  Future<WalmartProduct?> getProductDetails({
    required String productUrl,
  }) async {
    try {
      print('🔍 Obteniendo detalles del producto Walmart: $productUrl');

      // Construir parámetros para obtener detalles del producto
      Map<String, String> queryParams = {
        'url': productUrl,
      };

      Uri url = Uri.parse('$_baseUrl$_productDetailsEndpoint').replace(
        queryParameters: queryParams,
      );

      print('📡 URL de petición: $url');

      final response = await http.get(url, headers: _headers)
        .timeout(const Duration(seconds: 15));

      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data.containsKey('data') && data['data'] is Map) {
          try {
            final product = _createProductFromApiResponse(data['data'] as Map<String, dynamic>);
            print('✅ Detalles del producto obtenidos');
            return product;
          } catch (e) {
            print('⚠️ Error procesando detalles del producto: $e');
          }
        }
        
      } else {
        throw Exception('Error obteniendo detalles: ${response.statusCode} - ${response.body}');
      }
      
    } catch (e) {
      print('❌ Error obteniendo detalles del producto: $e');
    }

    return null;
  }
  
  /// Extraer peso de los datos del producto desde la API de Walmart
  String? _extractWeightFromProduct(Map<String, dynamic> json) {
    print('🔍 Extrayendo peso del producto Walmart...');
    
    // Lista de campos donde podríamos encontrar peso
    List<String> weightFields = [
      'weight',
      'item_weight', 
      'product_weight',
      'shipping_weight',
      'package_weight',
      'dimensions_weight',
      'weight_with_package',
      'item_dimensions_weight'
    ];
    
    // Buscar peso en campos directos
    for (String field in weightFields) {
      if (json.containsKey(field) && json[field] != null) {
        String weightStr = json[field].toString().trim();
        if (weightStr.isNotEmpty && weightStr.toLowerCase() != 'null') {
          print('✅ Peso encontrado en campo "$field": $weightStr');
          return _parseAndConvertWeight(weightStr);
        }
      }
    }
    
    // Buscar en specifications o technical_details
    if (json.containsKey('specifications') && json['specifications'] is Map) {
      Map<String, dynamic> specs = json['specifications'];
      for (String field in weightFields) {
        if (specs.containsKey(field) && specs[field] != null) {
          String weightStr = specs[field].toString().trim();
          if (weightStr.isNotEmpty) {
            print('✅ Peso encontrado en specifications "$field": $weightStr');
            return _parseAndConvertWeight(weightStr);
          }
        }
      }
    }
    
    // Buscar en product_information o details
    if (json.containsKey('product_information') && json['product_information'] is Map) {
      Map<String, dynamic> productInfo = json['product_information'];
      for (String field in weightFields) {
        if (productInfo.containsKey(field) && productInfo[field] != null) {
          String weightStr = productInfo[field].toString().trim();
          if (weightStr.isNotEmpty) {
            print('✅ Peso encontrado en product_information "$field": $weightStr');
            return _parseAndConvertWeight(weightStr);
          }
        }
      }
    }
    
    // Buscar en description o title (menos confiable)
    String fullText = '';
    if (json['product_title'] != null) fullText += '${json['product_title']} ';
    if (json['product_description'] != null) fullText += '${json['product_description']} ';
    if (json['description'] != null) fullText += '${json['description']} ';
    
    if (fullText.isNotEmpty) {
      String? extractedWeight = _extractWeightFromText(fullText);
      if (extractedWeight != null) {
        print('✅ Peso extraído del texto: $extractedWeight');
        return extractedWeight;
      }
    }
    
    print('❌ No se pudo encontrar peso para el producto');
    return null;
  }
  
  /// Extraer peso del texto usando regex
  String? _extractWeightFromText(String text) {
    // Patrones para encontrar peso en el texto
    List<RegExp> patterns = [
      RegExp(r'(\d+(?:\.\d+)?)\s*(lbs?|pounds?)', caseSensitive: false),
      RegExp(r'(\d+(?:\.\d+)?)\s*(kg|kilograms?)', caseSensitive: false),
      RegExp(r'(\d+(?:\.\d+)?)\s*(oz|ounces?)', caseSensitive: false),
      RegExp(r'(\d+(?:\.\d+)?)\s*(g|grams?)', caseSensitive: false),
      RegExp(r'Weight:?\s*(\d+(?:\.\d+)?)\s*(lbs?|kg|pounds?|kilograms?)', caseSensitive: false),
      RegExp(r'(\d+(?:\.\d+)?)\s*lb', caseSensitive: false),
    ];
    
    for (RegExp pattern in patterns) {
      RegExpMatch? match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 2) {
        String value = match.group(1) ?? '';
        String unit = match.group(2) ?? '';
        
        if (value.isNotEmpty && unit.isNotEmpty) {
          return _parseAndConvertWeight('$value $unit');
        }
      }
    }
    
    return null;
  }
  
  /// Convertir peso a kilogramos estándar
  String _parseAndConvertWeight(String weightStr) {
    print('🔧 Parseando peso: "$weightStr"');
    
    weightStr = weightStr.toLowerCase().trim();
    
    // Extraer número
    RegExp numberPattern = RegExp(r'(\d+(?:\.\d+)?)');
    RegExpMatch? numberMatch = numberPattern.firstMatch(weightStr);
    
    if (numberMatch == null) {
      print('❌ No se pudo extraer número del peso: $weightStr');
      return 'PESO_NO_DISPONIBLE';
    }
    
    double? weightValue = double.tryParse(numberMatch.group(1) ?? '0');
    if (weightValue == null || weightValue <= 0) {
      print('❌ Valor de peso inválido: ${numberMatch.group(1)}');
      return 'PESO_NO_DISPONIBLE';
    }
    
    // Convertir a kg según la unidad
    double weightInKg;
    
    if (weightStr.contains('lb') || weightStr.contains('pound')) {
      // Libras a kilogramos
      weightInKg = weightValue * 0.453592;
      print('🔄 Convertido de $weightValue lbs a ${weightInKg.toStringAsFixed(2)} kg');
    } else if (weightStr.contains('oz') || weightStr.contains('ounce')) {
      // Onzas a kilogramos
      weightInKg = weightValue * 0.0283495;
      print('🔄 Convertido de $weightValue oz a ${weightInKg.toStringAsFixed(2)} kg');
    } else if (weightStr.contains('g') && !weightStr.contains('kg')) {
      // Gramos a kilogramos
      weightInKg = weightValue / 1000;
      print('🔄 Convertido de $weightValue g a ${weightInKg.toStringAsFixed(3)} kg');
    } else {
      // Ya está en kilogramos
      weightInKg = weightValue;
      print('✅ Peso ya en kilogramos: ${weightInKg.toStringAsFixed(2)} kg');
    }
    
    return '${weightInKg.toStringAsFixed(3)} kg';
  }
  
  /// Convertir string de peso a double en kilogramos
  double? _parseWeightFromString(String? weightStr) {
    if (weightStr == null || weightStr.contains('PESO_NO_DISPONIBLE')) {
      return null;
    }
    
    // Extraer número del peso en formato "X.XXX kg"
    RegExp numberPattern = RegExp(r'([0-9]+\.?[0-9]*)');
    RegExpMatch? match = numberPattern.firstMatch(weightStr);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0');
    }
    
    return null;
  }
  
  /// Crear un WalmartProduct a partir de la respuesta de la API real
  WalmartProduct? _createProductFromApiResponse(Map<String, dynamic> json) {
    try {
      // Extraer datos con nombres de campos que puede usar RapidAPI
      String? productId = json['product_id'] ?? json['id'] ?? json['item_id'];
      String? title = json['product_title'] ?? json['title'] ?? json['name'];
      String? description = json['product_description'] ?? json['description'] ?? json['about_product'];
      
      // Precios
      double? price;
      if (json['product_price'] != null) {
        String priceStr = json['product_price'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
        price = double.tryParse(priceStr);
      } else if (json['price'] != null) {
        if (json['price'] is num) {
          price = json['price'].toDouble();
        } else {
          String priceStr = json['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
          price = double.tryParse(priceStr);
        }
      }
      
      double? originalPrice;
      if (json['product_original_price'] != null) {
        String originalPriceStr = json['product_original_price'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
        originalPrice = double.tryParse(originalPriceStr);
      }
      
      // Rating
      double? rating;
      if (json['product_star_rating'] != null) {
        if (json['product_star_rating'] is num) {
          rating = json['product_star_rating'].toDouble();
        } else {
          String ratingStr = json['product_star_rating'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
          rating = double.tryParse(ratingStr);
        }
      } else if (json['rating'] != null) {
        if (json['rating'] is num) {
          rating = json['rating'].toDouble();
        }
      }
      
      // Reviews
      int? reviewCount;
      if (json['product_num_ratings'] != null) {
        reviewCount = int.tryParse(json['product_num_ratings'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
      } else if (json['reviews_count'] != null) {
        reviewCount = int.tryParse(json['reviews_count'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
      }
      
      // Imágenes
      List<String> images = [];
      if (json['product_photo'] != null) {
        images.add(json['product_photo'].toString());
      } else if (json['product_main_image_url'] != null) {
        images.add(json['product_main_image_url'].toString());
      } else if (json['image'] != null) {
        images.add(json['image'].toString());
      } else if (json['images'] != null && json['images'] is List) {
        for (var img in json['images']) {
          if (img != null) images.add(img.toString());
        }
      }
      
      // Si no tenemos imagen, usar placeholder de Walmart
      if (images.isEmpty) {
        images.add('https://via.placeholder.com/300x300/004C91/FFFFFF?text=Walmart');
      }
      
      // Datos adicionales
      String? brand = json['brand'] ?? json['product_brand'];
      String? category = json['category'] ?? json['product_category'] ?? json['department'];
      String? currency = json['currency'] ?? 'USD';
      
      // ⚖️ EXTRACCIÓN DE PESO REAL DE LA API
      String? weightFromApi = _extractWeightFromProduct(json);
      
      // Validar que tenemos los datos mínimos
      if (productId == null || title == null || price == null) {
        print('⚠️ Producto incompleto - ID: $productId, Title: $title, Price: $price');
        return null;
      }
      
      return WalmartProduct(
        productId: productId,
        title: title,
        description: description ?? 'Descripción no disponible',
        price: price,
        originalPrice: originalPrice,
        currency: currency,
        rating: rating ?? 4.0,
        reviewCount: reviewCount ?? 100,
        images: images,
        category: category,
        brand: brand,
        features: [],
        weight: weightFromApi ?? 'PESO_NO_DISPONIBLE', // Usar peso de API o marcador
        weightKg: _parseWeightFromString(weightFromApi), // Convertir a kg numérico
        color: 'Varios',
      );
      
    } catch (e) {
      print('❌ Error creando producto desde API: $e');
      return null;
    }
  }

  /// Verificar conectividad con la API
  Future<bool> testApiConnection() async {
    try {
      // Hacer una búsqueda simple para probar la conexión
      await searchProducts(query: 'test', page: 1);
      return true;
    } catch (e) {
      print('❌ Error de conectividad con la API: $e');
      return false;
    }
  }

  /// Obtener categorías disponibles (basado en Walmart)
  static List<String> getAvailableCategories() {
    return [
      'All Departments',
      'Electronics',
      'Home & Garden',
      'Clothing & Accessories',
      'Health & Beauty',
      'Sports & Outdoors',
      'Toys & Games',
      'Automotive',
      'Books',
      'Movies & TV',
      'Music',
      'Video Games',
      'Grocery',
      'Pharmacy',
      'Baby',
      'Pet Supplies',
    ];
  }

  /// Obtener países soportados
  static List<String> getSupportedCountries() {
    return ['US', 'CA', 'MX', 'UK', 'IN'];
  }
}