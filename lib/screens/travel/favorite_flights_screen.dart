import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/flight_offer.dart';
import 'flight_detail_favorites.dart';
// import 'flight_booking_screen.dart'; // No usado

class FavoriteFlightsScreen extends StatefulWidget {
  const FavoriteFlightsScreen({super.key});

  @override
  State<FavoriteFlightsScreen> createState() => _FavoriteFlightsScreenState();
}

class _FavoriteFlightsScreenState extends State<FavoriteFlightsScreen> {
  List<FlightOffer> _favoriteFlights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteFlights();
  }

  /// 💖 Cargar vuelos favoritos desde SharedPreferences
  Future<void> _loadFavoriteFlights() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesKey = 'favorite_flights';
      final favoritesJson = prefs.getStringList(favoritesKey) ?? [];
      
      print('🔍 Cargando favoritos: ${favoritesJson.length} vuelos');
      
      final flights = <FlightOffer>[];
      for (final flightJson in favoritesJson) {
        try {
          final flightData = jsonDecode(flightJson) as Map<String, dynamic>;
          final flight = _createFlightFromFavorites(flightData);
          flights.add(flight);
        } catch (e) {
          print('❌ Error parseando favorito: $e');
        }
      }
      
      setState(() {
        _favoriteFlights = flights;
        _isLoading = false;
      });
      
      print('✅ Favoritos cargados: ${_favoriteFlights.length} vuelos');
    } catch (e) {
      print('❌ Error cargando favoritos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 🛫 Crear FlightOffer desde datos guardados
  FlightOffer _createFlightFromFavorites(Map<String, dynamic> flightData) {
    print('🔍 DEBUG _createFlightFromFavorites:');
    print('🔍 flightData: $flightData');
    print('🔍 origin: ${flightData['origin']}');
    print('🔍 destination: ${flightData['destination']}');
    
    // Crear segmento con los datos guardados
    final segments = <FlightSegment>[];
    if (flightData['origin'] != null && flightData['destination'] != null) {
      segments.add(FlightSegment(
        id: flightData['id'] ?? '',
        departingAt: flightData['formattedDepartureTime'] ?? 'N/A',
        arrivingAt: flightData['formattedArrivalTime'] ?? 'N/A',
        originAirport: '${flightData['origin']} - ${flightData['origin']}',
        destinationAirport: '${flightData['destination']} - ${flightData['destination']}',
        airline: flightData['airline'] ?? 'N/A',
        flightNumber: flightData['flightNumber'] ?? '',
        aircraft: 'Unknown Aircraft',
        duration: flightData['duration'] ?? 'N/A',
      ));
    }
    
    return FlightOffer(
      id: flightData['id'] ?? '',
      airline: flightData['airline'] ?? 'N/A',
      flightNumber: flightData['flightNumber'] ?? '',
      totalAmount: (flightData['formattedPrice'] ?? '0').toString(),
      totalCurrency: 'USD',
      departureTime: flightData['formattedDepartureTime'] ?? 'N/A',
      arrivalTime: flightData['formattedArrivalTime'] ?? 'N/A',
      duration: flightData['duration'] ?? 'N/A',
      stops: _parseStops(flightData['stopsText'] ?? 'N/A'),
      segments: segments,
      airlineLogo: flightData['airlineCode'] ?? 'N/A',
      rawData: flightData['rawData'] ?? {},
    );
  }

  /// 🔢 Parsear número de escalas
  int _parseStops(String stopsText) {
    if (stopsText.toLowerCase().contains('directo') || stopsText.toLowerCase().contains('direct')) {
      return 0;
    } else if (stopsText.toLowerCase().contains('1 escala') || stopsText.toLowerCase().contains('1 stop')) {
      return 1;
    } else if (stopsText.toLowerCase().contains('2 escalas') || stopsText.toLowerCase().contains('2 stops')) {
      return 2;
    }
    return 0;
  }

  /// 🗑️ Eliminar vuelo de favoritos
  Future<void> _removeFavorite(FlightOffer flight) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesKey = 'favorite_flights';
      final existingFavorites = prefs.getStringList(favoritesKey) ?? [];
      
      print('🔍 DEBUG _removeFavorite:');
      print('🔍 Flight ID: ${flight.id}');
      print('🔍 Existing favorites count: ${existingFavorites.length}');
      
      // Buscar y eliminar por ID del vuelo
      final updatedFavorites = existingFavorites.where((favoriteJson) {
        try {
          final favoriteData = jsonDecode(favoriteJson) as Map<String, dynamic>;
          final favoriteId = favoriteData['id']?.toString() ?? '';
          final flightId = flight.id.toString();
          
          print('🔍 Comparing: $favoriteId vs $flightId');
          
          // Eliminar si coincide el ID
          return favoriteId != flightId;
        } catch (e) {
          print('❌ Error parsing favorite: $e');
          return true; // Mantener si hay error
        }
      }).toList();
      
      print('🔍 Updated favorites count: ${updatedFavorites.length}');
      
      await prefs.setStringList(favoritesKey, updatedFavorites);
      
      // Recargar la lista
      await _loadFavoriteFlights();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vuelo eliminado de favoritos'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      print('❌ Error eliminando favorito: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Fondo general oficial Cubalink23
      appBar: AppBar(
        title: Text('Mis Vuelos Favoritos'),
        backgroundColor: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
              ),
            )
          : _favoriteFlights.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesList(),
    );
  }

  /// 📱 Construir estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Color(0xFFFF9800), // Naranja oficial Cubalink23
            ),
            SizedBox(height: 24),
            Text(
              'No tienes vuelos favoritos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C), // Texto principal oficial Cubalink23
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Agrega vuelos a tus favoritos para verlos aquí',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666), // Texto secundario oficial Cubalink23
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/flight-search');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF9800), // Naranja oficial Cubalink23
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Buscar Vuelos',
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

  /// 📋 Construir lista de favoritos
  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _favoriteFlights.length,
      itemBuilder: (context, index) {
        final flight = _favoriteFlights[index];
        return _buildFavoriteCard(flight);
      },
    );
  }

  /// 🎴 Construir tarjeta de favorito
  Widget _buildFavoriteCard(FlightOffer flight) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FlightDetailFavorites(flight: flight),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Logo de aerolínea
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://images.kiwi.com/airlines/64/${flight.airlineCode}.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business,
                            size: 30,
                            color: Colors.grey[600],
                          );
                        },
                      ),
                    ),
                  ),
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
                            color: Color(0xFF2C2C2C), // Texto principal oficial Cubalink23
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vuelo ${flight.flightNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666), // Texto secundario oficial Cubalink23
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              flight.origin,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 16, color: Color(0xFFFF9800)),
                            SizedBox(width: 8),
                            Text(
                              flight.destination,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                          ],
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50), // Verde oficial Cubalink23
                        ),
                      ),
                      Text(
                        'por persona',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Información adicional
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Color(0xFF666666)),
                  SizedBox(width: 4),
                  Text(
                    flight.duration,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.flight, size: 16, color: Color(0xFF666666)),
                  SizedBox(width: 4),
                  Text(
                    flight.stopsText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  Spacer(),
                  // Botón eliminar
                  IconButton(
                    onPressed: () => _removeFavorite(flight),
                    icon: Icon(Icons.favorite, color: Color(0xFFFF9800)),
                    tooltip: 'Eliminar de favoritos',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
