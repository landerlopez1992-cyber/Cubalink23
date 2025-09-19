import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/data/cuba_locations.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  _AddressesScreenState createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _countryController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idDocumentController = TextEditingController();

  List<Map<String, dynamic>> addresses = [];
  bool isLoading = false;
  bool isAddingAddress = false;
  String? editingAddressId; // ✅ NUEVA VARIABLE para saber si estamos editando
  
  // Variables para selectores de Cuba
  String? selectedProvince;
  String? selectedMunicipality;
  List<String> availableMunicipalities = [];

  @override
  void initState() {
    super.initState();
    print('AddressesScreen initState called');
    _countryController.text = 'Cuba'; // ✅ País fijo
    _loadAddresses();
  }

  // ELIMINADO: No crear direcciones de muestra automáticamente

  Future<void> _loadAddresses() async {
    try {
      print('=== LOADING ADDRESSES ===');
      setState(() => isLoading = true);

      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser == null) {
        print('❌ No current user found');
        setState(() => isLoading = false);
        return;
      }

      print('👤 Current user: ${currentUser.id}');

      // Cargar direcciones reales del usuario desde Supabase
      final userAddresses = await SupabaseService.instance.select(
        'user_addresses',
        where: 'user_id',
        equals: currentUser.id,
        orderBy: 'created_at',
        ascending: false,
      );
      print('📍 Addresses loaded from Supabase: ${userAddresses.length}');

      // Log cada dirección cargada
      for (final address in userAddresses) {
        print(
            '   📋 Address: ${address['full_name'] ?? address['fullName']} - ${address['municipality']}, ${address['province']}');
      }

      if (mounted) {
        setState(() {
          addresses = userAddresses;
          isLoading = false;
        });
        print('✅ STATE UPDATED - Addresses in widget: ${addresses.length}');
      }

      print('=== ADDRESS LOADING COMPLETE ===');
    } catch (e) {
      print('❌ ERROR LOADING ADDRESSES: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error cargando direcciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validar selectores
    if (selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una provincia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (selectedMunicipality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un municipio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final newAddress = {
        'street': _streetController.text.trim(),
        'municipality': selectedMunicipality ?? '',
        'province': selectedProvince ?? '',
        'country': _countryController.text.trim(),
        'fullName': _nameController.text.trim(),
        'phone': '+53${_phoneController.text.trim()}', // ✅ Formato cubano
        'idDocument': _idDocumentController.text.trim(),
        'createdAt': DateTime.now(),
      };

      final addressData = {
        'user_id': currentUser.id,
        'name': newAddress['fullName'], // ✅ NOMBRE COMPLETO
        'address_line_1': newAddress['street'], // ✅ DIRECCIÓN
        'address_line_2': '${selectedMunicipality ?? ''} - ${newAddress['idDocument'] ?? ''}', // ✅ MUNICIPIO + ID
        'city': selectedMunicipality ?? '', // ✅ MUNICIPIO COMO CIUDAD
        'province': newAddress['province'],
        'country': newAddress['country'],
        'phone': newAddress['phone'],
        'municipality': selectedMunicipality, // ✅ MUNICIPIO SEPARADO
        'id_document': newAddress['idDocument'], // ✅ DOCUMENTO SEPARADO
        'is_default': false,
      };

      if (editingAddressId != null) {
        // ✅ ACTUALIZAR dirección existente
        print('🔄 Actualizando dirección: $editingAddressId');
        await SupabaseService.instance.update('user_addresses', editingAddressId!, addressData);
        print('✅ Dirección actualizada exitosamente');
      } else {
        // ✅ CREAR nueva dirección
        print('🆕 Creando nueva dirección');
        await SupabaseService.instance.insert('user_addresses', addressData);
        print('✅ Nueva dirección creada exitosamente');
      }

      // Recargar direcciones
      await _loadAddresses();
      _clearForm();
      setState(() {
        isAddingAddress = false;
        editingAddressId = null; // ✅ LIMPIAR MODO EDICIÓN
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(editingAddressId != null ? '✅ Dirección actualizada exitosamente' : '✅ Dirección guardada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error guardando dirección: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      setState(() => isLoading = true);

      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Eliminar de Supabase - MÉTODO CORREGIDO
      print('🗑️ Eliminando dirección: $addressId');
      await SupabaseService.instance.delete('user_addresses', addressId);
      print('✅ Dirección eliminada de Supabase');

      // Recargar direcciones desde Firebase
      await _loadAddresses();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Dirección eliminada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error eliminando dirección: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _editAddress(Map<String, dynamic> address) {
    try {
      print('🔧 Editando dirección: $address');
      
      // Cargar datos de la dirección en el formulario - CON VALIDACIÓN
      _nameController.text = address['name']?.toString() ?? '';
      _streetController.text = address['address_line_1']?.toString() ?? '';
      
      // Limpiar teléfono de +53 si existe
      String phone = address['phone']?.toString() ?? '';
      if (phone.startsWith('+53')) {
        phone = phone.substring(3);
      }
      _phoneController.text = phone;
      
      _idDocumentController.text = address['id_document']?.toString() ?? '';
      _countryController.text = address['country']?.toString() ?? 'Cuba';
      
      // Cargar provincia y municipio en selectores - CON VALIDACIÓN
      String? province = address['province']?.toString();
      String? municipality = address['municipality']?.toString() ?? address['city']?.toString();
      
        setState(() {
          selectedProvince = province;
          if (selectedProvince != null && selectedProvince!.isNotEmpty) {
            availableMunicipalities = CubaLocations.getMunicipalities(selectedProvince!);
            selectedMunicipality = municipality;
          } else {
            availableMunicipalities = [];
            selectedMunicipality = null;
          }
          isAddingAddress = true; // Mostrar formulario
          editingAddressId = address['id']?.toString(); // ✅ GUARDAR ID PARA EDITAR
        });
      
      print('✅ Dirección cargada en formulario');
    } catch (e) {
      print('❌ Error cargando dirección para editar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando dirección: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _streetController.clear();
    _municipalityController.clear();
    _provinceController.clear();
    _countryController.clear();
    _nameController.clear();
    _phoneController.clear();
    _idDocumentController.clear();
    
    // Limpiar selectores y modo edición
    setState(() {
      selectedProvince = null;
      selectedMunicipality = null;
      availableMunicipalities = [];
      editingAddressId = null; // ✅ LIMPIAR MODO EDICIÓN
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Mis Direcciones',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isAddingAddress)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => setState(() => isAddingAddress = true),
            ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Botón Agregar dirección siempre visible al inicio
                    if (!isAddingAddress && addresses.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => isAddingAddress = true),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Nueva Dirección'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                    // Formulario para agregar nueva dirección
                    if (isAddingAddress) ...[
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Agregar Nueva Dirección',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Campos del formulario
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Nombre y Apellidos',
                                  icon: Icons.person,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El nombre es requerido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

                                _buildTextField(
                                  controller: _streetController,
                                  label: 'Calle',
                                  icon: Icons.home,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'La calle es requerida';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Selector de Provincia
                                _buildProvinceSelector(),
                                const SizedBox(height: 12),
                                
                                // Selector de Municipio
                                _buildMunicipalitySelector(),
                                const SizedBox(height: 12),

                                _buildTextField(
                                  controller: _countryController,
                                  label: 'País',
                                  icon: Icons.flag,
                                  readOnly: true, // ✅ Solo lectura - Cuba fijo
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El país es requerido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildCubanPhoneField(),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDocumentField(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Botones
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          _clearForm();
                                          setState(() => isAddingAddress = false);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Cancelar'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : _saveAddress,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(editingAddressId != null ? 'Actualizar' : 'Guardar'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Lista de direcciones guardadas
                    if (addresses.isNotEmpty) ...[
                      Text(
                        'Direcciones Guardadas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...addresses.map((address) => _buildAddressCard(address)),
                    ] else if (!isAddingAddress && addresses.isEmpty) ...[
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            Icon(
                              Icons.location_off,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tienes direcciones guardadas',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => setState(() => isAddingAddress = true),
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar Primera Dirección'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address['name'] ?? address['full_name'] ?? address['fullName'] ?? 'Sin nombre',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _editAddress(address),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _showDeleteDialog(address),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildAddressRow(Icons.home, address['street'] ?? ''),
            _buildAddressRow(Icons.location_city, '${address['municipality']}, ${address['province']}'),
            _buildAddressRow(Icons.flag, address['country'] ?? ''),
            _buildAddressRow(Icons.phone, address['phone'] ?? ''),
            _buildAddressRow(Icons.badge, address['id_document'] ?? address['idDocument'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Dirección'),
        content: const Text('¿Estás seguro de que deseas eliminar esta dirección?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAddress(address['id'] ?? '');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streetController.dispose();
    _municipalityController.dispose();
    _provinceController.dispose();
    _countryController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _idDocumentController.dispose();
    super.dispose();
  }

  // ========================== SELECTORES DE CUBA ==========================
  
  Widget _buildProvinceSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.map, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedProvince,
                hint: const Text('Seleccionar Provincia'),
                isExpanded: true,
                items: CubaLocations.provinces.map((String province) {
                  return DropdownMenuItem<String>(
                    value: province,
                    child: Text(province),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProvince = newValue;
                    selectedMunicipality = null; // Reset municipality
                    availableMunicipalities = newValue != null 
                        ? CubaLocations.getMunicipalities(newValue) 
                        : [];
                    _provinceController.text = newValue ?? '';
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMunicipalitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.location_city, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMunicipality,
                hint: Text(selectedProvince == null 
                    ? 'Primero selecciona una provincia' 
                    : 'Seleccionar Municipio'),
                isExpanded: true,
                items: availableMunicipalities.map((String municipality) {
                  return DropdownMenuItem<String>(
                    value: municipality,
                    child: Text(municipality),
                  );
                }).toList(),
                onChanged: selectedProvince == null ? null : (String? newValue) {
                  setState(() {
                    selectedMunicipality = newValue;
                    _municipalityController.text = newValue ?? '';
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCubanPhoneField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.phone, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '+53',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8), // Exactamente 8 dígitos
              ],
              decoration: const InputDecoration(
                hintText: '12345678',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Teléfono requerido';
                }
                if (value.length != 8) {
                  return 'Debe tener 8 dígitos';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.badge, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _idDocumentController,
              keyboardType: TextInputType.number, // ✅ Solo números
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // ✅ Solo dígitos
                LengthLimitingTextInputFormatter(11), // ✅ Exactamente 11 dígitos
              ],
              decoration: const InputDecoration(
                hintText: '12345678901',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Documento requerido';
                }
                if (value.length != 11) {
                  return 'Debe tener 11 dígitos';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
