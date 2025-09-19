import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/database_service.dart';
import 'package:cubalink23/services/supabase_database_service.dart';
import 'package:cubalink23/models/recharge_history.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final double amount;
  final double fee;
  final double total;
  final String transactionId;
  final bool isBalanceRecharge; // ✅ NUEVO: Identificar si es recarga de saldo

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.fee,
    required this.total,
    required this.transactionId,
    this.isBalanceRecharge = false, // ✅ DEFAULT: NO es recarga
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<RechargeHistory> recentHistory = [];
  bool isLoadingHistory = true;

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
    // ✅ ACTUALIZAR SALDO SOLO SI ES RECARGA
    if (widget.isBalanceRecharge) {
      _updateUserBalance();
      print('💰 Recarga de saldo - actualizando billetera');
    } else {
      print('💳 Pago de compra exitoso - NO se actualiza saldo de billetera');
    }
    _loadRecentHistory();
  }

  Future<void> _updateUserBalance() async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser != null) {
        print('💰 Actualizando saldo del usuario...');
        print('💰 Usuario: ${currentUser.id}');
        print('💰 Agregando: \$${widget.amount.toStringAsFixed(2)}');
        
        // Actualizar saldo en Supabase
        await SupabaseDatabaseService.instance.addUserBalance(currentUser.id, widget.amount);
        
        // Refrescar datos del usuario en memoria
        await SupabaseAuthService.instance.loadCurrentUserData();
        
        // TODO: Crear registro en historial de recargas cuando esté disponible el método
        
        print('✅ Saldo actualizado exitosamente');
      }
    } catch (e) {
      print('❌ Error actualizando saldo: $e');
    }
  }

  Future<void> _loadRecentHistory() async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser != null) {
        final history = await DatabaseService.instance.getRechargeHistory(currentUser.id);
        setState(() {
          recentHistory = history.take(5).toList(); // Últimas 5 transacciones
          isLoadingHistory = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando historial: $e');
      setState(() => isLoadingHistory = false);
    }
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
                          _buildTransactionIdRow('ID de Transacción:', widget.transactionId),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Historial reciente
                if (!isLoadingHistory && recentHistory.isNotEmpty) ...[
                  SlideTransition(
                    position: _slideAnimation,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📊 Historial Reciente',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ...recentHistory.map((transaction) => _buildHistoryItem(transaction)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 20),
                // Continue Button - Fixed size
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      // ✅ MOSTRAR LOADING MIENTRAS SE PROCESA
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Procesando orden...'),
                            ],
                          ),
                        ),
                      );
                      
                      // Refrescar datos del usuario
                      try {
                        await SupabaseAuthService.instance.loadCurrentUserData();
                        print('✅ Datos del usuario refrescados desde pantalla de éxito');
                      } catch (e) {
                        print('❌ Error refrescando datos: $e');
                      }
                      
                      // ✅ SIMULAR PROCESAMIENTO (2-3 segundos)
                      await Future.delayed(Duration(seconds: 2));
                      
                      // Cerrar loading
                      Navigator.pop(context);
                      
                      // ✅ MOSTRAR MODAL DE ORDEN CREADA
                      await _showOrderCreatedModal();
                      
                      // Regresar resultado exitoso y luego ir al inicio
                      Navigator.pop(context, true); // ✅ REGRESAR TRUE = ORDEN DEBE CREARSE
                      Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the first screen (Welcome)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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

  Widget _buildTransactionIdRow(String label, String transactionId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SelectableText(
              transactionId,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(RechargeHistory transaction) {
    final isCurrentTransaction = transaction.transactionId == widget.transactionId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentTransaction ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: isCurrentTransaction ? Border.all(color: const Color(0xFF4CAF50), width: 2) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrentTransaction ? const Color(0xFF4CAF50) : Colors.grey[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isCurrentTransaction ? Icons.check_circle : Icons.history,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentTransaction ? 'Transacción Actual' : 'Recarga de Saldo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCurrentTransaction ? const Color(0xFF4CAF50) : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                Text(
                  'ID: ${transaction.transactionId.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 12,
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
                _formatDate(transaction.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: transaction.status == 'completed' ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.status == 'completed' ? 'Completado' : 'Pendiente',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  // ✅ MODAL DE ORDEN CREADA EXITOSAMENTE
  Future<void> _showOrderCreatedModal() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de éxito
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),
              
              // Título
              Text(
                '¡Orden Creada\nExitosamente!', // ✅ DIVIDIR EN 2 LÍNEAS
                style: TextStyle(
                  fontSize: 18, // ✅ REDUCIR TAMAÑO
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              
              // Descripción
              Text(
                'Tu pedido ha sido procesado correctamente. Puedes seguir el progreso en "Rastreo de órdenes".', // ✅ TEXTO MÁS CORTO
                style: TextStyle(
                  fontSize: 13, // ✅ REDUCIR TAMAÑO
                  color: Colors.grey[600],
                  height: 1.3, // ✅ REDUCIR ALTURA LÍNEA
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              
              // Información del pago
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Monto Pagado:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('\$${widget.total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ID:', style: TextStyle(fontSize: 12, color: Colors.grey[600])), // ✅ TEXTO MÁS CORTO
                        Expanded(
                          child: Text(
                            widget.transactionId.length > 15 
                                ? '${widget.transactionId.substring(0, 15)}...' // ✅ TRUNCAR SI ES MUY LARGO
                                : widget.transactionId,
                            style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey[600]), // ✅ TEXTO MÁS PEQUEÑO
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Botón continuar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar modal
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


