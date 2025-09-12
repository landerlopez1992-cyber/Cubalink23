import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:cubalink23/models/user.dart' as UserModel;
// Models will be handled as raw maps for compatibility
import 'dart:typed_data';

/// Comprehensive Supabase service for Tu Recarga app operations
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  final SupabaseClient _client = SupabaseConfig.client;

  // ==================== BASIC CRUD OPERATIONS ====================
  
  /// Insert a record into a table
  Future<Map<String, dynamic>?> insert(String table, Map<String, dynamic> data) async {
    try {
      print('Inserting into Supabase table $table: $data');
      final response = await _client.from(table).insert(data).select().single();
      print('Insert successful: $response');
      return response;
    } catch (e) {
      print('Error inserting into Supabase table $table: $e');
      return null;
    }
  }

  /// Update a record in a table
  Future<Map<String, dynamic>?> update(String table, String id, Map<String, dynamic> data) async {
    try {
      print('Updating Supabase table $table, id $id: $data');
      final response = await _client.from(table).update(data).eq('id', id).select().single();
      print('Update successful: $response');
      return response;
    } catch (e) {
      print('Error updating Supabase table $table: $e');
      return null;
    }
  }

  /// Select records from a table with advanced filtering
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String? columns,
    String? where,
    dynamic equals,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    try {
      print('Selecting from Supabase table $table with filters: $filters');
      
      dynamic query = _client.from(table).select(columns ?? '*');
      
      // Simple equality filter
      if (where != null && equals != null) {
        query = query.eq(where, equals);
      }
      
      // Advanced filters
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
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query;
      print('Select successful: ${response.length} records');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error selecting from Supabase table $table: $e');
      return [];
    }
  }

  /// Delete a record from a table
  Future<bool> delete(String table, String id) async {
    try {
      print('Deleting from Supabase table $table, id: $id');
      await _client.from(table).delete().eq('id', id);
      print('Delete successful');
      return true;
    } catch (e) {
      print('Error deleting from Supabase table $table: $e');
      return false;
    }
  }

  /// Count records in a table
  Future<int> count(String table, {Map<String, dynamic>? filters}) async {
    try {
      dynamic query = _client.from(table).select('*');
      
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.eq(key, value);
          }
        });
      }
      
      final response = await query.count();
      return response.count;
    } catch (e) {
      print('Error counting records in Supabase table $table: $e');
      return 0;
    }
  }

  // ==================== USER MANAGEMENT ====================
  
  /// Get user profile data
  Future<UserModel.User?> getUserProfile(String userId) async {
    try {
      final data = await select('users', where: 'id', equals: userId);
      if (data.isNotEmpty) {
        final user = data.first;
        return UserModel.User(
          id: user['id'],
          name: user['name'] ?? '',
          email: user['email'] ?? '',
          phone: user['phone'] ?? '',
          balance: (user['balance'] ?? 0.0).toDouble(),
          profilePhotoUrl: user['profile_photo_url'],
          address: user['address'],
          role: user['role'] ?? 'Usuario',
          status: user['status'] ?? 'Activo',
          createdAt: DateTime.parse(user['created_at']),
        );
      }
      return null;
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final result = await update('users', userId, updates);
      return result != null;
    } catch (e) {
      print('❌ Error updating user profile: $e');
      return false;
    }
  }

  /// Update user balance
  Future<bool> updateUserBalance(String userId, double newBalance) async {
    return await updateUserProfile(userId, {'balance': newBalance});
  }

  // ==================== CONTACTS MANAGEMENT ====================
  
  /// Get user contacts (raw data)
  Future<List<Map<String, dynamic>>> getUserContactsRaw(String userId) async {
    try {
      final data = await select(
        'contacts', 
        where: 'user_id', 
        equals: userId,
        orderBy: 'created_at',
        ascending: false,
      );
      
      return data;
    } catch (e) {
      print('❌ Error getting contacts: $e');
      return [];
    }
  }

  /// Add new contact (raw data)
  Future<Map<String, dynamic>?> addContactRaw(Map<String, dynamic> contactData) async {
    try {
      final data = await insert('contacts', contactData);
      return data;
    } catch (e) {
      print('❌ Error adding contact: $e');
      return null;
    }
  }

  /// Update contact (raw data)
  Future<bool> updateContactRaw(String contactId, Map<String, dynamic> contactData) async {
    try {
      final result = await update('contacts', contactId, contactData);
      return result != null;
    } catch (e) {
      print('❌ Error updating contact: $e');
      return false;
    }
  }

  /// Delete contact
  Future<bool> deleteContact(String contactId) async {
    return await delete('contacts', contactId);
  }

  // ==================== RECHARGE HISTORY ====================
  
  /// Add recharge record (raw data)
  Future<Map<String, dynamic>?> addRechargeRecordRaw(Map<String, dynamic> rechargeData) async {
    try {
      final data = await insert('recharge_history', rechargeData);
      return data;
    } catch (e) {
      print('❌ Error adding recharge record: $e');
      return null;
    }
  }

  /// Get user recharge history (raw data)
  Future<List<Map<String, dynamic>>> getUserRechargeHistoryRaw(String userId) async {
    try {
      final data = await select(
        'recharge_history', 
        where: 'user_id', 
        equals: userId,
        orderBy: 'created_at',
        ascending: false,
      );
      
      return data;
    } catch (e) {
      print('❌ Error getting recharge history: $e');
      return [];
    }
  }

  /// Update recharge status
  Future<bool> updateRechargeStatus(String rechargeId, String status) async {
    try {
      final result = await update('recharge_history', rechargeId, {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return result != null;
    } catch (e) {
      print('❌ Error updating recharge status: $e');
      return false;
    }
  }

  // ==================== STORE MANAGEMENT ====================
  
  /// Get all store categories
  Future<List<Map<String, dynamic>>> getStoreCategories() async {
    return await select(
      'store_categories',
      filters: {'is_active': true},
      orderBy: 'sort_order',
      ascending: true,
    );
  }

  /// Get products by category (raw data)
  Future<List<Map<String, dynamic>>> getProductsByCategoryRaw(String categoryId) async {
    try {
      final data = await select(
        'store_products',
        filters: {'category_id': categoryId, 'is_active': true},
        orderBy: 'created_at',
        ascending: false,
      );
      
      return data;
    } catch (e) {
      print('❌ Error getting products by category: $e');
      return [];
    }
  }

  /// Get featured products (raw data)
  Future<List<Map<String, dynamic>>> getFeaturedProductsRaw({int limit = 10}) async {
    try {
      final data = await select(
        'store_products',
        filters: {'is_featured': true, 'is_active': true},
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
      );
      
      return data;
    } catch (e) {
      print('❌ Error getting featured products: $e');
      return [];
    }
  }

  /// Search products (raw data)
  Future<List<Map<String, dynamic>>> searchProductsRaw(String query) async {
    try {
      // Using PostgreSQL full-text search
      final response = await _client
          .from('store_products')
          .select()
          .textSearch('name', query)
          .eq('is_active', true);
      
      final data = List<Map<String, dynamic>>.from(response);
      return data;
    } catch (e) {
      print('❌ Error searching products: $e');
      return [];
    }
  }

  /// Add product (admin only) (raw data)
  Future<Map<String, dynamic>?> addProductRaw(Map<String, dynamic> productData) async {
    try {
      final data = await insert('store_products', productData);
      return data;
    } catch (e) {
      print('❌ Error adding product: $e');
      return null;
    }
  }

  /// Update product (admin only) (raw data)
  Future<bool> updateProductRaw(String productId, Map<String, dynamic> productData) async {
    try {
      final result = await update('store_products', productId, productData);
      return result != null;
    } catch (e) {
      print('❌ Error updating product: $e');
      return false;
    }
  }

  // ==================== CART MANAGEMENT ====================
  
  /// Get user cart items (raw data)
  Future<List<Map<String, dynamic>>> getUserCartItemsRaw(String userId) async {
    try {
      final data = await select(
        'cart_items', 
        where: 'user_id', 
        equals: userId,
        orderBy: 'created_at',
        ascending: false,
      );
      
      return data;
    } catch (e) {
      print('❌ Error getting cart items: $e');
      return [];
    }
  }

  /// Add item to cart (raw data)
  Future<Map<String, dynamic>?> addToCartRaw(Map<String, dynamic> itemData) async {
    try {
      // Check if item already exists in cart
      final existing = await select(
        'cart_items',
        filters: {
          'user_id': itemData['user_id'],
          'product_id': itemData['product_id'],
          'selected_size': itemData['selected_size'],
          'selected_color': itemData['selected_color'],
        },
      );

      if (existing.isNotEmpty) {
        // Update quantity if item exists
        final existingItem = existing.first;
        final newQuantity = (existingItem['quantity'] as int) + (itemData['quantity'] as int);
        
        final result = await update('cart_items', existingItem['id'], {'quantity': newQuantity});
        return result;
      } else {
        // Add new item
        final data = await insert('cart_items', itemData);
        return data;
      }
    } catch (e) {
      print('❌ Error adding to cart: $e');
      return null;
    }
  }

  /// Update cart item quantity
  Future<bool> updateCartItemQuantity(String itemId, int quantity) async {
    try {
      if (quantity <= 0) {
        return await delete('cart_items', itemId);
      } else {
        final result = await update('cart_items', itemId, {'quantity': quantity});
        return result != null;
      }
    } catch (e) {
      print('❌ Error updating cart item: $e');
      return false;
    }
  }

  /// Clear user cart
  Future<bool> clearCart(String userId) async {
    try {
      await _client.from('cart_items').delete().eq('user_id', userId);
      return true;
    } catch (e) {
      print('❌ Error clearing cart: $e');
      return false;
    }
  }

  // ==================== ORDERS MANAGEMENT ====================
  
  /// Create order (raw data)
  Future<Map<String, dynamic>?> createOrderRaw(Map<String, dynamic> orderData) async {
    try {
      final data = await insert('orders', orderData);
      return data;
    } catch (e) {
      print('❌ Error creating order: $e');
      return null;
    }
  }

  /// Get user orders (raw data)
  Future<List<Map<String, dynamic>>> getUserOrdersRaw(String userId) async {
    try {
      final data = await select(
        'orders', 
        where: 'user_id', 
        equals: userId,
        orderBy: 'created_at',
        ascending: false,
      );
      
      return data;
    } catch (e) {
      print('❌ Error getting orders: $e');
      return [];
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final result = await update('orders', orderId, {
        'order_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return result != null;
    } catch (e) {
      print('❌ Error updating order status: $e');
      return false;
    }
  }

  // ==================== STORAGE OPERATIONS ====================
  
  /// Upload file to Supabase Storage
  Future<String?> uploadFile(String bucket, String path, List<int> fileBytes, {bool upsert = false}) async {
    try {
      print('Uploading file to Supabase Storage: $bucket/$path');
      final bytes = Uint8List.fromList(fileBytes);
      
      // Upload with upsert option to overwrite existing files
      final response = await _client.storage.from(bucket).uploadBinary(
        path, 
        bytes,
        fileOptions: FileOptions(upsert: upsert),
      );
      
      final publicUrl = _client.storage.from(bucket).getPublicUrl(path);
      print('Upload successful: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error uploading file to Supabase Storage: $e');
      return null;
    }
  }
  
  /// Delete file from Supabase Storage
  Future<bool> deleteFile(String bucket, String path) async {
    try {
      print('Deleting file from Supabase Storage: $bucket/$path');
      await _client.storage.from(bucket).remove([path]);
      print('Delete successful');
      return true;
    } catch (e) {
      print('Error deleting file from Supabase Storage: $e');
      return false;
    }
  }

  /// Get public URL for a file in Supabase Storage
  String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // ==================== NOTIFICATIONS ====================
  
  /// Add notification
  Future<bool> addNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = {
        'user_id': userId,
        'type': type,
        'title': title,
        'message': message,
        'data': data ?? {},
        'read': false,
      };
      
      final result = await insert('notifications', notification);
      return result != null;
    } catch (e) {
      print('❌ Error adding notification: $e');
      return false;
    }
  }

  /// Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId, {int limit = 50}) async {
    return await select(
      'notifications',
      where: 'user_id',
      equals: userId,
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
    );
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final result = await update('notifications', notificationId, {'read': true});
      return result != null;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  // ==================== ACTIVITIES/TRANSACTIONS ====================
  
  /// Log activity
  Future<bool> logActivity({
    required String userId,
    required String type,
    required String description,
    double? amount,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final activity = {
        'user_id': userId,
        'type': type,
        'description': description,
        'amount': amount,
        'metadata': metadata ?? {},
      };
      
      final result = await insert('activities', activity);
      return result != null;
    } catch (e) {
      print('❌ Error logging activity: $e');
      return false;
    }
  }

  /// Get user activities
  Future<List<Map<String, dynamic>>> getUserActivities(String userId, {int limit = 50}) async {
    return await select(
      'activities',
      where: 'user_id',
      equals: userId,
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
    );
  }

  // ==================== TRANSFERS MANAGEMENT ====================
  
  /// Create transfer record
  Future<Map<String, dynamic>?> createTransfer({
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String description,
    String? toPhoneNumber,
    String? toName,
  }) async {
    try {
      final transferData = {
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'amount': amount,
        'description': description,
        'to_phone_number': toPhoneNumber,
        'to_name': toName,
        'status': 'completed',
        'direction': 'sent',
      };
      
      final result = await insert('transfers', transferData);
      return result;
    } catch (e) {
      print('❌ Error creating transfer: $e');
      return null;
    }
  }

  /// Get user transfers (sent and received)
  Future<List<Map<String, dynamic>>> getUserTransfers(String userId) async {
    try {
      final sentTransfers = await select(
        'transfers',
        where: 'from_user_id',
        equals: userId,
        orderBy: 'created_at',
        ascending: false,
      );
      
      final receivedTransfers = await select(
        'transfers',
        where: 'to_user_id',
        equals: userId,
        orderBy: 'created_at',
        ascending: false,
      );
      
      final allTransfers = [...sentTransfers, ...receivedTransfers];
      allTransfers.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
      
      return allTransfers;
    } catch (e) {
      print('❌ Error getting user transfers: $e');
      return [];
    }
  }

  // ==================== ADMIN OPERATIONS ====================
  
  /// Get all users (admin only)
  Future<List<UserModel.User>> getAllUsers() async {
    try {
      final data = await select('users', orderBy: 'created_at', ascending: false);
      return data.map((user) => UserModel.User(
        id: user['id'],
        name: user['name'] ?? '',
        email: user['email'] ?? '',
        phone: user['phone'] ?? '',
        balance: (user['balance'] ?? 0.0).toDouble(),
        profilePhotoUrl: user['profile_photo_url'],
        address: user['address'],
        role: user['role'] ?? 'Usuario',
        status: user['status'] ?? 'Activo',
        createdAt: DateTime.parse(user['created_at']),
      )).toList();
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  /// Get all orders (admin only) (raw data)
  Future<List<Map<String, dynamic>>> getAllOrdersRaw() async {
    try {
      final data = await select('orders', orderBy: 'created_at', ascending: false);
      return data;
    } catch (e) {
      print('❌ Error getting all orders: $e');
      return [];
    }
  }

  /// Get app statistics (admin only)
  Future<Map<String, dynamic>> getAppStatistics() async {
    try {
      final totalUsers = await count('users');
      final totalOrders = await count('orders');
      final totalProducts = await count('store_products');
      final pendingOrders = await count('orders', filters: {'order_status': 'payment_pending'});
      
      return {
        'total_users': totalUsers,
        'total_orders': totalOrders,
        'total_products': totalProducts,
        'pending_orders': pendingOrders,
      };
    } catch (e) {
      print('❌ Error getting app statistics: $e');
      return {};
    }
  }

  // ==================== SUPPORT CHAT OPERATIONS ====================
  
  /// Get all support conversations (admin only)
  Future<List<Map<String, dynamic>>> getAllSupportConversations() async {
    try {
      final data = await select('support_conversations', orderBy: 'last_message_time', ascending: false);
      return data;
    } catch (e) {
      print('❌ Error getting support conversations: $e');
      return [];
    }
  }
  
  /// Get support messages for a conversation
  Future<List<Map<String, dynamic>>> getSupportMessages(String conversationId) async {
    try {
      final data = await select(
        'support_messages',
        where: 'conversation_id',
        equals: conversationId,
        orderBy: 'created_at',
        ascending: true,
      );
      return data;
    } catch (e) {
      print('❌ Error getting support messages: $e');
      return [];
    }
  }
  
  /// Send support message
  Future<Map<String, dynamic>?> sendSupportMessage({
    required String conversationId,
    required String userId,
    required String userEmail,
    required String userName,
    required String message,
    required bool isFromUser,
  }) async {
    try {
      final messageData = {
        'conversation_id': conversationId,
        'user_id': userId,
        'user_email': userEmail,
        'user_name': userName,
        'message': message,
        'is_from_user': isFromUser,
        'is_read': false,
      };
      
      final result = await insert('support_messages', messageData);
      
      // Update conversation
      await update('support_conversations', conversationId, {
        'last_message_time': DateTime.now().toIso8601String(),
        'unread_count': isFromUser ? 1 : 0,
        'status': 'active',
      });
      
      return result;
    } catch (e) {
      print('❌ Error sending support message: $e');
      return null;
    }
  }
  
  // ==================== PAYMENT METHODS ====================
  
  /// Get user payment cards
  Future<List<Map<String, dynamic>>> getUserPaymentCards(String userId) async {
    try {
      print('🔍 === DEBUGGING getUserPaymentCards ===');
      print('🔍 User ID recibido: $userId');
      print('🔍 Supabase Auth User: ${_client.auth.currentUser?.id}');
      print('🔍 Supabase Auth Email: ${_client.auth.currentUser?.email}');
      
      final data = await select(
        'payment_cards',
        where: 'user_id',
        equals: userId,
        orderBy: 'created_at',
        ascending: false,
      );
      
      print('🔍 Respuesta de Supabase: $data');
      print('🔍 Número de tarjetas: ${data.length}');
      
      return data;
    } catch (e) {
      print('🔍 Error cargando tarjetas de pago: $e');
      print('🔍 Stack trace: ${StackTrace.current}');
      return [];
    }
  }
  
  /// Save payment card
  Future<Map<String, dynamic>?> savePaymentCard(Map<String, dynamic> cardData) async {
    try {
      print('💳 === DEBUGGING PAYMENT CARD SAVE ===');
      print('💳 Card data: $cardData');
      print('💳 User authenticated: ${SupabaseConfig.client.auth.currentUser != null}');
      print('💳 User ID: ${SupabaseConfig.client.auth.currentUser?.id}');
      
      final result = await insert('payment_cards', cardData);
      print('💳 Insert result: $result');
      return result;
    } catch (e) {
      print('❌ Error saving payment card: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error details: ${e.toString()}');
      return null;
    }
  }
  
  // ==================== USER ADDRESSES ====================
  
  /// Get user addresses
  Future<List<Map<String, dynamic>>> getUserAddresses(String userId) async {
    try {
      final data = await select(
        'user_addresses',
        where: 'user_id',
        equals: userId,
        orderBy: 'created_at',
        ascending: false,
      );
      return data;
    } catch (e) {
      print('❌ Error getting user addresses: $e');
      return [];
    }
  }
  
  /// Save user address
  Future<Map<String, dynamic>?> saveUserAddress(Map<String, dynamic> addressData) async {
    try {
      final result = await insert('user_addresses', addressData);
      return result;
    } catch (e) {
      print('❌ Error saving user address: $e');
      return null;
    }
  }
  
  /// Delete user address
  Future<bool> deleteUserAddress(String addressId) async {
    try {
      await delete('user_addresses', addressId);
      return true;
    } catch (e) {
      print('❌ Error deleting user address: $e');
      return false;
    }
  }
  
  // ==================== REAL-TIME SUBSCRIPTIONS ====================
  
  /// Subscribe to real-time changes
  RealtimeChannel subscribeToTable(
    String table, {
    String? filter,
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) {
    final channel = _client.channel('table-$table-changes');
    
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          filter: filter != null ? PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: filter.split('=')[0], value: filter.split('=')[1]) : null,
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: table,
          filter: filter != null ? PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: filter.split('=')[0], value: filter.split('=')[1]) : null,
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: table,
          filter: filter != null ? PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: filter.split('=')[0], value: filter.split('=')[1]) : null,
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
    
    return channel;
  }
  
  /// Unsubscribe from real-time channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }

  /// Subscribe to user notifications
  RealtimeChannel subscribeToNotifications(String userId, Function(Map<String, dynamic>) onNotification) {
    return subscribeToTable(
      'notifications',
      filter: 'user_id=eq.$userId',
      onInsert: onNotification,
      onUpdate: onNotification,
      onDelete: (_) {},
    );
  }

  /// Subscribe to order updates
  RealtimeChannel subscribeToOrderUpdates(String userId, Function(Map<String, dynamic>) onOrderUpdate) {
    return subscribeToTable(
      'orders',
      filter: 'user_id=eq.$userId',
      onInsert: onOrderUpdate,
      onUpdate: onOrderUpdate,
      onDelete: (_) {},
    );
  }
  
  /// Subscribe to support messages (admin)
  RealtimeChannel subscribeToSupportMessages(Function(Map<String, dynamic>) onMessage) {
    return subscribeToTable(
      'support_messages',
      onInsert: onMessage,
      onUpdate: onMessage,
      onDelete: (_) {},
    );
  }

  // ==================== USER ROLE MANAGEMENT ====================
  
  /// Update user role by email
  Future<bool> updateUserRole(String email, String role) async {
    try {
      print('Updating user role for email $email to $role');
      final response = await _client
          .from('users')
          .update({'role': role})
          .eq('email', email)
          .select();
      
      if (response.isNotEmpty) {
        print('Role updated successfully for $email: $response');
        return true;
      } else {
        print('User not found with email: $email');
        return false;
      }
    } catch (e) {
      print('Error updating user role: $e');
      return false;
    }
  }
  
  /// Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }
}