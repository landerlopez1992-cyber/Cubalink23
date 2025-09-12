import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/square_payment_service.dart';
import 'package:cubalink23/screens/payment/add_card_screen.dart';
import 'package:cubalink23/screens/payment/payment_success_screen.dart';
import 'package:cubalink23/screens/payment/payment_error_screen.dart';
import 'package:cubalink23/models/payment_card.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? selectedCardId;
  List<PaymentCard> savedCards = [];
  bool isLoading = true;
  bool isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadUserCards();
  }

  Future<void> _loadUserCards() async {
    final currentUser = SupabaseAuthService.instance.currentUser;
    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final cardsData = await SupabaseService.instance.getUserPaymentCards(currentUser.id);
      final cardModels = cardsData.map((cardData) {
        return PaymentCard(
          id: cardData['id'],
          last4: cardData['last_4'] ?? '',
          cardType: cardData['card_type'] ?? 'Tarjeta',
          expiryMonth: cardData['expiry_month'] ?? '',
          expiryYear: cardData['expiry_year'] ?? '',
          holderName: cardData['holder_name'] ?? '',
          isDefault: cardData['is_default'] ?? false,
          squareCardId: cardData['square_card_id'],
          createdAt: DateTime.parse(cardData['created_at'] ?? DateTime.now().toIso8601String()),
        );
      }).toList();

      setState(() {
        savedCards = cardModels;
        isLoading = false;

        if (cardModels.isNotEmpty) {
          final defaultCard = cardModels.firstWhere(
            (card) => card.isDefault,
            orElse: () => cardModels.first,
          );
          selectedCardId = defaultCard.id;
        }
      });
    } catch (e) {
      print('Error loading payment cards: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _processPayment() async {
    if (selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una tarjeta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isProcessingPayment = true);

    try {
      final selectedCard = savedCards.firstWhere((card) => card.id == selectedCardId);
      
      print('💳 Procesando pago con Square...');
      print('💰 Monto: \$${widget.total.toStringAsFixed(2)}');
      
      final paymentResult = await SquarePaymentService.processPayment(
        amount: widget.total,
        description: 'Recarga de saldo Cubalink23',
        cardLast4: selectedCard.last4,
        cardType: selectedCard.cardType,
        cardHolderName: selectedCard.holderName,
      );

      if (paymentResult.success) {
        print('✅ Payment Link creado exitosamente');
        
        // Si hay checkoutUrl, abrir el Payment Link
        if (paymentResult.checkoutUrl != null) {
          print('🔗 Abriendo Payment Link: ${paymentResult.checkoutUrl}');
          await _openCheckoutUrl(paymentResult.checkoutUrl!);
        } else {
          // Si no hay URL, mostrar pantalla de éxito (fallback)
          await _showPaymentSuccessScreen(paymentResult);
        }
      } else {
        await _showPaymentErrorScreen(paymentResult.message);
      }
    } catch (error) {
      print('❌ Error procesando pago: $error');
      await _showPaymentErrorScreen('Error de conexión: $error');
    } finally {
      if (mounted) {
        setState(() => isProcessingPayment = false);
      }
    }
  }

  Future<bool> _openCheckoutUrl(String checkoutUrl) async {
    try {
      print('🔗 === DEBUGGING CHECKOUT URL ===');
      print('🔗 URL recibida: $checkoutUrl');
      print('🔗 URL válida: ${Uri.tryParse(checkoutUrl) != null}');
      
      if (checkoutUrl.isEmpty || checkoutUrl == 'URL no disponible') {
        throw Exception('URL de pago no disponible');
      }
      
      final uri = Uri.parse(checkoutUrl);
      print('🔗 URI parseado: $uri');
      
      // Intentar múltiples métodos para abrir la URL
      bool urlOpened = false;
      
      // Método 1: Intentar con LaunchMode.externalApplication
      try {
        if (await canLaunchUrl(uri)) {
          print('🔗 Método 1: Abriendo URL externa...');
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          urlOpened = true;
        }
      } catch (e) {
        print('❌ Método 1 falló: $e');
      }
      
      // Método 2: Intentar con LaunchMode.platformDefault
      if (!urlOpened) {
        try {
          print('🔗 Método 2: Intentando con platformDefault...');
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          urlOpened = true;
        } catch (e) {
          print('❌ Método 2 falló: $e');
        }
      }
      
      // Método 3: Intentar con LaunchMode.inAppWebView
      if (!urlOpened) {
        try {
          print('🔗 Método 3: Intentando con inAppWebView...');
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
          urlOpened = true;
        } catch (e) {
          print('❌ Método 3 falló: $e');
        }
      }
      
      if (urlOpened) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Abriendo página de pago de Square...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return true; // Pago iniciado exitosamente
      } else {
        // Si todos los métodos fallan, mostrar la URL al usuario
        _showUrlToUser(checkoutUrl);
        return true; // Consideramos que el pago se inició
      }
    } catch (e) {
      print('❌ Error abriendo URL: $e');
      _showPaymentError('Error abriendo página de pago: $e');
      return false; // Error al abrir URL
    }
  }
  
  void _showUrlToUser(String url) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('🔗 Abrir Página de Pago'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No se pudo abrir automáticamente la página de pago.'),
                const SizedBox(height: 16),
                const Text('Por favor, copia y pega esta URL en tu navegador:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    url,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  /// Refrescar datos del usuario en todas las pantallas
  Future<void> _refreshUserDataInAllScreens() async {
    try {
      print('🔄 Refrescando datos del usuario en todas las pantallas...');
      
      // Forzar recarga del usuario en el servicio de autenticación
      await SupabaseAuthService.instance.loadCurrentUserData();
      
      // Notificar a todas las pantallas que el saldo ha cambiado
      // Esto se puede hacer con un stream o notifier
      print('✅ Datos del usuario refrescados en todas las pantallas');
    } catch (e) {
      print('❌ Error refrescando datos del usuario: $e');
    }
  }

  Future<void> _showPaymentSuccessScreen(SquarePaymentResult result) async {
    try {
      print('💰 === DEBUGGING PAYMENT SUCCESS ===');
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) throw Exception('Usuario no autenticado');

      print('💰 Usuario actual: ${currentUser.name} (${currentUser.email})');
      print('💰 Saldo actual: \$${currentUser.balance}');
      print('💰 Monto a agregar: \$${widget.amount}');
      
      final newBalance = (currentUser.balance) + widget.amount;
      print('💰 Nuevo saldo calculado: \$${newBalance}');
      
      print('💰 Actualizando saldo en Supabase...');
      final updateResult = await SupabaseService.instance.update(
        'users',
        currentUser.id,
        {'balance': newBalance},
      );
      print('💰 Resultado de actualización: $updateResult');
      
      // Actualizar saldo en el servicio de autenticación
      await SupabaseAuthService.instance.updateUserBalance(newBalance);
      print('💰 ✅ Saldo actualizado en SupabaseAuthService: \$${newBalance}');
      
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
        'transaction_id': result.transactionId,
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
              transactionId: result.transactionId ?? 'N/A',
            ),
          ),
        );
        
        // Forzar recarga del usuario en todas las pantallas
        await _refreshUserDataInAllScreens();
      }
    } catch (e) {
      _showPaymentError('Error procesando pago exitoso: $e');
    }
  }

  Future<void> _showPaymentErrorScreen(String errorMessage) async {
    try {
      print('❌ === DEBUGGING PAYMENT ERROR ===');
      print('❌ Error: $errorMessage');
      print('❌ Monto: \$${widget.amount}');
      print('❌ Comisión: \$${widget.fee}');
      print('❌ Total: \$${widget.total}');

      // Mostrar pantalla de error
      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentErrorScreen(
              errorMessage: errorMessage,
              amount: widget.amount,
              fee: widget.fee,
              total: widget.total,
            ),
          ),
        );
      }
    } catch (e) {
      // Si hay error mostrando la pantalla de error, usar SnackBar como fallback
      _showPaymentError('Error mostrando pantalla de error: $e');
    }
  }

  void _showPaymentError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $message'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _addNewCard() async {
    final result = await Navigator.push<PaymentCard>(
      context,
      MaterialPageRoute(builder: (context) => const AddCardScreen()),
    );

    if (result != null) {
      await _loadUserCards();
      setState(() => selectedCardId = result.id);
    }
  }

  Widget _buildCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1434CB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'VISA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'mastercard':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEB001B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'MC',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'american express':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF006FCF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'AMEX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.credit_card,
            color: Colors.white,
            size: 16,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
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
                        // Resumen del pago
                        Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resumen del Pago',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSummaryRow('Monto a agregar', '\$${widget.amount.toStringAsFixed(2)}'),
                              _buildSummaryRow('Comisión de procesamiento', '\$${widget.fee.toStringAsFixed(2)}'),
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total a pagar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${widget.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Seleccionar tarjeta
                        const Text(
                          'Seleccionar Tarjeta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (savedCards.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
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
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Icon(
                                    Icons.credit_card_off,
                                    size: 30,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No tienes tarjetas guardadas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C2C2C),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Agrega una tarjeta para continuar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ...savedCards.map((card) {
                            final isSelected = selectedCardId == card.id;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: RadioListTile<String>(
                                value: card.id,
                                groupValue: selectedCardId,
                                onChanged: (value) {
                                  setState(() => selectedCardId = value);
                                },
                                activeColor: const Color(0xFF1976D2),
                                title: Text(
                                  '${card.cardType} •••• ${card.last4}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C2C2C),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card.holderName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (card.isDefault)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1976D2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'DEFAULT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                secondary: _buildCardIcon(card.cardType),
                              ),
                            );
                          }).toList(),

                        const SizedBox(height: 16),

                        // Botón agregar tarjeta
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _addNewCard,
                            icon: const Icon(Icons.add, color: Color(0xFF1976D2)),
                            label: const Text(
                              'Agregar Nueva Tarjeta',
                              style: TextStyle(
                                color: Color(0xFF1976D2),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF1976D2), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botón procesar pago - Posicionado más arriba
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
                      onPressed: (selectedCardId != null && !isProcessingPayment)
                          ? _processPayment
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isProcessingPayment
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Procesar Pago',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${widget.total.toStringAsFixed(2)}',
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
              ],
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
