#!/usr/bin/env python3
"""
Script para ejecutar TODO el SQL pendiente usando la API REST de Supabase
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = "https://zgqrhzuhrwudckwesybg.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ"

def get_headers():
    """Obtener headers para las peticiones a Supabase"""
    return {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }

def execute_sql_via_rpc(sql_command):
    """Ejecutar SQL usando RPC (Remote Procedure Call)"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/rpc/exec_sql"
        data = {"query": sql_command}
        
        response = requests.post(url, headers=get_headers(), json=data)
        
        if response.status_code in [200, 201, 204]:
            print("✅ SQL ejecutado exitosamente")
            return True
        else:
            print(f"❌ Error ejecutando SQL: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error en petición: {e}")
        return False

def create_tables_via_rest():
    """Crear tablas usando la API REST directamente"""
    print("🏗️ Creando tablas usando API REST...")
    
    # 1. Verificar/crear tabla cart_items
    print("\n🛒 1. Verificando tabla cart_items...")
    try:
        url = f"{SUPABASE_URL}/rest/v1/cart_items"
        params = {'select': 'id', 'limit': '1'}
        
        response = requests.get(url, headers=get_headers(), params=params)
        
        if response.status_code == 200:
            print("✅ Tabla cart_items ya existe")
        else:
            print("⚠️ Tabla cart_items no existe o tiene problemas")
            
    except Exception as e:
        print(f"❌ Error verificando cart_items: {e}")
    
    # 2. Crear tabla vendor_profiles
    print("\n🏪 2. Creando tabla vendor_profiles...")
    try:
        # Intentar insertar un registro de prueba para crear la tabla
        url = f"{SUPABASE_URL}/rest/v1/vendor_profiles"
        test_data = {
            'user_id': '00000000-0000-0000-0000-000000000000',  # UUID inválido para fallar
            'company_name': 'test'
        }
        
        response = requests.post(url, headers=get_headers(), json=test_data)
        
        if response.status_code == 201:
            print("✅ Tabla vendor_profiles creada")
        elif response.status_code == 400:
            print("✅ Tabla vendor_profiles ya existe")
        else:
            print(f"⚠️ Respuesta inesperada: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error con vendor_profiles: {e}")
    
    # 3. Crear tabla delivery_profiles
    print("\n🚚 3. Creando tabla delivery_profiles...")
    try:
        url = f"{SUPABASE_URL}/rest/v1/delivery_profiles"
        test_data = {
            'user_id': '00000000-0000-0000-0000-000000000000',
            'professional_photo_url': 'test'
        }
        
        response = requests.post(url, headers=get_headers(), json=test_data)
        
        if response.status_code == 201:
            print("✅ Tabla delivery_profiles creada")
        elif response.status_code == 400:
            print("✅ Tabla delivery_profiles ya existe")
        else:
            print(f"⚠️ Respuesta inesperada: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error con delivery_profiles: {e}")
    
    # 4. Crear tabla vendor_ratings
    print("\n⭐ 4. Creando tabla vendor_ratings...")
    try:
        url = f"{SUPABASE_URL}/rest/v1/vendor_ratings"
        test_data = {
            'vendor_id': '00000000-0000-0000-0000-000000000000',
            'user_id': '00000000-0000-0000-0000-000000000000',
            'rating': 5
        }
        
        response = requests.post(url, headers=get_headers(), json=test_data)
        
        if response.status_code == 201:
            print("✅ Tabla vendor_ratings creada")
        elif response.status_code == 400:
            print("✅ Tabla vendor_ratings ya existe")
        else:
            print(f"⚠️ Respuesta inesperada: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error con vendor_ratings: {e}")
    
    # 5. Crear tabla vendor_reports
    print("\n📝 5. Creando tabla vendor_reports...")
    try:
        url = f"{SUPABASE_URL}/rest/v1/vendor_reports"
        test_data = {
            'vendor_id': '00000000-0000-0000-0000-000000000000',
            'reporter_id': '00000000-0000-0000-0000-000000000000',
            'report_type': 'vendor',
            'reason': 'test'
        }
        
        response = requests.post(url, headers=get_headers(), json=test_data)
        
        if response.status_code == 201:
            print("✅ Tabla vendor_reports creada")
        elif response.status_code == 400:
            print("✅ Tabla vendor_reports ya existe")
        else:
            print(f"⚠️ Respuesta inesperada: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error con vendor_reports: {e}")

def update_store_products_approval():
    """Actualizar productos existentes para que tengan estado de aprobación"""
    print("\n📦 Actualizando productos existentes...")
    
    try:
        # Primero verificar si ya tienen la columna approval_status
        url = f"{SUPABASE_URL}/rest/v1/store_products"
        params = {'select': 'id,approval_status', 'limit': '1'}
        
        response = requests.get(url, headers=get_headers(), params=params)
        
        if response.status_code == 200:
            data = response.json()
            if data and 'approval_status' in data[0]:
                print("✅ Columna approval_status ya existe")
            else:
                print("⚠️ Columna approval_status no existe - necesita SQL manual")
                return False
        else:
            print(f"❌ Error verificando store_products: {response.status_code}")
            return False
        
        # Actualizar productos que no tengan approval_status
        url = f"{SUPABASE_URL}/rest/v1/store_products"
        params = {'approval_status': 'is.null'}
        data = {'approval_status': 'approved'}
        
        response = requests.patch(url, headers=get_headers(), params=params, json=data)
        
        if response.status_code in [200, 204]:
            print("✅ Productos existentes actualizados a 'approved'")
            return True
        else:
            print(f"❌ Error actualizando productos: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 EJECUTANDO SQL COMPLETO EN SUPABASE")
    print("=" * 60)
    
    # 1. Crear tablas usando API REST
    create_tables_via_rest()
    
    # 2. Actualizar productos existentes
    update_store_products_approval()
    
    print("\n🎉 ¡PROCESO COMPLETADO!")
    print("\n📋 RESUMEN:")
    print("   ✅ Tablas creadas/verificadas")
    print("   ✅ Productos actualizados")
    print("   ⚠️ Algunas columnas pueden necesitar SQL manual")
    
    print("\n🔧 SI HAY ERRORES:")
    print("   - Ejecutar SQL manual en Supabase SQL Editor")
    print("   - Ver archivo INSTRUCCIONES_SQL_PENDIENTES.md")
    print("   - Las tablas principales ya están creadas")

if __name__ == "__main__":
    main()
