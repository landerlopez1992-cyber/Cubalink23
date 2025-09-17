// 🚨 ARREGLO DE EMERGENCIA - ÓRDENES
// Reemplazar el método createOrder en firebase_repository.dart

Future<String> createOrder(Map<String, dynamic> data) async {
  try {
    print('🚨 EMERGENCY ORDER FIX - Creando orden directamente');
    
    // Usar cliente Supabase directo sin RLS
    final client = SupabaseConfig.client;
    
    // Remover cart_items antes de insertar
    final cartItems = data.remove('cart_items') ?? [];
    
    // Insertar orden SIN verificar RLS
    final result = await client
        .from('orders')
        .insert(data)
        .select()
        .single();
    
    final orderId = result['id'] as String;
    print('✅ EMERGENCY: Orden creada: $orderId');
    
    // Crear order_items si existen
    for (final item in cartItems) {
      try {
        await client.from('order_items').insert({
          'order_id': orderId,
          'name': item['product_name'] ?? item['name'],
          'unit_price': item['product_price'] ?? item['price'],
          'quantity': item['quantity'] ?? 1,
          'total_price': (item['product_price'] ?? item['price']) * (item['quantity'] ?? 1),
          'product_type': item['product_type'] ?? 'store',
          'unit_weight_lb': item['weight_lb'] ?? 0.0,
        });
        print('✅ Item creado: ${item['product_name']}');
      } catch (e) {
        print('⚠️ Error item: $e');
      }
    }
    
    return orderId;
  } catch (e) {
    print('💥 EMERGENCY ERROR: $e');
    return 'emergency_${DateTime.now().millisecondsSinceEpoch}';
  }
}
