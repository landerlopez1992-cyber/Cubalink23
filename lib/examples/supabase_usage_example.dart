import 'package:cubalink23/services/supabase_client_service.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';

/// Example demonstrating how to use the Supabase client in CubaLink23
class SupabaseUsageExample {
  
  // ==================== AUTHENTICATION EXAMPLES ====================
  
  /// Example: Register a new user
  static Future<void> exampleRegisterUser() async {
    try {
      final authService = SupabaseAuthService.instance;
      
      final user = await authService.registerUser(
        email: 'nuevo@ejemplo.com',
        password: 'password123',
        name: 'Juan Pérez',
        phone: '+593987654321',
        country: 'Ecuador',
        city: 'Quito',
      );
      
      if (user != null) {
        print('✅ Usuario registrado: ${user.name}');
      } else {
        print('❌ Error registrando usuario');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  
  /// Example: Login user
  static Future<void> exampleLoginUser() async {
    try {
      final authService = SupabaseAuthService.instance;
      
      final user = await authService.loginUser(
        email: 'usuario@ejemplo.com',
        password: 'password123',
      );
      
      if (user != null) {
        print('✅ Usuario logueado: ${user.name}');
        print('💰 Balance: \$${authService.userBalance.toStringAsFixed(2)}');
      } else {
        print('❌ Error en login');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  
  // ==================== DATABASE EXAMPLES ====================
  
  /// Example: Add a contact using the client service
  static Future<void> exampleAddContact() async {
    try {
      // Get current user ID
      final authService = SupabaseAuthService.instance;
      final userId = authService.currentUserId;
      
      if (userId == null) {
        print('❌ Usuario no autenticado');
        return;
      }
      
      // Using the client service directly
      final result = await supabase.insertRecord('contacts', {
        'user_id': userId,
        'name': 'María González',
        'phone_number': '+5355555555',
        'operator': 'Cubacel',
        'country': 'Cuba',
      });
      
      if (result != null) {
        print('✅ Contacto agregado exitosamente');
      } else {
        print('❌ Error agregando contacto');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  
  /// Example: Get user's recharge history
  static Future<void> exampleGetRecharges() async {
    try {
      final authService = SupabaseAuthService.instance;
      final userId = authService.currentUserId;
      
      if (userId == null) {
        print('❌ Usuario no autenticado');
        return;
      }
      
      final recharges = await supabase.selectRecords(
        'recharge_history',
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
        limit: 10,
      );
      
      print('📱 Historial de recargas (${recharges.length} encontradas):');
      for (final recharge in recharges.take(3)) { // Show only first 3
        print('- ${recharge['phone_number']}: \$${recharge['amount']} (${recharge['status']})');
      }
    } catch (e) {
      print('❌ Error obteniendo recargas: $e');
    }
  }
  
  /// Example: Add recharge record
  static Future<void> exampleAddRecharge() async {
    try {
      final authService = SupabaseAuthService.instance;
      final userId = authService.currentUserId;
      
      if (userId == null) {
        print('❌ Usuario no autenticado');
        return;
      }
      
      final result = await supabase.insertRecord('recharge_history', {
        'user_id': userId,
        'phone_number': '+5355555555',
        'operator': 'Cubacel',
        'country': 'Cuba',
        'amount': 10.00,
        'status': 'completed',
        'metadata': {
          'package': 'Datos 1GB',
          'validity': '30 días',
        },
      });
      
      if (result != null) {
        print('✅ Recarga registrada exitosamente');
      } else {
        print('❌ Error registrando recarga');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  
  // ==================== STORE EXAMPLES ====================
  
  /// Example: Get store categories
  static Future<void> exampleGetStoreCategories() async {
    try {
      final categories = await supabase.selectRecords(
        'store_categories',
        filters: {'is_active': true},
        orderBy: 'sort_order',
      );
      
      print('🛍️ Categorías de tienda (${categories.length} encontradas):');
      for (final category in categories) {
        print('- ${category['name']} (${category['is_active'] ? 'Activa' : 'Inactiva'})');
      }
    } catch (e) {
      print('❌ Error obteniendo categorías: $e');
    }
  }
  
  /// Example: Get featured products
  static Future<void> exampleGetFeaturedProducts() async {
    try {
      final products = await supabase.selectRecords(
        'store_products',
        filters: {'is_featured': true, 'is_active': true},
        orderBy: 'created_at',
        ascending: false,
        limit: 5,
      );
      
      print('⭐ Productos destacados (${products.length} encontrados):');
      for (final product in products) {
        print('- ${product['name']}: \$${product['price']} (Stock: ${product['stock']})');
      }
    } catch (e) {
      print('❌ Error obteniendo productos destacados: $e');
    }
  }
  
  // ==================== CART EXAMPLES ====================
  
  /// Example: Add item to cart
  static Future<void> exampleAddToCart() async {
    try {
      final authService = SupabaseAuthService.instance;
      final userId = authService.currentUserId;
      
      if (userId == null) {
        print('❌ Usuario no autenticado');
        return;
      }
      
      final result = await supabase.insertRecord('cart_items', {
        'user_id': userId,
        'product_id': 'some-product-id',
        'product_name': 'iPhone 15 Pro',
        'product_price': 999.99,
        'quantity': 1,
        'selected_color': 'Azul Titanio',
        'selected_size': '128GB',
        'product_type': 'store',
      });
      
      if (result != null) {
        print('✅ Producto agregado al carrito');
      } else {
        print('❌ Error agregando al carrito');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  
  /// Example: Get cart items
  static Future<void> exampleGetCartItems() async {
    try {
      final authService = SupabaseAuthService.instance;
      final userId = authService.currentUserId;
      
      if (userId == null) {
        print('❌ Usuario no autenticado');
        return;
      }
      
      final cartItems = await supabase.selectRecords(
        'cart_items',
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
      );
      
      print('🛒 Items en el carrito (${cartItems.length} items):');
      double total = 0.0;
      for (final item in cartItems) {
        final subtotal = (item['product_price'] as double) * (item['quantity'] as int);
        total += subtotal;
        print('- ${item['product_name']} x${item['quantity']}: \$${subtotal.toStringAsFixed(2)}');
      }
      print('💰 Total: \$${total.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Error obteniendo carrito: $e');
    }
  }
  
  // ==================== STORAGE EXAMPLES ====================
  
  /// Example: Upload a profile image
  static Future<void> exampleUploadProfileImage(List<int> imageBytes) async {
    try {
      final authService = SupabaseAuthService.instance;
      final userId = authService.currentUserId;
      
      if (userId == null) {
        print('❌ Usuario no autenticado');
        return;
      }
      
      final imageUrl = await supabase.uploadFile(
        'profile-photos', 
        '$userId/profile.jpg', 
        imageBytes,
      );
      
      if (imageUrl != null) {
        print('✅ Imagen subida: $imageUrl');
      } else {
        print('❌ Error subiendo imagen');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  
  // ==================== NOTIFICATIONS EXAMPLES ====================
  
  /// Example: Add a notification
  static Future<void> exampleAddNotification() async {
    try {
      final authService = SupabaseAuthService.instance;
      final userId = authService.currentUserId;
      
      if (userId == null) {
        print('❌ Usuario no autenticado');
        return;
      }
      
      final result = await supabase.insertRecord('notifications', {
        'user_id': userId,
        'type': 'recharge',
        'title': 'Recarga Completada',
        'message': 'Tu recarga de \$10.00 ha sido procesada exitosamente',
        'data': {
          'phone': '+5355555555',
          'amount': 10.00,
          'operator': 'Cubacel',
        },
        'read': false,
      });
      
      if (result != null) {
        print('✅ Notificación enviada');
      } else {
        print('❌ Error enviando notificación');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  
  /// Example: Get user notifications
  static Future<void> exampleGetNotifications() async {
    try {
      final authService = SupabaseAuthService.instance;
      final userId = authService.currentUserId;
      
      if (userId == null) {
        print('❌ Usuario no autenticado');
        return;
      }
      
      final notifications = await supabase.selectRecords(
        'notifications',
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
        limit: 10,
      );
      
      print('🔔 Notificaciones (${notifications.length} encontradas):');
      for (final notification in notifications.take(3)) { // Show only first 3
        final status = notification['read'] ? '✅' : '🔴';
        print('$status ${notification['title']}: ${notification['message']}');
      }
    } catch (e) {
      print('❌ Error obteniendo notificaciones: $e');
    }
  }
  
  // ==================== COMPREHENSIVE EXAMPLE ====================
  
  /// Complete workflow example: Register → Login → Add Recharge → Check Balance
  static Future<void> exampleCompleteWorkflow() async {
    print('🚀 === COMPLETE SUPABASE WORKFLOW EXAMPLE ===');
    
    try {
      final authService = SupabaseAuthService.instance;
      
      // 1. Check if user is already logged in
      final isLoggedIn = await authService.isUserLoggedIn();
      
      if (!isLoggedIn) {
        print('⚠️ User not logged in, example workflow requires authentication');
        return;
      }
      
      // 2. Get current user info
      print('👤 Current user: ${authService.currentUser?.name ?? 'Unknown'}');
      print('💰 Current balance: \$${authService.userBalance.toStringAsFixed(2)}');
      
      final userId = authService.currentUserId!;
      
      // 3. Add a contact
      await supabase.insertRecord('contacts', {
        'user_id': userId,
        'name': 'Test Contact',
        'phone_number': '+5355555555',
        'operator': 'Cubacel',
        'country': 'Cuba',
      });
      
      // 4. Add a recharge
      await supabase.insertRecord('recharge_history', {
        'user_id': userId,
        'phone_number': '+5355555555',
        'operator': 'Cubacel',
        'country': 'Cuba',
        'amount': 15.00,
        'status': 'completed',
      });
      
      // 5. Update balance (simulate)
      await authService.updateUserBalance(authService.userBalance + 15.00);
      
      // 6. Log the activity
      await supabase.insertRecord('activities', {
        'user_id': userId,
        'type': 'recharge',
        'description': 'Recarga telefónica completada',
        'amount': 15.00,
        'metadata': {
          'phone': '+5355555555',
          'operator': 'Cubacel',
        },
      });
      
      // 7. Send notification
      await supabase.insertRecord('notifications', {
        'user_id': userId,
        'type': 'recharge_success',
        'title': 'Recarga Exitosa',
        'message': 'Tu recarga de \$15.00 ha sido completada',
        'read': false,
      });
      
      print('✅ === WORKFLOW COMPLETED SUCCESSFULLY ===');
      
    } catch (e) {
      print('❌ === WORKFLOW FAILED: $e ===');
    }
  }
}