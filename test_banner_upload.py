#!/usr/bin/env python3
"""
Script para probar la subida de banners a Supabase Storage
"""

import requests
import base64
import uuid
import os

def test_banner_upload():
    """Probar subida de banner a Supabase Storage"""
    
    # Configuración de Supabase
    SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
    SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.kUgRPYHRuWJVPfD8iVA7GDuOlj9Xwp6eQ2gH7FJqJ9s'
    
    print("🔍 Probando subida de banner a Supabase Storage...")
    
    # 1. Verificar que el bucket 'banners' existe
    print("\n1. Verificando bucket 'banners'...")
    headers = {
        'apikey': SERVICE_KEY,
        'Authorization': f'Bearer {SERVICE_KEY}',
        'Content-Type': 'application/json'
    }
    
    response = requests.get(f'{SUPABASE_URL}/storage/v1/bucket', headers=headers)
    print(f"📡 Response Status: {response.status_code}")
    print(f"📊 Response Text: {response.text}")
    
    if response.status_code == 200:
        buckets = response.json()
        banner_bucket = next((b for b in buckets if b['name'] == 'banners'), None)
        if banner_bucket:
            print("✅ Bucket 'banners' encontrado")
        else:
            print("❌ Bucket 'banners' NO encontrado")
            print("📋 Buckets disponibles:", [b['name'] for b in buckets])
    else:
        print(f"❌ Error obteniendo buckets: {response.status_code}")
    
    # 2. Crear una imagen de prueba (base64 simple)
    print("\n2. Creando imagen de prueba...")
    # Imagen PNG simple de 1x1 pixel (base64)
    test_image_base64 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    
    # 3. Probar subida
    print("\n3. Probando subida de imagen...")
    image_id = str(uuid.uuid4())
    filename = f"test_banner_{image_id}.png"
    
    # Decodificar imagen base64
    image_data = base64.b64decode(test_image_base64.split(',')[1])
    
    # Headers para upload
    upload_headers = {
        'apikey': SERVICE_KEY,
        'Authorization': f'Bearer {SERVICE_KEY}',
        'Content-Type': 'image/png',
    }
    
    print(f"🔍 Subiendo: {filename}")
    print(f"📸 Tamaño de datos: {len(image_data)} bytes")
    
    response = requests.post(
        f'{SUPABASE_URL}/storage/v1/object/banners/{filename}',
        headers=upload_headers,
        data=image_data
    )
    
    print(f"📡 Response Status: {response.status_code}")
    print(f"📊 Response Text: {response.text}")
    
    if response.status_code == 200:
        public_url = f'{SUPABASE_URL}/storage/v1/object/public/banners/{filename}'
        print(f"✅ Banner subido exitosamente: {public_url}")
        
        # 4. Verificar que se puede acceder a la imagen
        print("\n4. Verificando acceso a la imagen...")
        verify_response = requests.get(public_url)
        print(f"📡 Verify Status: {verify_response.status_code}")
        if verify_response.status_code == 200:
            print("✅ Imagen accesible públicamente")
        else:
            print("❌ Imagen no accesible")
            
    else:
        print(f"❌ Error subiendo banner: {response.status_code}")
        print(f"📊 Error details: {response.text}")
    
    # 5. Listar archivos en el bucket
    print("\n5. Listando archivos en bucket 'banners'...")
    list_response = requests.get(f'{SUPABASE_URL}/storage/v1/object/list/banners', headers=headers)
    print(f"📡 List Status: {list_response.status_code}")
    print(f"📊 List Response: {list_response.text}")

if __name__ == "__main__":
    test_banner_upload()





"""
Script para probar la subida de banners a Supabase Storage
"""

import requests
import base64
import uuid
import os

def test_banner_upload():
    """Probar subida de banner a Supabase Storage"""
    
    # Configuración de Supabase
    SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
    SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.kUgRPYHRuWJVPfD8iVA7GDuOlj9Xwp6eQ2gH7FJqJ9s'
    
    print("🔍 Probando subida de banner a Supabase Storage...")
    
    # 1. Verificar que el bucket 'banners' existe
    print("\n1. Verificando bucket 'banners'...")
    headers = {
        'apikey': SERVICE_KEY,
        'Authorization': f'Bearer {SERVICE_KEY}',
        'Content-Type': 'application/json'
    }
    
    response = requests.get(f'{SUPABASE_URL}/storage/v1/bucket', headers=headers)
    print(f"📡 Response Status: {response.status_code}")
    print(f"📊 Response Text: {response.text}")
    
    if response.status_code == 200:
        buckets = response.json()
        banner_bucket = next((b for b in buckets if b['name'] == 'banners'), None)
        if banner_bucket:
            print("✅ Bucket 'banners' encontrado")
        else:
            print("❌ Bucket 'banners' NO encontrado")
            print("📋 Buckets disponibles:", [b['name'] for b in buckets])
    else:
        print(f"❌ Error obteniendo buckets: {response.status_code}")
    
    # 2. Crear una imagen de prueba (base64 simple)
    print("\n2. Creando imagen de prueba...")
    # Imagen PNG simple de 1x1 pixel (base64)
    test_image_base64 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    
    # 3. Probar subida
    print("\n3. Probando subida de imagen...")
    image_id = str(uuid.uuid4())
    filename = f"test_banner_{image_id}.png"
    
    # Decodificar imagen base64
    image_data = base64.b64decode(test_image_base64.split(',')[1])
    
    # Headers para upload
    upload_headers = {
        'apikey': SERVICE_KEY,
        'Authorization': f'Bearer {SERVICE_KEY}',
        'Content-Type': 'image/png',
    }
    
    print(f"🔍 Subiendo: {filename}")
    print(f"📸 Tamaño de datos: {len(image_data)} bytes")
    
    response = requests.post(
        f'{SUPABASE_URL}/storage/v1/object/banners/{filename}',
        headers=upload_headers,
        data=image_data
    )
    
    print(f"📡 Response Status: {response.status_code}")
    print(f"📊 Response Text: {response.text}")
    
    if response.status_code == 200:
        public_url = f'{SUPABASE_URL}/storage/v1/object/public/banners/{filename}'
        print(f"✅ Banner subido exitosamente: {public_url}")
        
        # 4. Verificar que se puede acceder a la imagen
        print("\n4. Verificando acceso a la imagen...")
        verify_response = requests.get(public_url)
        print(f"📡 Verify Status: {verify_response.status_code}")
        if verify_response.status_code == 200:
            print("✅ Imagen accesible públicamente")
        else:
            print("❌ Imagen no accesible")
            
    else:
        print(f"❌ Error subiendo banner: {response.status_code}")
        print(f"📊 Error details: {response.text}")
    
    # 5. Listar archivos en el bucket
    print("\n5. Listando archivos en bucket 'banners'...")
    list_response = requests.get(f'{SUPABASE_URL}/storage/v1/object/list/banners', headers=headers)
    print(f"📡 List Status: {list_response.status_code}")
    print(f"📊 List Response: {list_response.text}")

if __name__ == "__main__":
    test_banner_upload()





