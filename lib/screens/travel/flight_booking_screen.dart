import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cubalink23/services/duffel_api_service.dart';
import 'package:cubalink23/models/flight_offer.dart';
// import 'package:cubalink23/widgets/cubalink_loading_spinner.dart'; // Archivo eliminado
import 'passenger_info_screen.dart';
import 'flight_results_screen.dart';

class FlightBookingScreen extends StatefulWidget {
  const FlightBookingScreen({super.key});

  @override
  _FlightBookingScreenState createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para los campos de texto
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController(text: '1');
  
  // Variables para fechas y selecciones
  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _isRoundTrip = false;
  String _selectedClass = 'Económica';
  final List<String> _flightClasses = ['Económica', 'Premium Económica', 'Business', 'Primera Clase'];
  
  // Variables para selector de pasajeros
  int _adults = 1;        // 18-64 años
  int _seniors = 0;       // 65+ años
  int _children = 0;      // 3-17 años
  int _infants = 0;       // 0-2 años
  bool _showPassengerSelector = false;
  
  // Variables para resultados de búsqueda de vuelos
  List<FlightOffer> _flightOffers = [];
  bool _isLoadingFlights = false;
  String? _errorMessage;
  
  // REMOVIDO: Sugerencias locales. Solo se mostrarán resultados reales de Duffel
  
  List<Map<String, dynamic>> _fromSearchResults = [];
  List<Map<String, dynamic>> _toSearchResults = [];
  bool _isSearchingFrom = false;
  bool _isSearchingTo = false;
  bool _showFromDropdown = false;
  bool _showToDropdown = false;
  
  // Timers para debounce
  Timer? _fromSearchTimer;
  Timer? _toSearchTimer;

  @override
  void dispose() {
    _fromSearchTimer?.cancel();
    _toSearchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco puro como en los diseños modernos
      body: Stack(
        children: [
          CustomScrollView(
        slivers: [
          // Header optimizado para Motorola Edge 2024
          SliverAppBar(
            expandedHeight: 100.0, // Reducido de 120 a 100
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFF37474F), // Header oficial Cubalink23
            centerTitle: true,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(6), // Reducido de 8 a 6
              decoration: BoxDecoration(
                color: Colors.white.withOpacity( 0.2),
                borderRadius: BorderRadius.circular(10), // Reducido de 12 a 10
                border: Border.all(color: Colors.white.withOpacity( 0.3), width: 1),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18), // Reducido de 20 a 18
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF37474F), // Header oficial Cubalink23
                  // Removemos el gradiente para un look más limpio
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Reducido padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // Centrado
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Reserva',
                          style: TextStyle(
                            fontSize: 24, // Reducido de 28 a 24
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'Tu vuelo ideal',
                          style: TextStyle(
                            fontSize: 24, // Reducido de 28 a 24
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity( 0.9),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Contenido principal optimizado para Motorola Edge 2024
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16), // Reducido de 20 a 16
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle de ida y vuelta optimizado
                    Container(
                      margin: EdgeInsets.only(bottom: 16), // Reducido de 20 a 16
                      decoration: BoxDecoration(
                        color: Colors.blue[50], // Fondo azul claro como en los diseños
                        borderRadius: BorderRadius.circular(20), // Más redondeado
                        border: Border.all(color: Colors.blue[200]!, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 15,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                print('🔘 Usuario seleccionó: Solo ida');
                                setState(() => _isRoundTrip = false);
                                print('🔘 _isRoundTrip cambiado a: $_isRoundTrip');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Reducido padding
                                decoration: BoxDecoration(
                                  color: !_isRoundTrip 
                                      ? Color(0xFF2E7D32) // Verde oscuro para seleccionado 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14), // Reducido de 16 a 14
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_forward,
                                      color: !_isRoundTrip 
                                          ? Colors.white 
                                          : Colors.grey[600],
                                      size: 18, // Reducido de 20 a 18
                                    ),
                                    SizedBox(width: 6), // Reducido de 8 a 6
                                    Text(
                                      'Solo ida',
                                      style: TextStyle(
                                        color: !_isRoundTrip 
                                            ? Colors.white 
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15, // Reducido de 16 a 15
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                print('🔘 Usuario seleccionó: Ida y vuelta');
                                setState(() => _isRoundTrip = true);
                                print('🔘 _isRoundTrip cambiado a: $_isRoundTrip');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Reducido padding
                                decoration: BoxDecoration(
                                  color: _isRoundTrip 
                                      ? Color(0xFF2E7D32) // Verde oscuro para seleccionado 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14), // Reducido de 16 a 14
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.swap_horiz,
                                      color: _isRoundTrip 
                                          ? Colors.white 
                                          : Colors.grey[600],
                                      size: 18, // Reducido de 20 a 18
                                    ),
                                    SizedBox(width: 6), // Reducido de 8 a 6
                                    Text(
                                      'Ida y vuelta',
                                      style: TextStyle(
                                        color: _isRoundTrip 
                                            ? Colors.white 
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15, // Reducido de 16 a 15
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Campos de origen y destino optimizados
                    Container(
                      margin: EdgeInsets.only(bottom: 16), // Reducido de 20 a 16
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14), // Reducido de 16 a 14
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity( 0.08),
                            blurRadius: 8, // Reducido de 10 a 8
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Campo "Desde"
                          Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(14), // Reducido de 16 a 14
                                decoration: BoxDecoration(
                                  color: Colors.blue[50], // Fondo azul claro como en los diseños
                                  borderRadius: BorderRadius.circular(20), // Más redondeado
                                  border: Border.all(color: Colors.blue[200]!, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.flight_takeoff,
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 16, // Reducido de 18 a 16
                                        ),
                                        SizedBox(width: 6), // Reducido de 8 a 6
                                        Text(
                                          'Desde',
                                          style: TextStyle(
                                            fontSize: 12, // Reducido de 13 a 12
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6), // Reducido de 8 a 6
                                    TextFormField(
                                      controller: _fromController,
                                      decoration: InputDecoration(
                                        hintText: 'Origen (ej: MIA)',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 15, // Reducido de 16 a 15
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: TextStyle(
                                        fontSize: 15, // Reducido de 16 a 15
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                      onChanged: (value) {
                                        // Cancelar timer anterior
                                        _fromSearchTimer?.cancel();
                                        
                                        if (value.isNotEmpty) {
                                          // Crear nuevo timer con delay de 800ms
                                          _fromSearchTimer = Timer(Duration(milliseconds: 800), () {
                                            _searchAirportsFrom(value);
                                          });
                                        } else {
                                          setState(() {
                                            _showFromDropdown = false;
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Seleccione el aeropuerto de origen';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Dropdown de resultados "Desde"
                              if (_showFromDropdown && _fromSearchResults.isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(top: 50),
                                  constraints: BoxConstraints(maxHeight: 300),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue[400]!, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[600],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.flight_takeoff, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Aeropuertos encontrados',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              '${_fromSearchResults.length}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _fromSearchResults.length,
                                          itemBuilder: (context, index) {
                                            final airport = _fromSearchResults[index];
                                            return ListTile(
                                              dense: false,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              leading: Icon(Icons.flight_takeoff, color: Colors.blue[700], size: 24),
                                              title: Text(
                                                airport['display_name'] ?? airport['name'] ?? 'Aeropuerto',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              subtitle: Text(
                                                '${airport['city'] ?? ''} ${airport['iata_code'] ?? airport['code'] ?? ''}'.trim(),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              hoverColor: Colors.blue[50],
                                              focusColor: Colors.blue[50],
                                              selectedTileColor: Colors.blue[100],
                                              onTap: () {
                                                String displayText = airport['display_name'] ?? '';
                                                if (displayText.isEmpty) {
                                                  displayText = '${airport['name']} (${airport['iata_code'] ?? airport['code']})';
                                                }
                                                _fromController.text = displayText;
                                                setState(() {
                                                  _showFromDropdown = false;
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          
                          Container(
                            height: 1,
                            color: Colors.grey[100],
                            margin: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          
                          // Campo "Hasta"
                          Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(14), // Reducido de 16 a 14
                                decoration: BoxDecoration(
                                  color: Colors.blue[50], // Fondo azul claro como en los diseños
                                  borderRadius: BorderRadius.circular(20), // Más redondeado
                                  border: Border.all(color: Colors.blue[200]!, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.flight_land,
                                          color: Theme.of(context).colorScheme.secondary,
                                          size: 16, // Reducido de 18 a 16
                                        ),
                                        SizedBox(width: 6), // Reducido de 8 a 6
                                        Text(
                                          'Hasta',
                                          style: TextStyle(
                                            fontSize: 12, // Reducido de 13 a 12
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6), // Reducido de 8 a 6
                                    TextFormField(
                                      controller: _toController,
                                      decoration: InputDecoration(
                                        hintText: 'Destino (ej: HAV)',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 15, // Reducido de 16 a 15
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: TextStyle(
                                        fontSize: 15, // Reducido de 16 a 15
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                      onChanged: (value) {
                                        // Cancelar timer anterior
                                        _toSearchTimer?.cancel();
                                        
                                        if (value.isNotEmpty) {
                                          // Crear nuevo timer con delay de 800ms
                                          _toSearchTimer = Timer(Duration(milliseconds: 800), () {
                                            _searchAirportsTo(value);
                                          });
                                        } else {
                                          setState(() {
                                            _showToDropdown = false;
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Seleccione el aeropuerto de destino';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Dropdown de resultados "Hasta"
                              if (_showToDropdown && _toSearchResults.isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(top: 50),
                                  constraints: BoxConstraints(maxHeight: 300),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue[400]!, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[600],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.flight_land, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Aeropuertos encontrados',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              '${_toSearchResults.length}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _toSearchResults.length,
                                          itemBuilder: (context, index) {
                                            final airport = _toSearchResults[index];
                                            return ListTile(
                                              dense: false,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              leading: Icon(Icons.flight_land, color: Colors.blue[700], size: 24),
                                              title: Text(
                                                airport['display_name'] ?? airport['name'] ?? 'Aeropuerto',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              subtitle: Text(
                                                '${airport['city'] ?? ''} ${airport['iata_code'] ?? airport['code'] ?? ''}'.trim(),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              hoverColor: Colors.blue[50],
                                              focusColor: Colors.blue[50],
                                              selectedTileColor: Colors.blue[100],
                                              onTap: () {
                                                String displayText = airport['display_name'] ?? '';
                                                if (displayText.isEmpty) {
                                                  displayText = '${airport['name']} (${airport['iata_code'] ?? airport['code']})';
                                                }
                                                _toController.text = displayText;
                                                setState(() {
                                                  _showToDropdown = false;
                                                });
                                              },
                                            );
                                          },
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
                    
                    // Botón de intercambio optimizado
                    Center(
                      child: GestureDetector(
                        onTap: _swapAirports,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16), // Reducido de 20 a 16
                          padding: EdgeInsets.all(10), // Reducido de 12 a 10
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity( 0.1),
                                blurRadius: 6, // Reducido de 8 a 6
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.swap_vert,
                            size: 20, // Reducido de 24 a 20
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    
                    // Fechas
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity( 0.08),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () => _selectDate(true),
                                  borderRadius: BorderRadius.circular(14),
                                  splashColor: Colors.orange.withOpacity(0.1),
                                  highlightColor: Colors.orange.withOpacity(0.05),
                                  child: Container(
                                    padding: EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.calendar_today,
                                                color: Colors.orange[600],
                                                size: 16,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Salida',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _departureDate != null
                                                    ? '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}'
                                                    : 'Seleccionar fecha',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: _departureDate != null 
                                                      ? Colors.grey[800] 
                                                      : Colors.grey[400],
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.grey[400],
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                if (_isRoundTrip) ...[
                                  Container(
                                    height: 1,
                                    color: Colors.grey[100],
                                  ),
                                  
                                  InkWell(
                                    onTap: () => _selectDate(false),
                                    borderRadius: BorderRadius.circular(14),
                                    splashColor: Colors.blue.withOpacity(0.1),
                                    highlightColor: Colors.blue.withOpacity(0.05),
                                    child: Container(
                                      padding: EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.blue[600],
                                                  size: 16,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Regreso',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _returnDate != null
                                                      ? '${_returnDate!.day}/${_returnDate!.month}/${_returnDate!.year}'
                                                      : 'Seleccionar fecha',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: _returnDate != null 
                                                        ? Colors.grey[800] 
                                                        : Colors.grey[400],
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.grey[400],
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        // Pasajeros y clase
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity( 0.08),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Pasajeros con mejor respuesta táctil
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showPassengerSelector = !_showPassengerSelector;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  splashColor: Colors.green.withOpacity(0.1),
                                  highlightColor: Colors.green.withOpacity(0.05),
                                  child: Container(
                                    padding: EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Colors.green[600],
                                              size: 16,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Pasajeros',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${_getTotalPassengers()}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            Icon(
                                              _showPassengerSelector 
                                                  ? Icons.keyboard_arrow_up 
                                                  : Icons.keyboard_arrow_down,
                                              color: Colors.grey[600],
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                Container(
                                  height: 1,
                                  color: Colors.grey[100],
                                ),
                                
                                // Clase optimizada para Motorola Edge 2024
                                Container(
                                  padding: EdgeInsets.all(14), // Reducido de 16 a 14
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.airline_seat_recline_normal,
                                            color: Colors.blue[600],
                                            size: 16, // Reducido de 18 a 16
                                          ),
                                          SizedBox(width: 6), // Reducido de 8 a 6
                                          Text(
                                            'Clase',
                                            style: TextStyle(
                                              fontSize: 12, // Reducido de 13 a 12
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6), // Reducido de 8 a 6
                                      DropdownButtonFormField<String>(
                                        initialValue: _selectedClass,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true, // Agregado para reducir altura
                                        ),
                                        style: TextStyle(
                                          fontSize: 14, // Reducido de 16 a 14
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                        dropdownColor: Colors.white,
                                        isExpanded: true, // Agregado para evitar overflow
                                        items: _flightClasses.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                fontSize: 14, // Tamaño consistente
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis, // Agregado para evitar overflow
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedClass = newValue!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Selector de pasajeros optimizado para Motorola Edge 2024
                    if (_showPassengerSelector)
                      Container(
                        margin: EdgeInsets.only(top: 12), // Reducido de 16 a 12
                        padding: EdgeInsets.all(16), // Reducido de 20 a 16
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14), // Reducido de 16 a 14
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity( 0.08),
                              blurRadius: 8, // Reducido de 10 a 8
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seleccionar pasajeros',
                              style: TextStyle(
                                fontSize: 16, // Reducido de 18 a 16
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 16), // Reducido de 20 a 16
                            _buildPassengerSelector(
                              'Adultos',
                              '18 - 64 años',
                              Icons.person,
                              _adults,
                              (value) => setState(() => _adults = value),
                            ),
                            SizedBox(height: 12), // Reducido de 16 a 12
                            _buildPassengerSelector(
                              'Personas mayores',
                              '65+ años',
                              Icons.elderly,
                              _seniors,
                              (value) => setState(() => _seniors = value),
                            ),
                            SizedBox(height: 12), // Reducido de 16 a 12
                            _buildPassengerSelector(
                              'Niños',
                              '3 - 17 años',
                              Icons.child_care,
                              _children,
                              (value) => setState(() => _children = value),
                            ),
                            SizedBox(height: 12), // Reducido de 16 a 12
                            _buildPassengerSelector(
                              'Bebés',
                              '0 - 2 años',
                              Icons.baby_changing_station,
                              _infants,
                              (value) => setState(() => _infants = value),
                            ),
                            SizedBox(height: 16), // Reducido de 20 a 16
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _adults = 1;
                                        _seniors = 0;
                                        _children = 0;
                                        _infants = 0;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey[300]!),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10), // Reducido de 12 a 10
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 12), // Agregado padding
                                    ),
                                    child: Text(
                                      'Reiniciar', 
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14, // Agregado tamaño de fuente
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10), // Reducido de 12 a 10
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showPassengerSelector = false;
                                        _passengersController.text = _getTotalPassengers().toString();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10), // Reducido de 12 a 10
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 12), // Agregado padding
                                    ),
                                    child: Text(
                                      'Confirmar',
                                      style: TextStyle(
                                        fontSize: 14, // Agregado tamaño de fuente
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    
                    SizedBox(height: 24), // Reducido de 32 a 24
                    
                    // Botón de búsqueda optimizado para Motorola Edge 2024
                    SizedBox(
                      width: double.infinity,
                      height: 50, // Reducido de 56 a 50
                      child: ElevatedButton(
                        onPressed: _isLoadingFlights ? null : () {
                          if (_formKey.currentState!.validate()) {
                            if (_departureDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('⚠️ Seleccione la fecha de salida'),
                                  backgroundColor: Colors.orange[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                              return;
                            }
                            if (_isRoundTrip && _returnDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('⚠️ Seleccione la fecha de regreso'),
                                  backgroundColor: Colors.orange[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                              return;
                            }
                            _searchFlights();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF9800), // Botón principal oficial Cubalink23
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: Color(0xFFFF9800).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14), // Reducido de 16 a 14
                          ),
                        ),
                        child: _isLoadingFlights
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18, // Reducido de 20 a 18
                                    height: 18, // Reducido de 20 a 18
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10), // Reducido de 12 a 10
                                  Text(
                                    'Buscando...',
                                    style: TextStyle(
                                      fontSize: 16, // Reducido de 18 a 16
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_rounded, size: 20), // Reducido de 22 a 20
                                  SizedBox(width: 10), // Reducido de 12 a 10
                                  Text(
                                    'Buscar Vuelos',
                                    style: TextStyle(
                                      fontSize: 16, // Reducido de 18 a 16
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    
                    SizedBox(height: 16), // Reducido de 20 a 16

                    // Los resultados ahora se muestran en una pantalla separada
                    
                    // Mostrar error si existe
                    if (_errorMessage != null)
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[600]),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Padding inferior para evitar barra de navegación
          SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
          ),
          // Overlay de loading en el centro de la pantalla
          if (_isLoadingFlights)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                        strokeWidth: 4,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Buscando vuelos...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ✈️ BÚSQUEDA DE VUELOS CON DUFFEL API REAL
  Future<void> _searchFlights() async {
    setState(() {
      _isLoadingFlights = true;
      _errorMessage = null;
      _flightOffers.clear();
    });

    try {
      print('🎯 INICIANDO BÚSQUEDA REAL CON DUFFEL API');
      
      // Extraer códigos IATA
      final fromCode = _extractAirportCode(_fromController.text);
      final toCode = _extractAirportCode(_toController.text);
      
      if (fromCode == null || toCode == null) {
        throw Exception('Códigos de aeropuerto no válidos');
      }

      // Formatear fechas
      final departureStr = '${_departureDate!.year}-${_departureDate!.month.toString().padLeft(2, '0')}-${_departureDate!.day.toString().padLeft(2, '0')}';
      final returnStr = _isRoundTrip && _returnDate != null 
          ? '${_returnDate!.year}-${_returnDate!.month.toString().padLeft(2, '0')}-${_returnDate!.day.toString().padLeft(2, '0')}'
          : null;

      // Convertir clase a formato Duffel API
      String cabinClass = 'economy';
      switch (_selectedClass) {
        case 'Económica':
          cabinClass = 'economy';
          break;
        case 'Premium Económica':
          cabinClass = 'premium_economy';
          break;
        case 'Business':
          cabinClass = 'business';
          break;
        case 'Primera Clase':
          cabinClass = 'first';
          break;
      }

      print('🔍 Buscando: $fromCode → $toCode');
      print('📅 Salida: $departureStr');
      if (returnStr != null) print('📅 Regreso: $returnStr');
      print('👥 Pasajeros: ${_getTotalPassengers()}');
      print('💺 Clase: $cabinClass');

      // PASO 1: Crear Offer Request
      final searchResult = await DuffelApiService.searchFlights(
        origin: fromCode,
        destination: toCode,
        departureDate: departureStr,
        adults: _getTotalPassengers(),
        cabinClass: cabinClass,
        returnDate: returnStr,
      );

      if (searchResult == null) {
        throw Exception('No se pudo crear la búsqueda de vuelos');
      }

      if (searchResult['data'] == null) {
        throw Exception('No se recibieron datos del servidor');
      }

      // Delay mínimo para mostrar el spinner
      await Future.delayed(Duration(milliseconds: 500));
      
      // El backend devuelve directamente los vuelos, no necesita segundo paso
      final flightsData = searchResult['data'];
      
      if (flightsData is! List || flightsData.isEmpty) {
        setState(() {
          _errorMessage = 'No se encontraron vuelos disponibles para esta ruta y fecha. Intente con diferentes destinos o fechas.';
        });
        return;
      }

      print('✅ Vuelos recibidos directamente del backend: ${flightsData.length}');
      print('🔍 DEBUG _isRoundTrip ANTES de crear FlightOffer: $_isRoundTrip');

      // Convertir a modelos FlightOffer usando los datos directos del backend
      final offers = flightsData.map((flightData) => FlightOffer.fromBackendJson(flightData)).toList();
      
      setState(() {
        _flightOffers = offers;
      });

      print('🎉 ¡${offers.length} ofertas cargadas exitosamente!');
      
      // 🚀 NAVEGAR AUTOMÁTICAMENTE A LA PANTALLA DE RESULTADOS
      if (offers.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightResultsScreen(
              flightOffers: offers,
              fromAirport: _fromController.text,
              toAirport: _toController.text,
              departureDate: _departureDate != null ? 
                '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}' : '',
              returnDate: _returnDate != null ? 
                '${_returnDate!.day}/${_returnDate!.month}/${_returnDate!.year}' : null,
              passengers: _getTotalPassengers(),
              airlineType: _selectedClass,
            ),
          ),
        );
      }

    } catch (e) {
      print('❌ Error en búsqueda: $e');
      setState(() {
        _errorMessage = 'Error buscando vuelos: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingFlights = false;
      });
    }
  }

  // Extraer código IATA del texto del controller
  String? _extractAirportCode(String text) {
    // Buscar patrón de 3 letras mayúsculas dentro de paréntesis
    final regexParens = RegExp(r'\(([A-Z]{3})\)');
    var match = regexParens.firstMatch(text);
    if (match != null) {
      return match.group(1)!;
    }
    
    // Buscar patrón de 3 letras mayúsculas al final del string
    final regex = RegExp(r'\b([A-Z]{3})\b');
    match = regex.firstMatch(text);
    if (match != null) {
      return match.group(1)!;
    }
    
    return null;
  }

  // Widget para mostrar una oferta de vuelo
  Widget _buildFlightOfferCard(FlightOffer offer) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con aerolínea y precio
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.flight,
                    size: 20,
                    color: Colors.blue[600],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.airline,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      offer.stopsText,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    offer.formattedPrice,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'por persona',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Información del vuelo
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.formattedDepartureTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Salida',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        offer.formattedDuration,
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      offer.stopsText,
                      style: TextStyle(
                        fontSize: 11, 
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      offer.formattedArrivalTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Llegada',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Botón de seleccionar vuelo
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _proceedToPassengerInfo(offer),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Seleccionar Vuelo',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Proceder a información del pasajero
  void _proceedToPassengerInfo(FlightOffer selectedOffer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassengerInfoScreen(
          selectedOffer: selectedOffer,
          totalPassengers: _getTotalPassengers(),
          searchDetails: {
            'origin': _extractAirportCode(_fromController.text),
            'destination': _extractAirportCode(_toController.text),
            'departureDate': _departureDate,
            'returnDate': _returnDate,
            'isRoundTrip': _isRoundTrip,
            'cabinClass': _selectedClass,
            'adults': _adults,
            'children': _children,
            'infants': _infants,
          },
        ),
      ),
    );
  }

  // Métodos auxiliares
  String _cleanSearchQuery(String query) {
    // Remover códigos IATA en paréntesis y limpiar texto
    String cleaned = query
        .replaceAll(RegExp(r'\([A-Z]{3}\)'), '') // Remover (MIA), (HAV), etc.
        .replaceAll(RegExp(r'\s+'), ' ') // Normalizar espacios
        .trim();
    
    // Si contiene coma, tomar solo la primera parte (nombre de ciudad)
    if (cleaned.contains(',')) {
      cleaned = cleaned.split(',')[0].trim();
    }
    
    print('🧹 Query original: "$query" -> Query limpio: "$cleaned"');
    return cleaned;
  }

  Future<void> _searchAirportsFrom(String query) async {
    setState(() {
      _isSearchingFrom = true;
      _showFromDropdown = true;
    });

    try {
      // Limpiar el query antes de usar (remover códigos IATA y caracteres especiales)
      String cleanQuery = _cleanSearchQuery(query);
      
      // Si el query limpio está vacío o es muy corto, no buscar
      if (cleanQuery.length < 2) {
        setState(() {
          _fromSearchResults = [];
          _isSearchingFrom = false;
        });
        return;
      }

      // Buscar SOLO en la API de Duffel con query limpio (sin locales)
      final apiResults = await DuffelApiService.searchAirports(cleanQuery);
      
      setState(() {
        _fromSearchResults = apiResults;
        _isSearchingFrom = false;
      });
    } catch (e) {
      print('Error searching airports: $e');
      setState(() {
        _fromSearchResults = [];
        _isSearchingFrom = false;
      });
    }
  }

  Future<void> _searchAirportsTo(String query) async {
    setState(() {
      _isSearchingTo = true;
      _showToDropdown = true;
    });

    try {
      // Limpiar el query antes de usar (remover códigos IATA y caracteres especiales)
      String cleanQuery = _cleanSearchQuery(query);
      
      // Si el query limpio está vacío o es muy corto, no buscar
      if (cleanQuery.length < 2) {
        setState(() {
          _toSearchResults = [];
          _isSearchingTo = false;
        });
        return;
      }

      // Buscar SOLO en la API de Duffel con query limpio (sin locales)
      final apiResults = await DuffelApiService.searchAirports(cleanQuery);
      
      setState(() {
        _toSearchResults = apiResults;
        _isSearchingTo = false;
      });
    } catch (e) {
      print('Error searching airports: $e');
      setState(() {
        _toSearchResults = [];
        _isSearchingTo = false;
      });
    }
  }

  void _swapAirports() {
    final temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
  }

  Future<void> _selectDate(bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeparture 
          ? (_departureDate ?? DateTime.now())
          : (_returnDate ?? _departureDate ?? DateTime.now().add(Duration(days: 1))),
      firstDate: isDeparture 
          ? DateTime.now()
          : (_departureDate ?? DateTime.now()),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          // Si la fecha de regreso es anterior a la de salida, resetearla
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = null;
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  int _getTotalPassengers() {
    return _adults + _seniors + _children + _infants;
  }
  
  Widget _buildPassengerSelector(
    String title,
    String subtitle,
    IconData icon,
    int value,
    Function(int) onChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (value > (title == 'Adultos' ? 1 : 0)) {
                  onChanged(value - 1);
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.remove, size: 16),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (value < 9) {
                  onChanged(value + 1);
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}