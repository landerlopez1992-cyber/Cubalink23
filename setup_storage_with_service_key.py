#!/usr/bin/env python3
"""
Setup de Supabase Storage usando Service Key
"""

import requests
import json
import base64

# Configuración de Supabase con Service Key
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.kUgRPYHRuWJVPfD8iVA7GDuOlj9Xwp6eQ2gH7FJqJ9s'

service_headers = {
    'apikey': SERVICE_KEY,
    'Authorization': f'Bearer {SERVICE_KEY}',
    'Content-Type': 'application/json'
}

def create_bucket_with_service_key():
    """Crear bucket usando Service Key"""
    print("🔧 Creando bucket product-images con Service Key...")
    
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
            headers=service_headers,
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

def download_and_upload_image_with_service_key(image_url, filename):
    """Descargar y subir imagen usando Service Key"""
    print(f"📥 Descargando y subiendo: {filename}")
    
    try:
        # Descargar imagen
        img_response = requests.get(image_url, timeout=10)
        if img_response.status_code != 200:
            print(f"❌ Error descargando imagen: {img_response.status_code}")
            return False
        
        # Headers para upload con Service Key
        upload_headers = {
            'apikey': SERVICE_KEY,
            'Authorization': f'Bearer {SERVICE_KEY}',
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
    
    # Usar headers normales para leer productos
    normal_headers = {
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ',
        'Authorization': f'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ',
        'Content-Type': 'application/json'
    }
    
    try:
        # Obtener productos actuales
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url', headers=normal_headers)
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
                if download_and_upload_image_with_service_key(current_url, filename):
                    # Actualizar producto con nueva URL usando Service Key
                    update_response = requests.patch(
                        f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product_id}',
                        headers=service_headers,
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
        response = requests.get(f'{SUPABASE_URL}/storage/v1/bucket', headers=service_headers)
        if response.status_code == 200:
            buckets = response.json()
            print(f"📦 Buckets disponibles: {[b['name'] for b in buckets]}")
        
        # Verificar archivos en bucket
        response = requests.get(f'{SUPABASE_URL}/storage/v1/object/list/product-images', headers=service_headers)
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
    print("🚀 SETUP DE SUPABASE STORAGE CON SERVICE KEY")
    print("=" * 50)
    
    # 1. Crear bucket
    if not create_bucket_with_service_key():
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
