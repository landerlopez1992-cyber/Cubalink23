import 'package:flutter/material.dart';

class FlightBooking {
  String id;
  String userId;
  String userEmail;
  String userName;
  String passengerName;
  String departure;
  String destination;
  DateTime departureDate;
  DateTime? returnDate;
  String flightNumber;
  String airline;
  double totalPrice;
  String status; // 'pending', 'confirmed', 'cancelled', 'completed', 'refunded'
  DateTime bookingDate;
  String? cancellationReason;
  String ticketNumber;
  String seatNumber;

  FlightBooking({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.passengerName,
    required this.departure,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.flightNumber,
    required this.airline,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
    this.cancellationReason,
    required this.ticketNumber,
    required this.seatNumber,
  });
}

class TravelManagementScreen extends StatefulWidget {
  const TravelManagementScreen({super.key});

  @override
  _TravelManagementScreenState createState() => _TravelManagementScreenState();
}

class _TravelManagementScreenState extends State<TravelManagementScreen> {
  List<FlightBooking> _allBookings = [];
  List<FlightBooking> _filteredBookings = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadSampleData();
    _filteredBookings = _allBookings;
  }

  void _loadSampleData() {
    // ELIMINADO: Todos los datos falsos de ejemplo removidos
    _allBookings = [];
    print('⚠️ [ADMIN] DEMO DATA ELIMINADO - Solo datos reales de Firebase');
  }

  void _filterBookings() {
    setState(() {
      _filteredBookings = _allBookings.where((booking) {
        bool matchesSearch = _searchController.text.isEmpty ||
            booking.userName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            booking.userEmail.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            booking.passengerName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            booking.flightNumber.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            booking.ticketNumber.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesStatus = _selectedStatus == 'all' || booking.status == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _changeBookingStatus(FlightBooking booking, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar Estado del Vuelo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Cambiar estado del vuelo a "${_getStatusText(newStatus)}"?'),
            SizedBox(height: 8),
            Text('Vuelo: ${booking.flightNumber}'),
            Text('Pasajero: ${booking.passengerName}'),
            Text('Ruta: ${booking.departure} → ${booking.destination}'),
            if (newStatus == 'cancelled') ...[
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Motivo de la cancelación (opcional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  booking.cancellationReason = value;
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                booking.status = newStatus;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Estado actualizado a ${_getStatusText(newStatus)}')),
              );
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _processRefund(FlightBooking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Procesar Reembolso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Procesar reembolso para este vuelo?'),
            SizedBox(height: 8),
            Text('Pasajero: ${booking.passengerName}'),
            Text('Vuelo: ${booking.flightNumber}'),
            Text('Precio: \$${booking.totalPrice.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'El monto será devuelto a la billetera del usuario.',
                style: TextStyle(color: Colors.orange[800]),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              setState(() {
                booking.status = 'refunded';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reembolso procesado exitosamente')),
              );
            },
            child: Text('Procesar Reembolso'),
          ),
        ],
      ),
    );
  }

  void _showFlightDetails(FlightBooking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles del Vuelo'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Número de Vuelo:', booking.flightNumber),
                _buildDetailRow('Aerolínea:', booking.airline),
                _buildDetailRow('Número de Ticket:', booking.ticketNumber),
                _buildDetailRow('Asiento:', booking.seatNumber),
                Divider(),
                _buildDetailRow('Pasajero:', booking.passengerName),
                _buildDetailRow('Usuario:', '${booking.userName} (${booking.userEmail})'),
                Divider(),
                _buildDetailRow('Origen:', booking.departure),
                _buildDetailRow('Destino:', booking.destination),
                _buildDetailRow('Fecha Salida:', _formatDateTime(booking.departureDate)),
                if (booking.returnDate != null)
                  _buildDetailRow('Fecha Regreso:', _formatDateTime(booking.returnDate!)),
                Divider(),
                _buildDetailRow('Precio Total:', '\$${booking.totalPrice.toStringAsFixed(2)}'),
                _buildDetailRow('Estado:', _getStatusText(booking.status)),
                _buildDetailRow('Reservado:', _formatDateTime(booking.bookingDate)),
                if (booking.cancellationReason != null)
                  _buildDetailRow('Motivo Cancelación:', booking.cancellationReason!),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'PENDIENTE';
      case 'confirmed':
        return 'CONFIRMADO';
      case 'cancelled':
        return 'CANCELADO';
      case 'completed':
        return 'COMPLETADO';
      case 'refunded':
        return 'REEMBOLSADO';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          'Gestión de Viajes',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
              child: Column(
                children: [
                  // Filtros y búsqueda
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey[600]),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Buscar por nombre, email, vuelo o ticket...',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (_) => _filterBookings(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              isExpanded: true,
                              underline: SizedBox(),
                              items: [
                                DropdownMenuItem(value: 'all', child: Text('Todos los estados')),
                                DropdownMenuItem(value: 'pending', child: Text('Pendientes')),
                                DropdownMenuItem(value: 'confirmed', child: Text('Confirmados')),
                                DropdownMenuItem(value: 'cancelled', child: Text('Cancelados')),
                                DropdownMenuItem(value: 'completed', child: Text('Completados')),
                                DropdownMenuItem(value: 'refunded', child: Text('Reembolsados')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                                _filterBookings();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // Estadísticas
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Total', style: TextStyle(fontSize: 14)),
                                Text('${_allBookings.length}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Pendientes', style: TextStyle(fontSize: 14)),
                                Text('${_allBookings.where((b) => b.status == 'pending').length}',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Confirmados', style: TextStyle(fontSize: 14)),
                                Text('${_allBookings.where((b) => b.status == 'confirmed').length}',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('Ingresos', style: TextStyle(fontSize: 14)),
                                Text('\$${_allBookings.where((b) => b.status != 'cancelled' && b.status != 'refunded').fold(0.0, (sum, b) => sum + b.totalPrice).toStringAsFixed(0)}',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // Lista de reservas
                  Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.flight, color: Theme.of(context).colorScheme.primary),
                              SizedBox(width: 12),
                              Text(
                                'Reservas de Vuelos (${_filteredBookings.length})',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        if (_filteredBookings.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No se encontraron reservas',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _filteredBookings.length,
                            separatorBuilder: (context, index) => Divider(height: 1),
                            itemBuilder: (context, index) {
                              final booking = _filteredBookings[index];
                              return Card(
                                margin: EdgeInsets.all(8),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: _getStatusColor(booking.status).withOpacity( 0.2),
                                            child: Icon(
                                              Icons.flight,
                                              color: _getStatusColor(booking.status),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${booking.flightNumber} - ${booking.airline}',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                Text('${booking.departure} → ${booking.destination}'),
                                                Text('Pasajero: ${booking.passengerName}'),
                                                Text('Usuario: ${booking.userName}'),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(booking.status),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  _getStatusText(booking.status),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '\$${booking.totalPrice.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Fecha de Salida: ${_formatDate(booking.departureDate)}'),
                                                if (booking.returnDate != null)
                                                  Text('Fecha de Regreso: ${_formatDate(booking.returnDate!)}'),
                                                Text('Reservado: ${_formatDateTime(booking.bookingDate)}'),
                                                Text('Asiento: ${booking.seatNumber}'),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              TextButton.icon(
                                                onPressed: () => _showFlightDetails(booking),
                                                icon: Icon(Icons.info_outline),
                                                label: Text('Detalles'),
                                              ),
                                              if (booking.status == 'pending') ...[
                                                SizedBox(width: 8),
                                                ElevatedButton.icon(
                                                  onPressed: () => _changeBookingStatus(booking, 'confirmed'),
                                                  icon: Icon(Icons.check),
                                                  label: Text('Confirmar'),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                                ),
                                                SizedBox(width: 8),
                                                ElevatedButton.icon(
                                                  onPressed: () => _changeBookingStatus(booking, 'cancelled'),
                                                  icon: Icon(Icons.close),
                                                  label: Text('Cancelar'),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                ),
                                              ],
                                              if (booking.status == 'confirmed') ...[
                                                SizedBox(width: 8),
                                                ElevatedButton.icon(
                                                  onPressed: () => _changeBookingStatus(booking, 'completed'),
                                                  icon: Icon(Icons.flight_takeoff),
                                                  label: Text('Completar'),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                                ),
                                              ],
                                              if (booking.status == 'cancelled' || booking.status == 'completed') ...[
                                                SizedBox(width: 8),
                                                ElevatedButton.icon(
                                                  onPressed: () => _processRefund(booking),
                                                  icon: Icon(Icons.money_off),
                                                  label: Text('Reembolsar'),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}