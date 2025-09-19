import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/square_webview_service.dart';
import 'package:cubalink23/screens/payment/payment_success_screen.dart';
import 'package:cubalink23/screens/payment/payment_error_screen.dart';

/// ====================== PANTALLA PAGO SIMPLE ======================
/// 
/// Sin tarjetas guardadas, sin complicaciones
/// Solo: Monto → Pagar con Square → Payment Link
class PaymentSimpleScreen extends StatefulWidget {
  final double amount;
  final double fee;
  final double total;

  const PaymentSimpleScreen({
    super.key,
    required this.amount,
    required this.fee,
    required this.total,
  });

  @override
  State<PaymentSimpleScreen> createState() => _PaymentSimpleScreenState();
}

class _PaymentSimpleScreenState extends State<PaymentSimpleScreen> {
  bool isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => isProcessing = true);

    try {
      print('🔗 Creando Payment Link directo...');
      print('💰 Monto: \$${widget.total.toStringAsFixed(2)}');

      // 🌐 WEBVIEW MANUAL - COMO FUNCIONABA BIEN
      final result = await SquareWebViewService.openTokenizeSheet(
        context: context,
        amountCents: (widget.total * 100).round(),
        customerId: 'user-${DateTime.now().millisecondsSinceEpoch}',
        currency: 'USD',
        note: 'Recarga Cubalink23',
      );
      
      if (result != null && result['success'] == true) {
        print('✅ Pago procesado: ${result['payment_id']}');
        
        // Navegar a pantalla de éxito
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              amount: widget.amount,
              fee: widget.fee,
              total: widget.total,
              transactionId: result['payment_id'] ?? 'N/A',
            ),
          ),
        );
      } else if (result != null && result['success'] == false) {
        print('❌ Pago falló: ${result['error']}');
        
        // Navegar a pantalla de error
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentErrorScreen(
              errorMessage: result['error'] ?? 'Pago fallido',
              amount: widget.amount,
              fee: widget.fee,
              total: widget.total,
            ),
          ),
        );
      } else {
        print('⚠️ Pago cancelado por usuario');
      }
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error procesando pago: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('💳 Pagar con Square'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con resumen del pago
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Resumen del Pago',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monto:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '\$${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Comisión:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '\$${widget.fee.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${widget.total.toStringAsFixed(2)} USD',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Información de Square
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.security,
                        size: 48,
                        color: Colors.green[600],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pago Seguro con Square',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Square procesará tu pago de forma segura y guardará tu tarjeta para futuros pagos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.lock, color: Colors.green),
                              Text('Seguro', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.speed, color: Colors.blue),
                              Text('Rápido', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.save, color: Colors.orange),
                              Text('Guarda tarjeta', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botón de pagar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Creando pago...'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payment, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'PAGAR \$${widget.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Información adicional
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Al continuar, serás redirigido a Square para completar el pago de forma segura.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
