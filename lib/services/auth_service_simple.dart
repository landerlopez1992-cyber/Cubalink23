import 'package:cubalink23/models/user.dart' as UserModel;
import 'package:cubalink23/services/supabase_auth_service.dart';

/// Simple authentication service that delegates to Supabase
class AuthServiceSimple {
  static AuthServiceSimple? _instance;
  static AuthServiceSimple get instance => _instance ??= AuthServiceSimple._();
  
  AuthServiceSimple._();
  
  final SupabaseAuthService _supabaseAuth = SupabaseAuthService.instance;
  
  /// Get current user
  UserModel.User? get currentUser => _supabaseAuth.currentUser;
  
  /// Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    return await _supabaseAuth.isUserLoggedIn();
  }
  
  /// Register user
  Future<UserModel.User?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String country,
    required String city,
  }) async {
    return await _supabaseAuth.registerUser(
      email: email,
      password: password,
      name: name,
      phone: phone,
      country: country,
      city: city,
    );
  }
  
  /// Login user
  Future<UserModel.User?> loginUser({
    required String email,
    required String password,
  }) async {
    return await _supabaseAuth.loginUser(
      email: email,
      password: password,
    );
  }
  
  /// Logout user
  Future<void> logoutUser() async {
    await _supabaseAuth.logoutUser();
  }
}