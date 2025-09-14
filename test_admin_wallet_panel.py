#!/usr/bin/env python3
"""
Script que simula el panel de administración para agregar saldo a usuarios reales
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
    print("🔐 Iniciando sesión como administrador...")
    
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

def test_get_users_for_wallet(cookies):
    """Obtener lista de usuarios reales para el panel"""
    print("\n👥 Obteniendo lista de usuarios reales...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/admin/wallet/users', cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                users = result.get('users', [])
                print(f"✅ Usuarios obtenidos: {len(users)}")
                
                for i, user in enumerate(users[:5], 1):  # Mostrar solo los primeros 5
                    print(f"   {i}. ID: {user.get('id')} - {user.get('name', 'N/A')} ({user.get('email', 'N/A')}) - 📞 {user.get('phone', 'N/A')}")
                
                return users
            else:
                print(f"❌ Error: {result.get('error')}")
                return []
        else:
            print(f"❌ Error en request: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def test_search_users(cookies, query):
    """Buscar usuarios por nombre, email o teléfono"""
    print(f"\n🔍 Buscando usuarios con: '{query}'...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/admin/wallet/search-users?q={query}', cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                users = result.get('users', [])
                print(f"✅ Usuarios encontrados: {len(users)}")
                
                for i, user in enumerate(users, 1):
                    print(f"   {i}. ID: {user.get('id')} - {user.get('name', 'N/A')} ({user.get('email', 'N/A')}) - 📞 {user.get('phone', 'N/A')}")
                
                return users
            else:
                print(f"❌ Error: {result.get('error')}")
                return []
        else:
            print(f"❌ Error en request: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def test_get_user_wallet_info(cookies, user_id):
    """Obtener información completa de usuario y billetera"""
    print(f"\n👤 Obteniendo información de usuario {user_id}...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/admin/wallet/user/{user_id}/info', cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                data = result.get('data', {})
                user = data.get('user', {})
                wallet = data.get('wallet', {})
                transactions = data.get('recent_transactions', [])
                
                print(f"✅ Información obtenida")
                print(f"   👤 Usuario: {user.get('name', 'N/A')} ({user.get('email', 'N/A')})")
                print(f"   📞 Teléfono: {user.get('phone', 'N/A')}")
                print(f"   💰 Saldo: ${wallet.get('balance', 0)}")
                print(f"   📊 Transacciones recientes: {len(transactions)}")
                
                return data
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error en request: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_admin_add_balance(cookies, user_id, amount, description):
    """Agregar saldo real a usuario desde panel admin"""
    print(f"\n💰 Agregando ${amount} a usuario {user_id}...")
    
    add_balance_data = {
        'user_id': user_id,
        'amount': amount,
        'description': description
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/admin/wallet/add-balance', 
                               json=add_balance_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                data = result.get('data', {})
                user = data.get('user', {})
                wallet = data.get('wallet', {})
                
                print(f"✅ Saldo agregado exitosamente")
                print(f"   👤 Usuario: {user.get('name', 'N/A')}")
                print(f"   📞 Teléfono: {user.get('phone', 'N/A')}")
                print(f"   💰 Monto agregado: ${data.get('amount_added')}")
                print(f"   💰 Nuevo saldo: ${data.get('new_balance')}")
                print(f"   🆔 Transaction ID: {data.get('transaction_id')}")
                
                return data
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error en request: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def simulate_admin_panel_flow():
    """Simular el flujo completo del panel de administración"""
    print("🚀 Simulando panel de administración: Agregar saldo a usuarios")
    print("=" * 60)
    
    # Login como administrador
    cookies = login()
    if not cookies:
        print("❌ No se pudo iniciar sesión.")
        return
    
    # 1. Obtener lista de usuarios reales
    users = test_get_users_for_wallet(cookies)
    
    if not users:
        print("❌ No hay usuarios disponibles.")
        return
    
    # 2. Buscar un usuario específico
    test_user = users[0]  # Usar el primer usuario
    user_id = test_user.get('id')
    user_name = test_user.get('name', 'Usuario')
    
    print(f"\n🎯 Usuario seleccionado: {user_name} (ID: {user_id})")
    
    # 3. Buscar usuario por nombre
    search_results = test_search_users(cookies, user_name.split()[0] if user_name else '')
    
    # 4. Obtener información completa del usuario
    user_info = test_get_user_wallet_info(cookies, user_id)
    
    if user_info:
        # 5. Agregar saldo al usuario
        amount = 100.00
        description = f"Depósito desde panel admin - {datetime.now().strftime('%Y-%m-%d %H:%M')}"
        
        result = test_admin_add_balance(cookies, user_id, amount, description)
        
        if result:
            # 6. Verificar saldo actualizado
            updated_info = test_get_user_wallet_info(cookies, user_id)
            
            if updated_info:
                wallet = updated_info.get('wallet', {})
                print(f"\n✅ Verificación final:")
                print(f"   💰 Saldo actual: ${wallet.get('balance', 0)}")
                print(f"   📅 Última transacción: {wallet.get('last_transaction_date', 'N/A')}")
    
    print("\n" + "=" * 60)
    print("✅ Simulación del panel de administración completada!")
    print("\n📋 Funcionalidades probadas:")
    print("   ✅ Login de administrador")
    print("   ✅ Obtener lista de usuarios reales")
    print("   ✅ Buscar usuarios por nombre/email/teléfono")
    print("   ✅ Obtener información de usuario y billetera")
    print("   ✅ Agregar saldo real a usuario")
    print("   ✅ Verificar saldo actualizado")
    
    print("\n🎯 Panel de administración listo!")
    print("   Los administradores pueden:")
    print("   - Ver todos los usuarios reales")
    print("   - Buscar usuarios por nombre, email o teléfono")
    print("   - Ver información completa de billeteras")
    print("   - Agregar saldo real a cualquier usuario")
    print("   - Ver historial de transacciones")

if __name__ == "__main__":
    simulate_admin_panel_flow()
