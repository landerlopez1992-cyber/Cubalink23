#!/usr/bin/env python3
"""
Script para diagnosticar y arreglar problemas de imágenes y panel admin
"""

import requests
import json
import base64
from datetime import datetime

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def test_supabase_connection():
    """Probar conexión con Supabase"""
    print("🔍 Probando conexión con Supabase...")
    try:
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id&limit=1', headers=headers)
        if response.status_code == 200:
            print("✅ Conexión con Supabase exitosa")
            return True
        else:
            print(f"❌ Error de conexión: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def check_store_products_schema():
    """Verificar esquema de la tabla store_products"""
    print("\n🔍 Verificando esquema de store_products...")
    try:
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=*&limit=1', headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data:
                print("✅ Tabla store_products accesible")
                print(f"📋 Columnas disponibles: {list(data[0].keys())}")
                return True
            else:
                print("⚠️ Tabla store_products vacía")
                return True
        else:
            print(f"❌ Error accediendo a store_products: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error verificando esquema: {e}")
        return False

def check_existing_products():
    """Verificar productos existentes y sus imágenes"""
    print("\n🔍 Verificando productos existentes...")
    try:
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url&limit=10', headers=headers)
        if response.status_code == 200:
            products = response.json()
            print(f"📦 Encontrados {len(products)} productos")
            
            for product in products:
                print(f"  - {product.get('name', 'Sin nombre')}: {product.get('image_url', 'Sin imagen')}")
            
            return products
        else:
            print(f"❌ Error obteniendo productos: {response.status_code} - {response.text}")
            return []
    except Exception as e:
        print(f"❌ Error verificando productos: {e}")
        return []

def test_image_urls(products):
    """Probar URLs de imágenes existentes"""
    print("\n🔍 Probando URLs de imágenes...")
    working_images = 0
    broken_images = 0
    
    for product in products:
        image_url = product.get('image_url', '')
        if image_url and image_url.startswith('http'):
            try:
                img_response = requests.head(image_url, timeout=5)
                if img_response.status_code == 200:
                    working_images += 1
                    print(f"  ✅ {product.get('name', 'Sin nombre')}: Imagen OK")
                else:
                    broken_images += 1
                    print(f"  ❌ {product.get('name', 'Sin nombre')}: Imagen rota ({img_response.status_code})")
            except Exception as e:
                broken_images += 1
                print(f"  ❌ {product.get('name', 'Sin nombre')}: Error de imagen ({e})")
        else:
            broken_images += 1
            print(f"  ⚠️ {product.get('name', 'Sin nombre')}: Sin URL de imagen")
    
    print(f"\n📊 Resumen de imágenes: {working_images} OK, {broken_images} con problemas")
    return working_images, broken_images

def test_create_product():
    """Probar creación de producto"""
    print("\n🔍 Probando creación de producto...")
    
    test_product = {
        'name': f'Producto Test {datetime.now().strftime("%H:%M:%S")}',
        'description': 'Producto de prueba para verificar funcionalidad',
        'price': 10.99,
        'category': 'test',
        'stock': 5,
        'image_url': 'https://via.placeholder.com/400x300/007bff/ffffff?text=Test+Product',
        'is_active': True,
        'approval_status': 'approved',
        'vendor_id': 'admin'
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
            print("✅ Producto creado exitosamente")
            return True
        else:
            print(f"❌ Error creando producto: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error en creación: {e}")
        return False

def fix_broken_image_urls():
    """Arreglar URLs de imágenes rotas"""
    print("\n🔧 Arreglando URLs de imágenes rotas...")
    
    try:
        # Obtener productos con imágenes rotas
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url&image_url.not.is.null', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        fixed_count = 0
        
        for product in products:
            image_url = product.get('image_url', '')
            if image_url and not image_url.startswith('http'):
                # Generar URL pública de Supabase
                if image_url.startswith('storage/v1/object/public/'):
                    new_url = f'{SUPABASE_URL}/{image_url}'
                else:
                    new_url = f'{SUPABASE_URL}/storage/v1/object/public/product-images/{image_url}'
                
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
        
        print(f"\n📊 URLs arregladas: {fixed_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error arreglando URLs: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 DIAGNÓSTICO Y REPARACIÓN DE PROBLEMAS")
    print("=" * 50)
    
    # 1. Probar conexión
    if not test_supabase_connection():
        print("❌ No se puede continuar sin conexión a Supabase")
        return
    
    # 2. Verificar esquema
    if not check_store_products_schema():
        print("❌ Problemas con el esquema de la tabla")
        return
    
    # 3. Verificar productos existentes
    products = check_existing_products()
    
    # 4. Probar URLs de imágenes
    if products:
        working, broken = test_image_urls(products)
        
        # 5. Arreglar URLs rotas si es necesario
        if broken > 0:
            fix_broken_image_urls()
    
    # 6. Probar creación de producto
    test_create_product()
    
    print("\n✅ DIAGNÓSTICO COMPLETADO")
    print("=" * 50)

if __name__ == "__main__":
    main()





"""
Script para diagnosticar y arreglar problemas de imágenes y panel admin
"""

import requests
import json
import base64
from datetime import datetime

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def test_supabase_connection():
    """Probar conexión con Supabase"""
    print("🔍 Probando conexión con Supabase...")
    try:
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id&limit=1', headers=headers)
        if response.status_code == 200:
            print("✅ Conexión con Supabase exitosa")
            return True
        else:
            print(f"❌ Error de conexión: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def check_store_products_schema():
    """Verificar esquema de la tabla store_products"""
    print("\n🔍 Verificando esquema de store_products...")
    try:
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=*&limit=1', headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data:
                print("✅ Tabla store_products accesible")
                print(f"📋 Columnas disponibles: {list(data[0].keys())}")
                return True
            else:
                print("⚠️ Tabla store_products vacía")
                return True
        else:
            print(f"❌ Error accediendo a store_products: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error verificando esquema: {e}")
        return False

def check_existing_products():
    """Verificar productos existentes y sus imágenes"""
    print("\n🔍 Verificando productos existentes...")
    try:
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url&limit=10', headers=headers)
        if response.status_code == 200:
            products = response.json()
            print(f"📦 Encontrados {len(products)} productos")
            
            for product in products:
                print(f"  - {product.get('name', 'Sin nombre')}: {product.get('image_url', 'Sin imagen')}")
            
            return products
        else:
            print(f"❌ Error obteniendo productos: {response.status_code} - {response.text}")
            return []
    except Exception as e:
        print(f"❌ Error verificando productos: {e}")
        return []

def test_image_urls(products):
    """Probar URLs de imágenes existentes"""
    print("\n🔍 Probando URLs de imágenes...")
    working_images = 0
    broken_images = 0
    
    for product in products:
        image_url = product.get('image_url', '')
        if image_url and image_url.startswith('http'):
            try:
                img_response = requests.head(image_url, timeout=5)
                if img_response.status_code == 200:
                    working_images += 1
                    print(f"  ✅ {product.get('name', 'Sin nombre')}: Imagen OK")
                else:
                    broken_images += 1
                    print(f"  ❌ {product.get('name', 'Sin nombre')}: Imagen rota ({img_response.status_code})")
            except Exception as e:
                broken_images += 1
                print(f"  ❌ {product.get('name', 'Sin nombre')}: Error de imagen ({e})")
        else:
            broken_images += 1
            print(f"  ⚠️ {product.get('name', 'Sin nombre')}: Sin URL de imagen")
    
    print(f"\n📊 Resumen de imágenes: {working_images} OK, {broken_images} con problemas")
    return working_images, broken_images

def test_create_product():
    """Probar creación de producto"""
    print("\n🔍 Probando creación de producto...")
    
    test_product = {
        'name': f'Producto Test {datetime.now().strftime("%H:%M:%S")}',
        'description': 'Producto de prueba para verificar funcionalidad',
        'price': 10.99,
        'category': 'test',
        'stock': 5,
        'image_url': 'https://via.placeholder.com/400x300/007bff/ffffff?text=Test+Product',
        'is_active': True,
        'approval_status': 'approved',
        'vendor_id': 'admin'
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
            print("✅ Producto creado exitosamente")
            return True
        else:
            print(f"❌ Error creando producto: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error en creación: {e}")
        return False

def fix_broken_image_urls():
    """Arreglar URLs de imágenes rotas"""
    print("\n🔧 Arreglando URLs de imágenes rotas...")
    
    try:
        # Obtener productos con imágenes rotas
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url&image_url.not.is.null', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        fixed_count = 0
        
        for product in products:
            image_url = product.get('image_url', '')
            if image_url and not image_url.startswith('http'):
                # Generar URL pública de Supabase
                if image_url.startswith('storage/v1/object/public/'):
                    new_url = f'{SUPABASE_URL}/{image_url}'
                else:
                    new_url = f'{SUPABASE_URL}/storage/v1/object/public/product-images/{image_url}'
                
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
        
        print(f"\n📊 URLs arregladas: {fixed_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error arreglando URLs: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 DIAGNÓSTICO Y REPARACIÓN DE PROBLEMAS")
    print("=" * 50)
    
    # 1. Probar conexión
    if not test_supabase_connection():
        print("❌ No se puede continuar sin conexión a Supabase")
        return
    
    # 2. Verificar esquema
    if not check_store_products_schema():
        print("❌ Problemas con el esquema de la tabla")
        return
    
    # 3. Verificar productos existentes
    products = check_existing_products()
    
    # 4. Probar URLs de imágenes
    if products:
        working, broken = test_image_urls(products)
        
        # 5. Arreglar URLs rotas si es necesario
        if broken > 0:
            fix_broken_image_urls()
    
    # 6. Probar creación de producto
    test_create_product()
    
    print("\n✅ DIAGNÓSTICO COMPLETADO")
    print("=" * 50)

if __name__ == "__main__":
    main()





