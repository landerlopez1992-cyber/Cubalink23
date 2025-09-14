import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    serverClientId: '514921114205-e17864v7035843lebaptp8j9n90to9vl.apps.googleusercontent.com',
  );

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Inicia sesión con Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      print('🔍 Iniciando proceso de autenticación con Google...');
      
      // Obtener cuenta de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ Usuario canceló el inicio de sesión');
        return null;
      }

      print('✅ Usuario de Google obtenido: ${googleUser.email}');

      // Obtener tokens de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('❌ No se pudieron obtener los tokens de Google');
        return null;
      }

      print('✅ Tokens de Google obtenidos');

      // Autenticar con Supabase usando los tokens de Google
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (response.user != null) {
        print('✅ Autenticación exitosa con Supabase');
        print('Usuario ID: ${response.user!.id}');
        print('Email: ${response.user!.email}');
        
        return response;
      } else {
        print('❌ Error: Respuesta de Supabase sin usuario');
        return null;
      }
      
    } catch (e, stackTrace) {
      print('❌ Error en signInWithGoogle: $e');
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Cierra la sesión de Google
  Future<void> signOut() async {
    try {
      print('🔍 Cerrando sesión de Google...');
      
      // Cerrar sesión en Google
      await _googleSignIn.signOut();
      
      // Cerrar sesión en Supabase
      await _supabase.auth.signOut();
      
      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ Error cerrando sesión de Google: $e');
      rethrow;
    }
  }

  /// Verifica si el usuario está autenticado
  bool get isSignedIn => _supabase.auth.currentUser != null;

  /// Obtiene el usuario actual
  User? get currentUser => _supabase.auth.currentUser;

  /// Obtiene información del usuario de Google actual
  Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      print('❌ Error obteniendo usuario actual de Google: $e');
      return null;
    }
  }

  /// Obtiene el stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}