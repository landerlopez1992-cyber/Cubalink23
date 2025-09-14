import 'package:flutter/material.dart';

class RentaCarScreen extends StatefulWidget {
  const RentaCarScreen({super.key});

  @override
  _RentaCarScreenState createState() => _RentaCarScreenState();
}

class _RentaCarScreenState extends State<RentaCarScreen> {
  String _selectedCategory = 'Autos';
  String _selectedProvince = 'La Habana';
  String _selectedPickupOffice = 'Vedado';
  String _selectedDeliveryOffice = 'Vedado';
  DateTime? _pickupDate;
  DateTime? _returnDate;
  int _passengers = 1;

  final List<String> _categories = [
    'Autos',
    'Autos de Lujo',
    'Motos',
    'Shuttle',
    'Bus Tour',
    'Autos Eléctricos',
    'Ecotur Safari',
  ];

  final List<String> _provinces = [
    'La Habana',
    'Varadero',
    'Trinidad',
    'Santiago de Cuba',
    'Camagüey',
    'Holguín',
    'Cienfuegos',
    'Pinar del Río',
    'Matanzas',
    'Villa Clara',
    'Sancti Spíritus',
    'Ciego de Ávila',
    'Las Tunas',
    'Granma',
    'Guantánamo',
    'Isla de la Juventud',
  ];

  final Map<String, List<String>> _offices = {
    'La Habana': ['Vedado', 'Habana Vieja', 'Playa', 'Aeropuerto José Martí'],
    'Varadero': ['Centro', 'Marina', 'Aeropuerto Juan Gualberto Gómez'],
    'Trinidad': ['Centro Histórico', 'Playa Ancón'],
    'Santiago de Cuba': ['Centro', 'Aeropuerto Antonio Maceo'],
    'Camagüey': ['Centro', 'Aeropuerto Ignacio Agramonte'],
    'Holguín': ['Centro', 'Aeropuerto Frank País'],
    'Cienfuegos': ['Punta Gorda', 'Hotel Unión', 'Aeropuerto Cienfuegos', 'Aguada'],
    'Pinar del Río': ['Centro', 'Viñales'],
    'Matanzas': ['Centro', 'Varadero'],
    'Villa Clara': ['Centro', 'Aeropuerto Abel Santamaría'],
    'Sancti Spíritus': ['Centro', 'Trinidad'],
    'Ciego de Ávila': ['Centro', 'Cayo Coco'],
    'Las Tunas': ['Centro'],
    'Granma': ['Centro', 'Bayamo'],
    'Guantánamo': ['Centro', 'Baracoa'],
    'Isla de la Juventud': ['Nueva Gerona'],
  };

  final Map<String, List<Map<String, dynamic>>> _carTypes = {
    'Autos': [
      {'name': 'Económico Manual', 'price': '\$107.00', 'features': ['Transmisión Manual', 'A/C', 'Radio', '4 puertas']},
      {'name': 'Económico Automático', 'price': '\$113.00', 'features': ['Transmisión Automática', 'A/C', 'Radio', '4 puertas']},
      {'name': 'Medio Automático', 'price': '\$105.00', 'features': ['Transmisión Automática', 'A/C', 'Radio', '4 puertas', 'GPS']},
      {'name': 'SUV Automático', 'price': '\$152.00', 'features': ['Transmisión Automática', 'A/C', 'Radio', '5 puertas', 'GPS', '4x4']},
    ],
    'Autos de Lujo': [
      {'name': 'Sedán Premium', 'price': '\$180.00', 'features': ['Transmisión Automática', 'A/C', 'Radio Premium', 'Cuero', 'GPS']},
      {'name': 'SUV Premium', 'price': '\$220.00', 'features': ['Transmisión Automática', 'A/C', 'Radio Premium', 'Cuero', 'GPS', '4x4']},
      {'name': 'Convertible', 'price': '\$250.00', 'features': ['Transmisión Automática', 'A/C', 'Radio Premium', 'Cuero', 'GPS', 'Techo']},
    ],
    'Motos': [
      {'name': 'Scooter 125cc', 'price': '\$45.00', 'features': ['Casco incluido', 'Seguro', 'Automática']},
      {'name': 'Moto 250cc', 'price': '\$65.00', 'features': ['Casco incluido', 'Seguro', 'GPS', 'Manual']},
      {'name': 'Moto 400cc', 'price': '\$85.00', 'features': ['Casco incluido', 'Seguro', 'GPS', 'Manual']},
    ],
    'Shuttle': [
      {'name': 'Shuttle Compartido', 'price': '\$25.00', 'features': ['A/C', 'WiFi', 'Horarios fijos', 'Rutas Vedado/Habana Vieja/Playa']},
    ],
    'Bus Tour': [
      {'name': 'City Tour', 'price': '\$35.00', 'features': ['Guía turístico', 'A/C', 'WiFi', 'Vistas panorámicas']},
      {'name': 'Tour Panorámico', 'price': '\$45.00', 'features': ['Guía turístico', 'A/C', 'WiFi', 'Vistas', 'Información detallada']},
    ],
    'Autos Eléctricos': [
      {'name': 'Eco Compacto', 'price': '\$120.00', 'features': ['100% Eléctrico', 'A/C', 'GPS', 'Carga rápida', 'Automático']},
      {'name': 'Eco SUV', 'price': '\$160.00', 'features': ['100% Eléctrico', 'A/C', 'GPS', '4x4', 'Carga rápida', 'Automático']},
    ],
    'Ecotur Safari': [
      {'name': 'Safari 4x4', 'price': '\$180.00', 'features': ['4x4', 'Aventura', 'Naturaleza', 'Guía especializado', 'Manual']},
      {'name': 'Eco Adventure', 'price': '\$200.00', 'features': ['4x4', 'Aventura', 'Naturaleza', 'Guía especializado', 'Automático']},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 0,
        title: Text(
          'Renta Car Cuba',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // TODO: Mostrar ayuda
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner principal
            _buildMainBanner(),
            SizedBox(height: 24),
            
            // Categorías
            _buildCategorySelector(),
            SizedBox(height: 24),
            
            // Formulario de reserva
            _buildReservationForm(),
            SizedBox(height: 24),
            
            // Tipos de vehículos disponibles
            _buildVehicleTypes(),
            SizedBox(height: 24),
            
            // Información adicional
            _buildAdditionalInfo(),
            SizedBox(height: 100), // Padding para evitar barra de navegación
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildMainBanner() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[600]!, Colors.blue[400]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.directions_car,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Encuentra tu auto ideal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Para unas vacaciones inolvidables con Transtur',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Disponible: Diciembre 2024 - Junio 2025',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría de Vehículo - Transtur',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return Container(
                margin: EdgeInsets.only(right: 12),
                child: Material(
                  color: isSelected ? Colors.blue[600] : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReservationForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos de Reserva',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          
          // Provincia
          _buildDropdownField(
            'Provincia',
            _selectedProvince,
            _provinces,
            (value) {
              setState(() {
                _selectedProvince = value!;
                _selectedPickupOffice = _offices[value]?.first ?? '';
                _selectedDeliveryOffice = _offices[value]?.first ?? '';
              });
            },
            Icons.location_city,
          ),
          SizedBox(height: 16),
          
          // Oficina de Recogida
          _buildDropdownField(
            'Lugar de Recogida',
            _selectedPickupOffice,
            _offices[_selectedProvince] ?? [],
            (value) => setState(() => _selectedPickupOffice = value!),
            Icons.location_on,
          ),
          SizedBox(height: 16),
          
          // Oficina de Entrega
          _buildDropdownField(
            'Lugar de Entrega',
            _selectedDeliveryOffice,
            _offices[_selectedProvince] ?? [],
            (value) => setState(() => _selectedDeliveryOffice = value!),
            Icons.location_off,
          ),
          SizedBox(height: 16),
          
          // Fechas
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  'Fecha de Recogida',
                  _pickupDate,
                  Icons.calendar_today,
                  () => _selectDate(context, true),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  'Fecha de Devolución',
                  _returnDate,
                  Icons.calendar_today,
                  () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Pasajeros
          _buildPassengerSelector(),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue[600]),
              border: InputBorder.none,
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue[600]),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null 
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Seleccionar fecha',
                    style: TextStyle(
                      color: date != null ? Colors.grey[800] : Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pasajeros',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.blue[600]),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$_passengers ${_passengers == 1 ? 'pasajero' : 'pasajeros'}',
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _passengers > 1 ? () => setState(() => _passengers--) : null,
                    icon: Icon(Icons.remove_circle_outline, color: Colors.blue[600]),
                  ),
                  Text(
                    '$_passengers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    onPressed: _passengers < 8 ? () => setState(() => _passengers++) : null,
                    icon: Icon(Icons.add_circle_outline, color: Colors.blue[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTypes() {
    final vehicles = _carTypes[_selectedCategory] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehículos Disponibles - $_selectedCategory',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return _buildVehicleCard(vehicle);
          },
        ),
      ],
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _selectedCategory == 'Motos' ? Icons.motorcycle : Icons.directions_car,
              size: 40,
              color: Colors.blue[600],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  vehicle['price'] + ' /día',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: (vehicle['features'] as List<String>).map((feature) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Implementar selección de vehículo
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Seleccionar',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text(
                'Información Importante',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildInfoItem('• Licencia de conducir válida requerida'),
          _buildInfoItem('• Tarjeta de crédito para garantía'),
          _buildInfoItem('• Seguro incluido en todos los vehículos'),
          _buildInfoItem('• Combustible: Entrega con tanque lleno'),
          _buildInfoItem('• Cancelación gratuita hasta 24h antes'),
          SizedBox(height: 12),
          if (_selectedCategory == 'Shuttle')
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horarios Shuttle:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('• Vedado: 9:40 AM - 10:40 PM'),
                  Text('• Habana Vieja: 9:55 AM - 10:55 PM'),
                  Text('• Playa: 9:30 AM - 10:35 PM'),
                ],
              ),
            ),
          if (_selectedProvince == 'Cienfuegos')
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oficinas en Cienfuegos:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('• Punta Gorda: Calle 37 y Ave. 18'),
                  Text('• Hotel Unión: Ave. 133 entre 54 y 56'),
                  Text('• Aeropuerto Cienfuegos: Carretera Cumanayagua, Km 3'),
                  Text('• Aguada: Autopista Nacional Km 172'),
                ],
              ),
            ),
          if (_selectedCategory == 'Ecotur Safari')
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ecotur Safari 4x4:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('• Aventura única en la naturaleza'),
                  Text('• Descubre la belleza de Cuba'),
                  Text('• Guía especializado incluido'),
                  Text('• Vehículos 4x4 para terrenos difíciles'),
                  Text('• Más información: https://ecotur.travel'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implementar búsqueda
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.blue[600]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Buscar Disponibilidad',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar reserva directa
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Reservar Ahora',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isPickup) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPickup ? (_pickupDate ?? DateTime.now()) : (_returnDate ?? DateTime.now().add(Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }
}
