import 'package:flutter/material.dart';
import '../../models/flight_offer.dart';

class SimpleDetail extends StatelessWidget {
  final FlightOffer flight;

  const SimpleDetail({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    print('🔍 DEBUG: SimpleDetail construida');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Vuelo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aerolínea: ${flight.airline}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Precio: ${flight.formattedPrice}'),
            SizedBox(height: 8),
            Text('Origen: ${flight.origin}'),
            SizedBox(height: 8),
            Text('Destino: ${flight.destination}'),
            SizedBox(height: 8),
            Text('Salida: ${flight.formattedDepartureTime}'),
            SizedBox(height: 8),
            Text('Llegada: ${flight.formattedArrivalTime}'),
            SizedBox(height: 8),
            Text('Duración: ${flight.formattedDuration}'),
            SizedBox(height: 8),
            Text('Escalas: ${flight.stopsText}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reserva en desarrollo')),
                );
              },
              child: Text('Reservar'),
            ),
          ],
        ),
      ),
    );
  }
}


