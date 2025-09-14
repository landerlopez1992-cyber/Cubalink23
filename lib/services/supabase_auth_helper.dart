import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:cubalink23/models/user.dart' as UserModel;
import 'package:cubalink23/services/supabase_client_service.dart';

/// Enhanced authentication helper for CubaLink23 app
/// Follows Supabase best practices for authentication management
class CubaLink23AuthService {
  static CubaLink23AuthService? _instance;
  static CubaLink23AuthService get instance => _instance ??= CubaLink23AuthService._();
  
  CubaLink23AuthService._();
  
  final SupabaseClient _client = SupabaseConfig.client;
  final SupabaseClientService _supabaseService = SupabaseClientService.instance;
  
  // ==================== AUTH STATE MANAGEMENT ====================
  
  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  /// Check if user is currently authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;
  
  /// Get current authenticated user (basic info from auth)
  User? get currentAuthUser => _client.auth.currentUser;
  
  /// Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;
  
  /// Get current user email
  String? get currentUserEmail => _client.auth.currentUser?.email;
  
  // ==================== AUTHENTICATION ACTIONS ====================
  
  /// Sign up new user with comprehensive error handling
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? referralCode,
  }) async {
    try {
      print('🔐 Iniciando registro en CubaLink23: $email');
      
      // Validate input
      if (!_isValidEmail(email)) {
        return AuthResult.error('Formato de email inválido');
      }
      
      if (password.length < 6) {
        return AuthResult.error('La contraseña debe tener al menos 6 caracteres');
      }
      
      if (name.trim().isEmpty) {
        return AuthResult.error('El nombre es requerido');
      }
      
      if (phone.trim().isEmpty) {
        return AuthResult.error('El teléfono es requerido');
      }
      
      // Generate referral code for new user
      final userReferralCode = _generateReferralCode();
      
      // Sign up with Supabase Auth
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name.trim(),
          'phone': phone.trim(),
          'referral_code': userReferralCode,
          'referred_by_code': referralCode,
        },
      );
      
      if (response.user == null) {
        return AuthResult.error('Error creando cuenta de usuario');
      }
      
      final userId = response.user!.id;
      print('✅ Usuario auth creado: $userId');
      
      // Create user profile in users table (with retry logic)
      bool profileCreated = false;
      int retries = 3;
      
      while (!profileCreated && retries > 0) {
        try {
          await _client.from('users').insert({
            'id': userId,
            'email': email.trim(),
            'name': name.trim(),
            'phone': phone.trim(),
            'balance': 0.0,
            'role': 'Usuario',
            'status': 'Activo',
            'registration_date': DateTime.now().toIso8601String(),
            'referral_code': userReferralCode,
          });
          
          profileCreated = true;
          print('✅ Perfil de usuario creado exitosamente');
          
          // Handle referral if provided
          if (referralCode != null && referralCode.trim().isNotEmpty) {
            await _handleReferral(userId, referralCode.trim());
          }
          
          // Initialize user rewards
          await _initializeUserRewards(userId);
          
        } catch (insertError) {
          retries--;
          print('⚠️ Intento ${4 - retries} de crear perfil falló: $insertError');
          if (retries == 0) {
            print('❌ Error crítico creando perfil, pero auth exitoso');
            // Continue - auth was successful even if profile creation failed
          } else {
            await Future.delayed(Duration(seconds: 1)); // Wait before retry
          }
        }
      }
      
      return AuthResult.success(
        UserModel.User(
          id: userId,
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          balance: 0.0,
          role: 'Usuario',
          status: 'Activo',
          createdAt: DateTime.now(),
        ),
      );
      
    } on AuthException catch (authError) {
      print('❌ Error de autenticación: ${authError.message}');
      return AuthResult.error(_getAuthErrorMessage(authError));
    } catch (e) {
      print('❌ Error inesperado en registro: $e');
      return AuthResult.error('Error inesperado durante el registro');
    }
  }
  
  /// Sign in existing user
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Iniciando sesión en Tu Recarga: $email');
      
      if (!_isValidEmail(email)) {
        return AuthResult.error('Formato de email inválido');
      }
      
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      if (response.user == null) {
        return AuthResult.error('Error en inicio de sesión');
      }
      
      print('✅ Sesión iniciada exitosamente: ${response.user!.id}');
      
      // NOTE: Don't load user data immediately after sign in
      // This will be done later after navigation
      
      return AuthResult.success(
        UserModel.User(
          id: response.user!.id,
          name: response.user!.userMetadata?['name'] ?? 'Usuario',
          email: response.user!.email ?? '',
          phone: response.user!.userMetadata?['phone'] ?? '',
          createdAt: DateTime.now(),
        ),
      );
      
    } on AuthException catch (authError) {
      print('❌ Error de autenticación: ${authError.message}');
      return AuthResult.error(_getAuthErrorMessage(authError));
    } catch (e) {
      print('❌ Error inesperado en login: $e');
      return AuthResult.error('Error inesperado durante el login');
    }
  }
  
  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      throw Exception('Error cerrando sesión');
    }
  }
  
  /// Reset password for user
  Future<bool> resetPassword(String email) async {
    try {
      if (!_isValidEmail(email)) {
        throw Exception('Formato de email inválido');
      }
      
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'turecarga://reset-password', // Deep link for mobile app
      );
      
      print('✅ Email de recuperación enviado a: $email');
      return true;
    } catch (e) {
      print('❌ Error enviando email de recuperación: $e');
      return false;
    }
  }
  
  /// Update user password
  Future<bool> updatePassword(String newPassword) async {
    try {
      if (newPassword.length < 6) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }
      
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      print('✅ Contraseña actualizada exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando contraseña: $e');
      return false;
    }
  }
  
  // ==================== PROFILE MANAGEMENT ====================
  
  /// Load complete user profile from database
  /// Call this after successful authentication and navigation
  Future<UserModel.User?> loadUserProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    
    return await _supabaseService.getUserProfile(userId);
  }
  
  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;
      
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name.trim();
      if (phone != null) updateData['phone'] = phone.trim();
      if (address != null) updateData['address'] = address.trim();
      
      if (updateData.isEmpty) return true;
      
      await _client.from('users').update(updateData).eq('id', userId);
      
      // Also update auth metadata
      final authUpdateData = <String, dynamic>{};
      if (name != null) authUpdateData['name'] = name.trim();
      if (phone != null) authUpdateData['phone'] = phone.trim();
      
      if (authUpdateData.isNotEmpty) {
        await _client.auth.updateUser(UserAttributes(data: authUpdateData));
      }
      
      print('✅ Perfil actualizado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando perfil: $e');
      return false;
    }
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Generate unique referral code
  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(8, (index) => chars[(random + index) % chars.length]).join();
  }
  
  /// Handle referral logic
  Future<void> _handleReferral(String newUserId, String referralCode) async {
    try {
      // Find referrer by code
      final referrerResponse = await _client
          .from('users')
          .select('id, name')
          .eq('referral_code', referralCode)
          .limit(1);
      
      if (referrerResponse.isNotEmpty) {
        final referrerId = referrerResponse.first['id'];
        
        // Create referral record
        await _client.from('referrals').insert({
          'referrer_id': referrerId,
          'referred_id': newUserId,
          'referral_code': referralCode,
          'reward_amount': 5.00, // Default reward amount
          'reward_status': 'pending',
        });
        
        print('✅ Referral procesado exitosamente');
      }
    } catch (e) {
      print('⚠️ Error procesando referral: $e');
      // Don't throw - this is not critical for registration
    }
  }
  
  /// Initialize user rewards
  Future<void> _initializeUserRewards(String userId) async {
    try {
      await _client.from('user_rewards').insert({
        'user_id': userId,
        'points': 0,
        'level': 'Bronze',
        'total_spent': 0.00,
        'total_recharges': 0,
      });
      
      print('✅ Sistema de recompensas inicializado');
    } catch (e) {
      print('⚠️ Error inicializando recompensas: $e');
      // Don't throw - this is not critical
    }
  }
  
  /// Get user-friendly auth error message
  String _getAuthErrorMessage(AuthException authError) {
    switch (authError.message.toLowerCase()) {
      case 'invalid login credentials':
        return 'Credenciales de login inválidas';
      case 'email already registered':
      case 'user already registered':
        return 'Este email ya está registrado';
      case 'password is too short':
        return 'La contraseña es demasiado corta';
      case 'invalid email':
        return 'Formato de email inválido';
      case 'signup disabled':
        return 'El registro está temporalmente deshabilitado';
      default:
        return authError.message;
    }
  }
}

// ==================== RESULT CLASSES ====================

/// Authentication result wrapper
class AuthResult {
  final bool isSuccess;
  final UserModel.User? user;
  final String? error;
  
  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
  });
  
  factory AuthResult.success(UserModel.User user) {
    return AuthResult._(isSuccess: true, user: user);
  }
  
  factory AuthResult.error(String error) {
    return AuthResult._(isSuccess: false, error: error);
  }
}