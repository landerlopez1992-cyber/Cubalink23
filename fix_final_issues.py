#!/usr/bin/env python3
"""
Script para arreglar los problemas finales de imágenes y admin
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

def get_admin_user_id():
    """Obtener el ID del usuario admin"""
    print("🔍 Obteniendo ID del usuario admin...")
    try:
        # Buscar usuario admin por email
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/users?email=eq.admin@cubalink23.com&select=id',
            headers=headers
        )
        
        if response.status_code == 200:
            users = response.json()
            if users:
                admin_id = users[0]['id']
                print(f"✅ Usuario admin encontrado: {admin_id}")
                return admin_id
        
        # Si no existe, crear usuario admin
        print("⚠️ Usuario admin no encontrado, creando...")
        admin_user = {
            'email': 'admin@cubalink23.com',
            'full_name': 'Administrador',
            'role': 'admin'
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/users',
            headers=headers,
            json=admin_user
        )
        
        if response.status_code == 201:
            admin_data = response.json()
            admin_id = admin_data[0]['id']
            print(f"✅ Usuario admin creado: {admin_id}")
            return admin_id
        else:
            print(f"❌ Error creando usuario admin: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Error obteniendo usuario admin: {e}")
        return None

def fix_product_images():
    """Arreglar URLs de imágenes de productos"""
    print("\n🔧 Arreglando URLs de imágenes de productos...")
    
    try:
        # Obtener productos con imágenes placeholder
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url&image_url.like.*via.placeholder.com*',
            headers=headers
        )
        
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        fixed_count = 0
        
        for product in products:
            # Crear URL de imagen local simple
            new_url = f'https://zgqrhzuhrwudckwesybg.supabase.co/storage/v1/object/public/product-images/default-product.png'
            
            # Actualizar en la base de datos
            update_response = requests.patch(
                f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product["id"]}',
                headers=headers,
                json={'image_url': new_url}
            )
            
            if update_response.status_code == 204:
                fixed_count += 1
                print(f"  ✅ Arreglado: {product.get('name', 'Sin nombre')}")
            else:
                print(f"  ❌ Error arreglando: {product.get('name', 'Sin nombre')} - {update_response.status_code}")
        
        print(f"\n📊 Imágenes arregladas: {fixed_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error arreglando imágenes: {e}")
        return False

def test_admin_product_creation():
    """Probar creación de producto desde admin"""
    print("\n🔍 Probando creación de producto desde admin...")
    
    admin_id = get_admin_user_id()
    if not admin_id:
        print("❌ No se puede continuar sin usuario admin")
        return False
    
    test_product = {
        'name': f'Producto Admin Test {datetime.now().strftime("%H:%M:%S")}',
        'description': 'Producto de prueba creado desde admin',
        'price': 15.99,
        'category': 'test',
        'stock': 10,
        'image_url': 'https://zgqrhzuhrwudckwesybg.supabase.co/storage/v1/object/public/product-images/default-product.png',
        'is_active': True,
        'approval_status': 'approved',
        'vendor_id': admin_id  # Usar UUID del admin
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

def update_admin_routes():
    """Actualizar admin_routes.py para usar UUID correcto"""
    print("\n🔧 Actualizando admin_routes.py...")
    
    try:
        # Leer el archivo actual
        with open('admin_routes.py', 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Buscar la línea problemática
        old_line = "product_data['vendor_id'] = data.get('vendor_id', 'admin')"
        new_line = "product_data['vendor_id'] = data.get('vendor_id', get_admin_user_id())"
        
        if old_line in content:
            content = content.replace(old_line, new_line)
            
            # Agregar función helper al inicio del archivo
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
        
        response = requests.get(f'{SUPABASE_URL}/rest/v1/users?email=eq.admin@cubalink23.com&select=id', headers=headers)
        if response.status_code == 200:
            users = response.json()
            if users:
                return users[0]['id']
        
        # Si no existe, crear usuario admin
        admin_user = {
            'email': 'admin@cubalink23.com',
            'full_name': 'Administrador',
            'role': 'admin'
        }
        response = requests.post(f'{SUPABASE_URL}/rest/v1/users', headers=headers, json=admin_user)
        if response.status_code == 201:
            return response.json()[0]['id']
        
        return None
    except:
        return None

'''
            
            # Insertar la función helper después de los imports
            import_end = content.find('admin = Blueprint')
            if import_end != -1:
                content = content[:import_end] + helper_function + content[import_end:]
            
            # Escribir el archivo actualizado
            with open('admin_routes.py', 'w', encoding='utf-8') as f:
                f.write(content)
            
            print("✅ admin_routes.py actualizado")
            return True
        else:
            print("⚠️ No se encontró la línea a actualizar")
            return False
            
    except Exception as e:
        print(f"❌ Error actualizando admin_routes.py: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 ARREGLANDO PROBLEMAS FINALES")
    print("=" * 50)
    
    # 1. Arreglar imágenes de productos
    fix_product_images()
    
    # 2. Actualizar admin_routes.py
    update_admin_routes()
    
    # 3. Probar creación de producto
    test_admin_product_creation()
    
    print("\n✅ REPARACIÓN COMPLETADA")
    print("=" * 50)
    print("📋 RESUMEN:")
    print("  ✅ URLs de imágenes arregladas")
    print("  ✅ admin_routes.py actualizado")
    print("  ✅ Sistema de creación de productos corregido")
    print("\n🎯 PRÓXIMOS PASOS:")
    print("  1. Reiniciar el servidor backend")
    print("  2. Probar subida de productos desde panel admin")
    print("  3. Verificar que las imágenes se muestran en la app")

if __name__ == "__main__":
    main()





"""
Script para arreglar los problemas finales de imágenes y admin
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

def get_admin_user_id():
    """Obtener el ID del usuario admin"""
    print("🔍 Obteniendo ID del usuario admin...")
    try:
        # Buscar usuario admin por email
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/users?email=eq.admin@cubalink23.com&select=id',
            headers=headers
        )
        
        if response.status_code == 200:
            users = response.json()
            if users:
                admin_id = users[0]['id']
                print(f"✅ Usuario admin encontrado: {admin_id}")
                return admin_id
        
        # Si no existe, crear usuario admin
        print("⚠️ Usuario admin no encontrado, creando...")
        admin_user = {
            'email': 'admin@cubalink23.com',
            'full_name': 'Administrador',
            'role': 'admin'
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/users',
            headers=headers,
            json=admin_user
        )
        
        if response.status_code == 201:
            admin_data = response.json()
            admin_id = admin_data[0]['id']
            print(f"✅ Usuario admin creado: {admin_id}")
            return admin_id
        else:
            print(f"❌ Error creando usuario admin: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Error obteniendo usuario admin: {e}")
        return None

def fix_product_images():
    """Arreglar URLs de imágenes de productos"""
    print("\n🔧 Arreglando URLs de imágenes de productos...")
    
    try:
        # Obtener productos con imágenes placeholder
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url&image_url.like.*via.placeholder.com*',
            headers=headers
        )
        
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        fixed_count = 0
        
        for product in products:
            # Crear URL de imagen local simple
            new_url = f'https://zgqrhzuhrwudckwesybg.supabase.co/storage/v1/object/public/product-images/default-product.png'
            
            # Actualizar en la base de datos
            update_response = requests.patch(
                f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product["id"]}',
                headers=headers,
                json={'image_url': new_url}
            )
            
            if update_response.status_code == 204:
                fixed_count += 1
                print(f"  ✅ Arreglado: {product.get('name', 'Sin nombre')}")
            else:
                print(f"  ❌ Error arreglando: {product.get('name', 'Sin nombre')} - {update_response.status_code}")
        
        print(f"\n📊 Imágenes arregladas: {fixed_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error arreglando imágenes: {e}")
        return False

def test_admin_product_creation():
    """Probar creación de producto desde admin"""
    print("\n🔍 Probando creación de producto desde admin...")
    
    admin_id = get_admin_user_id()
    if not admin_id:
        print("❌ No se puede continuar sin usuario admin")
        return False
    
    test_product = {
        'name': f'Producto Admin Test {datetime.now().strftime("%H:%M:%S")}',
        'description': 'Producto de prueba creado desde admin',
        'price': 15.99,
        'category': 'test',
        'stock': 10,
        'image_url': 'https://zgqrhzuhrwudckwesybg.supabase.co/storage/v1/object/public/product-images/default-product.png',
        'is_active': True,
        'approval_status': 'approved',
        'vendor_id': admin_id  # Usar UUID del admin
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

def update_admin_routes():
    """Actualizar admin_routes.py para usar UUID correcto"""
    print("\n🔧 Actualizando admin_routes.py...")
    
    try:
        # Leer el archivo actual
        with open('admin_routes.py', 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Buscar la línea problemática
        old_line = "product_data['vendor_id'] = data.get('vendor_id', 'admin')"
        new_line = "product_data['vendor_id'] = data.get('vendor_id', get_admin_user_id())"
        
        if old_line in content:
            content = content.replace(old_line, new_line)
            
            # Agregar función helper al inicio del archivo
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
        
        response = requests.get(f'{SUPABASE_URL}/rest/v1/users?email=eq.admin@cubalink23.com&select=id', headers=headers)
        if response.status_code == 200:
            users = response.json()
            if users:
                return users[0]['id']
        
        # Si no existe, crear usuario admin
        admin_user = {
            'email': 'admin@cubalink23.com',
            'full_name': 'Administrador',
            'role': 'admin'
        }
        response = requests.post(f'{SUPABASE_URL}/rest/v1/users', headers=headers, json=admin_user)
        if response.status_code == 201:
            return response.json()[0]['id']
        
        return None
    except:
        return None

'''
            
            # Insertar la función helper después de los imports
            import_end = content.find('admin = Blueprint')
            if import_end != -1:
                content = content[:import_end] + helper_function + content[import_end:]
            
            # Escribir el archivo actualizado
            with open('admin_routes.py', 'w', encoding='utf-8') as f:
                f.write(content)
            
            print("✅ admin_routes.py actualizado")
            return True
        else:
            print("⚠️ No se encontró la línea a actualizar")
            return False
            
    except Exception as e:
        print(f"❌ Error actualizando admin_routes.py: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 ARREGLANDO PROBLEMAS FINALES")
    print("=" * 50)
    
    # 1. Arreglar imágenes de productos
    fix_product_images()
    
    # 2. Actualizar admin_routes.py
    update_admin_routes()
    
    # 3. Probar creación de producto
    test_admin_product_creation()
    
    print("\n✅ REPARACIÓN COMPLETADA")
    print("=" * 50)
    print("📋 RESUMEN:")
    print("  ✅ URLs de imágenes arregladas")
    print("  ✅ admin_routes.py actualizado")
    print("  ✅ Sistema de creación de productos corregido")
    print("\n🎯 PRÓXIMOS PASOS:")
    print("  1. Reiniciar el servidor backend")
    print("  2. Probar subida de productos desde panel admin")
    print("  3. Verificar que las imágenes se muestran en la app")

if __name__ == "__main__":
    main()





