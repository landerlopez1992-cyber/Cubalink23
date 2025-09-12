import 'package:flutter/material.dart';
import '../../models/flight_offer.dart';

class FlightDetailFinal extends StatelessWidget {
  final FlightOffer flight;

  const FlightDetailFinal({
    super.key,
    required this.flight,
  });

  @override
  Widget build(BuildContext context) {
    print('🔍 DEBUG: FlightDetailFinal iniciada');
    print('🔍 DEBUG: Flight ID: ${flight.id}');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Vuelo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // TARJETA PRINCIPAL
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Aerolínea y precio
                        Row(
                          children: [
                            Icon(Icons.flight, size: 40, color: Colors.blue),
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
                                    ),
                                  ),
                                  Text('Vuelo ${flight.flightNumber}'),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  flight.formattedPrice,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text('por persona'),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        
                        // Ruta
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    flight.origin,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(flight.formattedDepartureTime),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(flight.formattedDuration),
                                Icon(Icons.arrow_forward),
                                Text(flight.stopsText),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    flight.destination,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(flight.formattedArrivalTime),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // INFORMACIÓN DETALLADA
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Vuelo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        _buildInfoRow('ID de la Oferta:', flight.id),
                        _buildInfoRow('Aerolínea:', flight.airline),
                        _buildInfoRow('Código IATA:', flight.airlineCode),
                        _buildInfoRow('Número de Vuelo:', flight.flightNumber),
                        _buildInfoRow('Origen:', flight.origin),
                        _buildInfoRow('Destino:', flight.destination),
                        _buildInfoRow('Duración:', flight.formattedDuration),
                        _buildInfoRow('Escalas:', flight.stopsText),
                        _buildInfoRow('Precio:', flight.formattedPrice),
                        _buildInfoRow('Moneda:', flight.totalCurrency),
                        _buildInfoRow('Reembolsable:', flight.refundable ? 'Sí' : 'No'),
                        _buildInfoRow('Modificable:', flight.changeable ? 'Sí' : 'No'),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // SEGMENTOS (SEGÚN DUFFEL)
                if (flight.segments.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Segmentos del Vuelo (Slices)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          ...flight.segments.asMap().entries.map((entry) {
                            final index = entry.key;
                            final segment = entry.value;
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Segmento ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text('Origen: ${segment.originAirport}'),
                                  Text('Destino: ${segment.destinationAirport}'),
                                  Text('Salida: ${segment.departingAt}'),
                                  Text('Llegada: ${segment.arrivingAt}'),
                                  Text('Aerolínea: ${segment.airline}'),
                                  Text('Vuelo: ${segment.flightNumber}'),
                                  Text('Aeronave: ${segment.aircraft}'),
                                  Text('Duración: ${segment.duration}'),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                
                // DATOS RAW PARA DEBUG
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Datos Raw de Duffel (Debug)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              flight.rawData.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // BOTÓN DE RESERVA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print('🔍 DEBUG: Botón presionado');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Funcionalidad de reserva próximamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: EdgeInsets.all(16),
                    ),
                    child: Text(
                      'Reservar Vuelo - ${flight.formattedPrice}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


