import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cubalink23/services/firebase_repository.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseRepository _firebaseRepository = FirebaseRepository.instance;
  final String _baseUrl = 'https://cubalink23-backend.onrender.com';

  /// Obtener notificaciones push pendientes
  Future<List<Map<String, dynamic>>> getPendingNotifications() async {
    try {
      print('🔔 Obteniendo notificaciones push pendientes...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/api/notifications'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['notifications'] != null) {
          final notifications = List<Map<String, dynamic>>.from(data['notifications']);
          print('✅ ${notifications.length} notificaciones obtenidas');
          return notifications;
        }
      }
      
      print('⚠️ No se pudieron obtener notificaciones');
      return [];
    } catch (e) {
      print('❌ Error obteniendo notificaciones: $e');
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

  /// Verificar si hay notificaciones nuevas
  Future<bool> hasNewNotifications() async {
    try {
      final notifications = await getPendingNotifications();
      return notifications.isNotEmpty;
    } catch (e) {
      print('❌ Error verificando notificaciones nuevas: $e');
      return false;
    }
  }

  /// Obtener la última notificación
  Future<Map<String, dynamic>?> getLatestNotification() async {
    try {
      final notifications = await getPendingNotifications();
      if (notifications.isNotEmpty) {
        return notifications.first;
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo última notificación: $e');
      return null;
    }
  }
}


