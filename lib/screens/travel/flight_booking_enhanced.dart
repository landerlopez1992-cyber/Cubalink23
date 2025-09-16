import 'package:flutter/material.dart';
import '../../models/flight_offer.dart';
import '../../services/duffel_api_service.dart';
import 'seat_selection_screen.dart';
import '../payment/payment_method_screen_modern.dart';

class FlightBookingEnhanced extends StatefulWidget {
  final FlightOffer flight;

  const FlightBookingEnhanced({super.key, required this.flight});

  @override
  _FlightBookingEnhancedState createState() => _FlightBookingEnhancedState();
}

class _FlightBookingEnhancedState extends State<FlightBookingEnhanced> {
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
  // final String _selectedExtraBaggage = ''; // Removed unused variable
  String _selectedCabinClass = 'main_cabin';
  String _paymentOption = 'pay_now';
  bool _acceptTerms = false;
  bool _acceptMarketing = false;
  bool _isLoading = false;
  
  // Variable para cantidad de equipaje adicional
  int _selectedBaggage = 0;
  
  // Variables para precios
  double _seatPrice = 0.0;
  double _baggagePrice = 0.0;
  // double _cabinClassPrice = 0.0; // Removed unused variable

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
                _buildProgressStep(0, 'Cabina', Icons.flight),
                _buildProgressLine(),
                _buildProgressStep(1, 'Pasajero', Icons.person),
                _buildProgressLine(),
                _buildProgressStep(2, 'Contacto', Icons.contact_phone),
                _buildProgressLine(),
                _buildProgressStep(3, 'Asientos', Icons.event_seat),
                _buildProgressLine(),
                _buildProgressStep(4, 'Equipaje', Icons.luggage),
                _buildProgressLine(),
                _buildProgressStep(5, 'Pago', Icons.payment),
                _buildProgressLine(),
                _buildProgressStep(6, 'Confirmar', Icons.check_circle),
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
                _buildCabinSelection(),
                _buildPassengerForm(),
                _buildContactForm(),
                _buildSeatSelection(),
                _buildBaggageSelection(),
                _buildPaymentOptions(),
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
                    onPressed: _currentStep < 6 ? _nextStep : _submitBooking,
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
                        : Text(_currentStep < 6 ? 'Siguiente' : 'Confirmar Reserva'),
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
            width: 32,
            height: 32,
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
              size: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
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
      width: 16,
      color: _currentStep > 0 ? Colors.blue[600] : Colors.grey[300],
    );
  }

  Widget _buildCabinSelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
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
            'Seleccione Tipo de Cabina',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Main Cabin
          _buildCabinOption(
            'main_cabin',
            'ECONOMY Main Cabin',
            _getCabinClassPriceString('main_cabin'),
            [
              _buildPolicyIcon(Icons.check_circle, 'Cambiable', Colors.green),
              _buildPolicyIcon(Icons.cancel, 'No reembolsable', Colors.red),
              _buildPolicyIcon(Icons.schedule, 'Mantener precio y espacio', Colors.blue),
              _buildPolicyIcon(Icons.luggage, 'Incluye equipaje de mano', Colors.blue),
              _buildPolicyIcon(Icons.airport_shuttle, 'Incluye equipaje facturado', Colors.blue),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Main Cabin Flexible
          _buildCabinOption(
            'main_cabin_flexible',
            'ECONOMY Main Cabin Flexible',
            _getCabinClassPriceString('main_cabin_flexible'),
            [
              _buildPolicyIcon(Icons.check_circle, 'Cambiable', Colors.green),
              _buildPolicyIcon(Icons.check_circle, 'Reembolsable', Colors.green),
              _buildPolicyIcon(Icons.schedule, 'Mantener precio y espacio', Colors.blue),
              _buildPolicyIcon(Icons.luggage, 'Incluye equipaje de mano', Colors.blue),
              _buildPolicyIcon(Icons.airport_shuttle, 'Incluye equipaje facturado', Colors.blue),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Main Plus
          _buildCabinOption(
            'main_plus',
            'ECONOMY Main Plus',
            _getCabinClassPriceString('main_plus'),
            [
              _buildPolicyIcon(Icons.check_circle, 'Cambiable', Colors.green),
              _buildPolicyIcon(Icons.cancel, 'No reembolsable', Colors.red),
              _buildPolicyIcon(Icons.schedule, 'Mantener precio y espacio', Colors.blue),
              _buildPolicyIcon(Icons.luggage, 'Incluye equipaje de mano', Colors.blue),
              _buildPolicyIcon(Icons.airport_shuttle, 'Incluye equipaje facturado', Colors.blue),
              _buildPolicyIcon(Icons.eco, '23kg CO2', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCabinOption(String value, String title, String price, List<Widget> policies) {
    final isSelected = _selectedCabinClass == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCabinClass = value;
          // _cabinClassPrice = _getCabinClassPrice(value); // Removed unused variable
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue[600] : Colors.grey[800],
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: Colors.blue[600], size: 24),
              ],
            ),
            SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: policies,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyIcon(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
            
            // Pasaporte
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
          
          // Mapa de asientos simulado
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flight, size: 48, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Seleccionar Asiento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_selectedSeat.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Asiento: $_selectedSeat (\$${_seatPrice.toStringAsFixed(0)})',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  ElevatedButton.icon(
                    onPressed: _selectSeat,
                    icon: Icon(Icons.airline_seat_recline_normal),
                    label: Text(
                      _selectedSeat.isEmpty 
                          ? 'Seleccionar Asiento'
                          : 'Cambiar Asiento',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
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
                    'Opciones de Asientos',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaggageSelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Equipaje Adicional',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Incluye equipaje de mano y un artículo personal',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 24),
          
          // Equipaje incluido
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600]),
                      SizedBox(width: 8),
                      Text(
                        'Incluido en tu tarifa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.work_outline, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text('Equipaje de mano (10kg)'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.backpack_outlined, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text('Artículo personal (bolso/mochila)'),
                    ],
                  ),
                ],
              ),
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
                  Text(
                    'Equipaje Facturado Adicional',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Icon(Icons.remove_circle_outline, color: Colors.red[400]),
                      SizedBox(width: 16),
                      Text(
                        _selectedBaggage.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.add_circle_outline, color: Colors.green[400]),
                      SizedBox(width: 16),
                      Text('maletas'),
                      Spacer(),
                      Text(
                        '\$${(_selectedBaggage * 50).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _selectedBaggage > 0 
                            ? () {
                                setState(() {
                                  _selectedBaggage--;
                                  _baggagePrice = _selectedBaggage * 25.0; // $25 por maleta (precio real)
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(Icons.remove),
                      ),
                      
                      ElevatedButton(
                        onPressed: _selectedBaggage < 5 
                            ? () {
                                setState(() {
                                  _selectedBaggage++;
                                  _baggagePrice = _selectedBaggage * 25.0; // $25 por maleta (precio real)
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          foregroundColor: Colors.white,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  Text(
                    'Cada maleta adicional: \$25 USD (hasta 23kg)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opciones de Pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          Text(
            'Decida si desea pagar por su viaje ahora en su totalidad, o si desea mantener la reserva y pagar en una fecha posterior. Tenga en cuenta que no puede seleccionar asientos o equipaje al mantener una reserva.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Pay now
          _buildPaymentOption(
            'pay_now',
            'Pagar Ahora',
            'Pagar ahora y confirmar selección de asientos y equipaje',
            Icons.check_circle,
            Colors.green,
            true,
          ),
          
          SizedBox(height: 16),
          
          // Hold order
          _buildPaymentOption(
            'hold_order',
            'Mantener Reserva',
            'Mantener precio y espacio en este viaje y pagar en 3 días',
            Icons.schedule,
            Colors.orange,
            false,
          ),
          
          SizedBox(height: 24),
          
          // Información adicional para hold order
          if (_paymentOption == 'hold_order')
            Card(
              elevation: 2,
              color: Colors.orange[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[600]),
                        SizedBox(width: 8),
                        Text(
                          'Información Importante',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• Su reserva se mantendrá por 3 días\n• Debe completar el pago antes del vencimiento\n• No se pueden seleccionar asientos hasta el pago\n• No se puede agregar equipaje adicional hasta el pago',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
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

  Widget _buildPaymentOption(String value, String title, String description, IconData icon, Color color, bool isRecommended) {
    final isSelected = _paymentOption == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentOption = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : Colors.grey[800],
                        ),
                      ),
                      if (isRecommended) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Recomendado',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
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
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
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
                  _buildSummaryRow('Tipo de Cabina:', _getCabinClassTitle(_selectedCabinClass)),
                  _buildSummaryRow('Pasajero:', '$_selectedTitle ${_firstNameController.text} ${_lastNameController.text}'),
                  _buildSummaryRow('Email:', _emailController.text),
                  _buildSummaryRow('Teléfono:', _phoneController.text),
                  
                  if (_selectedSeat.isNotEmpty) ...[
                    Divider(),
                    _buildSummaryRow('Asiento:', _getSeatDescription(_selectedSeat)),
                  ],
                  
                  Divider(),
                  _buildSummaryRow('Opción de Pago:', _paymentOption == 'pay_now' ? 'Pagar Ahora' : 'Mantener Reserva (3 días)'),
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
                  
                  _buildPriceRow('Tipo de cabina:', _getCabinClassPriceString(_selectedCabinClass)),
                  
                  if (_selectedSeat.isNotEmpty) ...[
                    _buildPriceRow('Asiento seleccionado:', _getSeatPrice(_selectedSeat)),
                  ],
                  
                  if (_selectedBaggage > 0) ...[
                    _buildPriceRow('Equipaje adicional:', '${_selectedBaggage}x \$25.00 = \$${(_selectedBaggage * 25.0).toStringAsFixed(2)} USD'),
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

  String _getCabinClassTitle(String cabinClass) {
    switch (cabinClass) {
      case 'main_cabin':
        return 'ECONOMY Main Cabin';
      case 'main_cabin_flexible':
        return 'ECONOMY Main Cabin Flexible';
      case 'main_plus':
        return 'ECONOMY Main Plus';
      default:
        return 'ECONOMY Main Cabin';
    }
  }

  String _getCabinClassPriceString(String cabinClass) {
    // final basePrice = double.tryParse(widget.flight.totalAmount) ?? 0.0; // Removed unused variable
    final price = _getCabinClassPrice(cabinClass);
    return 'US\$${price.toStringAsFixed(2)}';
  }

  double _getCabinClassPrice(String cabinClass) {
    // Usar precio real del vuelo de Duffel como base
    final basePrice = double.tryParse(widget.flight.totalAmount) ?? 0.0;
    
    switch (cabinClass) {
      case 'main_cabin':
        return basePrice; // Precio base del vuelo
      case 'main_cabin_flexible':
        return basePrice + 45.0; // +$45 por flexibilidad
      case 'main_plus':
        return basePrice + 77.0; // +$77 por main plus
      default:
        return basePrice;
    }
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
      default:
        return 'Gratis';
    }
  }

  double _getSeatPriceValue(String seatType) {
    switch (seatType) {
      case 'standard':
        return 0.0;
      case 'extra_legroom':
        return 25.0;
      case 'window':
        return 15.0;
      default:
        return 0.0;
    }
  }

  String _getTotalPrice() {
    final cabinPrice = _getCabinClassPrice(_selectedCabinClass);
    final seatPrice = _getSeatPriceValue(_selectedSeat);
    final baggagePrice = _selectedBaggage * 25.0;
    
    final total = cabinPrice + seatPrice + baggagePrice;
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

  void _nextStep() {
    if (_currentStep == 0) {
      // Validar selección de cabina
      if (_selectedCabinClass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debe seleccionar un tipo de cabina'),
            backgroundColor: Colors.red[600],
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_formKey.currentState!.validate()) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      return;
    } else if (_currentStep == 5) {
      // Validar opción de pago
      if (_paymentOption.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debe seleccionar una opción de pago'),
            backgroundColor: Colors.red[600],
          ),
        );
        return;
      }
    }
    
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Función para seleccionar asiento
  Future<void> _selectSeat() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => SeatSelectionScreen(
          flight: widget.flight,
          passengerData: {
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSeat = result['selected_seat'] ?? '';
        _seatPrice = result['seat_price'] ?? 0.0;
      });
      print('✅ Asiento seleccionado: $_selectedSeat (\$$_seatPrice)');
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

    try {
      print('🎯 INICIANDO RESERVA REAL CON DUFFEL API');
      print('✈️ Vuelo: ${widget.flight.airline} - ${widget.flight.flightNumber}');
      print('🎫 Offer ID: ${widget.flight.id}');
      print('👤 Pasajero: $_selectedTitle ${_firstNameController.text} ${_lastNameController.text}');
      print('💳 Opción de pago: $_paymentOption');

      // Preparar datos del pasajero en formato Duffel
      final passengerData = {
        'title': _selectedTitle.toLowerCase().replaceAll('.', ''),
        'given_name': _firstNameController.text.trim(),
        'family_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'born_on': _dateOfBirthController.text,
        'gender': _selectedGender.toLowerCase().substring(0, 1), // 'm' o 'f'
        'passport_number': _passportController.text.trim(),
        'passport_country_of_issue': _selectedCountryOfIssue,
        'passport_expires_on': _passportExpiryDate,
        'nationality': _nationalityController.text.trim(),
      };

      print('👤 Datos del pasajero preparados: $passengerData');

      // FLUJO REAL: Cliente paga con Square, luego Duffel usa su propio saldo
      print('💳 Procesando pago REAL con Square...');
      
      // Calcular precio total del vuelo
      final flightPrice = _getCabinClassPrice(_selectedCabinClass);
      final seatPrice = _getSeatPriceValue(_selectedSeat);
      final baggagePrice = _selectedBaggage * 25.0; // $25 por maleta adicional
      final totalPrice = flightPrice + seatPrice + baggagePrice;
      
      // Procesar pago real con Square usando PaymentMethodScreen
      final paymentResult = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentMethodScreen(
            amount: totalPrice,
            fee: totalPrice * 0.03, // 3% comisión
            total: totalPrice * 1.03,
            metadata: {
              'service_type': 'flight',
              'description': 'Vuelo ${widget.flight.airline} ${widget.flight.flightNumber}',
              'flight_id': widget.flight.id,
              'passenger_data': passengerData,
              'selected_seat': _selectedSeat,
              'selected_baggage': _selectedBaggage,
              'cabin_class': _selectedCabinClass,
            },
          ),
        ),
      );
      
      final appPaymentSuccess = paymentResult?['success'] == true;
      
      if (appPaymentSuccess) {
        print('✅ PAGO EXITOSO CON SQUARE');
        print('💰 Cliente pagó: \$${totalPrice.toStringAsFixed(2)}');
        print('🆔 Transaction ID: ${paymentResult!['transaction_id']}');
        
        // Preparar datos de asientos seleccionados
        List<Map<String, dynamic>>? selectedSeats;
        if (_selectedSeat.isNotEmpty) {
          selectedSeats = [{
            'seat_number': _selectedSeat,
            'price': _seatPrice.toString(),
          }];
        }

        // Preparar datos de equipaje adicional
        List<Map<String, dynamic>>? selectedBaggage;
        if (_selectedBaggage > 0) {
          selectedBaggage = [{
            'quantity': _selectedBaggage,
            'price': _baggagePrice.toString(),
          }];
        }

        // Determinar método de pago según la opción seleccionada
        String paymentMethod;
        if (_paymentOption == 'pay_now') {
          paymentMethod = 'balance'; // Tu app ya cobró, usar balance de Duffel
        } else {
          paymentMethod = 'hold'; // Mantener reserva 3 días sin pago
        }

        print('📞 Solicitando a Duffel que cree la orden...');
        print('💺 Asientos: $selectedSeats');
        print('🧳 Equipaje: $selectedBaggage');
        print('💳 Método: $paymentMethod');
        
        final bookingResult = await DuffelApiService.createBooking(
          offerId: widget.flight.id,
          passengers: [passengerData],
          paymentMethod: paymentMethod,
          selectedSeats: selectedSeats,
          selectedBaggage: selectedBaggage,
        );
        
        setState(() {
          _isLoading = false;
        });
        
        if (bookingResult != null && bookingResult['success'] == true) {
          print('✅ DUFFEL CREÓ LA ORDEN (tenía saldo)');
          _showBookingSuccessDialog(bookingResult);
        } else {
          print('❌ DUFFEL NO PUDO CREAR ORDEN (sin saldo o error)');
          print('⚠️ TU APP YA COBRÓ AL CLIENTE - Revisar manualmente');
          _showDuffelErrorDialog(bookingResult);
        }
      } else {
        print('❌ PAGO FALLÓ O CANCELADO');
        setState(() {
          _isLoading = false;
        });
        
        // Si el usuario canceló el pago, no mostrar error
        if (paymentResult == null) {
          print('ℹ️ Usuario canceló el pago');
        } else {
          _showBookingErrorDialog({'message': paymentResult['error'] ?? 'El pago no pudo ser procesado'});
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      print('❌ EXCEPCIÓN EN RESERVA: $e');
      _showBookingErrorDialog({'error': e.toString()});
    }
  }

  void _showBookingSuccessDialog(Map<String, dynamic> bookingResult) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_paymentOption == 'pay_now' ? '¡Reserva Confirmada!' : '¡Reserva Mantenida!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _paymentOption == 'pay_now' ? Icons.check_circle : Icons.schedule,
              color: _paymentOption == 'pay_now' ? Colors.green : Colors.orange,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              _paymentOption == 'pay_now' 
                  ? 'Su reserva ha sido confirmada exitosamente.'
                  : 'Su reserva se ha mantenido por 3 días.',
            ),
            SizedBox(height: 8),
            Text(
              'Referencia: ${bookingResult['booking_reference'] ?? 'N/A'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _paymentOption == 'pay_now'
                  ? 'Recibirá un email de confirmación en breve.'
                  : 'Debe completar el pago antes del vencimiento.',
            ),
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

  void _showBookingErrorDialog(Map<String, dynamic>? errorResult) {
    final errorMessage = errorResult?['message'] ?? 'Error desconocido al crear la reserva';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error en la Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(errorMessage),
            if (errorResult?['error'] != null) ...[
              SizedBox(height: 8),
              Text(
                'Detalles: ${errorResult!['error']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showDuffelErrorDialog(Map<String, dynamic>? errorResult) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Problema con Duffel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber,
              color: Colors.orange,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'El pago fue procesado exitosamente en tu app.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Sin embargo, Duffel no pudo crear la orden (posiblemente sin saldo).',
            ),
            SizedBox(height: 8),
            Text(
              'Por favor, revisa tu panel de Duffel y procesa manualmente.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (errorResult?['message'] != null) ...[
              SizedBox(height: 8),
              Text(
                'Error: ${errorResult!['message']}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red[600],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Volver a detalles
            },
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
