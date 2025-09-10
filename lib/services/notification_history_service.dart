import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationHistoryService {
  static final NotificationHistoryService _instance = NotificationHistoryService._internal();
  factory NotificationHistoryService() => _instance;
  NotificationHistoryService._internal();

  final String _baseUrl = 'https://cubalink23-backend.onrender.com';

  /// Obtener historial de notificaciones para la campanita
  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    try {
      print('📋 Obteniendo historial de notificaciones...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/api/notifications/history'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['notifications'] != null) {
          final notifications = List<Map<String, dynamic>>.from(data['notifications']);
          print('✅ ${notifications.length} notificaciones en historial');
          return notifications;
        }
      }
      
      print('⚠️ No se pudieron obtener notificaciones del historial');
      return [];
    } catch (e) {
      print('❌ Error obteniendo historial: $e');
      return [];
    }
  }

  /// Marcar notificación como leída
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      print('📖 Marcando notificación como leída: $notificationId');
      
      // Aquí podrías implementar lógica para marcar como leída en Supabase
      // Por ahora solo retornamos true
      return true;
    } catch (e) {
      print('❌ Error marcando notificación como leída: $e');
      return false;
    }
  }

  /// Limpiar notificaciones expiradas
  Future<bool> cleanupExpiredNotifications() async {
    try {
      print('🧹 Limpiando notificaciones expiradas...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/api/notifications/cleanup'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final deletedCount = data['deleted_count'] ?? 0;
          print('✅ $deletedCount notificaciones expiradas eliminadas');
          return true;
        }
      }
      
      print('⚠️ No se pudieron limpiar notificaciones expiradas');
      return false;
    } catch (e) {
      print('❌ Error limpiando notificaciones: $e');
      return false;
    }
  }
}







