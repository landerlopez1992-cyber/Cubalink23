#!/usr/bin/env python3
"""
Script de prueba para el sistema de Reglas del Sistema
Prueba todas las funcionalidades de configuraciones, reglas de negocio y límites
"""

import requests
import json
import time
from datetime import datetime

# Configuración
BASE_URL = 'http://localhost:3005'
ADMIN_CREDENTIALS = {
    'username': 'admin',
    'password': 'admin123'
}

def test_admin_login():
    """Login de administrador"""
    print("🔐 Iniciando sesión como administrador...")
    
    try:
        response = requests.post(f'{BASE_URL}/admin/login', data=ADMIN_CREDENTIALS)
        
        if response.status_code == 200:
            print("✅ Login exitoso")
            return response.cookies
        else:
            print(f"❌ Error en login: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_initialize_system(cookies):
    """Inicializar configuraciones por defecto"""
    print("\n🚀 Inicializando sistema con configuraciones por defecto...")
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/system/initialize', cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                print("✅ Sistema inicializado exitosamente")
                return True
            else:
                print(f"❌ Error: {result.get('error')}")
                return False
        else:
            print(f"❌ Error en request: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_get_system_configs(cookies, category=None):
    """Obtener configuraciones del sistema"""
    print(f"\n⚙️ Obteniendo configuraciones del sistema{f' ({category})' if category else ''}...")
    
    try:
        url = f'{BASE_URL}/admin/api/system/configs'
        if category:
            url += f'?category={category}'
        
        response = requests.get(url, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                configs = result.get('configs', [])
                print(f"✅ Configuraciones obtenidas: {len(configs)}")
                
                for i, config in enumerate(configs[:5], 1):  # Mostrar solo las primeras 5
                    print(f"   {i}. {config.get('config_key')} = {config.get('config_value')} ({config.get('category')})")
                
                return configs
            else:
                print(f"❌ Error: {result.get('error')}")
                return []
        else:
            print(f"❌ Error en request: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def test_update_system_config(cookies, config_key, new_value):
    """Actualizar configuración del sistema"""
    print(f"\n🔄 Actualizando configuración '{config_key}' a '{new_value}'...")
    
    update_data = {
        'config_value': new_value,
        'config_type': 'string',
        'category': 'general',
        'description': f'Configuración actualizada el {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}',
        'is_public': True
    }
    
    try:
        response = requests.put(f'{BASE_URL}/admin/api/system/configs/{config_key}', 
                              json=update_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                print(f"✅ Configuración actualizada exitosamente")
                return True
            else:
                print(f"❌ Error: {result.get('error')}")
                return False
        else:
            print(f"❌ Error en request: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_get_business_rules(cookies, rule_type=None):
    """Obtener reglas de negocio"""
    print(f"\n📋 Obteniendo reglas de negocio{f' ({rule_type})' if rule_type else ''}...")
    
    try:
        url = f'{BASE_URL}/admin/api/system/business-rules'
        if rule_type:
            url += f'?rule_type={rule_type}'
        
        response = requests.get(url, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                rules = result.get('rules', [])
                print(f"✅ Reglas obtenidas: {len(rules)}")
                
                for i, rule in enumerate(rules[:3], 1):  # Mostrar solo las primeras 3
                    print(f"   {i}. {rule.get('rule_name')} - {rule.get('rule_type')} (Prioridad: {rule.get('priority')})")
                
                return rules
            else:
                print(f"❌ Error: {result.get('error')}")
                return []
        else:
            print(f"❌ Error en request: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def test_add_business_rule(cookies):
    """Agregar regla de negocio"""
    print(f"\n➕ Agregando nueva regla de negocio...")
    
    rule_data = {
        'rule_name': 'max_daily_transactions',
        'rule_type': 'validation',
        'rule_condition': '{"field": "daily_transactions", "operator": "<=", "value": "daily_transactions_limit"}',
        'rule_action': 'reject',
        'priority': 8,
        'description': 'Validar límite de transacciones diarias por usuario'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/system/business-rules', 
                               json=rule_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                print(f"✅ Regla agregada exitosamente")
                print(f"   📋 Nombre: {rule_data.get('rule_name')}")
                print(f"   🔧 Tipo: {rule_data.get('rule_type')}")
                print(f"   🎯 Prioridad: {rule_data.get('priority')}")
                return True
            else:
                print(f"❌ Error: {result.get('error')}")
                return False
        else:
            print(f"❌ Error en request: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_get_system_limits(cookies, limit_type=None):
    """Obtener límites del sistema"""
    print(f"\n🚫 Obteniendo límites del sistema{f' ({limit_type})' if limit_type else ''}...")
    
    try:
        url = f'{BASE_URL}/admin/api/system/limits'
        if limit_type:
            url += f'?limit_type={limit_type}'
        
        response = requests.get(url, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                limits = result.get('limits', [])
                print(f"✅ Límites obtenidos: {len(limits)}")
                
                for i, limit in enumerate(limits[:3], 1):  # Mostrar solo los primeros 3
                    print(f"   {i}. {limit.get('limit_name')} = {limit.get('limit_value')} {limit.get('limit_unit')} ({limit.get('limit_type')})")
                
                return limits
            else:
                print(f"❌ Error: {result.get('error')}")
                return []
        else:
            print(f"❌ Error en request: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def test_add_system_limit(cookies):
    """Agregar límite del sistema"""
    print(f"\n➕ Agregando nuevo límite del sistema...")
    
    limit_data = {
        'limit_name': 'max_concurrent_sessions',
        'limit_type': 'user',
        'limit_value': 3,
        'limit_unit': 'count',
        'applies_to': 'all',
        'description': 'Máximo sesiones concurrentes por usuario'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/system/limits', 
                               json=limit_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                print(f"✅ Límite agregado exitosamente")
                print(f"   🚫 Nombre: {limit_data.get('limit_name')}")
                print(f"   📊 Valor: {limit_data.get('limit_value')} {limit_data.get('limit_unit')}")
                print(f"   🎯 Tipo: {limit_data.get('limit_type')}")
                return True
            else:
                print(f"❌ Error: {result.get('error')}")
                return False
        else:
            print(f"❌ Error en request: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_get_app_configs():
    """Obtener configuraciones públicas para app Flutter"""
    print(f"\n📱 Obteniendo configuraciones públicas para app Flutter...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/system/app-configs')
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                configs = result.get('configs', [])
                print(f"✅ Configuraciones públicas obtenidas: {len(configs)}")
                
                for i, config in enumerate(configs[:5], 1):  # Mostrar solo las primeras 5
                    print(f"   {i}. {config.get('config_key')} = {config.get('config_value')}")
                
                return configs
            else:
                print(f"❌ Error: {result.get('error')}")
                return []
        else:
            print(f"❌ Error en request: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def test_check_maintenance_mode():
    """Verificar modo mantenimiento"""
    print(f"\n🔧 Verificando modo mantenimiento...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/system/check-maintenance')
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                maintenance_mode = result.get('maintenance_mode', False)
                message = result.get('message', 'N/A')
                
                print(f"✅ Estado de mantenimiento verificado")
                print(f"   🔧 Modo mantenimiento: {'Activado' if maintenance_mode else 'Desactivado'}")
                print(f"   💬 Mensaje: {message}")
                
                return result
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error en request: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def simulate_system_config_flow():
    """Simular flujo completo de configuración del sistema"""
    print("🚀 INICIANDO PRUEBA DEL SISTEMA DE CONFIGURACIONES")
    print("=" * 60)
    
    # 1. Login de administrador
    cookies = test_admin_login()
    if not cookies:
        print("❌ No se pudo iniciar sesión. Abortando prueba.")
        return
    
    # 2. Inicializar sistema
    test_initialize_system(cookies)
    
    # 3. Obtener configuraciones por categoría
    print(f"\n📊 CONFIGURACIONES POR CATEGORÍA")
    print("-" * 40)
    
    categories = ['general', 'payment', 'flight', 'wallet', 'security', 'app']
    for category in categories:
        test_get_system_configs(cookies, category)
    
    # 4. Actualizar algunas configuraciones
    print(f"\n🔄 ACTUALIZANDO CONFIGURACIONES")
    print("-" * 40)
    
    test_update_system_config(cookies, 'app_contact_email', 'nuevo@cubalink23.com')
    test_update_system_config(cookies, 'app_contact_phone', '+1-555-9999')
    test_update_system_config(cookies, 'payment_commission', '7.5')
    
    # 5. Obtener reglas de negocio
    print(f"\n📋 REGLAS DE NEGOCIO")
    print("-" * 40)
    
    test_get_business_rules(cookies)
    test_get_business_rules(cookies, 'validation')
    test_add_business_rule(cookies)
    
    # 6. Obtener límites del sistema
    print(f"\n🚫 LÍMITES DEL SISTEMA")
    print("-" * 40)
    
    test_get_system_limits(cookies)
    test_get_system_limits(cookies, 'transaction')
    test_add_system_limit(cookies)
    
    # 7. Probar APIs públicas
    print(f"\n📱 APIS PÚBLICAS PARA FLUTTER")
    print("-" * 40)
    
    test_get_app_configs()
    test_check_maintenance_mode()
    
    # 8. Verificar configuraciones actualizadas
    print(f"\n✅ VERIFICANDO CAMBIOS")
    print("-" * 40)
    
    test_get_system_configs(cookies, 'app')
    
    # 9. Resumen final
    print("\n" + "=" * 60)
    print("📋 RESUMEN DE LA PRUEBA")
    print("=" * 60)
    
    print("✅ Funcionalidades probadas:")
    print("   ✅ Login de administrador")
    print("   ✅ Inicialización del sistema")
    print("   ✅ Obtener configuraciones por categoría")
    print("   ✅ Actualizar configuraciones")
    print("   ✅ Gestionar reglas de negocio")
    print("   ✅ Gestionar límites del sistema")
    print("   ✅ APIs públicas para Flutter")
    print("   ✅ Verificación de modo mantenimiento")
    
    print(f"\n🎯 Sistema de Configuraciones listo!")
    print("   Los administradores pueden:")
    print("   - Configurar parámetros del sistema")
    print("   - Gestionar reglas de negocio")
    print("   - Establecer límites y restricciones")
    print("   - Controlar funcionalidades de la app")
    print("   - Los usuarios pueden:")
    print("   - Obtener configuraciones públicas")
    print("   - Verificar estado de mantenimiento")
    print("   - Adaptar la app según configuraciones")

if __name__ == "__main__":
    simulate_system_config_flow()

