import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cubalink23/models/order.dart';
import 'package:cubalink23/services/firebase_repository.dart';
import 'package:cubalink23/services/auth_service.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/supabase_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _planeAnimationController;
  late AnimationController _celebrationController;
  late Animation<double> _planeAnimation;
  late Animation<double> _celebrationAnimation;
  
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
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload orders when screen is revisited
    _loadOrders();
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
        
        // Cargar órdenes reales desde Supabase
        final ordersData = await SupabaseService.instance.getUserOrdersRaw(currentUser.id);
        
        final orders = ordersData.map((orderData) {
          try {
            return Order(
              id: orderData['id'] ?? '',
              userId: orderData['user_id'] ?? '',
              orderNumber: orderData['order_number'] ?? '',
              items: [], // Se cargarían por separado si es necesario
              subtotal: (orderData['subtotal'] ?? 0.0).toDouble(),
              shippingCost: (orderData['shipping_cost'] ?? 0.0).toDouble(),
              total: (orderData['total'] ?? 0.0).toDouble(),
              orderStatus: orderData['order_status'] ?? 'created',
              paymentStatus: orderData['payment_status'] ?? 'pending',
              paymentMethod: orderData['payment_method'] ?? 'card',
              shippingMethod: orderData['shipping_method'] ?? 'standard',
              shippingAddress: OrderAddress(
                recipient: orderData['shipping_recipient'] ?? '',
                phone: orderData['shipping_phone'] ?? '',
                address: orderData['shipping_street'] ?? '',
                city: orderData['shipping_city'] ?? '',
                province: orderData['shipping_province'] ?? '',
              ),
              createdAt: DateTime.parse(orderData['created_at'] ?? DateTime.now().toIso8601String()),
              updatedAt: DateTime.parse(orderData['updated_at'] ?? DateTime.now().toIso8601String()),
              estimatedDelivery: orderData['estimated_delivery'] != null 
                  ? DateTime.parse(orderData['estimated_delivery']) 
                  : null,
              metadata: orderData['metadata'] ?? {},
            );
          } catch (e) {
            print('Error parsing order data: $e');
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
    
    _planeAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    int currentStatus = _getOrderStatusIndex(_orders[_selectedOrderIndex].orderStatus);
    
    _planeAnimation = Tween<double>(
      begin: 0,
      end: (currentStatus - 1) / 6, // Posición del avión basada en el status (7 estados, índice 0-6)
    ).animate(CurvedAnimation(
      parent: _planeAnimationController,
      curve: Curves.easeInOut,
    ));

    _celebrationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _planeAnimationController.forward();
    
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
      case 'cancelled': return 'Cancelación Pendiente';
      default: return 'Desconocido';
    }
  }

  void _showDeliveredCelebration() {
    setState(() => showCelebration = true);
    _celebrationController.forward();
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
              _loadOrders(showSuccessMessage: true);
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
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selector de orden si hay múltiples
                            if (_orders.length > 1) _buildOrderSelector(),
                            
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
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
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
        padding: EdgeInsets.all(16),
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
            
            // Timeline con avión animado
            SizedBox(
              height: 420, // Increased for 7 states
              child: Stack(
                children: [
                  // Línea vertical de fondo
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: Colors.grey[300],
                    ),
                  ),
                  
                  // Pasos del timeline
                  Column(
                    children: statusList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, String> status = entry.value;
                      int currentStatus = _getOrderStatusIndex(_orders.isNotEmpty ? _orders[_selectedOrderIndex].orderStatus : 'created');
                      bool isCompleted = (index + 1) < currentStatus;
                      bool isCurrent = (index + 1) == currentStatus;
                      
                      return _buildTimelineStep(
                        status['title']!,
                        _getStatusSubtitle(index),
                        isCompleted,
                        isCurrent,
                        index == statusList.length - 1,
                      );
                    }).toList(),
                  ),
                  
                  // Avión animado
                  AnimatedBuilder(
                    animation: _planeAnimation,
                    builder: (context, child) {
                      return Positioned(
                        left: 35,
                        top: _planeAnimation.value * 360 + 8, // Ajustar para 7 estados
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity( 0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.flight,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
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
        padding: EdgeInsets.all(16),
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
        padding: EdgeInsets.all(16),
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
    
    return Column(
      children: [
        if (canCancel) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCancelOrderConfirmation(),
              icon: Icon(Icons.cancel_outlined),
              label: Text('Cancelar Pedido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Contactar soporte
              Navigator.pushNamed(context, '/support-chat');
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Contactar Soporte'),
          ),
        ),
      ],
    );
  }

  Widget _buildCelebrationOverlay() {
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
                        _celebrationController.reset();
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
      builder: (context) => AlertDialog(
        title: Text('Cancelar Pedido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que deseas cancelar este pedido?'),
            SizedBox(height: 8),
            Text(
              'Orden: ${order.orderNumber}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Total: \$${order.total.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Una vez cancelado, el sistema procesará la cancelación y el pedido pasará a estado "Cancelación Pendiente".',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelOrder(order);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Cancelar Pedido'),
          ),
        ],
      ),
    );
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
    _planeAnimationController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }
}