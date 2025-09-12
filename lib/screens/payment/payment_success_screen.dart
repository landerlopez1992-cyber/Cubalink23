import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final double amount;
  final double fee;
  final double total;
  final String transactionId;

  const PaymentSuccessScreen({
    Key? key,
    required this.amount,
    required this.fee,
    required this.total,
    required this.transactionId,
  }) : super(key: key);

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)], // Green gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Success Icon with animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 120,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    '¡Pago Procesado Exitosamente!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Payment Details
                SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildDetailRow('Monto Agregado:', '\$${widget.amount.toStringAsFixed(2)}', Colors.green),
                          _buildDetailRow('Comisión de Procesamiento:', '\$${widget.fee.toStringAsFixed(2)}', Colors.orange),
                          const Divider(),
                          _buildDetailRow('Total Cobrado:', '\$${widget.total.toStringAsFixed(2)}', Colors.black, isBold: true),
                          const SizedBox(height: 10),
                          _buildDetailRow('ID de Transacción:', widget.transactionId, Colors.grey[700]!),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Continue Button
                ElevatedButton(
                  onPressed: () async {
                    // Refrescar datos del usuario antes de regresar
                    try {
                      await SupabaseAuthService.instance.loadCurrentUserData();
                      print('✅ Datos del usuario refrescados desde pantalla de éxito');
                    } catch (e) {
                      print('❌ Error refrescando datos: $e');
                    }
                    
                    Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the first screen (Welcome)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}


