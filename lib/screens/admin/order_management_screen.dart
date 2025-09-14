import 'package:flutter/material.dart';
import 'package:cubalink23/models/order.dart' as AppOrder;
import 'package:cubalink23/services/supabase_service.dart';
import 'package:intl/intl.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Commented out for compilation
  List<AppOrder.Order> _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';
  String _searchQuery = '';

  // Estados disponibles
  final List<String> _orderStatuses = [
    'Pendiente',
    'Confirmado',
    'Procesando',
    'Enviado',
    'Entregado',
    'Cancelado',
  ];

  final List<String> _paymentStatuses = [
    'Pendiente',
    'Pagado',
    'Fallido',
    'Reembolsado',
  ];

  final List<String> _cancellationStatuses = [
    'Sin Solicitud',
    'Cancelación Pendiente',
    'Cancelado',
    'No Cancelado - Ya Enviado',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      print('🔄 [ADMIN] Cargando órdenes reales desde Supabase...');
      
      setState(() => _isLoading = true);
      
      // Cargar órdenes reales desde Supabase
      final ordersData = await SupabaseService.instance.getAllOrdersRaw();
      
      final orders = ordersData.map((orderData) {
        return AppOrder.Order(
          id: orderData['id'] ?? '',
          userId: orderData['user_id'] ?? '',
          orderNumber: orderData['order_number'] ?? '',
          items: [],
          subtotal: (orderData['subtotal'] ?? 0.0).toDouble(),
          shippingCost: (orderData['shipping_cost'] ?? 0.0).toDouble(),
          total: (orderData['total'] ?? 0.0).toDouble(),
          orderStatus: orderData['order_status'] ?? 'pending',
          paymentStatus: orderData['payment_status'] ?? 'pending',
          paymentMethod: orderData['payment_method'] ?? 'card',
          shippingMethod: orderData['shipping_method'] ?? 'standard',
          shippingAddress: AppOrder.OrderAddress(
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
      }).toList();
      
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
      
      print('🎯 [ADMIN] Órdenes reales cargadas desde Supabase: ${orders.length}');
    } catch (e) {
      print('❌ [ADMIN] Error cargando órdenes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  List<AppOrder.Order> get _filteredOrders {
    List<AppOrder.Order> filtered = _orders;

    // Filtro por estado
    if (_selectedFilter != 'Todos') {
      filtered = filtered.where((order) {
        switch (_selectedFilter) {
          case 'Pendientes':
            return order.orderStatus == 'Pendiente';
          case 'Enviadas':
            return order.orderStatus == 'Enviado';
          case 'Entregadas':
            return order.orderStatus == 'Entregado';
          case 'Canceladas':
            return order.orderStatus == 'Cancelado';
          case 'Pago Pendiente':
            return order.paymentStatus == 'Pendiente';
          default:
            return true;
        }
      }).toList();
    }

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        return order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.shippingAddress.recipient.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  Future<void> _updateOrderStatus(String orderId, String field, String newStatus) async {
    try {
      // Actualizar estado real en Supabase
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (field == 'order_status') {
        updateData['order_status'] = newStatus;
      } else if (field == 'payment_status') {
        updateData['payment_status'] = newStatus;
      }
      
      await SupabaseService.instance.update('orders', orderId, updateData);

      // Actualizar localmente
      setState(() {
        int index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          AppOrder.Order updatedOrder;
          switch (field) {
            case 'order_status':
              updatedOrder = _orders[index].copyWith(orderStatus: newStatus);
              break;
            case 'payment_status':
              updatedOrder = _orders[index].copyWith(paymentStatus: newStatus);
              break;
            default:
              updatedOrder = _orders[index];
          }
          _orders[index] = updatedOrder;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Estado actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error actualizando estado: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error actualizando estado'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOrderDetails(AppOrder.Order order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          constraints: BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalles de Orden',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            order.orderNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity( 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Información General', [
                        'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
                        'Total: \$${order.total.toStringAsFixed(2)}',
                        'Método de Pago: ${order.paymentMethod}',
                      ]),

                      SizedBox(height: 16),

                      _buildDetailSection('Dirección de Envío', [
                        order.shippingAddress.recipient,
                        order.shippingAddress.phone,
                        order.shippingAddress.fullAddress,
                      ]),

                      SizedBox(height: 16),

                      _buildDetailSection('Productos', 
                        order.items.map((item) => 
                          '• ${item.name} (x${item.quantity}) - \$${item.totalPrice.toStringAsFixed(2)}'
                        ).toList()
                      ),

                      SizedBox(height: 20),

                      // Controles de estado
                      _buildStatusControls(order),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text(
            item,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        )),
      ],
    );
  }

  Widget _buildStatusControls(AppOrder.Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Administrar Estados',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 12),

        // Estado de la orden
        Row(
          children: [
            Expanded(
              child: Text('Estado de Orden:'),
            ),
            Expanded(
              child: DropdownButton<String>(
                value: order.orderStatus,
                isExpanded: true,
                items: _orderStatuses.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                )).toList(),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    _updateOrderStatus(order.id, 'order_status', newStatus);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 8),

        // Estado de pago
        Row(
          children: [
            Expanded(
              child: Text('Estado de Pago:'),
            ),
            Expanded(
              child: DropdownButton<String>(
                value: order.paymentStatus,
                isExpanded: true,
                items: _paymentStatuses.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                )).toList(),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    _updateOrderStatus(order.id, 'payment_status', newStatus);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 8),

        // Estado de cancelación
        Row(
          children: [
            Expanded(
              child: Text('Cancelación:'),
            ),
            Expanded(
              child: DropdownButton<String>(
                value: order.metadata?['cancellation_status'] ?? 'Sin Solicitud',
                isExpanded: true,
                items: _cancellationStatuses.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status, style: TextStyle(fontSize: 12)),
                )).toList(),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    _updateCancellationStatus(order.id, newStatus);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _updateCancellationStatus(String orderId, String status) async {
    try {
      // Actualizar estado de cancelación real en Supabase
      await SupabaseService.instance.update('orders', orderId, {
        'cancellation_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Actualizar localmente
      setState(() {
        int index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          Map<String, dynamic> newMetadata = Map.from(_orders[index].metadata ?? {});
          newMetadata['cancellation_status'] = status;
          _orders[index] = _orders[index].copyWith(metadata: newMetadata);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Estado de cancelación actualizado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error actualizando cancelación: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmado':
        return Colors.blue;
      case 'enviado':
        return Colors.green;
      case 'entregado':
        return Colors.teal;
      case 'cancelado':
        return Colors.red;
      case 'pagado':
        return Colors.green;
      case 'fallido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          'Administración de Órdenes',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadOrders();
            },
            tooltip: 'Recargar órdenes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Estadísticas rápidas
          if (_orders.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatChip('Total', _orders.length, Colors.blue),
                  _buildStatChip('Pendientes', 
                    _orders.where((o) => o.orderStatus == 'Pendiente').length, 
                    Colors.orange),
                  _buildStatChip('Enviadas', 
                    _orders.where((o) => o.orderStatus == 'Enviado').length, 
                    Colors.green),
                  _buildStatChip('Pago Pendiente', 
                    _orders.where((o) => o.paymentStatus == 'Pendiente').length, 
                    Colors.red),
                ],
              ),
            ),

          // Barra de filtros y búsqueda
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Todos',
                      'Pendientes',
                      'Enviadas',
                      'Entregadas',
                      'Canceladas',
                      'Pago Pendiente',
                    ].map((filter) => Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = selected ? filter : 'Todos';
                          });
                        },
                      ),
                    )).toList(),
                  ),
                ),
                SizedBox(height: 12),
                // Búsqueda
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por número de orden o destinatario...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Lista de órdenes
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 24),
                            Text(
                              'No hay órdenes disponibles',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              _selectedFilter == 'Todos' 
                                ? 'Las órdenes de los usuarios aparecerán aquí automáticamente'
                                : 'No hay órdenes con el filtro "$_selectedFilter"',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () => _showOrderDetails(order),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                order.orderNumber,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                order.shippingAddress.recipient,
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
                                              '\$${order.total.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              DateFormat('dd/MM/yyyy').format(order.createdAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _buildStatusChip('Orden', order.orderStatus),
                                        SizedBox(width: 8),
                                        _buildStatusChip('Pago', order.paymentStatus),
                                        if (order.metadata?['cancellation_status'] != null &&
                                            order.metadata!['cancellation_status'] != 'Sin Solicitud') ...[
                                          SizedBox(width: 8),
                                          _buildStatusChip('Cancel', order.metadata!['cancellation_status']),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity( 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity( 0.3),
        ),
      ),
      child: Text(
        '$label: $status',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity( 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity( 0.3)),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}