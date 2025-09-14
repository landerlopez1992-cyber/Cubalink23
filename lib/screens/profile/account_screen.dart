import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cubalink23/services/auth_service_bypass.dart';
import 'package:cubalink23/services/user_role_service.dart';
import 'package:cubalink23/services/profile_image_service.dart';
import 'package:cubalink23/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cubalink23/screens/profile/addresses_screen.dart';
import 'package:cubalink23/screens/profile/order_tracking_screen.dart';
import 'package:cubalink23/screens/wallet/saved_cards_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  User? currentUser;
  bool isLoading = false;
  String? profileImagePath; // Ruta local como fallback
  String? profileImageUrl; // URL de Supabase Storage
  final ImagePicker _picker = ImagePicker();
  final UserRoleService _roleService = UserRoleService();
  final ProfileImageService _profileImageService = ProfileImageService.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      // Cargar datos reales desde Supabase
      await AuthServiceBypass.instance.loadCurrentUserFromLocal();
      final user = AuthServiceBypass.instance.getCurrentUser();

      if (user != null && mounted) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phone;
          currentUser = user;
        });

        // Cargar foto de perfil desde Supabase primero
        profileImageUrl = await _profileImageService.getProfileImageUrl(user.id);

        // Cargar datos de rol del usuario
        await _roleService.initialize();
        await _roleService.getUserByEmail(user.email);

        // Cargar foto de perfil local como fallback si no hay en Supabase
        if (profileImageUrl == null) {
          await _loadLocalProfileImage(user.id);
        }

        if (mounted) {
          setState(() {}); // Actualizar UI con datos de rol
        }
      } else if (mounted) {
        // Si no hay usuario, redirigir al login
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        // En caso de error, también redirigir al login
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Mi Cuenta',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20), // Padding inferior para evitar barra de navegación
                child: Column(
                  children: [
                    // Header con gradiente - Optimizado para Motorola Edge 2024
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20), // Reducido de 32 a 20
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.tertiary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Foto de perfil circular (táctil) - Optimizada para Motorola
                          GestureDetector(
                            onTap: _changeProfileImage,
                            child: Container(
                              width: 100, // Reducido de 120 a 100
                              height: 100, // Reducido de 120 a 100
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 46, // Reducido de 56 a 46
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: _getProfileImage(),
                                  ),
                                  // Icono de cámara - Optimizado para Motorola
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 30, // Reducido de 36 a 30
                                      height: 30, // Reducido de 36 a 30
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16, // Reducido de 18 a 16
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12), // Reducido de 16 a 12
                          Text(
                            _roleService.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20, // Reducido de 24 a 20
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _emailController.text,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14, // Reducido de 16 a 14
                            ),
                          ),
                          if (_roleService.currentUserRole != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _roleService.roleDisplayText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Formulario de datos - Optimizado para Motorola
                    Padding(
                      padding: const EdgeInsets.all(16), // Reducido de 24 a 16
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información Personal',
                              style: TextStyle(
                                fontSize: 18, // Reducido de 20 a 18
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16), // Reducido de 24 a 16

                            // Campo Nombre completo
                            _buildTextField(
                              controller: _nameController,
                              label: 'Nombre completo',
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El nombre es requerido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12), // Reducido de 16 a 12

                            // Campo Email
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El email es requerido';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Email inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12), // Reducido de 16 a 12

                            // Campo Teléfono
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Teléfono',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  // Validar formato básico de teléfono (puede tener + al inicio, espacios, guiones, paréntesis)
                                  if (!RegExp(r'^[\+]?[0-9\s\-\(\)]+$').hasMatch(value)) {
                                    return 'Formato de teléfono inválido';
                                  }
                                  // Verificar que tenga al menos 8 dígitos (sin contar caracteres especiales)
                                  final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                                  if (digitsOnly.length < 8) {
                                    return 'Teléfono debe tener al menos 8 dígitos';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20), // Reducido de 32 a 20

                            // Botón Actualizar Perfil
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: isLoading
                                    ? const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Guardando...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'Actualizar Perfil',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20), // Reducido de 32 a 20

                            // Sección Opciones de Cuenta
                            Text(
                              'Opciones de Cuenta',
                              style: TextStyle(
                                fontSize: 18, // Reducido de 20 a 18
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8), // Reducido de 12 a 8 para subir botón cerrar sesión

                            // Lista de opciones
                            _buildOptionTile(
                              icon: Icons.location_on,
                              title: 'Mis Direcciones',
                              subtitle: 'Gestiona tus direcciones guardadas',
                              onTap: _goToAddresses,
                            ),
                            _buildOptionTile(
                              icon: Icons.credit_card,
                              title: 'Mis Tarjetas Guardadas',
                              subtitle: 'Administra tus métodos de pago',
                              onTap: _goToSavedCards,
                            ),
                            _buildOptionTile(
                              icon: Icons.history,
                              title: 'Transacciones Historial',
                              subtitle: 'Ver historial completo de transacciones',
                              onTap: _goToTransactionHistory,
                            ),
                            _buildOptionTile(
                              icon: Icons.chat,
                              title: 'Soporte Chat',
                              subtitle: 'Contacta con nuestro equipo de soporte',
                              onTap: _goToSupportChat,
                            ),
                            _buildOptionTile(
                              icon: Icons.local_shipping,
                              title: 'Rastreo de Mi Orden',
                              subtitle: 'Rastrea el estado de tus pedidos',
                              onTap: _goToOrderTracking,
                            ),
                            _buildOptionTile(
                              icon: Icons.lock,
                              title: 'Cambiar Contraseña',
                              subtitle: 'Actualiza tu contraseña de acceso',
                              onTap: _changePassword,
                            ),

                            // Botones de acceso a paneles según rol
                            if (_roleService.isVendor)
                              _buildOptionTile(
                                icon: Icons.store,
                                title: 'Panel de Vendedor',
                                subtitle: 'Gestiona tus productos y ventas',
                                onTap: _goToVendorPanel,
                                color: const Color(0xFF2E7D32), // Verde para vendedor
                              ),

                            if (_roleService.isDelivery)
                              _buildOptionTile(
                                icon: Icons.local_shipping,
                                title: 'Panel de Repartidor',
                                subtitle: 'Gestiona tus entregas y pedidos',
                                onTap: _goToDeliveryPanel,
                                color: const Color(0xFF1976D2), // Azul para repartidor
                              ),

                            if (_roleService.isAdmin)
                              _buildOptionTile(
                                icon: Icons.admin_panel_settings,
                                title: 'Panel de Administrador',
                                subtitle: 'Acceso completo al sistema',
                                onTap: _goToAdminPanel,
                                color: const Color(0xFF7B1FA2), // Púrpura para admin
                              ),

                            const SizedBox(height: 8), // Reducido de 16 a 8 para subir botón cerrar sesión

                            // Botón Cerrar Sesión
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _logout,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Cerrar Sesión',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate() && currentUser != null) {
      try {
        setState(() => isLoading = true);

        // Actualizar usuario real en Firebase
        final updatedUser = User(
          id: currentUser!.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          balance: currentUser!.balance,
          createdAt: currentUser!.createdAt,
        );

        // Guardar en Supabase
        await AuthServiceBypass.instance.updateUserProfile(
          name: updatedUser.name,
          phone: updatedUser.phone,
        );

        setState(() {
          currentUser = updatedUser;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Perfil actualizado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('Error updating profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error actualizando perfil: ${e.toString()}'),
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
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4), // Reducido de 8 a 4 para subir botón cerrar sesión
      child: ListTile(
        leading: Container(
          width: 40, // Reducido de 48 a 40
          height: 40, // Reducido de 48 a 40
          decoration: BoxDecoration(
            color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10), // Reducido de 12 a 10
          ),
          child: Icon(
            icon,
            color: color ?? Theme.of(context).colorScheme.primary,
            size: 20, // Reducido de 24 a 20
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15, // Reducido de 16 a 15
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13, // Reducido de 14 a 13
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14, // Reducido de 16 a 14
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), // Reducido de 6 a 4
        tileColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _goToAddresses() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressesScreen()),
    );
  }

  Future<void> _goToSavedCards() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedCardsScreen()),
    );
  }

  Future<void> _goToTransactionHistory() async {
    Navigator.pushNamed(context, '/history');
  }

  Future<void> _goToSupportChat() async {
    Navigator.pushNamed(context, '/support-chat');
  }

  Future<void> _goToOrderTracking() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrderTrackingScreen()),
    );
  }

  Future<void> _changePassword() async {
    Navigator.pushNamed(context, '/change-password');
  }

  Future<void> _goToVendorPanel() async {
    Navigator.pushNamed(context, '/vendor-dashboard');
  }

  Future<void> _goToDeliveryPanel() async {
    Navigator.pushNamed(context, '/delivery-dashboard');
  }

  Future<void> _goToAdminPanel() async {
    // TODO: Implementar pantalla de administrador
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Panel de administrador próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _logout() async {
    // Mostrar diálogo de confirmación
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Cerrar sesión en Supabase y limpiar datos de rol
        await AuthServiceBypass.instance.signOut();
        await _roleService.clearUserData();

        // Navegar a login y limpiar stack
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error cerrando sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadLocalProfileImage(String userId) async {
    try {
      // Cargar ruta de imagen local desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_$userId');

      if (imagePath != null && File(imagePath).existsSync()) {
        if (mounted) {
          setState(() {
            profileImagePath = imagePath;
          });
        }
      }
    } catch (e) {
      print('Error loading local profile image: $e');
      // No necesitamos hacer nada si no hay imagen local
    }
  }

  Future<void> _changeProfileImage() async {
    // Mostrar opciones
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cambiar foto de perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (result != null) {
      await _pickAndSaveImageLocally(result);
    }
  }

  Future<void> _pickAndSaveImageLocally(ImageSource source) async {
    if (!mounted) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null && currentUser != null && mounted) {
        // Mostrar indicador de carga
        setState(() => isLoading = true);

        try {
          if (!mounted) return;

          // Guardar localmente primero como backup
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image_${currentUser!.id}', image.path);

          // Actualizar UI inmediatamente con imagen local
          setState(() {
            profileImagePath = image.path;
          });

          // Subir a Supabase usando ProfileImageService
          try {
            final imageUrl = await _profileImageService.uploadProfileImage(
              imageFile: File(image.path),
              userId: currentUser!.id,
            );

            if (imageUrl != null && mounted) {
              setState(() {
                profileImageUrl = imageUrl;
                isLoading = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Foto de perfil actualizada exitosamente'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              if (mounted) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Foto guardada localmente - Error subiendo a servidor'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          } catch (uploadError) {
            // Si falla Supabase, mantener solo la versión local
            print('Error uploading to Supabase: $uploadError');
            if (mounted) {
              setState(() => isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ Foto guardada localmente (sin conexión)'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (e) {
          print('Error processing image: $e');
          if (mounted) {
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Error procesando imagen'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error seleccionando imagen'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Obtener imagen de perfil prioritizando Supabase Storage
  ImageProvider _getProfileImage() {
    // 1. Prioridad: URL de Supabase Storage
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return NetworkImage(profileImageUrl!);
    }

    // 2. Fallback: Imagen local
    if (profileImagePath != null && File(profileImagePath!).existsSync()) {
      return FileImage(File(profileImagePath!));
    }

    // 3. Default: Imagen placeholder
    return const NetworkImage(
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&h=150',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
