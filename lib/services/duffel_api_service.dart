import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// 🎯 Servicio REAL para conectar con backend Duffel
/// Se conecta SOLO al backend local, NO directamente a APIs externas
class DuffelApiService {
  // 🔗 URL del backend - RENDER.COM (PRODUCCIÓN GLOBAL)
  static const String _baseUrl = 'https://cubalink23-backend.onrender.com';
  
  // Headers estándar para todas las requests
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 🚀 CACHÉ DE AEROPUERTOS para optimizar búsquedas repetidas
  static final Map<String, List<Map<String, dynamic>>> _airportCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 10); // Cache válido por 10 minutos
  
  // 🚀 CACHÉ DE ESTADO DEL BACKEND para evitar verificaciones repetidas
  static bool? _backendStatusCache;
  static DateTime? _backendStatusTimestamp;
  static const Duration _backendStatusExpiry = Duration(minutes: 2); // Backend status válido por 2 minutos

  /// 🏥 Health Check - Verificar si backend está activo SIN CACHÉ
  static Future<bool> isBackendActive() async {
    // 🚀 SIEMPRE VERIFICAR ESTADO REAL - NO USAR CACHÉ
    print('🔄 Verificando estado del backend en tiempo real...');

    try {
      print('🔗 Verificando estado del backend...');
      print('🌐 URL: $_baseUrl/api/health');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/health'),
        headers: _headers,
      ).timeout(Duration(seconds: 10)); // Timeout aumentado para health check // Timeout reducido para health check

      print('📡 Respuesta status: ${response.statusCode}');
      print('📡 Respuesta body: ${response.body}');

      final isActive = response.statusCode == 200;

      if (isActive) {
        print('✅ Backend FINAL ACTIVO');
      } else {
        print('⚠️ Backend respondió con código: ${response.statusCode}');
      }
      
      return isActive;
    } catch (e) {
      print('❌ Backend NO disponible: $e');
      print('🔍 Tipo de error: ${e.runtimeType}');
      
      return false;
    }
  }

  /// ✈️ Buscar vuelos REALES usando backend
  static Future<Map<String, dynamic>?> searchFlights({
    required String origin,
    required String destination,
    required String departureDate,
    int adults = 1,
    String cabinClass = 'economy',
    String? returnDate,
    String airlineType = 'comerciales', // 'comerciales', 'charter', 'todos'
  }) async {
    try {
      print('🚀 BÚSQUEDA VUELOS REALES - Backend Duffel');
      print('✈️ Ruta: $origin → $destination');
      print('📅 Fecha: $departureDate');
      print('👥 Pasajeros: $adults');
      print('🎯 Tipo: $airlineType');

      // Verificar que backend esté activo
      final backendActive = await isBackendActive();
      if (!backendActive) {
        return {
          'status': 'offline',
          'message': 'Servicio temporalmente no disponible. Intente más tarde.',
          'error_type': 'backend_offline'
        };
      }

      // Preparar payload para backend
      final payload = {
        'origin': origin.toUpperCase(),
        'destination': destination.toUpperCase(),
        'departure_date': departureDate,
        'passengers': adults,
        'cabin_class': cabinClass.toLowerCase(),
      };

      // Agregar fecha de regreso si es ida y vuelta
      if (returnDate != null) {
        payload['return_date'] = returnDate;
      }

      // 🚨 TEMPORALMENTE DESHABILITADO: Tipo de aerolínea
      // TODO: Implementar filtrado por tipo de aerolínea después de que funcione la búsqueda básica
      // if (airlineType != 'todos') {
      //   payload['airline_type'] = airlineType;
      // }

      print('📤 Enviando solicitud al backend...');
      print('🔗 URL: $_baseUrl/admin/api/flights/search');
      print('📋 Payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/admin/api/flights/search'),
        headers: _headers,
        body: json.encode(payload),
      ).timeout(Duration(seconds: 30));

      print('📡 Status: ${response.statusCode}');
      print('📄 Response length: ${response.body.length} chars');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ BÚSQUEDA EXITOSA');
        
        if (data['data'] != null && data['data'] is List) {
          final flights = data['data'] as List;
          print('✈️ Vuelos encontrados: ${flights.length}');
          
          // Mostrar preview de precios
          if (flights.isNotEmpty) {
            print('💰 Precios de vuelos:');
            for (int i = 0; i < (flights.length > 3 ? 3 : flights.length); i++) {
              if (i < flights.length) {
                final flight = flights[i];
                final price = flight['total_amount'] ?? 'N/A';
                final airline = flight['airline'] ?? 'N/A';
                print('   ${i+1}. $airline: \$$price');
              }
            }
          }
        } else {
          print('⚠️ No se encontraron vuelos en la respuesta');
        }
        
        return data;
      } else if (response.statusCode == 500) {
        print('❌ Error interno del backend');
        return {
          'status': 'error',
          'message': 'Error interno del servidor. Intente más tarde.',
          'error_type': 'backend_error'
        };
      } else {
        print('❌ Error HTTP ${response.statusCode}: ${response.body}');
        return {
          'status': 'error',
          'message': 'Error en la búsqueda de vuelos.',
          'error_type': 'http_error',
          'status_code': response.statusCode
        };
      }
    } catch (e) {
      print('💥 Exception en búsqueda: $e');
      if (e is TimeoutException) {
        return {
          'status': 'timeout',
          'message': 'La búsqueda está tomando más tiempo del esperado. Intente nuevamente.',
          'error_type': 'timeout'
        };
      } else {
        return {
          'status': 'error',
          'message': 'Error de conexión. Verifique su internet.',
          'error_type': 'connection_error'
        };
      }
    }
  }

  /// 🏪 Buscar aeropuertos usando backend con caché optimizado
  static Future<List<Map<String, dynamic>>> searchAirports(String query) async {
    try {
      if (query.length < 2) return [];
      
      final normalizedQuery = query.toLowerCase().trim();
      print('🔍 ===========================================');
      print('🔍 BÚSQUEDA DE AEROPUERTOS INICIADA');
      print('🔍 Query original: "$query"');
      print('🔍 Query normalizada: "$normalizedQuery"');
      print('🔍 ===========================================');

      // 🚀 VERIFICAR CACHÉ PRIMERO
      if (_airportCache.containsKey(normalizedQuery)) {
        final cacheTime = _cacheTimestamps[normalizedQuery];
        if (cacheTime != null && DateTime.now().difference(cacheTime) < _cacheExpiry) {
          print('⚡ Usando caché para: $query (${_airportCache[normalizedQuery]!.length} resultados)');
          return _airportCache[normalizedQuery]!;
        } else {
          // Cache expirado, limpiar
          _airportCache.remove(normalizedQuery);
          _cacheTimestamps.remove(normalizedQuery);
          print('🗑️ Cache expirado para: $query');
        }
      }

      // Verificar backend activo
      print('🔗 Verificando estado del backend...');
      final backendActive = await isBackendActive();
      print('🔗 Backend activo: $backendActive');
      
      if (!backendActive) {
        print('❌ Backend offline - NO HAY DATOS DISPONIBLES');
        return [];
      }

      print('📡 Realizando petición HTTP...');
      print('🌐 URL: $_baseUrl/admin/api/flights/airports?query=${Uri.encodeComponent(query)}');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/api/flights/airports?query=${Uri.encodeComponent(query)}'),
        headers: _headers,
      ).timeout(Duration(seconds: 15)); // Timeout aumentado a 15s para API Duffel

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response length: ${response.body.length} chars');
      print('📡 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Backend devuelve array directo [] o objeto {data: []}
        List airportsList = [];
        
        if (data is List) {
          // Array directo []
          airportsList = data;
          print('📋 Backend devolvió array directo: ${airportsList.length}');
        } else if (data is Map && data['data'] != null && data['data'] is List) {
          // Objeto con data {data: [...]}
          airportsList = data['data'];
          print('📋 Backend devolvió objeto con data: ${airportsList.length}');
        } else {
          print('⚠️ Formato de respuesta no reconocido: ${data.runtimeType}');
          return [];
        }
        
        final airports = airportsList.map((airport) {
          // Usar display_name del backend si existe, sino construir uno
          String displayName = airport['display_name']?.toString() ?? '';
          if (displayName.isEmpty) {
            final city = airport['city']?.toString() ?? '';
            final country = airport['country']?.toString() ?? '';
            displayName = '$city${country.isNotEmpty ? ', $country' : ''}';
          }
          
          return {
            'code': airport['iata_code']?.toString() ?? airport['code']?.toString() ?? '',
            'name': airport['name']?.toString() ?? '',
            'display_name': displayName,
            'city': airport['city']?.toString() ?? '',
            'country': airport['country']?.toString() ?? '',
          };
        }).where((airport) => airport['code']?.isNotEmpty == true).toList();
        
        // 🚀 GUARDAR EN CACHÉ
        _airportCache[normalizedQuery] = airports;
        _cacheTimestamps[normalizedQuery] = DateTime.now();
        
        print('✅ Aeropuertos procesados: ${airports.length} (guardados en caché)');
        if (airports.isNotEmpty) {
          print('🔍 PREVIEW aeropuertos encontrados:');
          for (int i = 0; i < (airports.length > 3 ? 3 : airports.length); i++) {
            print('   ${i+1}. ${airports[i]['code']} - ${airports[i]['name']}');
          }
          return airports;
        } else {
          // Si el backend responde pero sin aeropuertos, devolver lista vacía
          print('⚠️ Backend respondió con lista vacía - NO HAY RESULTADOS REALES');
          return [];
        }
      }
      
      // Sin fallback - mostrar error real
      print('⚠️ Backend sin aeropuertos - ERROR REAL DEL BACKEND');
      return [];
      
    } catch (e) {
      print('❌ Error buscando aeropuertos: $e');
      print('🔄 NO HAY DATOS DE RESPALDO - SOLO API REAL');
      return [];
    }
  }

  /// 🏢 Obtener aerolíneas disponibles
  static Future<List<Map<String, dynamic>>> getAirlines() async {
    try {
      print('🏢 Obteniendo aerolíneas...');

      // Verificar backend activo
      final backendActive = await isBackendActive();
      if (!backendActive) {
        print('❌ Backend offline - sin aerolíneas disponibles');
        return [];
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/flights/airlines'),
        headers: _headers,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null && data['data'] is List) {
          final airlines = (data['data'] as List).map((airline) {
            return {
              'id': airline['id']?.toString() ?? '',
              'name': airline['name']?.toString() ?? '',
              'iata_code': airline['iata_code']?.toString() ?? '',
              'icao_code': airline['icao_code']?.toString() ?? '',
            };
          }).toList();
          
          print('✅ Aerolíneas obtenidas: ${airlines.length}');
          return airlines;
        }
      }
      
      print('⚠️ Sin aerolíneas disponibles');
      return [];
      
    } catch (e) {
      print('❌ Error obteniendo aerolíneas: $e');
      return [];
    }
  }

  /// 📋 Obtener ofertas por ID de request
  static Future<List<Map<String, dynamic>>> getOffers(String offerRequestId) async {
    try {
      print('📋 Obteniendo ofertas para: $offerRequestId');

      // Verificar backend activo
      final backendActive = await isBackendActive();
      if (!backendActive) {
        print('❌ Backend offline - sin ofertas disponibles');
        return [];
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/flights/offers/$offerRequestId'),
        headers: _headers,
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null && data['data'] is List) {
          final offers = data['data'] as List<Map<String, dynamic>>;
          print('✅ Ofertas obtenidas: ${offers.length}');
          return offers;
        }
      }
      
      print('⚠️ Sin ofertas disponibles');
      return [];
      
    } catch (e) {
      print('❌ Error obteniendo ofertas: $e');
      return [];
    }
  }

  /// 🌐 Test de conexión completa
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🧪 PRUEBA COMPLETA DE CONEXIÓN');
      
      // Test 1: Health check
      final healthOk = await isBackendActive();
      
      return {
        'backend_active': healthOk,
        'base_url': _baseUrl,
        'status': healthOk ? 'ok' : 'error',
        'message': healthOk 
            ? 'Conexión exitosa con backend'
            : 'Problemas de conexión con backend'
      };
    } catch (e) {
      return {
        'backend_active': false,
        'base_url': _baseUrl,
        'status': 'error',
        'message': 'Error en prueba de conexión: $e'
      };
    }
  }


    /// 💳 Crear PaymentIntent con Duffel API
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required String offerId,
    required String amount,
    String currency = 'USD',
  }) async {
    try {
      print('💳 CREANDO PAYMENTINTENT CON DUFFEL API...');
      print('🎫 Offer ID: $offerId');
      print('💰 Amount: $amount $currency');

      // Verificar que backend esté activo
      final backendActive = await isBackendActive();
      if (!backendActive) {
        return {
          'success': false,
          'error': 'Backend no disponible',
          'message': 'Servicio temporalmente no disponible. Intente más tarde.',
        };
      }

      // Preparar payload para backend
      final payload = {
        'offer_id': offerId,
        'amount': amount,
        'currency': currency,
      };

      print('📤 Enviando solicitud de PaymentIntent al backend...');
      print('🔗 URL: $_baseUrl/admin/api/flights/payment-intent');
      print('📋 Payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/admin/api/flights/payment-intent'),
        headers: _headers,
        body: json.encode(payload),
      ).timeout(Duration(seconds: 30));

      print('📡 Status: ${response.statusCode}');
      print('📄 Response length: ${response.body.length} chars');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ PAYMENTINTENT CREADO EXITOSAMENTE');
        print('📋 Datos de respuesta: $data');
        
        return {
          'success': true,
          'payment_intent_id': data['payment_intent_id'] ?? '',
          'client_token': data['client_token'] ?? '',
          'amount': data['amount'] ?? amount,
          'currency': data['currency'] ?? currency,
          'message': data['message'] ?? 'PaymentIntent creado exitosamente',
          'data': data,
        };
      } else {
        print('❌ Error HTTP creando PaymentIntent: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
          'message': 'Error del servidor al crear PaymentIntent',
          'details': response.body,
        };
      }
    } catch (e) {
      print('❌ Error creando PaymentIntent: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error de conexión al crear PaymentIntent',
      };
    }
  }

  /// 💺 Obtener asientos disponibles para una oferta
  static Future<Map<String, dynamic>?> getAvailableSeats({
    required String offerId,
  }) async {
    try {
      print('💺 OBTENIENDO ASIENTOS PARA OFERTA: $offerId');

      // Verificar que backend esté activo
      final backendActive = await isBackendActive();
      if (!backendActive) {
        return {
          'success': false,
          'error': 'Backend no disponible',
          'message': 'Servicio temporalmente no disponible. Intente más tarde.',
        };
      }

      print('📤 Enviando solicitud de asientos al backend...');
      print('🔗 URL: $_baseUrl/admin/api/flights/seats/$offerId');

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/api/flights/seats/$offerId'),
        headers: _headers,
      ).timeout(Duration(seconds: 30));

      print('📡 Status: ${response.statusCode}');
      print('📄 Response length: ${response.body.length} chars');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ ASIENTOS OBTENIDOS EXITOSAMENTE');
        print('📋 Datos de respuesta: ${data['seat_maps']?.length ?? 0} seat maps');
        
        return {
          'success': true,
          'seat_maps': data['seat_maps'] ?? [],
          'message': data['message'] ?? 'Asientos obtenidos exitosamente',
          'data': data,
        };
      } else {
        print('❌ Error HTTP obteniendo asientos: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
          'message': 'Error del servidor al obtener asientos',
          'details': response.body,
        };
      }
    } catch (e) {
      print('❌ Error obteniendo asientos: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error de conexión al obtener asientos',
      };
    }
  }

  /// 📋 Crear reserva/booking REAL con Duffel API
  static Future<Map<String, dynamic>?> createBooking({
    required String offerId,
    required List<Map<String, dynamic>> passengers,
    String? paymentIntentId,
    String paymentMethod = 'balance', // 'balance', 'hold', o 'payment_intent'
    List<Map<String, dynamic>>? selectedSeats,
    List<Map<String, dynamic>>? selectedBaggage,
  }) async {
    try {
      print('📋 CREANDO RESERVA REAL CON DUFFEL API...');
      print('🎫 Offer ID: $offerId');
      print('👥 Pasajeros: ${passengers.length}');
      print('💳 Método de pago: $paymentMethod');

      // Verificar que backend esté activo
      final backendActive = await isBackendActive();
      if (!backendActive) {
        return {
          'success': false,
          'error': 'Backend no disponible',
          'message': 'Servicio temporalmente no disponible. Intente más tarde.',
        };
      }

      // Preparar payload para backend
      final payload = {
        'offer_id': offerId,
        'passengers': passengers,
        'payment_method': paymentMethod,
        'payment_intent_id': paymentIntentId,
        'selected_seats': selectedSeats,
        'selected_baggage': selectedBaggage,
      };

      print('📤 Enviando solicitud de reserva al backend...');
      print('🔗 URL: $_baseUrl/admin/api/flights/booking');
      print('📋 Payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/admin/api/flights/booking'),
        headers: _headers,
        body: json.encode(payload),
      ).timeout(Duration(seconds: 30));

      print('📡 Status: ${response.statusCode}');
      print('📄 Response length: ${response.body.length} chars');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ RESERVA CREADA EXITOSAMENTE');
        print('📋 Datos de respuesta: $data');
        
        return {
          'success': true,
          'booking_reference': data['booking_reference'] ?? 'CL23${DateTime.now().millisecondsSinceEpoch}',
          'order_id': data['order_id'] ?? data['id'] ?? 'ORD_${DateTime.now().millisecondsSinceEpoch}',
          'status': data['status'] ?? 'confirmed',
          'message': data['message'] ?? 'Reserva creada exitosamente',
          'passengers': passengers,
          'total_amount': data['total_amount'] ?? '0.00',
          'currency': data['currency'] ?? 'USD',
          'data': data,
        };
      } else {
        print('❌ Error HTTP creando reserva: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
          'message': 'Error del servidor al crear la reserva',
          'details': response.body,
        };
      }
    } catch (e) {
      print('❌ Error creando reserva: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error de conexión al crear la reserva',
      };
    }
  }

  /// 📊 Obtener estado de orden (simulado para desarrollo)
  static Future<Map<String, dynamic>?> getOrderStatus(String orderId) async {
    try {
      print('📊 OBTENIENDO ESTADO DE ORDEN: $orderId');

      // ⚠️ SIMULACIÓN PARA DESARROLLO
      await Future.delayed(Duration(seconds: 1));
      
      return {
        'order_id': orderId,
        'status': 'confirmed',
        'payment_status': 'paid',
        'message': 'Orden confirmada y pagada (DEMO)',
        'booking_reference': 'CL23${DateTime.now().millisecondsSinceEpoch}',
      };
    } catch (e) {
      print('❌ Error obteniendo estado: $e');
      return null;
    }
  }

  /// 🧪 Test completo de conexión con backend Render.com
  static Future<Map<String, dynamic>> testBackendConnection() async {
    print('🧪 PRUEBA COMPLETA DE CONEXIÓN A RENDER.COM');
    print('🌐 URL de Render: $_baseUrl');
    final healthOk = await isBackendActive();
    return {
      'backend_active': healthOk,
      'base_url': _baseUrl,
      'status': healthOk ? 'ok' : 'error',
      'message': healthOk 
          ? 'Conexión exitosa con backend Render'
          : 'Problemas de conexión con backend Render'
    };
  }
}