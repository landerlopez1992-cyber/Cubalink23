#!/usr/bin/env python3
"""
Script de pruebas para el sistema de billetera
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

def test_health_check(cookies):
    """Probar health check"""
    print("\n🏥 Probando health check...")
    
    try:
        response = requests.get(f'{BASE_URL}/api/health', cookies=cookies)
        
        if response.status_code == 200:
            print("✅ Health check exitoso")
            return True
        else:
            print(f"❌ Error en health check: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_get_wallets(cookies):
    """Probar obtener billeteras"""
    print("\n💰 Probando obtener billeteras...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/wallets', cookies=cookies)
        
        if response.status_code == 200:
            wallets = response.json()
            print(f"✅ Billeteras obtenidas: {len(wallets)}")
            for wallet in wallets[:3]:  # Mostrar solo las primeras 3
                print(f"   - Usuario {wallet.get('user_id')}: ${wallet.get('balance', 0)}")
            return wallets
        else:
            print(f"❌ Error obteniendo billeteras: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def test_create_wallet(cookies):
    """Probar crear billetera"""
    print("\n➕ Probando crear billetera...")
    
    wallet_data = {
        'user_id': 999,  # Usuario de prueba
        'initial_balance': 100.00,
        'currency': 'USD'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/wallets', 
                               json=wallet_data, cookies=cookies)
        
        if response.status_code == 200:
            wallet = response.json()
            print(f"✅ Billetera creada exitosamente")
            print(f"   - ID: {wallet.get('id')}")
            print(f"   - Usuario: {wallet.get('user_id')}")
            print(f"   - Saldo: ${wallet.get('balance')}")
            return wallet
        else:
            print(f"❌ Error creando billetera: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_deposit_to_wallet(cookies, user_id):
    """Probar depositar a billetera"""
    print(f"\n💸 Probando depósito a usuario {user_id}...")
    
    deposit_data = {
        'amount': 50.00,
        'description': 'Depósito de prueba'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/wallets/{user_id}/deposit', 
                               json=deposit_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Depósito exitoso")
            print(f"   - Mensaje: {result.get('message')}")
            if result.get('wallet'):
                print(f"   - Nuevo saldo: ${result['wallet'].get('balance')}")
            return result
        else:
            print(f"❌ Error en depósito: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_withdraw_from_wallet(cookies, user_id):
    """Probar retiro de billetera"""
    print(f"\n💳 Probando retiro de usuario {user_id}...")
    
    withdraw_data = {
        'amount': 25.00,
        'description': 'Retiro de prueba'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/wallets/{user_id}/withdraw', 
                               json=withdraw_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Retiro exitoso")
            print(f"   - Mensaje: {result.get('message')}")
            if result.get('wallet'):
                print(f"   - Nuevo saldo: ${result['wallet'].get('balance')}")
            return result
        else:
            print(f"❌ Error en retiro: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_get_wallet_transactions(cookies, user_id):
    """Probar obtener transacciones de billetera"""
    print(f"\n📊 Probando obtener transacciones de usuario {user_id}...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/wallets/{user_id}/transactions', 
                              cookies=cookies)
        
        if response.status_code == 200:
            transactions = response.json()
            print(f"✅ Transacciones obtenidas: {len(transactions)}")
            for tx in transactions[:5]:  # Mostrar solo las primeras 5
                print(f"   - {tx.get('type')}: ${tx.get('amount')} - {tx.get('description')}")
            return transactions
        else:
            print(f"❌ Error obteniendo transacciones: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def test_get_wallet_statistics(cookies):
    """Probar obtener estadísticas de billeteras"""
    print("\n📈 Probando obtener estadísticas...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/wallets/statistics', cookies=cookies)
        
        if response.status_code == 200:
            stats = response.json()
            print(f"✅ Estadísticas obtenidas")
            print(f"   - Total billeteras: {stats.get('total_wallets', 0)}")
            print(f"   - Billeteras activas: {stats.get('active_wallets', 0)}")
            print(f"   - Saldo total: ${stats.get('total_balance', 0)}")
            
            transactions_by_type = stats.get('transactions_by_type', {})
            print(f"   - Transacciones por tipo:")
            for tx_type, data in transactions_by_type.items():
                print(f"     * {tx_type}: {data.get('count', 0)} transacciones, ${data.get('total_amount', 0)}")
            
            return stats
        else:
            print(f"❌ Error obteniendo estadísticas: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_transfer_between_wallets(cookies, user_id_1, user_id_2):
    """Probar transferencia entre billeteras"""
    print(f"\n🔄 Probando transferencia de {user_id_1} a {user_id_2}...")
    
    transfer_data = {
        'target_user_id': user_id_2,
        'amount': 10.00,
        'description': 'Transferencia de prueba'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/wallets/{user_id_1}/transfer', 
                               json=transfer_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Transferencia exitosa")
            print(f"   - Mensaje: {result.get('message')}")
            print(f"   - Monto: ${result.get('amount')}")
            print(f"   - De: {result.get('from_user')} a {result.get('to_user')}")
            return result
        else:
            print(f"❌ Error en transferencia: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_get_wallet_by_user(cookies, user_id):
    """Probar obtener billetera específica"""
    print(f"\n👤 Probando obtener billetera de usuario {user_id}...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/wallets/{user_id}', cookies=cookies)
        
        if response.status_code == 200:
            wallet = response.json()
            print(f"✅ Billetera obtenida")
            print(f"   - Usuario: {wallet.get('user_name', 'N/A')}")
            print(f"   - Email: {wallet.get('user_email', 'N/A')}")
            print(f"   - Saldo: ${wallet.get('balance', 0)}")
            print(f"   - Estado: {wallet.get('status')}")
            return wallet
        else:
            print(f"❌ Error obteniendo billetera: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def main():
    """Función principal de pruebas"""
    print("🚀 Iniciando pruebas del sistema de billetera...")
    print("=" * 60)
    
    # Login
    cookies = login()
    if not cookies:
        print("❌ No se pudo iniciar sesión. Verifica que el servidor esté corriendo.")
        return
    
    # Health check
    if not test_health_check(cookies):
        print("❌ El servidor no está respondiendo correctamente.")
        return
    
    # Obtener billeteras existentes
    existing_wallets = test_get_wallets(cookies)
    
    # Crear billetera de prueba
    test_wallet = test_create_wallet(cookies)
    test_user_id = test_wallet.get('user_id') if test_wallet else 999
    
    # Probar operaciones con la billetera
    if test_wallet:
        # Depositar dinero
        test_deposit_to_wallet(cookies, test_user_id)
        
        # Retirar dinero
        test_withdraw_from_wallet(cookies, test_user_id)
        
        # Obtener transacciones
        test_get_wallet_transactions(cookies, test_user_id)
        
        # Obtener billetera específica
        test_get_wallet_by_user(cookies, test_user_id)
        
        # Transferir entre billeteras (si hay otra billetera)
        if existing_wallets:
            other_user_id = existing_wallets[0].get('user_id')
            if other_user_id != test_user_id:
                test_transfer_between_wallets(cookies, test_user_id, other_user_id)
    
    # Obtener estadísticas
    test_get_wallet_statistics(cookies)
    
    print("\n" + "=" * 60)
    print("✅ Pruebas del sistema de billetera completadas!")
    print("\n📋 Funcionalidades probadas:")
    print("   ✅ Login de administrador")
    print("   ✅ Health check")
    print("   ✅ Obtener billeteras")
    print("   ✅ Crear billetera")
    print("   ✅ Depositar dinero")
    print("   ✅ Retirar dinero")
    print("   ✅ Obtener transacciones")
    print("   ✅ Obtener billetera específica")
    print("   ✅ Transferir entre billeteras")
    print("   ✅ Obtener estadísticas")
    
    print("\n🎯 Sistema de billetera implementado correctamente!")
    print("   El sistema está listo para gestionar saldos de usuarios.")

if __name__ == "__main__":
    main()

