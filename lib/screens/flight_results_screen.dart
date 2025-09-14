import 'package:flutter/material.dart';
import '../../models/flight_offer.dart';
import 'flight_detail_simple.dart';

class FlightResultsScreen extends StatefulWidget {
  final List<FlightOffer> flightOffers;
  final String fromAirport;
  final String toAirport;
  final String departureDate;
  final String? returnDate;
  final int passengers;
  final String airlineType;

  const FlightResultsScreen({
    super.key,
    required this.flightOffers,
    required this.fromAirport,
    required this.toAirport,
    required this.departureDate,
    this.returnDate,
    required this.passengers,
    required this.airlineType,
  });

  @override
  _FlightResultsScreenState createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  String _sortBy = 'price'; // 'price', 'duration', 'departure'
  
  @override
  Widget build(BuildContext context) {
    // Ordenar vuelos según criterio seleccionado
    List<FlightOffer> sortedFlights = List.from(widget.flightOffers);
    
    switch (_sortBy) {
      case 'price':
        sortedFlights.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'duration':
        sortedFlights.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case 'departure':
        sortedFlights.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${widget.fromAirport} → ${widget.toAirport}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Column(
        children: [
          // 📊 Header con información de búsqueda
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      widget.airlineType == 'comerciales' 
                          ? Icons.business 
                          : Icons.flight_takeoff,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.airlineType == 'comerciales' 
                          ? 'Aerolíneas Comerciales' 
                          : 'Vuelos Charter',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '${widget.passengers} pasajero${widget.passengers > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                    SizedBox(width: 6),
                    Text(
                      widget.departureDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (widget.returnDate != null) ...[
                      SizedBox(width: 12),
                      Icon(Icons.keyboard_return, size: 16, color: Colors.grey[500]),
                      SizedBox(width: 6),
                      Text(
                        widget.returnDate!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // 🔽 Filtros y ordenamiento
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  '${sortedFlights.length} vuelos encontrados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      isDense: true,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      items: [
                        DropdownMenuItem(value: 'price', child: Text('Precio')),
                        DropdownMenuItem(value: 'duration', child: Text('Duración')),
                        DropdownMenuItem(value: 'departure', child: Text('Salida')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 1, color: Colors.grey[200]),
          
          // ✈️ Lista de vuelos
          Expanded(
            child: sortedFlights.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: sortedFlights.length,
                    itemBuilder: (context, index) {
                      if (index >= sortedFlights.length) return SizedBox.shrink();
                      return _buildFlightCard(sortedFlights[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 🔳 Estado vacío cuando no hay vuelos
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No se encontraron vuelos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.airlineType == 'comerciales'
                ? 'Intenta cambiar las fechas o buscar vuelos charter'
                : 'Intenta cambiar las fechas o buscar aerolíneas comerciales',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Buscar de nuevo'),
          ),
        ],
      ),
    );
  }

  /// ✈️ Card individual de vuelo
  Widget _buildFlightCard(FlightOffer flight) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onFlightSelected(flight),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Header con aerolínea y precio
                Row(
                  children: [
                    // Logo de aerolínea
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: flight.airlineLogo.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                flight.airlineLogo,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    flight.airlineCode == 'charter'
                                        ? Icons.flight_takeoff
                                        : Icons.flight,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Icon(
                              flight.airlineCode == 'charter'
                                  ? Icons.flight_takeoff
                                  : Icons.flight,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.airline,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          if (flight.flightNumber.isNotEmpty)
                            Text(
                              flight.flightNumber,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${flight.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          flight.currency,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Información del vuelo
                Row(
                  children: [
                    // Salida
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTime(flight.departureTime),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            flight.origin,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Duración y línea
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatDuration(flight.duration),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ],
                          ),
                          if (flight.stops > 0)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                '${flight.stops} parada${flight.stops > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Llegada
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(flight.arrivalTime),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            flight.destination,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Badges de información
                Row(
                  children: [
                    if (flight.refundable)
                      _buildBadge('Reembolsable', Colors.green),
                    if (flight.changeable)
                      _buildBadge('Modificable', Colors.blue),
                    Spacer(),
                    Text(
                      '${flight.availableSeats} asientos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🏷️ Badge de información
  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 🕐 Formatear hora
  String _formatTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  /// ⏱️ Formatear duración
  String _formatDuration(String duration) {
    try {
      // Formato ISO 8601 duration como PT2H30M
      final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?');
      final match = regex.firstMatch(duration);
      if (match != null) {
        final hours = match.group(1) != null ? int.parse(match.group(1)!) : 0;
        final minutes = match.group(2) != null ? int.parse(match.group(2)!) : 0;
        
        if (hours > 0 && minutes > 0) {
          return '${hours}h ${minutes}m';
        } else if (hours > 0) {
          return '${hours}h';
        } else {
          return '${minutes}m';
        }
      }
    } catch (e) {
      // Fallback para otros formatos
    }
    return duration;
  }

  /// ✈️ Acción al seleccionar vuelo
  void _onFlightSelected(FlightOffer flight) {
    print('🔍 DEBUG: Vuelo seleccionado: ${flight.airline} - ${flight.formattedPrice}');
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlightDetailSimple(
          flight: flight,
        ),
      ),
    );
  }
}
