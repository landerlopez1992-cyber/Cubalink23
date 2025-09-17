#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🧪 TEST DIRECTO DE CREACIÓN DE ÓRDENES
Probar si las órdenes se están creando correctamente en Supabase
"""

import requests
import json
from datetime import datetime

# Configuración del backend
BACKEND_URL = "https://cubalink23-backend.onrender.com"

def test_create_order_direct():
    print("🧪 ===== TEST DIRECTO DE CREACIÓN DE ÓRDENES =====")
    print(f"🌐 Backend: {BACKEND_URL}")
    print()
    
    # Datos de orden de prueba
    test_order = {
        "user_id": "test-user-123",  # ID de prueba
        "order_number": f"TEST-{datetime.now().strftime('%Y%m%d-%H%M%S')}",
        "customer_name": "Usuario Test",
        "customer_phone": "+1234567890",
        "shipping_recipient": "Usuario Test",
        "shipping_phone": "+1234567890", 
        "shipping_street": "Calle Test 123",
        "shipping_city": "Havana",
        "shipping_province": "La Habana",
        "shipping_method": "express",
        "subtotal": 25.99,
        "shipping_cost": 5.00,
        "total": 30.99,
        "payment_method": "wallet",
        "payment_status": "completed",
        "order_status": "payment_confirmed",
        "items": [
            {
                "name": "Producto Test 1",
                "price": 15.99,
                "quantity": 1,
                "type": "store"
            },
            {
                "name": "Producto Test 2", 
                "price": 9.99,
                "quantity": 1,
                "type": "amazon"
            }
        ]
    }
    
    print("📦 Datos de orden preparados:")
    print(f"   - Número: {test_order['order_number']}")
    print(f"   - Total: ${test_order['total']}")
    print(f"   - Items: {len(test_order['items'])}")
    print()
    
    # 1. Verificar que el backend esté funcionando
    print("🔍 1. VERIFICANDO BACKEND...")
    try:
        response = requests.get(f"{BACKEND_URL}/api/health", timeout=10)
        if response.status_code == 200:
            print("✅ Backend funcionando correctamente")
        else:
            print(f"⚠️ Backend responde con código: {response.status_code}")
    except Exception as e:
        print(f"❌ Error conectando al backend: {e}")
        return
    
    print()
    
    # 2. Intentar crear orden a través del backend
    print("🚀 2. CREANDO ORDEN A TRAVÉS DEL BACKEND...")
    try:
        response = requests.post(
            f"{BACKEND_URL}/admin/api/orders",
            headers={"Content-Type": "application/json"},
            json=test_order,
            timeout=15
        )
        
        print(f"📡 Response code: {response.status_code}")
        print(f"📋 Response body: {response.text[:500]}...")
        
        if response.status_code in [200, 201]:
            result = response.json()
            print("✅ ORDEN CREADA EXITOSAMENTE")
            print(f"🆔 ID: {result.get('id', 'N/A')}")
            print(f"📋 Número: {result.get('order_number', 'N/A')}")
        else:
            print("❌ Error creando orden")
            
    except Exception as e:
        print(f"💥 Error en request: {e}")
    
    print()
    
    # 3. Verificar órdenes existentes
    print("📋 3. VERIFICANDO ÓRDENES EXISTENTES...")
    try:
        response = requests.get(f"{BACKEND_URL}/admin/api/orders", timeout=10)
        
        if response.status_code == 200:
            orders = response.json()
            if isinstance(orders, list):
                print(f"📦 {len(orders)} órdenes encontradas en total")
                
                # Mostrar últimas 3 órdenes
                for i, order in enumerate(orders[:3]):
                    print(f"   {i+1}. {order.get('order_number', 'N/A')} - ${order.get('total', 0)}")
                    print(f"      Estado: {order.get('order_status', 'N/A')}")
                    print(f"      Pago: {order.get('payment_method', 'N/A')}")
                    print(f"      Fecha: {order.get('created_at', 'N/A')}")
                    print()
            else:
                print("⚠️ Respuesta no es una lista")
        else:
            print(f"❌ Error obteniendo órdenes: {response.status_code}")
            
    except Exception as e:
        print(f"💥 Error verificando órdenes: {e}")
    
    print()
    print("🎯 CONCLUSIONES:")
    print("Si ves órdenes creadas aquí pero no en la app:")
    print("   → El problema está en la app Flutter")
    print("Si no se crean órdenes:")
    print("   → El problema está en el backend/Supabase")
    print()
    print("🏁 ===== TEST COMPLETADO =====")

if __name__ == "__main__":
    test_create_order_direct()
