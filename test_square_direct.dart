import 'package:flutter/material.dart';
import 'package:cubalink23/services/square_payment_service.dart';

void main() async {
  print('🧪 Probando Square Payment Service directamente...');
  
  try {
    // 1. Inicializar Square
    print('\n📋 1. Inicializando Square...');
    await SquarePaymentService.initialize();
    
    // 2. Crear Payment Link
    print('\n📋 2. Creando Payment Link...');
    final result = await SquarePaymentService.createQuickPaymentLink(
      amount: 10.0,
      description: 'Test Payment CubaLink23 - Direct Test',
      returnUrl: 'https://cubalink23.com/payment-success',
    );
    
    // 3. Mostrar resultado
    print('\n📋 3. Resultado del pago:');
    print('✅ Success: ${result.success}');
    print('💰 Amount: \$${result.amount}');
    print('🆔 Transaction ID: ${result.transactionId}');
    print('💬 Message: ${result.message}');
    print('🔗 Checkout URL: ${result.checkoutUrl}');
    
    if (result.success && result.checkoutUrl != null) {
      print('\n🎉 ¡Square está funcionando correctamente!');
      print('🌐 URL para probar: ${result.checkoutUrl}');
    } else {
      print('\n❌ Error en Square: ${result.message}');
    }
    
  } catch (e) {
    print('\n❌ Error ejecutando test: $e');
  }
}



