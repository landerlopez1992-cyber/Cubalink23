import 'package:flutter/material.dart';
import 'package:cubalink23/services/user_role_service.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  _VendorOrdersScreenState createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> with SingleTickerProviderStateMixin {
  final UserRoleService _roleService = UserRoleService();
  late TabController _tabController;
  
  List<Map<String, dynamic>> _pendingOrders = [];
  List<Map<String, dynamic>> _preparingOrders = [];
  List<Map<String, dynamic>> _shippedOrders = [];
  List<Map<String, dynamic>> _deliveredOrders = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    
    try {
      // Simular órdenes del vendedor
      // En producción, esto vendría de Supabase
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        _pendingOrders = [
          {
            'id': '1',
            'orderId': 'ORD-12345',
            'customerName': 'María González',
            'customerPhone': '+593 99 123 4567',
            'customerAddress': 'Av. Amazonas 1234, Quito',
            'deliveryType': 'delivery', // 'delivery' o 'pickup'
            'deliveryAddress': 'Calle 10 de Agosto 567, Quito',
            'totalAmount': 25.50,
            'items': [
              {'name': 'Pizza Margherita', 'quantity': 1, 'price': 12.00},
              {'name': 'Coca Cola 500ml', 'quantity': 2, 'price': 1.50},
              {'name': 'Ensalada César', 'quantity': 1, 'price': 8.50},
            ],
            'specialInstructions': 'Sin cebolla en la pizza',
            'orderTime': DateTime.now().subtract(Duration(minutes: 10)),
            'status': 'pending',
            'canVendorDeliver': false, // Si el vendedor configuró entrega propia
          },
          {
            'id': '2',
            'orderId': 'ORD-12346',
            'customerName': 'Carlos Rodríguez',
            'customerPhone': '+593 98 765 4321',
            'customerAddress': 'Av. 6 de Diciembre 890, Quito',
            'deliveryType': 'pickup',
            'deliveryAddress': null,
            'totalAmount': 18.75,
            'items': [
              {'name': 'Hamburguesa Clásica', 'quantity': 1, 'price': 15.00},
              {'name': 'Papas Fritas', 'quantity': 1, 'price': 3.75},
            ],
            'specialInstructions': 'Hamburguesa bien cocida',
            'orderTime': DateTime.now().subtract(Duration(minutes: 25)),
            'status': 'pending',
            'canVendorDeliver': true, // Vendedor configuró entrega propia
          },
        ];
        
        _preparingOrders = [
          {
            'id': '3',
            'orderId': 'ORD-12347',
            'customerName': 'Ana Martínez',
            'customerPhone': '+593 97 654 3210',
            'customerAddress': 'Av. Colón 456, Quito',
            'deliveryType': 'delivery',
            'deliveryAddress': 'Calle Reina Victoria 789, Quito',
            'totalAmount': 32.00,
            'items': [
              {'name': 'Sushi Roll California', 'quantity': 2, 'price': 16.00},
              {'name': 'Sopa Miso', 'quantity': 1, 'price': 8.00},
              {'name': 'Té Verde', 'quantity': 1, 'price': 4.00},
            ],
            'specialInstructions': 'Sushi fresco',
            'orderTime': DateTime.now().subtract(Duration(hours: 1)),
            'status': 'preparing',
            'canVendorDeliver': true,
          },
        ];
        
        _shippedOrders = [
          {
            'id': '4',
            'orderId': 'ORD-12348',
            'customerName': 'Luis Pérez',
            'customerPhone': '+593 96 543 2109',
            'customerAddress': 'Av. 12 de Octubre 321, Quito',
            'deliveryType': 'delivery',
            'deliveryAddress': 'Calle La Niña 654, Quito',
            'totalAmount': 28.50,
            'items': [
              {'name': 'Pasta Carbonara', 'quantity': 1, 'price': 18.00},
              {'name': 'Pan de Ajo', 'quantity': 1, 'price': 5.50},
              {'name': 'Jugo de Naranja', 'quantity': 1, 'price': 5.00},
            ],
            'specialInstructions': 'Pasta al dente',
            'orderTime': DateTime.now().subtract(Duration(hours: 2)),
            'status': 'shipped',
            'canVendorDeliver': true,
          },
        ];
        
        _deliveredOrders = [
          {
            'id': '5',
            'orderId': 'ORD-12349',
            'customerName': 'Elena Ruiz',
            'customerPhone': '+593 95 432 1098',
            'customerAddress': 'Av. Patria 987, Quito',
            'deliveryType': 'pickup',
            'deliveryAddress': null,
            'totalAmount': 22.00,
            'items': [
              {'name': 'Ensalada Mixta', 'quantity': 1, 'price': 12.00},
              {'name': 'Agua Mineral', 'quantity': 1, 'price': 2.00},
              {'name': 'Postre de Chocolate', 'quantity': 1, 'price': 8.00},
            ],
            'specialInstructions': 'Sin aceitunas',
            'orderTime': DateTime.now().subtract(Duration(days: 1)),
            'status': 'delivered',
            'canVendorDeliver': true,
          },
        ];
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando órdenes: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
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
            onPressed: _loadOrders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Pendientes',
              icon: Icon(Icons.pending_actions, size: 20),
            ),
            Tab(
              text: 'Preparando',
              icon: Icon(Icons.restaurant, size: 20),
            ),
            Tab(
              text: 'Enviadas',
              icon: Icon(Icons.local_shipping, size: 20),
            ),
            Tab(
              text: 'Entregadas',
              icon: Icon(Icons.done_all, size: 20),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(_pendingOrders, 'Pendientes'),
                _buildOrdersList(_preparingOrders, 'Preparando'),
                _buildOrdersList(_shippedOrders, 'Enviadas'),
                _buildOrdersList(_deliveredOrders, 'Entregadas'),
              ],
            ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders, String title) {
    if (orders.isEmpty) {
      return _buildEmptyState(title);
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: Color(0xFF2E7D32),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmptyStateIcon(title),
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No hay órdenes $title.toLowerCase()',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Las órdenes aparecerán aquí cuando los clientes hagan pedidos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getEmptyStateIcon(String title) {
    switch (title) {
      case 'Pendientes':
        return Icons.pending_actions;
      case 'Preparando':
        return Icons.restaurant;
      case 'Enviadas':
        return Icons.local_shipping;
      case 'Entregadas':
        return Icons.done_all;
      default:
        return Icons.shopping_cart;
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final deliveryType = order['deliveryType'] as String;
    final canVendorDeliver = order['canVendorDeliver'] as bool;
    final orderTime = order['orderTime'] as DateTime;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = Icons.pending_actions;
        break;
      case 'preparing':
        statusColor = Colors.blue;
        statusText = 'Preparando';
        statusIcon = Icons.restaurant;
        break;
      case 'shipped':
        statusColor = Colors.purple;
        statusText = 'Enviada';
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusText = 'Entregada';
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
        statusIcon = Icons.help;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    statusIcon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['orderId'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Cliente: ${order['customerName']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${order['totalAmount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                    Text(
                      _formatTimestamp(orderTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Order Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Delivery Type
                Row(
                  children: [
                    Icon(
                      deliveryType == 'delivery' ? Icons.local_shipping : Icons.store,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      deliveryType == 'delivery' ? 'Entrega a domicilio' : 'Recogida en tienda',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (canVendorDeliver && deliveryType == 'delivery')
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ENTREGA PROPIA',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                if (deliveryType == 'delivery' && order['deliveryAddress'] != null) ...[
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order['deliveryAddress'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text(
                      order['customerPhone'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                if (order['specialInstructions'] != null && order['specialInstructions'].isNotEmpty) ...[
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order['specialInstructions'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Items
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Productos:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      ...order['items'].map<Widget>((item) => Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              '${item['quantity']}x',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Text(
                              '\$${item['price'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          if (status == 'pending')
            _buildActionButtons(order)
          else if (status == 'preparing' && canVendorDeliver)
            _buildPreparingButtons(order)
          else if (status == 'shipped' && canVendorDeliver)
            _buildShippedButtons(order),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    final canVendorDeliver = order['canVendorDeliver'] as bool;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _startPreparing(order),
              icon: Icon(Icons.restaurant, size: 18),
              label: Text('Preparar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF2E7D32),
                side: BorderSide(color: Color(0xFF2E7D32)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (canVendorDeliver) ...[
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _assignToRepartidor(order),
                icon: Icon(Icons.local_shipping, size: 18),
                label: Text('Asignar Repartidor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreparingButtons(Map<String, dynamic> order) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _markAsShipped(order),
              icon: Icon(Icons.local_shipping, size: 18),
              label: Text('Marcar Enviada'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippedButtons(Map<String, dynamic> order) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _markAsDelivered(order),
              icon: Icon(Icons.done_all, size: 18),
              label: Text('Marcar Entregada'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startPreparing(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preparar Orden'),
        content: Text('¿Estás listo para preparar la orden ${order['orderId']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order, 'preparing');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Orden ${order['orderId']} en preparación'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: Text('Preparar'),
          ),
        ],
      ),
    );
  }

  void _assignToRepartidor(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Asignar Repartidor'),
        content: Text('¿Quieres asignar esta orden a un repartidor? Ya no podrás manejarla tú mismo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order, 'assigned_to_delivery');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Orden ${order['orderId']} asignada a repartidor'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Asignar'),
          ),
        ],
      ),
    );
  }

  void _markAsShipped(Map<String, dynamic> order) {
    _updateOrderStatus(order, 'shipped');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Orden ${order['orderId']} marcada como enviada'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _markAsDelivered(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Completar Entrega'),
        content: Text('¿Has entregado la orden ${order['orderId']} al cliente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order, 'delivered');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Orden ${order['orderId']} marcada como entregada'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Sí, Entregada'),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(Map<String, dynamic> order, String newStatus) {
    setState(() {
      // Remove from current list
      _pendingOrders.removeWhere((o) => o['id'] == order['id']);
      _preparingOrders.removeWhere((o) => o['id'] == order['id']);
      _shippedOrders.removeWhere((o) => o['id'] == order['id']);
      _deliveredOrders.removeWhere((o) => o['id'] == order['id']);
      
      // Update order status
      order['status'] = newStatus;
      
      // Add to appropriate list
      switch (newStatus) {
        case 'preparing':
          _preparingOrders.add(order);
          break;
        case 'shipped':
          _shippedOrders.add(order);
          break;
        case 'delivered':
          _deliveredOrders.add(order);
          break;
        case 'assigned_to_delivery':
          // Order is now handled by delivery system
          break;
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}