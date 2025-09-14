import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/flight_offer.dart';

class FlightBookingForm extends StatefulWidget {
  final FlightOffer flight;

  const FlightBookingForm({super.key, required this.flight});

  @override
  _FlightBookingFormState createState() => _FlightBookingFormState();
}

class _FlightBookingFormState extends State<FlightBookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  
  // Controladores para datos del pasajero
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _passportController = TextEditingController();
  final _nationalityController = TextEditingController();
  
  // Controladores para datos de contacto
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  
  // Variables de estado
  String _selectedGender = 'Masculino';
  String _selectedTitle = 'Sr.';
  String _selectedSeat = '';
  String _selectedCountryOfIssue = '';
  String _passportExpiryDate = '';
  String _selectedExtraBaggage = '';
  final String _selectedCabinClass = 'main_cabin';
  final String _paymentOption = 'pay_now';
  bool _acceptTerms = false;
  bool _acceptMarketing = false;
  bool _isLoading = false;
  
  // Precios adicionales
  double _seatPrice = 0.0;
  double _baggagePrice = 0.0;
  final double _cabinClassPrice = 0.0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _passportController.dispose();
    _nationalityController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar Vuelo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              if (_currentStep > 0) {
                _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Text(
              _currentStep > 0 ? 'Atrás' : '',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de progreso
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildProgressStep(0, 'Pasajero', Icons.person),
                _buildProgressLine(),
                _buildProgressStep(1, 'Contacto', Icons.contact_phone),
                _buildProgressLine(),
                _buildProgressStep(2, 'Asientos', Icons.event_seat),
                _buildProgressLine(),
                _buildProgressStep(3, 'Confirmar', Icons.check_circle),
              ],
            ),
          ),
          
          // Contenido del formulario
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildPassengerForm(),
                _buildContactForm(),
                _buildSeatSelection(),
                _buildConfirmationForm(),
              ],
            ),
          ),
          
          // Botones de navegación
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text('Anterior'),
                    ),
                  ),
                
                if (_currentStep > 0) SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep < 3 ? _nextStep : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_currentStep < 3 ? 'Siguiente' : 'Confirmar Reserva'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String title, IconData icon) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Colors.green[600] 
                  : isActive 
                      ? Colors.blue[600] 
                      : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue[600] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine() {
    return Container(
      height: 2,
      width: 20,
      color: _currentStep > 0 ? Colors.blue[600] : Colors.grey[300],
    );
  }

  Widget _buildPassengerForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del vuelo
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen del Vuelo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.flight, color: Colors.blue[600]),
                        SizedBox(width: 8),
                        Text('${widget.flight.airline} - ${widget.flight.flightNumber}'),
                        Spacer(),
                        Text(
                          widget.flight.formattedPrice,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('${widget.flight.origin} → ${widget.flight.destination}'),
                    Text('${widget.flight.formattedDepartureTime} - ${widget.flight.formattedArrivalTime}'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            Text(
              'Datos del Pasajero',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Título y género
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedTitle,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Sr.', 'Sra.', 'Dr.', 'Prof.'].map((title) {
                      return DropdownMenuItem(
                        value: title,
                        child: Text(title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTitle = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Género',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Masculino', 'Femenino', 'Otro'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Nombre y apellido
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El apellido es requerido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Email y teléfono
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El email es requerido';
                }
                if (!value.contains('@')) {
                  return 'Email inválido';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El teléfono es requerido';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // Fecha de nacimiento
            TextFormField(
              controller: _dateOfBirthController,
              decoration: InputDecoration(
                labelText: 'Fecha de Nacimiento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_month),
                  onPressed: _selectDateOfBirth,
                ),
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La fecha de nacimiento es requerida';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // Pasaporte y nacionalidad
            TextFormField(
              controller: _passportController,
              decoration: InputDecoration(
                labelText: 'Número de Pasaporte',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El pasaporte es requerido';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // País de emisión y fecha de vencimiento
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCountryOfIssue.isEmpty ? null : _selectedCountryOfIssue,
                    decoration: InputDecoration(
                      labelText: 'País de Emisión',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'Estados Unidos',
                      'Cuba',
                      'México',
                      'Canadá',
                      'España',
                      'Colombia',
                      'Venezuela',
                      'Argentina',
                      'Chile',
                      'Perú',
                      'Brasil',
                    ].map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCountryOfIssue = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'País requerido';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(text: _passportExpiryDate),
                    decoration: InputDecoration(
                      labelText: 'Fecha de Vencimiento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_month),
                        onPressed: _selectPassportExpiry,
                      ),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Fecha de vencimiento requerida';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            TextFormField(
              controller: _nationalityController,
              decoration: InputDecoration(
                labelText: 'Nacionalidad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La nacionalidad es requerida';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de Contacto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          TextFormField(
            controller: _contactEmailController,
            decoration: InputDecoration(
              labelText: 'Email de Contacto',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El email de contacto es requerido';
              }
              if (!value.contains('@')) {
                return 'Email inválido';
              }
              return null;
            },
          ),
          
          SizedBox(height: 16),
          
          TextFormField(
            controller: _contactPhoneController,
            decoration: InputDecoration(
              labelText: 'Teléfono de Contacto',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El teléfono de contacto es requerido';
              }
              return null;
            },
          ),
          
          SizedBox(height: 16),
          
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Dirección',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.home),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La dirección es requerida';
              }
              return null;
            },
          ),
          
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Ciudad',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La ciudad es requerida';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: 'País',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El país es requerido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Opciones adicionales
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opciones Adicionales',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  CheckboxListTile(
                    title: Text('Acepto recibir ofertas por email'),
                    value: _acceptMarketing,
                    onChanged: (value) {
                      setState(() {
                        _acceptMarketing = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatSelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selección de Asientos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Leyenda de asientos
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leyenda de Asientos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSeatLegend('Incluido', Colors.green, Icons.check_circle),
                      SizedBox(width: 16),
                      _buildSeatLegend('Costo Adicional', Colors.orange, Icons.attach_money),
                      SizedBox(width: 16),
                      _buildSeatLegend('Seleccionado', Colors.blue, Icons.radio_button_checked),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSeatLegend('No Disponible', Colors.red, Icons.cancel),
                      SizedBox(width: 16),
                      _buildSeatLegend('Salida de Emergencia', Colors.purple, Icons.exit_to_app),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Mapa de asientos visual
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Cabina del avión
                SizedBox(
                  height: 200,
                  child: _buildAircraftSeatMap(),
                ),
                
                SizedBox(height: 16),
                
                // Información del avión
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAircraftFeature('Salida', Icons.exit_to_app),
                    _buildAircraftFeature('Baño', Icons.wc),
                    _buildAircraftFeature('Cocina', Icons.restaurant),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Precio de asientos seleccionados
          if (_selectedSeat.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Precio por ${_getSeatCount()} asiento(s):',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _getSeatPrice(_selectedSeat),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          
          SizedBox(height: 16),
          
          // Equipaje adicional
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.luggage, color: Colors.blue[600]),
                      SizedBox(width: 8),
                      Text(
                        'Equipaje Adicional',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Agregue equipaje adicional para su viaje',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  RadioListTile<String>(
                    title: Text('Sin equipaje adicional'),
                    subtitle: Text('Solo equipaje incluido'),
                    value: 'none',
                    groupValue: _selectedExtraBaggage,
                    onChanged: (value) {
                      setState(() {
                        _selectedExtraBaggage = value!;
                        _baggagePrice = 0.0;
                      });
                    },
                  ),
                  
                  RadioListTile<String>(
                    title: Text('1 Maleta Adicional (23kg)'),
                    subtitle: Text('+ \$50 USD'),
                    value: '1_bag',
                    groupValue: _selectedExtraBaggage,
                    onChanged: (value) {
                      setState(() {
                        _selectedExtraBaggage = value!;
                        _baggagePrice = 50.0;
                      });
                    },
                  ),
                  
                  RadioListTile<String>(
                    title: Text('2 Maletas Adicionales (23kg c/u)'),
                    subtitle: Text('+ \$90 USD'),
                    value: '2_bags',
                    groupValue: _selectedExtraBaggage,
                    onChanged: (value) {
                      setState(() {
                        _selectedExtraBaggage = value!;
                        _baggagePrice = 90.0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Opciones de asientos
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipos de Asientos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  RadioListTile<String>(
                    title: Text('Asiento Estándar'),
                    subtitle: Text('Sin cargo adicional'),
                    value: 'standard',
                    groupValue: _selectedSeat,
                    onChanged: (value) {
                      setState(() {
                        _selectedSeat = value!;
                        _seatPrice = 0.0;
                      });
                    },
                  ),
                  
                  RadioListTile<String>(
                    title: Text('Asiento con Más Espacio'),
                    subtitle: Text('+ \$25 USD'),
                    value: 'extra_legroom',
                    groupValue: _selectedSeat,
                    onChanged: (value) {
                      setState(() {
                        _selectedSeat = value!;
                        _seatPrice = 25.0;
                      });
                    },
                  ),
                  
                  RadioListTile<String>(
                    title: Text('Asiento de Ventana'),
                    subtitle: Text('+ \$15 USD'),
                    value: 'window',
                    groupValue: _selectedSeat,
                    onChanged: (value) {
                      setState(() {
                        _selectedSeat = value!;
                        _seatPrice = 15.0;
                      });
                    },
                  ),
                  
                  RadioListTile<String>(
                    title: Text('Asiento de Pasillo'),
                    subtitle: Text('+ \$10 USD'),
                    value: 'aisle',
                    groupValue: _selectedSeat,
                    onChanged: (value) {
                      setState(() {
                        _selectedSeat = value!;
                        _seatPrice = 10.0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirmar Reserva',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Resumen del vuelo
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles del Vuelo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  _buildSummaryRow('Aerolínea:', widget.flight.airline),
                  _buildSummaryRow('Vuelo:', widget.flight.flightNumber),
                  _buildSummaryRow('Ruta:', '${widget.flight.origin} → ${widget.flight.destination}'),
                  _buildSummaryRow('Fecha:', '${widget.flight.formattedDepartureTime} - ${widget.flight.formattedArrivalTime}'),
                  _buildSummaryRow('Duración:', widget.flight.formattedDuration),
                  _buildSummaryRow('Pasajero:', '$_selectedTitle ${_firstNameController.text} ${_lastNameController.text}'),
                  _buildSummaryRow('Email:', _emailController.text),
                  _buildSummaryRow('Teléfono:', _phoneController.text),
                  
                  if (_selectedSeat.isNotEmpty) ...[
                    Divider(),
                    _buildSummaryRow('Asiento:', _getSeatDescription(_selectedSeat)),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Desglose de precios
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desglose de Precios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  _buildPriceRow('Tarifa base:', widget.flight.formattedPrice),
                  _buildPriceRow('Impuestos de tarifa:', '\$58.00 USD'),
                  
                  if (_selectedSeat.isNotEmpty) ...[
                    _buildPriceRow('Asiento seleccionado:', _getSeatPrice(_selectedSeat)),
                  ],
                  
                  if (_selectedExtraBaggage.isNotEmpty && _selectedExtraBaggage != 'none') ...[
                    _buildPriceRow('Equipaje adicional:', _getBaggagePrice(_selectedExtraBaggage)),
                  ],
                  
                  Divider(),
                  
                  _buildPriceRow(
                    'Total (USD):',
                    _getTotalPrice(),
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Términos y condiciones
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: Text('Acepto los términos y condiciones'),
                    subtitle: Text('He leído y acepto las políticas de la aerolínea'),
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  
                  if (!_acceptTerms)
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 8),
                      child: Text(
                        'Debe aceptar los términos y condiciones para continuar',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[800],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.blue[600] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  String _getSeatDescription(String seatType) {
    switch (seatType) {
      case 'standard':
        return 'Asiento Estándar';
      case 'extra_legroom':
        return 'Asiento con Más Espacio';
      case 'window':
        return 'Asiento de Ventana';
      default:
        return 'No seleccionado';
    }
  }

  String _getSeatPrice(String seatType) {
    switch (seatType) {
      case 'standard':
        return 'Gratis';
      case 'extra_legroom':
        return '+ \$25.00 USD';
      case 'window':
        return '+ \$15.00 USD';
      case 'aisle':
        return '+ \$10.00 USD';
      default:
        return 'Gratis';
    }
  }

  String _getBaggagePrice(String baggageType) {
    switch (baggageType) {
      case 'none':
        return 'Gratis';
      case '1_bag':
        return '+ \$50.00 USD';
      case '2_bags':
        return '+ \$90.00 USD';
      default:
        return 'Gratis';
    }
  }

  String _getTotalPrice() {
    double basePrice = double.tryParse(widget.flight.totalAmount) ?? 0.0;
    double taxes = 58.0; // Impuestos fijos como en Duffel
    double seatPrice = _seatPrice;
    double baggagePrice = _baggagePrice;
    
    double total = basePrice + taxes + seatPrice + baggagePrice;
    return '\$${total.toStringAsFixed(2)} USD';
  }

  void _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _selectPassportExpiry() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 3650)), // 10 años
    );
    
    if (picked != null) {
      setState(() {
        _passportExpiryDate = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Widget _buildSeatLegend(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 10,
          ),
        ),
        SizedBox(width: 4),
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

  Widget _buildAircraftSeatMap() {
    return Column(
      children: [
        // Filas de asientos
        ...List.generate(8, (rowIndex) {
          final rowNumber = rowIndex + 8;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Número de fila
                SizedBox(
                  width: 30,
                  child: Text(
                    '$rowNumber',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                
                // Asientos A, B
                _buildSeatButton('${rowNumber}A', rowNumber == 10 ? 'emergency' : 'available'),
                _buildSeatButton('${rowNumber}B', rowNumber == 10 ? 'emergency' : 'available'),
                
                SizedBox(width: 16), // Pasillo
                
                // Asientos C, D
                _buildSeatButton('${rowNumber}C', rowNumber == 10 ? 'emergency' : 'available'),
                _buildSeatButton('${rowNumber}D', rowNumber == 10 ? 'emergency' : 'available'),
              ],
            ),
          );
        }),
        
        SizedBox(height: 8),
        
        // Etiquetas de columnas
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 30),
            SizedBox(width: 8),
            Text('A', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Text('B', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            SizedBox(width: 16),
            Text('C', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Text('D', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildSeatButton(String seatNumber, String status) {
    Color seatColor;
    IconData? seatIcon;
    
    switch (status) {
      case 'available':
        seatColor = Colors.green[100]!;
        break;
      case 'selected':
        seatColor = Colors.blue[600]!;
        seatIcon = Icons.check;
        break;
      case 'emergency':
        seatColor = Colors.purple[100]!;
        break;
      case 'unavailable':
        seatColor = Colors.red[100]!;
        seatIcon = Icons.close;
        break;
      default:
        seatColor = Colors.grey[200]!;
    }
    
    return GestureDetector(
      onTap: status == 'available' || status == 'emergency' ? () {
        setState(() {
          // Simular selección de asiento
          _selectedSeat = seatNumber;
        });
      } : null,
      child: Container(
        width: 24,
        height: 24,
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: status == 'emergency' ? Colors.purple : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: seatIcon != null
            ? Icon(
                seatIcon,
                color: Colors.white,
                size: 12,
              )
            : Center(
                child: Text(
                  seatNumber.substring(seatNumber.length - 1),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: status == 'emergency' ? Colors.purple[700] : Colors.grey[700],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAircraftFeature(String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
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

  int _getSeatCount() {
    return 1; // Por ahora solo 1 pasajero
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitBooking() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debe aceptar los términos y condiciones'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simular proceso de reserva
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Mostrar confirmación
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('¡Reserva Confirmada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text('Su reserva ha sido confirmada exitosamente.'),
            SizedBox(height: 8),
            Text('Recibirá un email de confirmación en breve.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(); // Volver a detalles
              Navigator.of(context).pop(); // Volver a resultados
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
