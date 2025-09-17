// 🔍 DEBUGGING: Agregar logs detallados al método _handleWalletPayment
// Para encontrar exactamente dónde falla la creación de órdenes

// INSTRUCCIONES:
// 1. Copia este código y reemplaza el método _handleWalletPayment en shipping_screen.dart
// 2. Compila la app
// 3. Haz una compra con saldo
// 4. Revisa los logs de Flutter

void _handleWalletPayment(Order order) async {
  try {
    print('👛 ===== INICIANDO PAGO CON BILLETERA =====');
    print('   💰 Total: \$${order.total.toStringAsFixed(2)}');
    print('   💳 Saldo disponible: \$${_userBalance.toStringAsFixed(2)}');
    print('   🆔 Order ID inicial: ${order.id}');
    print('   📦 Order Number: ${order.orderNumber}');
    print('   👤 User ID: ${order.userId}');

    // Verificar si el usuario tiene suficiente saldo
    if (_userBalance < order.total) {
      print('❌ Saldo insuficiente');
      _showErrorSnackBar(
          'Saldo insuficiente. Tu saldo es \$${_userBalance.toStringAsFixed(2)} y el total es \$${order.total.toStringAsFixed(2)}');
      return;
    }

    final currentUser = SupabaseAuthService.instance.getCurrentUser();
    if (currentUser == null) {
      print('❌ ERROR CRÍTICO: currentUser es null');
      _showErrorSnackBar('Error: Usuario no autenticado');
      return;
    }

    print('✅ Usuario verificado: ${currentUser.id}');
    print('📧 Email: ${currentUser.email}');

    // Crear la orden con pago completo
    print('🔄 Preparando datos de orden...');
    final orderData = order.toMap();
    print('📋 Datos base preparados, keys: ${orderData.keys.toList()}');
    
    orderData['payment_status'] = 'completed';
    orderData['order_status'] = 'payment_confirmed';
    orderData['payment_method'] = 'wallet';

    print('💾 Datos finales de orden:');
    print('   - user_id: ${orderData['user_id']}');
    print('   - order_number: ${orderData['order_number']}');
    print('   - total: ${orderData['total']}');
    print('   - payment_status: ${orderData['payment_status']}');
    print('   - order_status: ${orderData['order_status']}');
    print('   - payment_method: ${orderData['payment_method']}');
    print('   - cart_items count: ${(orderData['cart_items'] as List?)?.length ?? 0}');

    print('🚀 Llamando _repository.createOrder...');
    
    // ESTE ES EL PUNTO CRÍTICO - Aquí puede fallar
    String orderId;
    try {
      orderId = await _repository.createOrder(orderData);
      print('✅ _repository.createOrder retornó: $orderId');
      
      if (orderId.isEmpty) {
        throw Exception('Order ID vacío retornado por createOrder');
      }
      
    } catch (createOrderError) {
      print('💥 ERROR EN createOrder: $createOrderError');
      print('📋 Tipo de error: ${createOrderError.runtimeType}');
      _showErrorSnackBar('Error creando orden: $createOrderError');
      return;
    }

    print('✅ Orden creada con pago billetera: $orderId');

    // Descontar del saldo del usuario
    print('💰 Actualizando saldo usuario...');
    try {
      final newBalance = _userBalance - order.total;
      await _repository.updateUserBalance(currentUser.id, newBalance);
      print('✅ Saldo actualizado: \$${_userBalance.toStringAsFixed(2)} → \$${newBalance.toStringAsFixed(2)}');
    } catch (balanceError) {
      print('⚠️ Error actualizando saldo: $balanceError');
      // No es crítico, continuar
    }

    // Add delay to ensure proper saving
    print('⏳ Esperando 500ms para asegurar guardado...');
    await Future.delayed(const Duration(milliseconds: 500));

    // Registrar actividades
    print('📝 Registrando actividades...');
    try {
      await _repository.addActivity(
        order.userId,
        'order_created',
        'Orden #${order.orderNumber} pagada con billetera',
        amount: order.total,
      );
      print('✅ Actividad order_created registrada');

      await _repository.addActivity(
        order.userId,
        'amazon_purchase',
        'Compra en Amazon por \$${order.total.toStringAsFixed(2)}',
        amount: order.total,
      );
      print('✅ Actividad amazon_purchase registrada');
    } catch (activityError) {
      print('⚠️ Error registrando actividades: $activityError');
      // No es crítico, continuar
    }

    // 🎯 NOTIFICAR SERVICIO USADO PARA RECOMPENSAS DE REFERIDOS
    try {
      await AuthService.instance.notifyServiceUsed();
      print('✅ Compra con billetera completada - Recompensas de referidos procesadas');
    } catch (rewardError) {
      print('⚠️ Error en recompensas: $rewardError');
      // No es crítico, continuar
    }

    // Limpiar carrito
    print('🛒 Limpiando carrito...');
    _cartService.clearCart();
    print('✅ Carrito limpiado');

    // Mostrar diálogo de éxito
    print('🎉 Mostrando diálogo de éxito...');
    _showSuccessDialog(order.orderNumber, 'wallet');
    print('✅ Diálogo mostrado');

    print('👛 ===== PAGO CON BILLETERA COMPLETADO EXITOSAMENTE =====');
    
  } catch (e) {
    print('💥 ERROR GENERAL en pago con billetera: $e');
    print('📋 Stack trace: ${e.toString()}');
    print('📋 Tipo de error: ${e.runtimeType}');
    _showErrorSnackBar('Error al procesar el pago con billetera: ${e.toString()}');
  }
}

// TAMBIÉN AGREGAR LOGS AL MÉTODO createOrder en firebase_repository.dart:

Future<String> createOrder(Map<String, dynamic> data) async {
  try {
    print('🔄 FirebaseRepository.createOrder iniciado');
    print('📋 Data recibida: ${data.keys.toList()}');
    print('🎯 Llamando SupabaseService.createOrderRaw...');
    
    final result = await _supabaseService.createOrderRaw(data);
    
    if (result != null) {
      final orderId = result['id']?.toString() ?? 'order_${DateTime.now().millisecondsSinceEpoch}';
      print('✅ SupabaseService retornó: $orderId');
      return orderId;
    } else {
      print('❌ SupabaseService retornó null');
      return 'order_${DateTime.now().millisecondsSinceEpoch}';
    }
  } catch (e) {
    print('💥 ERROR en FirebaseRepository.createOrder: $e');
    return 'order_${DateTime.now().millisecondsSinceEpoch}';
  }
}
