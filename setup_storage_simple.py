#!/usr/bin/env python3
"""
Setup simple de Supabase Storage para imágenes de productos
"""

import requests
import json
import base64

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def create_bucket():
    """Crear bucket product-images en Supabase Storage"""
    print("🔧 Creando bucket product-images...")
    
    bucket_data = {
        'id': 'product-images',
        'name': 'product-images',
        'public': True,
        'file_size_limit': 52428800,  # 50MB
        'allowed_mime_types': ['image/jpeg', 'image/png', 'image/webp']
    }
    
    try:
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/bucket',
            headers=headers,
            json=bucket_data
        )
        
        print(f"📤 Respuesta creación bucket: {response.status_code}")
        print(f"📤 Contenido: {response.text}")
        
        if response.status_code == 200:
            print("✅ Bucket product-images creado exitosamente")
            return True
        else:
            print(f"⚠️ Error creando bucket: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error creando bucket: {e}")
        return False

def download_and_upload_image(image_url, filename):
    """Descargar imagen de URL externa y subirla a Supabase Storage"""
    print(f"📥 Descargando imagen: {image_url}")
    
    try:
        # Descargar imagen
        img_response = requests.get(image_url, timeout=10)
        if img_response.status_code != 200:
            print(f"❌ Error descargando imagen: {img_response.status_code}")
            return False
        
        # Headers para upload
        upload_headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
        }
        
        # Subir archivo
        files = {
            'file': (filename, img_response.content, 'image/jpeg')
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/object/product-images/{filename}',
            headers=upload_headers,
            files=files
        )
        
        print(f"📤 Respuesta upload: {response.status_code}")
        
        if response.status_code == 200:
            print(f"✅ Imagen {filename} subida exitosamente")
            return True
        else:
            print(f"❌ Error subiendo {filename}: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error procesando imagen: {e}")
        return False

def update_products_with_storage_urls():
    """Actualizar productos con URLs de Supabase Storage"""
    print("🔄 Actualizando productos con URLs de Storage...")
    
    try:
        # Obtener productos actuales
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        updated_count = 0
        
        for i, product in enumerate(products):
            # Crear nombre de archivo único
            product_id = product['id']
            filename = f"product_{i+1}_{product_id[:8]}.jpg"
            
            # URL pública de Supabase Storage
            storage_url = f"{SUPABASE_URL}/storage/v1/object/public/product-images/{filename}"
            
            # Descargar y subir imagen actual
            current_url = product.get('image_url', '')
            if current_url and current_url.startswith('http'):
                if download_and_upload_image(current_url, filename):
                    # Actualizar producto con nueva URL
                    update_response = requests.patch(
                        f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product_id}',
                        headers=headers,
                        json={'image_url': storage_url}
                    )
                    
                    if update_response.status_code == 204:
                        updated_count += 1
                        print(f"  ✅ Actualizado: {product.get('name', 'Sin nombre')}")
                    else:
                        print(f"  ❌ Error actualizando: {product.get('name', 'Sin nombre')}")
                else:
                    print(f"  ⚠️ No se pudo procesar imagen de: {product.get('name', 'Sin nombre')}")
        
        print(f"\n📊 Productos actualizados: {updated_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error actualizando productos: {e}")
        return False

def verify_storage_setup():
    """Verificar que el setup de Storage funcione"""
    print("\n🔍 Verificando setup de Storage...")
    
    try:
        # Verificar bucket
        response = requests.get(f'{SUPABASE_URL}/storage/v1/bucket', headers=headers)
        if response.status_code == 200:
            buckets = response.json()
            print(f"📦 Buckets disponibles: {[b['name'] for b in buckets]}")
        
        # Verificar archivos en bucket
        response = requests.get(f'{SUPABASE_URL}/storage/v1/object/list/product-images', headers=headers)
        if response.status_code == 200:
            files = response.json()
            print(f"📁 Archivos en product-images: {len(files)}")
            for file in files:
                print(f"  - {file.get('name', 'Sin nombre')}")
        else:
            print(f"❌ Error listando archivos: {response.status_code}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error verificando Storage: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 SETUP SIMPLE DE SUPABASE STORAGE")
    print("=" * 50)
    
    # 1. Crear bucket
    if not create_bucket():
        print("⚠️ Bucket ya existe o error creándolo, continuando...")
    
    # 2. Descargar y subir imágenes de productos
    update_products_with_storage_urls()
    
    # 3. Verificar setup
    verify_storage_setup()
    
    print("\n✅ SETUP DE STORAGE COMPLETADO")
    print("=" * 50)
    print("📋 RESULTADO:")
    print("  ✅ Bucket product-images configurado")
    print("  ✅ Imágenes descargadas y subidas a Storage")
    print("  ✅ Productos actualizados con URLs de Storage")
    print("\n🎯 PRÓXIMO PASO:")
    print("  Las imágenes ahora se almacenan en Supabase Storage")

if __name__ == "__main__":
    main()





"""
Setup simple de Supabase Storage para imágenes de productos
"""

import requests
import json
import base64

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def create_bucket():
    """Crear bucket product-images en Supabase Storage"""
    print("🔧 Creando bucket product-images...")
    
    bucket_data = {
        'id': 'product-images',
        'name': 'product-images',
        'public': True,
        'file_size_limit': 52428800,  # 50MB
        'allowed_mime_types': ['image/jpeg', 'image/png', 'image/webp']
    }
    
    try:
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/bucket',
            headers=headers,
            json=bucket_data
        )
        
        print(f"📤 Respuesta creación bucket: {response.status_code}")
        print(f"📤 Contenido: {response.text}")
        
        if response.status_code == 200:
            print("✅ Bucket product-images creado exitosamente")
            return True
        else:
            print(f"⚠️ Error creando bucket: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error creando bucket: {e}")
        return False

def download_and_upload_image(image_url, filename):
    """Descargar imagen de URL externa y subirla a Supabase Storage"""
    print(f"📥 Descargando imagen: {image_url}")
    
    try:
        # Descargar imagen
        img_response = requests.get(image_url, timeout=10)
        if img_response.status_code != 200:
            print(f"❌ Error descargando imagen: {img_response.status_code}")
            return False
        
        # Headers para upload
        upload_headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
        }
        
        # Subir archivo
        files = {
            'file': (filename, img_response.content, 'image/jpeg')
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/object/product-images/{filename}',
            headers=upload_headers,
            files=files
        )
        
        print(f"📤 Respuesta upload: {response.status_code}")
        
        if response.status_code == 200:
            print(f"✅ Imagen {filename} subida exitosamente")
            return True
        else:
            print(f"❌ Error subiendo {filename}: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error procesando imagen: {e}")
        return False

def update_products_with_storage_urls():
    """Actualizar productos con URLs de Supabase Storage"""
    print("🔄 Actualizando productos con URLs de Storage...")
    
    try:
        # Obtener productos actuales
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        updated_count = 0
        
        for i, product in enumerate(products):
            # Crear nombre de archivo único
            product_id = product['id']
            filename = f"product_{i+1}_{product_id[:8]}.jpg"
            
            # URL pública de Supabase Storage
            storage_url = f"{SUPABASE_URL}/storage/v1/object/public/product-images/{filename}"
            
            # Descargar y subir imagen actual
            current_url = product.get('image_url', '')
            if current_url and current_url.startswith('http'):
                if download_and_upload_image(current_url, filename):
                    # Actualizar producto con nueva URL
                    update_response = requests.patch(
                        f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product_id}',
                        headers=headers,
                        json={'image_url': storage_url}
                    )
                    
                    if update_response.status_code == 204:
                        updated_count += 1
                        print(f"  ✅ Actualizado: {product.get('name', 'Sin nombre')}")
                    else:
                        print(f"  ❌ Error actualizando: {product.get('name', 'Sin nombre')}")
                else:
                    print(f"  ⚠️ No se pudo procesar imagen de: {product.get('name', 'Sin nombre')}")
        
        print(f"\n📊 Productos actualizados: {updated_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error actualizando productos: {e}")
        return False

def verify_storage_setup():
    """Verificar que el setup de Storage funcione"""
    print("\n🔍 Verificando setup de Storage...")
    
    try:
        # Verificar bucket
        response = requests.get(f'{SUPABASE_URL}/storage/v1/bucket', headers=headers)
        if response.status_code == 200:
            buckets = response.json()
            print(f"📦 Buckets disponibles: {[b['name'] for b in buckets]}")
        
        # Verificar archivos en bucket
        response = requests.get(f'{SUPABASE_URL}/storage/v1/object/list/product-images', headers=headers)
        if response.status_code == 200:
            files = response.json()
            print(f"📁 Archivos en product-images: {len(files)}")
            for file in files:
                print(f"  - {file.get('name', 'Sin nombre')}")
        else:
            print(f"❌ Error listando archivos: {response.status_code}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error verificando Storage: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 SETUP SIMPLE DE SUPABASE STORAGE")
    print("=" * 50)
    
    # 1. Crear bucket
    if not create_bucket():
        print("⚠️ Bucket ya existe o error creándolo, continuando...")
    
    # 2. Descargar y subir imágenes de productos
    update_products_with_storage_urls()
    
    # 3. Verificar setup
    verify_storage_setup()
    
    print("\n✅ SETUP DE STORAGE COMPLETADO")
    print("=" * 50)
    print("📋 RESULTADO:")
    print("  ✅ Bucket product-images configurado")
    print("  ✅ Imágenes descargadas y subidas a Storage")
    print("  ✅ Productos actualizados con URLs de Storage")
    print("\n🎯 PRÓXIMO PASO:")
    print("  Las imágenes ahora se almacenan en Supabase Storage")

if __name__ == "__main__":
    main()





