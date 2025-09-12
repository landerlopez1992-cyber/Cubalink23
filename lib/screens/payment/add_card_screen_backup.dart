import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/models/payment_card.dart';
import 'package:cubalink23/services/supabase_service.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  
  bool _isLoading = false;
  String? _cardType;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  String _getCardType(String cardNumber) {
    cardNumber = cardNumber.replaceAll(' ', '');
    if (cardNumber.startsWith('4')) {
      return 'Visa';
    } else if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) {
      return 'Mastercard';
    } else if (cardNumber.startsWith('3')) {
      return 'American Express';
    }
    return 'Tarjeta';
  }

  Widget _getCardIcon(String cardType) {
    switch (cardType) {
      case 'Visa':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        );
      case 'Mastercard':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('MC', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        );
      case 'American Express':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('AMEX', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        );
      default:
        return const Icon(Icons.credit_card, color: Colors.grey);
    }
  }

  void _onCardNumberChanged(String value) {
    setState(() {
      _cardType = _getCardType(value);
    });
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar que el usuario esté autenticado
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debe iniciar sesión para agregar una tarjeta'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Preparar datos de la tarjeta
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final last4 = cardNumber.length >= 4 ? cardNumber.substring(cardNumber.length - 4) : cardNumber;
      final expiryParts = _expiryController.text.split('/');
      
      if (expiryParts.length != 2) {
        throw Exception('Formato de fecha de expiración inválido');
      }

      final expiryMonth = expiryParts[0].padLeft(2, '0');
      final expiryYear = '20${expiryParts[1]}'; // Asumir años 2000+

      // Crear modelo de tarjeta
      final paymentCard = PaymentCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        last4: last4,
        cardType: _cardType ?? 'Tarjeta',
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        holderName: _cardHolderController.text.trim(),
        isDefault: false, // No será default por defecto
        createdAt: DateTime.now(),
      );

      // Guardar en Supabase
      final cardData = {
        'user_id': currentUser.id,
        'last_4': paymentCard.last4,
        'card_type': paymentCard.cardType,
        'expiry_month': paymentCard.expiryMonth,
        'expiry_year': paymentCard.expiryYear,
        'holder_name': paymentCard.holderName,
        'is_default': paymentCard.isDefault,
      };
      
      final result = await SupabaseService.instance.savePaymentCard(cardData);
      final success = result != null;

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tarjeta guardada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Regresar a la pantalla anterior
        Navigator.pop(context, paymentCard);
      } else {
        throw Exception('Error guardando la tarjeta en la base de datos');
      }
    } catch (e) {
      print('Error saving card: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error guardando tarjeta: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    setState(() => _isLoading = true);

    try {
      // Crear objeto PaymentCard
      final cardData = PaymentCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        last4: _cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4),
        cardType: _cardType ?? 'Tarjeta',
        expiryMonth: _expiryController.text.split('/')[0],
        expiryYear: _expiryController.text.split('/')[1],
        holderName: _cardHolderController.text,
        createdAt: DateTime.now(),
      );

      // 1. Primero procesar con Square (opcional - para tokenizar la tarjeta)
      String? squareCardId;
      try {
        // Aquí puedes integrar con Square si necesitas tokenizar la tarjeta
        // Por ahora saltamos este paso, pero la estructura está lista
        // squareCardId = await SquarePaymentService.createCard(cardData);
      } catch (e) {
        print('Error with Square processing: $e');
        // Continuamos sin Square si hay error
      }

      // 2. Guardar tarjeta real en Supabase
      final cardWithSquareId = cardData.copyWith(squareCardId: squareCardId);
      
      // Verificar que el usuario esté autenticado
      final currentUser = SupabaseAuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }
      
      final savedCard = await SupabaseService.instance.insert('payment_cards', {
        'user_id': currentUser.id,
        'last_4': cardWithSquareId.last4,
        'card_type': cardWithSquareId.cardType,
        'expiry_month': cardWithSquareId.expiryMonth,
        'expiry_year': cardWithSquareId.expiryYear,
        'holder_name': cardWithSquareId.holderName,
        'square_card_id': squareCardId,
        'is_default': true, // Primera tarjeta es default
      });
      
      if (savedCard == null) {
        throw Exception('Error guardando tarjeta en la base de datos');
      }

      print('Card saved successfully to Supabase');
      final defaultCard = cardWithSquareId.copyWith(id: savedCard['id'], isDefault: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Tarjeta agregada exitosamente a tu perfil'),
            backgroundColor: Theme.of(context).primaryColor,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, cardWithSquareId.copyWith(id: savedCard['id'])); // Retorna la tarjeta guardada
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Agregar Nueva Tarjeta'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vista previa de la tarjeta
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tu Recarga', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          if (_cardType != null) _getCardIcon(_cardType!),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        _cardNumberController.text.isEmpty ? '**** **** **** ****' : _formatCardNumber(_cardNumberController.text),
                        style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TITULAR', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              Text(
                                _cardHolderController.text.isEmpty ? 'NOMBRE APELLIDO' : _cardHolderController.text.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('EXPIRA', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              Text(
                                _expiryController.text.isEmpty ? 'MM/AA' : _expiryController.text,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Formulario
              const Text('Información de la Tarjeta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Número de tarjeta
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Número de tarjeta',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: const Icon(Icons.credit_card),
                  suffixIcon: _cardType != null ? _getCardIcon(_cardType!) : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                onChanged: _onCardNumberChanged,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingrese el número de tarjeta';
                  if (value!.replaceAll(' ', '').length < 13) return 'Número de tarjeta inválido';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Titular de la tarjeta
              TextFormField(
                controller: _cardHolderController,
                decoration: InputDecoration(
                  labelText: 'Nombre del titular',
                  hintText: 'Como aparece en la tarjeta',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingrese el nombre del titular';
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              
              const SizedBox(height: 16),
              
              // Fecha de expiración y CVV
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'MM/AA',
                        hintText: '12/27',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Ingrese fecha';
                        if (value!.length < 5) return 'Fecha inválida';
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Ingrese CVV';
                        if (value!.length < 3) return 'CVV inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Tarjeta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Nota de seguridad
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tu información está protegida con encriptación de nivel bancario. Nunca compartimos tus datos.',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCardNumber(String value) {
    value = value.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += value[i];
    }
    return formatted;
  }
}

// Formateador para número de tarjeta
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    String formatted = '';
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Formateador para fecha de expiración
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    String formatted = '';
    
    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) formatted += '/';
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}