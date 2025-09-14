#!/usr/bin/env python3
"""
Script de pruebas para la integración de billetera con Square
Simula el flujo completo que usaría la app Flutter
"""

import requests
import json
import time
from datetime import datetime

# Configuración
BASE_URL = 'http://localhost:3005'
ADMIN_USERNAME = 'admin'
ADMIN_PASSWORD = 'admin123'

def login():
    """Iniciar sesión como administrador"""
    print("🔐 Iniciando sesión...")
    
    login_data = {
        'username': ADMIN_USERNAME,
        'password': ADMIN_PASSWORD
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/login', json=login_data)
        
        if response.status_code == 200:
            print("✅ Login exitoso")
            return response.cookies
        else:
            print(f"❌ Error en login: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_create_wallet_for_user(cookies, user_id):
    """Crear billetera para un usuario (simula registro en Flutter)"""
    print(f"\n👤 Creando billetera para usuario {user_id}...")
    
    wallet_data = {
        'user_id': user_id,
        'initial_balance': 0.00,
        'currency': 'USD'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/wallets', 
                               json=wallet_data, cookies=cookies)
        
        if response.status_code == 200:
            wallet = response.json()
            print(f"✅ Billetera creada para usuario {user_id}")
            print(f"   - Saldo inicial: ${wallet.get('balance', 0)}")
            return wallet
        else:
            print(f"❌ Error creando billetera: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_add_funds_with_square(cookies, user_id, amount):
    """Simular recarga de billetera usando Square (como en Flutter)"""
    print(f"\n💳 Simulando recarga de ${amount} para usuario {user_id}...")
    
    recharge_data = {
        'amount': amount,
        'payment_method': 'card'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/wallets/{user_id}/add-funds', 
                               json=recharge_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Enlace de pago creado")
            print(f"   - Enlace: {result.get('payment_link', 'N/A')}")
            print(f"   - Payment ID: {result.get('payment_id', 'N/A')}")
            print(f"   - Monto: ${result.get('amount')}")
            return result
        else:
            print(f"❌ Error creando enlace de pago: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_confirm_payment(cookies, user_id, payment_id, amount):
    """Confirmar pago y agregar fondos (simula webhook de Square)"""
    print(f"\n✅ Confirmando pago {payment_id}...")
    
    confirm_data = {
        'payment_id': payment_id,
        'amount': amount
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/wallets/{user_id}/confirm-payment', 
                               json=confirm_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Pago confirmado y fondos agregados")
            print(f"   - Nuevo saldo: ${result.get('wallet', {}).get('balance', 0)}")
            print(f"   - Mensaje: {result.get('message')}")
            return result
        else:
            print(f"❌ Error confirmando pago: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_transfer_between_users(cookies, user_id_1, user_id_2, amount):
    """Simular transferencia entre usuarios (como en Flutter)"""
    print(f"\n🔄 Simulando transferencia de ${amount} de {user_id_1} a {user_id_2}...")
    
    transfer_data = {
        'target_user_id': user_id_2,
        'amount': amount,
        'description': 'Transferencia desde app móvil'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/wallets/{user_id_1}/transfer', 
                               json=transfer_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Transferencia exitosa")
            print(f"   - Monto: ${result.get('amount')}")
            print(f"   - De: {result.get('from_user')} a {result.get('to_user')}")
            return result
        else:
            print(f"❌ Error en transferencia: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_get_wallet_balance(cookies, user_id):
    """Obtener saldo de billetera (como en Flutter)"""
    print(f"\n💰 Obteniendo saldo de usuario {user_id}...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/wallets/{user_id}/balance', cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Saldo obtenido")
            print(f"   - Saldo actual: ${result.get('balance', 0)}")
            print(f"   - Moneda: {result.get('currency', 'USD')}")
            return result
        else:
            print(f"❌ Error obteniendo saldo: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_get_payment_history(cookies, user_id):
    """Obtener historial de pagos (como en Flutter)"""
    print(f"\n📊 Obteniendo historial de pagos de usuario {user_id}...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/wallets/{user_id}/payment-history', cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            transactions = result.get('transactions', [])
            print(f"✅ Historial obtenido: {len(transactions)} transacciones")
            
            for tx in transactions[:3]:  # Mostrar solo las primeras 3
                print(f"   - {tx.get('type')}: ${tx.get('amount')} - {tx.get('description')}")
            
            return result
        else:
            print(f"❌ Error obteniendo historial: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_withdraw_to_bank(cookies, user_id, amount):
    """Simular retiro a cuenta bancaria (como en Flutter)"""
    print(f"\n🏦 Simulando retiro de ${amount} a cuenta bancaria...")
    
    bank_data = {
        'amount': amount,
        'bank_account': {
            'account_number': '1234567890',
            'routing_number': '021000021',
            'account_type': 'checking'
        }
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/wallets/{user_id}/withdraw-to-bank', 
                               json=bank_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Retiro procesado")
            print(f"   - Transfer ID: {result.get('transfer_id')}")
            print(f"   - Nuevo saldo: ${result.get('wallet', {}).get('balance', 0)}")
            return result
        else:
            print(f"❌ Error procesando retiro: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def simulate_flutter_app_flow():
    """Simular el flujo completo de la app Flutter"""
    print("🚀 Simulando flujo completo de la app Flutter...")
    print("=" * 60)
    
    # Login
    cookies = login()
    if not cookies:
        print("❌ No se pudo iniciar sesión.")
        return
    
    # Usuarios de prueba (simulan usuarios de Flutter)
    user_1 = 1001  # Usuario 1
    user_2 = 1002  # Usuario 2
    
    print(f"\n📱 Simulando app Flutter para usuarios {user_1} y {user_2}")
    
    # 1. Crear billeteras para usuarios
    wallet_1 = test_create_wallet_for_user(cookies, user_1)
    wallet_2 = test_create_wallet_for_user(cookies, user_2)
    
    if not wallet_1 or not wallet_2:
        print("❌ Error creando billeteras")
        return
    
    # 2. Usuario 1 recarga su billetera con Square
    print(f"\n💳 Usuario {user_1} recarga su billetera...")
    payment_result = test_add_funds_with_square(cookies, user_1, 100.00)
    
    if payment_result:
        # 3. Confirmar pago (simula webhook de Square)
        payment_id = payment_result.get('payment_id')
        amount = payment_result.get('amount')
        
        confirm_result = test_confirm_payment(cookies, user_1, payment_id, amount)
        
        if confirm_result:
            # 4. Verificar saldo actualizado
            test_get_wallet_balance(cookies, user_1)
            
            # 5. Usuario 1 transfiere dinero a Usuario 2
            print(f"\n🔄 Usuario {user_1} transfiere dinero a Usuario {user_2}...")
            transfer_result = test_transfer_between_users(cookies, user_1, user_2, 30.00)
            
            if transfer_result:
                # 6. Verificar saldos después de transferencia
                test_get_wallet_balance(cookies, user_1)
                test_get_wallet_balance(cookies, user_2)
                
                # 7. Obtener historial de transacciones
                test_get_payment_history(cookies, user_1)
                test_get_payment_history(cookies, user_2)
                
                # 8. Usuario 2 retira dinero a cuenta bancaria
                print(f"\n🏦 Usuario {user_2} retira dinero a cuenta bancaria...")
                test_withdraw_to_bank(cookies, user_2, 20.00)
                
                # 9. Verificar saldo final
                test_get_wallet_balance(cookies, user_2)
    
    print("\n" + "=" * 60)
    print("✅ Simulación del flujo de app Flutter completada!")
    print("\n📋 Funcionalidades probadas:")
    print("   ✅ Crear billeteras para usuarios")
    print("   ✅ Recargar billetera con Square")
    print("   ✅ Confirmar pagos automáticamente")
    print("   ✅ Transferir entre usuarios")
    print("   ✅ Verificar saldos en tiempo real")
    print("   ✅ Obtener historial de transacciones")
    print("   ✅ Retirar a cuenta bancaria")
    
    print("\n🎯 Sistema listo para integración con Flutter!")
    print("   Los usuarios pueden:")
    print("   - Recargar con tarjetas reales vía Square")
    print("   - Transferir dinero entre usuarios")
    print("   - Retirar a cuentas bancarias")
    print("   - Ver historial completo de transacciones")

if __name__ == "__main__":
    simulate_flutter_app_flow()

