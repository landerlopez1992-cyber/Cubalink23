import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cubalink23/services/duffel_api_service.dart';
import 'package:cubalink23/models/flight_offer.dart';
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
  
  // Variables para estado de búsqueda
  bool _isLoadingFlights = false;
  String? _errorMessage;
  
  // Variables para debounce de búsqueda de aeropuertos
  Timer? _fromSearchTimer;
  Timer? _toSearchTimer;
  
  // Variables para indicadores de carga de búsqueda
  bool _isSearchingFrom = false;
  bool _isSearchingTo = false;
  
  // 🎯 SELECTOR DE TIPO DE AEROLÍNEAS  
  String _airlineType = 'ambos'; // 'comerciales', 'charter', 'ambos'
  
  List<Map<String, dynamic>> _fromSearchResults = [];
  List<Map<String, dynamic>> _toSearchResults = [];
  bool _showFromDropdown = false;
  bool _showToDropdown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco puro como en los diseños modernos
      body: CustomScrollView(
        slivers: [
          // Header moderno estilo referencia
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity( 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity( 0.3), width: 1),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[600], // Azul sólido moderno como en los diseños
                  // Removemos el gradiente para un look más limpio
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Reserva',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'Tu vuelo ideal',
                          style: TextStyle(
                            fontSize: 28,
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
          
          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16), // Reducido de 20 a 16
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle de ida y vuelta
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
                            offset: Offset(0, 5),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isRoundTrip = false),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: !_isRoundTrip 
                                      ? Colors.blue[700] // Azul más oscuro para selección
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: !_isRoundTrip ? Colors.blue[700]! : Colors.blue[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_forward,
                                      color: !_isRoundTrip 
                                          ? Colors.white 
                                          : Colors.grey[600],
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Solo ida',
                                      style: TextStyle(
                                        color: !_isRoundTrip 
                                            ? Colors.white 
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isRoundTrip = true),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: _isRoundTrip 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.swap_horiz,
                                      color: _isRoundTrip 
                                          ? Colors.white 
                                          : Colors.grey[600],
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Ida y vuelta',
                                      style: TextStyle(
                                        color: _isRoundTrip 
                                            ? Colors.white 
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
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
                    
                    // 🎯 SELECTOR DE TIPO DE AEROLÍNEAS - RESPONSIVE
                    Container(
                      margin: EdgeInsets.only(bottom: 12), // Reducido de 20 a 12
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Ambos
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _airlineType = 'ambos'),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: _airlineType == 'ambos'
                                      ? Theme.of(context).colorScheme.primary 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.all_inclusive,
                                      color: _airlineType == 'ambos'
                                          ? Colors.white 
                                          : Colors.grey[600],
                                      size: 14,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Ambos',
                                      style: TextStyle(
                                        color: _airlineType == 'ambos'
                                            ? Colors.white 
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Comerciales
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _airlineType = 'comerciales'),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: _airlineType == 'comerciales'
                                      ? Theme.of(context).colorScheme.primary 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.business,
                                      color: _airlineType == 'comerciales'
                                          ? Colors.white 
                                          : Colors.grey[600],
                                      size: 14,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Comerciales',
                                      style: TextStyle(
                                        color: _airlineType == 'comerciales'
                                          ? Colors.white 
                                          : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Charter
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _airlineType = 'charter'),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: _airlineType == 'charter'
                                      ? Theme.of(context).colorScheme.primary 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.flight_takeoff,
                                      color: _airlineType == 'charter'
                                          ? Colors.white 
                                          : Colors.grey[600],
                                      size: 14,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Charter',
                                      style: TextStyle(
                                        color: _airlineType == 'charter'
                                          ? Colors.white 
                                          : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Campos de origen y destino con intercambio
                    Container(
                      margin: EdgeInsets.only(bottom: 12), // Reducido de 20 a 12
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
                        children: [
                          // Campo "Desde"
                          Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.flight_takeoff,
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Desde',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    TextFormField(
                                      controller: _fromController,
                                      decoration: InputDecoration(
                                        hintText: 'Origen (ej: MIA)',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 16,
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                        suffixIcon: _isSearchingFrom 
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: Padding(
                                                padding: EdgeInsets.all(12),
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : null,
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                      onChanged: (value) {
                                        // Cancelar búsqueda anterior
                                        _fromSearchTimer?.cancel();
                                        
                                        if (value.isNotEmpty) {
                                          // Debounce optimizado de 300ms para búsquedas más rápidas
                                          _fromSearchTimer = Timer(Duration(milliseconds: 300), () {
                                            _searchAirportsFrom(value);
                                          });
                                        } else {
                                          setState(() {
                                            _fromSearchResults = [];
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
                              
                              // Dropdown de resultados "Desde" - RECUADRO LIMPIO
                              if (_showFromDropdown)
                                Container(
                                  margin: EdgeInsets.only(top: 80, left: 20, right: 20), // Separación máxima + márgenes laterales
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20), // Más redondeado
                                    border: Border.all(color: Colors.blue[400]!, width: 3), // Borde azul más visible
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(maxHeight: 500), // Altura máxima para evitar overlap
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: _fromSearchResults.length,
                                    itemBuilder: (context, index) {
                                      if (index >= _fromSearchResults.length) return SizedBox.shrink();
                                      final airport = _fromSearchResults[index];
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey[100]!,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        child: ListTile(
                                          dense: true,
                                          leading: Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                          title: Text(
                                            airport['display_name'] ?? airport['name'] ?? '',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                          subtitle: Text(
                                            '${airport['code']}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                          onTap: () {
                                            print('🔍 ===== DEBUG SELECCIÓN FROM =====');
                                            print('🔍 display_name: "${airport['display_name']}"');
                                            print('🔍 name: "${airport['name']}"');
                                            print('🔍 iata_code: "${airport['iata_code']}"');
                                            print('🔍 code: "${airport['code']}"');
                                            
                                            // LIMPIAR display_name para evitar duplicaciones
                                            final rawDisplayName = airport['display_name'] ?? '';
                                            String cleanText = rawDisplayName;
                                            
                                            // Detectar patrón: "Airport Name (CODE) (CODE)"
                                            if (cleanText.contains('(') && cleanText.contains(')')) {
                                              // Contar paréntesis
                                              final openParens = cleanText.split('(').length - 1;
                                              if (openParens > 1) {
                                                // Hay duplicación - extraer solo el primer código
                                                final firstParen = cleanText.indexOf('(');
                                                final firstClose = cleanText.indexOf(')', firstParen);
                                                if (firstClose != -1) {
                                                  cleanText = cleanText.substring(0, firstClose + 1);
                                                  print('🔍 DUPLICACIÓN REMOVIDA: "$cleanText"');
                                                }
                                              }
                                            }
                                            
                                            print('🔍 TEXTO FINAL: "$cleanText"');
                                            _fromController.text = cleanText;
                                            setState(() {
                                              _showFromDropdown = false;
                                            });
                                          },
                                        ),
                                      );
                                    },
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
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.flight_land,
                                          color: Theme.of(context).colorScheme.secondary,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Hasta',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    TextFormField(
                                      controller: _toController,
                                      decoration: InputDecoration(
                                        hintText: 'Destino (ej: HAV)',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 16,
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                        suffixIcon: _isSearchingTo 
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: Padding(
                                                padding: EdgeInsets.all(12),
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : null,
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                      onChanged: (value) {
                                        // Cancelar búsqueda anterior
                                        _toSearchTimer?.cancel();
                                        
                                        if (value.isNotEmpty) {
                                          // Debounce optimizado de 300ms para búsquedas más rápidas
                                          _toSearchTimer = Timer(Duration(milliseconds: 300), () {
                                            _searchAirportsTo(value);
                                          });
                                        } else {
                                          setState(() {
                                            _toSearchResults = [];
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
                              
                              // Dropdown de resultados "Hasta" - RECUADRO LIMPIO
                              if (_showToDropdown)
                                Container(
                                  margin: EdgeInsets.only(top: 80, left: 20, right: 20), // Separación máxima + márgenes laterales
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20), // Más redondeado
                                    border: Border.all(color: Colors.blue[400]!, width: 3), // Borde azul más visible
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(maxHeight: 500), // Altura máxima para evitar overlap
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: _toSearchResults.length,
                                    itemBuilder: (context, index) {
                                      if (index >= _toSearchResults.length) return SizedBox.shrink();
                                      final airport = _toSearchResults[index];
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey[100]!,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        child: ListTile(
                                          dense: true,
                                          leading: Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                          title: Text(
                                            airport['display_name'] ?? airport['name'] ?? '',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                          subtitle: Text(
                                            '${airport['code']}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                          onTap: () {
                                            print('🔍 ===== DEBUG SELECCIÓN TO =====');
                                            print('🔍 display_name: "${airport['display_name']}"');
                                            print('🔍 name: "${airport['name']}"');
                                            print('🔍 iata_code: "${airport['iata_code']}"');
                                            print('🔍 code: "${airport['code']}"');
                                            
                                            // LIMPIAR display_name para evitar duplicaciones
                                            final rawDisplayName = airport['display_name'] ?? '';
                                            String cleanText = rawDisplayName;
                                            
                                            // Detectar patrón: "Airport Name (CODE) (CODE)"
                                            if (cleanText.contains('(') && cleanText.contains(')')) {
                                              // Contar paréntesis
                                              final openParens = cleanText.split('(').length - 1;
                                              if (openParens > 1) {
                                                // Hay duplicación - extraer solo el primer código
                                                final firstParen = cleanText.indexOf('(');
                                                final firstClose = cleanText.indexOf(')', firstParen);
                                                if (firstClose != -1) {
                                                  cleanText = cleanText.substring(0, firstClose + 1);
                                                  print('🔍 DUPLICACIÓN REMOVIDA: "$cleanText"');
                                                }
                                              }
                                            }
                                            
                                            print('🔍 TEXTO FINAL: "$cleanText"');
                                            _toController.text = cleanText;
                                            setState(() {
                                              _showToDropdown = false;
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Botón de intercambio - CENTRADO Y RESPONSIVE
                    SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: GestureDetector(
                          onTap: _swapAirports,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 12), // Reducido de 20 a 12
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.swap_vert,
                              size: 24,
                              color: Theme.of(context).colorScheme.primary,
                            ),
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
                                GestureDetector(
                                  onTap: () => _selectDate(true),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              color: Colors.orange[600],
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Salida',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          _departureDate != null
                                              ? '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}'
                                              : 'Seleccionar fecha',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _departureDate != null 
                                                ? Colors.grey[800] 
                                                : Colors.grey[400],
                                          ),
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
                                  
                                  GestureDetector(
                                    onTap: () => _selectDate(false),
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                color: Colors.blue[600],
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Regreso',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            _returnDate != null
                                                ? '${_returnDate!.day}/${_returnDate!.month}/${_returnDate!.year}'
                                                : 'Seleccionar fecha',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: _returnDate != null 
                                                  ? Colors.grey[800] 
                                                  : Colors.grey[400],
                                            ),
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
                                // Pasajeros
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showPassengerSelector = !_showPassengerSelector;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Colors.green[600],
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Pasajeros',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '${_getTotalPassengers()}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                Container(
                                  height: 1,
                                  color: Colors.grey[100],
                                ),
                                
                                // Clase
                                Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.airline_seat_recline_normal,
                                            color: Colors.blue[600],
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Clase',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        initialValue: _selectedClass,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                        items: _flightClasses.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
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
                    
                    // Selector de pasajeros (desplegable)
                    if (_showPassengerSelector)
                      Container(
                        margin: EdgeInsets.only(top: 8), // Reducido de 16 a 8
                        padding: EdgeInsets.all(16), // Reducido de 20 a 16
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seleccionar pasajeros',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8), // Reducido de 12 a 8
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
                            SizedBox(height: 8), // Reducido de 12 a 8
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 12), // Añadido padding vertical
                                    ),
                                    child: Text(
                                      'Reiniciar', 
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14, // Reducido de default
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 12), // Añadido padding vertical
                                    ),
                                    child: Text(
                                      'Confirmar',
                                      style: TextStyle(fontSize: 14), // Reducido de default
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    
                    SizedBox(height: 16), // Reducido de 32 a 16
                    
                    // Botón de búsqueda principal - RESPONSIVE
                    Container(
                      width: double.infinity,
                      height: 50, // Reducido de 56 a 50
                      margin: EdgeInsets.symmetric(horizontal: 4),
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
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: Theme.of(context).colorScheme.primary.withOpacity( 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoadingFlights
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
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
                                  Icon(Icons.search_rounded, size: 22),
                                  SizedBox(width: 12),
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
                    
                    SizedBox(height: 12),
                    
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
                    
                    // Padding inferior para asegurar que el botón no quede fuera
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🛩️ MOSTRAR MODAL DE CARGA CON AVIONCITO
  void _showLoadingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avioncito animado
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      children: [
                        // Círculo de fondo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Avioncito con animación
                        Center(
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(seconds: 2),
                            builder: (context, double value, child) {
                              return Transform.translate(
                                offset: Offset(10 * value, -5 * value),
                                child: Transform.rotate(
                                  angle: 0.3 * value,
                                  child: Icon(
                                    Icons.flight_takeoff,
                                    size: 40,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Buscando vuelos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _airlineType == 'ambos' 
                        ? 'Consultando todas las aerolíneas...'
                        : _airlineType == 'comerciales'
                        ? 'Consultando aerolíneas comerciales...'
                        : 'Consultando aerolíneas charter...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ✈️ BÚSQUEDA DE VUELOS CON DUFFEL API REAL
  Future<void> _searchFlights() async {
    // 🛩️ MOSTRAR MODAL DE CARGA
    _showLoadingModal();

    try {
      print('🎯 INICIANDO BÚSQUEDA REAL CON DUFFEL API');
      
      // Extraer códigos IATA
      print('🔍 DEBUG: Texto del controlador FROM: "${_fromController.text}"');
      print('🔍 DEBUG: Texto del controlador TO: "${_toController.text}"');
      
      final fromCode = _extractAirportCode(_fromController.text);
      final toCode = _extractAirportCode(_toController.text);
      
      print('🔍 DEBUG: Código FROM extraído: $fromCode');
      print('🔍 DEBUG: Código TO extraído: $toCode');
      
      if (fromCode == null || toCode == null) {
        print('❌ ERROR: No se pudieron extraer códigos IATA');
        print('❌ FROM text: "${_fromController.text}" → code: $fromCode');
        print('❌ TO text: "${_toController.text}" → code: $toCode');
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

      // PASO 1: Crear Offer Request con tipo de aerolínea
      print('🎯 Tipo de aerolínea seleccionado: $_airlineType');
      final searchResult = await DuffelApiService.searchFlights(
        origin: fromCode,
        destination: toCode,
        departureDate: departureStr,
        adults: _getTotalPassengers(),
        cabinClass: cabinClass,
        returnDate: returnStr,
        airlineType: _airlineType, // 🎯 USAR TIPO SELECCIONADO
      );

      if (searchResult == null) {
        throw Exception('No se pudo crear la búsqueda de vuelos');
      }

      // 🛡️ MANEJAR ESTADO OFFLINE DEL BACKEND
      if (searchResult['status'] == 'offline' || searchResult['status'] == 'error') {
        // 🚫 CERRAR MODAL DE CARGA
        Navigator.of(context).pop();
        
        setState(() {
          _errorMessage = searchResult['message'] ?? 'Servicio temporalmente no disponible';
          _isLoadingFlights = false;
        });
        return;
      }

      // Verificar si el resultado contiene datos de vuelos directamente
      if (searchResult['data'] != null && searchResult['data'] is List) {
        // El backend ya devolvió los vuelos procesados
        final flights = searchResult['data'] as List;
        print('✅ Vuelos obtenidos directamente: ${flights.length}');
        
        // Convertir a FlightOffer
        final flightOffers = flights.map((flight) => FlightOffer.fromDuffelJson(flight)).toList();
        
        // 🚫 CERRAR MODAL DE CARGA
        Navigator.of(context).pop();
        
        setState(() {
          _isLoadingFlights = false;
        });
        
        // Navegar a resultados
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FlightResultsScreen(
              flightOffers: flightOffers,
              fromAirport: fromCode,
              toAirport: toCode,
              departureDate: departureStr,
              returnDate: returnStr,
              passengers: _getTotalPassengers(),
              airlineType: _airlineType,
            ),
          ),
        );
        return;
      }
      
      // Si no, procesar como antes (offer request)
      if (searchResult['data'] == null) {
        throw Exception('No se recibieron datos del servidor');
      }
      
      final offerRequestId = searchResult['data']['id'] as String;
      
      print('✅ Offer Request creado: $offerRequestId');

      // PASO 2: Obtener ofertas disponibles
      print('🔍 Obteniendo ofertas disponibles...');
      final offersData = await DuffelApiService.getOffers(offerRequestId);

      if (offersData.isEmpty) {
        // 🚫 CERRAR MODAL DE CARGA
        Navigator.of(context).pop();
        
        setState(() {
          _errorMessage = 'No se encontraron vuelos disponibles para esta ruta y fecha. Intente con diferentes destinos o fechas.';
          _isLoadingFlights = false;
        });
        return;
      }

      // Convertir a modelos FlightOffer
      final offers = offersData.map((offerData) => FlightOffer.fromDuffelJson(offerData)).toList();
      
      // 🚫 CERRAR MODAL DE CARGA
      Navigator.of(context).pop();
      
      print('🎉 ¡${offers.length} ofertas cargadas exitosamente!');
      
      // 🚀 NAVEGAR A NUEVA PANTALLA DE RESULTADOS
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlightResultsScreen(
            flightOffers: offers,
            fromAirport: _fromController.text,
            toAirport: _toController.text,
            departureDate: departureStr,
            returnDate: returnStr,
            passengers: _getTotalPassengers(),
            airlineType: _airlineType,
          ),
        ),
      );
      
      setState(() {
        _isLoadingFlights = false;
      });

    } catch (e) {
      print('❌ Error en búsqueda: $e');
      // 🚫 CERRAR MODAL DE CARGA EN CASO DE ERROR
      Navigator.of(context).pop();
      
      setState(() {
        _errorMessage = 'Error buscando vuelos: ${e.toString()}';
        _isLoadingFlights = false;
      });
    }
  }

  // Extraer código IATA del texto del controller
  String? _extractAirportCode(String text) {
    print('🔍 DEBUG: Extrayendo código IATA de: "$text"');
    
    // Buscar patrón de 3 letras mayúsculas dentro de paréntesis
    final regexParens = RegExp(r'\(([A-Z]{3})\)');
    var match = regexParens.firstMatch(text);
    if (match != null) {
      print('✅ Encontrado código IATA en paréntesis: ${match.group(1)}');
      return match.group(1)!;
    }
    
    // Buscar patrón de 3 letras mayúsculas al final del string
    final regex = RegExp(r'\b([A-Z]{3})\b');
    match = regex.firstMatch(text);
    if (match != null) {
      print('✅ Encontrado código IATA al final: ${match.group(1)}');
      return match.group(1)!;
    }
    
    // Buscar cualquier secuencia de 3 letras mayúsculas consecutivas
    final allCaps = RegExp(r'[A-Z]{3}');
    match = allCaps.firstMatch(text);
    if (match != null) {
      print('✅ Encontrado código IATA en texto: ${match.group(0)}');
      return match.group(0);
    }
    
    // Último recurso: buscar cualquier 3 letras mayúsculas
    final anyThree = RegExp(r'[A-Z][A-Z][A-Z]');
    match = anyThree.firstMatch(text);
    if (match != null) {
      print('✅ Encontrado código IATA (último recurso): ${match.group(0)}');
      return match.group(0);
    }
    
    print('❌ No se pudo extraer código IATA de: "$text"');
    print('❌ Longitud del texto: ${text.length}');
    print('❌ Caracteres del texto: ${text.codeUnits}');
    return null;
  }


  // Métodos auxiliares
  Future<void> _searchAirportsFrom(String query) async {
    setState(() {
      _showFromDropdown = true;
      _isSearchingFrom = true;
    });
    
    print('🔍 DEBUG: _showFromDropdown = $_showFromDropdown, _fromSearchResults.length = ${_fromSearchResults.length}');

    try {
      // 🎯 USAR API REAL DE DUFFEL
      print('🔍 Buscando aeropuertos "From" con Duffel API: $query');
      final results = await DuffelApiService.searchAirports(query);
      
      print('🔍 DEBUG: Resultados obtenidos: ${results.length}');
      
      setState(() {
        _fromSearchResults = results;
        _showFromDropdown = results.isNotEmpty; // Solo mostrar si hay resultados
        _isSearchingFrom = false;
      });
      
      print('🔍 DEBUG: Después del setState - _showFromDropdown = $_showFromDropdown, _fromSearchResults.length = ${_fromSearchResults.length}');
      print('✅ Encontrados ${results.length} aeropuertos "From"');
    } catch (e) {
      print('⚠️ Error searching airports From: $e');
      
      // 🚫 SIN FALLBACK SIMULADO - SOLO API REAL
      print('❌ API real no disponible - no se muestran aeropuertos falsos');
      setState(() {
        _fromSearchResults = [];
        _showFromDropdown = false;
        _isSearchingFrom = false;
      });
    }
  }

  Future<void> _searchAirportsTo(String query) async {
    setState(() {
      _showToDropdown = true;
      _isSearchingTo = true;
    });
    
    print('🔍 DEBUG: _showToDropdown = $_showToDropdown, _toSearchResults.length = ${_toSearchResults.length}');

    try {
      // 🎯 USAR API REAL DE DUFFEL
      print('🔍 Buscando aeropuertos "To" con Duffel API: $query');
      final results = await DuffelApiService.searchAirports(query);
      
      print('🔍 DEBUG: Resultados obtenidos: ${results.length}');
      
      setState(() {
        _toSearchResults = results;
        _showToDropdown = results.isNotEmpty; // Solo mostrar si hay resultados
        _isSearchingTo = false;
      });
      
      print('🔍 DEBUG: Después del setState - _showToDropdown = $_showToDropdown, _toSearchResults.length = ${_toSearchResults.length}');
      print('✅ Encontrados ${results.length} aeropuertos "To"');
    } catch (e) {
      print('⚠️ Error searching airports To: $e');
      
      // 🚫 SIN FALLBACK SIMULADO - SOLO API REAL  
      print('❌ API real no disponible - no se muestran aeropuertos falsos');
      setState(() {
        _toSearchResults = [];
        _showToDropdown = false;
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
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
                padding: EdgeInsets.all(6), // Reducido de 8 a 6
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.remove, size: 14), // Reducido de 16 a 14
              ),
            ),
            SizedBox(
              width: 32, // Reducido de 40 a 32
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14, // Reducido de 16 a 14
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
                padding: EdgeInsets.all(6), // Reducido de 8 a 6
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 14, color: Colors.white), // Reducido de 16 a 14
              ),
            ),
          ],
        ),
      ],
    );
  }
}