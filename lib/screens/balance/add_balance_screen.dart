import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cubalink23/services/auth_guard_service.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key});

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> with WidgetsBindingObserver {
  double _currentBalance = 0.00;
  double? _selectedAmount;
  bool _isLoading = true;
  bool _isManualAmount = false;
  final TextEditingController _manualAmountController = TextEditingController();
  
  final List<double> _balanceOptions = [5.00, 10.00, 15.00, 20.00, 25.00, 50.00, 100.00];

  // Processing fees: 2.9% + $0.30 per transaction
  double _calculateProcessingFee(double amount) {
    return (amount * 0.029) + 0.30;
  }

  double get _processingFee => _selectedAmount != null ? _calculateProcessingFee(_selectedAmount!) : 0.0;
  double get _totalAmount => (_selectedAmount ?? 0) + _processingFee;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserBalance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _manualAmountController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // La app volvió a primer plano, refrescar saldo
      print('🔄 App resumed, refrescando saldo...');
      _loadUserBalance();
    }
  }

  Future<void> _loadUserBalance() async {
    try {
      // Cargar balance del usuario inmediatamente (sin verificar auth aquí para ser más rápido)
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser != null) {
        setState(() {
          _currentBalance = currentUser.balance;
          _isLoading = false;
        });
        print('✅ Balance cargado rápidamente: \$${_currentBalance.toStringAsFixed(2)}');
      } else {
        // Solo verificar autenticación si no hay usuario
        print('⚠️ No hay usuario, verificando autenticación...');
        final hasAuth = await AuthGuardService.instance.requireAuth(context, serviceName: 'Agregar Balance');
        if (!hasAuth) {
          Navigator.pop(context);
          return;
        }
        setState(() {
          _currentBalance = 0.00;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando balance: $e');
      setState(() {
        _currentBalance = 0.00;
        _isLoading = false;
      });
    }
  }

  void _selectAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _isManualAmount = false;
      _manualAmountController.clear();
    });
  }

  void _selectManualAmount() {
    setState(() {
      _isManualAmount = true;
      _selectedAmount = null;
      _manualAmountController.clear();
    });
  }

  void _validateManualAmount() {
    final text = _manualAmountController.text;
    if (text.isEmpty) return;
    
    final amount = double.tryParse(text);
    if (amount == null || amount < 5.00) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El monto mínimo es \$5.00'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _selectedAmount = amount;
    });
  }

  void _proceedToPayment() {
    if (_selectedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un monto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAmount! < 5.00) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El monto mínimo es \$5.00'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ir a la pantalla de método de pago existente
    Navigator.pushNamed(
      context, 
      '/payment_method',
      arguments: {
        'amount': _selectedAmount!,
        'fee': _processingFee,
        'total': _totalAmount,
        'isBalanceRecharge': true, // ✅ RECARGA: SÍ afectar saldo
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Fondo general Cubalink23
      appBar: AppBar(
        backgroundColor: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Texto blanco sobre header oscuro
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Agregar Saldo',
          style: TextStyle(
            color: Colors.white, // Texto blanco sobre header oscuro
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance actual
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Balance Actual',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${_currentBalance.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'USD',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Información del servicio
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF1976D2),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Información del Servicio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Agrega saldo a tu cuenta para usar en pagos y transferencias. Incluye comisión de procesamiento.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Selector de cantidad
                  const Text(
                    'Seleccionar Monto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Opciones predefinidas - BOTONES MÁS PEQUEÑOS
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 columnas en lugar de 2
                      childAspectRatio: 2.0, // Más compactos
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _balanceOptions.length,
                    itemBuilder: (context, index) {
                      final amount = _balanceOptions[index];
                      final isSelected = _selectedAmount == amount && !_isManualAmount;
                      
                      return GestureDetector(
                        onTap: () => _selectAmount(amount),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1976D2) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  color: isSelected ? Colors.white : const Color(0xFF1976D2),
                                  size: 16,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : const Color(0xFF2C2C2C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Opción de monto manual - MÁS COMPACTO
                  GestureDetector(
                    onTap: _selectManualAmount,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isManualAmount ? const Color(0xFF1976D2) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isManualAmount ? const Color(0xFF1976D2) : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: _isManualAmount ? Colors.white : const Color(0xFF1976D2),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Monto personalizado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isManualAmount ? Colors.white : const Color(0xFF2C2C2C),
                            ),
                          ),
                          const Spacer(),
                          if (_isManualAmount)
                            SizedBox(
                              width: 100,
                              height: 35,
                              child: TextField(
                                controller: _manualAmountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                onSubmitted: (_) => _validateManualAmount(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Min \$5',
                                  hintStyle: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.white70),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.white70),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Colors.white, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Resumen del pago
                  if (_selectedAmount != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
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
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildSummaryRow('Monto a agregar', '\$${_selectedAmount!.toStringAsFixed(2)}'),
                          _buildSummaryRow('Comisión de procesamiento', '\$${_processingFee.toStringAsFixed(2)}', isFee: true),
                          
                          const SizedBox(height: 12),
                          Container(
                            height: 1,
                            color: Colors.grey[200],
                          ),
                          const SizedBox(height: 12),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total a pagar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                              Text(
                                '\$${_totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: Colors.grey[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Pago procesado de forma segura',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Botón Siguiente - Posicionado más arriba
          if (_selectedAmount != null)
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12 + safeAreaBottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continuar al Pago',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isFee = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isFee ? Colors.grey[600] : const Color(0xFF2C2C2C),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isFee ? Colors.grey[600] : const Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }
}
