import 'package:flutter/material.dart';
import 'package:cubalink23/models/order.dart';
import 'package:cubalink23/services/firebase_repository.dart';
import 'package:cubalink23/services/supabase_service.dart';

class ZellePaymentDialog extends StatefulWidget {
  final double totalAmount;
  final Order order;
  final VoidCallback? onCancel;
  final Function(String orderId)? onOrderCreated;

  const ZellePaymentDialog({
    super.key,
    required this.totalAmount,
    required this.order,
    this.onCancel,
    this.onOrderCreated,
  });

  @override
  _ZellePaymentDialogState createState() => _ZellePaymentDialogState();
}

class _ZellePaymentDialogState extends State<ZellePaymentDialog> {
  bool _isCreatingOrder = false;
  final FirebaseRepository _repository = FirebaseRepository.instance;

  Future<void> _confirmOrder() async {
    setState(() => _isCreatingOrder = true);
    
    try {
      print('Creating Zelle order with pending payment status...');
      
      // Crear orden con datos completos y pago pendiente
      final orderWithZelle = widget.order.copyWith(
        paymentMethod: 'zelle',
        paymentStatus: 'pending_verification',
        orderStatus: 'payment_pending',
      );
      
      // Crear orden REAL en Supabase
      final orderData = orderWithZelle.toMap();
      final createdOrder = await SupabaseService.instance.createOrderRaw(orderData);
      
      if (createdOrder != null && createdOrder['id'] != null) {
        String orderId = createdOrder['id'];
        print('Zelle order created successfully in Supabase with ID: $orderId');
        
        // Llamar callback con el ID de la orden creada
        if (widget.onOrderCreated != null) {
          widget.onOrderCreated!(orderId);
        }
        
        if (mounted) {
          print('Closing dialog with success');
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('No se pudo crear la orden');
      }
    } catch (e) {
      print('Error creating order: $e');
      
      if (mounted) {
        _showErrorSnackBar('Error al crear la orden: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingOrder = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isCreatingOrder,
      child: Dialog(
        insetPadding: EdgeInsets.all(16),
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple[600],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: Colors.purple[600],
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pago con Zelle',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total: \$${widget.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isCreatingOrder)
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          if (widget.onCancel != null) widget.onCancel!();
                          Navigator.of(context).pop(false);
                        },
                      ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructions
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue[600], size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Instrucciones de Pago',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Para completar su pedido, envíe la cantidad exacta de:',
                              style: TextStyle(color: Colors.blue[700], fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '\$${widget.totalAmount.toStringAsFixed(2)} USD',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Zelle Details
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('📱 Número de Zelle:', '+1 561-480-5188'),
                            SizedBox(height: 12),
                            _buildInfoRow('🏢 Nombre de la empresa:', 'LAnd Installation Service LLC'),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Order Process Info
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.green[600], size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'PROCESO DE ORDEN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              '• Su orden será creada inmediatamente en estado pendiente de pago.\n\n• Será revisada rápidamente por nuestro equipo.\n\n• Si no recibimos el pago Zelle en 12-24h, se contactará al cliente.\n\n• Las órdenes sin pago confirmado por más de 24h serán eliminadas automáticamente.',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                      
                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isCreatingOrder ? null : _confirmOrder,
                          icon: _isCreatingOrder
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(Icons.add_shopping_cart, color: Colors.white),
                          label: Text(
                            _isCreatingOrder ? 'Creando Orden...' : 'Crear Orden',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 12),
                      
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isCreatingOrder ? null : () {
                            if (widget.onCancel != null) widget.onCancel!();
                            Navigator.of(context).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.red[400]!),
                            foregroundColor: Colors.red[600],
                          ),
                          child: Text('Cancelar'),
                        ),
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}