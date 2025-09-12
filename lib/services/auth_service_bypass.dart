import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cubalink23/models/user.dart' as UserModel;
import 'package:cubalink23/models/payment_card.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:cubalink23/services/cart_service.dart';

/// Simplified Supabase Authentication Service that bypasses RLS policy issues
/// This service handles authentication without problematic database queries
class AuthServiceBypass {
  static AuthServiceBypass? _instance;
  static AuthServiceBypass get instance => _instance ??= AuthServiceBypass._();
  
  AuthServiceBypass._();
  
  final SupabaseClient _client = SupabaseConfig.client;
  
  UserModel.User? _currentUser;
  double _userBalance = 1000.0;
  
  // Getters
  UserModel.User? get currentUser => _currentUser;
  double get userBalance => _userBalance;
  String? get currentUserId => _client.auth.currentUser?.id;
  bool get isSignedIn => _client.auth.currentUser != null;
  
  // Keys for SharedPreferences
  static const String _isLoggedInKey = 'is_logged_in_bypass';
  static const String _userIdKey = 'user_id_bypass';
  static const String _userNameKey = 'user_name_bypass';
  static const String _userEmailKey = 'user_email_bypass';
  static const String _userPhoneKey = 'user_phone_bypass';
  static const String _userCountryKey = 'user_country_bypass';
  static const String _userCityKey = 'user_city_bypass';
  static const String _userBalanceKey = 'user_balance_bypass';
  
  /// Check if user is already authenticated
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    
    // Check Supabase Auth state
    final supabaseUser = _client.auth.currentUser;
    
    if (isLoggedIn && supabaseUser != null) {
      // Load current user data from SharedPreferences
      await loadCurrentUserFromLocal();
      return _currentUser != null;
    }
    
    return false;
  }
  
  /// Save user data to local storage
  Future<void> _saveUserData(UserModel.User user, double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userNameKey, user.name);
    await prefs.setString(_userEmailKey, user.email);
    await prefs.setString(_userPhoneKey, user.phone);
    await prefs.setString(_userCountryKey, user.country ?? 'Ecuador');
    await prefs.setString(_userCityKey, user.city ?? 'Quito');
    await prefs.setDouble(_userBalanceKey, balance);
  }
  
  /// Load user data from local storage
  Future<void> loadCurrentUserFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    
    final userId = prefs.getString(_userIdKey);
    if (userId == null) return;
    
    _currentUser = UserModel.User(
      id: userId,
      name: prefs.getString(_userNameKey) ?? 'Usuario',
      email: prefs.getString(_userEmailKey) ?? '',
      phone: prefs.getString(_userPhoneKey) ?? '',
      country: prefs.getString(_userCountryKey) ?? 'Ecuador',
      city: prefs.getString(_userCityKey) ?? 'Quito',
      createdAt: DateTime.now(),
      role: 'Usuario',
    );
    
    _userBalance = prefs.getDouble(_userBalanceKey) ?? 1000.0;
    
    // Cargar carrito del usuario desde Supabase
    try {
      final cartService = CartService();
      await cartService.loadFromSupabase();
      print('🛒 Carrito cargado desde Supabase');
    } catch (e) {
      print('⚠️ Error cargando carrito: $e');
    }
    
    print('✅ Usuario cargado desde almacenamiento local: ${_currentUser!.name}');
  }
  
  /// Clear login state and local data
  Future<void> _clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userCountryKey);
    await prefs.remove(_userCityKey);
    await prefs.remove(_userBalanceKey);
    
    _currentUser = null;
    _userBalance = 0.0;
  }
  
  /// Register user with email and password
  Future<UserModel.User?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String country,
    required String city,
  }) async {
    try {
      print('🔐 Registrando usuario bypass: $email');
      
      // Sign up with Supabase Auth only
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'country': country,
          'city': city,
        },
      );
      
      if (response.user != null) {
        print('✅ Usuario registrado en Supabase Auth: ${response.user!.id}');
        
        // Create user object
        _currentUser = UserModel.User(
          id: response.user!.id,
          name: name,
          email: email,
          phone: phone,
          createdAt: DateTime.now(),
          country: country,
          city: city,
          role: 'Usuario',
        );
        _userBalance = 1000.0;
        
        // Save to local storage
        await _saveUserData(_currentUser!, _userBalance);
        
        print('✅ Registro completado exitosamente');
        return _currentUser;
      }
      
      return null;
    } catch (e) {
      print('❌ Error registrando usuario: $e');
      // Provide more user-friendly error messages
      if (e.toString().contains('already registered')) {
        throw Exception('Este email ya está registrado. Intenta iniciar sesión.');
      } else if (e.toString().contains('Invalid email')) {
        throw Exception('El formato del email no es válido.');
      } else if (e.toString().contains('Password too weak')) {
        throw Exception('La contraseña debe tener al menos 6 caracteres.');
      } else {
        throw Exception('Error de conexión. Verifica tu internet e intenta de nuevo.');
      }
    }
  }
  
  /// Login user with email/phone and password
  Future<UserModel.User?> loginUser({
    String? email,
    String? phone,
    required String password,
  }) async {
    print('🔐 === LOGIN BYPASS ===');
    try {
      String identifier = email ?? phone ?? '';
      print('🔐 Identificador: $identifier');
      
      AuthResponse? response;
      
      if (email != null && email.isNotEmpty) {
        print('🔐 Login con email');
        response = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else if (phone != null && phone.isNotEmpty) {
        // For phone login, we'll try common email patterns
        print('🔐 Login con teléfono (intentando patrones de email)');
        final possibleEmails = [
          phone,
          '$phone@phone.local',
          '$phone@turecarga.com',
        ];
        
        Exception? lastError;
        for (final testEmail in possibleEmails) {
          try {
            response = await _client.auth.signInWithPassword(
              email: testEmail,
              password: password,
            );
            break; // Success
          } catch (e) {
            lastError = Exception(e.toString());
            continue;
          }
        }
        
        if (response == null) {
          throw lastError ?? Exception('No se encontró cuenta con ese teléfono');
        }
      } else {
        throw Exception('Debes proporcionar un email o teléfono.');
      }
      
      if (response.user != null) {
        print('✅ Sesión iniciada exitosamente: ${response.user!.id}');
        
        // Create user object from auth metadata
        final user = response.user!;
        final metadata = user.userMetadata ?? {};
        
        _currentUser = UserModel.User(
          id: user.id,
          name: metadata['name']?.toString() ?? 'Usuario',
          email: user.email ?? email ?? '',
          phone: metadata['phone']?.toString() ?? phone ?? '',
          country: metadata['country']?.toString() ?? 'Ecuador',
          city: metadata['city']?.toString() ?? 'Quito',
          createdAt: DateTime.now(),
          role: 'Usuario',
        );
        _userBalance = 1000.0;
        
        // Save to local storage
        await _saveUserData(_currentUser!, _userBalance);
        
        // Cargar carrito del usuario desde Supabase
        try {
          final cartService = CartService();
          await cartService.loadFromSupabase();
          print('🛒 Carrito cargado desde Supabase');
        } catch (e) {
          print('⚠️ Error cargando carrito: $e');
        }
        
        print('✅ Login completado - Usuario: ${_currentUser!.name}');
        return _currentUser;
      }
      
      return null;
    } catch (e) {
      print('❌ Error durante login: $e');
      
      String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('invalid login credentials') || 
          errorMessage.contains('invalid_credentials') ||
          errorMessage.contains('invalid') ||
          errorMessage.contains('credentials')) {
        throw Exception('Email/teléfono o contraseña incorrectos.');
      } else if (errorMessage.contains('too many requests')) {
        throw Exception('Demasiados intentos. Espera unos minutos.');
      } else if (errorMessage.contains('network') || 
                 errorMessage.contains('connection')) {
        throw Exception('Error de conexión. Verifica tu internet.');
      } else {
        throw Exception('Error al iniciar sesión: ${e.toString()}');
      }
    }
  }
  
  /// Logout user
  Future<void> logoutUser() async {
    try {
      print('🚪 Cerrando sesión...');
      
      await _client.auth.signOut();
      await _clearLoginState();
      
      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      // Force clear local state even if remote logout fails
      await _clearLoginState();
    }
  }
  
  /// Update user balance
  Future<void> updateUserBalance(double newBalance) async {
    _userBalance = newBalance;
    if (_currentUser != null) {
      await _saveUserData(_currentUser!, _userBalance);
    }
    print('✅ Balance actualizado: $newBalance');
  }
  
  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    String? country,
    String? city,
    String? profilePhotoUrl,
  }) async {
    if (_currentUser == null) return;
    
    _currentUser = UserModel.User(
      id: _currentUser!.id,
      name: name ?? _currentUser!.name,
      email: _currentUser!.email,
      phone: phone ?? _currentUser!.phone,
      country: country ?? _currentUser!.country,
      city: city ?? _currentUser!.city,
      createdAt: _currentUser!.createdAt,
      role: _currentUser!.role,
      profilePhotoUrl: profilePhotoUrl ?? _currentUser!.profilePhotoUrl,
    );
    
    await _saveUserData(_currentUser!, _userBalance);
    print('✅ Perfil actualizado');
  }
  
  /// Convenience methods for screen compatibility
  Future<UserModel.User?> register({
    required String email,
    required String password, 
    required String name,
    required String phone,
    required String country,
    required String city,
  }) async {
    return await registerUser(
      email: email,
      password: password,
      name: name,
      phone: phone,
      country: country,
      city: city,
    );
  }
  
  Future<UserModel.User?> login({
    String? email,
    String? phone, 
    required String password,
  }) async {
    return await loginUser(email: email, phone: phone, password: password);
  }
  
  Future<UserModel.User?> loginByPhone({
    required String phone,
    required String password,
  }) async {
    return await loginUser(phone: phone, password: password);
  }
  
  Future<void> logout() async {
    await logoutUser();
  }
  
  Future<void> signOut() async {
    await logoutUser();
  }
  
  UserModel.User? getCurrentUser() {
    return _currentUser;
  }
  
  /// Check if user is suspended (always false for bypass)
  Future<bool> isUserSuspended(String userId) async {
    return false; // No suspension checks in bypass mode
  }
  
  /// Get user addresses (empty for bypass)
  Future<List<Map<String, dynamic>>> getUserAddresses(String userId) async {
    return [];
  }
  
  /// Get user payment cards (empty for bypass)
  Future<List<PaymentCard>> getUserPaymentCards(String userId) async {
    return [];
  }
  
  /// Add recharge history (no-op for bypass)
  Future<void> addRechargeHistory(String userId, Map<String, dynamic> recharge) async {
    print('ℹ️ Recharge history bypass - no DB interaction');
  }
  
  /// Notify service used (no-op for bypass)
  Future<void> notifyServiceUsed() async {
    print('ℹ️ Service usage notification bypass');
  }
  
  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _client.auth.updateUser(UserAttributes(
        password: newPassword,
      ));
      print('✅ Contraseña cambiada exitosamente');
    } catch (e) {
      print('❌ Error cambiando contraseña: $e');
      throw Exception('Error cambiando contraseña. Intenta de nuevo.');
    }
  }
}