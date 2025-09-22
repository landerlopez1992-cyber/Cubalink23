import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/flight_offer.dart';
import 'flight_booking_enhanced.dart';

class FlightDetailSimple extends StatelessWidget {
  final FlightOffer flight;

  const FlightDetailSimple({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    print('🔍 DEBUG: FlightDetailSimple abierta exitosamente');
    print('🔍 DEBUG: Vuelo seleccionado: ${flight.airline} - ${flight.formattedPrice}');
    print('🔍 DEBUG: Raw data keys: ${flight.rawData.keys.toList()}');
    print('🔍 DEBUG: Logo URL: "${flight.airlineLogo}"');
    print('🔍 DEBUG: Airline Code: "${flight.airlineCode}"');
    
    // Extraer datos adicionales de Duffel API
    final rawDuffelData = flight.rawData;
    final slices = flight.rawData['slices'] as List<dynamic>? ?? [];
    
    // Debug: Ver si hay slices
    print('🔍 DEBUG FlightDetailSimple:');
    print('🔍 Slices count: ${slices.length}');
    print('🔍 RawData keys: ${flight.rawData.keys.toList()}');
    print('🔍 Flight origin: ${flight.origin}');
    print('🔍 Flight destination: ${flight.destination}');
    print('🔍 Flight segments count: ${flight.segments.length}');
    print('🔍 RawData origin_airport: ${flight.rawData['origin_airport']}');
    print('🔍 RawData destination_airport: ${flight.rawData['destination_airport']}');
    if (flight.segments.isNotEmpty) {
      print('🔍 First segment origin: ${flight.segments[0].originAirport}');
      print('🔍 First segment destination: ${flight.segments[0].destinationAirport}');
      if (flight.segments.length > 1) {
        print('🔍 Last segment origin: ${flight.segments[flight.segments.length - 1].originAirport}');
        print('🔍 Last segment destination: ${flight.segments[flight.segments.length - 1].destinationAirport}');
      }
    }
    if (slices.isNotEmpty) {
      print('🔍 First slice keys: ${slices[0].keys.toList()}');
      final segments = slices[0]['segments'] as List<dynamic>? ?? [];
      print('🔍 Segments count: ${segments.length}');
      if (segments.isNotEmpty) {
        print('🔍 First segment keys: ${segments[0].keys.toList()}');
        print('🔍 First segment origin: ${segments[0]['origin']}');
        print('🔍 First segment destination: ${segments[0]['destination']}');
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Vuelo'),
        backgroundColor: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TARJETA PRINCIPAL
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Logo de aerolínea
                        _buildAirlineLogo(),
                        SizedBox(width: 16),
                        
                        // Información del vuelo
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flight.airline,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Vuelo ${flight.flightNumberValue}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Precio
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              flight.formattedPrice,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF37474F),
                              ),
                            ),
                            Text(
                              'por persona',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    
                    // RUTA DEL VUELO COMPLETA
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: _buildCompleteRoute(slices),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // INFORMACIÓN ADICIONAL
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Información del Vuelo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    _buildInfoRow('Aerolínea:', flight.airline),
                    _buildInfoRow('Número de Vuelo:', flight.flightNumberValue),
                    _buildInfoRow('Origen:', flight.rawData['origin_airport'] ?? flight.origin),
                    _buildInfoRow('Destino:', flight.rawData['destination_airport'] ?? flight.destination),
                    _buildInfoRow('Duración:', flight.formattedDuration),
                    _buildInfoRow('Escalas:', flight.stopsText),
                    _buildInfoRow('Precio:', flight.formattedPrice),
                    ],
                  ),
                ),
              ),
            
            SizedBox(height: 16),
            
            // ✈️ INFORMACIÓN DETALLADA DE VUELO
            if (slices.isNotEmpty)
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flight_takeoff, color: Colors.blue[600], size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Detalles de Segmentos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      ...slices.asMap().entries.map((entry) {
                        final index = entry.key;
                        final slice = entry.value as Map<String, dynamic>;
                        final segments = slice['segments'] as List<dynamic>? ?? [];
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (slices.length > 1)
                              Text(
                                'Tramo ${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ...segments.asMap().entries.map((segEntry) {
                              final segIndex = segEntry.key;
                              final segment = segEntry.value as Map<String, dynamic>;
                              
                              return _buildSegmentCard(segment, segIndex + 1);
                            }),
                            if (index < slices.length - 1) SizedBox(height: 16),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            
            SizedBox(height: 16),
            
            // BOTONES DE ACCIÓN
            Row(
              children: [
                // Botón de compartir
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _shareFlight(flight),
                      icon: Icon(Icons.share, size: 18),
                      label: Text('Compartir'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF37474F)), // Azul gris oscuro oficial Cubalink23
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 12),
                
                // Botón de favoritos
                SizedBox(
                  width: 48,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => _addToFavorites(context, flight),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFFFF9800)), // Naranja oficial Cubalink23
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Icon(Icons.favorite_border, color: Color(0xFFFF9800)), // Naranja oficial Cubalink23
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // BOTÓN DE RESERVA PRINCIPAL
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  print('🔍 DEBUG: Botón de reserva presionado');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FlightBookingEnhanced(flight: flight),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF9800), // Naranja oficial Cubalink23
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Reservar Vuelo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 Construir logo de aerolínea con múltiples fuentes
  Widget _buildAirlineLogo() {
    final airlineCode = flight.airlineCode;
    print('🔍 DEBUG Logo: airlineCode = $airlineCode');
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          'https://images.kiwi.com/airlines/64/$airlineCode.png',
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error cargando logo: $error');
            return Icon(
              Icons.business,
              size: 40,
              color: Colors.grey[600],
            );
          },
        ),
      ),
    );
  }

  /// 🛣️ Construir ruta completa del vuelo
  Widget _buildCompleteRoute(List<dynamic> slices) {
    print('🔍 DEBUG _buildCompleteRoute:');
    print('🔍 Flight segments count: ${flight.segments.length}');
    print('🔍 Raw slices count: ${slices.length}');
    
    // Usar datos directos del backend
    final originAirport = flight.rawData['origin_airport'] ?? 'N/A';
    final destinationAirport = flight.rawData['destination_airport'] ?? 'N/A';
    
    print('🔍 Origin: $originAirport, Destination: $destinationAirport');
    
    // Mostrar ruta simple con datos del backend
    return _buildSimpleRoute(originAirport, destinationAirport);
  }

  /// 🛣️ Construir ruta con segmentos
  Widget _buildSegmentedRoute(List<dynamic> rawSegments) {
    print('🔍 DEBUG _buildSegmentedRoute:');
    print('🔍 Raw segments: $rawSegments');
    
    // Usar segmentos de flight si están disponibles, sino usar rawSegments
    List<dynamic> segmentsToUse = flight.segments.isNotEmpty ? flight.segments : rawSegments;
    
    if (segmentsToUse.isEmpty) {
      return _buildSimpleRoute();
    }
    
    final List<Widget> routeWidgets = [];
    
    for (int i = 0; i < segmentsToUse.length; i++) {
      final segment = segmentsToUse[i];
      
      String originCode = '';
      String destinationCode = '';
      String departureTime = '';
      String duration = '';
      
      // Intentar extraer datos del segmento
      if (segment is Map<String, dynamic>) {
        // Es un Map (rawData)
        final origin = segment['origin'] as Map<String, dynamic>? ?? {};
        final destination = segment['destination'] as Map<String, dynamic>? ?? {};
        originCode = origin['iata_code']?.toString() ?? 'N/A';
        destinationCode = destination['iata_code']?.toString() ?? 'N/A';
        departureTime = segment['departing_at']?.toString() ?? '';
        duration = segment['duration']?.toString() ?? '';
      } else {
        // Intentar acceder como FlightSegment
        try {
          originCode = segment.originAirport.split(' - ')[0];
          destinationCode = segment.destinationAirport.split(' - ')[0];
          departureTime = segment.departingAt;
          duration = segment.duration;
        } catch (e) {
          print('❌ Error accediendo a segment: $e');
          originCode = 'N/A';
          destinationCode = 'N/A';
          departureTime = '';
          duration = '';
        }
      }
      
      print('🔍 Segment $i: $originCode -> $destinationCode');
      
      // Origen del segmento
      routeWidgets.add(
        Expanded(
              child: Column(
                children: [
              Text(
                originCode,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 4),
                  Text(
                _formatTime(departureTime),
                    style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
      
      // Flecha y duración (excepto para el último segmento)
      if (i < segmentsToUse.length - 1) {
        routeWidgets.add(
          Column(
        children: [
              Text(
                _formatDuration(duration),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
          ),
          SizedBox(height: 4),
              Icon(Icons.arrow_forward, size: 16, color: Colors.grey[600]),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Parada',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
            ),
                ),
          ),
        ],
      ),
    );
      }
    }
    
    // Destino final
    final lastSegment = segmentsToUse.last;
    String finalDestination = '';
    String finalArrivalTime = '';
    
    if (lastSegment is Map<String, dynamic>) {
      final destination = lastSegment['destination'] as Map<String, dynamic>? ?? {};
      finalDestination = destination['iata_code']?.toString() ?? 'N/A';
      finalArrivalTime = lastSegment['arriving_at']?.toString() ?? '';
    } else {
      // Intentar acceder como FlightSegment
      try {
        finalDestination = lastSegment.destinationAirport.split(' - ')[0];
        finalArrivalTime = lastSegment.arrivingAt;
      } catch (e) {
        print('❌ Error accediendo a lastSegment: $e');
        finalDestination = 'N/A';
        finalArrivalTime = '';
      }
    }
    
    routeWidgets.add(
      Expanded(
        child: Column(
        children: [
            Text(
              finalDestination,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(finalArrivalTime),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
            ),
          ),
        ],
        ),
      ),
    );
    
    return Row(
      children: routeWidgets,
    );
  }

  /// 🛣️ Construir ruta simple
  Widget _buildSimpleRoute([String? origin, String? destination]) {
    final originCode = origin ?? flight.origin;
    final destinationCode = destination ?? flight.destination;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                originCode,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 4),
              Text(
                flight.formattedDepartureTime,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        Column(
        children: [
            Text(
              flight.formattedDuration,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
          Container(
              width: 60,
              height: 2,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: flight.stops == 0 ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                flight.stopsText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: flight.stops == 0 ? Colors.green[700] : Colors.orange[700],
                ),
              ),
            ),
          ],
        ),
        
          Expanded(
            child: Column(
              children: [
                Text(
                destinationCode,
                  style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              SizedBox(height: 4),
                Text(
                flight.formattedArrivalTime,
                  style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 📝 Construir fila de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
              child: Text(
              value,
                style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🛫 Construir tarjeta de segmento
  Widget _buildSegmentCard(Map<String, dynamic> segment, int segmentNumber) {
    final origin = segment['origin'] as Map<String, dynamic>? ?? {};
    final destination = segment['destination'] as Map<String, dynamic>? ?? {};
    final aircraft = segment['aircraft'] as Map<String, dynamic>? ?? {};
    final marketingCarrier = segment['marketing_carrier'] as Map<String, dynamic>? ?? {};
    
    final originCode = origin['iata_code']?.toString() ?? 'N/A';
    final destinationCode = destination['iata_code']?.toString() ?? 'N/A';
    final originName = origin['name']?.toString() ?? 'Aeropuerto Desconocido';
    final destinationName = destination['name']?.toString() ?? 'Aeropuerto Desconocido';
    final departingAt = segment['departing_at']?.toString() ?? '';
    final arrivingAt = segment['arriving_at']?.toString() ?? '';
    final duration = segment['duration']?.toString() ?? '';
    final flightNumber = segment['flight_number']?.toString() ?? '';
    final aircraftName = aircraft['name']?.toString() ?? 'Aeronave Desconocida';
    final airline = marketingCarrier['name']?.toString() ?? 'Aerolínea Desconocida';
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Segmento $segmentNumber',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      originCode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      originName,
                      style: TextStyle(fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (departingAt.isNotEmpty)
                      Text(
                        _formatTime(departingAt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              
              Column(
                children: [
                  if (duration.isNotEmpty)
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(fontSize: 10),
                    ),
                  SizedBox(height: 4),
                  Icon(Icons.arrow_forward, size: 16),
                  SizedBox(height: 4),
                  Text(
                    '$airline $flightNumber',
                    style: TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      destinationCode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      destinationName,
                      style: TextStyle(fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                    if (arrivingAt.isNotEmpty)
                      Text(
                        _formatTime(arrivingAt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
            SizedBox(height: 8),
          
            Text(
              'Aeronave: $aircraftName',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  /// ⏱️ Formatear duración
  String _formatDuration(String duration) {
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

  /// 🕐 Formatear tiempo
  String _formatTime(String time) {
    try {
      final dateTime = DateTime.parse(time);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }

  /// 💖 Agregar vuelo a favoritos
  Future<void> _addToFavorites(BuildContext context, FlightOffer flight) async {
    print('💖 Agregando a favoritos: ${flight.airline} - ${flight.flightNumberValue}');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesKey = 'favorite_flights';
      
      // Obtener favoritos existentes
      final existingFavorites = prefs.getStringList(favoritesKey) ?? [];
      
      // Crear objeto del vuelo para guardar
      final flightData = {
        'id': flight.id,
        'airline': flight.airline,
        'flightNumber': flight.flightNumberValue,
        'origin': flight.rawData['origin_airport'] ?? flight.origin,
        'destination': flight.rawData['destination_airport'] ?? flight.destination,
        'formattedPrice': flight.formattedPrice,
        'duration': flight.duration,
        'stopsText': flight.stopsText,
        'formattedDepartureTime': flight.formattedDepartureTime,
        'formattedArrivalTime': flight.formattedArrivalTime,
        'airlineCode': flight.airlineCode,
        'rawData': flight.rawData,
        'addedAt': DateTime.now().toIso8601String(),
      };
      
      // Verificar si ya existe
      final flightJson = jsonEncode(flightData);
      if (!existingFavorites.contains(flightJson)) {
        existingFavorites.add(flightJson);
        await prefs.setStringList(favoritesKey, existingFavorites);
        
        print('✅ Vuelo agregado a favoritos: ${flight.airline}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.favorite, color: Colors.white),
                SizedBox(width: 8),
                Text('Vuelo agregado a favoritos'),
              ],
            ),
            backgroundColor: Color(0xFF4CAF50), // Verde oficial Cubalink23
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        print('⚠️ Vuelo ya está en favoritos');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Este vuelo ya está en tus favoritos'),
            backgroundColor: Color(0xFFFF9800), // Naranja oficial Cubalink23
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error al agregar a favoritos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar a favoritos'),
          backgroundColor: Color(0xFFDC2626), // Rojo oficial Cubalink23
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 📤 Compartir vuelo
  Future<void> _shareFlight(FlightOffer flight) async {
    final String shareText = '''
✈️ ¡Mira este vuelo increíble!

${flight.airline} - Vuelo ${flight.flightNumberValue}
${flight.origin} → ${flight.destination}
💰 ${flight.formattedPrice}
⏰ ${flight.duration} • ${flight.stopsText}

Descarga Cubalink23 para encontrar más vuelos como este! 🚀
''';

    try {
      await Share.share(shareText);
      print('📤 Vuelo compartido: ${flight.airline}');
    } catch (e) {
      print('❌ Error al compartir: $e');
    }
  }
}