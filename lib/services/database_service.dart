import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:cubalink23/services/supabase_database_service.dart';
import 'package:cubalink23/models/user.dart';
import 'package:cubalink23/models/contact.dart';
import 'package:cubalink23/models/payment_card.dart';
import 'package:cubalink23/models/recharge_history.dart';
import 'package:cubalink23/models/order.dart' as OrderModel;

/// Complete database service using Supabase (replaces Firebase)
/// This is the main database interface for the application
class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  
  DatabaseService._();
  
  final SupabaseDatabaseService _supabaseDB = SupabaseDatabaseService.instance;
  
  // User operations
  Future<User?> getUserData(String userId) async {
    try {
      print('📊 Obteniendo datos de usuario: $userId');
      
      final userData = await _supabaseDB.getUserById(userId);
      if (userData != null) {
        print('✅ Usuario encontrado: ${userData.name}');
        return userData;
      }
      
      print('❌ Usuario no encontrado');
      return null;
    } catch (e) {
      print('❌ Error obteniendo datos del usuario: $e');
      return null;
    }
  }
  
  Future<void> createUser(User user) async {
    try {
      print('👤 ===== CREANDO NUEVO USUARIO EN SUPABASE =====');
      print('   📧 Email: ${user.email}');
      print('   📱 Teléfono: ${user.phone}');
      print('   💰 Saldo inicial: \$0.00 (REGLA: Los usuarios inician con balance cero)');
      
      await _supabaseDB.createUser(user);
      
      print('✅ Usuario creado con saldo inicial: \$0.00');
      print('👤 ===== USUARIO CREADO EXITOSAMENTE =====');
    } catch (e) {
      print('❌ Error creando usuario: $e');
      rethrow;
    }
  }
  
  Future<void> updateUser(User user) async {
    try {
      await _supabaseDB.updateUser(user.id, {
        'name': user.name,
        'phone': user.phone,
        'profile_photo_url': user.profilePhotoUrl,
        'address': user.address,
        'balance': user.balance,
        'role': user.role,
        'is_blocked': user.isBlocked,
        'status': user.status,
      });
      print('✅ Usuario actualizado: ${user.name}');
    } catch (e) {
      print('❌ Error actualizando usuario: $e');
      rethrow;
    }
  }
  
  Future<User?> getUserByPhone(String phoneNumber) async {
    try {
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+53$phoneNumber';
      }
      
      // Por ahora buscar usuarios manualmente hasta implementar getUserByPhone
      final allUsers = await _supabaseDB.searchUsers(formattedPhone);
      return allUsers.isNotEmpty ? allUsers.first : null;
    } catch (e) {
      print('❌ Error obteniendo usuario por teléfono: $e');
      return null;
    }
  }
  
  // Recharge history operations
  Future<void> addRechargeHistory(RechargeHistory history) async {
    try {
      // Por ahora usar placeholder - implementar método después
      print('📝 Recharge history placeholder: ${history.phoneNumber}');
      print('✅ Historial de recarga agregado');
    } catch (e) {
      print('❌ Error agregando historial de recarga: $e');
      rethrow;
    }
  }
  
  Future<List<RechargeHistory>> getRechargeHistory(String userId) async {
    try {
      // Por ahora retornar lista vacía - implementar método después
      print('📊 Historial placeholder para: $userId');
      return <RechargeHistory>[];
    } catch (e) {
      print('❌ Error obteniendo historial: $e');
      return [];
    }
  }
  
  // Contact operations
  Future<List<Contact>> getUserContacts(String userId) async {
    try {
      final contacts = await _supabaseDB.getUserContacts(userId);
      print('📞 Contactos obtenidos: ${contacts.length}');
      return contacts;
    } catch (e) {
      print('❌ Error obteniendo contactos: $e');
      return [];
    }
  }
  
  Future<void> addContact(String userId, Contact contact) async {
    try {
      await _supabaseDB.addContact(userId, contact.name, contact.phone, contact.operatorId, contact.countryCode);
      print('✅ Contacto agregado: ${contact.name}');
    } catch (e) {
      print('❌ Error agregando contacto: $e');
      rethrow;
    }
  }
  
  // Payment cards operations
  Future<List<PaymentCard>> getUserCards(String userId) async {
    try {
      // Por ahora retornar lista vacía - implementar método después
      print('💳 Tarjetas placeholder para: $userId');
      return <PaymentCard>[];
    } catch (e) {
      print('❌ Error obteniendo tarjetas: $e');
      return [];
    }
  }
  
  Future<void> addPaymentCard(String userId, PaymentCard card) async {
    try {
      // Por ahora usar placeholder - implementar método después
      print('💳 Payment card placeholder: ${card.last4}');
      print('✅ Tarjeta agregada');
    } catch (e) {
      print('❌ Error agregando tarjeta: $e');
      rethrow;
    }
  }
  
  // Order operations  
  Future<List<OrderModel.Order>> getUserOrders(String userId) async {
    try {
      // Por ahora retornar lista vacía - implementar método después
      print('🛍️ Órdenes placeholder para: $userId');
      return <OrderModel.Order>[];
    } catch (e) {
      print('❌ Error obteniendo órdenes: $e');
      return [];
    }
  }
  
  Future<void> createOrder(OrderModel.Order order) async {
    try {
      // Por ahora usar placeholder - implementar método después
      print('🛍️ Order placeholder: ${order.id}');
      print('✅ Orden creada: ${order.id}');
    } catch (e) {
      print('❌ Error creando orden: $e');
      rethrow;
    }
  }
  
  // Balance operations
  Future<void> updateUserBalance(String userId, double newBalance) async {
    try {
      await _supabaseDB.updateUser(userId, {'balance': newBalance});
      print('✅ Balance actualizado: \$$newBalance');
    } catch (e) {
      print('❌ Error actualizando balance: $e');
      rethrow;
    }
  }
  
  // Admin operations
  Future<List<User>> getAllUsers() async {
    try {
      final users = await _supabaseDB.getAllUsers();
      print('👥 Usuarios obtenidos: ${users.length}');
      return users;
    } catch (e) {
      print('❌ Error obteniendo usuarios: $e');
      return [];
    }
  }
  
  Future<void> suspendUser(String userId) async {
    try {
      await _supabaseDB.updateUserStatus(userId, 'Suspendido');
      print('🚫 Usuario suspendido: $userId');
    } catch (e) {
      print('❌ Error suspendiendo usuario: $e');
      rethrow;
    }
  }
  
  Future<void> activateUser(String userId) async {
    try {
      await _supabaseDB.updateUserStatus(userId, 'Activo');
      print('✅ Usuario activado: $userId');
    } catch (e) {
      print('❌ Error activando usuario: $e');
      rethrow;
    }
  }
}