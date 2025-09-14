import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Configuración de Supabase para CubaLink23
  static const String supabaseUrl = 'https://zgqrhzuhrwudckwesybg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ';
  
  static SupabaseClient? _client;
  static bool _isInitialized = false;
  
  /// Inicializa Supabase - debe llamarse en main()
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: false,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      print('✅ Supabase inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando Supabase: $e');
      _isInitialized = false;
    }
  }
  
  /// Cliente Supabase - null si no está inicializado o falló
  static SupabaseClient? get safeClient {
    if (!_isInitialized || _client == null) {
      print('⚠️ Supabase no inicializado - usando modo offline');
      return null;
    }
    return _client;
  }
  
  /// Cliente Supabase - lanza excepción si no está disponible
  static SupabaseClient get client {
    if (!_isInitialized || _client == null) {
      throw Exception('Supabase no inicializado. Llama a SupabaseConfig.initialize() primero.');
    }
    return _client!;
  }
  
  /// Verifica si Supabase está disponible
  static bool get isAvailable => _isInitialized && _client != null;
  
  /// Estado de inicialización
  static bool get isInitialized => _isInitialized;
}