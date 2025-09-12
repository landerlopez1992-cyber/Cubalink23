import 'package:flutter/material.dart';
import '../../models/flight_offer.dart';

class FlightDetailsWorking extends StatelessWidget {
  final FlightOffer flight;
  final String origin;
  final String destination;
  final String departureDate;
  final String? returnDate;
  final int passengers;
  final String airlineType;

  const FlightDetailsWorking({
    super.key,
    required this.flight,
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.passengers,
    required this.airlineType,
  });

  @override
  Widget build(BuildContext context) {
    print('🔍 DEBUG: FlightDetailsWorking construida exitosamente');
    print('🔍 DEBUG: Vuelo: ${flight.airline} - ${flight.formattedPrice}');
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Detalles del Vuelo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🎫 HEADER DEL VUELO
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Aerolínea y precio
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.flight,
                          size: 30,
                          color: Colors.blue[600],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flight.airline,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Vuelo ${flight.flightNumber}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            flight.formattedPrice,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                          Text(
                            'por persona',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // Ruta del vuelo
                  Row(
                    children: [
                      // Origen
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              flight.origin,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              flight.formattedDepartureTime,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Línea y duración
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              flight.formattedDuration,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 2,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: flight.stops == 0 ? Colors.green[100] : Colors.orange[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                flight.stopsText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: flight.stops == 0 ? Colors.green[700] : Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Destino
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              flight.destination,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              flight.formattedArrivalTime,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 12),
            
            // 💰 INFORMACIÓN DE PRECIO
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desglose de Precios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Precio por persona:'),
                      Text(
                        flight.formattedPrice,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Número de pasajeros:'),
                      Text(
                        '$passengers',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  
                  Divider(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${flight.totalCurrency} ${(flight.price * passengers).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 12),
            
            // ✈️ DETALLES DEL VUELO SEGÚN DUFFEL
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles del Vuelo (Duffel API)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  _buildDetailRow('ID de la Oferta:', flight.id),
                  _buildDetailRow('Aerolínea:', flight.airline),
                  _buildDetailRow('Código IATA:', flight.airlineCode),
                  _buildDetailRow('Número de Vuelo:', flight.flightNumber),
                  _buildDetailRow('Origen:', '${flight.origin} ($origin)'),
                  _buildDetailRow('Destino:', '${flight.destination} ($destination)'),
                  _buildDetailRow('Duración Total:', flight.formattedDuration),
                  _buildDetailRow('Escalas:', flight.stopsText),
                  _buildDetailRow('Moneda:', flight.totalCurrency),
                  _buildDetailRow('Reembolsable:', flight.refundable ? 'Sí' : 'No'),
                  _buildDetailRow('Modificable:', flight.changeable ? 'Sí' : 'No'),
                  _buildDetailRow('Asientos Disponibles:', '${flight.availableSeats}'),
                ],
              ),
            ),
            
            SizedBox(height: 12),
            
            // 📋 SEGMENTOS DEL VUELO (SEGÚN DUFFEL)
            if (flight.segments.isNotEmpty) ...[
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Segmentos del Vuelo (Slices & Segments)',
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
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Segmento ${index + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                            SizedBox(height: 12),
                            
                            _buildDetailRow('Aeropuerto de Origen:', segment.originAirport),
                            _buildDetailRow('Aeropuerto de Destino:', segment.destinationAirport),
                            _buildDetailRow('Salida:', _formatTime(segment.departingAt)),
                            _buildDetailRow('Llegada:', _formatTime(segment.arrivingAt)),
                            _buildDetailRow('Aerolínea:', segment.airline),
                            _buildDetailRow('Número de Vuelo:', segment.flightNumber),
                            _buildDetailRow('Aeronave:', segment.aircraft),
                            _buildDetailRow('Duración:', segment.duration),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 12),
            ],
            
            // 🎒 EQUIPAJE (SEGÚN DUFFEL)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipaje Incluido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Según Duffel, el equipaje viene en los segments
                  _buildBaggageItem(
                    icon: Icons.luggage,
                    title: 'Equipaje de Mano',
                    description: 'Incluido según política de aerolínea',
                    included: true,
                  ),
                  SizedBox(height: 12),
                  
                  _buildBaggageItem(
                    icon: Icons.airport_shuttle,
                    title: 'Equipaje Facturado',
                    description: 'Verificar con aerolínea',
                    included: false,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 12),
            
            // 📊 DATOS RAW DE DUFFEL (PARA DEBUGGING)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datos Raw de Duffel API (Debug)',
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
                    child: Text(
                      flight.rawData.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // 🛒 BOTÓN DE RESERVA
            Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    print('🔍 DEBUG: Botón de reserva presionado');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Funcionalidad de reserva en desarrollo'),
                        backgroundColor: Colors.orange[600],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Reservar Vuelo - ${flight.totalCurrency} ${(flight.price * passengers).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaggageItem({
    required IconData icon,
    required String title,
    required String description,
    required bool included,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: included ? Colors.green[100] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: included ? Colors.green[600] : Colors.grey[400],
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (included)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Incluido',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(String timeString) {
    try {
      if (timeString.isEmpty) return 'N/A';
      final dateTime = DateTime.parse(timeString);
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString;
    }
  }
}


