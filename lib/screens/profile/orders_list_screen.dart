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
      backgroundColor: Color(0xFFF5F5F5), // Fondo general oficial Cubalink23
      appBar: AppBar(
        backgroundColor: Color(0xFF37474F), // Header oficial Cubalink23
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
                      Color(0xFF37474F), // Header oficial Cubalink23
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando órdenes...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666), // Texto secundario oficial
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
            color: Color(0xFF9E9E9E), // Gris claro oficial
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
              backgroundColor: Color(0xFF37474F), // Header oficial Cubalink23
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
                        color: Color(0xFF37474F), // Header oficial Cubalink23
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
                  Icon(Icons.monetization_on, size: 16, color: Color(0xFF4CAF50)), // Verde éxito oficial
                  SizedBox(width: 8),
                  Text(
                    'Total: \$${order.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50), // Verde éxito oficial
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.payment, size: 16, color: Color(0xFF666666)), // Texto secundario oficial
                  SizedBox(width: 4),
                  Text(
                    _getPaymentMethodText(order.paymentMethod),
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666), // Texto secundario oficial
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Fecha y método de envío
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Color(0xFF666666)), // Texto secundario oficial
                  SizedBox(width: 8),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666), // Texto secundario oficial
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.local_shipping, size: 16, color: Color(0xFF666666)), // Texto secundario oficial
                  SizedBox(width: 4),
                  Text(
                    _getShippingMethodText(order.shippingMethod),
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666), // Texto secundario oficial
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Dirección de envío
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Color(0xFF666666)), // Texto secundario oficial
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getShippingAddressText(order.shippingAddress),
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666), // Texto secundario oficial
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF9E9E9E), // Gris claro oficial
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
        return Color(0xFFFF9800); // Naranja oficial Cubalink23
      case 'payment_confirmed':
      case 'processing':
        return Color(0xFF37474F); // Header oficial Cubalink23
      case 'shipped':
      case 'out_for_delivery':
        return Color(0xFF37474F); // Header oficial Cubalink23
      case 'delivered':
        return Color(0xFF4CAF50); // Verde éxito oficial
      case 'cancelled':
        return Color(0xFFDC2626); // Rojo error oficial
      default:
        return Color(0xFF666666); // Texto secundario oficial
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

  String _getShippingAddressText(OrderAddress address) {
    // Construir dirección completa con verificación de campos vacíos
    List<String> addressParts = [];
    
    if (address.recipient.isNotEmpty && address.recipient != 'Sin destinatario') {
      addressParts.add(address.recipient);
    }
    
    if (address.address.isNotEmpty) {
      addressParts.add(address.address);
    }
    
    if (address.city.isNotEmpty) {
      addressParts.add(address.city);
    }
    
    if (address.province.isNotEmpty && address.province != 'Cuba') {
      addressParts.add(address.province);
    } else if (address.province.isEmpty && address.city.isNotEmpty) {
      addressParts.add('Cuba'); // Fallback si no hay provincia
    }
    
    if (addressParts.isEmpty) {
      return 'Dirección no disponible';
    }
    
    return addressParts.join(', ');
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
