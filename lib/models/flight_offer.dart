class FlightOffer {
  final String id;
  final String totalAmount;
  final String totalCurrency;
  final String airline;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int stops;
  final List<FlightSegment> segments;
  final Map<String, dynamic> rawData;
  final String airlineLogo;
  final String flightNumber;

  FlightOffer({
    required this.id,
    required this.totalAmount,
    required this.totalCurrency,
    required this.airline,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.stops,
    required this.segments,
    required this.rawData,
    required this.airlineLogo,
    required this.flightNumber,
  });

  factory FlightOffer.fromBackendJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing Backend JSON: ${json.keys.toList()}');
      
      // Extraer información básica del backend directo
      final String id = json['id'] ?? '';
      final String totalAmount = (json['total_amount'] ?? json['price'] ?? '0').toString();
      final String totalCurrency = json['total_currency'] ?? json['currency'] ?? 'USD';
      
      // Extraer información de la aerolínea del backend - CORREGIR CAMPOS
      String airline = 'Aerolínea Desconocida';
      if (json['airline'] != null && json['airline'].toString().isNotEmpty) {
        airline = json['airline'].toString();
      } else if (json['owner'] != null && json['owner']['name'] != null) {
        airline = json['owner']['name'];
      }
      
      // Extraer logo de aerolínea - CORREGIR CAMPOS
      String airlineLogo = '';
      if (json['airline_logo'] != null && json['airline_logo'].toString().isNotEmpty) {
        airlineLogo = json['airline_logo'].toString();
      } else if (json['owner'] != null && json['owner']['logo_symbol_url'] != null) {
        airlineLogo = json['owner']['logo_symbol_url'];
      }
      
      // Extraer datos de tiempo y duración - CORREGIR CAMPOS
      String duration = json['duration'] ?? 'N/A';
      String departureTime = json['departureTime'] ?? json['departing_at'] ?? 'N/A';
      String arrivalTime = json['arrivalTime'] ?? json['arriving_at'] ?? 'N/A';
      int stops = int.tryParse(json['stops'].toString()) ?? 0;
      String flightNumber = json['flight_number'] ?? '';
      
      // Extraer segmentos del backend
      final slices = json['slices'] as List<dynamic>? ?? [];
      final segments = <FlightSegment>[];

      if (slices.isNotEmpty) {
        final firstSlice = slices[0] as Map<String, dynamic>;
        duration = firstSlice['duration'] ?? duration;
        
        final sliceSegments = firstSlice['segments'] as List<dynamic>? ?? [];
        stops = sliceSegments.isNotEmpty ? (sliceSegments.length - 1) : stops;
        
        for (int i = 0; i < sliceSegments.length; i++) {
          try {
            final segmentData = sliceSegments[i];
            if (segmentData != null && segmentData is Map<String, dynamic>) {
              print('🔍 DEBUG Segment $i: $segmentData');
              
              // Crear segmento simple para datos del backend
              segments.add(FlightSegment(
                id: segmentData['id'] ?? '',
                departingAt: segmentData['departing_at'] ?? segmentData['departureTime'] ?? '',
                arrivingAt: segmentData['arriving_at'] ?? segmentData['arrivalTime'] ?? '',
                originAirport: '${segmentData['origin_airport'] ?? 'N/A'} - ${segmentData['origin_airport'] ?? 'Unknown'}',
                destinationAirport: '${segmentData['destination_airport'] ?? 'N/A'} - ${segmentData['destination_airport'] ?? 'Unknown'}',
                airline: segmentData['airline'] ?? 'Unknown',
                flightNumber: segmentData['flight_number'] ?? '',
                aircraft: 'Unknown Aircraft',
                duration: segmentData['duration'] ?? '',
              ));
            }
          } catch (e) {
            print('⚠️ Error parseando segment $i: $e');
          }
        }

        if (segments.isNotEmpty) {
          departureTime = segments[0].departingAt;
          arrivalTime = segments[segments.length - 1].arrivingAt;
        }
      }

      print('✅ Parsed Backend: $airline - \$$totalAmount $totalCurrency');
      
      return FlightOffer(
        id: id,
        totalAmount: totalAmount,
        totalCurrency: totalCurrency,
        airline: airline,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        duration: duration,
        stops: stops,
        segments: segments,
        rawData: json,
        airlineLogo: airlineLogo,
        flightNumber: flightNumber,
      );
    } catch (e) {
      print('❌ Error parsing Backend FlightOffer: $e');
      print('📋 JSON data: $json');
      return FlightOffer(
        id: json['id'] ?? 'unknown',
        totalAmount: '0',
        totalCurrency: 'USD',
        airline: 'Error parsing',
        departureTime: 'N/A',
        arrivalTime: 'N/A',
        duration: 'N/A',
        stops: 0,
        segments: [],
        rawData: json,
        airlineLogo: '',
        flightNumber: '',
      );
    }
  }

  factory FlightOffer.fromDuffelJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing JSON: ${json.keys.toList()}');
      
      // Extraer información básica - CORREGIR CAMPOS
      final String id = json['id'] ?? json['offer_id'] ?? '';
      final String totalAmount = (json['total_amount'] ?? json['price'] ?? '0').toString();
      final String totalCurrency = json['total_currency'] ?? json['currency'] ?? 'USD';
      
      // Extraer información de la aerolínea - MÚLTIPLES FUENTES
      String airline = 'Aerolínea Desconocida';
      if (json['airline'] != null && json['airline'].toString() != 'Desconocida') {
        airline = json['airline'].toString();
      } else if (json['airline_code'] != null && json['airline_code'].toString().isNotEmpty) {
        // Mapear códigos IATA a nombres de aerolíneas conocidas
        final airlineCode = json['airline_code'].toString().toUpperCase();
        airline = _getAirlineNameFromCode(airlineCode);
      } else if (json['owner'] != null && json['owner']['name'] != null) {
        airline = json['owner']['name'];
      } else if (json['marketing_carrier'] != null && json['marketing_carrier']['name'] != null) {
        airline = json['marketing_carrier']['name'];
      } else if (json['flight_number'] != null) {
        // Extraer aerolínea del número de vuelo (ej: AA1234 -> American Airlines)
        final flightNum = json['flight_number'].toString();
        final codeMatch = RegExp(r'^([A-Z]{2})').firstMatch(flightNum);
        if (codeMatch != null) {
          airline = _getAirlineNameFromCode(codeMatch.group(1)!);
        }
      }

      // Extraer logo de aerolínea
      String airlineLogo = '';
      if (json['airline_logo'] != null) {
        airlineLogo = json['airline_logo'].toString();
      } else if (json['airline_code'] != null) {
        // Generar URL de logo basado en código IATA
        final code = json['airline_code'].toString().toUpperCase();
        airlineLogo = 'https://daisycon.io/images/airline/?width=60&height=60&color=ffffff&iata=$code';
      }

      // Extraer segmentos de vuelo
      final slices = json['slices'] as List<dynamic>? ?? [];
      final segments = <FlightSegment>[];
      String duration = 'N/A';
      String departureTime = 'N/A';
      String arrivalTime = 'N/A';
      int stops = 0;
      String flightNumber = json['flight_number'] ?? '';

      if (slices.isNotEmpty) {
        final firstSlice = slices[0] as Map<String, dynamic>;
        duration = firstSlice['duration'] ?? 'N/A';
        
        final sliceSegments = firstSlice['segments'] as List<dynamic>? ?? [];
        stops = sliceSegments.isNotEmpty ? (sliceSegments.length - 1) : 0;
        
        for (int i = 0; i < sliceSegments.length; i++) {
          try {
            final segmentData = sliceSegments[i];
            if (segmentData != null && segmentData is Map<String, dynamic>) {
              segments.add(FlightSegment.fromDuffelJson(segmentData));
            }
          } catch (e) {
            print('⚠️ Error parseando segment $i: $e');
          }
        }

        if (segments.isNotEmpty) {
          departureTime = segments[0].departingAt;
          arrivalTime = segments[segments.length - 1].arrivingAt;
        } else {
          // Si no hay segmentos, usar datos directos del JSON
          departureTime = json['departureTime']?.toString() ?? json['departing_at']?.toString() ?? 'N/A';
          arrivalTime = json['arrivalTime']?.toString() ?? json['arriving_at']?.toString() ?? 'N/A';
        }
      }

      // SI NO HAY SLICES, INTENTAR OBTENER DATOS DIRECTOS
      if (slices.isEmpty && json['departure_time'] != null) {
        departureTime = json['departure_time'].toString();
        arrivalTime = json['arrival_time']?.toString() ?? 'N/A';
        duration = json['duration']?.toString() ?? 'N/A';
      }

      // SI NO HAY SLICES, USAR DATOS DEL BACKEND LOCAL
      if (slices.isEmpty) {
        departureTime = json['departureTime']?.toString() ?? 'N/A';
        arrivalTime = json['arrivalTime']?.toString() ?? 'N/A';
        duration = json['duration']?.toString() ?? 'N/A';
        stops = int.tryParse(json['stops'].toString()) ?? 0;
        
        // Crear segmentos para backend local
        if (json['origin_airport'] != null && json['destination_airport'] != null) {
          final stops = int.tryParse(json['stops'].toString()) ?? 0;
          
          if (stops > 0) {
            // Vuelo con paradas - crear segmentos múltiples
            // Segmento 1: Origen → Parada intermedia
            segments.add(FlightSegment(
              id: '${id}_1',
              departingAt: departureTime,
              arrivingAt: 'TBD', // Tiempo estimado de parada
              originAirport: json['origin_airport'],
              destinationAirport: 'PARADA', // Aeropuerto de parada
              airline: airline,
              flightNumber: json['flight_number'] ?? json['airline_code'] ?? '',
              aircraft: 'Unknown Aircraft',
              duration: 'TBD',
            ));
            
            // Segmento 2: Parada intermedia → Destino final
            segments.add(FlightSegment(
              id: '${id}_2',
              departingAt: 'TBD', // Tiempo de salida de parada
              arrivingAt: arrivalTime,
              originAirport: 'PARADA', // Aeropuerto de parada
              destinationAirport: json['destination_airport'],
              airline: airline,
              flightNumber: json['flight_number'] ?? json['airline_code'] ?? '',
              aircraft: 'Unknown Aircraft',
              duration: 'TBD',
            ));
          } else {
            // Vuelo directo - crear un solo segmento
            segments.add(FlightSegment(
              id: id,
              departingAt: departureTime,
              arrivingAt: arrivalTime,
              originAirport: json['origin_airport'],
              destinationAirport: json['destination_airport'],
              airline: airline,
              flightNumber: json['flight_number'] ?? json['airline_code'] ?? '',
              aircraft: 'Unknown Aircraft',
              duration: duration,
            ));
          }
        }
      }

      print('✅ Parsed: $airline - \$$totalAmount $totalCurrency');
      
      return FlightOffer(
        id: id,
        totalAmount: totalAmount,
        totalCurrency: totalCurrency,
        airline: airline,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        duration: duration,
        stops: stops,
        segments: segments,
        rawData: json,
        airlineLogo: airlineLogo,
        flightNumber: flightNumber,
      );
    } catch (e) {
      print('❌ Error parsing FlightOffer: $e');
      print('📋 JSON data: $json');
      return FlightOffer(
        id: json['id'] ?? 'unknown',
        totalAmount: '0',
        totalCurrency: 'USD',
        airline: 'Error parsing',
        departureTime: 'N/A',
        arrivalTime: 'N/A',
        duration: 'N/A',
        stops: 0,
        segments: [],
        rawData: json,
        airlineLogo: '',
        flightNumber: '',
      );
    }
  }

  // Mapear códigos IATA a nombres de aerolíneas conocidas
  static String _getAirlineNameFromCode(String code) {
    final airlineMap = {
      'AA': 'American Airlines',
      'DL': 'Delta Air Lines',
      'UA': 'United Airlines',
      'B6': 'JetBlue Airways',
      'WN': 'Southwest Airlines',
      'AS': 'Alaska Airlines',
      'F9': 'Frontier Airlines',
      'NK': 'Spirit Airlines',
      'HA': 'Hawaiian Airlines',
      'G4': 'Allegiant Air',
      'AM': 'Aeromexico',
      'AV': 'Avianca',
      'CM': 'Copa Airlines',
      'LA': 'LATAM Airlines',
      'IB': 'Iberia',
      'BA': 'British Airways',
      'AF': 'Air France',
      'LH': 'Lufthansa',
      'KL': 'KLM',
      'AZ': 'ITA Airways',
      'TP': 'TAP Air Portugal',
      'LX': 'Swiss International Air Lines',
      'OS': 'Austrian Airlines',
      'SN': 'Brussels Airlines',
      'SK': 'SAS Scandinavian Airlines',
      'AY': 'Finnair',
      'LO': 'LOT Polish Airlines',
      'OK': 'Czech Airlines',
      'RO': 'TAROM',
      'SU': 'Aeroflot',
      'TK': 'Turkish Airlines',
      'QR': 'Qatar Airways',
      'EK': 'Emirates',
      'EY': 'Etihad Airways',
      'SV': 'Saudia',
      'MS': 'EgyptAir',
      'ET': 'Ethiopian Airlines',
      'KE': 'Korean Air',
      'OZ': 'Asiana Airlines',
      'NH': 'All Nippon Airways',
      'JL': 'Japan Airlines',
      'CA': 'Air China',
      'MU': 'China Eastern Airlines',
      'CZ': 'China Southern Airlines',
      'HU': 'Hainan Airlines',
      'AI': 'Air India',
      '6E': 'IndiGo',
      '9W': 'Jet Airways',
      'TG': 'Thai Airways',
      'VN': 'Vietnam Airlines',
      'PR': 'Philippine Airlines',
      'GA': 'Garuda Indonesia',
      'MH': 'Malaysia Airlines',
      'SQ': 'Singapore Airlines',
      'CX': 'Cathay Pacific',
      'BR': 'EVA Air',
      'CI': 'China Airlines',
      'NZ': 'Air New Zealand',
      'QF': 'Qantas',
      'VA': 'Virgin Australia',
      'AC': 'Air Canada',
      'WS': 'WestJet',
      'PD': 'Porter Airlines',
      'F8': 'Flair Airlines',
      'TS': 'Air Transat',
      'WG': 'Sunwing Airlines',
      'RV': 'Air Canada Rouge',
      'XW': 'NokScoot',
      'VJ': 'VietJet Air',
      'Z2': 'Philippines AirAsia',
      'FD': 'Thai AirAsia',
      'AK': 'AirAsia',
      'D7': 'AirAsia X',
      'QZ': 'Indonesia AirAsia',
      'I5': 'AirAsia India',
      'UO': 'Hong Kong Express',
      'UQ': 'Urumqi Air',
      'PN': 'China West Air',
      'GS': 'Tianjin Airlines',
      'GJ': 'Loong Air',
      'JD': 'Beijing Capital Airlines',
      'NS': 'Hebei Airlines',
      'KY': 'Kunming Airlines',
      'MF': 'Xiamen Airlines',
      'SC': 'Shandong Airlines',
      '3U': 'Sichuan Airlines',
      'EU': 'Chengdu Airlines',
      '8L': 'Lucky Air',
      '9C': 'Spring Airlines',
      'HO': 'Juneyao Airlines',
      'BK': 'Okay Airways',
      'DR': 'Ruili Airlines',
      'GT': 'Guizhou Airlines',
      'RY': 'Jiangxi Air',
      'ZH': 'Shenzhen Airlines',
      'KN': 'China United Airlines',
      'G5': 'China Express Airlines',
      'QW': 'Qingdao Airlines',
      'FU': 'Fuzhou Airlines',
      'TV': 'Tibet Airlines',
    };
    
    return airlineMap[code] ?? 'Aerolínea $code';
  }

  String get formattedPrice => '$totalCurrency $totalAmount';
  
  String get stopsText {
    if (stops == 0) return 'Directo';
    if (stops == 1) return '1 escala';
    return '$stops escalas';
  }

  String get formattedDepartureTime {
    try {
      final dateTime = DateTime.parse(departureTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return departureTime;
    }
  }

  String get formattedArrivalTime {
    try {
      final dateTime = DateTime.parse(arrivalTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return arrivalTime;
    }
  }

  String get formattedDuration {
    // Formato esperado: "PT1H30M" -> "1h 30m"
    if (duration.startsWith('PT')) {
      final timeStr = duration.substring(2);
      String result = '';
      
      final hourMatch = RegExp(r'(\d+)H').firstMatch(timeStr);
      final minuteMatch = RegExp(r'(\d+)M').firstMatch(timeStr);
      
      if (hourMatch != null) {
        result += '${hourMatch.group(1)}h ';
      }
      if (minuteMatch != null) {
        result += '${minuteMatch.group(1)}m';
      }
      
      return result.trim();
    }
    return duration;
  }

  // ✅ PROPIEDADES ADICIONALES REQUERIDAS

  /// Precio como double para comparaciones y cálculos
  double get price {
    try {
      return double.parse(totalAmount);
    } catch (e) {
      return 0.0;
    }
  }

  /// Moneda del vuelo
  String get currency => totalCurrency;

  /// Código IATA del aeropuerto de origen
  String get origin {
    if (segments.isNotEmpty) {
      final originCode = segments[0].originAirport.split(' - ')[0];
      return originCode != 'N/A' ? originCode : 'N/A';
    }
    return 'N/A';
  }

  /// Código IATA del aeropuerto de destino
  String get destination {
    if (segments.isNotEmpty) {
      final destCode = segments[segments.length - 1].destinationAirport.split(' - ')[0];
      return destCode != 'N/A' ? destCode : 'N/A';
    }
    return 'N/A';
  }

  /// Código de la aerolínea (extraído del segmento)
  String get airlineCode {
    // Priorizar rawData del backend
    if (rawData['airline_code'] != null && rawData['airline_code'].toString().isNotEmpty) {
      return rawData['airline_code'].toString().toUpperCase();
    }
    
    // Usar el campo flightNumber directamente
    if (flightNumber.isNotEmpty) {
      final match = RegExp(r'^([A-Z]{2,3})').firstMatch(flightNumber);
      if (match != null) {
        return match.group(1) ?? 'N/A';
      }
    }
    
    // Fallback a segmentos
    if (segments.isNotEmpty) {
      final segmentFlightNumber = segments[0].flightNumber;
      final match = RegExp(r'^([A-Z]{2,3})').firstMatch(segmentFlightNumber);
      if (match != null) {
        return match.group(1) ?? 'N/A';
      }
    }
    return 'N/A';
  }

  /// Número de vuelo principal
  String get flightNumberValue {
    // Usar el campo flightNumber directamente si está disponible
    if (flightNumber.isNotEmpty) {
      return flightNumber;
    }
    
    // Fallback a segmentos
    if (segments.isNotEmpty) {
      return segments[0].flightNumber;
    }
    return '';
  }

  /// Si el vuelo es reembolsable (por defecto true para Duffel)
  bool get refundable => true;

  /// Si el vuelo es modificable (por defecto true para Duffel)
  bool get changeable => true;

  /// Asientos disponibles (información no siempre disponible en Duffel)
  int get availableSeats => 9; // Valor por defecto
}

class FlightSegment {
  final String id;
  final String departingAt;
  final String arrivingAt;
  final String originAirport;
  final String destinationAirport;
  final String airline;
  final String flightNumber;
  final String aircraft;
  final String duration;

  FlightSegment({
    required this.id,
    required this.departingAt,
    required this.arrivingAt,
    required this.originAirport,
    required this.destinationAirport,
    required this.airline,
    required this.flightNumber,
    required this.aircraft,
    required this.duration,
  });

  factory FlightSegment.fromDuffelJson(Map<String, dynamic> json) {
    try {
      // 🎯 COMPATIBILIDAD CON BACKEND SIMPLIFICADO
      String originAirport = 'N/A - Unknown';
      String destinationAirport = 'N/A - Unknown';
      String airline = 'Unknown Airline';
      String flightNumber = '';
      String aircraft = 'Unknown Aircraft';
      
      // Intentar datos complejos de Duffel primero
      if (json['origin'] != null && json['origin'] is Map<String, dynamic>) {
        final origin = json['origin'] as Map<String, dynamic>;
        originAirport = '${origin['iata_code'] ?? 'N/A'} - ${origin['name'] ?? 'Unknown'}';
      } else if (json['origin_airport'] != null) {
        // Backend simplificado
        originAirport = '${json['origin_airport']} - ${json['origin_airport']}';
      }
      
      if (json['destination'] != null && json['destination'] is Map<String, dynamic>) {
        final destination = json['destination'] as Map<String, dynamic>;
        destinationAirport = '${destination['iata_code'] ?? 'N/A'} - ${destination['name'] ?? 'Unknown'}';
      } else if (json['destination_airport'] != null) {
        // Backend simplificado
        destinationAirport = '${json['destination_airport']} - ${json['destination_airport']}';
      }
      
      if (json['operating_carrier'] != null && json['operating_carrier'] is Map<String, dynamic>) {
        final operatingCarrier = json['operating_carrier'] as Map<String, dynamic>;
        airline = operatingCarrier['name'] ?? 'Unknown Airline';
        flightNumber = '${operatingCarrier['iata_code'] ?? ''}${json['operating_carrier_flight_number'] ?? ''}';
      } else if (json['airline'] != null) {
        // Backend simplificado
        airline = json['airline'].toString();
        flightNumber = json['airline_code']?.toString() ?? '';
      }
      
      if (json['aircraft'] != null && json['aircraft'] is Map<String, dynamic>) {
        final aircraftData = json['aircraft'] as Map<String, dynamic>;
        aircraft = aircraftData['name'] ?? 'Unknown Aircraft';
      }

      return FlightSegment(
        id: json['id'] ?? '',
        departingAt: json['departing_at'] ?? json['departureTime'] ?? '',
        arrivingAt: json['arriving_at'] ?? json['arrivalTime'] ?? '',
        originAirport: originAirport,
        destinationAirport: destinationAirport,
        airline: airline,
        flightNumber: flightNumber,
        aircraft: aircraft,
        duration: json['duration'] ?? '',
      );
    } catch (e) {
      print('Error parsing FlightSegment: $e');
      return FlightSegment(
        id: json['id'] ?? 'unknown',
        departingAt: '',
        arrivingAt: '',
        originAirport: 'Error parsing',
        destinationAirport: 'Error parsing',
        airline: 'Error parsing',
        flightNumber: '',
        aircraft: '',
        duration: '',
      );
    }
  }
}
