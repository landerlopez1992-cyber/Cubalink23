import 'package:flutter/material.dart';
import 'package:cubalink23/models/order.dart';
import 'package:cubalink23/services/firebase_repository.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/screens/profile/order_tracking_screen.dart'; // ✅ PANTALLA CORRECTA

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  _OrdersListScreenState createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  final FirebaseRepository _repository = FirebaseRepository.instance;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({bool showSuccessMessage = false}) async {
    setState(() => _isLoading = true);
    
    try {
      print('=== CARGANDO LISTA DE ÓRDENES ===');
      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser != null) {
        print('👤 Usuario actual: ${currentUser.id}');
        
        // Cargar órdenes desde Supabase
        final ordersData = await SupabaseService.instance.getUserOrdersRaw(currentUser.id);
        print('📦 Órdenes cargadas: ${ordersData.length}');
        
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
              shippingMethod: orderData['shipping_method'] ?? 'express',
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
            print('Error parsing order: $e');
            return null;
          }
        }).where((order) => order != null).cast<Order>().toList();
        
        if (mounted) {
          setState(() {
            _orders = orders;
            _isLoading = false;
          });
          
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
        print('❌ No hay usuario autenticado');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('❌ Error cargando órdenes: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Mis Órdenes',
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
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando órdenes...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : _orders.isEmpty
              ? _buildEmptyState()
              : _buildOrdersList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'No tienes órdenes aún',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tus pedidos aparecerán aquí después de realizar compras',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/store');
            },
            icon: Icon(Icons.shopping_cart),
            label: Text('Ir a la Tienda'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: () => _loadOrders(showSuccessMessage: true),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // ✅ NAVEGAR A LA PANTALLA CORRECTA CON ARREGLOS
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderTrackingScreen(selectedOrder: order), // ✅ PASAR ORDEN ESPECÍFICA
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de la orden
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Orden #${order.orderNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.orderStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(order.orderStatus),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Información básica
              Row(
                children: [
                  Icon(Icons.monetization_on, size: 16, color: Colors.green[600]),
                  SizedBox(width: 8),
                  Text(
                    'Total: \$${order.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    _getPaymentMethodText(order.paymentMethod),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Fecha y método de envío
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.local_shipping, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    _getShippingMethodText(order.shippingMethod),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Dirección de envío
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${order.shippingAddress.city}, ${order.shippingAddress.province}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'created':
      case 'payment_pending':
        return Colors.orange[600]!;
      case 'payment_confirmed':
      case 'processing':
        return Colors.blue[600]!;
      case 'shipped':
      case 'out_for_delivery':
        return Colors.purple[600]!;
      case 'delivered':
        return Colors.green[600]!;
      case 'cancelled':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'created': return 'Creada';
      case 'payment_pending': return 'Pago Pendiente';
      case 'payment_confirmed': return 'Pago Confirmado';
      case 'processing': return 'Procesando';
      case 'shipped': return 'Enviado';
      case 'out_for_delivery': return 'En Reparto';
      case 'delivered': return 'Entregado';
      case 'cancelled': return 'Cancelado';
      default: return 'Desconocido';
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'wallet': return 'Billetera';
      case 'card': return 'Tarjeta';
      case 'zelle': return 'Zelle';
      default: return method;
    }
  }

  String _getShippingMethodText(String method) {
    switch (method) {
      case 'express': return 'Express';
      case 'maritime': return 'Marítimo';
      case 'pickup': return 'Recoger';
      default: return method;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
