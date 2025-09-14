import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cubalink23/services/ding_connect_service.dart';

/// Widget para procesar órdenes de DingConnect siguiendo la documentación oficial
/// Implementa polling de estado cada 5-10 segundos según especificaciones
class OrderProcessingWidget extends StatefulWidget {
  final String phoneNumber;
  final Map<String, dynamic> selectedProduct;
  final Function(Map<String, dynamic>) onOrderComplete;
  final Function(String) onOrderError;

  const OrderProcessingWidget({
    super.key,
    required this.phoneNumber,
    required this.selectedProduct,
    required this.onOrderComplete,
    required this.onOrderError,
  });

  @override
  State<OrderProcessingWidget> createState() => _OrderProcessingWidgetState();
}

class _OrderProcessingWidgetState extends State<OrderProcessingWidget> {
  String _orderStatus = 'idle'; // idle, processing, created, polling, success, failed
  String _orderId = '';
  String _statusMessage = '';
  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  static const int _maxPollingAttempts = 60; // 5 minutos máximo (60 * 5s)

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity( 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity( 0.3)),
      ),
      child: Column(
        children: [
          // Botón principal
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _orderStatus == 'idle' || _orderStatus == 'failed' 
                  ? _processOrder 
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusColor(),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_orderStatus == 'processing' || _orderStatus == 'polling')
                    Container(
                      width: 20,
                      height: 20,
                      margin: EdgeInsets.only(right: 10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  Text(
                    _getButtonText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mensaje de estado
          if (_statusMessage.isNotEmpty) ...[
            SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity( 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor().withOpacity( 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_orderId.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            'Order ID: $_orderId',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'Courier',
                            ),
                          ),
                        ],
                        if (_orderStatus == 'polling') ...[
                          SizedBox(height: 4),
                          Text(
                            'Verificando estado... ($_pollingAttempts/$_maxPollingAttempts)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Detalles del producto
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalles de la recarga:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      widget.phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.card_giftcard, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.selectedProduct['title'] ?? 'Producto',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      '\$${widget.selectedProduct['price']?.toStringAsFixed(2) ?? '0.00'} ${widget.selectedProduct['currency'] ?? 'USD'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Procesar orden siguiendo el flujo de la documentación
  Future<void> _processOrder() async {
    setState(() {
      _orderStatus = 'processing';
      _statusMessage = 'Creando orden de recarga...';
      _orderId = '';
      _pollingAttempts = 0;
    });

    try {
      // Paso 1: Crear orden usando POST /orders
      final orderResult = await DingConnectService.instance.createOrder(
        phoneNumber: widget.phoneNumber,
        productId: widget.selectedProduct['productId'] ?? widget.selectedProduct['id'] ?? '',
        value: (widget.selectedProduct['price'] ?? 0.0).toDouble(),
      );

      if (orderResult != null && orderResult['success'] == true) {
        setState(() {
          _orderStatus = 'created';
          _orderId = orderResult['orderId'] ?? '';
          _statusMessage = 'Orden creada exitosamente. Verificando estado...';
        });

        // Paso 2: Iniciar polling de estado cada 5 segundos
        _startOrderPolling(_orderId);

      } else {
        setState(() {
          _orderStatus = 'failed';
          _statusMessage = 'Error al crear orden: ${orderResult?['error'] ?? 'Error desconocido'}';
        });
        widget.onOrderError(_statusMessage);
      }

    } catch (e) {
      setState(() {
        _orderStatus = 'failed';
        _statusMessage = 'Error interno: $e';
      });
      widget.onOrderError(_statusMessage);
    }
  }

  /// Iniciar polling de estado según documentación (cada 5-10 segundos)
  void _startOrderPolling(String orderId) {
    setState(() {
      _orderStatus = 'polling';
    });

    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      _pollingAttempts++;
      
      // Límite de intentos para evitar polling infinito
      if (_pollingAttempts >= _maxPollingAttempts) {
        timer.cancel();
        setState(() {
          _orderStatus = 'failed';
          _statusMessage = 'Timeout: La orden tardó demasiado en procesarse';
        });
        widget.onOrderError(_statusMessage);
        return;
      }

      try {
        final statusResult = await DingConnectService.instance.getOrderStatus(orderId);
        
        if (statusResult != null && statusResult['success'] == true) {
          final status = statusResult['status'] ?? 'UNKNOWN';
          
          print('📊 Polling Order Status: $status (Intento $_pollingAttempts)');
          
          switch (status.toUpperCase()) {
            case 'SUCCESS':
              timer.cancel();
              setState(() {
                _orderStatus = 'success';
                _statusMessage = '¡Recarga completada exitosamente!';
              });
              widget.onOrderComplete(statusResult);
              break;
              
            case 'FAILED':
              timer.cancel();
              setState(() {
                _orderStatus = 'failed';
                _statusMessage = 'La recarga falló. ${statusResult['errorMessage'] ?? ''}';
              });
              widget.onOrderError(_statusMessage);
              break;
              
            case 'PROCESSING':
            default:
              setState(() {
                _statusMessage = 'Procesando recarga... Por favor espere';
              });
              break;
          }
        } else {
          print('❌ Error polling order status');
          // Continuar polling en caso de error de red temporal
        }
      } catch (e) {
        print('❌ Error en polling: $e');
        // Continuar polling en caso de error temporal
      }
    });
  }

  /// Obtener color según estado actual
  Color _getStatusColor() {
    switch (_orderStatus) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'processing':
      case 'polling':
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  /// Obtener icono según estado actual
  IconData _getStatusIcon() {
    switch (_orderStatus) {
      case 'success':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'processing':
      case 'polling':
        return Icons.hourglass_empty;
      default:
        return Icons.info;
    }
  }

  /// Obtener texto del botón según estado
  String _getButtonText() {
    switch (_orderStatus) {
      case 'processing':
        return 'Creando Orden...';
      case 'polling':
        return 'Verificando Estado...';
      case 'success':
        return '✅ Recarga Completada';
      case 'failed':
        return 'Reintentar Recarga';
      default:
        return 'Confirmar Recarga';
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}