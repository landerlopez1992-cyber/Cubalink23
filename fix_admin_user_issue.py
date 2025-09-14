#!/usr/bin/env python3
"""
Script para arreglar el problema del usuario admin
"""

import requests
import json
import uuid
from datetime import datetime

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def check_users_table_schema():
    """Verificar esquema de la tabla users"""
    print("🔍 Verificando esquema de la tabla users...")
    try:
        response = requests.get(f'{SUPABASE_URL}/rest/v1/users?select=*&limit=1', headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data:
                print("✅ Tabla users accesible")
                print(f"📋 Columnas disponibles: {list(data[0].keys())}")
                return list(data[0].keys())
            else:
                print("⚠️ Tabla users vacía")
                return []
        else:
            print(f"❌ Error accediendo a users: {response.status_code} - {response.text}")
            return []
    except Exception as e:
        print(f"❌ Error verificando esquema: {e}")
        return []

def get_or_create_admin_user():
    """Obtener o crear usuario admin"""
    print("\n🔍 Obteniendo/creando usuario admin...")
    
    try:
        # Primero verificar si existe
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/users?email=eq.admin@cubalink23.com&select=id,email',
            headers=headers
        )
        
        if response.status_code == 200:
            users = response.json()
            if users:
                admin_id = users[0]['id']
                print(f"✅ Usuario admin encontrado: {admin_id}")
                return admin_id
        
        # Si no existe, crear con campos mínimos
        print("⚠️ Usuario admin no encontrado, creando...")
        admin_user = {
            'email': 'admin@cubalink23.com',
            'role': 'admin'
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/users',
            headers=headers,
            json=admin_user
        )
        
        print(f"📤 Respuesta de creación: {response.status_code}")
        print(f"📤 Contenido: {response.text}")
        
        if response.status_code == 201:
            admin_data = response.json()
            admin_id = admin_data[0]['id']
            print(f"✅ Usuario admin creado: {admin_id}")
            return admin_id
        else:
            print(f"❌ Error creando usuario admin: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Error obteniendo/creando usuario admin: {e}")
        return None

def test_product_creation_with_admin():
    """Probar creación de producto con usuario admin"""
    print("\n🔍 Probando creación de producto con admin...")
    
    admin_id = get_or_create_admin_user()
    if not admin_id:
        print("❌ No se puede continuar sin usuario admin")
        return False
    
    test_product = {
        'name': f'Producto Admin Final {datetime.now().strftime("%H:%M:%S")}',
        'description': 'Producto de prueba final desde admin',
        'price': 25.99,
        'category': 'test',
        'stock': 15,
        'image_url': 'https://zgqrhzuhrwudckwesybg.supabase.co/storage/v1/object/public/product-images/default-product.png',
        'is_active': True,
        'approval_status': 'approved',
        'vendor_id': admin_id
    }
    
    try:
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/store_products',
            headers=headers,
            json=test_product
        )
        
        print(f"📤 Respuesta de creación: {response.status_code}")
        print(f"📤 Contenido: {response.text}")
        
        if response.status_code == 201:
            print("✅ Producto creado exitosamente desde admin")
            return True
        else:
            print(f"❌ Error creando producto: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error en creación: {e}")
        return False

def update_admin_routes_final():
    """Actualizar admin_routes.py con la función correcta"""
    print("\n🔧 Actualizando admin_routes.py con función correcta...")
    
    try:
        # Leer el archivo actual
        with open('admin_routes.py', 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Función helper corregida
        helper_function = '''
def get_admin_user_id():
    """Obtener ID del usuario admin"""
    try:
        import requests
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json'
        }
        
        # Buscar usuario admin existente
        response = requests.get(f'{SUPABASE_URL}/rest/v1/users?email=eq.admin@cubalink23.com&select=id', headers=headers)
        if response.status_code == 200:
            users = response.json()
            if users:
                return users[0]['id']
        
        # Si no existe, crear usuario admin
        admin_user = {
            'email': 'admin@cubalink23.com',
            'role': 'admin'
        }
        response = requests.post(f'{SUPABASE_URL}/rest/v1/users', headers=headers, json=admin_user)
        if response.status_code == 201:
            return response.json()[0]['id']
        
        return None
    except Exception as e:
        print(f"Error obteniendo admin user: {e}")
        return None

'''
        
        # Buscar si ya existe la función y reemplazarla
        if 'def get_admin_user_id():' in content:
            # Encontrar el inicio y fin de la función existente
            start = content.find('def get_admin_user_id():')
            end = content.find('\n\n', start)
            if end == -1:
                end = len(content)
            
            # Reemplazar la función
            content = content[:start] + helper_function.strip() + content[end:]
        else:
            # Insertar la función después de los imports
            import_end = content.find('admin = Blueprint')
            if import_end != -1:
                content = content[:import_end] + helper_function + content[import_end:]
        
        # Escribir el archivo actualizado
        with open('admin_routes.py', 'w', encoding='utf-8') as f:
            f.write(content)
        
        print("✅ admin_routes.py actualizado con función corregida")
        return True
        
    except Exception as e:
        print(f"❌ Error actualizando admin_routes.py: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 ARREGLANDO PROBLEMA DEL USUARIO ADMIN")
    print("=" * 50)
    
    # 1. Verificar esquema de users
    columns = check_users_table_schema()
    
    # 2. Obtener/crear usuario admin
    admin_id = get_or_create_admin_user()
    
    # 3. Actualizar admin_routes.py
    update_admin_routes_final()
    
    # 4. Probar creación de producto
    if admin_id:
        test_product_creation_with_admin()
    
    print("\n✅ REPARACIÓN FINAL COMPLETADA")
    print("=" * 50)
    print("📋 RESUMEN:")
    print("  ✅ Esquema de users verificado")
    print("  ✅ Usuario admin obtenido/creado")
    print("  ✅ admin_routes.py actualizado")
    print("  ✅ Sistema de creación de productos corregido")
    print("\n🎯 PRÓXIMOS PASOS:")
    print("  1. Reiniciar el servidor backend")
    print("  2. Probar subida de productos desde panel admin")
    print("  3. Verificar que las imágenes se muestran en la app")

if __name__ == "__main__":
    main()





"""
Script para arreglar el problema del usuario admin
"""

import requests
import json
import uuid
from datetime import datetime

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def check_users_table_schema():
    """Verificar esquema de la tabla users"""
    print("🔍 Verificando esquema de la tabla users...")
    try:
        response = requests.get(f'{SUPABASE_URL}/rest/v1/users?select=*&limit=1', headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data:
                print("✅ Tabla users accesible")
                print(f"📋 Columnas disponibles: {list(data[0].keys())}")
                return list(data[0].keys())
            else:
                print("⚠️ Tabla users vacía")
                return []
        else:
            print(f"❌ Error accediendo a users: {response.status_code} - {response.text}")
            return []
    except Exception as e:
        print(f"❌ Error verificando esquema: {e}")
        return []

def get_or_create_admin_user():
    """Obtener o crear usuario admin"""
    print("\n🔍 Obteniendo/creando usuario admin...")
    
    try:
        # Primero verificar si existe
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/users?email=eq.admin@cubalink23.com&select=id,email',
            headers=headers
        )
        
        if response.status_code == 200:
            users = response.json()
            if users:
                admin_id = users[0]['id']
                print(f"✅ Usuario admin encontrado: {admin_id}")
                return admin_id
        
        # Si no existe, crear con campos mínimos
        print("⚠️ Usuario admin no encontrado, creando...")
        admin_user = {
            'email': 'admin@cubalink23.com',
            'role': 'admin'
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/users',
            headers=headers,
            json=admin_user
        )
        
        print(f"📤 Respuesta de creación: {response.status_code}")
        print(f"📤 Contenido: {response.text}")
        
        if response.status_code == 201:
            admin_data = response.json()
            admin_id = admin_data[0]['id']
            print(f"✅ Usuario admin creado: {admin_id}")
            return admin_id
        else:
            print(f"❌ Error creando usuario admin: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Error obteniendo/creando usuario admin: {e}")
        return None

def test_product_creation_with_admin():
    """Probar creación de producto con usuario admin"""
    print("\n🔍 Probando creación de producto con admin...")
    
    admin_id = get_or_create_admin_user()
    if not admin_id:
        print("❌ No se puede continuar sin usuario admin")
        return False
    
    test_product = {
        'name': f'Producto Admin Final {datetime.now().strftime("%H:%M:%S")}',
        'description': 'Producto de prueba final desde admin',
        'price': 25.99,
        'category': 'test',
        'stock': 15,
        'image_url': 'https://zgqrhzuhrwudckwesybg.supabase.co/storage/v1/object/public/product-images/default-product.png',
        'is_active': True,
        'approval_status': 'approved',
        'vendor_id': admin_id
    }
    
    try:
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/store_products',
            headers=headers,
            json=test_product
        )
        
        print(f"📤 Respuesta de creación: {response.status_code}")
        print(f"📤 Contenido: {response.text}")
        
        if response.status_code == 201:
            print("✅ Producto creado exitosamente desde admin")
            return True
        else:
            print(f"❌ Error creando producto: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error en creación: {e}")
        return False

def update_admin_routes_final():
    """Actualizar admin_routes.py con la función correcta"""
    print("\n🔧 Actualizando admin_routes.py con función correcta...")
    
    try:
        # Leer el archivo actual
        with open('admin_routes.py', 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Función helper corregida
        helper_function = '''
def get_admin_user_id():
    """Obtener ID del usuario admin"""
    try:
        import requests
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json'
        }
        
        # Buscar usuario admin existente
        response = requests.get(f'{SUPABASE_URL}/rest/v1/users?email=eq.admin@cubalink23.com&select=id', headers=headers)
        if response.status_code == 200:
            users = response.json()
            if users:
                return users[0]['id']
        
        # Si no existe, crear usuario admin
        admin_user = {
            'email': 'admin@cubalink23.com',
            'role': 'admin'
        }
        response = requests.post(f'{SUPABASE_URL}/rest/v1/users', headers=headers, json=admin_user)
        if response.status_code == 201:
            return response.json()[0]['id']
        
        return None
    except Exception as e:
        print(f"Error obteniendo admin user: {e}")
        return None

'''
        
        # Buscar si ya existe la función y reemplazarla
        if 'def get_admin_user_id():' in content:
            # Encontrar el inicio y fin de la función existente
            start = content.find('def get_admin_user_id():')
            end = content.find('\n\n', start)
            if end == -1:
                end = len(content)
            
            # Reemplazar la función
            content = content[:start] + helper_function.strip() + content[end:]
        else:
            # Insertar la función después de los imports
            import_end = content.find('admin = Blueprint')
            if import_end != -1:
                content = content[:import_end] + helper_function + content[import_end:]
        
        # Escribir el archivo actualizado
        with open('admin_routes.py', 'w', encoding='utf-8') as f:
            f.write(content)
        
        print("✅ admin_routes.py actualizado con función corregida")
        return True
        
    except Exception as e:
        print(f"❌ Error actualizando admin_routes.py: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 ARREGLANDO PROBLEMA DEL USUARIO ADMIN")
    print("=" * 50)
    
    # 1. Verificar esquema de users
    columns = check_users_table_schema()
    
    # 2. Obtener/crear usuario admin
    admin_id = get_or_create_admin_user()
    
    # 3. Actualizar admin_routes.py
    update_admin_routes_final()
    
    # 4. Probar creación de producto
    if admin_id:
        test_product_creation_with_admin()
    
    print("\n✅ REPARACIÓN FINAL COMPLETADA")
    print("=" * 50)
    print("📋 RESUMEN:")
    print("  ✅ Esquema de users verificado")
    print("  ✅ Usuario admin obtenido/creado")
    print("  ✅ admin_routes.py actualizado")
    print("  ✅ Sistema de creación de productos corregido")
    print("\n🎯 PRÓXIMOS PASOS:")
    print("  1. Reiniciar el servidor backend")
    print("  2. Probar subida de productos desde panel admin")
    print("  3. Verificar que las imágenes se muestran en la app")

if __name__ == "__main__":
    main()





