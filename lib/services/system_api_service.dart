import 'dart:convert';
import 'package:http/http.dart' as http;

/// 🛠️ Servicio para conectar con Backend Sistema
/// Maneja: Órdenes, Usuarios, Productos, Carrito, Notificaciones
class SystemApiService {
  // 🔗 URL del backend sistema - RENDER.COM (PRODUCCIÓN)
  static const String _baseUrl = 'https://cubalink23-system.onrender.com';
  
  // Headers estándar
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// 🏥 Health Check - Verificar si backend sistema está activo
  static Future<bool> isBackendActive() async {
    try {
      print('🔄 Verificando backend sistema...');
      print('🌐 URL: $_baseUrl/api/health');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/health'),
        headers: _headers,
      ).timeout(Duration(seconds: 10));

      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Backend Sistema ACTIVO');
        return true;
      } else {
        print('⚠️ Backend Sistema respondió: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Backend Sistema NO disponible: $e');
      return false;
    }
  }

  // ==================== ORDERS API ====================

  /// 📦 Crear nueva orden
  static Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> orderData) async {
    try {
      print('🛒 Creando orden en backend sistema...');
      print('📋 Order data: ${orderData.keys}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/orders'),
        headers: _headers,
        body: json.encode(orderData),
      ).timeout(Duration(seconds: 15));

      print('📡 Create order status: ${response.statusCode}');
      print('📡 Create order body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Orden creada exitosamente: ${result['order_id']}');
        return result;
      } else {
        print('❌ Error creando orden: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Error en createOrder: $e');
      return null;
    }
  }

  /// 📋 Obtener órdenes de usuario
  static Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      print('🔍 Obteniendo órdenes para usuario: $userId');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/orders/user/$userId'),
        headers: _headers,
      ).timeout(Duration(seconds: 10));

      print('📡 Get orders status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final orders = result['orders'] as List<dynamic>? ?? [];
        print('✅ Órdenes obtenidas: ${orders.length}');
        return orders.cast<Map<String, dynamic>>();
      } else {
        print('❌ Error obteniendo órdenes: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 Error en getUserOrders: $e');
      return [];
    }
  }

  /// 📊 Actualizar estado de orden
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      print('🔄 Actualizando orden $orderId a estado: $status');
      
      final response = await http.put(
        Uri.parse('$_baseUrl/api/orders/$orderId/status'),
        headers: _headers,
        body: json.encode({'status': status}),
      ).timeout(Duration(seconds: 10));

      print('📡 Update status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Estado actualizado');
        return true;
      } else {
        print('❌ Error actualizando estado: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Error en updateOrderStatus: $e');
      return false;
    }
  }

  // ==================== USERS API ====================

  /// 👤 Obtener datos de usuario
  static Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/$userId'),
        headers: _headers,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['user'];
      } else {
        print('❌ Error obteniendo usuario: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 Error en getUser: $e');
      return null;
    }
  }

  /// 💰 Actualizar saldo de usuario
  static Future<bool> updateUserBalance(String userId, double balance) async {
    try {
      print('💰 Actualizando saldo usuario $userId: $balance');
      
      final response = await http.put(
        Uri.parse('$_baseUrl/api/users/$userId/balance'),
        headers: _headers,
        body: json.encode({'balance': balance}),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ Saldo actualizado');
        return true;
      } else {
        print('❌ Error actualizando saldo: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Error en updateUserBalance: $e');
      return false;
    }
  }

  // ==================== ACTIVITIES API ====================

  /// 📊 Agregar actividad
  static Future<bool> addActivity(String userId, String type, String description, {double? amount}) async {
    try {
      print('📝 Agregando actividad: $type');
      
      final activityData = {
        'user_id': userId,
        'type': type,
        'description': description,
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/activities'),
        headers: _headers,
        body: json.encode(activityData),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ Actividad agregada');
        return true;
      } else {
        print('❌ Error agregando actividad: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Error en addActivity: $e');
      return false;
    }
  }

  /// 📋 Obtener actividades de usuario
  static Future<List<Map<String, dynamic>>> getUserActivities(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/activities/user/$userId'),
        headers: _headers,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final activities = result['activities'] as List<dynamic>? ?? [];
        return activities.cast<Map<String, dynamic>>();
      } else {
        print('❌ Error obteniendo actividades: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 Error en getUserActivities: $e');
      return [];
    }
  }

  // ==================== NOTIFICATIONS API ====================

  /// 🔔 Enviar notificación
  static Future<bool> sendNotification(String userId, String title, String message, {Map<String, dynamic>? data}) async {
    try {
      final notificationData = {
        'user_id': userId,
        'title': title,
        'message': message,
        'data': data ?? {},
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notifications'),
        headers: _headers,
        body: json.encode(notificationData),
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('💥 Error en sendNotification: $e');
      return false;
    }
  }

  /// 🔔 Obtener notificaciones de usuario
  static Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/notifications/user/$userId'),
        headers: _headers,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final notifications = result['notifications'] as List<dynamic>? ?? [];
        return notifications.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('💥 Error en getUserNotifications: $e');
      return [];
    }
  }
}
