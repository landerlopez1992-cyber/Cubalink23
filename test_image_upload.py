#!/usr/bin/env python3
"""
Script de prueba para verificar la subida de imágenes a Supabase Storage
"""

import requests
import base64
import uuid
import json

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

def test_bucket_access():
    """Probar acceso al bucket product-images"""
    print("🔍 Probando acceso al bucket 'product-images'...")
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
    }
    
    # Intentar listar objetos del bucket
    response = requests.get(
        f'{SUPABASE_URL}/storage/v1/object/list/product-images',
        headers=headers
    )
    
    print(f"📡 Status Code: {response.status_code}")
    print(f"📊 Response: {response.text}")
    
    if response.status_code == 200:
        print("✅ Acceso al bucket exitoso")
        return True
    else:
        print("❌ Error de acceso al bucket")
        return False

def test_image_upload():
    """Probar subida de imagen de prueba"""
    print("\n🖼️ Probando subida de imagen...")
    
    # Crear una imagen de prueba simple (1x1 pixel PNG en base64)
    test_image_base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    
    # Generar nombre único
    image_id = str(uuid.uuid4())
    filename = f"test_image_{image_id}.png"
    
    # Decodificar imagen
    image_data = base64.b64decode(test_image_base64)
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'image/png',
    }
    
    print(f"📁 Subiendo archivo: {filename}")
    print(f"📏 Tamaño: {len(image_data)} bytes")
    
    response = requests.post(
        f'{SUPABASE_URL}/storage/v1/object/product-images/{filename}',
        headers=headers,
        data=image_data
    )
    
    print(f"📡 Status Code: {response.status_code}")
    print(f"📊 Response: {response.text}")
    
    if response.status_code == 200:
        public_url = f'{SUPABASE_URL}/storage/v1/object/public/product-images/{filename}'
        print(f"✅ Imagen subida exitosamente: {public_url}")
        return public_url
    else:
        print("❌ Error en subida de imagen")
        return None

def test_database_connection():
    """Probar conexión a la base de datos"""
    print("\n🗄️ Probando conexión a la base de datos...")
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    # Intentar leer productos existentes
    response = requests.get(
        f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url&limit=5',
        headers=headers
    )
    
    print(f"📡 Status Code: {response.status_code}")
    print(f"📊 Response: {response.text}")
    
    if response.status_code == 200:
        print("✅ Conexión a base de datos exitosa")
        return True
    else:
        print("❌ Error de conexión a base de datos")
        return False

def main():
    print("🧪 INICIANDO PRUEBAS DE SUPABASE")
    print("=" * 50)
    
    # Probar conexión a base de datos
    db_ok = test_database_connection()
    
    # Probar acceso al bucket
    bucket_ok = test_bucket_access()
    
    # Probar subida de imagen
    if bucket_ok:
        image_url = test_image_upload()
    else:
        print("⚠️ Saltando prueba de imagen por error de bucket")
        image_url = None
    
    print("\n" + "=" * 50)
    print("📋 RESUMEN DE PRUEBAS:")
    print(f"🗄️ Base de datos: {'✅ OK' if db_ok else '❌ ERROR'}")
    print(f"🪣 Bucket storage: {'✅ OK' if bucket_ok else '❌ ERROR'}")
    print(f"🖼️ Subida imagen: {'✅ OK' if image_url else '❌ ERROR'}")
    
    if not bucket_ok:
        print("\n🔧 SOLUCIÓN RECOMENDADA:")
        print("1. Ve a tu dashboard de Supabase")
        print("2. Ve a Storage > product-images")
        print("3. Configura las políticas RLS:")
        print("   - SELECT: bucket_id = 'product-images'")
        print("   - INSERT: bucket_id = 'product-images'")
        print("   - UPDATE: bucket_id = 'product-images'")
        print("4. Asegúrate de que el bucket sea público")

if __name__ == "__main__":
    main()
