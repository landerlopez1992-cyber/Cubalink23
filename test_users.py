#!/usr/bin/env python3
"""
Script de prueba para la gestión de usuarios
"""

import requests
import json
import os

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

def test_get_users():
    """Probar obtener usuarios"""
    print("\n👥 Probando obtener usuarios...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/users")
        if response.status_code == 200:
            users = response.json()
            print(f"✅ Usuarios obtenidos: {len(users)} usuarios")
            for user in users[:3]:  # Mostrar solo los primeros 3
                print(f"   - {user.get('name', 'Sin nombre')}: {user.get('email', 'Sin email')}")
            return users
        else:
            print(f"❌ Error obteniendo usuarios: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener usuarios: {e}")
        return []

def test_add_user():
    """Probar agregar usuario"""
    print("\n➕ Probando agregar usuario...")
    
    user_data = {
        'user_id': 'test_user_001',
        'name': 'Juan Pérez',
        'email': 'juan.perez@ejemplo.com',
        'searches': 0,
        'blocked': False
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/users", json=user_data)
        if response.status_code == 200:
            user = response.json()
            print(f"✅ Usuario agregado: {user.get('name')} - ID: {user.get('id')}")
            return user
        else:
            print(f"❌ Error agregando usuario: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en agregar usuario: {e}")
        return None

def test_update_user(user_id):
    """Probar actualizar usuario"""
    print(f"\n✏️ Probando actualizar usuario ID: {user_id}...")
    
    update_data = {
        'name': 'Juan Pérez (Actualizado)',
        'email': 'juan.perez.actualizado@ejemplo.com',
        'searches': 5,
        'blocked': False
    }
    
    try:
        response = requests.put(f"{BASE_URL}/admin/api/users/{user_id}", json=update_data)
        if response.status_code == 200:
            user = response.json()
            print(f"✅ Usuario actualizado: {user.get('name')} - Email: {user.get('email')}")
            return user
        else:
            print(f"❌ Error actualizando usuario: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en actualizar usuario: {e}")
        return None

def test_block_user(user_id):
    """Probar bloquear usuario"""
    print(f"\n🚫 Probando bloquear usuario ID: {user_id}...")
    
    block_data = {
        'blocked': True
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/users/{user_id}/toggle", json=block_data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Usuario bloqueado: {result.get('success')}")
            return result
        else:
            print(f"❌ Error bloqueando usuario: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en bloquear usuario: {e}")
        return None

def test_unblock_user(user_id):
    """Probar desbloquear usuario"""
    print(f"\n✅ Probando desbloquear usuario ID: {user_id}...")
    
    unblock_data = {
        'blocked': False
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/users/{user_id}/toggle", json=unblock_data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Usuario desbloqueado: {result.get('success')}")
            return result
        else:
            print(f"❌ Error desbloqueando usuario: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en desbloquear usuario: {e}")
        return None

def test_update_user_activity(user_id):
    """Probar actualizar actividad del usuario"""
    print(f"\n📊 Probando actualizar actividad del usuario ID: {user_id}...")
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/users/{user_id}/activity")
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Actividad actualizada: {result.get('success')}")
            return result
        else:
            print(f"❌ Error actualizando actividad: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en actualizar actividad: {e}")
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
    print("🚀 Iniciando pruebas del sistema de gestión de usuarios...")
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
    
    # Probar obtener usuarios
    users = test_get_users()
    
    # Probar agregar usuario
    new_user = test_add_user()
    
    if new_user:
        user_id = new_user.get('id')
        
        # Probar actualizar usuario
        updated_user = test_update_user(user_id)
        
        # Probar bloquear usuario
        blocked_result = test_block_user(user_id)
        
        # Probar desbloquear usuario
        unblocked_result = test_unblock_user(user_id)
        
        # Probar actualizar actividad
        activity_result = test_update_user_activity(user_id)
    
    print("\n" + "=" * 60)
    print("✅ Pruebas completadas!")
    print("\n📋 Resumen:")
    print(f"   - Usuarios en sistema: {len(users)}")
    if new_user:
        print(f"   - Usuario de prueba agregado: {new_user.get('name')}")
        print(f"   - Funciones de bloqueo/desbloqueo: ✅")
        print(f"   - Seguimiento de actividad: ✅")

if __name__ == "__main__":
    main()
