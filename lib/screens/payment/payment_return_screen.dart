import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/services/square_payment_service.dart';
import 'package:cubalink23/screens/payment/payment_success_screen.dart';
import 'package:cubalink23/screens/payment/payment_error_screen.dart';

class PaymentReturnScreen extends StatefulWidget {
  final String paymentLinkId;
  final double amount;
  final double fee;
  final double total;

  const PaymentReturnScreen({
    super.key,
    required this.paymentLinkId,
    required this.amount,
    required this.fee,
    required this.total,
  });

  @override
  State<PaymentReturnScreen> createState() => _PaymentReturnScreenState();
}

class _PaymentReturnScreenState extends State<PaymentReturnScreen> {
  bool isLoading = true;
  String status = 'Verificando pago...';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _verifyPaymentStatus();
  }

  Future<void> _verifyPaymentStatus() async {
    try {
      print('🔍 Verificando estado del pago: ${widget.paymentLinkId}');
      setState(() {
        status = 'Verificando estado del pago...';
      });

      // Verificar el estado del pago con Square
      final paymentStatus = await SquarePaymentService.verifyPaymentCompletion(
        widget.paymentLinkId,
        maxAttempts: 5,
        delay: const Duration(seconds: 3),
      );

      if (paymentStatus['success']) {
        final status = paymentStatus['status'];
        print('📊 Estado del pago: $status');

        if (status == 'COMPLETED') {
          await _processSuccessfulPayment();
        } else if (status == 'FAILED') {
          await _processFailedPayment('El pago fue rechazado por Square');
        } else if (status == 'CANCELED') {
          await _processFailedPayment('El pago fue cancelado');
        } else {
          await _processFailedPayment('Estado de pago desconocido: $status');
        }
      } else {
        await _processFailedPayment('No se pudo verificar el estado del pago');
      }
    } catch (e) {
      print('❌ Error verificando pago: $e');
      await _processFailedPayment('Error verificando pago: $e');
    }
  }

  Future<void> _processSuccessfulPayment() async {
    try {
      print('✅ Procesando pago exitoso...');
      setState(() {
        status = 'Procesando pago exitoso...';
      });

      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      print('💰 Usuario actual: ${currentUser.name} (${currentUser.email})');
      print('💰 Saldo actual: \$${currentUser.balance}');
      print('💰 Monto a agregar: \$${widget.amount}');
      
      final newBalance = (currentUser.balance) + widget.amount;
      print('💰 Nuevo saldo calculado: \$$newBalance');
      
      print('💰 Actualizando saldo en Supabase...');
      final updateResult = await SupabaseService.instance.update(
        'users',
        currentUser.id,
        {'balance': newBalance},
      );
      print('💰 Resultado de actualización: $updateResult');
      
      // Actualizar saldo en el servicio de autenticación
      await SupabaseAuthService.instance.updateUserBalance(newBalance);
      print('💰 ✅ Saldo actualizado en SupabaseAuthService: \$$newBalance');
      
      // Forzar recarga del usuario para sincronizar datos
      await SupabaseAuthService.instance.loadCurrentUserData();
      print('💰 ✅ Usuario recargado con nuevo saldo');

      // Insertar en historial de recargas
      await SupabaseService.instance.insert('recharge_history', {
        'user_id': currentUser.id,
        'amount': widget.amount,
        'fee': widget.fee,
        'total': widget.total,
        'payment_method': 'square',
        'transaction_id': widget.paymentLinkId,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Mostrar pantalla de éxito
      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              amount: widget.amount,
              fee: widget.fee,
              total: widget.total,
              transactionId: widget.paymentLinkId,
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error procesando pago exitoso: $e');
      await _processFailedPayment('Error procesando pago exitoso: $e');
    }
  }

  Future<void> _processFailedPayment(String error) async {
    print('❌ Procesando pago fallido: $error');
    
    if (mounted) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentErrorScreen(
            errorMessage: error,
            amount: widget.amount,
            fee: widget.fee,
            total: widget.total,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Procesando Pago',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de carga
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.payment,
                size: 40,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Indicador de carga
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
            ),
            const SizedBox(height: 24),
            
            // Estado actual
            Text(
              status,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Información adicional
            Text(
              'Por favor espera mientras verificamos tu pago...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Información del pago
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Detalles del Pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentDetailRow('Monto', '\$${widget.amount.toStringAsFixed(2)}'),
                  _buildPaymentDetailRow('Comisión', '\$${widget.fee.toStringAsFixed(2)}'),
                  _buildPaymentDetailRow('Total', '\$${widget.total.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentDetailRow('ID de Transacción', widget.paymentLinkId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }
}


