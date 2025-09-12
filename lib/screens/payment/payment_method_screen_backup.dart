import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/services/firebase_repository.dart';
import 'package:cubalink23/services/square_payment_service.dart';
import 'package:cubalink23/services/auth_service.dart';
import 'package:cubalink23/screens/payment/add_card_screen.dart';
import 'package:cubalink23/models/payment_card.dart';
import 'package:cubalink23/models/recharge_history.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/services/ding_connect_service.dart';

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
double _userBalance = 0.0;

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

      // Mostrar solo las tarjetas reales guardadas
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
          print(
            'Selected default card: ${defaultCard.cardType} •••• ${defaultCard.last4}');
        }
      });
    } catch (e) {
      print('Error loading payment cards: $e');
      setState(() => isLoading = false);

      // Show error to user
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

// ELIMINADO: No crear tarjetas de muestra automáticamente

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Theme.of(context).colorScheme.surface,
appBar: AppBar(
backgroundColor: Theme.of(context).colorScheme.primary,
foregroundColor: Theme.of(context).colorScheme.onPrimary,
title: const Text('Tarjetas guardadas',
style: TextStyle(fontWeight: FontWeight.bold)),
elevation: 0,
),
body: Column(
children: [
Expanded(
child: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const SizedBox(height: 20),
Card(
color: Theme.of(context).colorScheme.surface,
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12)),
child: ListTile(
contentPadding: const EdgeInsets.all(16),
leading: Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color:
Theme.of(context).colorScheme.secondaryContainer,
borderRadius: BorderRadius.circular(8),
),
child: Icon(
Icons.add_card,
color: Theme.of(context).colorScheme.secondary,
size: 24,
),
),
title: Text(
'Agregar nueva tarjeta',
style: TextStyle(
fontWeight: FontWeight.w600,
color: Theme.of(context).colorScheme.onSurface,
),
),
subtitle: Text(
'Tarjeta de débito o crédito',
style: TextStyle(
color:
Theme.of(context).colorScheme.onSurfaceVariant),
),
trailing: Icon(
Icons.arrow_forward_ios,
color: Theme.of(context).colorScheme.outline,
size: 16,
),
onTap: () async {
final result = await Navigator.push<PaymentCard>(
context,
MaterialPageRoute(
builder: (context) => const AddCardScreen()),
);
if (result != null) {
await _loadUserCards();
}
},
),
),
const SizedBox(height: 20),
if (isLoading) ...[
const Center(
child: Padding(
padding: EdgeInsets.all(32.0),
child: CircularProgressIndicator(),
),
),
] else if (savedCards.isNotEmpty) ...[
Text(
'Tarjetas guardadas',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
color: Theme.of(context).colorScheme.onSurface,
),
),
const SizedBox(height: 12),
...savedCards
.map(
(card) => Padding(
padding: const EdgeInsets.only(bottom: 12),
child: Card(
elevation: selectedCardId == card.id ? 4 : 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
side: BorderSide(
color: selectedCardId == card.id
? Theme.of(context).colorScheme.primary
: Colors.transparent,
width: 2,
),
),
child: ListTile(
contentPadding: const EdgeInsets.all(16),
leading: Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: _getCardColor(card.cardType),
borderRadius: BorderRadius.circular(8),
),
child: Icon(
_getCardIcon(card.cardType),
color: Colors.white,
size: 24,
),
),
title: Row(
children: [
Text(
'${card.cardType} •••• ${card.last4}',
style: TextStyle(
fontWeight: FontWeight.w600,
color: Theme.of(context)
.colorScheme
.onSurface,
),
),
if (card.isDefault) ...[
const SizedBox(width: 8),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 6,
vertical: 2,
),
decoration: BoxDecoration(
color: Theme.of(context)
.colorScheme
.primary,
borderRadius:
BorderRadius.circular(10),
),
child: Text(
'Principal',
style: TextStyle(
color: Theme.of(context)
.colorScheme
.onPrimary,
fontSize: 10,
fontWeight: FontWeight.bold,
),
),
),
],
],
),
subtitle: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
card.holderName,
style: TextStyle(
color: Theme.of(context)
.colorScheme
.onSurface,
),
),
Text(
'Expira ${card.expiryDate}',
style: TextStyle(
color: Theme.of(context)
.colorScheme
.onSurfaceVariant,
fontSize: 12,
),
),
],
),
trailing: Radio<String>(
value: card.id,
groupValue: selectedCardId,
activeColor:
Theme.of(context).colorScheme.primary,
onChanged: (value) {
setState(() {
selectedCardId = value;
});
},
),
onTap: () {
setState(() {
selectedCardId = card.id;
});
},
),
),
),
)
.toList(),
] else if (!isLoading) ...[
Center(
child: Padding(
padding: const EdgeInsets.all(32.0),
child: Column(
children: [
Icon(
Icons.credit_card_off,
size: 64,
color: Theme.of(context).colorScheme.outline,
),
const SizedBox(height: 16),
Text(
'No tienes tarjetas guardadas',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w500,
color: Theme.of(context).colorScheme.onSurface,
),
),
const SizedBox(height: 8),
Text(
'Agrega tu primera tarjeta para continuar',
textAlign: TextAlign.center,
style: TextStyle(
color: Theme.of(context)
.colorScheme
.onSurfaceVariant,
),
),
],
),
),
),
],
],
),
),
),

// Botón de continuar al pago
if (selectedCardId != null && !isLoading)
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.1),
blurRadius: 10,
offset: const Offset(0, -5),
),
],
),
child: SafeArea(
child: SizedBox(
width: double.infinity,
height: 50,
child: ElevatedButton(
onPressed: _processPayment,
style: ElevatedButton.styleFrom(
backgroundColor: Theme.of(context).colorScheme.primary,
foregroundColor: Theme.of(context).colorScheme.onPrimary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
elevation: 0,
),
child: Text(
'Proceder al Pago - \$${widget.total.toStringAsFixed(2)}',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
),
),
),
),
],
),
);
}

Color _getCardColor(String cardType) {
switch (cardType.toLowerCase()) {
case 'visa':
return Colors.blue[600]!;
case 'mastercard':
return Colors.orange[600]!;
default:
return Colors.grey[600]!;
}
}

IconData _getCardIcon(String cardType) {
switch (cardType.toLowerCase()) {
case 'visa':
case 'mastercard':
return Icons.credit_card;
default:
return Icons.payment;
}
}

// Procesar pago - puede ser recarga de balance o transacción DingConnect
Future<void> _processPayment() async {
if (selectedCardId == null) return;

// Obtener la tarjeta seleccionada
final selectedCard = savedCards.firstWhere(
(card) => card.id == selectedCardId,
orElse: () => PaymentCard(
id: '',
last4: '',
cardType: '',
expiryMonth: '',
expiryYear: '',
holderName: '',
createdAt: DateTime.now()),
);

// Determinar si es una transacción DingConnect
final isDingConnectTransaction = widget.metadata?['isDingConnectTransaction'] == true;

// Mostrar diálogo de procesamiento
showDialog(
context: context,
barrierDismissible: false,
builder: (context) => AlertDialog(
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
CircularProgressIndicator(
color: Theme.of(context).colorScheme.primary),
const SizedBox(height: 20),
Text(
isDingConnectTransaction 
  ? 'Procesando recarga real'
  : 'Procesando pago con Square',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
textAlign: TextAlign.center,
),
const SizedBox(height: 8),
if (isDingConnectTransaction) ...[
Text(
'📱 ${widget.metadata?['productTitle'] ?? 'Recarga móvil'}',
style: TextStyle(
fontSize: 14,
color: Theme.of(context).colorScheme.primary,
fontWeight: FontWeight.w600,
),
textAlign: TextAlign.center,
),
Text(
'📞 ${widget.metadata?['phoneNumber'] ?? ''}',
style: TextStyle(
fontSize: 14,
color: Theme.of(context).colorScheme.onSurfaceVariant,
),
textAlign: TextAlign.center,
),
] else
Text(
'Tarjeta: ${selectedCard.cardType} •••• ${selectedCard.last4}',
style: TextStyle(
fontSize: 14,
color: Theme.of(context).colorScheme.onSurfaceVariant,
),
textAlign: TextAlign.center,
),
const SizedBox(height: 8),
Text(
'Total: \$${widget.total.toStringAsFixed(2)}',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
color: Colors.green,
),
textAlign: TextAlign.center,
),
const SizedBox(height: 16),
Text(
isDingConnectTransaction
  ? '🌍 Enviando recarga via DingConnect...'
  : 'Por favor no cierres la app...',
style: TextStyle(
fontSize: 12,
color: Theme.of(context).colorScheme.outline,
),
textAlign: TextAlign.center,
),
],
),
),
);

try {
// Procesar pago con Square API
final paymentResult = await SquarePaymentService.processPayment(
amount: widget.total,
description: isDingConnectTransaction
  ? 'Recarga ${widget.metadata?['productTitle']} - ${widget.metadata?['phoneNumber']}'
  : 'Recarga Tu Recarga - \$${widget.amount.toStringAsFixed(2)}',
cardLast4: selectedCard.last4,
cardType: selectedCard.cardType,
cardHolderName: selectedCard.holderName,
);

// Si el pago falló, mostrar error y salir
if (!paymentResult.success) {
if (mounted) Navigator.of(context).pop();
_showPaymentError(paymentResult);
return;
}

// Si es transacción DingConnect, procesar la recarga real
if (isDingConnectTransaction) {
await _processDingConnectRecharge(paymentResult);
} else {
// Si es recarga de balance normal, actualizar balance
await _updateUserBalance();
if (mounted) Navigator.of(context).pop();
_showPaymentSuccess(paymentResult);
}

} catch (error) {
// Cerrar diálogo de carga
if (mounted) Navigator.of(context).pop();

// Mostrar error de conexión/sistema
_showPaymentError(SquarePaymentResult(
success: false,
transactionId: null,
message: 'Error de conexión: $error',
amount: widget.total,
));
}
}

// Procesar recarga real con DingConnect después del pago exitoso
Future<void> _processDingConnectRecharge(SquarePaymentResult paymentResult) async {
try {
print('🌍 Procesando recarga DingConnect...');

// Extraer datos de metadata
final phoneNumber = widget.metadata?['phoneNumber'] ?? '';
final productId = widget.metadata?['productId'] ?? widget.metadata?['skuCode'] ?? '';
final countryCode = widget.metadata?['countryCode'] ?? '';
final isDemo = widget.metadata?['isDemo'] == true;

// VALIDACIÓN CRÍTICA: No procesar recargas reales con productos demo
if (isDemo || productId.startsWith('DEMO_')) {
print('⚠️ BLOQUEADO: Intento de procesar recarga real con producto demo');
if (mounted) Navigator.of(context).pop();
_showDemoProductError(paymentResult);
return;
}

print('✅ Producto validado - Creando orden DingConnect con Product ID: $productId');

// Crear orden real via DingConnect usando la nueva API
final rechargeResult = await DingConnectService.instance.createOrder(
phoneNumber: phoneNumber,
productId: productId,
value: widget.amount,
customerOrderId: 'CL_${paymentResult.transactionId}_${DateTime.now().millisecondsSinceEpoch}',
);

// Si la orden se creó exitosamente, monitorear su estado
if (rechargeResult != null && rechargeResult['success'] == true) {
  final orderId = rechargeResult['orderId'];
  print('📋 Orden creada: $orderId - Monitoreando estado...');
  
  // Monitorear estado de la orden por 30 segundos
  int attempts = 0;
  const maxAttempts = 6; // 30 segundos / 5 segundos = 6 intentos
  
  while (attempts < maxAttempts) {
    await Future.delayed(Duration(seconds: 5));
    
    final statusResult = await DingConnectService.instance.getOrderStatus(orderId);
    
    if (statusResult != null && statusResult['success'] == true) {
      final status = statusResult['status'];
      
      print('📊 Estado de orden $orderId: $status');
      
      if (status == 'SUCCESS') {
        // Recarga completada exitosamente
        rechargeResult['status'] = 'SUCCESS';
        rechargeResult['recipientAmount'] = widget.amount;
        rechargeResult['recipientCurrency'] = 'USD';
        break;
      } else if (status == 'FAILED') {
        // Recarga falló
        rechargeResult['success'] = false;
        rechargeResult['error'] = 'La recarga falló en DingConnect';
        break;
      }
      // Si status == 'PROCESSING', continuar esperando
    }
    
    attempts++;
  }
  
  // Si salió del loop sin éxito ni fallo, marcar como procesando
  if (attempts >= maxAttempts && rechargeResult['status'] != 'SUCCESS' && rechargeResult['status'] != 'FAILED') {
    rechargeResult['status'] = 'PROCESSING';
    rechargeResult['note'] = 'La orden está siendo procesada. Verifica el estado más tarde.';
  }
}

// Cerrar diálogo de procesamiento
if (mounted) Navigator.of(context).pop();

if (rechargeResult != null && rechargeResult['success'] == true) {
// Recarga exitosa - guardar en historial
await _saveRechargeHistory(paymentResult, rechargeResult);
_showDingConnectSuccess(paymentResult, rechargeResult);
} else {
// Recarga falló - mostrar error pero el pago ya se procesó
_showDingConnectError(paymentResult, rechargeResult);
}

} catch (e) {
print('❌ Error procesando recarga DingConnect: $e');
if (mounted) Navigator.of(context).pop();
_showDingConnectError(paymentResult, {'error': 'Error interno: $e'});
}
}

// Guardar historial de recarga DingConnect
Future<void> _saveRechargeHistory(SquarePaymentResult paymentResult, Map<String, dynamic> rechargeResult) async {
try {
final currentUser = SupabaseAuthService.instance.currentUser;
if (currentUser != null) {
final recharge = RechargeTransaction(
id: rechargeResult['orderId'] ?? rechargeResult['transactionId'] ?? paymentResult.transactionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
recipientPhone: widget.metadata?['phoneNumber'] ?? '',
recipientName: widget.metadata?['productTitle'] ?? 'Recarga DingConnect',
countryCode: widget.metadata?['countryCode'] ?? '',
operatorId: widget.metadata?['provider'] ?? 'dingconnect',
amount: rechargeResult['recipientAmount']?.toDouble() ?? widget.amount,
cost: widget.total,
status: rechargeResult['status'] == 'SUCCESS' ? RechargeStatus.completed : 
        rechargeResult['status'] == 'FAILED' ? RechargeStatus.failed : 
        RechargeStatus.pending,
paymentMethod: PaymentMethod.creditCard,
createdAt: DateTime.now(),
completedAt: rechargeResult['status'] == 'SUCCESS' ? DateTime.now() : null,
);

await SupabaseAuthService.instance.addRechargeHistory(currentUser.id, recharge.toMap());

// 🎯 NOTIFICAR SERVICIO USADO PARA RECOMPENSAS DE REFERIDOS
await AuthService.instance.notifyServiceUsed();
print('✅ Recarga DingConnect completada - Recompensas de referidos procesadas');
}
} catch (e) {
print('Error guardando historial de recarga: $e');
}
}

// Actualizar balance del usuario en Supabase
Future<void> _updateUserBalance() async {
try {
final currentUser = SupabaseAuthService.instance.currentUser;
if (currentUser != null) {
final newBalance = _userBalance + widget.amount;
await FirebaseRepository.instance.updateUserBalance(currentUser.id, newBalance);
_userBalance = newBalance;

// Guardar historial de transacción
// Create recharge transaction for history
final recharge = RechargeTransaction(
id: DateTime.now().millisecondsSinceEpoch.toString(),
recipientPhone: currentUser.phone ?? '',
recipientName: currentUser.name ?? 'Usuario',
countryCode: 'US',
operatorId: 'balance_recharge',
amount: widget.amount,
cost: widget.total,
status: RechargeStatus.completed,
paymentMethod: PaymentMethod.creditCard,
createdAt: DateTime.now(),
completedAt: DateTime.now(),
);
await SupabaseAuthService.instance.addRechargeHistory(currentUser.id, recharge.toMap());

// 🎯 NOTIFICAR SERVICIO USADO PARA RECOMPENSAS DE REFERIDOS
await AuthService.instance.notifyServiceUsed();
print('✅ Recarga completada - Recompensas de referidos procesadas');
}
} catch (e) {
print('Error actualizando balance: $e');
}
}

void _showPaymentSuccess(SquarePaymentResult result) {
showDialog(
context: context,
barrierDismissible: false,
builder: (context) => AlertDialog(
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
title: Row(
children: [
Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.green.withOpacity(0.1),
borderRadius: BorderRadius.circular(50),
),
child:
const Icon(Icons.check_circle, color: Colors.green, size: 28),
),
const SizedBox(width: 12),
const Expanded(
child: Text(
'¡Pago realizado satisfactoriamente!',
style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
),
],
),
content: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.green.withOpacity(0.05),
borderRadius: BorderRadius.circular(8),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Balance agregado: +\$${widget.amount.toStringAsFixed(2)}',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: Colors.green,
),
),
const SizedBox(height: 4),
Text('Comisión: \$${widget.fee.toStringAsFixed(2)}'),
Text('Total cobrado: \$${widget.total.toStringAsFixed(2)}'),
],
),
),
if (result.transactionId != null) ...[
const SizedBox(height: 12),
Text(
'ID Transacción:',
style: TextStyle(
fontSize: 12,
color: Theme.of(context).colorScheme.onSurfaceVariant,
),
),
Text(
'${result.transactionId}',
style: const TextStyle(
fontSize: 11,
fontFamily: 'monospace',
fontWeight: FontWeight.w500,
),
),
],
const SizedBox(height: 12),
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: Theme.of(context)
.colorScheme
.primaryContainer
.withOpacity(0.3),
borderRadius: BorderRadius.circular(6),
),
child: Row(
children: [
Icon(
Icons.info_outline,
size: 16,
color: Theme.of(context).colorScheme.primary,
),
const SizedBox(width: 8),
const Expanded(
child: Text(
'Tu balance se actualizó automáticamente',
style: TextStyle(fontSize: 12),
),
),
],
),
),
],
),
actions: [
ElevatedButton(
onPressed: () {
Navigator.of(context).pop(); // Cerrar diálogo
Navigator.of(context).pop(true); // Volver con éxito
},
style: ElevatedButton.styleFrom(
backgroundColor: Theme.of(context).colorScheme.primary,
foregroundColor: Theme.of(context).colorScheme.onPrimary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(8)),
),
child: const Text('Continuar',
style: TextStyle(fontWeight: FontWeight.bold)),
),
],
),
);
}

void _showPaymentError(SquarePaymentResult result) {
showDialog(
context: context,
barrierDismissible: false,
builder: (context) => AlertDialog(
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
title: Row(
children: [
Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.red.withOpacity(0.1),
borderRadius: BorderRadius.circular(50),
),
child:
const Icon(Icons.error_outline, color: Colors.red, size: 28),
),
const SizedBox(width: 12),
const Expanded(
child: Text(
'Error en el pago',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: Colors.red),
),
),
],
),
content: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.red.withOpacity(0.05),
borderRadius: BorderRadius.circular(8),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'No se pudo procesar el pago',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
),
),
const SizedBox(height: 8),
Text(
result.message,
style: TextStyle(
fontSize: 13,
color: Theme.of(context).colorScheme.onSurfaceVariant,
),
),
],
),
),
const SizedBox(height: 16),
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: Colors.orange.withOpacity(0.1),
borderRadius: BorderRadius.circular(6),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
const Icon(Icons.lightbulb_outline,
size: 16, color: Colors.orange),
const SizedBox(width: 8),
Text(
'Recomendaciones:',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w600,
color: Colors.orange[800],
),
),
],
),
const SizedBox(height: 6),
const Text(
'• Verifica que tu tarjeta tenga fondos suficientes\n'
'• Asegúrate de que la información sea correcta\n'
'• Intenta con otra tarjeta si es necesario',
style: TextStyle(fontSize: 11),
),
],
),
),
],
),
actions: [
TextButton(
onPressed: () => Navigator.of(context).pop(),
child: Text(
'Cambiar tarjeta',
style: TextStyle(color: Theme.of(context).colorScheme.outline),
),
),
ElevatedButton(
onPressed: () {
Navigator.of(context).pop(); // Cerrar diálogo
// Permitir que el usuario intente de nuevo
_processPayment();
},
style: ElevatedButton.styleFrom(
backgroundColor: Theme.of(context).colorScheme.primary,
foregroundColor: Theme.of(context).colorScheme.onPrimary,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(8)),
),
child: const Text('Intentar de nuevo',
style: TextStyle(fontWeight: FontWeight.bold)),
),
],
  ),
);
}

// Mostrar éxito para recarga DingConnect
void _showDingConnectSuccess(SquarePaymentResult paymentResult, Map<String, dynamic> rechargeResult) {
showDialog(
context: context,
barrierDismissible: false,
builder: (context) => AlertDialog(
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
title: Row(
children: [
Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.green.withOpacity( 0.1),
borderRadius: BorderRadius.circular(50),
),
child: const Icon(Icons.check_circle, color: Colors.green, size: 28),
),
const SizedBox(width: 12),
const Expanded(
child: Text(
'🎉 ¡Recarga Enviada!',
style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
),
],
),
content: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.green.withOpacity( 0.05),
borderRadius: BorderRadius.circular(8),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'📱 ${widget.metadata?['productTitle'] ?? 'Recarga móvil'}',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: Colors.green,
),
),
const SizedBox(height: 4),
Text('📞 Número: ${widget.metadata?['phoneNumber'] ?? ''}'),
Text('💰 Enviado: ${rechargeResult['recipientAmount']} ${rechargeResult['recipientCurrency']}'),
Text('💳 Cobrado: \$${widget.total.toStringAsFixed(2)} USD'),
if (rechargeResult['providerName'] != null)
Text('🏢 Operador: ${rechargeResult['providerName']}'),
],
),
),
if (rechargeResult['transactionId'] != null) ...[
const SizedBox(height: 12),
Text(
'ID Transacción DingConnect:',
style: TextStyle(
fontSize: 12,
color: Theme.of(context).colorScheme.onSurfaceVariant,
),
),
Text(
'${rechargeResult['transactionId']}',
style: const TextStyle(
fontSize: 11,
fontFamily: 'monospace',
fontWeight: FontWeight.w500,
),
),
],
const SizedBox(height: 12),
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: Theme.of(context).colorScheme.primaryContainer.withOpacity( 0.3),
borderRadius: BorderRadius.circular(6),
),
child: Row(
children: [
Icon(
Icons.verified,
size: 16,
color: Theme.of(context).colorScheme.primary,
),
const SizedBox(width: 8),
const Expanded(
child: Text(
'Recarga real procesada via DingConnect',
style: TextStyle(fontSize: 12),
),
),
],
),
),
],
),
actions: [
ElevatedButton(
onPressed: () {
Navigator.of(context).pop(); // Cerrar diálogo
Navigator.of(context).pop(true); // Volver con éxito
},
style: ElevatedButton.styleFrom(
backgroundColor: Theme.of(context).colorScheme.primary,
foregroundColor: Theme.of(context).colorScheme.onPrimary,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
),
child: const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold)),
),
],
),
);
}

// Mostrar error para recarga DingConnect
void _showDingConnectError(SquarePaymentResult paymentResult, Map<String, dynamic>? rechargeResult) {
final errorMessage = rechargeResult?['error'] ?? 'Error desconocido en la recarga';

showDialog(
context: context,
barrierDismissible: false,
builder: (context) => AlertDialog(
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
title: Row(
children: [
Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.orange.withOpacity( 0.1),
borderRadius: BorderRadius.circular(50),
),
child: const Icon(Icons.warning_amber, color: Colors.orange, size: 28),
),
const SizedBox(width: 12),
const Expanded(
child: Text(
'⚠️ Recarga No Enviada',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: Colors.orange,
),
),
),
],
),
content: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.orange.withOpacity( 0.05),
borderRadius: BorderRadius.circular(8),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'El pago de \$${widget.total.toStringAsFixed(2)} fue procesado exitosamente, pero la recarga móvil no pudo ser enviada.',
style: const TextStyle(fontWeight: FontWeight.w600),
),
const SizedBox(height: 8),
Text('📞 Número: ${widget.metadata?['phoneNumber'] ?? ''}'),
Text('❌ Error: $errorMessage'),
],
),
),
const SizedBox(height: 16),
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: Colors.blue.withOpacity( 0.1),
borderRadius: BorderRadius.circular(6),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
const Icon(Icons.support_agent, size: 16, color: Colors.blue),
const SizedBox(width: 8),
Text(
'¿Qué hacer ahora?',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w600,
color: Colors.blue[800],
),
),
],
),
const SizedBox(height: 6),
const Text(
'• Tu pago fue procesado correctamente\n'
'• Contacta a soporte para procesar la recarga manualmente\n'
'• Se te reembolsará si no es posible completar la recarga',
style: TextStyle(fontSize: 11),
),
],
),
),
if (paymentResult.transactionId != null) ...[
const SizedBox(height: 12),
Text(
'ID Pago (para soporte):',
style: TextStyle(
fontSize: 12,
color: Theme.of(context).colorScheme.onSurfaceVariant,
),
),
Text(
'${paymentResult.transactionId}',
style: const TextStyle(
fontSize: 11,
fontFamily: 'monospace',
fontWeight: FontWeight.w500,
),
),
],
],
),
actions: [
TextButton(
onPressed: () {
Navigator.of(context).pop();
Navigator.of(context).pop();
// Navegar a soporte/contacto
},
child: const Text('Contactar Soporte'),
),
ElevatedButton(
onPressed: () {
Navigator.of(context).pop(); // Cerrar diálogo
Navigator.of(context).pop(true); // Volver
},
style: ElevatedButton.styleFrom(
backgroundColor: Theme.of(context).colorScheme.primary,
foregroundColor: Theme.of(context).colorScheme.onPrimary,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
),
child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
),
],
),
);
}

// Mostrar error específico para productos demo
void _showDemoProductError(SquarePaymentResult paymentResult) {
showDialog(
context: context,
barrierDismissible: false,
builder: (context) => AlertDialog(
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
title: Row(
children: [
Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.red.withOpacity( 0.1),
borderRadius: BorderRadius.circular(50),
),
child: const Icon(Icons.block, color: Colors.red, size: 28),
),
const SizedBox(width: 12),
const Expanded(
child: Text(
'🚫 Producto Demo Detectado',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: Colors.red,
),
),
),
],
),
content: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.red.withOpacity( 0.05),
borderRadius: BorderRadius.circular(8),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'❗ IMPORTANTE: Este producto es solo para demostración y NO puede utilizarse para recargas reales.',
style: const TextStyle(fontWeight: FontWeight.w600),
),
const SizedBox(height: 12),
Text('🛑 Tu pago de \$${widget.total.toStringAsFixed(2)} NO fue procesado por seguridad.'),
const SizedBox(height: 8),
Text('🎭 Producto: ${widget.metadata?['productTitle'] ?? 'Demo'}'),
Text('📱 SKU: ${widget.metadata?['skuCode'] ?? 'N/A'}'),
],
),
),
const SizedBox(height: 16),
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: Colors.blue.withOpacity( 0.1),
borderRadius: BorderRadius.circular(6),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
const Icon(Icons.info, size: 16, color: Colors.blue),
const SizedBox(width: 8),
Text(
'¿Cómo realizar recargas reales?',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w600,
color: Colors.blue,
),
),
],
),
const SizedBox(height: 8),
const Text(
'• Espera a que se establezca conexión con DingConnect API\n'
'• Los productos reales se mostrarán sin la marca "DEMO"\n'
'• Contacta soporte si necesitas ayuda inmediata',
style: TextStyle(fontSize: 12, height: 1.4),
),
],
),
),
],
),
actions: [
TextButton(
onPressed: () {
Navigator.of(context).pop(); // Cerrar diálogo
Navigator.of(context).pop(false); // Volver sin procesar pago
},
child: const Text('Entendido'),
),
ElevatedButton(
onPressed: () {
Navigator.of(context).pop(); // Cerrar diálogo
Navigator.of(context).pop(false); // Volver sin procesar pago
},
style: ElevatedButton.styleFrom(
backgroundColor: Theme.of(context).colorScheme.primary,
foregroundColor: Theme.of(context).colorScheme.onPrimary,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
),
child: const Text('Volver', style: TextStyle(fontWeight: FontWeight.bold)),
),
],
),
);
}
}
