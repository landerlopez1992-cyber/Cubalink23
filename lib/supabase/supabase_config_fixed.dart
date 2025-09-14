import 'package:supabase_flutter/supabase_flutter.dart';

enum SupabaseStatus {
  uninitialized,
  initializing,
  initialized,
  error,
}

class SupabaseConfigFixed {
  // Configuración de Supabase para Tu Recarga (versión fija)
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
  
  static SupabaseClient? _client;
  static bool _isInitialized = false;
  static SupabaseStatus _status = SupabaseStatus.uninitialized;
  
  /// Inicializa Supabase - debe llamarse en main()
  static Future<void> initialize() async {
    _status = SupabaseStatus.initializing;
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: false,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      _status = SupabaseStatus.initialized;
      print('✅ SupabaseConfigFixed inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando SupabaseConfigFixed: $e');
      _isInitialized = false;
      _status = SupabaseStatus.error;
    }
  }

  /// Inicialización asíncrona (alias para initialize)
  static Future<void> initializeAsync() async {
    await initialize();
  }
  
  /// Cliente Supabase - null si no está inicializado o falló
  static SupabaseClient? get safeClient {
    if (!_isInitialized || _client == null) {
      print('⚠️ SupabaseConfigFixed no inicializado - usando modo offline');
      return null;
    }
    return _client;
  }
  
  /// Cliente Supabase - lanza excepción si no está disponible
  static SupabaseClient get client {
    if (!_isInitialized || _client == null) {
      throw Exception('SupabaseConfigFixed no inicializado. Llama a SupabaseConfigFixed.initialize() primero.');
    }
    return _client!;
  }
  
  /// Verifica si Supabase está disponible
  static bool get isAvailable => _isInitialized && _client != null;
  
  /// Estado de inicialización
  static bool get isInitialized => _isInitialized;

  /// Estado actual de Supabase
  static SupabaseStatus get status => _status;
}