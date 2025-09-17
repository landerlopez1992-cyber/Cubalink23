#!/usr/bin/env python3

import requests
import json
from datetime import datetime

# Datos de prueba para crear una orden
test_order_data = {
    "user_id": "0b802a1e-8651-4fcf-b2d7-0442db89f4d7",  # Lander Lopez
    "order_number": f"TEST-{datetime.now().strftime('%Y%m%d-%H%M%S')}",
    "items": [],
    "shipping_address": {
        "recipient": "Lander Lopez",
        "phone": "5358456789",
        "address": "Calle Test 123",
        "city": "La Habana",
        "province": "La Habana"
    },
    "shipping_method": "express",
    "subtotal": 25.00,
    "shipping_cost": 5.00,
    "total": 30.00,
    "payment_method": "wallet",
    "payment_status": "completed",
    "order_status": "payment_confirmed",
    "cart_items": [
        {
            "product_id": "test-product-1",
            "product_name": "Producto de Prueba",
            "product_price": 25.00,
            "quantity": 1,
            "product_type": "store"
        }
    ]
}

def test_backend_order_creation():
    """Probar creación de orden en el backend sistema"""
    print("🧪 PROBANDO CREACIÓN DE ORDEN EN BACKEND SISTEMA")
    print("=" * 60)
    
    backend_url = "https://cubalink23-system.onrender.com"
    
    print(f"🎯 Creando orden de prueba...")
    print(f"👤 Usuario: Lander Lopez ({test_order_data['user_id']})")
    print(f"💰 Total: ${test_order_data['total']}")
    print(f"📦 Items: {len(test_order_data['cart_items'])}")
    
    try:
        # Crear orden
        response = requests.post(
            f"{backend_url}/api/orders",
            json=test_order_data,
            headers={'Content-Type': 'application/json'},
            timeout=30
        )
        
        print(f"\n📡 Response Status: {response.status_code}")
        
        if response.status_code == 201:
            result = response.json()
            print("✅ ORDEN CREADA EXITOSAMENTE!")
            print(f"🆔 ID: {result.get('order_id', 'N/A')}")
            print(f"📄 Número: {result.get('order_number', 'N/A')}")
            
            # Ahora verificar que se puede obtener
            print(f"\n🔍 Verificando que se puede obtener la orden...")
            get_response = requests.get(
                f"{backend_url}/api/orders/user/{test_order_data['user_id']}",
                timeout=30
            )
            
            if get_response.status_code == 200:
                orders = get_response.json()
                print(f"✅ Órdenes encontradas: {len(orders)}")
                
                # Buscar la orden recién creada
                new_order = None
                for order in orders:
                    if order.get('order_number') == test_order_data['order_number']:
                        new_order = order
                        break
                
                if new_order:
                    print("🎉 ¡LA ORDEN SE GUARDÓ Y SE PUEDE RECUPERAR!")
                    print(f"   📄 Número: {new_order.get('order_number')}")
                    print(f"   💰 Total: ${new_order.get('total')}")
                    print(f"   📊 Estado: {new_order.get('order_status')}")
                    return True
                else:
                    print("❌ La orden se creó pero no se encuentra al buscarla")
                    return False
            else:
                print(f"❌ Error obteniendo órdenes: {get_response.status_code}")
                print(get_response.text)
                return False
                
        else:
            print("❌ ERROR CREANDO ORDEN")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ EXCEPCIÓN: {e}")
        return False

def main():
    success = test_backend_order_creation()
    
    print("\n" + "=" * 60)
    if success:
        print("🎯 RESULTADO: El backend sistema funciona correctamente")
        print("🔧 El problema debe estar en Flutter o en la comunicación")
    else:
        print("🎯 RESULTADO: Hay un problema en el backend sistema")
        print("🔧 Necesitamos arreglar el backend primero")

if __name__ == "__main__":
    main()
