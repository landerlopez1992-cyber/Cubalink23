import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/models/user.dart' as UserModel;
import 'dart:typed_data';

/// Compatibility service to bridge old Firebase calls with new Supabase implementation
class SupabaseCompatibilityService {
  static SupabaseCompatibilityService? _instance;
  static SupabaseCompatibilityService get instance => _instance ??= SupabaseCompatibilityService._();
  
  SupabaseCompatibilityService._();
  
  final SupabaseService _supabase = SupabaseService.instance;

  // ==================== BASIC CRUD COMPATIBILITY ====================
  
  /// Create document (Firebase style)
  Future<Map<String, dynamic>?> createDocument(String collection, Map<String, dynamic> data) async {
    return await _supabase.insert(collection, data);
  }

  /// Update document (Firebase style)
  Future<Map<String, dynamic>?> updateDocument(String collection, String id, Map<String, dynamic> data) async {
    return await _supabase.update(collection, id, data);
  }

  /// Get documents (Firebase style)
  Future<List<Map<String, dynamic>>> getDocuments(String collection, {Map<String, dynamic>? where}) async {
    return await _supabase.select(collection, filters: where);
  }

  /// Get single document
  Future<Map<String, dynamic>?> getDocument(String collection, String id) async {
    final results = await _supabase.select(collection, where: 'id', equals: id);
    return results.isNotEmpty ? results.first : null;
  }

  /// Delete document
  Future<bool> deleteDocument(String collection, String id) async {
    return await _supabase.delete(collection, id);
  }

  // ==================== USER OPERATIONS ====================
  
  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    return await getDocument('users', userId);
  }

  /// Get users by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final results = await _supabase.select('users', where: 'email', equals: email);
    return results.isNotEmpty ? results.first : null;
  }

  /// Update user balance
  Future<bool> updateUserBalance(String userId, double balance) async {
    return await _supabase.updateUserBalance(userId, balance);
  }

  // ==================== CONTACT OPERATIONS ====================
  
  /// Get user contacts (returns raw maps for compatibility)
  Future<List<Map<String, dynamic>>> getUserContactsRaw(String userId) async {
    return await _supabase.select('contacts', where: 'user_id', equals: userId);
  }

  /// Add contact (accepts raw map)
  Future<Map<String, dynamic>?> addContactRaw(Map<String, dynamic> contactData) async {
    return await _supabase.insert('contacts', contactData);
  }

  /// Update contact (accepts raw map)
  Future<bool> updateContactRaw(String contactId, Map<String, dynamic> contactData) async {
    final result = await _supabase.update('contacts', contactId, contactData);
    return result != null;
  }

  // ==================== RECHARGE OPERATIONS ====================
  
  /// Add recharge record (accepts raw map)
  Future<Map<String, dynamic>?> addRechargeRecordRaw(Map<String, dynamic> rechargeData) async {
    return await _supabase.insert('recharge_history', rechargeData);
  }

  /// Get user recharge history (returns raw maps)
  Future<List<Map<String, dynamic>>> getUserRechargeHistoryRaw(String userId) async {
    return await _supabase.select(
      'recharge_history', 
      where: 'user_id', 
      equals: userId,
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Update recharge status
  Future<bool> updateRechargeStatus(String rechargeId, String status) async {
    return await _supabase.updateRechargeStatus(rechargeId, status);
  }

  // ==================== ORDER OPERATIONS ====================
  
  /// Get user orders (returns raw maps)
  Future<List<Map<String, dynamic>>> getUserOrdersRaw(String userId) async {
    return await _supabase.select(
      'orders', 
      where: 'user_id', 
      equals: userId,
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Create order (accepts raw map)
  Future<Map<String, dynamic>?> createOrderRaw(Map<String, dynamic> orderData) async {
    return await _supabase.insert('orders', orderData);
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    return await _supabase.updateOrderStatus(orderId, status);
  }

  // ==================== CART OPERATIONS ====================
  
  /// Get user cart items (returns raw maps)
  Future<List<Map<String, dynamic>>> getUserCartItemsRaw(String userId) async {
    return await _supabase.select('cart_items', where: 'user_id', equals: userId);
  }

  /// Add to cart (accepts raw map)
  Future<Map<String, dynamic>?> addToCartRaw(Map<String, dynamic> cartData) async {
    return await _supabase.insert('cart_items', cartData);
  }

  /// Update cart item quantity
  Future<bool> updateCartItemQuantity(String itemId, int quantity) async {
    return await _supabase.updateCartItemQuantity(itemId, quantity);
  }

  /// Clear user cart
  Future<bool> clearUserCart(String userId) async {
    return await _supabase.clearCart(userId);
  }

  // ==================== STORE OPERATIONS ====================
  
  /// Get store categories
  Future<List<Map<String, dynamic>>> getStoreCategories() async {
    return await _supabase.getStoreCategories();
  }

  /// Get products by category
  Future<List<Map<String, dynamic>>> getProductsByCategoryRaw(String categoryId) async {
    return await _supabase.select(
      'store_products',
      filters: {'category_id': categoryId, 'is_active': true},
    );
  }

  /// Get featured products
  Future<List<Map<String, dynamic>>> getFeaturedProductsRaw({int limit = 10}) async {
    return await _supabase.select(
      'store_products',
      filters: {'is_featured': true, 'is_active': true},
      limit: limit,
    );
  }

  /// Add product (accepts raw map)
  Future<Map<String, dynamic>?> addProductRaw(Map<String, dynamic> productData) async {
    return await _supabase.insert('store_products', productData);
  }

  /// Update product (accepts raw map)
  Future<bool> updateProductRaw(String productId, Map<String, dynamic> productData) async {
    final result = await _supabase.update('store_products', productId, productData);
    return result != null;
  }

  // ==================== NOTIFICATION OPERATIONS ====================
  
  /// Add notification
  Future<bool> addNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    return await _supabase.addNotification(
      userId: userId,
      type: type,
      title: title,
      message: message,
      data: data,
    );
  }

  /// Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    return await _supabase.getUserNotifications(userId);
  }

  // ==================== STORAGE OPERATIONS ====================
  
  /// Upload file to storage
  Future<String?> uploadFile(String bucket, String path, Uint8List bytes) async {
    return await _supabase.uploadFile(bucket, path, bytes.toList());
  }

  /// Delete file from storage
  Future<bool> deleteFile(String bucket, String path) async {
    return await _supabase.deleteFile(bucket, path);
  }

  /// Get public URL for file
  String getPublicUrl(String bucket, String path) {
    return _supabase.getPublicUrl(bucket, path);
  }

  // ==================== ACTIVITY OPERATIONS ====================
  
  /// Log activity
  Future<bool> logActivity({
    required String userId,
    required String type,
    required String description,
    double? amount,
    Map<String, dynamic>? metadata,
  }) async {
    return await _supabase.logActivity(
      userId: userId,
      type: type,
      description: description,
      amount: amount,
      metadata: metadata,
    );
  }

  /// Get user activities
  Future<List<Map<String, dynamic>>> getUserActivities(String userId) async {
    return await _supabase.getUserActivities(userId);
  }

  // ==================== TRANSFER OPERATIONS ====================
  
  /// Create transfer
  Future<Map<String, dynamic>?> createTransfer({
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String type,
    String? description,
  }) async {
    return await _supabase.insert('transfers', {
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'amount': amount,
      'type': type,
      'description': description,
      'status': 'pending',
    });
  }

  /// Get transfers for user
  Future<List<Map<String, dynamic>>> getUserTransfers(String userId) async {
    // Get transfers where user is either sender or receiver
    final sent = await _supabase.select('transfers', where: 'from_user_id', equals: userId);
    final received = await _supabase.select('transfers', where: 'to_user_id', equals: userId);
    
    // Combine and sort by date
    final allTransfers = [...sent, ...received];
    allTransfers.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
    
    return allTransfers;
  }

  // ==================== SUPPORT OPERATIONS ====================
  
  /// Create support conversation
  Future<Map<String, dynamic>?> createSupportConversation({
    required String userId,
    required String userEmail,
    required String userName,
    required String message,
  }) async {
    // Create conversation first
    final conversation = await _supabase.insert('support_conversations', {
      'user_id': userId,
      'user_email': userEmail,
      'user_name': userName,
      'status': 'pending',
      'last_message': message,
      'last_message_time': DateTime.now().toIso8601String(),
      'unread_count': 1,
    });

    if (conversation != null) {
      // Add first message
      await _supabase.insert('support_messages', {
        'conversation_id': conversation['id'],
        'user_id': userId,
        'user_email': userEmail,
        'user_name': userName,
        'message': message,
        'is_from_user': true,
        'is_read': false,
      });
    }

    return conversation;
  }

  /// Add message to support conversation
  Future<Map<String, dynamic>?> addSupportMessage({
    required String conversationId,
    required String userId,
    required String userEmail,
    required String userName,
    required String message,
    bool isFromUser = true,
  }) async {
    return await _supabase.insert('support_messages', {
      'conversation_id': conversationId,
      'user_id': userId,
      'user_email': userEmail,
      'user_name': userName,
      'message': message,
      'is_from_user': isFromUser,
      'is_read': false,
    });
  }

  /// Get support conversations for user
  Future<List<Map<String, dynamic>>> getUserSupportConversations(String userId) async {
    return await _supabase.select('support_conversations', where: 'user_id', equals: userId);
  }

  // ==================== ADMIN OPERATIONS ====================
  
  /// Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _supabase.select('users', orderBy: 'created_at', ascending: false);
  }

  /// Get all orders (admin only)
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    return await _supabase.select('orders', orderBy: 'created_at', ascending: false);
  }

  /// Get app statistics
  Future<Map<String, dynamic>> getAppStatistics() async {
    return await _supabase.getAppStatistics();
  }

  // ==================== APP CONFIG OPERATIONS ====================
  
  /// Get app config value
  Future<dynamic> getAppConfig(String key) async {
    final results = await _supabase.select('app_config', where: 'key', equals: key);
    return results.isNotEmpty ? results.first['value'] : null;
  }

  /// Set app config value
  Future<bool> setAppConfig(String key, dynamic value, {String? description}) async {
    final existing = await _supabase.select('app_config', where: 'key', equals: key);
    
    if (existing.isNotEmpty) {
      final result = await _supabase.update('app_config', existing.first['id'], {
        'value': value,
        'description': description,
      });
      return result != null;
    } else {
      final result = await _supabase.insert('app_config', {
        'key': key,
        'value': value,
        'description': description,
      });
      return result != null;
    }
  }
}