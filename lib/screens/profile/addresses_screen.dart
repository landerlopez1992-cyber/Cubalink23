import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/supabase_service.dart';

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

  @override
  void initState() {
    super.initState();
    print('AddressesScreen initState called');
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

    try {
      setState(() => isLoading = true);

      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final newAddress = {
        'street': _streetController.text.trim(),
        'municipality': _municipalityController.text.trim(),
        'province': _provinceController.text.trim(),
        'country': _countryController.text.trim(),
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'idDocument': _idDocumentController.text.trim(),
        'createdAt': DateTime.now(),
      };

      // Guardar en Supabase
      await SupabaseService.instance.insert('user_addresses', {
        'user_id': currentUser.id,
        'street': newAddress['street'],
        'municipality': newAddress['municipality'],
        'province': newAddress['province'],
        'country': newAddress['country'],
        'full_name': newAddress['fullName'],
        'phone': newAddress['phone'],
        'id_document': newAddress['idDocument'],
      });
      print('Address saved to Supabase successfully');

      // Recargar direcciones desde Firebase
      await _loadAddresses();

      _clearForm();
      setState(() => isAddingAddress = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Dirección guardada exitosamente'),
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

      // Eliminar de Supabase
      await SupabaseService.instance.delete('user_addresses', addressId);
      print('Address deleted from Supabase successfully');

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

  void _clearForm() {
    _streetController.clear();
    _municipalityController.clear();
    _provinceController.clear();
    _countryController.clear();
    _nameController.clear();
    _phoneController.clear();
    _idDocumentController.clear();
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

                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _municipalityController,
                                        label: 'Municipio',
                                        icon: Icons.location_city,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Requerido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _provinceController,
                                        label: 'Provincia',
                                        icon: Icons.map,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Requerido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                _buildTextField(
                                  controller: _countryController,
                                  label: 'País',
                                  icon: Icons.flag,
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
                                      child: _buildTextField(
                                        controller: _phoneController,
                                        label: 'Teléfono',
                                        icon: Icons.phone,
                                        keyboardType: TextInputType.phone,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Requerido';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _idDocumentController,
                                        label: 'Documento ID',
                                        icon: Icons.badge,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Requerido';
                                          }
                                          return null;
                                        },
                                      ),
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
                                            : const Text('Guardar'),
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
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
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
                    address['full_name'] ?? address['fullName'] ?? 'Sin nombre',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
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
}
