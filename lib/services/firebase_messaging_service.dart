import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    try {
      // Inicializar Firebase si no está inicializado
      await Firebase.initializeApp();
      
      // Solicitar permisos de notificación
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Usuario autorizó las notificaciones push');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ Usuario autorizó notificaciones provisionales');
      } else {
        print('❌ Usuario denegó las notificaciones push');
        return;
      }

      // Obtener token FCM
      await _getFCMToken();

      // Configurar manejadores de mensajes
      _setupMessageHandlers();

    } catch (e) {
      print('❌ Error inicializando Firebase Messaging: $e');
    }
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        print('✅ FCM Token obtenido: ${_fcmToken!.substring(0, 20)}...');
        
        // Guardar token en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
        
        // Enviar token al backend (opcional)
        await _sendTokenToBackend(_fcmToken!);
      } else {
        print('❌ No se pudo obtener el FCM Token');
      }
    } catch (e) {
      print('❌ Error obteniendo FCM Token: $e');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      // Aquí podrías enviar el token a tu backend para asociarlo con el usuario
      print('📱 Token FCM listo para enviar al backend: ${token.substring(0, 20)}...');
    } catch (e) {
      print('❌ Error enviando token al backend: $e');
    }
  }

  void _setupMessageHandlers() {
    // Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Mensaje recibido en primer plano: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Manejar mensajes cuando la app está en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Mensaje abierto desde segundo plano: ${message.notification?.title}');
      _handleBackgroundMessage(message);
    });

    // Manejar mensajes cuando la app está cerrada
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 Mensaje recibido con app cerrada: ${message.notification?.title}');
        _handleBackgroundMessage(message);
      }
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Mostrar notificación local o diálogo
    print('📱 Procesando mensaje en primer plano:');
    print('   Título: ${message.notification?.title}');
    print('   Cuerpo: ${message.notification?.body}');
    print('   Datos: ${message.data}');
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Manejar mensaje cuando la app está en segundo plano
    print('📱 Procesando mensaje en segundo plano:');
    print('   Título: ${message.notification?.title}');
    print('   Cuerpo: ${message.notification?.body}');
    print('   Datos: ${message.data}');
  }

  Future<void> refreshToken() async {
    try {
      await _getFCMToken();
    } catch (e) {
      print('❌ Error refrescando FCM Token: $e');
    }
  }

  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      print('❌ Error obteniendo token almacenado: $e');
      return null;
    }
  }
}

// Función para manejar mensajes en segundo plano (debe ser top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Mensaje manejado en segundo plano: ${message.messageId}');
}
