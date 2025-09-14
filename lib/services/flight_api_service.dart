import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class FlightApiService {
  // 🔥 GOOGLE FLIGHTS API - RapidAPI (OPTIMIZADA SEGÚN DOCUMENTACIÓN)
  static const String _baseUrl = 'https://google-flights4.p.rapidapi.com';
  static const String _apiKey = '43db5773a3msh2a82d305d0dbf5ap16f958jsna677a7d7e263';
  
  // Headers exactos según documentación RapidAPI
  static const Map<String, String> _headers = {
    'x-rapidapi-key': _apiKey,
    'x-rapidapi-host': 'google-flights4.p.rapidapi.com',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Variables para mantener estado de búsquedas
  static List<Map<String, dynamic>> _cachedFlights = [];
  static String? _lastSearchId;

  /// Test de conexión con Google Flights API
  static Future<bool> testApiConnection() async {
    try {
      print('🔗 PROBANDO CONEXIÓN CON GOOGLE FLIGHTS API...');
      print('🔑 API Key: $_apiKey');
      print('🌐 Base URL: $_baseUrl');
      print('📋 Headers: $_headers');
      
      // Hacer una búsqueda de prueba simple MIA->JFK (ruta muy popular)
      final testUrl = '$_baseUrl/flights/search-one-way?departureId=MIA&arrivalId=JFK&departureDate=2025-08-30';
      print('🔗 Test URL: $testUrl');
      
      final response = await http.get(
        Uri.parse(testUrl),
        headers: _headers,
      ).timeout(Duration(seconds: 15));

      print('📡 Test Status: ${response.statusCode}');
      print('📄 Response Length: ${response.body.length} characters');
      
      if (response.statusCode == 200) {
        print('✅ CONEXIÓN EXITOSA - Google Flights API funcionando');
        final data = json.decode(response.body);
        
        // Debug completo de la respuesta
        print('📊 Response Keys: ${data.keys.toList()}');
        
        if (data['data'] != null) {
          print('📊 API respondiendo con datos válidos');
          final searchData = data['data'];
          print('🔍 Search Data Keys: ${searchData.keys.toList()}');
          
          // Verificar si hay vuelos
          if (searchData['topFlights'] != null) {
            final topFlights = searchData['topFlights'] as List;
            print('✈️  TopFlights encontrados: ${topFlights.length}');
          } else {
            print('⚠️  No hay topFlights en la respuesta');
          }
          
          if (searchData['otherFlights'] != null) {
            final otherFlights = searchData['otherFlights'] as List;
            print('✈️  OtherFlights encontrados: ${otherFlights.length}');
          } else {
            print('⚠️  No hay otherFlights en la respuesta');
          }
        } else {
          print('⚠️  Response data is null');
        }
        
        return true;
      } else if (response.statusCode == 429) {
        print('⏸️  ERROR 429: Rate limit excedido');
        print('📄 Response: ${response.body}');
        return false;
      } else if (response.statusCode == 403) {
        print('❌ ERROR 403: API Key inválida o sin permisos');
        print('📄 Response: ${response.body}');
        return false;
      } else {
        print('❌ ERROR ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('💥 Error probando conexión: $e');
      return false;
    }
  }

  /// Buscar vuelos de ida - Endpoint principal
  /// GET /flights/search-one-way
  static Future<Map<String, dynamic>?> searchOneWayFlights({
    required String departureId,
    required String arrivalId,
    required String departureDate,
    int adults = 1,
    String cabinClass = 'economy',
  }) async {
    try {
      print('🚀 BÚSQUEDA VUELOS IDA - GOOGLE FLIGHTS API');
      print('✈️  Ruta: $departureId → $arrivalId');
      print('📅 Fecha: $departureDate');
      print('👥 Pasajeros: $adults ($cabinClass)');

      // Validar códigos IATA (3 caracteres exactos)
      if (departureId.length != 3 || arrivalId.length != 3) {
        print('❌ ERROR: Códigos IATA deben ser 3 caracteres');
        return null;
      }

      final url = '$_baseUrl/flights/search-one-way'
          '?departureId=${departureId.toUpperCase()}'
          '&arrivalId=${arrivalId.toUpperCase()}'
          '&departureDate=$departureDate'
          '&adults=$adults'
          '&cabinClass=${cabinClass.toLowerCase()}';

      print('📤 GET: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(Duration(seconds: 30));

      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ RESPUESTA EXITOSA');
        print('📊 Response Keys: ${data.keys.toList()}');
        print('📄 Response Length: ${response.body.length} characters');
        
        // Debug completo de la estructura
        if (response.body.length < 2000) {
          print('📄 Full Response: ${response.body}');
        } else {
          print('📄 Response Preview: ${response.body.substring(0, 500)}...');
        }
        
        // Procesar y cachear vuelos encontrados
        if (data['data'] != null) {
          final searchData = data['data'];
          print('🔍 Search Data Keys: ${searchData.keys.toList()}');
          
          // Extraer vuelos principales (topFlights)
          List<Map<String, dynamic>> allFlights = [];
          
          if (searchData['topFlights'] != null) {
            final topFlights = searchData['topFlights'] as List;
            allFlights.addAll(topFlights.cast<Map<String, dynamic>>());
            print('📊 TopFlights encontrados: ${topFlights.length}');
            
            // Debug primer vuelo
            if (topFlights.isNotEmpty) {
              print('🔍 Primer TopFlight Keys: ${topFlights[0].keys.toList()}');
            }
          } else {
            print('⚠️  No hay topFlights en searchData');
          }
          
          // Agregar otros vuelos (otherFlights)
          if (searchData['otherFlights'] != null) {
            final otherFlights = searchData['otherFlights'] as List;
            allFlights.addAll(otherFlights.cast<Map<String, dynamic>>());
            print('📊 OtherFlights encontrados: ${otherFlights.length}');
          } else {
            print('⚠️  No hay otherFlights en searchData');
          }

          print('📊 Total vuelos antes de procesar: ${allFlights.length}');

          // Procesar vuelos para UI
          _cachedFlights = allFlights.map((flight) => _processFlightForUI(flight)).toList();
          print('💾 Total vuelos cacheados: ${_cachedFlights.length}');
          
          // Mostrar resumen de precios
          if (_cachedFlights.isNotEmpty) {
            print('💰 Precios encontrados:');
            for (int i = 0; i < (_cachedFlights.length > 3 ? 3 : _cachedFlights.length); i++) {
              final price = _cachedFlights[i]['price']['amount'] ?? 'N/A';
              final airline = _cachedFlights[i]['airline']['name'] ?? 'N/A';
              print('   ${i+1}. $airline: $price');
            }
          } else {
            print('⚠️  No se pudieron procesar vuelos para UI');
          }

          return data;
        } else {
          print('⚠️  Respuesta sin datos de vuelos (data is null)');
          return data;
        }
      } else {
        print('❌ Error HTTP ${response.statusCode}');
        print('📄 Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception en búsqueda: $e');
      return null;
    }
  }

  /// Buscar vuelos ida y vuelta - Endpoint round trip
  /// GET /flights/search-roundtrip (según documentación)  
  static Future<Map<String, dynamic>?> searchRoundTripFlights({
    required String departureId,
    required String arrivalId,
    required String departureDate,
    required String returnDate,
    int adults = 1,
    String cabinClass = 'economy',
  }) async {
    try {
      print('🚀 BÚSQUEDA VUELOS IDA Y VUELTA - GOOGLE FLIGHTS');
      print('✈️  Ruta: $departureId ↔ $arrivalId');
      print('📅 Ida: $departureDate | Vuelta: $returnDate');
      print('👥 Pasajeros: $adults ($cabinClass)');

      final url = '$_baseUrl/flights/search-roundtrip'
          '?departureId=${departureId.toUpperCase()}'
          '&arrivalId=${arrivalId.toUpperCase()}'
          '&departureDate=$departureDate'
          '&returnDate=$returnDate'
          '&adults=$adults'
          '&cabinClass=${cabinClass.toLowerCase()}';

      print('📤 GET: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(Duration(seconds: 45));

      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ RESPUESTA EXITOSA - VUELOS IDA Y VUELTA');
        
        // Procesar vuelos round-trip
        if (data['data'] != null) {
          final searchData = data['data'];
          List<Map<String, dynamic>> allFlights = [];
          
          if (searchData['topFlights'] != null) {
            final topFlights = searchData['topFlights'] as List;
            allFlights.addAll(topFlights.cast<Map<String, dynamic>>());
          }
          
          if (searchData['otherFlights'] != null) {
            final otherFlights = searchData['otherFlights'] as List;
            allFlights.addAll(otherFlights.cast<Map<String, dynamic>>());
          }

          _cachedFlights = allFlights.map((flight) => _processFlightForUI(flight)).toList();
          print('💾 Vuelos ida y vuelta cacheados: ${_cachedFlights.length}');
        }

        return data;
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception: $e');
      return null;
    }
  }

  /// Obtener detalles de reserva usando detailToken
  /// GET /flights/get-booking-results (según capturas de RapidAPI)
  static Future<Map<String, dynamic>?> getBookingDetails(String detailToken) async {
    try {
      print('📋 OBTENIENDO DETALLES DE RESERVA...');
      print('🎫 DetailToken: ${detailToken.substring(0, 50)}...');

      // Usar GET con query parameter según documentación
      final url = '$_baseUrl/flights/get-booking-results?token=${Uri.encodeComponent(detailToken)}';
      print('📤 GET: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(Duration(seconds: 30));

      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ DETALLES DE RESERVA OBTENIDOS');
        
        // Procesar información detallada de reserva
        if (data['data'] != null) {
          print('📊 Datos de reserva disponibles');
          return data;
        }
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('💥 Error obteniendo detalles: $e');
      return null;
    }
  }

  /// Método principal para búsqueda de vuelos
  /// Maneja tanto ida como ida y vuelta automáticamente
  static Future<List<Map<String, dynamic>>> searchFlights({
    required String originIata,
    required String destinationIata,
    required String departureDate,
    String? returnDate,
    int adults = 1,
    String cabinClass = 'economy',
  }) async {
    try {
      print('\n🔍 BÚSQUEDA PRINCIPAL DE VUELOS - GOOGLE FLIGHTS API');
      print('🔑 API Key: $_apiKey');
      print('✈️  Ruta: $originIata → $destinationIata');
      print('📅 Salida: $departureDate');
      if (returnDate != null) print('📅 Regreso: $returnDate');
      print('👥 Pasajeros: $adults');
      print('🎫 Clase: $cabinClass');

      Map<String, dynamic>? searchResult;
      
      if (returnDate != null) {
        // Búsqueda ida y vuelta
        print('\n🎯 MODO: Ida y Vuelta (Round-trip)');
        searchResult = await searchRoundTripFlights(
          departureId: originIata,
          arrivalId: destinationIata,
          departureDate: departureDate,
          returnDate: returnDate,
          adults: adults,
          cabinClass: cabinClass,
        );
      } else {
        // Búsqueda solo ida
        print('\n🎯 MODO: Solo Ida');
        searchResult = await searchOneWayFlights(
          departureId: originIata,
          arrivalId: destinationIata,
          departureDate: departureDate,
          adults: adults,
          cabinClass: cabinClass,
        );
      }

      if (searchResult != null && _cachedFlights.isNotEmpty) {
        print('\n✅ BÚSQUEDA EXITOSA');
        print('📊 Total de vuelos encontrados: ${_cachedFlights.length}');
        
        // Ordenar por precio (menor a mayor)
        _cachedFlights.sort((a, b) {
          final priceA = double.tryParse(a['price']['raw_amount']?.toString() ?? '0') ?? 0;
          final priceB = double.tryParse(b['price']['raw_amount']?.toString() ?? '0') ?? 0;
          return priceA.compareTo(priceB);
        });
        
        return _cachedFlights;
      } else {
        print('\n❌ NO SE ENCONTRARON VUELOS');
        print('💡 Posibles causas:');
        print('   - Códigos de aeropuerto inválidos');
        print('   - Fecha en el pasado o muy lejana');
        print('   - No hay vuelos disponibles para esa ruta');
        print('   - Error temporal de la API');
        
        return [];
      }
    } catch (e) {
      print('💥 EXCEPCIÓN en búsqueda principal: $e');
      return [];
    }
  }

  /// Procesar vuelo de Google Flights para UI
  static Map<String, dynamic> _processFlightForUI(Map<String, dynamic> flight) {
    try {
      String airlineName = 'Aerolínea Desconocida';
      String airlineCode = '';
      String departureTime = '--:--';
      String arrivalTime = '--:--';
      String departureAirport = '';
      String arrivalAirport = '';
      String duration = '--';
      String stops = '0';
      String price = '\$0';
      String currency = 'USD';
      double rawPrice = 0.0;
      String detailToken = '';

      // Extraer precio
      if (flight['price'] != null) {
        final priceData = flight['price'];
        if (priceData['amount'] != null) {
          rawPrice = (priceData['amount'] as num).toDouble();
          price = '\$${rawPrice.toStringAsFixed(2)}';
        }
        currency = priceData['currency']?.toString() ?? 'USD';
      }

      // Extraer detailToken para obtener más detalles después
      detailToken = flight['detailToken']?.toString() ?? '';

      // Extraer información de segmentos (legs)
      if (flight['legs'] != null && flight['legs'] is List) {
        final legs = flight['legs'] as List;
        
        if (legs.isNotEmpty) {
          final firstLeg = legs[0] as Map<String, dynamic>;
          
          // Aerolínea
          if (firstLeg['carrier'] != null) {
            final carrier = firstLeg['carrier'];
            airlineName = carrier['name']?.toString() ?? airlineName;
            airlineCode = carrier['iata']?.toString() ?? '';
          }
          
          // Horarios
          departureTime = _formatTime(firstLeg['departureTime']?.toString());
          arrivalTime = _formatTime(firstLeg['arrivalTime']?.toString());
          
          // Aeropuertos
          departureAirport = firstLeg['departureAirport']?.toString() ?? '';
          arrivalAirport = firstLeg['arrivalAirport']?.toString() ?? '';
          
          // Duración
          if (firstLeg['duration'] != null) {
            duration = _formatDuration(firstLeg['duration']);
          }
          
          // Escalas
          stops = (firstLeg['stops']?.toString() ?? '0');
        }
      }

      return {
        'id': flight['id']?.toString() ?? 'flight_${DateTime.now().millisecondsSinceEpoch}',
        'airline': {
          'name': airlineName,
          'code': airlineCode,
          'logo_url': '', // Google Flights no provee logos directamente
        },
        'price': {
          'amount': price,
          'currency': currency,
          'raw_amount': rawPrice,
        },
        'departure_time': departureTime,
        'arrival_time': arrivalTime,
        'source_airport': {'code': departureAirport},
        'destination_airport': {'code': arrivalAirport},
        'duration': duration,
        'stops': stops,
        'detail_token': detailToken,
        'raw_flight': flight,
      };
    } catch (e) {
      print('💥 Error procesando vuelo: $e');
      return {
        'id': 'error_${DateTime.now().millisecondsSinceEpoch}',
        'airline': {'name': 'Error', 'code': '', 'logo_url': ''},
        'price': {'amount': '\$0', 'currency': 'USD', 'raw_amount': 0.0},
        'departure_time': '--:--',
        'arrival_time': '--:--',
        'source_airport': {'code': ''},
        'destination_airport': {'code': ''},
        'duration': '--',
        'stops': '0',
        'detail_token': '',
        'raw_flight': flight,
      };
    }
  }

  /// Formatear tiempo de Google Flights
  static String _formatTime(String? timeString) {
    try {
      if (timeString == null || timeString.isEmpty) return '--:--';
      
      // Google Flights suele devolver tiempo como "14:30" o timestamp
      if (timeString.contains(':')) {
        return timeString.substring(0, 5); // Tomar solo HH:mm
      }
      
      // Si es timestamp, convertir
      final timestamp = int.tryParse(timeString);
      if (timestamp != null) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
      
      return timeString;
    } catch (e) {
      return '--:--';
    }
  }

  /// Formatear duración
  static String _formatDuration(dynamic duration) {
    try {
      if (duration == null) return '--';
      
      // Si viene como minutos totales
      if (duration is int) {
        final hours = duration ~/ 60;
        final minutes = duration % 60;
        return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
      }
      
      // Si viene como string
      final durationStr = duration.toString();
      if (durationStr.contains('h') || durationStr.contains('m')) {
        return durationStr;
      }
      
      return durationStr;
    } catch (e) {
      return duration?.toString() ?? '--';
    }
  }

  /// Autocompletado de aeropuertos usando la API
  /// GET /auto-complete
  static Future<List<Map<String, dynamic>>> searchAirportsAPI(String query) async {
    if (query.length < 2) return searchAirports(query);
    
    try {
      print('🔍 AUTOCOMPLETADO API: $query');
      
      final url = '$_baseUrl/auto-complete?query=${Uri.encodeComponent(query)}';
      print('📤 GET: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(Duration(seconds: 10));
      
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ AUTOCOMPLETADO EXITOSO');
        
        if (data['data'] != null && data['data'] is List) {
          final results = (data['data'] as List).map((airport) {
            return {
              'code': airport['iata']?.toString() ?? '',
              'name': airport['name']?.toString() ?? '',
              'display_name': airport['displayName']?.toString() ?? '',
              'city': airport['city']?.toString() ?? '',
              'country': airport['country']?.toString() ?? '',
            };
          }).where((airport) => airport['code']?.isNotEmpty == true).toList();
          
          print('🏪 Aeropuertos encontrados: ${results.length}');
          return results;
        }
      } else {
        print('⚠️ Error autocompletado ${response.statusCode}, usando lista local');
        return searchAirports(query);
      }
      
    } catch (e) {
      print('💥 Error autocompletado: $e, usando lista local');
      return searchAirports(query);
    }
    
    return [];
  }

  /// Buscar aeropuertos - Lista de aeropuertos principales (fallback)
  static Future<List<Map<String, dynamic>>> searchAirports(String query) async {
    if (query.length < 2) return [];
    
    print('🔍 Buscando aeropuertos (local): $query');
    
    // Aeropuertos principales y populares 
    final airports = [
      // USA - PRINCIPALES
      {'code': 'MIA', 'name': 'Miami International Airport', 'display_name': 'Miami, FL, USA', 'city': 'Miami', 'country': 'USA'},
      {'code': 'JFK', 'name': 'John F Kennedy International Airport', 'display_name': 'New York, NY, USA', 'city': 'New York', 'country': 'USA'},
      {'code': 'LAX', 'name': 'Los Angeles International Airport', 'display_name': 'Los Angeles, CA, USA', 'city': 'Los Angeles', 'country': 'USA'},
      {'code': 'ORD', 'name': 'Chicago O\'Hare International Airport', 'display_name': 'Chicago, IL, USA', 'city': 'Chicago', 'country': 'USA'},
      {'code': 'ATL', 'name': 'Hartsfield-Jackson Atlanta International Airport', 'display_name': 'Atlanta, GA, USA', 'city': 'Atlanta', 'country': 'USA'},
      {'code': 'DFW', 'name': 'Dallas/Fort Worth International Airport', 'display_name': 'Dallas, TX, USA', 'city': 'Dallas', 'country': 'USA'},
      {'code': 'FLL', 'name': 'Fort Lauderdale-Hollywood International Airport', 'display_name': 'Fort Lauderdale, FL, USA', 'city': 'Fort Lauderdale', 'country': 'USA'},
      {'code': 'LAS', 'name': 'McCarran International Airport', 'display_name': 'Las Vegas, NV, USA', 'city': 'Las Vegas', 'country': 'USA'},
      {'code': 'SFO', 'name': 'San Francisco International Airport', 'display_name': 'San Francisco, CA, USA', 'city': 'San Francisco', 'country': 'USA'},
      {'code': 'LGA', 'name': 'LaGuardia Airport', 'display_name': 'New York, NY, USA', 'city': 'New York', 'country': 'USA'},
      
      // CUBA
      {'code': 'HAV', 'name': 'José Martí International Airport', 'display_name': 'Havana, Cuba', 'city': 'Havana', 'country': 'Cuba'},
      {'code': 'VRA', 'name': 'Juan Gualberto Gómez Airport', 'display_name': 'Varadero, Cuba', 'city': 'Varadero', 'country': 'Cuba'},
      {'code': 'HOG', 'name': 'Frank País Airport', 'display_name': 'Holguín, Cuba', 'city': 'Holguín', 'country': 'Cuba'},
      {'code': 'SCU', 'name': 'Antonio Maceo Airport', 'display_name': 'Santiago de Cuba, Cuba', 'city': 'Santiago de Cuba', 'country': 'Cuba'},
      {'code': 'CFG', 'name': 'Jaime González Airport', 'display_name': 'Cienfuegos, Cuba', 'city': 'Cienfuegos', 'country': 'Cuba'},
      
      // EUROPA
      {'code': 'LHR', 'name': 'Heathrow Airport', 'display_name': 'London, UK', 'city': 'London', 'country': 'UK'},
      {'code': 'CDG', 'name': 'Charles de Gaulle Airport', 'display_name': 'Paris, France', 'city': 'Paris', 'country': 'France'},
      {'code': 'MAD', 'name': 'Madrid-Barajas Airport', 'display_name': 'Madrid, Spain', 'city': 'Madrid', 'country': 'Spain'},
      {'code': 'BCN', 'name': 'Barcelona-El Prat Airport', 'display_name': 'Barcelona, Spain', 'city': 'Barcelona', 'country': 'Spain'},
      {'code': 'FCO', 'name': 'Leonardo da Vinci Airport', 'display_name': 'Rome, Italy', 'city': 'Rome', 'country': 'Italy'},
      
      // LATINOAMÉRICA
      {'code': 'CUN', 'name': 'Cancún International Airport', 'display_name': 'Cancún, Mexico', 'city': 'Cancún', 'country': 'Mexico'},
      {'code': 'MEX', 'name': 'Mexico City International Airport', 'display_name': 'Mexico City, Mexico', 'city': 'Mexico City', 'country': 'Mexico'},
      {'code': 'GRU', 'name': 'São Paulo/Guarulhos International Airport', 'display_name': 'São Paulo, Brazil', 'city': 'São Paulo', 'country': 'Brazil'},
      {'code': 'BOG', 'name': 'El Dorado International Airport', 'display_name': 'Bogotá, Colombia', 'city': 'Bogotá', 'country': 'Colombia'},
      {'code': 'LIM', 'name': 'Jorge Chávez International Airport', 'display_name': 'Lima, Peru', 'city': 'Lima', 'country': 'Peru'},
      
      // CARIBE
      {'code': 'SJU', 'name': 'Luis Muñoz Marín International Airport', 'display_name': 'San Juan, Puerto Rico', 'city': 'San Juan', 'country': 'Puerto Rico'},
      {'code': 'PUJ', 'name': 'Punta Cana International Airport', 'display_name': 'Punta Cana, Dominican Republic', 'city': 'Punta Cana', 'country': 'Dominican Republic'},
      {'code': 'NAS', 'name': 'Lynden Pindling International Airport', 'display_name': 'Nassau, Bahamas', 'city': 'Nassau', 'country': 'Bahamas'},
      
      // CANADÁ
      {'code': 'YYZ', 'name': 'Toronto Pearson International Airport', 'display_name': 'Toronto, Canada', 'city': 'Toronto', 'country': 'Canada'},
      {'code': 'YVR', 'name': 'Vancouver International Airport', 'display_name': 'Vancouver, Canada', 'city': 'Vancouver', 'country': 'Canada'},
    ];
    
    // Filtrar aeropuertos basado en la búsqueda
    final results = airports.where((airport) => 
      airport['name']!.toLowerCase().contains(query.toLowerCase()) ||
      airport['display_name']!.toLowerCase().contains(query.toLowerCase()) ||
      airport['code']!.toLowerCase().contains(query.toLowerCase()) ||
      airport['city']!.toLowerCase().contains(query.toLowerCase())
    ).take(8).toList();
    
    print('✅ Encontrados ${results.length} aeropuertos para: $query');
    return results;
  }

  /// Obtener ubicaciones populares
  /// GET /locations
  static Future<List<Map<String, dynamic>>> getLocations() async {
    try {
      print('📍 OBTENIENDO UBICACIONES...');
      
      final url = '$_baseUrl/locations';
      print('📤 GET: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(Duration(seconds: 15));
      
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ UBICACIONES OBTENIDAS');
        
        if (data['data'] != null && data['data'] is List) {
          final locations = (data['data'] as List).map((location) {
            return {
              'code': location['iata']?.toString() ?? '',
              'name': location['name']?.toString() ?? '',
              'display_name': location['displayName']?.toString() ?? '',
              'city': location['city']?.toString() ?? '',
              'country': location['country']?.toString() ?? '',
              'type': location['type']?.toString() ?? 'airport',
            };
          }).toList();
          
          print('📍 Total ubicaciones: ${locations.length}');
          return locations;
        }
      } else {
        print('⚠️ Error obteniendo ubicaciones: ${response.statusCode}');
      }
      
    } catch (e) {
      print('💥 Error obteniendo ubicaciones: $e');
    }
    
    return [];
  }

  /// Obtener monedas disponibles
  /// GET /currencies
  static Future<List<Map<String, dynamic>>> getCurrencies() async {
    try {
      print('💱 OBTENIENDO MONEDAS...');
      
      final url = '$_baseUrl/currencies';
      print('📤 GET: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(Duration(seconds: 10));
      
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ MONEDAS OBTENIDAS');
        
        if (data['data'] != null && data['data'] is List) {
          final currencies = (data['data'] as List).map((currency) {
            return {
              'code': currency['code']?.toString() ?? '',
              'name': currency['name']?.toString() ?? '',
              'symbol': currency['symbol']?.toString() ?? '',
            };
          }).toList();
          
          print('💰 Total monedas: ${currencies.length}');
          return currencies;
        }
      } else {
        print('⚠️ Error obteniendo monedas: ${response.statusCode}');
      }
      
    } catch (e) {
      print('💥 Error obteniendo monedas: $e');
    }
    
    return [];
  }

  /// Decodificar detailToken (para análisis)
  static Map<String, dynamic>? decodeDetailToken(String detailToken) {
    try {
      print('🔍 DECODIFICANDO DETAIL TOKEN...');
      print('🎫 Token: ${detailToken.substring(0, 100)}...');
      
      // El detailToken de Google Flights es un string codificado en base64 o similar
      // que contiene información del vuelo seleccionado
      
      // Intentar decodificar como base64
      try {
        final decoded = utf8.decode(base64.decode(detailToken));
        final jsonData = json.decode(decoded);
        print('✅ Token decodificado exitosamente');
        return jsonData;
      } catch (e) {
        print('⚠️  Token no es JSON base64 estándar');
      }
      
      // El token puede ser un formato propietario de Google
      // Por ahora lo devolvemos tal como viene
      return {
        'token': detailToken,
        'decoded': false,
        'note': 'Token en formato propietario de Google Flights'
      };
      
    } catch (e) {
      print('💥 Error decodificando token: $e');
      return null;
    }
  }

  /// Crear orden de vuelo con información de pasajeros
  /// Endpoint simulado ya que Google Flights API no maneja reservas directamente
  static Future<Map<String, dynamic>?> createOrder({
    required String offerId,
    required List<Map<String, dynamic>> passengers,
  }) async {
    try {
      print('📋 CREANDO ORDEN DE VUELO...');
      print('🎫 Offer ID: $offerId');
      print('👥 Pasajeros: ${passengers.length}');
      
      // Validar datos de pasajeros
      for (int i = 0; i < passengers.length; i++) {
        final passenger = passengers[i];
        print('   Pasajero ${i + 1}: ${passenger['given_name']} ${passenger['family_name']}');
        
        // Validar campos requeridos
        if (passenger['given_name']?.toString().trim().isEmpty == true ||
            passenger['family_name']?.toString().trim().isEmpty == true ||
            passenger['email']?.toString().trim().isEmpty == true) {
          print('❌ Error: Datos de pasajero incompletos');
          return null;
        }
      }
      
      // Simulación de creación de orden
      await Future.delayed(Duration(seconds: 2));
      
      // Generar orden simulada
      final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
      final bookingReference = 'GF${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      
      final orderData = {
        'success': true,
        'order_id': orderId,
        'booking_reference': bookingReference,
        'status': 'created',
        'flight_offer_id': offerId,
        'passengers': passengers.map((p) => {
          'id': 'PAX_${DateTime.now().millisecondsSinceEpoch}_${passengers.indexOf(p)}',
          'title': p['title'] ?? 'mr',
          'given_name': p['given_name'],
          'family_name': p['family_name'],
          'email': p['email'],
          'phone_number': p['phone_number'],
          'born_on': p['born_on'],
        }).toList(),
        'payment_required': true,
        'total_amount': 0.0, // Se calculará desde el vuelo seleccionado
        'currency': 'USD',
        'expires_at': DateTime.now().add(Duration(minutes: 30)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'payment_methods': [
          'balance',
          'credit_card',
          'paypal'
        ],
        'terms_accepted': false,
      };
      
      print('✅ ORDEN CREADA EXITOSAMENTE');
      print('📝 Order ID: $orderId');
      print('🎫 Booking Reference: $bookingReference');
      
      return orderData;
      
    } catch (e) {
      print('💥 Error creando orden: $e');
      return null;
    }
  }

  /// Procesar pago - Simulación para desarrollo
  static Future<Map<String, dynamic>?> payWithBalance({
    String? flightId,
    double? amount,
    String? detailToken,
  }) async {
    try {
      print('💳 PROCESANDO PAGO DE VUELO...');
      print('✈️  Flight ID: $flightId');
      print('💰 Monto: \$${amount?.toStringAsFixed(2) ?? "N/A"}');
      print('🎫 Detail Token: ${detailToken?.substring(0, 30)}...');

      // Simulación de procesamiento
      await Future.delayed(Duration(seconds: 3));
      
      return {
        'success': true,
        'booking_reference': 'GF${DateTime.now().millisecondsSinceEpoch}',
        'payment_id': 'pay_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount?.toStringAsFixed(2) ?? '0.00',
        'currency': 'USD',
        'status': 'confirmed',
        'flight_details': {
          'id': flightId,
          'detail_token': detailToken,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('💥 Error procesando pago: $e');
      return null;
    }
  }

  // Getters
  static List<Map<String, dynamic>> get cachedFlights => _cachedFlights;
  static String? get lastSearchId => _lastSearchId;

  // Limpiar estado
  static void clearState() {
    _cachedFlights.clear();
    _lastSearchId = null;
    print('🧹 Estado limpiado (vuelos cacheados)');
  }

  /// Métodos de conveniencia para diferentes tipos de búsqueda

  /// Búsqueda rápida - solo vuelos principales
  static Future<List<Map<String, dynamic>>> searchQuickFlights({
    required String originIata,
    required String destinationIata,
    required String departureDate,
    String? returnDate,
    int adults = 1,
  }) async {
    print('⚡ BÚSQUEDA RÁPIDA DE VUELOS');
    return await searchFlights(
      originIata: originIata,
      destinationIata: destinationIata,
      departureDate: departureDate,
      returnDate: returnDate,
      adults: adults,
      cabinClass: 'economy',
    );
  }

  /// Búsqueda premium - clase business/primera
  static Future<List<Map<String, dynamic>>> searchPremiumFlights({
    required String originIata,
    required String destinationIata,
    required String departureDate,
    String? returnDate,
    int adults = 1,
    String cabinClass = 'business',
  }) async {
    print('👑 BÚSQUEDA VUELOS PREMIUM');
    return await searchFlights(
      originIata: originIata,
      destinationIata: destinationIata,
      departureDate: departureDate,
      returnDate: returnDate,
      adults: adults,
      cabinClass: cabinClass,
    );
  }
}