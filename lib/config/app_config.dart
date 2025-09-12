/// Configuración de la aplicación para diferentes entornos
class AppConfig {
  // URLs del backend según el entorno
  static const String _productionBackendUrl = 'https://cubalink23-backend.onrender.com';
  static const String _localBackendUrl = 'http://localhost:3005';
  
  // Detectar si estamos en desarrollo o producción
  static bool get isDevelopment {
    // En Flutter, puedes detectar si es debug mode
    bool isDebug = false;
    assert(isDebug = true); // Solo se ejecuta en debug mode
    return isDebug;
  }
  
  // URL del backend según el entorno
  static String get backendUrl {
    return isDevelopment ? _localBackendUrl : _productionBackendUrl;
  }
  
  // Configuración de Square (siempre la misma)
  static const String squareBaseUrl = 'https://connect.squareupsandbox.com';
  static const String squareApplicationId = 'sandbox-sq0idb-IsIJtKqx2OHdVJjYmg6puA';
  static const String squareLocationId = 'LZVTP0YQ9YQBB';
  static const String squareAccessToken = 'EAAAl4WnC2APxLhZXN1HJrn5CPWQGd-wXe_PpQm6vPvdOBHj1xWINxP3s7uOpvYO';
  static const String squareEnvironment = 'sandbox';
  
  // Configuración de Supabase (siempre la misma)
  static const String supabaseUrl = 'https://zgqrhzuhrwudckwesybg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ';
  
  // Configuración de webhooks
  static String get webhookUrl => '$backendUrl/webhooks/square';
  
  // Configuración de timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration paymentTimeout = Duration(minutes: 5);
  
  // Configuración de reintentos
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Logs
  static void logConfig() {
    print('🔧 AppConfig cargado:');
    print('   Backend URL: $backendUrl');
    print('   Square URL: $squareBaseUrl');
    print('   Supabase URL: $supabaseUrl');
    print('   Webhook URL: $webhookUrl');
    print('   Entorno: ${isDevelopment ? "DESARROLLO" : "PRODUCCIÓN"}');
  }
}


