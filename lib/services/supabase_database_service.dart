import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cubalink23/models/user.dart' as UserModel;
import 'package:cubalink23/models/contact.dart';
import 'package:cubalink23/models/payment_card.dart';
import 'package:cubalink23/models/recharge_history.dart';
import 'package:cubalink23/supabase/supabase_config.dart';

/// Simplified database service using Supabase
/// This replaces all Firebase database operations
class SupabaseDatabaseService {
  static SupabaseDatabaseService? _instance;
  static SupabaseDatabaseService get instance => _instance ??= SupabaseDatabaseService._();
  
  SupabaseDatabaseService._();
  
  final SupabaseClient _client = SupabaseConfig.client;
  
  // ==================== USER OPERATIONS ====================
  
  /// Create new user in users table
  Future<void> createUser(UserModel.User user) async {
    try {
      await _client.from('users').insert({
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'phone': user.phone,
        'balance': user.balance,
        'profile_photo_url': user.profilePhotoUrl,
        'address': user.address,
        'role': user.role,
        'is_blocked': user.isBlocked,
        'status': user.status,
        'referral_code': user.referralCode,
        'referred_by': user.referredBy,
        'has_used_service': user.hasUsedService,
        'reward_date': user.rewardDate?.toIso8601String(),
      });
      print('✅ Usuario creado en Supabase: ${user.name}');
    } catch (e) {
      print('❌ Error creando usuario: $e');
      rethrow;
    }
  }
  
  /// Get user by ID
  Future<UserModel.User?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.User.fromJson(response);
    } catch (e) {
      print('❌ Error obteniendo usuario: $e');
      return null;
    }
  }
  
  /// Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _client.from('users').update(data).eq('id', userId);
      print('✅ Usuario actualizado: $userId');
    } catch (e) {
      print('❌ Error actualizando usuario: $e');
      rethrow;
    }
  }
  
  /// Add balance to user (ONLY positive amounts)
  Future<void> addUserBalance(String userId, double amount) async {
    try {
      if (amount <= 0) {
        throw Exception('Solo se pueden agregar montos positivos al saldo');
      }
      
      // Get current balance
      final user = await getUserById(userId);
      if (user == null) throw Exception('Usuario no encontrado');
      
      final newBalance = user.balance + amount;
      
      await _client.from('users').update({
        'balance': newBalance,
      }).eq('id', userId);
      
      print('✅ Saldo agregado: +\$${amount.toStringAsFixed(2)}, nuevo saldo: \$${newBalance.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Error agregando saldo: $e');
      rethrow;
    }
  }
  
  /// Subtract balance from user (with validation)
  Future<void> subtractUserBalance(String userId, double amount) async {
    try {
      if (amount <= 0) {
        throw Exception('Solo se pueden restar montos positivos del saldo');
      }
      
      // Get current balance
      final user = await getUserById(userId);
      if (user == null) throw Exception('Usuario no encontrado');
      
      if (user.balance < amount) {
        throw Exception('Saldo insuficiente');
      }
      
      final newBalance = user.balance - amount;
      
      await _client.from('users').update({
        'balance': newBalance,
      }).eq('id', userId);
      
      print('✅ Saldo descontado: -\$${amount.toStringAsFixed(2)}, nuevo saldo: \$${newBalance.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Error descontando saldo: $e');
      rethrow;
    }
  }
  
  /// Get all users (for admin)
  Future<List<UserModel.User>> getAllUsers() async {
    try {
      final response = await _client.from('users').select().order('created_at', ascending: false);
      
      return response.map((json) => UserModel.User.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error obteniendo todos los usuarios: $e');
      return [];
    }
  }
  
  /// Search users by email or phone
  Future<List<UserModel.User>> searchUsers(String query) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .or('email.ilike.%$query%,phone.ilike.%$query%')
          .limit(50);
      
      return response.map((json) => UserModel.User.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error buscando usuarios: $e');
      return [];
    }
  }
  
  /// Update user status (Active/Blocked)
  Future<void> updateUserStatus(String userId, String status) async {
    try {
      final isBlocked = status == 'Bloqueado';
      await _client.from('users').update({
        'status': status,
        'is_blocked': isBlocked,
      }).eq('id', userId);
      print('✅ Estado de usuario actualizado: $status');
    } catch (e) {
      print('❌ Error actualizando estado de usuario: $e');
      rethrow;
    }
  }
  
  /// Delete user account
  Future<void> deleteUserAccount(String userId) async {
    try {
      await _client.from('users').delete().eq('id', userId);
      print('✅ Cuenta de usuario eliminada: $userId');
    } catch (e) {
      print('❌ Error eliminando cuenta de usuario: $e');
      rethrow;
    }
  }
  
  // ==================== CONTACT OPERATIONS ====================
  
  /// Get user contacts
  Future<List<Contact>> getUserContacts(String userId) async {
    try {
      final response = await _client
          .from('contacts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((json) => Contact.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error obteniendo contactos: $e');
      return [];
    }
  }
  
  /// Add new contact
  Future<void> addContact(String userId, String name, String phoneNumber, String operator, String country) async {
    try {
      await _client.from('contacts').insert({
        'user_id': userId,
        'name': name,
        'phone_number': phoneNumber,
        'operator': operator,
        'country': country,
      });
      print('✅ Contacto agregado: $name');
    } catch (e) {
      print('❌ Error agregando contacto: $e');
      rethrow;
    }
  }
  
  /// Update contact
  Future<void> updateContact(String contactId, Map<String, dynamic> data) async {
    try {
      await _client.from('contacts').update(data).eq('id', contactId);
      print('✅ Contacto actualizado: $contactId');
    } catch (e) {
      print('❌ Error actualizando contacto: $e');
      rethrow;
    }
  }
  
  /// Delete contact
  Future<void> deleteContact(String contactId) async {
    try {
      await _client.from('contacts').delete().eq('id', contactId);
      print('✅ Contacto eliminado: $contactId');
    } catch (e) {
      print('❌ Error eliminando contacto: $e');
      rethrow;
    }
  }
  
  // ==================== ACTIVITY OPERATIONS ====================
  
  /// Add activity log
  Future<void> addActivity({
    required String userId,
    required String type,
    required String description,
    double? amount,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _client.from('activities').insert({
        'user_id': userId,
        'type': type,
        'description': description,
        'amount': amount,
        'metadata': metadata ?? {},
      });
      print('✅ Actividad registrada: $type');
    } catch (e) {
      print('❌ Error registrando actividad: $e');
      // Don't throw error for activity logging to avoid blocking main operations
    }
  }
  
  /// Get user activities
  Future<List<Map<String, dynamic>>> getUserActivities(String userId, {int limit = 50}) async {
    try {
      final response = await _client
          .from('activities')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error obteniendo actividades: $e');
      return [];
    }
  }
  
  // ==================== NOTIFICATION OPERATIONS ====================
  
  /// Send admin message to user
  Future<void> sendAdminMessage(String userId, String message) async {
    try {
      // Create notification
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': 'admin_message',
        'title': 'Mensaje del Administrador',
        'message': message,
        'read': false,
      });
      
      // Also store in admin_messages for admin reference
      await _client.from('admin_messages').insert({
        'user_id': userId,
        'message': message,
        'is_read': false,
      });
      
      print('✅ Mensaje de administrador enviado');
    } catch (e) {
      print('❌ Error enviando mensaje de administrador: $e');
      rethrow;
    }
  }
  
  /// Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error obteniendo notificaciones: $e');
      return [];
    }
  }
  
  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client.from('notifications').update({'read': true}).eq('id', notificationId);
    } catch (e) {
      print('❌ Error marcando notificación como leída: $e');
    }
  }
  
  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('read', false);
      
      return response.length;
    } catch (e) {
      print('❌ Error obteniendo contador de notificaciones: $e');
      return 0;
    }
  }

  // ==================== RECHARGE HISTORY OPERATIONS ====================
  
  /// Add recharge history entry
  Future<void> addRechargeHistory({
    required String userId,
    required String phoneNumber,
    required double amount,
    required String operatorId,
    required String transactionId,
    required String status,
    required DateTime createdAt,
  }) async {
    try {
      await _client.from('recharge_history').insert({
        'user_id': userId,
        'phone_number': phoneNumber,
        'amount': amount,
        'operator_id': operatorId,
        'transaction_id': transactionId,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      });
      print('✅ Historial de recarga agregado: $transactionId');
    } catch (e) {
      print('❌ Error agregando historial de recarga: $e');
      rethrow;
    }
  }
  
  /// Get recharge history for user
  Future<List<Map<String, dynamic>>> getRechargeHistory(String userId) async {
    try {
      final response = await _client
          .from('recharge_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      print('✅ Historial de recargas obtenido: ${response.length} entradas');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error obteniendo historial de recargas: $e');
      return [];
    }
  }
}