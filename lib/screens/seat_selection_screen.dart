import 'package:flutter/material.dart';
import '../../models/flight_offer.dart';
import '../../services/duffel_api_service.dart';

class SeatSelectionScreen extends StatefulWidget {
  final FlightOffer flight;
  final Map<String, dynamic> passengerData;

  const SeatSelectionScreen({
    super.key,
    required this.flight,
    required this.passengerData,
  });

  @override
  _SeatSelectionScreenState createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  bool _isLoading = true;
  List<dynamic> _seatMaps = [];
  String? _selectedSeat;
  double _seatPrice = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAvailableSeats();
  }

  Future<void> _loadAvailableSeats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('💺 Cargando asientos para oferta: ${widget.flight.id}');
      
      final result = await DuffelApiService.getAvailableSeats(
        offerId: widget.flight.id,
      );

      if (result != null && result['success'] == true) {
        setState(() {
          _seatMaps = result['seat_maps'] ?? [];
          _isLoading = false;
        });
        print('✅ Asientos cargados: ${_seatMaps.length} seat maps');
      } else {
        setState(() {
          _errorMessage = result?['message'] ?? 'Error cargando asientos';
          _isLoading = false;
        });
        print('❌ Error cargando asientos: $_errorMessage');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _isLoading = false;
      });
      print('❌ Excepción cargando asientos: $e');
    }
  }

  void _selectSeat(String seatNumber, double price) {
    setState(() {
      if (_selectedSeat == seatNumber) {
        // Deseleccionar si ya está seleccionado
        _selectedSeat = null;
        _seatPrice = 0.0;
      } else {
        // Seleccionar nuevo asiento
        _selectedSeat = seatNumber;
        _seatPrice = price;
      }
    });
    print('💺 Asiento seleccionado: $_selectedSeat (Precio: \$_seatPrice)');
  }

  Color _getSeatColor(Map<String, dynamic> seat) {
    final seatNumber = seat['seat_number'] ?? '';
    final available = seat['available'] ?? false;
    final type = seat['type'] ?? '';

    if (!available) {
      return Colors.grey[400]!; // Ocupado
    }

    if (_selectedSeat == seatNumber) {
      return Colors.blue[600]!; // Seleccionado
    }

    switch (type) {
      case 'window':
        return Colors.green[300]!; // Ventana
      case 'aisle':
        return Colors.orange[300]!; // Pasillo
      case 'middle':
        return Colors.grey[200]!; // Medio
      default:
        return Colors.grey[200]!;
    }
  }

  IconData _getSeatIcon(Map<String, dynamic> seat) {
    final available = seat['available'] ?? false;
    final type = seat['type'] ?? '';

    if (!available) {
      return Icons.airline_seat_recline_normal; // Ocupado
    }

    switch (type) {
      case 'window':
        return Icons.airline_seat_legroom_reduced; // Ventana
      case 'aisle':
        return Icons.airline_seat_legroom_extra; // Pasillo
      case 'middle':
        return Icons.airline_seat_recline_normal; // Medio
      default:
        return Icons.airline_seat_recline_normal;
    }
  }

  void _confirmSeatSelection() {
    if (_selectedSeat != null) {
      Navigator.pop(context, {
        'selected_seat': _selectedSeat,
        'seat_price': _seatPrice,
      });
    } else {
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Asiento'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (_selectedSeat != null)
            TextButton(
              onPressed: _confirmSeatSelection,
              child: Text(
                'Confirmar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando asientos disponibles...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error cargando asientos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(_errorMessage!),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAvailableSeats,
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header con información del vuelo
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.blue[50],
                      child: Row(
                        children: [
                          Icon(Icons.flight, color: Colors.blue[600]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.flight.origin} → ${widget.flight.destination}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${widget.flight.airline} ${widget.flight.flightNumber}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedSeat != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_selectedSeat (\$${_seatPrice.toStringAsFixed(0)})',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Leyenda
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem(
                            Colors.green[300]!,
                            Icons.airline_seat_legroom_reduced,
                            'Ventana',
                          ),
                          _buildLegendItem(
                            Colors.orange[300]!,
                            Icons.airline_seat_legroom_extra,
                            'Pasillo',
                          ),
                          _buildLegendItem(
                            Colors.grey[200]!,
                            Icons.airline_seat_recline_normal,
                            'Medio',
                          ),
                          _buildLegendItem(
                            Colors.grey[400]!,
                            Icons.airline_seat_recline_normal,
                            'Ocupado',
                          ),
                        ],
                      ),
                    ),

                    // Mapa de asientos
                    Expanded(
                      child: _seatMaps.isEmpty
                          ? Center(
                              child: Text('No hay asientos disponibles'),
                            )
                          : SingleChildScrollView(
                              padding: EdgeInsets.all(16),
                              child: _buildSeatMap(),
                            ),
                    ),

                    // Footer con botones
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context, null),
                              child: Text('Sin Asiento'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _selectedSeat != null
                                  ? _confirmSeatSelection
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                _selectedSeat != null
                                    ? 'Confirmar Asiento'
                                    : 'Seleccionar Asiento',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildLegendItem(Color color, IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSeatMap() {
    if (_seatMaps.isEmpty) return SizedBox.shrink();

    final seatMap = _seatMaps[0]; // Usar el primer seat map
    final rows = seatMap['rows'] ?? [];

    return Column(
      children: [
        // Indicador de frente del avión
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12),
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flight_takeoff, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Frente del Avión',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Filas de asientos
        ...rows.map<Widget>((row) => _buildSeatRow(row)).toList(),
      ],
    );
  }

  Widget _buildSeatRow(Map<String, dynamic> row) {
    final rowNumber = row['row_number'] ?? '';
    final seats = row['seats'] ?? [];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Número de fila
          SizedBox(
            width: 30,
            child: Text(
              rowNumber,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 8),

          // Asientos
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: seats.map<Widget>((seat) => _buildSeat(seat)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(Map<String, dynamic> seat) {
    final seatNumber = seat['seat_number'] ?? '';
    final available = seat['available'] ?? false;
    final price = double.tryParse(seat['price']?.toString() ?? '0') ?? 0.0;

    return GestureDetector(
      onTap: available ? () => _selectSeat(seatNumber, price) : null,
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: _getSeatColor(seat),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedSeat == seatNumber
                ? Colors.blue[800]!
                : Colors.grey[300]!,
            width: _selectedSeat == seatNumber ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getSeatIcon(seat),
              size: 16,
              color: available
                  ? (_selectedSeat == seatNumber ? Colors.white : Colors.grey[700])
                  : Colors.grey[500],
            ),
            if (price > 0)
              Text(
                '\$${price.toInt()}',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: available
                      ? (_selectedSeat == seatNumber ? Colors.white : Colors.grey[700])
                      : Colors.grey[500],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
