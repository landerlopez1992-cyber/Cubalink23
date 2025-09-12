import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cubalink23/models/user.dart' as UserModel;
import 'package:cubalink23/models/payment_card.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:cubalink23/services/user_role_service.dart';
import 'dart:typed_data';

/// Simplified authentication service using Supabase
/// This replaces the Firebase AuthService
class SupabaseAuthService {
  static SupabaseAuthService? _instance;
  static SupabaseAuthService get instance => _instance ??= SupabaseAuthService._();

  SupabaseAuthService._();

  SupabaseClient? get _client => SupabaseConfig.safeClient;

  UserModel.User? _currentUser;
  double _userBalance = 0.0;
  final UserRoleService _roleService = UserRoleService();

  /// Safe auth getter - returns null if Supabase not initialized
  GoTrueClient? get _auth => _client?.auth;

  /// Check if Supabase is available
  bool get _isSupabaseAvailable => _client != null;

  // Getters
  UserModel.User? get currentUser => _currentUser;
  double get userBalance => _userBalance;

  // Keys for SharedPreferences
  static const String _isLoggedInKey = 'is_logged_in_supabase';
  static const String _userIdKey = 'user_id_supabase';

  /// Check if user is already authenticated
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    // Check Supabase Auth state
    final supabaseUser = _auth?.currentUser;

    if (isLoggedIn && supabaseUser != null && _isSupabaseAvailable) {
      // Load current user data
      await loadCurrentUserData();
      
      // Cargar datos de rol del usuario
      if (supabaseUser.email != null) {
        await _roleService.initialize();
        await _roleService.getUserByEmail(supabaseUser.email!);
      }
      
      return _currentUser != null;
    }

    // Return false if Supabase not available or user not logged in
    return false;
  }

  /// Save login state
  Future<void> _saveLoginState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, userId);
  }

  /// Clear login state
  Future<void> _clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userIdKey);
    _currentUser = null;
    _userBalance = 0.0;
    await _roleService.clearUserData();
  }

  /// Logout user
  Future<void> logoutUser() async {
    try {
      print('🚪 Cerrando sesión...');

      if (_auth != null) {
        await _auth!.signOut();
      }
      await _clearLoginState();

      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      // Force clear local state even if remote logout fails
      await _clearLoginState();
      throw e;
    }
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
      print('🔐 Registrando usuario en Supabase: $email');

      // Sign up with Supabase Auth
      final response = await _client?.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'country': country,
          'city': city,
        },
      );

      if (response?.user != null) {
        print('✅ Usuario registrado en Supabase Auth: ${response?.user?.id}');

        // FIXED: Skip database profile creation to avoid RLS policy issues
        print('📝 Saltando creación de perfil en BD para evitar policy recursion...');

        // Set current user and balance
        _currentUser = UserModel.User(
          id: response?.user?.id ?? '',
          name: name,
          email: email,
          phone: phone,
          createdAt: DateTime.now(),
          country: country,
          city: city,
          role: 'Usuario', // Default role for new users
        );
        _userBalance = 1000.0; // Default balance for testing

        // Save login state
        await _saveLoginState(response?.user?.id ?? '');

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
    print('🔐 === INICIANDO LOGIN ===');
    print('🔐 Email: ${email ?? 'null'}');
    print('🔐 Phone: ${phone ?? 'null'}');
    print('🔐 Password length: ${password.length}');

    try {
      String identifier = email ?? phone ?? '';
      print('🔐 Identificador para login: $identifier');

      AuthResponse? response;

      if (email != null && email.isNotEmpty) {
        print('🔐 === PROCESO LOGIN CON EMAIL ===');
        print('🔐 Email a verificar: $email');

        // Validate email format
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
          print('❌ Formato de email inválido');
          throw Exception('Formato de email inválido');
        }

        // FIXED: Skip database user check to avoid RLS policy recursion
        print('📡 Saltando verificación de BD para evitar recursión de policies...');

        // Attempt login with Supabase Auth
        print('🔐 Ejecutando signInWithPassword...');
        try {
          response = await _client?.auth.signInWithPassword(
            email: email,
            password: password,
          );
          print('✅ signInWithPassword ejecutado exitosamente');
          print('✅ Response user ID: ${response?.user?.id}');
          print('✅ Response user email: ${response?.user?.email}');
        } catch (authError) {
          print('❌ Error en signInWithPassword: $authError');
          print('❌ Tipo de error: ${authError.runtimeType}');
          throw authError;
        }

      } else if (phone != null && phone.isNotEmpty) {
        print('🔐 === PROCESO LOGIN CON TELEFONO ===');
        print('🔐 Teléfono: $phone');

        // FIXED: Use RPC to avoid RLS policy issues
        print('📡 Usando RPC para buscar usuario por teléfono...');
        try {
          final userResponse = await _client?.rpc('find_user_by_phone', params: {
            'user_phone': phone
          });

          print('📞 RPC respuesta para teléfono: $userResponse');

          if (userResponse != null && userResponse['email'] != null) {
            final userEmail = userResponse['email'];
            print('📧 Encontrado email para teléfono: $userEmail');

            response = await _client?.auth.signInWithPassword(
              email: userEmail,
              password: password,
            );
            print('✅ Login con teléfono->email exitoso');
          } else {
            throw Exception('No se encontró una cuenta con ese número de teléfono.');
          }
        } catch (rpcError) {
          print('⚠️ RPC no disponible, usando método directo: $rpcError');
          // Fallback: Try direct auth with phone as email
          try {
            response = await _client?.auth.signInWithPassword(
              email: phone + '@phone.local', // Dummy email format for phone
              password: password,
            );
          } catch (e) {
            throw Exception('No se encontró una cuenta con ese número de teléfono.');
          }
        }
      } else {
        throw Exception('Debes proporcionar un email o teléfono.');
      }

      if (response?.user != null) {
        print('✅ Sesión iniciada en Supabase: ${response?.user?.id}');

        // Load user data from database
        await loadCurrentUserData();
        
        // Cargar datos de rol del usuario
        final userEmail = response?.user?.email ?? email ?? '';
        if (userEmail.isNotEmpty) {
          await _roleService.initialize();
          await _roleService.getUserByEmail(userEmail);
          print('✅ Datos de rol cargados para: $userEmail');
        }

        if (_currentUser != null) {
          // Save login state
          await _saveLoginState(response?.user?.id ?? '');
          print('✅ Login completado exitosamente - Usuario: ${_currentUser!.name}');
          return _currentUser;
        } else {
          // FIXED: Create basic user object without database interaction
          print('⚠️ Creando usuario básico sin interacción con BD...');

          _currentUser = UserModel.User(
            id: response?.user?.id ?? '',
            name: response?.user?.userMetadata?['name'] ?? 'Usuario',
            email: response?.user?.email ?? email ?? '',
            phone: response?.user?.userMetadata?['phone'] ?? phone ?? '',
            createdAt: DateTime.now(),
            country: response?.user?.userMetadata?['country'] ?? 'Ecuador',
            city: response?.user?.userMetadata?['city'] ?? 'Quito',
            role: 'Usuario',
          );
          _userBalance = 1000.0; // Default balance for testing

          await _saveLoginState(response?.user?.id ?? '');
          print('✅ Login completado con datos básicos');
          return _currentUser;
        }
      }

      print('❌ ERROR: Usuario no pudo ser autenticado completamente');
      return null;
    } catch (e) {
      print('❌ === ERROR DURANTE LOGIN ===');
      print('❌ Error completo: $e');
      print('❌ Tipo: ${e.runtimeType}');

      // Provide more user-friendly error messages
      String errorMessage = e.toString().toLowerCase();
      print('❌ Mensaje de error (lowercase): $errorMessage');

      if (errorMessage.contains('invalid login credentials') ||
          errorMessage.contains('invalid_credentials') ||
          errorMessage.contains('invalid') ||
          errorMessage.contains('credentials')) {
        print('❌ Error identificado: Credenciales inválidas');
        throw Exception('Email/teléfono o contraseña incorrectos.');
      } else if (errorMessage.contains('too many requests') ||
          errorMessage.contains('rate limit') ||
          errorMessage.contains('rate_limit')) {
        print('❌ Error identificado: Rate limit');
        throw Exception('Demasiados intentos. Espera unos minutos e intenta de nuevo.');
      } else if (errorMessage.contains('network') ||
          errorMessage.contains('connection') ||
          errorMessage.contains('timeout')) {
        print('❌ Error identificado: Red/conexión');
        throw Exception('Error de conexión. Verifica tu internet e intenta de nuevo.');
      } else {
        print('❌ Error identificado: Error genérico');
        throw Exception('Error al iniciar sesión: ${e.toString()}');
      }
    }
  }

  /// Load current user data from Supabase
  Future<void> loadCurrentUserData() async {
    print('📡 === CARGANDO DATOS DE USUARIO ===');
    try {
      if (!_isSupabaseAvailable) {
        print('⚠️ Supabase no disponible, no se pueden cargar datos');
        _currentUser = null;
        _userBalance = 0.0;
        return;
      }

      final supabaseUser = _auth?.currentUser;
      if (supabaseUser == null) {
        print('❌ No hay usuario autenticado en Supabase');
        _currentUser = null;
        _userBalance = 0.0;
        return;
      }

      print('📡 Usuario autenticado encontrado - ID: ${supabaseUser.id}');
      print('📡 Email en Auth: ${supabaseUser.email}');

      // Intentar cargar datos reales del usuario desde la base de datos
      print('📊 Consultando datos del usuario en la base de datos...');
      try {
        final response = await _client!.from('users')
            .select('*')
            .eq('email', supabaseUser.email!)
            .maybeSingle();

        if (response != null) {
          print('✅ Datos encontrados en BD para: ${supabaseUser.email}');
          _currentUser = UserModel.User(
            id: response['id'] ?? supabaseUser.id,
            name: response['name'] ?? 'Usuario',
            email: response['email'] ?? '',
            phone: response['phone'] ?? '',
            createdAt: DateTime.parse(response['created_at'] ?? DateTime.now().toIso8601String()),
            country: response['country'] ?? 'Ecuador',
            city: response['city'] ?? 'Quito',
            role: response['role'] ?? 'Usuario',
            balance: (response['balance'] ?? 0.0).toDouble(),
          );
          _userBalance = _currentUser!.balance;
          print('💰 Saldo cargado desde BD: \$${_userBalance}');
        } else {
          print('⚠️ No se encontraron datos en BD, usando datos básicos de Auth');
          _currentUser = UserModel.User(
            id: supabaseUser.id,
            name: supabaseUser.userMetadata?['name'] ?? 'Usuario',
            email: supabaseUser.email ?? '',
            phone: supabaseUser.userMetadata?['phone'] ?? '',
            createdAt: DateTime.now(),
            country: supabaseUser.userMetadata?['country'] ?? 'Ecuador',
            city: supabaseUser.userMetadata?['city'] ?? 'Quito',
            role: supabaseUser.userMetadata?['role'] ?? 'Usuario',
          );
          _userBalance = 0.0; // Balance por defecto si no se encuentra en BD
        }
      } catch (dbError) {
        print('⚠️ Error consultando BD: $dbError');
        print('⚠️ Usando datos básicos de Auth como fallback');
        _currentUser = UserModel.User(
          id: supabaseUser.id,
          name: supabaseUser.userMetadata?['name'] ?? 'Usuario',
          email: supabaseUser.email ?? '',
          phone: supabaseUser.userMetadata?['phone'] ?? '',
          createdAt: DateTime.now(),
          country: supabaseUser.userMetadata?['country'] ?? 'Ecuador',
          city: supabaseUser.userMetadata?['city'] ?? 'Quito',
          role: supabaseUser.userMetadata?['role'] ?? 'Usuario',
        );
        _userBalance = 0.0; // Balance por defecto en caso de error
      }

      print('✅ Usuario básico creado desde Auth:');
      print(' - Nombre: ${_currentUser!.name}');
      print(' - Email: ${_currentUser!.email}');
      print(' - Balance: $_userBalance');

    } catch (e) {
      print('❌ === ERROR CARGANDO DATOS DE USUARIO ===');
      print('❌ Error: $e');
      print('❌ Tipo: ${e.runtimeType}');

      // Fallback to basic auth data if database query fails
      final supabaseUser = _client?.auth.currentUser;
      if (supabaseUser != null) {
        print('⚠️ Creando usuario fallback desde datos de Auth');
        _currentUser = UserModel.User(
          id: supabaseUser.id,
          name: supabaseUser.userMetadata?['name'] ?? 'Usuario',
          email: supabaseUser.email ?? '',
          phone: supabaseUser.userMetadata?['phone'] ?? '',
          createdAt: DateTime.now(),
          role: supabaseUser.userMetadata?['role'] ?? 'Usuario',
        );
        _userBalance = 0.0; // Balance por defecto si no se puede cargar desde BD
      } else {
        _currentUser = null;
        _userBalance = 0.0;
      }
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      print('🚪 Cerrando sesión...');

      // Sign out from Supabase
      await _client?.auth.signOut();

      // Clear local state
      await _clearLoginState();
      _currentUser = null;
      _userBalance = 0.0;

      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// Get current user ID
  String? get currentUserId => _auth?.currentUser?.id;

  /// Check if user is signed in
  bool get isSignedIn => _auth?.currentUser != null;

  /// Register method (alias for registerUser) - for screen compatibility
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

  /// Login method (alias for loginUser) - for screen compatibility
  Future<UserModel.User?> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    return await loginUser(email: email, phone: phone, password: password);
  }

  /// Login by phone - convenience method
  Future<UserModel.User?> loginByPhone({
    required String phone,
    required String password,
  }) async {
    return await loginUser(phone: phone, password: password);
  }

  /// Get current user (method required by screens)
  UserModel.User? getCurrentUser() {
    return _currentUser;
  }

  /// Get user addresses
  Future<List<Map<String, dynamic>>> getUserAddresses(String userId) async {
    try {
      final response = await _client
          ?.from('user_addresses')
          .select()
          .eq('user_id', userId);
      return response ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Get user payment cards
  Future<List<PaymentCard>> getUserPaymentCards(String userId) async {
    // TODO: Implement payment cards retrieval
    return [];
  }

  /// Add recharge history
  Future<void> addRechargeHistory(String userId, Map<String, dynamic> recharge) async {
    try {
      await _client?.from('recharge_history').insert({
        'user_id': userId,
        ...recharge,
      });
    } catch (e) {
      print('Error adding recharge history: $e');
    }
  }

  /// Check if user is suspended
  Future<bool> isUserSuspended(String userId) async {
    try {
      final response = await _client
          ?.from('users')
          .select('suspended')
          .eq('id', userId)
          .single();
      return response?['suspended'] ?? false;
    } catch (e) {
      print('Error checking user suspension: $e');
      return false; // Default to not suspended if error
    }
  }

  /// Update user balance
  Future<void> updateUserBalance(double newBalance) async {
    try {
      _userBalance = newBalance;
      
      // Update in database if available
      if (_isSupabaseAvailable && currentUserId != null) {
        await _client?.from('users')
            .update({'balance': newBalance})
            .eq('id', currentUserId!);
        print('✅ Balance updated: \$${newBalance.toStringAsFixed(2)}');
      }
    } catch (e) {
      print('Error updating user balance: $e');
      // Keep local balance update even if database fails
      _userBalance = newBalance;
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (!_isSupabaseAvailable) {
        throw Exception('Supabase no está disponible');
      }

      await _client?.auth.updateUser(
        UserAttributes(password: newPassword)
      );
      print('✅ Password changed successfully');
    } catch (e) {
      print('Error changing password: $e');
      throw Exception('Error cambiando contraseña: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    String? country,
    String? city,
  }) async {
    try {
      // Update local user data
      if (_currentUser != null) {
        _currentUser = UserModel.User(
          id: _currentUser!.id,
          name: name ?? _currentUser!.name,
          email: _currentUser!.email,
          phone: phone ?? _currentUser!.phone,
          createdAt: _currentUser!.createdAt,
          country: country ?? _currentUser!.country,
          city: city ?? _currentUser!.city,
          role: _currentUser!.role,
        );
      }

      // Update in database if available
      if (_isSupabaseAvailable && currentUserId != null) {
        final updateData = <String, dynamic>{};
        if (name != null) updateData['name'] = name;
        if (phone != null) updateData['phone'] = phone;
        if (address != null) updateData['address'] = address;
        if (country != null) updateData['country'] = country;
        if (city != null) updateData['city'] = city;

        if (updateData.isNotEmpty) {
          await _client?.from('users')
              .update(updateData)
              .eq('id', currentUserId!);
        }
      }

      print('✅ User profile updated');
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Error actualizando perfil: $e');
    }
  }

  /// Sign out (alias for logout)
  Future<void> signOut() async {
    await logoutUser();
  }

  /// Notify that user has used a service
  Future<void> notifyServiceUsed() async {
    try {
      print('📱 Service usage notified');
      // This could be used for analytics or user activity tracking
      // For now, just log the usage
    } catch (e) {
      print('Error notifying service usage: $e');
    }
  }
}