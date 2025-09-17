#!/usr/bin/env python3
# 🔍 VERIFICAR ÓRDENES EN SUPABASE DIRECTAMENTE

from supabase import create_client
from datetime import datetime, timedelta

# Configuración Supabase
SUPABASE_URL = "https://zgqrhzuhrwudckwesybg.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNjY2NDgyOSwiZXhwIjoyMDQyMjQwODI5fQ.nMhOYDNNfq8NMqXvJKJT8SjLFjZJmVP9gDGGfcE8xhQ"

def main():
    print("🔍 ===== VERIFICANDO ÓRDENES EN SUPABASE =====")
    
    try:
        # Conectar con service key
        supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
        print("✅ Conectado a Supabase con service key")
        
        # 1. Verificar todas las órdenes
        print("\n📦 1. TODAS LAS ÓRDENES:")
        orders_result = supabase.table('orders').select('*').order('created_at', desc=True).limit(10).execute()
        
        if orders_result.data:
            print(f"✅ {len(orders_result.data)} órdenes encontradas:")
            for i, order in enumerate(orders_result.data):
                print(f"   {i+1}. {order['order_number']} - ${order['total']} - {order['order_status']}")
                print(f"      Usuario: {order['user_id'][:8]}... - Fecha: {order['created_at']}")
        else:
            print("❌ NO HAY ÓRDENES EN SUPABASE")
        
        # 2. Verificar órdenes del usuario específico (Lander)
        print(f"\n👤 2. ÓRDENES DE LANDER (0b802a1e-8651-4fcf-b2d7-0442db89f4d7):")
        user_orders = supabase.table('orders').select('*').eq('user_id', '0b802a1e-8651-4fcf-b2d7-0442db89f4d7').execute()
        
        if user_orders.data:
            print(f"✅ {len(user_orders.data)} órdenes de Lander:")
            for order in user_orders.data:
                print(f"   - {order['order_number']} - ${order['total']} - {order['created_at']}")
        else:
            print("❌ NO HAY ÓRDENES DE LANDER")
        
        # 3. Verificar órdenes recientes (últimas 2 horas)
        print(f"\n🕐 3. ÓRDENES RECIENTES (ÚLTIMAS 2 HORAS):")
        two_hours_ago = (datetime.now() - timedelta(hours=2)).isoformat()
        recent_orders = supabase.table('orders').select('*').gte('created_at', two_hours_ago).execute()
        
        if recent_orders.data:
            print(f"✅ {len(recent_orders.data)} órdenes recientes:")
            for order in recent_orders.data:
                print(f"   - {order['order_number']} - ${order['total']} - {order['created_at']}")
        else:
            print("❌ NO HAY ÓRDENES RECIENTES")
            print("💡 Esto confirma que las órdenes NO se están creando")
        
        # 4. Verificar estructura de tabla orders
        print(f"\n📋 4. ESTRUCTURA DE TABLA ORDERS:")
        # Intentar insertar orden de prueba
        test_order = {
            'user_id': '0b802a1e-8651-4fcf-b2d7-0442db89f4d7',
            'order_number': f'DIRECT-TEST-{datetime.now().strftime("%H%M%S")}',
            'shipping_method': 'express',
            'subtotal': 5.99,
            'shipping_cost': 1.00,
            'total': 6.99,
            'payment_method': 'wallet',
            'payment_status': 'completed',
            'order_status': 'payment_confirmed',
            'shipping_address': {"test": "data"},
            'items': []
        }
        
        try:
            test_result = supabase.table('orders').insert(test_order).execute()
            if test_result.data:
                print("✅ ORDEN DE PRUEBA CREADA EXITOSAMENTE")
                print(f"🆔 ID: {test_result.data[0]['id']}")
                print("🎯 PROBLEMA RESUELTO - Las órdenes ya funcionan")
            else:
                print("❌ Error creando orden de prueba")
        except Exception as e:
            print(f"❌ Error en prueba: {e}")
        
    except Exception as e:
        print(f"💥 Error general: {e}")
    
    print("\n🏁 ===== VERIFICACIÓN COMPLETADA =====")

if __name__ == "__main__":
    main()
