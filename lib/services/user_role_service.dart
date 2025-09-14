import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserRoleService {
  static const String _userDataKey = 'user_data';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  
  // Singleton pattern
  static final UserRoleService _instance = UserRoleService._internal();
  factory UserRoleService() => _instance;
  UserRoleService._internal();
  
  Map<String, dynamic>? _currentUserData;
  String? _currentUserRole;
  String? _currentUserEmail;
  
  /// Inicializar el servicio cargando datos guardados
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userDataKey);
      final userRole = prefs.getString(_userRoleKey);
      final userEmail = prefs.getString(_userEmailKey);
      
      if (userData != null) {
        _currentUserData = jsonDecode(userData);
      }
      _currentUserRole = userRole;
      _currentUserEmail = userEmail;
      
      print('🔧 UserRoleService inicializado');
      print('   Usuario: $_currentUserEmail');
      print('   Rol: $_currentUserRole');
    } catch (e) {
      print('❌ Error inicializando UserRoleService: $e');
    }
  }
  
  /// Verificar rol del usuario por email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final client = SupabaseConfig.safeClient;
      if (client == null) {
        print('⚠️ Supabase no disponible - usando datos locales');
        return _currentUserData;
      }
      
      print('🔍 Buscando usuario: $email');
      
      final response = await client
          .from('users')
          .select('*')
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();
      
      if (response != null) {
        print('✅ Usuario encontrado: ${response['name']} - Rol: ${response['role']}');
        
        // Guardar datos del usuario
        await _saveUserData(response);
        
        return response;
      } else {
        print('❌ Usuario no encontrado en Supabase: $email');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo usuario: $e');
      // Retornar datos locales si hay error
      return _currentUserData;
    }
  }
  
  /// Guardar datos del usuario localmente
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _currentUserData = userData;
      _currentUserRole = userData['role']?.toString();
      _currentUserEmail = userData['email']?.toString();
      
      await prefs.setString(_userDataKey, jsonEncode(userData));
      await prefs.setString(_userRoleKey, _currentUserRole ?? '');
      await prefs.setString(_userEmailKey, _currentUserEmail ?? '');
      
      print('💾 Datos de usuario guardados localmente');
    } catch (e) {
      print('❌ Error guardando datos de usuario: $e');
    }
  }
  
  /// Limpiar datos del usuario (logout)
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_userDataKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_userEmailKey);
      
      _currentUserData = null;
      _currentUserRole = null;
      _currentUserEmail = null;
      
      print('🧹 Datos de usuario limpiados');
    } catch (e) {
      print('❌ Error limpiando datos de usuario: $e');
    }
  }
  
  /// Obtener rol actual del usuario
  String? get currentUserRole => _currentUserRole;
  
  /// Obtener email actual del usuario
  String? get currentUserEmail => _currentUserEmail;
  
  /// Obtener datos completos del usuario actual
  Map<String, dynamic>? get currentUserData => _currentUserData;
  
  /// Verificar si el usuario es vendedor
  bool get isVendor => _currentUserRole?.toLowerCase() == 'vendor';
  
  /// Verificar si el usuario es repartidor
  bool get isDelivery => _currentUserRole?.toLowerCase() == 'delivery';
  
  /// Verificar si el usuario es administrador
  bool get isAdmin => _currentUserRole?.toLowerCase() == 'admin';
  
  /// Verificar si el usuario es moderador
  bool get isModerator => _currentUserRole?.toLowerCase() == 'moderador';
  
  /// Verificar si el usuario tiene un rol especial (vendedor o repartidor)
  bool get hasSpecialRole => isVendor || isDelivery;
  
  /// Obtener nombre para mostrar
  String get displayName {
    if (_currentUserData == null) return 'Usuario';
    
    final name = _currentUserData!['name']?.toString();
    final email = _currentUserData!['email']?.toString();
    
    if (name != null && name.isNotEmpty && name != 'null') {
      return name;
    } else if (email != null) {
      return email.split('@')[0]; // Usar parte antes del @ como nombre
    }
    
    return 'Usuario';
  }
  
  /// Obtener texto del rol para mostrar
  String get roleDisplayText {
    switch (_currentUserRole?.toLowerCase()) {
      case 'vendor':
        return 'Vendedor';
      case 'delivery':
        return 'Repartidor';
      case 'admin':
        return 'Administrador';
      case 'moderador':
        return 'Moderador';
      default:
        return 'Usuario';
    }
  }
  
  /// Actualizar rol del usuario (si es necesario)
  Future<bool> updateUserRole(String email, String newRole) async {
    try {
      final client = SupabaseConfig.safeClient;
      if (client == null) return false;
      
      final response = await client
          .from('users')
          .update({'role': newRole})
          .eq('email', email.toLowerCase().trim());
      
      // Actualizar datos locales
      if (_currentUserData != null && _currentUserEmail == email) {
        _currentUserData!['role'] = newRole;
        _currentUserRole = newRole;
        await _saveUserData(_currentUserData!);
      }
      
      print('✅ Rol actualizado: $email -> $newRole');
      return true;
    } catch (e) {
      print('❌ Error actualizando rol: $e');
      return false;
    }
  }
  
  /// Verificar si el usuario está autenticado y tiene datos
  bool get isAuthenticated => _currentUserData != null && _currentUserEmail != null;
}





