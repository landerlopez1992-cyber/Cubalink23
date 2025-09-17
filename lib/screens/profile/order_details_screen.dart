import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cubalink23/models/order.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;
  
  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _planeAnimationController;
  late AnimationController _celebrationController;
  late Animation<double> _planeAnimation;
  late Animation<double> _celebrationAnimation;
  
  bool showCelebration = false;

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
    _setupAnimations();
  }

  void _setupAnimations() {
    _planeAnimationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _planeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _planeAnimationController,
      curve: Curves.easeInOut,
    ));

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    // Iniciar animación del avión
    _planeAnimationController.repeat();
    
    // Mostrar celebración si está entregado
    if (widget.order.orderStatus == 'delivered') {
      _showDeliveredCelebration();
    }
  }

  @override
  void dispose() {
    _planeAnimationController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  int _getCurrentStep() {
    switch (widget.order.orderStatus) {
      case 'created': return 1;
      case 'payment_pending': return 2;
      case 'payment_confirmed': return 3;
      case 'processing': return 4;
      case 'shipped': return 5;
      case 'out_for_delivery': return 6;
      case 'delivered': return 7;
      case 'cancelled': return 0;
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
      case 'cancelled': return 'Cancelado';
      default: return 'Desconocido';
    }
  }

  void _showDeliveredCelebration() {
    setState(() => showCelebration = true);
    _celebrationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _getCurrentStep();
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Orden #${widget.order.orderNumber}',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información básica
            _buildOrderHeader(),
            
            SizedBox(height: 24),
            
            // Progreso de la orden
            _buildOrderProgress(currentStep),
            
            SizedBox(height: 24),
            
            // Detalles de envío
            _buildShippingDetails(),
            
            SizedBox(height: 24),
            
            // Detalles de pago
            _buildPaymentDetails(),
            
            if (widget.order.orderStatus == 'delivered')
              SizedBox(height: 24),
            
            if (widget.order.orderStatus == 'delivered')
              _buildCelebrationWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                _getStatusTitle(widget.order.orderStatus),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '\$${widget.order.total.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Creada el ${_formatDate(widget.order.createdAt)}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProgress(int currentStep) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso de la Orden',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 20),
          
          // Progress steps
          Column(
            children: statusList.asMap().entries.map((entry) {
              final index = entry.key;
              final status = entry.value;
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep - 1;
              
              return _buildProgressStep(
                title: status['title']!,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLast: index == statusList.length - 1,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep({
    required String title,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    return Row(
      children: [
        // Step indicator
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted || isCurrent
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? Icon(Icons.check, color: Colors.white, size: 16)
              : isCurrent
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
        ),
        
        SizedBox(width: 16),
        
        // Step title
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCompleted || isCurrent
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
          ),
        ),
        
        // Connector line
        if (!isLast)
          Container(
            width: 2,
            height: 40,
            color: isCompleted
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            margin: EdgeInsets.only(left: 11, top: 8),
          ),
      ],
    );
  }

  Widget _buildShippingDetails() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles de Envío',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          
          _buildDetailRow(
            icon: Icons.person,
            label: 'Destinatario',
            value: widget.order.shippingAddress.recipient,
          ),
          
          _buildDetailRow(
            icon: Icons.phone,
            label: 'Teléfono',
            value: widget.order.shippingAddress.phone,
          ),
          
          _buildDetailRow(
            icon: Icons.location_on,
            label: 'Dirección',
            value: widget.order.shippingAddress.fullAddress,
          ),
          
          _buildDetailRow(
            icon: Icons.local_shipping,
            label: 'Método de Envío',
            value: _getShippingMethodText(widget.order.shippingMethod),
          ),
          
          if (widget.order.estimatedDelivery != null)
            _buildDetailRow(
              icon: Icons.schedule,
              label: 'Entrega Estimada',
              value: _formatDate(widget.order.estimatedDelivery!),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles de Pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          
          _buildDetailRow(
            icon: Icons.payment,
            label: 'Método de Pago',
            value: _getPaymentMethodText(widget.order.paymentMethod),
          ),
          
          _buildDetailRow(
            icon: Icons.monetization_on,
            label: 'Subtotal',
            value: '\$${widget.order.subtotal.toStringAsFixed(2)}',
          ),
          
          _buildDetailRow(
            icon: Icons.local_shipping,
            label: 'Costo de Envío',
            value: '\$${widget.order.shippingCost.toStringAsFixed(2)}',
          ),
          
          Divider(height: 24),
          
          _buildDetailRow(
            icon: Icons.receipt,
            label: 'Total',
            value: '\$${widget.order.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isTotal 
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[600],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationWidget() {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _celebrationAnimation.value,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Pedido Entregado!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tu pedido ha sido entregado exitosamente',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      case 'express': return 'Express (1-3 días)';
      case 'maritime': return 'Marítimo (21-35 días)';
      case 'pickup': return 'Recoger en tienda';
      default: return method;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
