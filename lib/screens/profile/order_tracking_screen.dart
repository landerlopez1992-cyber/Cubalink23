import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cubalink23/models/order.dart';
import 'package:cubalink23/services/firebase_repository.dart';
import 'package:cubalink23/services/auth_service.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/supabase_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order? selectedOrder; // ✅ NUEVO: Orden específica seleccionada
  
  const OrderTrackingScreen({super.key, this.selectedOrder});

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _truckAnimationController;
  late AnimationController _vibrationController;
  late Animation<double> _truckAnimation;
  late Animation<double> _vibrationAnimation;
  
  List<Order> _orders = [];
  bool _isLoading = true;
  int _selectedOrderIndex = 0;
  bool showCelebration = false;
  
  final FirebaseRepository _repository = FirebaseRepository.instance;
  final AuthService _authService = AuthService();

  final List<Map<String, String>> statusList = [
    {'title': 'Orden Creada', 'subtitle': ''},
    {'title': 'Pago Pendiente', 'subtitle': ''},
    {'title': 'Pago Confirmado', 'subtitle': ''},
    {'title': 'Procesando', 'subtitle': ''},
    {'title': 'Enviado', 'subtitle': ''},
    {'title': 'En Reparto', 'subtitle': ''},
    {'title': 'Entregado', 'subtitle': ''},
    // ✅ "Cancelado" NO aparece en timeline visual (solo en lógica)
  ];

  // ✅ PARSEAR ITEMS DE LA ORDEN DESDE SUPABASE
  List<OrderItem> _parseOrderItems(dynamic itemsData) {
    if (itemsData == null) return [];
    
    try {
      if (itemsData is List) {
        return itemsData.map((item) {
          if (item is Map<String, dynamic>) {
            return OrderItem(
              id: item['id'] ?? '',
              productId: item['product_id'] ?? item['productId'] ?? '',
              name: item['name'] ?? item['product_name'] ?? item['title'] ?? 'Producto',
              imageUrl: item['image_url'] ?? item['imageUrl'] ?? item['image'] ?? item['picture'] ?? '',
              price: (item['price'] ?? 0.0).toDouble(),
              quantity: item['quantity'] ?? 1,
              category: item['category'] ?? 'general',
              type: item['type'] ?? 'product',
            );
          }
          return OrderItem(
            id: '',
            productId: '',
            name: 'Producto',
            imageUrl: '',
            price: 0.0,
            quantity: 1,
            category: 'general',
            type: 'product',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error parseando items: $e');
      return [];
    }
  }

  Map<String, dynamic> _parseMetadata(dynamic metadata) {
    try {
      if (metadata == null) return {};
      
      if (metadata is String) {
        // Si es un string JSON, parsearlo
        final parsed = jsonDecode(metadata);
        if (parsed is Map<String, dynamic>) {
          return parsed;
        }
      } else if (metadata is Map<String, dynamic>) {
        // Si ya es un Map, devolverlo directamente
        return metadata;
      }
      
      return {};
    } catch (e) {
      print('❌ Error parseando metadata: $e');
      return {};
    }
  }

  DateTime? _parseDateTime(dynamic dateTime) {
    try {
      if (dateTime == null) return null;
      
      if (dateTime is String) {
        return DateTime.parse(dateTime);
      } else if (dateTime is DateTime) {
        return dateTime;
      }
      
      return null;
    } catch (e) {
      print('❌ Error parseando fecha: $e');
      return DateTime.now();
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
      
      // Fallback si no es Map
      return OrderAddress(
        recipient: 'Sin destinatario',
        phone: '',
        address: '',
        city: '',
        province: 'Cuba',
      );
    } catch (e) {
      print('❌ Error parseando shipping_address: $e');
      return OrderAddress(
        recipient: 'Sin destinatario',
        phone: '',
        address: '',
        city: '',
        province: 'Cuba',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    
    // ✅ SI HAY ORDEN ESPECÍFICA, USARLA DIRECTAMENTE
    if (widget.selectedOrder != null) {
      _orders = [widget.selectedOrder!];
      _selectedOrderIndex = 0;
      setState(() => _isLoading = false);
      print('✅ Usando orden específica: ${widget.selectedOrder!.orderNumber}');
      print('📋 Orden específica - ID: ${widget.selectedOrder!.id}');
      print('📋 Orden específica - Total: \$${widget.selectedOrder!.total}');
      print('📋 Orden específica - Items: ${widget.selectedOrder!.items.length}');
      // ✅ INICIALIZAR ANIMACIONES DESPUÉS DE TENER LA ORDEN
      _setupAnimations();
    } else {
      print('⚠️ No hay orden específica - cargando todas las órdenes');
      _loadOrders();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔄 didChangeDependencies llamado');
    print('🔄 Widget selectedOrder: ${widget.selectedOrder?.orderNumber ?? "null"}');
    print('🔄 Current orders count: ${_orders.length}');
    
    // ✅ SOLO recargar si NO hay orden específica
    if (widget.selectedOrder == null) {
      print('🔄 Recargando órdenes (no hay orden específica)');
      _loadOrders();
    } else {
      print('🔄 NO recargando - usando orden específica: ${widget.selectedOrder!.orderNumber}');
    }
  }

  Future<void> _loadOrders({bool showSuccessMessage = false}) async {
    if (!mounted) return;
    
    // Only show loading on first load, not on refreshes
    if (_orders.isEmpty) {
      setState(() => _isLoading = true);
    }
    
    try {
      print('=== LOADING ORDERS FOR USER ===');
      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser != null) {
        print('👤 Current user: ${currentUser.id}');
        
        // Cargar órdenes reales desde Supabase CON ITEMS
        print('🔍 Cargando órdenes para usuario: ${currentUser.id}');
        final ordersData = await SupabaseService.instance.getUserOrdersRaw(currentUser.id);
        
        // ✅ CARGAR ITEMS PARA CADA ORDEN
        for (var orderData in ordersData) {
          try {
            final orderId = orderData['id'];
            final orderItems = await SupabaseService.instance.select(
              'order_items',
              where: 'order_id',
              equals: orderId,
            );
            orderData['items'] = orderItems; // ✅ AGREGAR ITEMS A LA ORDEN
            print('📦 Orden ${orderData['order_number']}: ${orderItems.length} items cargados');
          } catch (e) {
            print('⚠️ Error cargando items para orden ${orderData['id']}: $e');
            orderData['items'] = []; // Fallback a lista vacía
          }
        }
        print('📦 Órdenes cargadas desde Supabase: ${ordersData.length}');
        
        if (ordersData.isEmpty) {
          print('⚠️ NO SE ENCONTRARON ÓRDENES para usuario ${currentUser.id}');
          print('💡 Posibles causas:');
          print('   1. Las órdenes no se están creando correctamente');
          print('   2. Error en el filtro por user_id');
          print('   3. Error en los permisos RLS de Supabase');
        } else {
          print('✅ Órdenes encontradas:');
          for (int i = 0; i < ordersData.length && i < 3; i++) {
            final order = ordersData[i];
            print('   ${i + 1}. ${order['order_number']} - \$${order['total']} - ${order['order_status']}');
          }
        }
        
        final orders = ordersData.map((orderData) {
          try {
            print('🔍 Parseando orden: ${orderData['order_number']}');
            print('📋 Campos disponibles: ${orderData.keys.toList()}');
            
            return Order(
              id: orderData['id'] ?? '',
              userId: orderData['user_id'] ?? '',
              orderNumber: orderData['order_number'] ?? '',
              items: _parseOrderItems(orderData['items']), // ✅ CARGAR ITEMS REALES
              subtotal: (orderData['subtotal'] ?? 0.0).toDouble(),
              shippingCost: (orderData['shipping_cost'] ?? 0.0).toDouble(),
              total: (orderData['total'] ?? 0.0).toDouble(),
              orderStatus: orderData['order_status'] ?? 'created',
              paymentStatus: orderData['payment_status'] ?? 'pending',
              paymentMethod: orderData['payment_method'] ?? 'card',
              shippingMethod: orderData['shipping_method'] ?? 'standard',
              shippingAddress: _parseShippingAddress(orderData['shipping_address']),
              createdAt: _parseDateTime(orderData['created_at']) ?? DateTime.now(),
              updatedAt: _parseDateTime(orderData['updated_at']) ?? DateTime.now(),
              estimatedDelivery: _parseDateTime(orderData['estimated_delivery']),
              metadata: _parseMetadata(orderData['metadata']),
            );
          } catch (e) {
            print('❌ Error parsing order ${orderData['order_number']}: $e');
            print('📋 Datos de la orden problemática: ${orderData.toString()}');
            return null;
          }
        }).where((order) => order != null).cast<Order>().toList();
        
        print('📦 Orders loaded from Supabase: ${orders.length}');
        
        for (final order in orders) {
          print('   🛒 Order: ${order.orderNumber} - Status: ${order.orderStatus} - Total: \$${order.total} - Created: ${order.createdAt}');
        }
        
        if (mounted) {
          setState(() {
            _orders = orders;
            _isLoading = false;
            // Reset to first order if we have orders
            if (_orders.isNotEmpty) {
              _selectedOrderIndex = 0;
            }
          });
          
          if (_orders.isNotEmpty) {
            _setupAnimations();
          }
          print('✅ STATE UPDATED - Orders in widget: ${_orders.length}');
          
          // Show success message only on manual refresh
          if (showSuccessMessage && _orders.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Órdenes actualizadas - ${_orders.length} órdenes encontradas'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        print('❌ No current user found');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('❌ ERROR LOADING ORDERS: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar órdenes: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    print('=== ORDER LOADING COMPLETE ===');
  }

  void _setupAnimations() {
    if (_orders.isEmpty) return;
    
    _truckAnimationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _vibrationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    int currentStatus = _getOrderStatusIndex(_orders[_selectedOrderIndex].orderStatus);
    
    _truckAnimation = Tween<double>(
      begin: 0,
      end: (currentStatus - 1) / 6, // Posición del camión basada en el status
    ).animate(CurvedAnimation(
      parent: _truckAnimationController,
      curve: Curves.easeInOut,
    ));

    _vibrationAnimation = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _vibrationController,
      curve: Curves.linear,
    ));

    _truckAnimationController.forward();
    _vibrationController.repeat(reverse: true); // ✅ Vibración constante
    
    // Si está entregado, mostrar celebración
    if (_orders[_selectedOrderIndex].orderStatus == 'delivered') {
      _showDeliveredCelebration();
    }
  }

  int _getOrderStatusIndex(String status) {
    switch (status) {
      case 'created': return 1;
      case 'payment_pending': return 2;
      case 'payment_confirmed': return 3;
      case 'processing': return 4;
      case 'shipped': return 5;
      case 'out_for_delivery': return 6;
      case 'delivered': return 7;
      case 'cancelled': return 8; // ✅ NUEVO ESTADO CANCELADO
      default: return 1;
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'created': return 'Orden Creada';
      case 'payment_pending': return 'Pago Pendiente';
      case 'payment_confirmed': return 'Pago Confirmado';
      case 'processing': return 'Procesando';
      case 'shipped': return 'Enviado';
      case 'out_for_delivery': return 'En Reparto';
      case 'delivered': return 'Entregado';
      case 'cancelled': return 'Cancelado'; // ✅ NOMBRE CORRECTO
      default: return 'Desconocido';
    }
  }

  void _showDeliveredCelebration() {
    setState(() => showCelebration = true);
    // Celebración removida temporalmente
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : () {
              print('🔄 Manual refresh requested by user');
              // ✅ SI HAY ORDEN ESPECÍFICA, NO RECARGAR TODAS
              if (widget.selectedOrder != null) {
                print('🔄 Orden específica - NO recargando todas las órdenes');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Orden actualizada'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 1),
                  ),
                );
              } else {
                _loadOrders(showSuccessMessage: true);
              }
            },
            tooltip: 'Actualizar órdenes',
          ),
        ],
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
                      SizedBox(height: 8),
                      Text(
                        'Tus órdenes aparecerán aquí una vez que realices una compra',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(12), // ✅ Reducido de 16 a 12
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selector de orden si hay múltiples
                            // ✅ ELIMINADO: Selector de órdenes (está en "Mis Órdenes")
                            
                            // Información de la orden
                            _buildOrderInfoCard(),
                            SizedBox(height: 24),
                            
                            // Línea de tiempo con avión
                            _buildTrackingTimeline(),
                            SizedBox(height: 24),
                            
                            // Detalles del envío
                            _buildShippingDetails(),
                            SizedBox(height: 24),
                            
                            // Productos de la orden
                            _buildOrderItems(),
                            SizedBox(height: 24),
                            
                            // Botones de acción
                            _buildActionButtons(),
                            SizedBox(height: 50), // ✅ ESPACIO EXTRA PARA ACCESIBILIDAD
                          ],
                        ),
                      ),
                    ),
                    
                    // Overlay de celebración
                    if (showCelebration) _buildCelebrationOverlay(),
                  ],
                ),
    );
  }

  Widget _buildOrderSelector() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12), // ✅ Reducido
      child: Padding(
        padding: EdgeInsets.all(12), // ✅ Reducido
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar Orden:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final isSelected = _selectedOrderIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedOrderIndex = index;
                      });
                      _setupAnimations();
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                        border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text(
                          order.orderNumber,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    if (_orders.isEmpty) return SizedBox();
    
    final order = _orders[_selectedOrderIndex];
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12), // ✅ Reducido
        child: Row(
          children: [
            // Imagen del primer producto
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: firstItem != null && firstItem.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        firstItem.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            firstItem.type == 'recharge' ? Icons.phone : Icons.shopping_bag,
                            color: Colors.grey[400],
                            size: 32,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.shopping_bag,
                      color: Colors.grey[400],
                      size: 32,
                    ),
            ),
            SizedBox(width: 16),
            
            // Detalles
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
                    order.shippingMethod == 'express' ? 'Envío Express' : 'Envío Marítimo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity( 0.7),
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
                  SizedBox(height: 2),
                  Text(
                    'Fecha: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity( 0.6),
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

  Widget _buildTrackingTimeline() {
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
            SizedBox(height: 20),
            
            // ✅ BANNER DE CANCELACIÓN (si la orden está cancelada)
            if (_orders.isNotEmpty && _orders[_selectedOrderIndex].orderStatus == 'cancelled') ...[
              // ✅ LOG PARA DEBUG
              Builder(builder: (context) {
                print('🚨 Mostrando banner de cancelación para orden: ${_orders[_selectedOrderIndex].orderNumber}');
                return SizedBox.shrink();
              }), 
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red[700], size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Esta orden fue cancelada',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // ✅ TIMELINE HORIZONTAL COMPACTO (TODO EN PANTALLA)
            Container(
              height: 100, // ✅ MÁS COMPACTO
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ✅ DISTRIBUIR UNIFORMEMENTE
                children: statusList.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> status = entry.value;
                  int currentStatus = _getOrderStatusIndex(_orders.isNotEmpty ? _orders[_selectedOrderIndex].orderStatus : 'created');
                  bool isCompleted = (index + 1) < currentStatus;
                  bool isCurrent = (index + 1) == currentStatus;
                  
                  return Expanded( // ✅ CADA ESTADO OCUPA ESPACIO IGUAL
                    child: _buildCompactTimelineStep(
                      status['title']!,
                      isCompleted,
                      isCurrent,
                    ),
                  );
                }).toList(),
              ),
            ),
            
            SizedBox(height: 16),
            
            // ✅ CAMIÓN ANIMADO HORIZONTAL (SEPARADO)
            Container(
              height: 60,
              child: Stack(
                children: [
                  // Línea de progreso horizontal
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 30,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // 🚛 Camión animado horizontal
                  AnimatedBuilder(
                    animation: _truckAnimation,
                    builder: (context, child) {
                      int currentStatus = _getOrderStatusIndex(_orders.isNotEmpty ? _orders[_selectedOrderIndex].orderStatus : 'created');
                      double progress = (currentStatus - 1) / 6; // ✅ PROGRESO 0-1 (7 estados sin cancelado)
                      double screenWidth = MediaQuery.of(context).size.width;
                      double stepWidth = screenWidth / 7; // ✅ DIVIDIR PANTALLA EN 7 PARTES IGUALES
                      double truckPosition = (stepWidth * (currentStatus - 1)) + (stepWidth / 2) - 20; // ✅ CENTRADO EN CADA PASO
                      
                      return AnimatedBuilder(
                        animation: _vibrationAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: truckPosition + _vibrationAnimation.value, // ✅ Movimiento horizontal
                            top: 15,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange[600],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.local_shipping, // 🚛 Camión
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ PASO SÚPER COMPACTO (TODO EN PANTALLA)
  Widget _buildCompactTimelineStep(String title, bool isCompleted, bool isCurrent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Círculo pequeño
        Container(
          width: 24, // ✅ SÚPER PEQUEÑO
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted 
                ? Colors.green 
                : isCurrent 
                    ? Colors.blue 
                    : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted 
                ? Icons.check 
                : isCurrent 
                    ? Icons.radio_button_checked 
                    : Icons.radio_button_unchecked,
            color: isCompleted || isCurrent ? Colors.white : Colors.grey[600],
            size: 12, // ✅ ICONO PEQUEÑO
          ),
        ),
        SizedBox(height: 4),
        // Texto súper compacto
        Text(
          title,
          style: TextStyle(
            fontSize: 8, // ✅ TEXTO MUY PEQUEÑO
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? Colors.blue[700] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ✅ NUEVO: PASO HORIZONTAL DEL TIMELINE
  Widget _buildHorizontalTimelineStep(String title, String subtitle, bool isCompleted, bool isCurrent) {
    return Container(
      width: 60, // ✅ REDUCIDO PARA QUE NO SE SALGA
      child: Column(
        children: [
          // Círculo del estado
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Colors.green 
                  : isCurrent 
                      ? Colors.blue 
                      : Colors.grey[300],
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted 
                    ? Colors.green[700]! 
                    : isCurrent 
                        ? Colors.blue[700]! 
                        : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Icon(
              isCompleted 
                  ? Icons.check 
                  : isCurrent 
                      ? Icons.radio_button_checked 
                      : Icons.radio_button_unchecked,
              color: isCompleted || isCurrent ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          SizedBox(height: 8),
          // Título del estado
          Text(
            title,
            style: TextStyle(
              fontSize: 9, // ✅ TEXTO MÁS PEQUEÑO
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? Colors.blue[700] : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isCompleted, bool isCurrent, bool isLast) {
    return SizedBox(
      height: isLast ? 60 : 60,
      child: Row(
        children: [
          // Círculo del paso
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : isCurrent
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey[300],
              border: Border.all(
                color: isCompleted || isCurrent
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check
                  : isCurrent
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
              color: isCompleted
                  ? Colors.white
                  : isCurrent
                      ? Colors.white
                      : Colors.grey[500],
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          
          // Texto del paso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted || isCurrent
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.grey[600],
                  ),
                ),
                Text(
                  subtitle,
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
    );
  }

  Widget _buildShippingDetails() {
    if (_orders.isEmpty) return SizedBox();
    
    final order = _orders[_selectedOrderIndex];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12), // ✅ Reducido
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles del Envío',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16),
            
            _buildDetailRow(
              Icons.local_shipping,
              'Método',
              order.shippingMethod == 'express' ? 'Envío Express' : 'Envío Marítimo'
            ),
            if (order.estimatedDelivery != null)
              _buildDetailRow(
                Icons.schedule,
                'Entrega Estimada',
                '${order.estimatedDelivery!.day}/${order.estimatedDelivery!.month}/${order.estimatedDelivery!.year}'
              ),
            _buildDetailRow(
              Icons.location_on,
              'Destino',
              '${order.shippingAddress.city}, ${order.shippingAddress.province}'
            ),
            _buildDetailRow(
              Icons.info,
              'Estado Actual',
              _getStatusTitle(order.orderStatus)
            ),
            _buildDetailRow(
              Icons.payment,
              'Método de Pago',
              order.paymentMethod == 'zelle' ? 'Zelle' : 'Tarjeta'
            ),
            _buildDetailRow(
              Icons.monetization_on,
              'Estado del Pago',
              order.paymentStatus == 'completed' ? 'Pagado' : order.paymentStatus == 'pending' ? 'Pendiente' : 'No pagado'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    if (_orders.isEmpty) return SizedBox();
    
    final order = _orders[_selectedOrderIndex];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12), // ✅ Reducido
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos (${order.items.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16),
            
            ...order.items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: item.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  item.type == 'recharge' ? Icons.phone : Icons.image,
                                  color: Colors.grey[400],
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : Icon(
                            item.type == 'recharge' ? Icons.phone : Icons.image,
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
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Cantidad: ${item.quantity}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            )).toList(),
            
            Divider(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  '\$${order.subtotal.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Envío:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  '\$${order.shippingCost.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusSubtitle(int statusIndex) {
    if (_orders.isEmpty) return '';
    
    final order = _orders[_selectedOrderIndex];
    
    switch (statusIndex) {
      case 0: // Orden Creada
        return '${order.createdAt.day}/${order.createdAt.month} - ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';
      case 1: // Pago Pendiente
        return order.paymentStatus == 'pending' ? 'Esperando comprobante' : '';
      case 2: // Pago Confirmado
        return order.paymentStatus == 'completed' ? 'Verificado' : '';
      default:
        return '';
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity( 0.7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_orders.isEmpty) return SizedBox();
    
    final order = _orders[_selectedOrderIndex];
    final canCancel = order.orderStatus != 'delivered' && 
                     order.orderStatus != 'cancelled' && 
                     order.orderStatus != 'out_for_delivery' &&
                     order.orderStatus != 'shipped';
    
    return SingleChildScrollView( // ✅ ENVOLVER EN SCROLL PARA EVITAR OVERFLOW
      child: Column(
        children: [
          if (canCancel) ...[
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 8), // ✅ MARGEN PARA NO SALIRSE
              child: ElevatedButton.icon(
                onPressed: () => _showCancelOrderConfirmation(),
                icon: Icon(Icons.cancel_outlined, size: 18),
                label: Text('Cancelar Pedido', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16), // ✅ REDUCIDO
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
          
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 8), // ✅ MARGEN PARA NO SALIRSE
            child: OutlinedButton(
              onPressed: _openSupportChat, // ✅ USAR FUNCIÓN CENTRALIZADA
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16), // ✅ REDUCIDO
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Contactar Soporte', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    // TEMPORALMENTE DESHABILITADO - ARREGLAR ANIMACIONES
    return Container(); // Placeholder
    /*
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity( 0.8 * _celebrationAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _celebrationAnimation.value,
              child: Container(
                margin: EdgeInsets.all(40),
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animación de estrellas
                    SizedBox(
                      height: 100,
                      child: Stack(
                        children: List.generate(8, (index) {
                          return Positioned(
                            left: (index % 4) * 60.0,
                            top: (index ~/ 4) * 50.0,
                            child: Transform.rotate(
                              angle: _celebrationAnimation.value * 2 * math.pi,
                              child: Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20 + (_celebrationAnimation.value * 10),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    
                    Text(
                      '🎉 ¡Felicidades! 🎉',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Su pedido fue entregado exitosamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: () {
                        setState(() => showCelebration = false);
                        // _celebrationController removido temporalmente
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('¡Genial!'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    */
  }

  String _getCurrentStatusText() {
    if (_orders.isEmpty) return 'Sin órdenes';
    return _getStatusTitle(_orders[_selectedOrderIndex].orderStatus);
  }

  void _showCancelOrderConfirmation() {
    if (_orders.isEmpty) return;
    
    final order = _orders[_selectedOrderIndex];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cancelar Pedido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF232F3E),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El pedido se puede cancelar solo si aún no se ha procesado. Una vez que el pedido está siendo procesado o ya fue enviado, no es posible cancelarlo.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Orden: ${order.orderNumber}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Total: \$${order.total.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Estado actual: ${_getStatusDisplayName(order.orderStatus)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              '¿Desea continuar con la cancelación?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF232F3E),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processCancellation(order); // ✅ NUEVA LÓGICA INTELIGENTE
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Sí, Cancelar Pedido'),
          ),
        ],
      ),
    );
  }

  // ✅ NUEVA LÓGICA INTELIGENTE DE CANCELACIÓN
  void _processCancellation(Order order) {
    // Verificar si se puede cancelar según el estado
    final canCancel = _canOrderBeCancelled(order.orderStatus);
    
    if (canCancel) {
      // ✅ SE PUEDE CANCELAR
      _cancelOrder(order);
    } else {
      // ❌ NO SE PUEDE CANCELAR - MOSTRAR MODAL DE ERROR
      _showCannotCancelDialog(order);
    }
  }

  // ✅ VERIFICAR SI UNA ORDEN SE PUEDE CANCELAR
  bool _canOrderBeCancelled(String orderStatus) {
    final cancellableStates = [
      'created',
      'payment_pending', 
      'payment_confirmed',
      'pending_payment',
    ];
    return cancellableStates.contains(orderStatus.toLowerCase());
  }

  // ✅ MODAL CUANDO NO SE PUEDE CANCELAR
  void _showCannotCancelDialog(Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No se puede cancelar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Este pedido ya no se puede cancelar porque está siendo procesado y está listo para el envío.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Orden: ${order.orderNumber}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Estado: ${_getStatusDisplayName(order.orderStatus)}',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.red[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Si necesita ayuda, puede contactar a nuestro equipo de soporte.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendido',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openSupportChat(); // ✅ ABRIR CHAT DE SOPORTE
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Contactar Soporte'),
          ),
        ],
      ),
    );
  }

  // ✅ OBTENER NOMBRE LEGIBLE DEL ESTADO
  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return 'Orden Creada';
      case 'payment_pending':
        return 'Pago Pendiente';
      case 'payment_confirmed':
        return 'Pago Confirmado';
      case 'processing':
        return 'Procesando';
      case 'shipped':
        return 'Enviado';
      case 'out_for_delivery':
        return 'En Reparto';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  // ✅ ABRIR CHAT DE SOPORTE (CONECTA CON WEB ADMIN)
  void _openSupportChat() {
    try {
      // TODO: Implementar navegación al chat de soporte
      Navigator.pushNamed(context, '/support-chat');
      print('🔗 Abriendo chat de soporte...');
    } catch (e) {
      print('❌ Error abriendo chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error abriendo chat de soporte'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelOrder(Order order) async {
    try {
      // Mostrar pantalla de procesamiento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Procesando cancelación del pedido...'),
              SizedBox(height: 8),
              Text(
                'Por favor espera mientras procesamos la cancelación',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
      
      // Simular procesamiento
      await Future.delayed(Duration(seconds: 2));
      
      // Cerrar diálogo de procesamiento
      Navigator.pop(context);
      
      // Actualizar estado local a "cancelación pendiente"
      setState(() {
        _orders[_selectedOrderIndex] = order.copyWith(
          orderStatus: 'cancelled',
          updatedAt: DateTime.now(),
        );
      });
      
      // Actualizar animaciones
      _setupAnimations();
      
      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido cancelado - Cancelación Pendiente'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Actualizar en Supabase en segundo plano
      try {
        await SupabaseService.instance.updateOrderStatus(order.id, 'cancelled');
      } catch (e) {
        print('Error actualizando en Supabase: $e');
      }
      
    } catch (e) {
      // Cerrar diálogo si está abierto
      Navigator.of(context).popUntil((route) => route is! DialogRoute);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar el pedido'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _truckAnimationController.dispose();
    _vibrationController.dispose();
    super.dispose();
  }
}