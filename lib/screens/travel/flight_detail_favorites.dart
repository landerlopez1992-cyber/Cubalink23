import 'package:flutter/material.dart';
import 'package:cubalink23/models/flight_offer.dart';

class FlightDetailFavorites extends StatefulWidget {
  final FlightOffer flight;

  const FlightDetailFavorites({
    Key? key,
    required this.flight,
  }) : super(key: key);

  @override
  State<FlightDetailFavorites> createState() => _FlightDetailFavoritesState();
}

class _FlightDetailFavoritesState extends State<FlightDetailFavorites> {
  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Detalles del Vuelo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF37474F),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal del vuelo
            Card(
              color: Color(0xFFFFFFFF),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con logo y aerolínea
                    Row(
                      children: [
                        // Logo de aerolínea
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100],
                          ),
                          child: _buildAirlineLogo(flight),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flight.airline,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Vuelo ${flight.flightNumberValue}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    
                    // Ruta del vuelo
                    _buildRouteDisplay(flight),
                    SizedBox(height: 20),
                    
                    // Información del vuelo
                    _buildFlightInfo(flight),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Botón de acción
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _searchSimilarFlights(context, flight),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Buscar Vuelos Similares',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🏢 Logo de aerolínea
  Widget _buildAirlineLogo(FlightOffer flight) {
    final airlineCode = flight.airlineCode;
    
    if (airlineCode != 'N/A' && airlineCode.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          'https://images.kiwi.com/airlines/64/$airlineCode.png',
          width: 60,
          height: 60,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF37474F)),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error cargando logo: $error');
            return Icon(
              Icons.business,
              size: 30,
              color: Color(0xFF37474F),
            );
          },
        ),
      );
    }
    
    return Icon(
      Icons.business,
      size: 30,
      color: Color(0xFF37474F),
    );
  }

  /// 🛣️ Mostrar ruta completa del vuelo
  Widget _buildRouteDisplay(FlightOffer flight) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Text(
            'Ruta del Vuelo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          SizedBox(height: 12),
          Text(
            '${flight.origin} → ${flight.destination}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF37474F),
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Información del vuelo
  Widget _buildFlightInfo(FlightOffer flight) {
    return Column(
      children: [
        _buildInfoRow('Duración:', _formatDuration(flight.duration)),
        _buildInfoRow('Escalas:', _formatStops(flight.stops)),
        _buildInfoRow('Aerolínea:', flight.airline),
        _buildInfoRow('Número de Vuelo:', flight.flightNumberValue),
      ],
    );
  }

  /// 📝 Fila de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2C2C2C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ⏰ Formatear duración
  String _formatDuration(String duration) {
    if (duration == 'N/A' || duration.isEmpty) return 'No disponible';
    
    // Convertir formato ISO 8601 (PT1h18M) a formato legible
    if (duration.startsWith('PT')) {
      final regex = RegExp(r'PT(?:(\d+)h)?(?:(\d+)M)?');
      final match = regex.firstMatch(duration);
      
      if (match != null) {
        final hours = match.group(1);
        final minutes = match.group(2);
        
        if (hours != null && minutes != null) {
          return '${hours}h ${minutes}min';
        } else if (hours != null) {
          return '${hours}h';
        } else if (minutes != null) {
          return '${minutes}min';
        }
      }
    }
    
    return duration;
  }

  /// 🛬 Formatear escalas
  String _formatStops(int stops) {
    if (stops == 0) return 'Vuelo directo';
    if (stops == 1) return '1 escala';
    return '$stops escalas';
  }

  /// 🔍 Buscar vuelos similares
  void _searchSimilarFlights(BuildContext context, FlightOffer flight) {
    // Usar los datos reales guardados en lugar de los getters que pueden devolver N/A
    final origin = flight.rawData['origin_airport'] ?? flight.origin;
    final destination = flight.rawData['destination_airport'] ?? flight.destination;
    
    print('🔍 DEBUG _searchSimilarFlights:');
    print('🔍 Origin: $origin');
    print('🔍 Destination: $destination');
    print('🔍 RawData: ${flight.rawData}');
    
    Navigator.pushNamed(
      context,
      '/flight-search',
      arguments: {
        'origin': origin,
        'destination': destination,
        'airline': flight.airline,
      },
    );
  }
}
