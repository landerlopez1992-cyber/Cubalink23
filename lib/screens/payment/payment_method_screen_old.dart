import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/square_payment_service.dart';
import 'package:cubalink23/screens/payment/add_card_screen.dart';
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
      print('No current user found');
      setState(() => isLoading = false);
      return;
    }

    print('Loading payment cards for user: ${currentUser.id}');

    try {
      // Cargar tarjetas reales desde Supabase
      final cardsData = await SupabaseService.instance.getUserPaymentCards(currentUser.id);
      print('Loaded ${cardsData.length} payment cards from Supabase');

      // Convertir datos a modelos PaymentCard
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

        // Auto-seleccionar la tarjeta default si existe
        if (cardModels.isNotEmpty) {
          final defaultCard = cardModels.firstWhere(
            (card) => card.isDefault,
            orElse: () => cardModels.first,
          );
          selectedCardId = defaultCard.id;
          print('Selected default card: ${defaultCard.cardType} •••• ${defaultCard.last4}');
        }
      });
    } catch (e) {
      print('Error loading payment cards: $e');
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar tarjetas guardadas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

    setState(() {
      isProcessingPayment = true;
    });

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Procesando pago de \$${widget.total.toStringAsFixed(2)}...'),
          ],
        ),
      ),
    );

    try {
      // Obtener la tarjeta seleccionada
      final selectedCard = savedCards.firstWhere((card) => card.id == selectedCardId);

      print('💳 Procesando pago con Square...');
      print('💰 Monto: \$${widget.total.toStringAsFixed(2)}');
      print('💳 Tarjeta: ${selectedCard.cardType} •••• ${selectedCard.last4}');
      print('👤 Titular: ${selectedCard.holderName}');

      // Procesar pago con Square
      final paymentResult = await SquarePaymentService.processPayment(
        amount: widget.total,
        description: 'Recarga de saldo Cubalink23',
        cardLast4: selectedCard.last4,
        cardType: selectedCard.cardType,
        cardHolderName: selectedCard.holderName,
      );

      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();

      if (paymentResult.success) {
        print('✅ Pago exitoso con Square');
        print('🆔 Transaction ID: ${paymentResult.transactionId}');
        
        if (paymentResult.checkoutUrl != null && paymentResult.checkoutUrl!.isNotEmpty) {
          // Abrir URL de checkout de Square
          await _openCheckoutUrl(paymentResult.checkoutUrl!);
        } else {
          // Pago procesado directamente
          await _handleSuccessfulPayment(paymentResult);
        }
      } else {
        print('❌ Error en el pago: ${paymentResult.message}');
        _showPaymentError(paymentResult.message);
      }
    } catch (error) {
      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();
      
      print('❌ Error procesando pago: $error');
      _showPaymentError('Error de conexión: $error');
    } finally {
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  Future<void> _openCheckoutUrl(String checkoutUrl) async {
    try {
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        // Mostrar mensaje al usuario
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Abriendo página de pago de Square...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
        
        // Simular pago exitoso después de un tiempo (en producción esto vendría de un webhook)
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            _handleSuccessfulPayment(SquarePaymentResult(
              success: true,
              transactionId: 'square_${DateTime.now().millisecondsSinceEpoch}',
              message: 'Pago procesado exitosamente',
              amount: widget.total,
            ));
          }
        });
      } else {
        throw Exception('No se pudo abrir la URL de pago');
      }
    } catch (e) {
      print('Error opening checkout URL: $e');
      _showPaymentError('Error abriendo página de pago: $e');
    }
  }

  Future<void> _handleSuccessfulPayment(SquarePaymentResult result) async {
    try {
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Actualizar balance del usuario en Supabase
      final newBalance = (currentUser.balance ?? 0.0) + widget.amount;
      
      await SupabaseService.instance.update(
        'users',
        currentUser.id,
        {'balance': newBalance},
      );

      // Guardar historial de recarga
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

      // Mostrar éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Saldo agregado exitosamente: +\$${widget.amount.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Regresar a la pantalla anterior
        Navigator.pop(context, {'success': true, 'new_balance': newBalance});
      }
    } catch (e) {
      print('Error updating user balance: $e');
      _showPaymentError('Error actualizando saldo: $e');
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
      // Recargar tarjetas
      await _loadUserCards();
      
      // Auto-seleccionar la nueva tarjeta
      setState(() {
        selectedCardId = result.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Método de Pago',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Resumen del pago
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Resumen del Pago',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Monto a agregar:'),
                                  Text('\$${widget.amount.toStringAsFixed(2)}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Costo adicional:'),
                                  Text('\$${widget.fee.toStringAsFixed(2)}'),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '\$${widget.total.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Seleccionar tarjeta
                        Text(
                          'Seleccionar Tarjeta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (savedCards.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.credit_card_off,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No tienes tarjetas guardadas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Agrega una tarjeta para continuar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...savedCards.map((card) {
                            final isSelected = selectedCardId == card.id;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).dividerColor,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                    : null,
                              ),
                              child: RadioListTile<String>(
                                value: card.id,
                                groupValue: selectedCardId,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCardId = value;
                                  });
                                },
                                title: Text('${card.cardType} •••• ${card.last4}'),
                                subtitle: Text(card.holderName),
                                secondary: Icon(
                                  _getCardIcon(card.cardType),
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),

                        const SizedBox(height: 16),

                        // Botón agregar tarjeta
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _addNewCard,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Nueva Tarjeta'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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

                // Botón procesar pago
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
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
                          : Text(
                              'Procesar Pago - \$${widget.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'american express':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}
