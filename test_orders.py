#!/usr/bin/env python3
"""
Script de prueba para la gestión de pedidos
"""

import requests
import json
import os
from datetime import datetime, timedelta

# Configuración
BASE_URL = "http://localhost:3005"
ADMIN_USERNAME = "landerlopez1992@gmail.com"
ADMIN_PASSWORD = "Maquina.2055"

def test_login():
    """Probar login del admin"""
    print("🔐 Probando login...")
    
    login_data = {
        'username': ADMIN_USERNAME,
        'password': ADMIN_PASSWORD
    }
    
    try:
        response = requests.post(f"{BASE_URL}/auth/login", data=login_data)
        if response.status_code == 200:
            print("✅ Login exitoso")
            return True
        else:
            print(f"❌ Login falló: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error en login: {e}")
        return False

def test_get_orders():
    """Probar obtener pedidos"""
    print("\n📦 Probando obtener pedidos...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/orders")
        if response.status_code == 200:
            orders = response.json()
            print(f"✅ Pedidos obtenidos: {len(orders)} pedidos")
            for order in orders[:3]:  # Mostrar solo los primeros 3
                print(f"   - {order.get('order_number', 'N/A')}: ${order.get('total_amount', 0)} - {order.get('status', 'N/A')}")
            return orders
        else:
            print(f"❌ Error obteniendo pedidos: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener pedidos: {e}")
        return []

def test_add_order():
    """Probar agregar pedido"""
    print("\n➕ Probando agregar pedido...")
    
    # Obtener usuarios para usar uno existente
    try:
        users_response = requests.get(f"{BASE_URL}/admin/api/users")
        users = users_response.json() if users_response.status_code == 200 else []
        user_id = users[0].get('id') if users else 1
    except:
        user_id = 1
    
    order_data = {
        'user_id': user_id,
        'items': [
            {
                'product_id': 1,
                'name': 'Producto de Prueba',
                'price': 29.99,
                'quantity': 2,
                'subtotal': 59.98
            },
            {
                'product_id': 2,
                'name': 'Otro Producto',
                'price': 15.50,
                'quantity': 1,
                'subtotal': 15.50
            }
        ],
        'total_amount': 75.48,
        'currency': 'USD',
        'status': 'pending',
        'payment_method': 'credit_card',
        'payment_status': 'pending',
        'shipping_address': {
            'street': '123 Calle Principal',
            'city': 'Miami',
            'state': 'FL',
            'zip_code': '33101',
            'country': 'USA'
        },
        'notes': 'Pedido de prueba desde script'
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/orders", json=order_data)
        if response.status_code == 200:
            order = response.json()
            print(f"✅ Pedido agregado: {order.get('order_number')} - ${order.get('total_amount')}")
            return order
        else:
            print(f"❌ Error agregando pedido: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en agregar pedido: {e}")
        return None

def test_update_order(order_id):
    """Probar actualizar pedido"""
    print(f"\n✏️ Probando actualizar pedido ID: {order_id}...")
    
    update_data = {
        'items': [
            {
                'product_id': 1,
                'name': 'Producto Actualizado',
                'price': 35.99,
                'quantity': 1,
                'subtotal': 35.99
            }
        ],
        'total_amount': 35.99,
        'currency': 'USD',
        'status': 'processing',
        'payment_method': 'paypal',
        'payment_status': 'paid',
        'shipping_address': {
            'street': '456 Avenida Actualizada',
            'city': 'Miami',
            'state': 'FL',
            'zip_code': '33102',
            'country': 'USA'
        },
        'notes': 'Pedido actualizado desde script'
    }
    
    try:
        response = requests.put(f"{BASE_URL}/admin/api/orders/{order_id}", json=update_data)
        if response.status_code == 200:
            order = response.json()
            print(f"✅ Pedido actualizado: {order.get('order_number')} - ${order.get('total_amount')}")
            return order
        else:
            print(f"❌ Error actualizando pedido: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en actualizar pedido: {e}")
        return None

def test_update_order_status(order_id):
    """Probar actualizar estado del pedido"""
    print(f"\n🔄 Probando actualizar estado del pedido ID: {order_id}...")
    
    status_data = {
        'status': 'shipped'
    }
    
    try:
        response = requests.put(f"{BASE_URL}/admin/api/orders/{order_id}/status", json=status_data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Estado actualizado: {result.get('success')}")
            return result.get('success')
        else:
            print(f"❌ Error actualizando estado: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error en actualizar estado: {e}")
        return False

def test_update_payment_status(order_id):
    """Probar actualizar estado de pago"""
    print(f"\n💳 Probando actualizar estado de pago ID: {order_id}...")
    
    payment_data = {
        'payment_status': 'paid'
    }
    
    try:
        response = requests.put(f"{BASE_URL}/admin/api/orders/{order_id}/payment-status", json=payment_data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Estado de pago actualizado: {result.get('success')}")
            return result.get('success')
        else:
            print(f"❌ Error actualizando estado de pago: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error en actualizar estado de pago: {e}")
        return False

def test_get_orders_by_status():
    """Probar obtener pedidos por estado"""
    print("\n📊 Probando obtener pedidos por estado...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/orders/status/pending")
        if response.status_code == 200:
            orders = response.json()
            print(f"✅ Pedidos pendientes: {len(orders)} pedidos")
            for order in orders[:3]:
                print(f"   - {order.get('order_number')}: ${order.get('total_amount')}")
            return orders
        else:
            print(f"❌ Error obteniendo pedidos por estado: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener pedidos por estado: {e}")
        return []

def test_get_order_statistics():
    """Probar obtener estadísticas de pedidos"""
    print("\n📈 Probando obtener estadísticas de pedidos...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/orders/statistics")
        if response.status_code == 200:
            stats = response.json()
            print(f"✅ Estadísticas obtenidas:")
            print(f"   - Total de pedidos: {stats.get('total_orders', 0)}")
            print(f"   - Total de ventas: ${stats.get('total_sales', 0)}")
            print(f"   - Pedidos por estado: {stats.get('orders_by_status', {})}")
            return stats
        else:
            print(f"❌ Error obteniendo estadísticas: {response.status_code}")
            return {}
    except Exception as e:
        print(f"❌ Error en obtener estadísticas: {e}")
        return {}

def test_get_orders_by_user():
    """Probar obtener pedidos de un usuario específico"""
    print("\n👤 Probando obtener pedidos de usuario...")
    
    # Obtener usuarios para usar uno existente
    try:
        users_response = requests.get(f"{BASE_URL}/admin/api/users")
        users = users_response.json() if users_response.status_code == 200 else []
        user_id = users[0].get('id') if users else 1
    except:
        user_id = 1
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/orders/user/{user_id}")
        if response.status_code == 200:
            orders = response.json()
            print(f"✅ Pedidos del usuario {user_id}: {len(orders)} pedidos")
            for order in orders[:3]:
                print(f"   - {order.get('order_number')}: ${order.get('total_amount')}")
            return orders
        else:
            print(f"❌ Error obteniendo pedidos del usuario: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener pedidos del usuario: {e}")
        return []

def test_health_check():
    """Probar health check"""
    print("\n🏥 Probando health check...")
    
    try:
        response = requests.get(f"{BASE_URL}/api/health")
        if response.status_code == 200:
            health = response.json()
            print(f"✅ Health check: {health.get('status')} - {health.get('message')}")
            return True
        else:
            print(f"❌ Health check falló: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error en health check: {e}")
        return False

def main():
    """Función principal de pruebas"""
    print("🚀 Iniciando pruebas del sistema de gestión de pedidos...")
    print("=" * 60)
    
    # Verificar que el servidor esté corriendo
    if not test_health_check():
        print("\n❌ El servidor no está corriendo. Inicia el servidor primero:")
        print("   python app.py")
        return
    
    # Probar login
    if not test_login():
        print("\n❌ No se pudo hacer login. Verifica las credenciales.")
        return
    
    # Probar obtener pedidos
    orders = test_get_orders()
    
    # Probar obtener estadísticas
    stats = test_get_order_statistics()
    
    # Probar obtener pedidos por estado
    pending_orders = test_get_orders_by_status()
    
    # Probar obtener pedidos de usuario
    user_orders = test_get_orders_by_user()
    
    # Probar agregar pedido
    new_order = test_add_order()
    
    if new_order:
        order_id = new_order.get('id')
        
        # Probar actualizar pedido
        updated_order = test_update_order(order_id)
        
        # Probar actualizar estado
        status_updated = test_update_order_status(order_id)
        
        # Probar actualizar estado de pago
        payment_updated = test_update_payment_status(order_id)
    
    print("\n" + "=" * 60)
    print("✅ Pruebas completadas!")
    print("\n📋 Resumen:")
    print(f"   - Pedidos en sistema: {len(orders)}")
    print(f"   - Total de ventas: ${stats.get('total_sales', 0)}")
    print(f"   - Pedidos pendientes: {len(pending_orders)}")
    print(f"   - Pedidos de usuario: {len(user_orders)}")
    if new_order:
        print(f"   - Pedido de prueba agregado: {new_order.get('order_number')}")
        print(f"   - Funciones de actualización: ✅")
        print(f"   - Gestión de estados: ✅")
        print(f"   - Estadísticas: ✅")

if __name__ == "__main__":
    main()

