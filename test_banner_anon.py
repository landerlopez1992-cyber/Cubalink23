#!/usr/bin/env python3
"""
Script para probar la subida de banners usando anon key
"""

import requests
import base64
import uuid

def test_banner_upload_anon():
    """Probar subida de banner usando anon key"""
    
    # Configuración de Supabase
    SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
    ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
    
    print("🔍 Probando subida de banner con anon key...")
    
    # 1. Verificar buckets con anon key
    print("\n1. Verificando buckets con anon key...")
    headers = {
        'apikey': ANON_KEY,
        'Authorization': f'Bearer {ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    response = requests.get(f'{SUPABASE_URL}/storage/v1/bucket', headers=headers)
    print(f"📡 Response Status: {response.status_code}")
    print(f"📊 Response Text: {response.text}")
    
    # 2. Listar archivos en bucket banners
    print("\n2. Listando archivos en bucket 'banners'...")
    response = requests.get(f'{SUPABASE_URL}/storage/v1/object/list/banners', headers=headers)
    print(f"📡 Response Status: {response.status_code}")
    print(f"📊 Response Text: {response.text}")
    
    # 3. Probar subida con anon key
    print("\n3. Probando subida con anon key...")
    test_image_base64 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    
    image_id = str(uuid.uuid4())
    filename = f"test_banner_anon_{image_id}.png"
    
    image_data = base64.b64decode(test_image_base64.split(',')[1])
    
    upload_headers = {
        'apikey': ANON_KEY,
        'Authorization': f'Bearer {ANON_KEY}',
        'Content-Type': 'image/png',
    }
    
    print(f"🔍 Subiendo: {filename}")
    
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
    else:
        print(f"❌ Error subiendo banner: {response.status_code}")

if __name__ == "__main__":
    test_banner_upload_anon()





"""
Script para probar la subida de banners usando anon key
"""

import requests
import base64
import uuid

def test_banner_upload_anon():
    """Probar subida de banner usando anon key"""
    
    # Configuración de Supabase
    SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
    ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
    
    print("🔍 Probando subida de banner con anon key...")
    
    # 1. Verificar buckets con anon key
    print("\n1. Verificando buckets con anon key...")
    headers = {
        'apikey': ANON_KEY,
        'Authorization': f'Bearer {ANON_KEY}',
        'Content-Type': 'application/json'
    }
    
    response = requests.get(f'{SUPABASE_URL}/storage/v1/bucket', headers=headers)
    print(f"📡 Response Status: {response.status_code}")
    print(f"📊 Response Text: {response.text}")
    
    # 2. Listar archivos en bucket banners
    print("\n2. Listando archivos en bucket 'banners'...")
    response = requests.get(f'{SUPABASE_URL}/storage/v1/object/list/banners', headers=headers)
    print(f"📡 Response Status: {response.status_code}")
    print(f"📊 Response Text: {response.text}")
    
    # 3. Probar subida con anon key
    print("\n3. Probando subida con anon key...")
    test_image_base64 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    
    image_id = str(uuid.uuid4())
    filename = f"test_banner_anon_{image_id}.png"
    
    image_data = base64.b64decode(test_image_base64.split(',')[1])
    
    upload_headers = {
        'apikey': ANON_KEY,
        'Authorization': f'Bearer {ANON_KEY}',
        'Content-Type': 'image/png',
    }
    
    print(f"🔍 Subiendo: {filename}")
    
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
    else:
        print(f"❌ Error subiendo banner: {response.status_code}")

if __name__ == "__main__":
    test_banner_upload_anon()





