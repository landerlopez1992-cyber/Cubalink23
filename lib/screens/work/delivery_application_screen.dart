import 'package:flutter/material.dart';

class DeliveryApplicationScreen extends StatefulWidget {
  const DeliveryApplicationScreen({super.key});

  @override
  _DeliveryApplicationScreenState createState() => _DeliveryApplicationScreenState();
}

class _DeliveryApplicationScreenState extends State<DeliveryApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _availabilityController = TextEditingController();
  
  // Selectores
  String _selectedVehicleType = '';
  final List<String> _selectedProvinces = [];
  
  // Lista de tipos de vehículos
  final List<String> _vehicleTypes = [
    'Bicicleta',
    'Moto',
    'Auto',
    'Camión',
    'A pie'
  ];
  
  // Lista de provincias de Cuba
  final List<String> _provinces = [
    'La Habana',
    'Santiago de Cuba',
    'Camagüey',
    'Holguín',
    'Villa Clara',
    'Granma',
    'Pinar del Río',
    'Matanzas',
    'Cienfuegos',
    'Las Tunas',
    'Artemisa',
    'Mayabeque',
    'Sancti Spíritus',
    'Ciego de Ávila',
    'Guantánamo',
    'Isla de la Juventud'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Aplicación Repartidor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFFFF9800),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con logo
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFF9800),
                        Color(0xFFFFB74D),
                        Color(0xFFFFCC80),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Logo
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.asset(
                          'assets/images/assets_task_01k3m7yveaebmtdrdnybpe7ngv_1756247471_img_1.webp',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'CubaLink23',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '🚚 Repartidor en CubaLink23',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Gana dinero repartiendo en tu provincia',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              
                SizedBox(height: 20),
                
                // Información personal
                _buildSectionTitle('Información Personal'),
                SizedBox(height: 12),
                
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre Completo',
                  hint: 'Ingresa tu nombre completo',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'tu@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor ingresa un email válido';
                    }
                    return null;
                  },
                ),
                
                _buildTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  hint: '+1 561 593 6776',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu teléfono';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 20),
                
                // Información del vehículo
                _buildSectionTitle('Información del Vehículo'),
                SizedBox(height: 12),
                
                // Selector de tipo de vehículo
                _buildVehicleTypeSelector(),
                
                _buildTextField(
                  controller: _licenseController,
                  label: 'Licencia de Conducir',
                  hint: 'Número de licencia',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu licencia';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 20),
                
                // Disponibilidad
                _buildSectionTitle('Disponibilidad'),
                SizedBox(height: 12),
                
                _buildTextField(
                  controller: _availabilityController,
                  label: 'Horarios Disponibles',
                  hint: 'Ej: Lunes a Viernes 9:00-17:00',
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu disponibilidad';
                    }
                    return null;
                  },
                ),
                
                // Selector de provincias de entrega
                _buildProvincesSelector(),
                
                SizedBox(height: 30),
                
                // Botón de envío
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF9800),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Enviar Aplicación',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Información del proceso
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFFFF9800).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFFFF9800),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Proceso de Aprobación',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Revisaremos tu aplicación en 2-3 días hábiles\n2. Si eres aprobado, se activará automáticamente tu panel de REPARTIDOR en "Mi Cuenta"\n3. Podrás comenzar a repartir inmediatamente\n4. Si eres desaprobado, recibirás una notificación en la campanita',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFF9800),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFFF9800), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVehicleTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Vehículo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedVehicleType.isEmpty ? null : _selectedVehicleType,
              hint: Text(
                'Selecciona tu tipo de vehículo',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
              items: _vehicleTypes.map((String vehicleType) {
                return DropdownMenuItem<String>(
                  value: vehicleType,
                  child: Text(
                    vehicleType,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedVehicleType = newValue ?? '';
                });
              },
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProvincesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provincias donde está disponible para entregar',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _provinces.map((province) {
              final isSelected = _selectedProvinces.contains(province);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedProvinces.remove(province);
                    } else {
                      _selectedProvinces.add(province);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFFF9800) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Color(0xFFFF9800) : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      if (isSelected) SizedBox(width: 4),
                      Text(
                        province,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _submitApplication() {
    if (_formKey.currentState!.validate()) {
      if (_selectedVehicleType.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor selecciona tu tipo de vehículo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_selectedProvinces.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor selecciona al menos una provincia de entrega'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Aquí se enviaría la aplicación al backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aplicación enviada exitosamente'),
          backgroundColor: Color(0xFFFF9800),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
