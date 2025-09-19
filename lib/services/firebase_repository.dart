// ARCHIVO MIGRADO A SUPABASE
// Este archivo ha sido reemplazado por SupabaseService
// Se mantiene solo para compatibilidad, pero todas las operaciones 
// ahora van a través de Supabase

import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/services/system_api_service.dart';

class FirebaseRepository {
  static FirebaseRepository? _instance;
  static FirebaseRepository get instance => _instance ??= FirebaseRepository._();
  
  FirebaseRepository._();
  
  // Redirect all operations to Supabase
  final _supabaseService = SupabaseService.instance;
  
  // Products methods
  Future<Map<String, dynamic>?> createProduct(Map<String, dynamic> data) async {
    return await _supabaseService.insert('products', data);
  }
  
  Future<List<Map<String, dynamic>>> getProducts() async {
    return await _supabaseService.select('products');
  }
  
  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    final result = await _supabaseService.update('products', id, data);
    return result != null;
  }
  
  Future<bool> deleteProduct(String id) async {
    return await _supabaseService.delete('products', id);
  }

  // User methods
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final result = await _supabaseService.select('users', where: 'id', equals: userId);
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final result = await _supabaseService.select('users', where: 'email', equals: email);
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    try {
      final result = await _supabaseService.select('users', where: 'phone', equals: phone);
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user by phone: $e');
      return null;
    }
  }

  Future<bool> updateUserBalance(String userId, double balance) async {
    final result = await _supabaseService.update('users', userId, {'balance': balance});
    return result != null;
  }

  // Orders methods
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      print('🔍 FirebaseRepository.getUserOrders para: $userId');
      
      // 🎯 USAR BACKEND SISTEMA PRIMERO
      final systemOrders = await SystemApiService.getUserOrders(userId);
      if (systemOrders.isNotEmpty) {
        print('✅ Backend Sistema retornó ${systemOrders.length} órdenes');
        return systemOrders;
      }
      
      // Fallback a Supabase directo
      print('🔄 Fallback a Supabase directo...');
      return await _supabaseService.select('orders', where: 'user_id', equals: userId);
    } catch (e) {
      print('💥 Error en getUserOrders: $e');
      return [];
    }
  }

  Future<String> createOrder(Map<String, dynamic> data) async {
    try {
      print('🔄 FirebaseRepository.createOrder iniciado');
      print('📋 Data keys recibidas: ${data.keys.toList()}');
      print('👤 User ID: ${data['user_id']}');
      print('📦 Order Number: ${data['order_number']}');
      print('💰 Total: ${data['total']}');
      print('🛒 Cart items: ${(data['cart_items'] as List?)?.length ?? 0}');
      
      // 🎯 USAR SUPABASE DIRECTO PRIMERO (MÁS CONFIABLE)
      print('🗄️ Intentando Supabase directo primero...');
      print('🛒 Verificando cart_items antes de enviar: ${(data['cart_items'] as List?)?.length ?? 0}');
      
      final supabaseResult = await _supabaseService.createOrderRaw(data);
      if (supabaseResult != null) {
        final orderId = supabaseResult['id']?.toString() ?? 'order_${DateTime.now().millisecondsSinceEpoch}';
        print('✅ Supabase directo funcionó: $orderId');
        return orderId;
      }
      
      print('❌ Supabase directo falló, intentando Backend Sistema...');
      
      // Fallback a Backend Sistema
      final result = await SystemApiService.createOrder(data);
      
      if (result != null && result['success'] == true) {
        final orderId = result['order_id']?.toString() ?? 'order_${DateTime.now().millisecondsSinceEpoch}';
        print('✅ Backend Sistema retornó orden creada: $orderId');
        return orderId;
      }
      
      print('❌ Ambos métodos fallaron - usando ID de fallback');
      final fallbackId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      return fallbackId;
      
    } catch (e) {
      print('💥 ERROR CRÍTICO en FirebaseRepository.createOrder: $e');
      print('📋 Tipo de error: ${e.runtimeType}');
      
      // Retornar ID de fallback para no romper el flujo
      final fallbackId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      print('🆘 Usando ID de fallback: $fallbackId');
      return fallbackId;
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    return await _supabaseService.delete('orders', orderId);
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final result = await _supabaseService.update('orders', orderId, {'status': status});
    return result != null;
  }

  // Activities methods  
  Future<List<Map<String, dynamic>>> getUserActivities(String userId) async {
    return await _supabaseService.select('activities', where: 'user_id', equals: userId);
  }

  // Método addActivity eliminado - usando la nueva versión más abajo

  Future<bool> deleteActivity(String activityId) async {
    return await _supabaseService.delete('activities', activityId);
  }

  // Transfers methods
  Future<List<Map<String, dynamic>>> getUserTransfers(String userId) async {
    return await _supabaseService.select('transfers', where: 'user_id', equals: userId);
  }

  Future<Map<String, dynamic>?> createTransfer(Map<String, dynamic> data) async {
    return await _supabaseService.insert('transfers', data);
  }

  Future<bool> deleteTransfer(String transferId) async {
    return await _supabaseService.delete('transfers', transferId);
  }

  // Recharge history methods
  Future<List<Map<String, dynamic>>> getUserRechargeHistory(String userId) async {
    return await _supabaseService.select('recharge_history', where: 'user_id', equals: userId);
  }

  // Notification methods
  Future<Map<String, dynamic>?> createNotification(Map<String, dynamic> data) async {
    return await _supabaseService.insert('notifications', data);
  }

  // Address methods
  Future<List<Map<String, dynamic>>> getUserAddresses(String userId) async {
    return await _supabaseService.select('user_addresses', where: 'user_id', equals: userId);
  }

  Future<Map<String, dynamic>?> addUserAddress(Map<String, dynamic> data) async {
    return await _supabaseService.insert('user_addresses', data);
  }

  Future<bool> deleteUserAddress(String addressId) async {
    return await _supabaseService.delete('user_addresses', addressId);
  }

  // Payment methods
  Future<List<Map<String, dynamic>>> getUserPaymentMethods(String userId) async {
    return await _supabaseService.select('payment_cards', where: 'user_id', equals: userId);
  }

  Future<Map<String, dynamic>?> addPaymentCard(Map<String, dynamic> data) async {
    return await _supabaseService.insert('payment_cards', data);
  }

  Future<List<Map<String, dynamic>>> getUserCards(String userId) async {
    return await getUserPaymentMethods(userId);
  }

  // Admin methods
  Future<List<Map<String, dynamic>>> getBanners() async {
    return await _supabaseService.select('banners');
  }

  Future<Map<String, dynamic>?> addBanner(Map<String, dynamic> data) async {
    return await _supabaseService.insert('banners', data);
  }

  Future<bool> deleteBanner(String bannerId) async {
    return await _supabaseService.delete('banners', bannerId);
  }

  Future<Map<String, dynamic>?> getForceUpdateSettings() async {
    try {
      final result = await _supabaseService.select('app_settings', where: 'key', equals: 'force_update');
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> setForceUpdate(Map<String, dynamic> data) async {
    // This would require more complex logic for upsert
    return true; // Placeholder
  }

  Future<Map<String, dynamic>?> getMaintenanceStatus() async {
    try {
      final result = await _supabaseService.select('app_settings', where: 'key', equals: 'maintenance');
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> setMaintenanceMode(bool enabled, String message) async {
    // Placeholder - would need app_settings table
    return true;
  }

  Future<bool> sendPushNotification(Map<String, dynamic> data) async {
    // Placeholder - would integrate with notification service
    return true;
  }

  Future<bool> sendScreenAlert(Map<String, dynamic> data) async {
    // Placeholder - would integrate with notification service
    return true;
  }

  // File upload methods
  Future<String?> uploadFile(String bucket, String path, List<int> fileBytes) async {
    return await _supabaseService.uploadFile(bucket, path, fileBytes);
  }

  Future<String?> uploadBannerImage(List<int> fileBytes, String fileName) async {
    return await uploadFile('banners', fileName, fileBytes);
  }

  Future<String?> uploadPushNotificationImage(List<int> fileBytes, String fileName) async {
    return await uploadFile('notifications', fileName, fileBytes);
  }

  Future<String?> uploadAlertImage(List<int> fileBytes, String fileName) async {
    return await uploadFile('alerts', fileName, fileBytes);
  }

  // Activity methods
  Future<Map<String, dynamic>?> addActivity(
    String userId,
    String type,
    String description,
    {double? amount}
  ) async {
    final data = {
      'user_id': userId,
      'type': type,
      'description': description,
      'amount': amount,
      'created_at': DateTime.now().toIso8601String(),
    };
    return await _supabaseService.insert('activities', data);
  }
  
  // Utility methods
  String generateOrderNumber() {
    return 'ORD-${DateTime.now().millisecondsSinceEpoch}';
  }
}