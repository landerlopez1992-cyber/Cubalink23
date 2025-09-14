import 'package:flutter/material.dart';
import 'package:cubalink23/services/user_role_service.dart';

class DeliveryAssignedOrdersScreen extends StatefulWidget {
  const DeliveryAssignedOrdersScreen({super.key});

  @override
  _DeliveryAssignedOrdersScreenState createState() => _DeliveryAssignedOrdersScreenState();
}

class _DeliveryAssignedOrdersScreenState extends State<DeliveryAssignedOrdersScreen> {
  final UserRoleService _roleService = UserRoleService();
  List<Map<String, dynamic>> _assignedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignedOrders();
  }

  Future<void> _loadAssignedOrders() async {
    setState(() => _isLoading = true);
    
    try {
      // Simular órdenes asignadas
      // En producción, esto vendría de Supabase
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        _assignedOrders = [
          {
            'id': '1',
            'orderId': 'ORD-12345',
            'customerName': 'María González',
            'customerPhone': '+593 99 123 4567',
            'customerAddress': 'Av. Amazonas 1234, Quito',
            'deliveryAddress': 'Calle 10 de Agosto 567, Quito',
            'distance': '2.5 km',
            'estimatedTime': '15 min',
            'totalAmount': 25.50,
            'items': [
              {'name': 'Pizza Margherita', 'quantity': 1, 'price': 12.00},
              {'name': 'Coca Cola 500ml', 'quantity': 2, 'price': 1.50},
              {'name': 'Ensalada César', 'quantity': 1, 'price': 8.50},
            ],
            'specialInstructions': 'Llamar al llegar. Casa blanca con portón azul.',
            'assignedAt': DateTime.now().subtract(Duration(minutes: 5)),
            'status': 'pending', // pending, accepted, in_delivery, delivered, cancelled
            'priority': 'normal', // low, normal, high, urgent
          },
          {
            'id': '2',
            'orderId': 'ORD-12346',
            'customerName': 'Carlos Rodríguez',
            'customerPhone': '+593 98 765 4321',
            'customerAddress': 'Av. 6 de Diciembre 890, Quito',
            'deliveryAddress': 'Calle Los Shyris 123, Quito',
            'distance': '1.8 km',
            'estimatedTime': '12 min',
            'totalAmount': 18.75,
            'items': [
              {'name': 'Hamburguesa Clásica', 'quantity': 1, 'price': 15.00},
              {'name': 'Papas Fritas', 'quantity': 1, 'price': 3.75},
            ],
            'specialInstructions': 'Entregar en oficina, piso 3.',
            'assignedAt': DateTime.now().subtract(Duration(minutes: 15)),
            'status': 'pending',
            'priority': 'high',
          },
          {
            'id': '3',
            'orderId': 'ORD-12347',
            'customerName': 'Ana Martínez',
            'customerPhone': '+593 97 654 3210',
            'customerAddress': 'Av. Colón 456, Quito',
            'deliveryAddress': 'Calle Reina Victoria 789, Quito',
            'distance': '3.2 km',
            'estimatedTime': '20 min',
            'totalAmount': 32.00,
            'items': [
              {'name': 'Sushi Roll California', 'quantity': 2, 'price': 16.00},
              {'name': 'Sopa Miso', 'quantity': 1, 'price': 8.00},
              {'name': 'Té Verde', 'quantity': 1, 'price': 4.00},
            ],
            'specialInstructions': 'Sin cebolla en el sushi.',
            'assignedAt': DateTime.now().subtract(Duration(minutes: 30)),
            'status': 'accepted',
            'priority': 'normal',
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando órdenes asignadas: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Color(0xFF1976D2),
        title: Text(
          'Órdenes Asignadas',
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
            onPressed: _loadAssignedOrders,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1976D2),
              ),
            )
          : _assignedOrders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadAssignedOrders,
                  color: Color(0xFF1976D2),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _assignedOrders.length,
                    itemBuilder: (context, index) {
                      final order = _assignedOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No hay órdenes asignadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Las órdenes aparecerán aquí cuando el sistema te asigne entregas',
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final priority = order['priority'] as String;
    final assignedAt = order['assignedAt'] as DateTime;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = Icons.pending_actions;
        break;
      case 'accepted':
        statusColor = Colors.blue;
        statusText = 'Aceptada';
        statusIcon = Icons.check_circle;
        break;
      case 'in_delivery':
        statusColor = Colors.purple;
        statusText = 'En Reparto';
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusText = 'Entregada';
        statusIcon = Icons.done_all;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelada';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
        statusIcon = Icons.help;
    }

    Color priorityColor;
    switch (priority) {
      case 'urgent':
        priorityColor = Colors.red;
        break;
      case 'high':
        priorityColor = Colors.orange;
        break;
      case 'normal':
        priorityColor = Colors.blue;
        break;
      case 'low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
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
          // Header con información básica
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
                      Row(
                        children: [
                          Text(
                            order['orderId'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              priority.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
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
                      _formatTimestamp(assignedAt),
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
          
          // Información de entrega
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
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
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text(
                      '${order['distance']} - ${order['estimatedTime']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Spacer(),
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
              ],
            ),
          ),
          
          // Botones de acción
          if (status == 'pending')
            Container(
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
                      onPressed: () => _cancelOrder(order),
                      icon: Icon(Icons.cancel, size: 18),
                      label: Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptOrder(order),
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Aceptar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (status == 'accepted')
            Container(
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
                    child: OutlinedButton.icon(
                      onPressed: () => _startDelivery(order),
                      icon: Icon(Icons.local_shipping, size: 18),
                      label: Text('Iniciar Reparto'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF1976D2),
                        side: BorderSide(color: Color(0xFF1976D2)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (status == 'in_delivery')
            Container(
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
                      onPressed: () => _completeDelivery(order),
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
            ),
        ],
      ),
    );
  }

  void _acceptOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aceptar Orden'),
        content: Text('¿Estás seguro de que quieres aceptar la orden ${order['orderId']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                order['status'] = 'accepted';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Orden ${order['orderId']} aceptada'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Orden'),
        content: Text('¿Estás seguro de que quieres cancelar la orden ${order['orderId']}?\n\nLa orden será reasignada al repartidor más cercano.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                order['status'] = 'cancelled';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Orden ${order['orderId']} cancelada. Se reasignará automáticamente.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _startDelivery(Map<String, dynamic> order) {
    setState(() {
      order['status'] = 'in_delivery';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reparto iniciado para orden ${order['orderId']}'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _completeDelivery(Map<String, dynamic> order) {
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
              setState(() {
                order['status'] = 'delivered';
              });
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
}





