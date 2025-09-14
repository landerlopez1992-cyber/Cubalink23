#!/usr/bin/env python3
"""
Script de prueba para los métodos de pago con Square
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

def test_get_payment_methods():
    """Probar obtener métodos de pago"""
    print("\n💳 Probando obtener métodos de pago...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/payment-methods")
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                methods = result.get('methods', [])
                print(f"✅ Métodos de pago obtenidos: {len(methods)} métodos")
                for method in methods:
                    print(f"   - {method.get('icon')} {method.get('name')}: {method.get('description')}")
                return methods
            else:
                print(f"❌ Error: {result.get('error')}")
                return []
        else:
            print(f"❌ Error obteniendo métodos de pago: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener métodos de pago: {e}")
        return []

def test_get_square_status():
    """Probar obtener estado de Square"""
    print("\n🔧 Probando estado de Square...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/payments/square-status")
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                status = result.get('status', {})
                print(f"✅ Estado de Square:")
                print(f"   - Configurado: {'✅' if status.get('configured') else '❌'}")
                print(f"   - Ambiente: {status.get('environment', 'N/A')}")
                print(f"   - Location ID: {'✅' if status.get('location_id') else '❌'}")
                print(f"   - Access Token: {'✅' if status.get('access_token') else '❌'}")
                print(f"   - Application ID: {'✅' if status.get('application_id') else '❌'}")
                return status
            else:
                print(f"❌ Error: {result.get('error')}")
                return {}
        else:
            print(f"❌ Error obteniendo estado de Square: {response.status_code}")
            return {}
    except Exception as e:
        print(f"❌ Error en obtener estado de Square: {e}")
        return {}

def test_create_payment_link():
    """Probar crear enlace de pago"""
    print("\n🔗 Probando crear enlace de pago...")
    
    # Primero necesitamos un pedido para crear el enlace
    try:
        # Obtener pedidos existentes
        orders_response = requests.get(f"{BASE_URL}/admin/api/orders")
        if orders_response.status_code == 200:
            orders = orders_response.json()
            if orders:
                order = orders[0]  # Usar el primer pedido
            else:
                print("   ⚠️ No hay pedidos disponibles, creando uno de prueba...")
                # Crear un pedido de prueba
                test_order_data = {
                    'user_id': 1,
                    'items': [{'product_id': 1, 'name': 'Producto Test', 'price': 29.99, 'quantity': 1, 'subtotal': 29.99}],
                    'total_amount': 29.99,
                    'currency': 'USD',
                    'status': 'pending',
                    'payment_method': 'credit_card',
                    'payment_status': 'pending',
                    'shipping_address': {'street': '123 Test St', 'city': 'Miami', 'state': 'FL', 'zip_code': '33101', 'country': 'USA'},
                    'notes': 'Pedido de prueba para enlace de pago'
                }
                
                order_response = requests.post(f"{BASE_URL}/admin/api/orders", json=test_order_data)
                if order_response.status_code == 200:
                    order = order_response.json()
                else:
                    print("   ❌ No se pudo crear pedido de prueba")
                    return None
        else:
            print("   ❌ No se pudieron obtener pedidos")
            return None
        
        # Crear enlace de pago
        payment_link_data = {
            'order_id': order.get('id'),
            'total_amount': order.get('total_amount')
        }
        
        response = requests.post(f"{BASE_URL}/admin/api/payments/create-link", json=payment_link_data)
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print(f"✅ Enlace de pago creado:")
                print(f"   - ID: {result.get('payment_link_id')}")
                print(f"   - URL: {result.get('checkout_url')}")
                print(f"   - Monto: ${result.get('amount')}")
                print(f"   - Mock: {'Sí' if result.get('mock') else 'No'}")
                return result
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error creando enlace de pago: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error en crear enlace de pago: {e}")
        return None

def test_process_payment():
    """Probar procesar pago"""
    print("\n💳 Probando procesar pago...")
    
    payment_data = {
        'source_id': 'test_source_id',
        'amount': 25.99,
        'currency': 'USD',
        'order_id': 'test_order_123',
        'order_number': 'TEST-001'
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/payments/process", json=payment_data)
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print(f"✅ Pago procesado:")
                print(f"   - ID: {result.get('payment_id')}")
                print(f"   - Estado: {result.get('status')}")
                print(f"   - Monto: ${result.get('amount')}")
                print(f"   - Mock: {'Sí' if result.get('mock') else 'No'}")
                return result
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error procesando pago: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error en procesar pago: {e}")
        return None

def test_get_payment_status():
    """Probar obtener estado de pago"""
    print("\n📊 Probando obtener estado de pago...")
    
    payment_id = "test_payment_123"
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/payments/{payment_id}/status")
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print(f"✅ Estado de pago obtenido:")
                print(f"   - ID: {result.get('payment_id')}")
                print(f"   - Estado: {result.get('status')}")
                print(f"   - Monto: ${result.get('amount')}")
                print(f"   - Mock: {'Sí' if result.get('mock') else 'No'}")
                return result
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error obteniendo estado de pago: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error en obtener estado de pago: {e}")
        return None

def test_refund_payment():
    """Probar reembolsar pago"""
    print("\n💰 Probando reembolsar pago...")
    
    payment_id = "test_payment_123"
    refund_data = {
        'amount': 10.00,
        'reason': 'Customer request - partial refund',
        'order_id': 'test_order_123'
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/payments/{payment_id}/refund", json=refund_data)
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print(f"✅ Reembolso procesado:")
                print(f"   - ID: {result.get('refund_id')}")
                print(f"   - Estado: {result.get('status')}")
                print(f"   - Monto: ${result.get('amount')}")
                print(f"   - Razón: {result.get('reason')}")
                print(f"   - Mock: {'Sí' if result.get('mock') else 'No'}")
                return result
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error reembolsando pago: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error en reembolsar pago: {e}")
        return None

def test_get_transaction_history():
    """Probar obtener historial de transacciones"""
    print("\n📈 Probando obtener historial de transacciones...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/payments/transactions")
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                transactions = result.get('transactions', [])
                print(f"✅ Historial de transacciones obtenido: {len(transactions)} transacciones")
                for tx in transactions[:3]:  # Mostrar solo las primeras 3
                    print(f"   - {tx.get('id')}: ${tx.get('amount')} - {tx.get('status')}")
                print(f"   - Mock: {'Sí' if result.get('mock') else 'No'}")
                return result
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error obteniendo historial: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error en obtener historial: {e}")
        return None

def test_create_customer():
    """Probar crear cliente"""
    print("\n👤 Probando crear cliente...")
    
    customer_data = {
        'first_name': 'Juan',
        'last_name': 'Pérez',
        'email': 'juan.perez@ejemplo.com',
        'phone': '+1-555-123-4567',
        'address': {
            'street': '123 Calle Principal',
            'city': 'Miami',
            'state': 'FL',
            'zip_code': '33101',
            'country': 'US'
        }
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/payments/customers", json=customer_data)
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print(f"✅ Cliente creado:")
                print(f"   - ID: {result.get('customer_id')}")
                print(f"   - Nombre: {result.get('name')}")
                print(f"   - Email: {result.get('email')}")
                print(f"   - Mock: {'Sí' if result.get('mock') else 'No'}")
                return result
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error creando cliente: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error en crear cliente: {e}")
        return None

def test_square_connection():
    """Probar conexión con Square"""
    print("\n🔌 Probando conexión con Square...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/payments/test-connection")
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print(f"✅ Conexión exitosa con Square")
                print(f"   - Mensaje: {result.get('message')}")
                test_result = result.get('test_result', {})
                print(f"   - Test Result: {test_result.get('success', 'N/A')}")
                return result
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error probando conexión: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error en probar conexión: {e}")
        return None

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
    print("🚀 Iniciando pruebas del sistema de métodos de pago...")
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
    
    # Probar estado de Square
    square_status = test_get_square_status()
    
    # Probar métodos de pago
    payment_methods = test_get_payment_methods()
    
    # Probar crear enlace de pago
    payment_link = test_create_payment_link()
    
    # Probar procesar pago
    payment_result = test_process_payment()
    
    # Probar obtener estado de pago
    payment_status = test_get_payment_status()
    
    # Probar reembolsar pago
    refund_result = test_refund_payment()
    
    # Probar historial de transacciones
    transaction_history = test_get_transaction_history()
    
    # Probar crear cliente
    customer_result = test_create_customer()
    
    # Probar conexión con Square
    connection_result = test_square_connection()
    
    print("\n" + "=" * 60)
    print("✅ Pruebas completadas!")
    print("\n📋 Resumen:")
    print(f"   - Métodos de pago disponibles: {len(payment_methods)}")
    print(f"   - Square configurado: {'✅' if square_status.get('configured') else '❌'}")
    print(f"   - Enlace de pago creado: {'✅' if payment_link else '❌'}")
    print(f"   - Pago procesado: {'✅' if payment_result else '❌'}")
    print(f"   - Estado de pago obtenido: {'✅' if payment_status else '❌'}")
    print(f"   - Reembolso procesado: {'✅' if refund_result else '❌'}")
    print(f"   - Historial de transacciones: {'✅' if transaction_history else '❌'}")
    print(f"   - Cliente creado: {'✅' if customer_result else '❌'}")
    print(f"   - Conexión con Square: {'✅' if connection_result else '❌'}")
    
    print("\n🔧 Configuración de Square:")
    print("   Para usar Square en producción, configura las variables de entorno:")
    print("   - SQUARE_ACCESS_TOKEN")
    print("   - SQUARE_APPLICATION_ID") 
    print("   - SQUARE_LOCATION_ID")
    print("   - SQUARE_ENVIRONMENT (sandbox/production)")

if __name__ == "__main__":
    main()

