import 'package:flutter/material.dart';
import 'package:cubalink23/services/user_role_service.dart';
import 'package:cubalink23/supabase/supabase_config.dart';

class DeliveryNotificationsScreen extends StatefulWidget {
  const DeliveryNotificationsScreen({Key? key}) : super(key: key);

  @override
  _DeliveryNotificationsScreenState createState() => _DeliveryNotificationsScreenState();
}

class _DeliveryNotificationsScreenState extends State<DeliveryNotificationsScreen> {
  final UserRoleService _roleService = UserRoleService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      // Simular notificaciones del panel admin web
      // En producción, esto vendría de Supabase
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        _notifications = [
          {
            'id': '1',
            'title': 'Pedido Atrasado',
            'message': 'La orden #12345 está atrasada. Cliente esperando desde hace 30 minutos.',
            'type': 'urgent',
            'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
            'orderId': '12345',
            'read': false,
          },
          {
            'id': '2',
            'title': 'Producto Dañado',
            'message': 'Reporte de producto dañado en orden #12340. Contactar al cliente inmediatamente.',
            'type': 'warning',
            'timestamp': DateTime.now().subtract(Duration(minutes: 15)),
            'orderId': '12340',
            'read': false,
          },
          {
            'id': '3',
            'title': 'Nueva Orden Asignada',
            'message': 'Se te ha asignado una nueva orden #12350 en tu zona.',
            'type': 'info',
            'timestamp': DateTime.now().subtract(Duration(minutes: 30)),
            'orderId': '12350',
            'read': true,
          },
          {
            'id': '4',
            'title': 'Recordatorio de Entrega',
            'message': 'Recuerda entregar la orden #12335 antes de las 6:00 PM.',
            'type': 'reminder',
            'timestamp': DateTime.now().subtract(Duration(hours: 1)),
            'orderId': '12335',
            'read': true,
          },
          {
            'id': '5',
            'title': 'Cliente No Disponible',
            'message': 'Cliente de orden #12330 no disponible. Reintentar en 30 minutos.',
            'type': 'warning',
            'timestamp': DateTime.now().subtract(Duration(hours: 2)),
            'orderId': '12330',
            'read': true,
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando notificaciones: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Color(0xFF1976D2),
        title: Text(
          'Notificaciones',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1976D2),
              ),
            )
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: Color(0xFF1976D2),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Las notificaciones del panel admin aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final type = notification['type'] as String;
    final isRead = notification['read'] as bool;
    final timestamp = notification['timestamp'] as DateTime;
    
    Color cardColor;
    Color iconColor;
    IconData icon;
    
    switch (type) {
      case 'urgent':
        cardColor = Colors.red.shade50;
        iconColor = Colors.red.shade600;
        icon = Icons.priority_high;
        break;
      case 'warning':
        cardColor = Colors.orange.shade50;
        iconColor = Colors.orange.shade600;
        icon = Icons.warning;
        break;
      case 'info':
        cardColor = Colors.blue.shade50;
        iconColor = Colors.blue.shade600;
        icon = Icons.info;
        break;
      case 'reminder':
        cardColor = Colors.green.shade50;
        iconColor = Colors.green.shade600;
        icon = Icons.schedule;
        break;
      default:
        cardColor = Colors.grey.shade50;
        iconColor = Colors.grey.shade600;
        icon = Icons.notifications;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey.shade300 : iconColor.withOpacity(0.3),
          width: isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              notification['message'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[500],
                ),
                SizedBox(width: 4),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (!isRead) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'NUEVO',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isRead ? Icons.mark_email_unread : Icons.mark_email_read,
            color: iconColor,
          ),
          onPressed: () => _toggleReadStatus(notification),
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  void _toggleReadStatus(Map<String, dynamic> notification) {
    setState(() {
      notification['read'] = !notification['read'];
    });
    
    // En producción, actualizar en Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notification['read'] ? 'Marcada como leída' : 'Marcada como no leída',
        ),
        backgroundColor: Color(0xFF1976D2),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Marcar como leída si no lo está
    if (!notification['read']) {
      _toggleReadStatus(notification);
    }
    
    // Mostrar detalles de la notificación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Orden: ${notification['orderId']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  _formatTimestamp(notification['timestamp']),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
          if (notification['orderId'] != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navegar a detalles de la orden
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navegando a orden ${notification['orderId']}'),
                    backgroundColor: Color(0xFF1976D2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: Text('Ver Orden'),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}





