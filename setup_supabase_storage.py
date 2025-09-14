#!/usr/bin/env python3
"""
Script completo para configurar Supabase Storage: crear bucket y políticas
"""

import requests
import json

# Configuración de Supabase - usando anon key que funciona
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

def create_bucket():
    """Crear el bucket product-images si no existe"""
    print("🪣 Creando bucket 'product-images'...")
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': 'Bearer ' + SUPABASE_ANON_KEY,
        'Content-Type': 'application/json'
    }
    
    bucket_data = {
        'id': 'product-images',
        'name': 'product-images',
        'public': True,
        'file_size_limit': 52428800,  # 50MB
        'allowed_mime_types': ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    }
    
    try:
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/bucket',
            headers=headers,
            json=bucket_data
        )
        
        print(f"📊 Response: {response.status_code} - {response.text}")
        
        if response.status_code == 200:
            print("✅ Bucket 'product-images' creado exitosamente!")
            return True
        elif response.status_code == 409:
            print("ℹ️ Bucket 'product-images' ya existe.")
            return True
        else:
            print(f"❌ Error creando bucket: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_bucket_access():
    """Probar acceso al bucket"""
    print("\n🧪 Probando acceso al bucket...")
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': 'Bearer ' + SUPABASE_ANON_KEY
    }
    
    try:
        # Listar objetos del bucket
        response = requests.get(
            f'{SUPABASE_URL}/storage/v1/object/list/product-images',
            headers=headers
        )
        
        print(f"📊 Response: {response.status_code} - {response.text}")
        
        if response.status_code == 200:
            objects = response.json()
            print(f"✅ Acceso al bucket exitoso. Objetos encontrados: {len(objects)}")
            return True
        else:
            print(f"❌ Error accediendo al bucket: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error probando acceso: {e}")
        return False

def test_image_upload():
    """Probar subida de imagen"""
    print("\n📸 Probando subida de imagen...")
    
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': 'Bearer ' + SUPABASE_ANON_KEY,
        'Content-Type': 'image/jpeg'
    }
    
    # Crear una imagen de prueba simple (1x1 pixel JPEG)
    test_image_data = b'\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x01\x00H\x00H\x00\x00\xff\xdb\x00C\x00\x08\x06\x06\x07\x06\x05\x08\x07\x07\x07\t\t\x08\n\x0c\x14\r\x0c\x0b\x0b\x0c\x19\x12\x13\x0f\x14\x1d\x1a\x1f\x1e\x1d\x1a\x1c\x1c $.\' ",#\x1c\x1c(7),01444\x1f\'9=82<.342\xff\xc0\x00\x11\x08\x00\x01\x00\x01\x01\x01\x11\x00\x02\x11\x01\x03\x11\x01\xff\xc4\x00\x14\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\xff\xc4\x00\x14\x10\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xda\x00\x0c\x03\x01\x00\x02\x11\x03\x11\x00\x3f\x00\xaa\xff\xd9'
    
    try:
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/object/product-images/test_image.jpg',
            headers=headers,
            data=test_image_data
        )
        
        print(f"📊 Upload Response: {response.status_code} - {response.text}")
        
        if response.status_code == 200:
            print("✅ Subida de imagen exitosa!")
            # Probar acceso público
            public_url = f'{SUPABASE_URL}/storage/v1/object/public/product-images/test_image.jpg'
            print(f"🔗 URL pública: {public_url}")
            return True
        else:
            print(f"❌ Error subiendo imagen: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("🚀 CONFIGURADOR COMPLETO DE SUPABASE STORAGE")
    print("=" * 50)
    
    # Paso 1: Crear bucket
    bucket_success = create_bucket()
    
    if bucket_success:
        # Paso 2: Probar acceso
        access_success = test_bucket_access()
        
        if access_success:
            # Paso 3: Probar subida
            upload_success = test_image_upload()
            
            print("\n" + "=" * 50)
            if upload_success:
                print("🎉 ¡CONFIGURACIÓN COMPLETA!")
                print("✅ Bucket creado/verificado")
                print("✅ Acceso al bucket verificado")
                print("✅ Subida de imágenes funcional")
                print("\n🔄 Ahora puedes:")
                print("   - Agregar productos con imágenes desde el panel admin")
                print("   - Las imágenes se subirán a Supabase Storage")
                print("   - La app Flutter podrá acceder a las imágenes")
                print("\n📋 URLs de ejemplo:")
                print(f"   - Bucket: {SUPABASE_URL}/storage/v1/object/list/product-images")
                print(f"   - Imagen pública: {SUPABASE_URL}/storage/v1/object/public/product-images/filename.jpg")
            else:
                print("⚠️ CONFIGURACIÓN PARCIAL")
                print("✅ Bucket creado")
                print("✅ Acceso verificado")
                print("❌ Subida de imágenes falló")
                print("\n💡 Posibles soluciones:")
                print("   1. Verificar políticas en el dashboard de Supabase")
                print("   2. Asegurar que el bucket sea público")
                print("   3. Revisar permisos de escritura")
        else:
            print("❌ CONFIGURACIÓN FALLIDA")
            print("✅ Bucket creado")
            print("❌ No se puede acceder al bucket")
    else:
        print("❌ CONFIGURACIÓN FALLIDA")
        print("❌ No se pudo crear el bucket")
        print("\n💡 Verifica:")
        print("   1. Que las credenciales de Supabase sean correctas")
        print("   2. Que tengas permisos para crear buckets")
        print("   3. Que el proyecto de Supabase esté activo")
