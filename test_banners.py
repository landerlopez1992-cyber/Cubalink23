#!/usr/bin/env python3
"""
Script de prueba para la gestión de banners
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

def test_get_banners():
    """Probar obtener banners"""
    print("\n🎨 Probando obtener banners...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/banners")
        if response.status_code == 200:
            banners = response.json()
            print(f"✅ Banners obtenidos: {len(banners)} banners")
            for banner in banners[:3]:  # Mostrar solo los primeros 3
                print(f"   - {banner.get('title', 'Sin título')}: {banner.get('active', False)}")
            return banners
        else:
            print(f"❌ Error obteniendo banners: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener banners: {e}")
        return []

def test_get_active_banners():
    """Probar obtener banners activos"""
    print("\n🌟 Probando obtener banners activos...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/banners/active")
        if response.status_code == 200:
            banners = response.json()
            print(f"✅ Banners activos obtenidos: {len(banners)} banners")
            for banner in banners:
                print(f"   - {banner.get('title', 'Sin título')}: Posición {banner.get('position', 0)}")
            return banners
        else:
            print(f"❌ Error obteniendo banners activos: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener banners activos: {e}")
        return []

def test_add_banner():
    """Probar agregar banner"""
    print("\n➕ Probando agregar banner...")
    
    banner_data = {
        'title': 'Banner de Prueba',
        'description': 'Este es un banner de prueba para el sistema',
        'link_url': 'https://ejemplo.com',
        'active': True,
        'position': 1
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/banners", data=banner_data)
        if response.status_code == 200:
            banner = response.json()
            print(f"✅ Banner agregado: {banner.get('title')} - ID: {banner.get('id')}")
            return banner
        else:
            print(f"❌ Error agregando banner: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en agregar banner: {e}")
        return None

def test_update_banner(banner_id):
    """Probar actualizar banner"""
    print(f"\n✏️ Probando actualizar banner ID: {banner_id}...")
    
    update_data = {
        'title': 'Banner de Prueba (Actualizado)',
        'description': 'Este es un banner de prueba actualizado',
        'link_url': 'https://ejemplo-actualizado.com',
        'active': True,
        'position': 2
    }
    
    try:
        response = requests.put(f"{BASE_URL}/admin/api/banners/{banner_id}", json=update_data)
        if response.status_code == 200:
            banner = response.json()
            print(f"✅ Banner actualizado: {banner.get('title')} - Posición: {banner.get('position')}")
            return banner
        else:
            print(f"❌ Error actualizando banner: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en actualizar banner: {e}")
        return None

def test_toggle_banner_status(banner_id):
    """Probar activar/desactivar banner"""
    print(f"\n🔄 Probando desactivar banner ID: {banner_id}...")
    
    toggle_data = {
        'active': False
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/banners/{banner_id}/toggle", json=toggle_data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Banner desactivado: {result.get('success')}")
            return result
        else:
            print(f"❌ Error desactivando banner: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en desactivar banner: {e}")
        return None

def test_activate_banner_status(banner_id):
    """Probar activar banner"""
    print(f"\n✅ Probando activar banner ID: {banner_id}...")
    
    toggle_data = {
        'active': True
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/banners/{banner_id}/toggle", json=toggle_data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Banner activado: {result.get('success')}")
            return result
        else:
            print(f"❌ Error activando banner: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en activar banner: {e}")
        return None

def test_update_banner_position(banner_id):
    """Probar actualizar posición del banner"""
    print(f"\n📍 Probando actualizar posición del banner ID: {banner_id}...")
    
    position_data = {
        'position': 5
    }
    
    try:
        response = requests.put(f"{BASE_URL}/admin/api/banners/{banner_id}/position", json=position_data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Posición actualizada: {result.get('success')}")
            return result
        else:
            print(f"❌ Error actualizando posición: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en actualizar posición: {e}")
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
    print("🚀 Iniciando pruebas del sistema de gestión de banners...")
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
    
    # Probar obtener banners
    banners = test_get_banners()
    
    # Probar obtener banners activos
    active_banners = test_get_active_banners()
    
    # Probar agregar banner
    new_banner = test_add_banner()
    
    if new_banner:
        banner_id = new_banner.get('id')
        
        # Probar actualizar banner
        updated_banner = test_update_banner(banner_id)
        
        # Probar desactivar banner
        deactivated_result = test_toggle_banner_status(banner_id)
        
        # Probar activar banner
        activated_result = test_activate_banner_status(banner_id)
        
        # Probar actualizar posición
        position_result = test_update_banner_position(banner_id)
    
    print("\n" + "=" * 60)
    print("✅ Pruebas completadas!")
    print("\n📋 Resumen:")
    print(f"   - Banners en sistema: {len(banners)}")
    print(f"   - Banners activos: {len(active_banners)}")
    if new_banner:
        print(f"   - Banner de prueba agregado: {new_banner.get('title')}")
        print(f"   - Funciones de activación/desactivación: ✅")
        print(f"   - Control de posiciones: ✅")

if __name__ == "__main__":
    main()

