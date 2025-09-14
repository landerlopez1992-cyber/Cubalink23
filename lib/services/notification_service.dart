import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:cubalink23/services/supabase_service.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();
  
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  /// Initialize notification service
  Future<void> initialize() async {
    try {
      print('🔔 Inicializando servicio de notificaciones...');
      
      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings initializationSettingsIOS = 
          DarwinInitializationSettings();
      
      const InitializationSettings initializationSettings = 
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          print('Notification tapped: ${response.payload}');
        },
      );
      
      print('✅ Servicio de notificaciones inicializado');
    } catch (e) {
      print('❌ Error inicializando notificaciones: $e');
    }
  }
  
  /// Show local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = 
          AndroidNotificationDetails(
        'turecarga_channel',
        'TuRecarga Notifications',
        channelDescription: 'Notificaciones de TuRecarga',
        importance: Importance.max,
        priority: Priority.high,
      );
      
      const DarwinNotificationDetails iOSPlatformChannelSpecifics = 
          DarwinNotificationDetails();
      
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      
      print('✅ Notificación mostrada: $title');
    } catch (e) {
      print('❌ Error mostrando notificación: $e');
    }
  }
  
  /// Send push notification to user (via Supabase)
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    String? type,
  }) async {
    try {
      print('📤 Enviando notificación a usuario: $userId');
      
      // Store notification in database for in-app display
      await SupabaseService.instance.insert('notifications', {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type ?? 'general',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ Notificación guardada en base de datos');
    } catch (e) {
      print('❌ Error enviando notificación: $e');
    }
  }
  
  /// Get notifications for a user
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final notifications = await SupabaseService.instance.select(
        'notifications',
        where: 'user_id',
        equals: userId,
        orderBy: 'created_at',
        ascending: false,
        limit: 50,
      );
      
      return notifications;
    } catch (e) {
      print('❌ Error obteniendo notificaciones: $e');
      return [];
    }
  }
  
  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await SupabaseService.instance.update('notifications', notificationId, {
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error marcando notificación como leída: $e');
    }
  }
  
  /// Create notification (for compatibility with support chat)
  Future<void> createNotification(Map<String, dynamic> data) async {
    try {
      await SupabaseService.instance.insert('notifications', {
        'user_id': data['user_id'] ?? 'admin',
        'title': data['title'] ?? 'Notificación',
        'message': data['message'] ?? '',
        'type': data['type'] ?? 'general',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'data': data['data'],
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  /// Send chat notification
  Future<void> sendChatNotification({
    required String toUserId,
    required String fromUserName,
    required String message,
  }) async {
    try {
      await sendNotificationToUser(
        userId: toUserId,
        title: 'Nuevo mensaje de $fromUserName',
        message: message,
        type: 'chat',
      );
    } catch (e) {
      print('❌ Error enviando notificación de chat: $e');
    }
  }
}