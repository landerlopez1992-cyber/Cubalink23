#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para probar los endpoints de pago
"""

import requests
import json

BASE_URL = 'http://localhost:3005'

def test_square_status():
    """Probar estado de Square"""
    print("🔍 Probando estado de Square...")
    try:
        response = requests.get(f'{BASE_URL}/api/payments/square-status')
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_payment_methods():
    """Probar obtener métodos de pago"""
    print("\n💳 Probando métodos de pago...")
    try:
        response = requests.get(f'{BASE_URL}/api/payments/methods')
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_create_payment():
    """Probar crear enlace de pago"""
    print("\n🔗 Probando crear enlace de pago...")
    try:
        data = {
            'amount': 10.00,
            'description': 'Prueba de pago Cubalink23',
            'user_id': 'test_user_123',
            'currency': 'USD'
        }
        
        response = requests.post(
            f'{BASE_URL}/api/payments/process',
            headers={'Content-Type': 'application/json'},
            json=data
        )
        
        print(f"Status: {response.status_code}")
        result = response.json()
        print(f"Response: {result}")
        
        if result.get('success'):
            return result.get('payment_link_id')
        return None
        
    except Exception as e:
        print(f"Error: {e}")
        return None

def test_payment_status(payment_id):
    """Probar obtener estado de pago"""
    print(f"\n📊 Probando estado de pago: {payment_id}")
    try:
        response = requests.get(f'{BASE_URL}/api/payments/status/{payment_id}')
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_transaction_history():
    """Probar historial de transacciones"""
    print("\n📈 Probando historial de transacciones...")
    try:
        response = requests.get(f'{BASE_URL}/api/payments/history')
        print(f"Status: {response.status_code}")
        result = response.json()
        print(f"Total transactions: {result.get('total_count', 0)}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    """Función principal de pruebas"""
    print("🚀 Iniciando pruebas de endpoints de pago...")
    print("=" * 60)
    
    # Probar estado de Square
    square_ok = test_square_status()
    
    if not square_ok:
        print("\n❌ Square no está disponible. Verifica la configuración.")
        return
    
    # Probar métodos de pago
    methods_ok = test_payment_methods()
    
    # Probar crear enlace de pago
    payment_id = test_create_payment()
    
    if payment_id:
        # Probar estado del pago
        test_payment_status(payment_id)
    
    # Probar historial
    test_transaction_history()
    
    print("\n" + "=" * 60)
    print("✅ Pruebas completadas!")
    print("\n📋 Resumen:")
    print(f"   - Square Status: {'✅' if square_ok else '❌'}")
    print(f"   - Payment Methods: {'✅' if methods_ok else '❌'}")
    print(f"   - Create Payment: {'✅' if payment_id else '❌'}")
    
    if payment_id:
        print(f"   - Payment ID: {payment_id}")

if __name__ == "__main__":
    main()



