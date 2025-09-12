import 'package:flutter/material.dart';
// Removed unused imports: url_launcher, dart:io
// import 'package:cubalink23/services/firebase_repository.dart'; // Commented out for compilation
import 'package:image_picker/image_picker.dart';
// Removed unused imports: dart:typed_data, flutter/foundation

class PushManagementScreen extends StatefulWidget {
  const PushManagementScreen({super.key});

  @override
  _PushManagementScreenState createState() => _PushManagementScreenState();
}

class _PushManagementScreenState extends State<PushManagementScreen> {
  // final FirebaseRepository _firebaseRepository = FirebaseRepository.instance; // Commented out for compilation
  
  // Banner management
  List<String> _bannerUrls = [];
  final TextEditingController _bannerUrlController = TextEditingController();
  bool _isLoadingBanners = false;
  // Removed unused field: _isUploadingBanner
  
  // Force update management
  final TextEditingController _googlePlayController = TextEditingController();
  final TextEditingController _appStoreController = TextEditingController();
  bool _forceUpdateActive = false;
  bool _isLoadingUpdate = false;
  
  // Push notification management
  final TextEditingController _pushSubjectController = TextEditingController();
  final TextEditingController _pushMessageController = TextEditingController();
  final TextEditingController _pushImageUrlController = TextEditingController();
  String _selectedRole = 'user';
  // Removed unused field: _isSendingPush
  
  // Alert management
  final TextEditingController _alertMessageController = TextEditingController();
  final TextEditingController _alertImageUrlController = TextEditingController();
  // Removed unused field: _isSendingAlert
  
  // App maintenance
  bool _maintenanceMode = false;
  bool _isLoadingMaintenance = false;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadBanners();
    _loadForceUpdateSettings();
    _loadMaintenanceStatus();
  }

  @override
  void dispose() {
    _bannerUrlController.dispose();
    _googlePlayController.dispose();
    _appStoreController.dispose();
    _pushSubjectController.dispose();
    _pushMessageController.dispose();
    _pushImageUrlController.dispose();
    _alertMessageController.dispose();
    _alertImageUrlController.dispose();
    super.dispose();
  }

  _loadBanners() async {
    setState(() => _isLoadingBanners = true);
    try {
      // TODO: Replace with Supabase implementation
      await Future.delayed(Duration(seconds: 1));
      final banners = <String>[]; // Mock empty list
      setState(() {
        _bannerUrls = banners;
        _isLoadingBanners = false;
      });
    } catch (e) {
      setState(() => _isLoadingBanners = false);
      _showSnackBar('Error al cargar banners: $e', isError: true);
    }
  }

  _loadForceUpdateSettings() async {
    setState(() => _isLoadingUpdate = true);
    try {
      // TODO: Replace with Supabase implementation
      await Future.delayed(Duration(milliseconds: 500));
      final settings = {'active': false, 'googlePlayUrl': '', 'appStoreUrl': ''}; // Mock data
      setState(() {
        _forceUpdateActive = (settings['active'] as bool?) ?? false;
        _googlePlayController.text = (settings['googlePlayUrl'] as String?) ?? '';
        _appStoreController.text = (settings['appStoreUrl'] as String?) ?? '';
        _isLoadingUpdate = false;
      });
    } catch (e) {
      setState(() => _isLoadingUpdate = false);
      _showSnackBar('Error al cargar configuración: $e', isError: true);
    }
  }

  _addBanner() async {
    if (_bannerUrlController.text.trim().isEmpty) {
      _showSnackBar('Por favor ingresa una URL válida', isError: true);
      return;
    }

    try {
      _showSnackBar('Agregando banner...', isError: false);
      
      // TODO: Replace with Supabase implementation
      await Future.delayed(Duration(milliseconds: 500));
      _bannerUrlController.clear();
      _loadBanners();
      _showSnackBar('✅ Banner agregado exitosamente (simulado)');
    } catch (e) {
      _showSnackBar('Error al agregar banner: $e', isError: true);
    }
  }

  _deleteBanner(int index) async {
    try {
      _showSnackBar('Eliminando banner...', isError: false);
      
      // TODO: Replace with Supabase implementation
      await Future.delayed(Duration(milliseconds: 500));
      _loadBanners();
      _showSnackBar('🗑️ Banner eliminado exitosamente (simulado)');
    } catch (e) {
      _showSnackBar('Error al eliminar banner: $e', isError: true);
    }
  }

  _toggleForceUpdate() async {
    if (!_forceUpdateActive && 
        (_googlePlayController.text.trim().isEmpty || _appStoreController.text.trim().isEmpty)) {
      _showSnackBar('Por favor ingresa ambos enlaces de las tiendas', isError: true);
      return;
    }

    try {
      _showSnackBar('Configurando actualización forzosa...', isError: false);
      
      final newStatus = !_forceUpdateActive;
      // TODO: Replace with Supabase implementation
      await Future.delayed(Duration(milliseconds: 500));
      
      setState(() => _forceUpdateActive = newStatus);
      
      final statusText = newStatus ? '⚠️ ACTIVADA' : '✅ DESACTIVADA';
      _showSnackBar('Actualización forzosa $statusText (simulado)');
      
      if (newStatus) {
        _showConfirmationDialog();
      }
    } catch (e) {
      _showSnackBar('Error al configurar actualización: $e', isError: true);
    }
  }

  _loadMaintenanceStatus() async {
    setState(() => _isLoadingMaintenance = true);
    try {
      // TODO: Replace with Supabase implementation
      await Future.delayed(Duration(milliseconds: 500));
      final status = false; // Mock data
      setState(() {
        _maintenanceMode = status;
        _isLoadingMaintenance = false;
      });
    } catch (e) {
      setState(() => _isLoadingMaintenance = false);
      _showSnackBar('Error al cargar estado de mantenimiento: $e', isError: true);
    }
  }

  _pickBannerImageFile() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 600,
      );
      
      if (pickedFile != null) {
        _showSnackBar('Subiendo imagen...', isError: false);
        
        // TODO: Replace with Supabase Storage implementation
        await Future.delayed(Duration(seconds: 2));
        final imageUrl = 'https://via.placeholder.com/1200x600?text=Banner+Image';
        
        if (imageUrl.isNotEmpty) {
          await Future.delayed(Duration(milliseconds: 500));
          _loadBanners();
          _showSnackBar('Banner agregado exitosamente desde archivo (simulado)');
        } else {
          _showSnackBar('Error al subir la imagen', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar('Error al procesar imagen: $e', isError: true);
    }
  }

  _pickPushImageFile() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 600,
      );
      
      if (pickedFile != null) {
        _showSnackBar('Subiendo imagen...', isError: false);
        
        // TODO: Replace with Supabase Storage implementation
        await Future.delayed(Duration(seconds: 1));
        final imageUrl = 'https://via.placeholder.com/800x600?text=Push+Image';
        
        if (imageUrl.isNotEmpty) {
          setState(() {
            _pushImageUrlController.text = imageUrl;
          });
          _showSnackBar('Imagen agregada exitosamente (simulado)');
        } else {
          _showSnackBar('Error al subir la imagen', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar('Error al procesar imagen: $e', isError: true);
    }
  }

  _pickAlertImageFile() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 600,
      );
      
      if (pickedFile != null) {
        _showSnackBar('Subiendo imagen...', isError: false);
        
        // TODO: Replace with Supabase Storage implementation
        await Future.delayed(Duration(seconds: 1));
        final imageUrl = 'https://via.placeholder.com/800x600?text=Alert+Image';
        
        if (imageUrl.isNotEmpty) {
          setState(() {
            _alertImageUrlController.text = imageUrl;
          });
          _showSnackBar('Imagen agregada exitosamente (simulado)');
        } else {
          _showSnackBar('Error al subir la imagen', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar('Error al procesar imagen: $e', isError: true);
    }
  }

  _sendPushNotification() async {
    if (_pushSubjectController.text.trim().isEmpty || _pushMessageController.text.trim().isEmpty) {
      _showSnackBar('Por favor completa el asunto y mensaje', isError: true);
      return;
    }

    try {
      _showSnackBar('Enviando notificación...', isError: false);
      
      // TODO: Replace with Supabase implementation
      await Future.delayed(Duration(seconds: 1));
      
      _pushSubjectController.clear();
      _pushMessageController.clear();
      _pushImageUrlController.clear();
      setState(() => _selectedRole = 'user');
      
      _showSnackBar('✅ Notificación push enviada exitosamente (simulado) a usuarios con rol $_selectedRole');
    } catch (e) {
      _showSnackBar('Error al enviar notificación: $e', isError: true);
    }
  }

  _sendScreenAlert() async {
    if (_alertMessageController.text.trim().isEmpty) {
      _showSnackBar('Por favor ingresa el mensaje de alerta', isError: true);
      return;
    }

    try {
      _showSnackBar('Enviando alerta...', isError: false);
      
      // TODO: Replace with Supabase implementation
      await Future.delayed(Duration(seconds: 1));
      
      _alertMessageController.clear();
      _alertImageUrlController.clear();
      
      _showSnackBar('🚨 Alerta enviada a TODAS las pantallas de usuarios (simulado)');
    } catch (e) {
      _showSnackBar('Error al enviar alerta: $e', isError: true);
    }
  }

  _toggleMaintenanceMode() async {
    try {
      _showSnackBar('Actualizando modo mantenimiento...', isError: false);
      
      final newStatus = !_maintenanceMode;
      // TODO: Replace with Supabase implementation
      await Future.delayed(Duration(milliseconds: 500));
      
      setState(() => _maintenanceMode = newStatus);
      
      final statusText = newStatus ? '🔧 ACTIVADO' : '✅ DESACTIVADO';
      _showSnackBar('Modo mantenimiento $statusText (simulado)');
      
      if (newStatus) {
        _showMaintenanceConfirmationDialog();
      }
    } catch (e) {
      _showSnackBar('Error al cambiar modo mantenimiento: $e', isError: true);
    }
  }

  _showMaintenanceConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.build, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Mantenimiento Activado'),
          ],
        ),
        content: Text(
          'El modo mantenimiento está ACTIVO. Los usuarios verán el mensaje "Estamos dandole mantenimiento al servicio" y no podrán usar la app.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Actualización Activada'),
          ],
        ),
        content: Text(
          'La actualización forzosa está ahora ACTIVA. Todos los usuarios serán obligados a actualizar la app la próxima vez que la abran.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _isMobileDevice(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    if (_isMobileDevice(context)) {
      return _buildMobileBlockedView();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          'Push - Gestión de Publicidad y Actualizaciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              _buildHeaderSection(),
              
              SizedBox(height: 32),
              
              // Banner Management Section
              _buildBannerManagementSection(),
              
              SizedBox(height: 32),
              
              // Push Notifications Section
              _buildPushNotificationsSection(),
              
              SizedBox(height: 32),
              
              // Screen Alerts Section
              _buildScreenAlertsSection(),
              
              SizedBox(height: 32),
              
              // Maintenance Mode Section
              _buildMaintenanceModeSection(),
              
              SizedBox(height: 32),
              
              // Force Update Section
              _buildForceUpdateSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity( 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity( 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.campaign,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Centro de Gestión Push',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Administra banners publicitarios y actualizaciones forzosas para todos los usuarios de la aplicación',
                  style: TextStyle(
                    color: Colors.white.withOpacity( 0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerManagementSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.image, color: Colors.blue, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Banners Publicitarios',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Administra las imágenes del banner publicitario en la pantalla de bienvenida',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_bannerUrls.length} banners',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Add Banner Form
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agregar Nuevo Banner',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                // Banner dimensions info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Dimensiones recomendadas: 1200x600 pixels (PNG/JPG)',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bannerUrlController,
                        decoration: InputDecoration(
                          hintText: 'URL de la imagen del banner',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          prefixIcon: Icon(Icons.link, color: Colors.blue),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _pickBannerImageFile,
                      icon: Icon(Icons.upload_file, size: 20),
                      label: Text('Subir Archivo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _addBanner,
                      icon: Icon(Icons.add, size: 20),
                      label: Text('Agregar URL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Banners Display
          if (_isLoadingBanners)
            SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_bannerUrls.isEmpty)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 12),
                    Text(
                      'No hay banners configurados',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Agrega el primer banner para comenzar',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              constraints: BoxConstraints(maxHeight: 400),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                ),
                itemCount: _bannerUrls.length,
                itemBuilder: (context, index) => _buildBannerCard(index),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForceUpdateSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _forceUpdateActive ? Colors.red[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.update,
                  color: _forceUpdateActive ? Colors.red : Colors.orange,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actualización Forzosa de la App',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Obliga a todos los usuarios a actualizar la app desde las tiendas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _forceUpdateActive ? Colors.red[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _forceUpdateActive ? 'ACTIVO' : 'INACTIVO',
                  style: TextStyle(
                    color: _forceUpdateActive ? Colors.red[800] : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          if (_isLoadingUpdate)
            SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store URLs Configuration
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuración de Enlaces de Tiendas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Google Play Store
                      Text(
                        'Google Play Store',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _googlePlayController,
                        decoration: InputDecoration(
                          hintText: 'https://play.google.com/store/apps/details?id=com.turecarga.app',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          prefixIcon: Icon(Icons.android, color: Colors.green),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Apple App Store
                      Text(
                        'Apple App Store',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _appStoreController,
                        decoration: InputDecoration(
                          hintText: 'https://apps.apple.com/app/tu-recarga/id123456789',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          prefixIcon: Icon(Icons.phone_iphone, color: Colors.blue),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Warning Card (if active)
                if (_forceUpdateActive) ...[
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'La actualización forzosa está ACTIVA. Los usuarios no pueden usar la app sin actualizar.',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _toggleForceUpdate,
                    icon: Icon(
                      _forceUpdateActive ? Icons.stop : Icons.warning,
                      size: 20,
                    ),
                    label: Text(
                      _forceUpdateActive 
                          ? 'Desactivar Actualización Forzosa'
                          : 'Activar Actualización Forzosa',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _forceUpdateActive ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMobileBlockedView() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Acceso Restringido', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.desktop_access_disabled, size: 80, color: Colors.red[400]),
              SizedBox(height: 24),
              Text(
                'Acceso No Permitido',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Esta función solo está disponible desde tablets, laptops o computadoras.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método eliminado - funcionalidad movida a _buildBannerManagementSection()

  Widget _buildBannerCard(int index) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                _bannerUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[100],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey[400], size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Error al cargar',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Banner ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Imagen publicitaria',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(index),
                  icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
                  tooltip: 'Eliminar banner',
                  constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 12),
            Text('Eliminar Banner'),
          ],
        ),
        content: Text('¿Estás seguro de que deseas eliminar el Banner ${index + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteBanner(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPushNotificationsSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.notifications_active, color: Colors.purple, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notificaciones Push',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Envía notificaciones push con imagen y texto a usuarios específicos por rol',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nueva Notificación Push',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),

                // Subject
                Text('Asunto', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextField(
                  controller: _pushSubjectController,
                  decoration: InputDecoration(
                    hintText: 'Asunto de la notificación',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Message
                Text('Mensaje', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextField(
                  controller: _pushMessageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Contenido del mensaje push',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Image URL
                Text('Imagen (Opcional)', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pushImageUrlController,
                        decoration: InputDecoration(
                          hintText: 'URL de imagen para la notificación',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          prefixIcon: Icon(Icons.link, color: Colors.purple),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _pickPushImageFile,
                      icon: Icon(Icons.upload_file, size: 18),
                      label: Text('Subir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Role Selector
                Text('Dirigido a', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: 'user', child: Text('👥 Usuarios (Clientes)')),
                        DropdownMenuItem(value: 'admin', child: Text('👨‍💼 Administradores')),
                        DropdownMenuItem(value: 'vendedor', child: Text('🛍️ Vendedores')),
                        DropdownMenuItem(value: 'repartidor', child: Text('🚚 Repartidores')),
                        DropdownMenuItem(value: 'all', child: Text('🌍 Todos los Usuarios')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedRole = value!);
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendPushNotification,
                    icon: Icon(Icons.send, size: 20),
                    label: Text(
                      'Enviar Notificación Push',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  Widget _buildScreenAlertsSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.warning, color: Colors.amber[700], size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alertas en Pantalla',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Envía alertas que aparecen como cortina en la pantalla de todos los usuarios',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nueva Alerta de Pantalla',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),

                // Alert Message
                Text('Mensaje de Alerta', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                TextField(
                  controller: _alertMessageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Mensaje que aparecerá en la cortina de alerta',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Alert Image URL
                Text('Imagen de Alerta (Opcional)', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _alertImageUrlController,
                        decoration: InputDecoration(
                          hintText: 'URL de imagen para mostrar en la alerta',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          prefixIcon: Icon(Icons.link, color: Colors.amber[700]),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _pickAlertImageFile,
                      icon: Icon(Icons.upload_file, size: 18),
                      label: Text('Subir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendScreenAlert,
                    icon: Icon(Icons.campaign, size: 20),
                    label: Text(
                      'Enviar Alerta a Todas las Pantallas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  Widget _buildMaintenanceModeSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _maintenanceMode ? Colors.red[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.build,
                  color: _maintenanceMode ? Colors.red : Colors.grey[600],
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modo Mantenimiento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Bloquea el acceso a la app mostrando mensaje de mantenimiento',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _maintenanceMode ? Colors.red[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _maintenanceMode ? 'ACTIVO' : 'INACTIVO',
                  style: TextStyle(
                    color: _maintenanceMode ? Colors.red[800] : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          if (_isLoadingMaintenance)
            SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Column(
              children: [
                // Warning if active
                if (_maintenanceMode) ...[
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '⚠️ MODO MANTENIMIENTO ACTIVO\n\nLos usuarios ven: "Estamos dandole mantenimiento al servicio. En breve estará todo disponible"',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _toggleMaintenanceMode,
                    icon: Icon(
                      _maintenanceMode ? Icons.play_arrow : Icons.build,
                      size: 20,
                    ),
                    label: Text(
                      _maintenanceMode 
                          ? 'Desactivar Modo Mantenimiento'
                          : 'Activar Modo Mantenimiento',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _maintenanceMode ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Método eliminado - funcionalidad movida a _buildForceUpdateSection()
}