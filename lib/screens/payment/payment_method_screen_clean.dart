import 'package:flutter/material.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:cubalink23/services/square_payment_service.dart';
import 'package:cubalink23/screens/payment/payment_success_screen.dart';
import 'package:cubalink23/screens/payment/payment_error_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double amount;
  final double fee;
  final double total;
  final Map<String, dynamic>? metadata;

  const PaymentMethodScreen({
    super.key,
    required this.amount,
    required this.fee,
    required this.total,
    this.metadata,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  bool isLoading = true;
  bool isProcessingPayment = false;
  bool isSquareReady = false;

  @override
  void initState() {
    super.initState();
    _initializeSquare();
  }

  Future<void> _initializeSquare() async {
    try {
      // Inicializar Square In-App Payments SDK
      await InAppPayments.setSquareApplicationId('sandbox-sq0idb-IsIJtKqx2OHdVJjYmg6puA');
      
      // Verificar backend
      final health = await SquarePaymentService.checkHealth();
      
      setState(() {
        isSquareReady = health['square_ready'] == true;
        isLoading = false;
      });
      
      print('✅ Square SDK inicializado - Backend ready: $isSquareReady');
    } catch (e) {
      print('❌ Error inicializando Square: $e');
      setState(() {
        isSquareReady = false;
        isLoading = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (!isSquareReady) {
      _showError('Square no está disponible');
      return;
    }

    setState(() => isProcessingPayment = true);

    try {
      print('💳 Abriendo formulario nativo de Square...');
      print('💰 Monto: \$${widget.total.toStringAsFixed(2)}');

      // Abrir formulario nativo de Square para tokenizar tarjeta
      await CardEntry.collectCard(
        onCardNonceRequestSuccess: (CardDetails result) async {
          try {
            print('🎫 Nonce generado: ${result.nonce}');
            
            // Enviar nonce al backend
            final paymentResult = await SquarePaymentService.processPayment(
              nonce: result.nonce,
              amount: widget.total,
              note: 'Recarga de saldo Cubalink23',
            );

            // Verificar que el pago fue completado
            if (paymentResult['status'] == 'COMPLETED') {
              print('✅ Pago exitoso: ${paymentResult['id']}');
              
              // Cerrar formulario como éxito
              await InAppPayments.completeCardEntry(
                onCardEntryComplete: () {
                  _navigateToSuccess(paymentResult);
                },
              );
            } else {
              print('❌ Pago no completado: ${paymentResult['status']}');
              InAppPayments.showCardNonceProcessingError('Pago no completado.');
            }
            
          } catch (e) {
            print('💥 Error procesando pago: $e');
            if (e is SquarePaymentException) {
              InAppPayments.showCardNonceProcessingError(e.userFriendlyMessage);
            } else {
              InAppPayments.showCardNonceProcessingError('Error procesando el pago.');
            }
          }
        },
        onCardEntryCancel: () {
          print('❌ Usuario canceló el pago');
          setState(() {
            isProcessingPayment = false;
          });
        },
      );

    } catch (e) {
      print('💥 Error abriendo formulario Square: $e');
      _showError('Error abriendo formulario de pago: $e');
    } finally {
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  void _navigateToSuccess(Map<String, dynamic> result) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          amount: widget.amount,
          fee: widget.fee,
          total: widget.total,
          transactionId: result['id'],
          metadata: {
            'payment_method': 'Square',
            'status': result['status'],
            'receipt_url': result['receipt_url'],
          },
        ),
      ),
    );
  }

  void _showError(String message) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentErrorScreen(
          amount: widget.amount,
          fee: widget.fee,
          total: widget.total,
          errorMessage: message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C2C2C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Método de Pago',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Resumen del pago
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen del Pago',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Saldo a agregar:'),
                          Text('\$${widget.amount.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fee de procesamiento:'),
                          Text('\$${widget.fee.toStringAsFixed(2)}'),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total a cobrar:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '\$${widget.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Estado de Square
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSquareReady ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSquareReady ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSquareReady ? Icons.check_circle : Icons.error,
                        color: isSquareReady ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isSquareReady 
                              ? 'Square listo para procesar pagos'
                              : 'Square no disponible',
                          style: TextStyle(
                            color: isSquareReady ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Información sobre tarjetas de prueba
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💳 Tarjetas de Prueba Square:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('✅ 4111 1111 1111 1111 - Pago exitoso'),
                      Text('❌ 4000 0000 0000 0002 - Declinada'),
                      Text('💸 4000 0000 0000 0069 - Sin fondos'),
                      Text('🔒 4000 0000 0000 0127 - CVV incorrecto'),
                      SizedBox(height: 8),
                      Text(
                        'CVV: 123, Fecha: 12/25, Postal: 94103',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Botón de pago
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: (isProcessingPayment || !isSquareReady) ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isProcessingPayment
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Procesando...'),
                            ],
                          )
                        : Text(
                            'Pagar \$${widget.total.toStringAsFixed(2)} con Square',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
