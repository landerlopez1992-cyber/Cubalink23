#!/usr/bin/env python3

import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_service.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/models/order.dart';

class DebugOrderCreation {
  static Future<void> testOrderCreation() async {
    print('🧪 DEBUGGING FLUTTER ORDER CREATION');
    print('=' * 60);
    
    try {
      // Obtener usuario actual
      final currentUser = SupabaseAuthService.instance.getCurrentUser();
      if (currentUser == null) {
        print('❌ No hay usuario autenticado');
        return;
      }
      
      print('👤 Usuario autenticado: ${currentUser.id}');
      print('📧 Email: ${currentUser.email}');
      
      // Crear datos de orden de prueba (similar a los que crea Flutter)
      final testOrderData = {
        'user_id': currentUser.id,
        'order_number': 'FLUTTER-TEST-${DateTime.now().millisecondsSinceEpoch}',
        'items': [],
        'shipping_address': {
          'recipient': 'Lander Lopez',
          'phone': '5358456789',
          'address': 'Calle Flutter Test 123',
          'city': 'La Habana',
          'province': 'La Habana'
        },
        'shipping_method': 'express',
        'subtotal': 15.99,
        'shipping_cost': 3.50,
        'total': 19.49,
        'payment_method': 'wallet',
        'payment_status': 'completed',
        'order_status': 'payment_confirmed',
        'estimated_delivery': DateTime.now().add(Duration(days: 3)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'cart_items': [
          {
            'product_id': 'flutter-test-product',
            'product_name': 'Producto Test Flutter',
            'product_price': 15.99,
            'quantity': 1,
            'product_type': 'store',
            'weight_lb': 1.0
          }
        ]
      };
      
      print('📦 Datos de orden preparados:');
      print('   🆔 Order Number: ${testOrderData['order_number']}');
      print('   💰 Total: \$${testOrderData['total']}');
      print('   🛒 Cart Items: ${(testOrderData['cart_items'] as List).length}');
      
      // Probar creación usando SupabaseService directamente
      print('\n🗄️ Probando SupabaseService.createOrderRaw...');
      
      final supabaseResult = await SupabaseService.instance.createOrderRaw(testOrderData);
      
      if (supabaseResult != null) {
        print('✅ ¡ORDEN CREADA EXITOSAMENTE!');
        print('   🆔 ID: ${supabaseResult['id']}');
        print('   📄 Número: ${supabaseResult['order_number']}');
        print('   💰 Total: \$${supabaseResult['total']}');
        
        // Verificar que se puede obtener
        print('\n🔍 Verificando que se puede obtener la orden...');
        final orders = await SupabaseService.instance.getUserOrdersRaw(currentUser.id);
        
        final newOrder = orders.firstWhere(
          (order) => order['order_number'] == testOrderData['order_number'],
          orElse: () => {},
        );
        
        if (newOrder.isNotEmpty) {
          print('✅ ¡ORDEN ENCONTRADA EN LA BASE DE DATOS!');
          print('   📄 Número: ${newOrder['order_number']}');
          print('   💰 Total: \$${newOrder['total']}');
          print('   📊 Estado: ${newOrder['order_status']}');
          
          print('\n🎉 CONCLUSIÓN: Flutter SÍ puede crear órdenes correctamente');
          print('🔧 El problema debe estar en otro lado...');
        } else {
          print('❌ Orden creada pero no encontrada al buscar');
        }
        
      } else {
        print('❌ ERROR: SupabaseService.createOrderRaw falló');
        print('🔧 Esto indica un problema en el código de Flutter');
      }
      
    } catch (e) {
      print('💥 EXCEPCIÓN: $e');
      print('Stack trace: ${e.toString()}');
    }
  }
}
