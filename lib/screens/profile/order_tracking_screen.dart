import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cubalink23/models/order.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/supabase_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order? selectedOrder;

  const OrderTrackingScreen({
    super.key,
    this.selectedOrder,
  });

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('=== INIT STATE - ORDER TRACKING ===');
    print('🔍 widget.selectedOrder: ${widget.selectedOrder?.orderNumber ?? 'null'}');
    print('🔍 widget.selectedOrder items count: ${widget.selectedOrder?.items.length ?? 0}');

    // ✅ SI HAY ORDEN ESPECÍFICA, CARGAR SUS DETALLES COMPLETOS
    if (widget.selectedOrder != null) {
      print('🔄 Cargando detalles de orden específica: ${widget.selectedOrder!.orderNumber}');
      _loadSpecificOrder(widget.selectedOrder!.id);
    } else {
      print('⚠️ No hay orden específica - cargando todas las órdenes');
    _loadOrders();
    }
  }

  Future<void> _loadSpecificOrder(String orderId) async {
      setState(() => _isLoading = true);
    
    try {
      print('=== LOADING SPECIFIC ORDER ===');
      print('🔍 Buscando orden con ID: $orderId');

      // Verificar si el usuario está autenticado
      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser == null) {
        print('❌ No hay usuario autenticado');
        Navigator.of(context).pop();
        return;
      }

      // Usar el método para obtener una sola orden con sus ítems
      final orderData = await SupabaseService.instance.getOrderWithItems(orderId);

      print('📦 orderData result: ${orderData?.toString() ?? 'NULL'}');

      if (orderData == null) {
        print('❌ No se encontró la orden con ID: $orderId');
        setState(() => _isLoading = false);
        return;
      }

      // Parsear los ítems de la orden
      final items = _parseOrderItems(orderData['items']);

      // 💰 CALCULAR TOTAL AUTOMÁTICAMENTE si viene null
      double calculatedTotal = 0.0;
      if (items.isNotEmpty) {
        calculatedTotal = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
        print('💰 Total calculado desde productos: \$${calculatedTotal.toStringAsFixed(2)}');
      }

      final order = Order(
        id: orderData['id'] ?? '',
        userId: orderData['user_id'] ?? '',
        orderNumber: orderData['order_number'] ?? 'N/A',
        items: items,
        subtotal: calculatedTotal,
        shippingCost: (orderData['shipping_cost'] ?? 0.0).toDouble(),
        total: (orderData['total_amount'] ?? orderData['total'] ?? calculatedTotal).toDouble(),
        orderStatus: orderData['order_status'] ?? 'pending',
        paymentStatus: orderData['payment_status'] ?? 'pending',
        paymentMethod: orderData['payment_method'] ?? 'card',
        shippingMethod: orderData['shipping_method'] ?? 'standard',
        shippingAddress: _parseShippingAddress(orderData['shipping_address']),
        createdAt: DateTime.tryParse(orderData['created_at']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: orderData['updated_at'] != null
            ? DateTime.tryParse(orderData['updated_at'].toString())
            : null,
        estimatedDelivery: orderData['estimated_delivery'] != null
            ? DateTime.tryParse(orderData['estimated_delivery'].toString())
            : null,
        metadata: orderData['metadata'] is Map<String, dynamic>
            ? orderData['metadata']
            : <String, dynamic>{},
      );

      print('🔄 Actualizando estado con la orden específica');
      print('📦 Orden final - Items count: ${order.items.length}');

      setState(() {
        _orders = [order];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error en _loadSpecificOrder: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser != null) {
        final ordersData = await SupabaseService.instance.getUserOrdersWithItems(currentUser.id);

        final orders = ordersData.map((orderData) {
            return Order(
              id: orderData['id'] ?? '',
              userId: orderData['user_id'] ?? '',
              orderNumber: orderData['order_number'] ?? '',
            items: _parseOrderItems(orderData['items']),
              subtotal: (orderData['subtotal'] ?? 0.0).toDouble(),
              shippingCost: (orderData['shipping_cost'] ?? 0.0).toDouble(),
              total: (orderData['total'] ?? 0.0).toDouble(),
              orderStatus: orderData['order_status'] ?? 'created',
              paymentStatus: orderData['payment_status'] ?? 'pending',
              paymentMethod: orderData['payment_method'] ?? 'card',
              shippingMethod: orderData['shipping_method'] ?? 'standard',
            shippingAddress: _parseShippingAddress(orderData['shipping_address']),
            createdAt: DateTime.tryParse(orderData['created_at']?.toString() ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(orderData['updated_at']?.toString() ?? '') ?? DateTime.now(),
              estimatedDelivery: orderData['estimated_delivery'] != null 
                ? DateTime.tryParse(orderData['estimated_delivery'].toString())
                  : null,
            metadata: orderData['metadata'] is Map<String, dynamic>
                ? orderData['metadata']
                : <String, dynamic>{},
          );
        }).toList();

          setState(() {
            _orders = orders;
            _isLoading = false;
        });
      } else {
          setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ ERROR LOADING ORDERS: $e');
        setState(() => _isLoading = false);
    }
  }

  List<OrderItem> _parseOrderItems(dynamic itemsData) {
    if (itemsData == null) {
      print('⚠️ itemsData es null');
      return [];
    }

    try {
      print('🔍 Parseando items - Tipo: ${itemsData.runtimeType}');
      
      List<dynamic> itemsList = [];
      if (itemsData is List) {
        itemsList = itemsData;
        print('✅ itemsData es List con ${itemsList.length} elementos');
      } else if (itemsData is String) {
        print('🔄 itemsData es String, decodificando JSON...');
        final parsed = jsonDecode(itemsData);
        if (parsed is List) {
          itemsList = parsed;
          print('✅ JSON decodificado a List con ${itemsList.length} elementos');
        }
      }

      if (itemsList.isEmpty) {
        print('⚠️ itemsList está vacía');
        return [];
      }

      return itemsList.map((item) {
        if (item is Map<String, dynamic>) {
          // 🔍 LOGGING DETALLADO PARA DEBUG
          print('   📦 Item: ${item['name'] ?? item['product_name'] ?? 'sin nombre'}');
          print('      🖼️ Image: ${item['image_url'] ?? item['imageUrl'] ?? item['image'] ?? item['picture'] ?? 'sin imagen'}');
          print('      💰 Price: ${item['price'] ?? item['product_price'] ?? item['unit_price'] ?? 0.0}');
          print('      🔢 Quantity: ${item['quantity'] ?? 1}');
          print('      📂 Category: ${item['category'] ?? 'general'}');
          print('      🏷️ Type: ${item['type'] ?? item['product_type'] ?? 'product'}');

          return OrderItem(
            id: item['id'] ?? '',
            productId: item['product_id'] ?? item['productId'] ?? '',
            name: item['name'] ?? item['product_name'] ?? 'Producto sin nombre',
            imageUrl: item['image_url'] ?? item['imageUrl'] ?? item['image'] ?? item['picture'] ?? '',
            price: (item['price'] ?? item['product_price'] ?? item['unit_price'] ?? 0.0).toDouble(),
            quantity: item['quantity'] ?? 1,
            category: item['category'] ?? 'general',
            type: item['type'] ?? item['product_type'] ?? 'product',
          );
        }
        print('⚠️ Item no es Map<String, dynamic>: ${item.runtimeType}');
        return OrderItem(
          id: '',
          productId: '',
          name: 'Producto (formato incorrecto)',
          imageUrl: '',
          price: 0.0,
          quantity: 1,
          category: 'general',
          type: 'product',
        );
      }).toList();
    } catch (e) {
      print('❌ Error parseando items: $e');
      return [];
    }
  }

  OrderAddress _parseShippingAddress(dynamic shippingAddress) {
    try {
      if (shippingAddress == null) {
        return OrderAddress(
          recipient: 'Sin destinatario',
          phone: '',
          address: '',
          city: '',
          province: 'Cuba',
        );
      }

      if (shippingAddress is Map<String, dynamic>) {
        return OrderAddress(
          recipient: shippingAddress['recipient'] ?? 'Sin destinatario',
          phone: shippingAddress['phone'] ?? '',
          address: shippingAddress['address'] ?? '',
          city: shippingAddress['city'] ?? '',
          province: shippingAddress['province'] ?? 'Cuba',
        );
      }

      return OrderAddress(
        recipient: 'Sin destinatario',
        phone: '',
        address: '',
        city: '',
        province: 'Cuba',
      );
    } catch (e) {
      return OrderAddress(
        recipient: 'Sin destinatario',
        phone: '',
        address: '',
        city: '',
        province: 'Cuba',
      );
    }
  }

  String _getPaymentMethodName(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'card':
        return 'Tarjeta';
      case 'wallet':
        return 'Billetera';
      case 'zelle':
        return 'Zelle';
      default:
        return paymentMethod;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Rastreo de Mi Orden',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando órdenes...'),
                ],
              ),
            )
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No tienes órdenes aún',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOrderInfoCard(),
                            SizedBox(height: 24),
                            _buildOrderStatusTimeline(),
                            SizedBox(height: 24),
                            _buildOrderItems(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    final order = _orders.first;
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Total: \$${order.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Método: ${_getPaymentMethodName(order.paymentMethod)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Destinatario: ${order.shippingAddress.recipient}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Teléfono: ${order.shippingAddress.phone}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Destino: ${order.shippingAddress.city}, ${order.shippingAddress.province}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusTimeline() {
    final order = _orders.first;
    
    // Estados posibles de la orden
    List<Map<String, dynamic>> allStates = [
      {'status': 'created', 'label': 'Creada', 'icon': Icons.receipt},
      {'status': 'processing', 'label': 'Procesando', 'icon': Icons.settings},
      {'status': 'shipped', 'label': 'Enviada', 'icon': Icons.local_shipping},
      {'status': 'delivered', 'label': 'Entregada', 'icon': Icons.check_circle},
    ];
    
    // Agregar estado cancelado solo si la orden está cancelada
    if (order.orderStatus.toLowerCase() == 'cancelled' || order.orderStatus.toLowerCase() == 'canceled') {
      allStates = [
        {'status': 'created', 'label': 'Creada', 'icon': Icons.receipt},
        {'status': 'cancelled', 'label': 'Cancelada', 'icon': Icons.cancel},
      ];
    }
    
    // Determinar estado actual
    String currentStatus = order.orderStatus.toLowerCase();
    int currentIndex = allStates.indexWhere((state) => state['status'] == currentStatus);
    if (currentIndex == -1) currentIndex = 0; // Default a primer estado
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de la Orden',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16),
            
            // Timeline horizontal
            Row(
              children: allStates.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> state = entry.value;
                bool isActive = index <= currentIndex;
                bool isCurrent = index == currentIndex;
                bool isLast = index == allStates.length - 1;
                
                return Expanded(
                  child: Column(
                    children: [
                      // Línea horizontal (excepto el último)
                      Row(
                        children: [
                          // Círculo del estado
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive 
                                  ? (state['status'] == 'cancelled' 
                                      ? Colors.red 
                                      : Theme.of(context).colorScheme.primary)
                                  : Colors.grey[300],
                              border: Border.all(
                                color: isCurrent 
                                    ? (state['status'] == 'cancelled' 
                                        ? Colors.red 
                                        : Theme.of(context).colorScheme.primary)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              state['icon'],
                              color: isActive ? Colors.white : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                          
                          // Línea conectora (excepto el último)
                          if (!isLast)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: isActive && index < currentIndex 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Colors.grey[300],
                              ),
                            ),
                        ],
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Texto del estado
                      Text(
                        state['label'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isActive 
                              ? (state['status'] == 'cancelled' 
                                  ? Colors.red 
                                  : Theme.of(context).colorScheme.primary)
                              : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Camioncito debajo del estado actual
                      if (isCurrent && state['status'] != 'cancelled')
                        Icon(
                          Icons.local_shipping,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        )
                      else
                        SizedBox(height: 24), // Espacio vacío para mantener alineación
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    final order = _orders.first;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                  'Productos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${order.items.length} ${order.items.length == 1 ? 'producto' : 'productos'}',
                  style: TextStyle(
                    fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
            ),
            SizedBox(height: 16),
            
            if (order.items.isEmpty)
              Container(
        padding: EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Text(
                  'No hay productos en esta orden',
              style: TextStyle(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                      color: Colors.grey[200],
                    ),
                    child: item.imageUrl.isNotEmpty
                        ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                        item.type == 'recharge' ? Icons.phone : Icons.shopping_bag,
                                  color: Colors.grey[400],
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : Icon(
                                  item.type == 'recharge' ? Icons.phone : Icons.shopping_bag,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                              SizedBox(height: 4),
                        Text(
                          'Cantidad: ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                                  color: Colors.grey[600],
                          ),
                        ),
                              SizedBox(height: 2),
                  Text(
                                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                                  fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
