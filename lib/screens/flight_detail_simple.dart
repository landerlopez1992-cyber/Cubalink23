import 'package:flutter/material.dart';
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
    final slices = rawDuffelData['slices'] as List<dynamic>? ?? [];
    final conditions = rawDuffelData['conditions'] as Map<String, dynamic>? ?? {};
    
    // Extraer políticas
    final changeBeforeDeparture = conditions['change_before_departure'] as Map<String, dynamic>? ?? {};
    final refundBeforeDeparture = conditions['refund_before_departure'] as Map<String, dynamic>? ?? {};
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Vuelo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
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
                        // Logo de aerolínea real - MÁS GRANDE Y VISIBLE
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildAirlineLogo(),
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
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Vuelo ${flight.flightNumber}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
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
                    
                    // RUTA DEL VUELO
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  flight.origin,
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
                                  flight.destination,
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
                      ),
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
                    _buildInfoRow('Número de Vuelo:', flight.flightNumber),
                    _buildInfoRow('Origen:', flight.origin),
                    _buildInfoRow('Destino:', flight.destination),
                    _buildInfoRow('Duración:', flight.formattedDuration),
                    _buildInfoRow('Escalas:', flight.stopsText),
                    _buildInfoRow('Precio:', flight.formattedPrice),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // 📋 POLÍTICAS DE VUELO
            if (conditions.isNotEmpty)
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.policy_outlined, color: Colors.blue[600], size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Políticas del Vuelo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Política de cambios
                      if (changeBeforeDeparture.isNotEmpty) ...[
                        _buildPolicyRow(
                          icon: Icons.swap_horiz,
                          title: 'Cambios antes de la salida',
                          allowed: changeBeforeDeparture['allowed'] == true,
                          penalty: changeBeforeDeparture['penalty_amount']?.toString(),
                          currency: changeBeforeDeparture['penalty_currency']?.toString(),
                        ),
                        SizedBox(height: 12),
                      ],
                      
                      // Política de reembolsos
                      if (refundBeforeDeparture.isNotEmpty)
                        _buildPolicyRow(
                          icon: Icons.money_off,
                          title: 'Reembolso antes de la salida',
                          allowed: refundBeforeDeparture['allowed'] == true,
                          penalty: refundBeforeDeparture['penalty_amount']?.toString(),
                          currency: refundBeforeDeparture['penalty_currency']?.toString(),
                        ),
                    ],
                  ),
                ),
              ),
            
            SizedBox(height: 16),
            
            // 🎒 INFORMACIÓN DE EQUIPAJE
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
                          Icon(Icons.luggage, color: Colors.blue[600], size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Equipaje Incluido',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Extraer info de equipaje del primer slice
                      ...slices.map((slice) {
                        final segments = slice['segments'] as List<dynamic>? ?? [];
                        if (segments.isNotEmpty) {
                          final firstSegment = segments[0] as Map<String, dynamic>;
                          final passengers = firstSegment['passengers'] as List<dynamic>? ?? [];
                          
                          if (passengers.isNotEmpty) {
                            final passenger = passengers[0] as Map<String, dynamic>;
                            final baggages = passenger['baggages'] as List<dynamic>? ?? [];
                            
                            return Column(
                              children: baggages.map<Widget>((baggage) {
                                final bag = baggage as Map<String, dynamic>;
                                final type = bag['type']?.toString() ?? '';
                                final quantity = bag['quantity']?.toString() ?? '0';
                                
                                return _buildBaggageItem(
                                  icon: type == 'carry_on' ? Icons.luggage : Icons.airport_shuttle,
                                  title: type == 'carry_on' ? 'Equipaje de Mano' : 'Equipaje Facturado',
                                  description: '$quantity pieza(s) incluida(s)',
                                  included: true,
                                );
                              }).toList(),
                            );
                          }
                        }
                        return SizedBox.shrink();
                      }),
                      
                      // Si no hay datos de equipaje, mostrar valores por defecto
                      if (slices.isEmpty || _getBaggageCount(slices) == 0) ...[
                        _buildBaggageItem(
                          icon: Icons.luggage,
                          title: 'Equipaje de Mano',
                          description: '1 pieza hasta 8kg',
                          included: true,
                        ),
                        SizedBox(height: 12),
                        _buildBaggageItem(
                          icon: Icons.airport_shuttle,
                          title: 'Equipaje Facturado',
                          description: 'Consultar con aerolínea',
                          included: false,
                        ),
                      ],
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
                      onPressed: () {
                        print('🔍 DEBUG: Compartir vuelo');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Función de compartir en desarrollo'),
                            backgroundColor: Colors.blue[600],
                          ),
                        );
                      },
                      icon: Icon(Icons.share, size: 18),
                      label: Text('Compartir'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue[600]!),
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
                    onPressed: () {
                      print('🔍 DEBUG: Agregar a favoritos');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Agregado a favoritos'),
                          backgroundColor: Colors.orange[600],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.orange[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Icon(Icons.favorite_border, color: Colors.orange[600]),
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
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Reservar Vuelo - ${flight.formattedPrice}',
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
    // Generar múltiples URLs de logo
    final airlineCode = flight.airlineCode;
    final logoUrls = <String>[];
    
    if (airlineCode.isNotEmpty && airlineCode != 'N/A') {
      // Fuente 1: Daisycon
      logoUrls.add('https://daisycon.io/images/airline/?width=120&height=120&color=ffffff&iata=$airlineCode');
      // Fuente 2: Avionero
      logoUrls.add('https://avionero.com/airline-logos/$airlineCode.png');
      // Fuente 3: Airline Logos
      logoUrls.add('https://logos.skyscnr.com/images/airlines/favicon/$airlineCode.png');
      // Fuente 4: Alternative
      logoUrls.add('https://images.kiwi.com/airlines/64/$airlineCode.png');
    }
    
    print('🔍 DEBUG: Intentando cargar logos para código: $airlineCode');
    print('🔍 DEBUG: URLs generadas: $logoUrls');
    
    // Si hay URLs disponibles, intentar cargarlas
    if (logoUrls.isNotEmpty) {
      return _buildLogoWithFallback(logoUrls);
    }
    
    // Fallback final: ícono genérico más grande
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 32,
            color: Colors.blue[600],
          ),
          SizedBox(height: 4),
          Text(
            flight.airline.length > 8 
                ? '${flight.airline.substring(0, 8)}...' 
                : flight.airline,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 🔄 Construir logo con fallback a múltiples URLs
  Widget _buildLogoWithFallback(List<String> urls) {
    if (urls.isEmpty) {
      return _buildFallbackIcon();
    }
    
    final currentUrl = urls.first;
    final remainingUrls = urls.skip(1).toList();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        currentUrl,
        width: 80,
        height: 80,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error cargando logo desde: $currentUrl');
          print('❌ Error: $error');
          
          // Si hay más URLs, intentar la siguiente
          if (remainingUrls.isNotEmpty) {
            print('🔄 Intentando siguiente URL...');
            return _buildLogoWithFallback(remainingUrls);
          }
          
          // Si no hay más URLs, usar fallback
          return _buildFallbackIcon();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cargando...',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🎯 Ícono de fallback mejorado
  Widget _buildFallbackIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 32,
            color: Colors.blue[600],
          ),
          SizedBox(height: 4),
          Text(
            flight.airline.length > 8 
                ? '${flight.airline.substring(0, 8)}...' 
                : flight.airline,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow({
    required IconData icon,
    required String title,
    required bool allowed,
    String? penalty,
    String? currency,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: allowed ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: allowed ? Colors.green[600] : Colors.red[600],
            size: 16,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                allowed 
                  ? (penalty != null && penalty != '0' ? 'Permitido con cargo de $penalty $currency' : 'Permitido sin cargo')
                  : 'No permitido',
                style: TextStyle(
                  fontSize: 11,
                  color: allowed ? Colors.green[600] : Colors.red[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBaggageItem({
    required IconData icon,
    required String title,
    required String description,
    required bool included,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: included ? Colors.green[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: included ? Colors.green[600] : Colors.grey[400],
              size: 16,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (included)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Incluido',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

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
          
          if (aircraftName != 'Aeronave Desconocida') ...[
            SizedBox(height: 8),
            Text(
              'Aeronave: $aircraftName',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _getBaggageCount(List<dynamic> slices) {
    int count = 0;
    for (var slice in slices) {
      final segments = slice['segments'] as List<dynamic>? ?? [];
      for (var segment in segments) {
        final passengers = segment['passengers'] as List<dynamic>? ?? [];
        for (var passenger in passengers) {
          final baggages = passenger['baggages'] as List<dynamic>? ?? [];
          count += baggages.length;
        }
      }
    }
    return count;
  }

  String _formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoTime;
    }
  }

  String _formatDuration(String duration) {
    // Convertir duración PT1H18M a 1h 18m
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?');
    final match = regex.firstMatch(duration);
    if (match != null) {
      final hours = match.group(1);
      final minutes = match.group(2);
      String result = '';
      if (hours != null) result += '${hours}h ';
      if (minutes != null) result += '${minutes}m';
      return result.trim();
    }
    return duration;
  }
}
