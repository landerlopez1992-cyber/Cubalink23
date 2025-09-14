import 'package:flutter/material.dart';
import 'package:cubalink23/services/push_notification_service.dart';
import 'package:cubalink23/widgets/push_notification_dialog.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final PushNotificationService _pushService = PushNotificationService();
  BuildContext? _context;
  bool _isChecking = false;
  DateTime? _lastCheckTime;

  /// Inicializar el manager con el contexto
  void initialize(BuildContext context) {
    _context = context;
    _startPeriodicCheck();
  }

  /// Iniciar verificación periódica de notificaciones
  void _startPeriodicCheck() {
    // Verificar cada 30 segundos
    Future.delayed(const Duration(seconds: 30), () {
      if (_context != null && !_isChecking) {
        _checkForNotifications();
        _startPeriodicCheck(); // Continuar el ciclo
      }
    });
  }

  /// Verificar notificaciones nuevas
  Future<void> _checkForNotifications() async {
    if (_context == null || _isChecking) return;

    _isChecking = true;
    
    try {
      final notifications = await _pushService.getPendingNotifications();
      
      if (notifications.isNotEmpty) {
        // Mostrar la notificación más reciente
        final latestNotification = notifications.first;
        await _showNotificationDialog(latestNotification);
      }
    } catch (e) {
      print('❌ Error verificando notificaciones: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Mostrar diálogo de notificación
  Future<void> _showNotificationDialog(Map<String, dynamic> notification) async {
    if (_context == null) return;

    final title = notification['title'] ?? 'Nueva Notificación';
    final message = notification['message'] ?? '';
    final isUrgent = notification['is_urgent'] == true;
    final notificationId = notification['id'];

    await PushNotificationDialog.show(
      context: _context!,
      title: title,
      message: message,
      isUrgent: isUrgent,
      onAccept: () {
        // Marcar como leída
        if (notificationId != null) {
          _pushService.markNotificationAsRead(notificationId);
        }
        print('✅ Notificación aceptada: $title');
      },
      onDismiss: () {
        print('📖 Notificación cerrada: $title');
      },
    );
  }

  /// Verificar notificaciones manualmente
  Future<void> checkNotificationsManually() async {
    if (_context == null) return;
    
    await _checkForNotifications();
  }

  /// Limpiar recursos
  void dispose() {
    _context = null;
    _isChecking = false;
  }
}


