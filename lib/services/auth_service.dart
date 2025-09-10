import 'package:cubalink23/models/user.dart' as UserModel;
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/user_role_service.dart';

/// Main authentication service that delegates to Supabase
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();
  
  final SupabaseAuthService _supabaseAuth = SupabaseAuthService.instance;
  final UserRoleService _roleService = UserRoleService();
  
  /// Get current user
  UserModel.User? get currentUser => _supabaseAuth.currentUser;
  
  /// Get user balance
  double get userBalance => _supabaseAuth.userBalance;
  
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
    final user = await _supabaseAuth.loginUser(
      email: email,
      password: password,
    );
    
    // Si el login es exitoso, cargar datos de rol
    if (user != null) {
      await _loadUserRoleData(email);
    }
    
    return user;
  }
  
  /// Logout user
  Future<void> logoutUser() async {
    await _supabaseAuth.logoutUser();
    await _roleService.clearUserData();
  }
  
  /// Check if user is suspended
  Future<bool> isUserSuspended(String userId) async {
    return await _supabaseAuth.isUserSuspended(userId);
  }
  
  /// Update user balance
  Future<void> updateUserBalance(double newBalance) async {
    await _supabaseAuth.updateUserBalance(newBalance);
  }
  
  /// Load current user data
  Future<void> loadCurrentUserData() async {
    await _supabaseAuth.loadCurrentUserData();
    
    // Cargar datos de rol si hay un usuario actual
    final user = _supabaseAuth.currentUser;
    if (user != null && user.email.isNotEmpty) {
      await _loadUserRoleData(user.email);
    }
  }
  
  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _supabaseAuth.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
  
  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    String? country,
    String? city,
  }) async {
    await _supabaseAuth.updateUserProfile(
      name: name,
      phone: phone,
      address: address,
      country: country,
      city: city,
    );
  }
  
  /// Sign out (alias for logout)
  Future<void> signOut() async {
    await _supabaseAuth.signOut();
    await _roleService.clearUserData();
  }
  
  /// Notify that user has used a service
  Future<void> notifyServiceUsed() async {
    await _supabaseAuth.notifyServiceUsed();
  }
  
  /// Cargar datos de rol del usuario
  Future<void> _loadUserRoleData(String email) async {
    try {
      await _roleService.initialize();
      await _roleService.getUserByEmail(email);
      print('✅ Datos de rol cargados para: $email');
    } catch (e) {
      print('❌ Error cargando datos de rol: $e');
    }
  }
  
  /// Obtener servicio de roles
  UserRoleService get roleService => _roleService;
  
  /// Verificar si el usuario tiene un rol especial
  bool get hasSpecialRole => _roleService.hasSpecialRole;
  
  /// Verificar si es vendedor
  bool get isVendor => _roleService.isVendor;
  
  /// Verificar si es repartidor
  bool get isDelivery => _roleService.isDelivery;
  
  /// Verificar si es administrador
  bool get isAdmin => _roleService.isAdmin;
  
  /// Obtener rol actual
  String? get currentUserRole => _roleService.currentUserRole;
  
  /// Obtener texto del rol para mostrar
  String get roleDisplayText => _roleService.roleDisplayText;
  
  /// Obtener nombre para mostrar
  String get displayName => _roleService.displayName;
  
  // Constructor factory for compatibility
  factory AuthService() => instance;
}