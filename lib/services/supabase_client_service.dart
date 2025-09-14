import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:cubalink23/models/user.dart' as UserModel;
import 'package:cubalink23/models/payment_card.dart';
import 'package:cubalink23/models/contact.dart';
import 'package:cubalink23/models/recharge_history.dart';
import 'package:cubalink23/models/store_product.dart';
import 'package:cubalink23/models/order.dart';
import 'package:cubalink23/models/cart_item.dart';

/// Comprehensive Supabase client service for CubaLink23 app
/// Provides a unified interface for all Supabase operations
class SupabaseClientService {
  static SupabaseClientService? _instance;
  static SupabaseClientService get instance => _instance ??= SupabaseClientService._();
  
  SupabaseClientService._();
  
  /// Safe client getter - null if Supabase not initialized
  SupabaseClient? get _client => SupabaseConfig.safeClient;
  
  /// Direct access to Supabase client (throws if not available)
  SupabaseClient get client => SupabaseConfig.client;
  
  /// Check if Supabase is available
  bool get isAvailable => SupabaseConfig.isAvailable;
  
  /// Auth service
  GoTrueClient? get auth => _client?.auth;
  
  /// Storage service
  SupabaseStorageClient? get storage => _client?.storage;
  
  /// Real-time service
  RealtimeClient? get realtime => _client?.realtime;
  
  // ==================== USER MANAGEMENT ====================
  
  /// Get user profile by ID
  Future<UserModel.User?> getUserProfile(String userId) async {
    if (_client == null) {
      print('⚠️ Supabase not available - getUserProfile');
      return null;
    }
    
    try {
      final response = await _client!
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.User(
        id: response['id'],
        name: response['name'] ?? 'Usuario',
        email: response['email'] ?? '',
        phone: response['phone'] ?? '',
        balance: (response['balance'] ?? 0.0).toDouble(),
        profilePhotoUrl: response['profile_photo_url'],
        address: response['address'],
        role: response['role'] ?? 'Usuario',
        status: response['status'] ?? 'Activo',
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      print('❌ Error obteniendo perfil de usuario: $e');
      return null;
    }
  }
  
  /// Update user balance
  Future<bool> updateUserBalance(String userId, double newBalance) async {
    if (_client == null) {
      print('⚠️ Supabase not available - updateUserBalance');
      return false;
    }
    
    try {
      await _client!
          .from('users')
          .update({'balance': newBalance})
          .eq('id', userId);
      
      print('✅ Balance actualizado para usuario $userId: \$${newBalance.toStringAsFixed(2)}');
      return true;
    } catch (e) {
      print('❌ Error actualizando balance: $e');
      return false;
    }
  }
  
  /// Update user role (Admin function)
  Future<bool> updateUserRole(String email, String role) async {
    if (_client == null) {
      print('⚠️ Supabase not available - updateUserRole');
      return false;
    }
    
    try {
      final result = await _client!
          .from('users')
          .update({'role': role})
          .eq('email', email)
          .select();
      
      if (result.isNotEmpty) {
        print('✅ Role actualizado para $email: $role');
        return true;
      } else {
        print('⚠️ Usuario no encontrado: $email');
        return false;
      }
    } catch (e) {
      print('❌ Error actualizando role: $e');
      return false;
    }
  }
  
  // ==================== PAYMENT CARDS ====================
  
  /// Get user payment cards
  Future<List<Map<String, dynamic>>> getUserPaymentCards(String userId) async {
    if (_client == null) {
      print('⚠️ Supabase not available - getUserPaymentCards');
      return [];
    }
    
    try {
      final response = await _client!
          .from('payment_cards')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error obteniendo tarjetas de pago: $e');
      return [];
    }
  }
  
  /// Add payment card
  Future<Map<String, dynamic>?> addPaymentCard(Map<String, dynamic> cardData) async {
    if (_client == null) {
      print('⚠️ Supabase not available - addPaymentCard');
      return null;
    }
    
    try {
      final response = await _client!
          .from('payment_cards')
          .insert(cardData)
          .select()
          .single();
      
      print('✅ Tarjeta de pago agregada exitosamente');
      return response;
    } catch (e) {
      print('❌ Error agregando tarjeta de pago: $e');
      return null;
    }
  }
  
  /// Delete payment card
  Future<bool> deletePaymentCard(String cardId) async {
    if (_client == null) {
      print('⚠️ Supabase not available - deletePaymentCard');
      return false;
    }
    
    try {
      await _client!
          .from('payment_cards')
          .delete()
          .eq('id', cardId);
      
      print('✅ Tarjeta de pago eliminada');
      return true;
    } catch (e) {
      print('❌ Error eliminando tarjeta: $e');
      return false;
    }
  }
  
  // ==================== CONTACTS ====================
  
  /// Get user contacts
  Future<List<Contact>> getUserContacts(String userId) async {
    if (_client == null) {
      print('⚠️ Supabase not available - getUserContacts');
      return [];
    }
    
    try {
      final response = await _client!
          .from('contacts')
          .select()
          .eq('user_id', userId)
          .order('name');
      
      return response.map<Contact>((contactData) => Contact(
        id: contactData['id'],
        name: contactData['name'],
        phone: contactData['phone_number'],
        countryCode: contactData['country'] ?? 'CU',
        operatorId: contactData['operator'],
        createdAt: DateTime.parse(contactData['created_at']),
      )).toList();
    } catch (e) {
      print('❌ Error obteniendo contactos: $e');
      return [];
    }
  }
  
  /// Add contact
  Future<Contact?> addContact(String userId, Contact contact) async {
    if (_client == null) {
      print('⚠️ Supabase not available - addContact');
      return null;
    }
    
    try {
      final response = await _client!
          .from('contacts')
          .insert({
            'user_id': userId,
            'name': contact.name,
            'phone_number': contact.phone,
            'operator': contact.operatorId,
            'country': contact.countryCode,
          })
          .select()
          .single();
      
      return Contact(
        id: response['id'],
        name: response['name'],
        phone: response['phone_number'],
        countryCode: response['country'],
        operatorId: response['operator'],
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      print('❌ Error agregando contacto: $e');
      return null;
    }
  }
  
  // ==================== RECHARGE HISTORY ====================
  
  /// Get user recharge history
  Future<List<RechargeHistory>> getUserRechargeHistory(String userId, {int limit = 20}) async {
    if (_client == null) {
      print('⚠️ Supabase not available - getUserRechargeHistory');
      return [];
    }
    
    try {
      final response = await _client!
          .from('recharge_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      
      return response.map<RechargeHistory>((rechargeData) => RechargeHistory(
        id: rechargeData['id'],
        phoneNumber: rechargeData['phone_number'],
        operator: rechargeData['operator'],
        amount: (rechargeData['amount'] ?? 0.0).toDouble(),
        timestamp: DateTime.parse(rechargeData['created_at']),
        status: rechargeData['status'],
      )).toList();
    } catch (e) {
      print('❌ Error obteniendo historial de recargas: $e');
      return [];
    }
  }
  
  /// Add recharge record
  Future<RechargeHistory?> addRechargeRecord({
    required String userId,
    required String phoneNumber,
    required String operator,
    required String country,
    required double amount,
    String status = 'pending',
    String? transactionId,
    Map<String, dynamic>? metadata,
  }) async {
    if (_client == null) {
      print('⚠️ Supabase not available - addRechargeRecord');
      return null;
    }
    
    try {
      final response = await _client!
          .from('recharge_history')
          .insert({
            'user_id': userId,
            'phone_number': phoneNumber,
            'operator': operator,
            'country': country,
            'amount': amount,
            'status': status,
            'transaction_id': transactionId,
            'metadata': metadata ?? {},
          })
          .select()
          .single();
      
      return RechargeHistory(
        id: response['id'],
        phoneNumber: response['phone_number'],
        operator: response['operator'],
        amount: (response['amount'] ?? 0.0).toDouble(),
        timestamp: DateTime.parse(response['created_at']),
        status: response['status'],
      );
    } catch (e) {
      print('❌ Error agregando registro de recarga: $e');
      return null;
    }
  }
  
  /// Update recharge status
  Future<bool> updateRechargeStatus(String rechargeId, String status, {String? transactionId}) async {
    if (_client == null) {
      print('⚠️ Supabase not available - updateRechargeStatus');
      return false;
    }
    
    try {
      final updateData = {'status': status};
      if (transactionId != null) {
        updateData['transaction_id'] = transactionId;
      }
      
      await _client!
          .from('recharge_history')
          .update(updateData)
          .eq('id', rechargeId);
      
      print('✅ Estado de recarga actualizado: $status');
      return true;
    } catch (e) {
      print('❌ Error actualizando estado de recarga: $e');
      return false;
    }
  }
  
  // ==================== STORE MANAGEMENT ====================
  
  /// Get store categories
  Future<List<Map<String, dynamic>>> getStoreCategories({bool activeOnly = true}) async {
    if (_client == null) {
      print('⚠️ Supabase not available - getStoreCategories');
      return [];
    }
    
    try {
      dynamic query = _client!
          .from('store_categories')
          .select();
      
      if (activeOnly) {
        query = query.eq('is_active', true);
      }
      
      final response = await query.order('sort_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error obteniendo categorías de tienda: $e');
      return [];
    }
  }
  
  /// Get store products
  Future<List<StoreProduct>> getStoreProducts({
    String? categoryId,
    bool activeOnly = true,
    int? limit,
    bool featuredOnly = false,
  }) async {
    if (_client == null) {
      print('⚠️ Supabase not available - getStoreProducts');
      return [];
    }
    
    try {
      dynamic query = _client!
          .from('store_products')
          .select('*, store_categories(name, icon, color)');
      
      if (activeOnly) {
        query = query.eq('is_active', true);
      }
      
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      
      if (featuredOnly) {
        query = query.eq('is_featured', true);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return response.map<StoreProduct>((productData) => StoreProduct(
        id: productData['id'],
        name: productData['name'],
        description: productData['description'],
        price: (productData['price'] ?? 0.0).toDouble(),
        imageUrl: (productData['images'] as List?)?.isNotEmpty == true ? 
                  (productData['images'] as List).first : '',
        categoryId: productData['category_id'] ?? '',
        unit: productData['unit'] ?? 'unidad',
        weight: (productData['weight'] ?? 0.0).toDouble(),
        stock: productData['stock'] ?? 0,
        availableProvinces: List<String>.from(productData['available_provinces'] ?? []),
        deliveryMethod: productData['estimated_delivery_days'] != null && 
                       productData['estimated_delivery_days'] <= 3 ? 'express' : 'barco',
        createdAt: DateTime.parse(productData['created_at']),
      )).toList();
    } catch (e) {
      print('❌ Error obteniendo productos de tienda: $e');
      return [];
    }
  }
  
  /// Add store product (Admin only)
  Future<StoreProduct?> addStoreProduct(Map<String, dynamic> productData) async {
    if (_client == null) {
      print('⚠️ Supabase not available - addStoreProduct');
      return null;
    }
    
    try {
      final response = await _client!
          .from('store_products')
          .insert(productData)
          .select('*, store_categories(name, icon, color)')
          .single();
      
      print('✅ Producto agregado exitosamente: ${response['name']}');
      
      return StoreProduct(
        id: response['id'],
        name: response['name'],
        description: response['description'],
        price: (response['price'] ?? 0.0).toDouble(),
        imageUrl: (response['images'] as List?)?.isNotEmpty == true ? 
                  (response['images'] as List).first : '',
        categoryId: response['category_id'] ?? '',
        unit: response['unit'] ?? 'unidad',
        weight: (response['weight'] ?? 0.0).toDouble(),
        stock: response['stock'] ?? 0,
        availableProvinces: List<String>.from(response['available_provinces'] ?? []),
        deliveryMethod: response['estimated_delivery_days'] != null && 
                       response['estimated_delivery_days'] <= 3 ? 'express' : 'barco',
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      print('❌ Error agregando producto: $e');
      return null;
    }
  }
  
  // ==================== CART MANAGEMENT ====================
  
  /// Get user cart items
  Future<List<CartItem>> getUserCartItems(String userId) async {
    if (_client == null) {
      print('⚠️ Supabase not available - getUserCartItems');
      return [];
    }
    
    try {
      final response = await _client!
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map<CartItem>((cartData) => CartItem(
        id: cartData['id'],
        name: cartData['product_name'],
        price: (cartData['product_price'] ?? 0.0).toDouble(),
        quantity: cartData['quantity'] ?? 1,
        imageUrl: cartData['product_image_url'] ?? '',
        type: cartData['product_type'] ?? 'store',
        weight: cartData['weight'],
      )).toList();
    } catch (e) {
      print('❌ Error obteniendo items del carrito: $e');
      return [];
    }
  }
  
  /// Add item to cart
  Future<bool> addToCart({
    required String userId,
    required String productId,
    required String productName,
    required double productPrice,
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
    String productType = 'store',
  }) async {
    if (_client == null) {
      print('⚠️ Supabase not available - addToCart');
      return false;
    }
    
    try {
      await _client!
          .from('cart_items')
          .insert({
            'user_id': userId,
            'product_id': productId,
            'product_name': productName,
            'product_price': productPrice,
            'quantity': quantity,
            'selected_size': selectedSize,
            'selected_color': selectedColor,
            'product_type': productType,
          });
      
      print('✅ Producto agregado al carrito: $productName');
      return true;
    } catch (e) {
      print('❌ Error agregando al carrito: $e');
      return false;
    }
  }
  
  /// Clear user cart
  Future<bool> clearCart(String userId) async {
    if (_client == null) {
      print('⚠️ Supabase not available - clearCart');
      return false;
    }
    
    try {
      await _client!
          .from('cart_items')
          .delete()
          .eq('user_id', userId);
      
      print('✅ Carrito limpiado');
      return true;
    } catch (e) {
      print('❌ Error limpiando carrito: $e');
      return false;
    }
  }
  
  // ==================== NOTIFICATIONS ====================
  
  /// Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId, {int limit = 20}) async {
    if (_client == null) {
      print('⚠️ Supabase not available - getUserNotifications');
      return [];
    }
    
    try {
      final response = await _client!
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error obteniendo notificaciones: $e');
      return [];
    }
  }
  
  /// Add notification
  Future<bool> addNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    if (_client == null) {
      print('⚠️ Supabase not available - addNotification');
      return false;
    }
    
    try {
      await _client!
          .from('notifications')
          .insert({
            'user_id': userId,
            'type': type,
            'title': title,
            'message': message,
            'data': data ?? {},
          });
      
      print('✅ Notificación enviada: $title');
      return true;
    } catch (e) {
      print('❌ Error enviando notificación: $e');
      return false;
    }
  }
  
  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    if (_client == null) {
      print('⚠️ Supabase not available - markNotificationAsRead');
      return false;
    }
    
    try {
      await _client!
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
      
      return true;
    } catch (e) {
      print('❌ Error marcando notificación como leída: $e');
      return false;
    }
  }
  
  // ==================== REAL-TIME SUBSCRIPTIONS ====================
  
  /// Subscribe to user notifications
  RealtimeChannel? subscribeToUserNotifications(String userId, Function(Map<String, dynamic>) onNotification) {
    if (_client == null) {
      print('⚠️ Supabase not available - subscribeToUserNotifications');
      return null;
    }
    
    final channel = _client!.channel('user-notifications-$userId');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) => onNotification(payload.newRecord),
    ).subscribe();
    
    return channel;
  }
  
  /// Subscribe to user balance changes
  RealtimeChannel? subscribeToBalanceChanges(String userId, Function(double) onBalanceChange) {
    if (_client == null) {
      print('⚠️ Supabase not available - subscribeToBalanceChanges');
      return null;
    }
    
    final channel = _client!.channel('user-balance-$userId');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'users',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: userId,
      ),
      callback: (payload) {
        final newBalance = (payload.newRecord['balance'] ?? 0.0).toDouble();
        onBalanceChange(newBalance);
      },
    ).subscribe();
    
    return channel;
  }
  
  /// Unsubscribe from channel
  Future<void> unsubscribeFromChannel(RealtimeChannel channel) async {
    if (_client == null) {
      print('⚠️ Supabase not available - unsubscribeFromChannel');
      return;
    }
    
    await _client!.removeChannel(channel);
  }
  
  // ==================== ADMIN FUNCTIONS ====================
  
  /// Get all users (Admin only)
  Future<List<UserModel.User>> getAllUsers({int? limit, String? role}) async {
    if (_client == null) {
      print('⚠️ Supabase not available - getAllUsers');
      return [];
    }
    
    try {
      dynamic query = _client!
          .from('users')
          .select();
      
      if (role != null) {
        query = query.eq('role', role);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return response.map<UserModel.User>((userData) => UserModel.User(
        id: userData['id'],
        name: userData['name'] ?? 'Usuario',
        email: userData['email'] ?? '',
        phone: userData['phone'] ?? '',
        balance: (userData['balance'] ?? 0.0).toDouble(),
        profilePhotoUrl: userData['profile_photo_url'],
        address: userData['address'],
        role: userData['role'] ?? 'Usuario',
        status: userData['status'] ?? 'Activo',
        createdAt: DateTime.parse(userData['created_at']),
      )).toList();
    } catch (e) {
      print('❌ Error obteniendo usuarios: $e');
      return [];
    }
  }
  
  /// Get app statistics (Admin only)
  Future<Map<String, dynamic>> getAppStatistics() async {
    if (_client == null) {
      print('⚠️ Supabase not available - getAppStatistics');
      return {};
    }
    
    try {
      final results = await Future.wait([
        _client!.from('users').select('id').count(),
        _client!.from('recharge_history').select('id').count(),
        _client!.from('orders').select('id').count(),
        _client!.from('store_products').select('id').count(),
      ]);
      
      return {
        'total_users': results[0].count,
        'total_recharges': results[1].count,
        'total_orders': results[2].count,
        'total_products': results[3].count,
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return {};
    }
  }
  
  // ==================== STORAGE OPERATIONS ====================
  
  /// Upload file to Supabase Storage
  Future<String?> uploadFile(String bucket, String path, List<int> fileBytes) async {
    if (_client == null) {
      print('⚠️ Supabase not available - uploadFile');
      return null;
    }
    
    try {
      await _client!.storage.from(bucket).uploadBinary(
        path, 
        Uint8List.fromList(fileBytes),
        fileOptions: const FileOptions(upsert: true),
      );
      
      final publicUrl = _client!.storage.from(bucket).getPublicUrl(path);
      print('✅ Archivo subido: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error subiendo archivo: $e');
      return null;
    }
  }
  
  /// Get public URL for file
  String? getPublicUrl(String bucket, String path) {
    if (_client == null) return null;
    return _client!.storage.from(bucket).getPublicUrl(path);
  }
  
  /// Delete file from storage
  Future<bool> deleteFile(String bucket, String path) async {
    if (_client == null) {
      print('⚠️ Supabase not available - deleteFile');
      return false;
    }
    
    try {
      await _client!.storage.from(bucket).remove([path]);
      print('✅ Archivo eliminado: $path');
      return true;
    } catch (e) {
      print('❌ Error eliminando archivo: $e');
      return false;
    }
  }
  
  // ==================== GENERIC DATABASE OPERATIONS ====================
  
  /// Generic insert operation
  Future<Map<String, dynamic>?> insertRecord(String table, Map<String, dynamic> data) async {
    if (_client == null) {
      print('⚠️ Supabase not available - insertRecord');
      return null;
    }
    
    try {
      final response = await _client!
          .from(table)
          .insert(data)
          .select()
          .single();
      
      print('✅ Registro insertado en $table');
      return response;
    } catch (e) {
      print('❌ Error insertando en $table: $e');
      return null;
    }
  }
  
  /// Generic update operation
  Future<Map<String, dynamic>?> updateRecord(String table, String id, Map<String, dynamic> data) async {
    if (_client == null) {
      print('⚠️ Supabase not available - updateRecord');
      return null;
    }
    
    try {
      final response = await _client!
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      
      print('✅ Registro actualizado en $table');
      return response;
    } catch (e) {
      print('❌ Error actualizando $table: $e');
      return null;
    }
  }
  
  /// Generic select operation
  Future<List<Map<String, dynamic>>> selectRecords(
    String table, {
    String columns = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    if (_client == null) {
      print('⚠️ Supabase not available - selectRecords');
      return [];
    }
    
    try {
      dynamic query = _client!.from(table).select(columns);
      
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.eq(key, value);
          }
        });
      }
      
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error seleccionando de $table: $e');
      return [];
    }
  }
  
  /// Generic delete operation
  Future<bool> deleteRecord(String table, String id) async {
    if (_client == null) {
      print('⚠️ Supabase not available - deleteRecord');
      return false;
    }
    
    try {
      await _client!.from(table).delete().eq('id', id);
      print('✅ Registro eliminado de $table');
      return true;
    } catch (e) {
      print('❌ Error eliminando de $table: $e');
      return false;
    }
  }
}

/// Global instance for easy access throughout the app
final supabase = SupabaseClientService.instance;