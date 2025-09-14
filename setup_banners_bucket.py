#!/usr/bin/env python3
"""
Script para crear y configurar el bucket 'banners' en Supabase Storage
"""

import requests
import json

def setup_banners_bucket():
    """Crear bucket 'banners' y configurar políticas RLS"""
    
    # Configuración de Supabase
    SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
    SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.kUgRPYHRuWJVPfD8iVA7GDuOlj9Xwp6eQ2gH7FJqJ9s'
    
    headers = {
        'apikey': SERVICE_KEY,
        'Authorization': f'Bearer {SERVICE_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("🔍 Configurando bucket 'banners' en Supabase Storage...")
    
    # 1. Crear bucket 'banners'
    print("\n1. Creando bucket 'banners'...")
    bucket_data = {
        'id': 'banners',
        'name': 'banners',
        'public': True,
        'file_size_limit': 5242880,  # 5MB
        'allowed_mime_types': ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    }
    
    response = requests.post(
        f'{SUPABASE_URL}/storage/v1/bucket',
        headers=headers,
        json=bucket_data
    )
    
    print(f"📡 Response Status: {response.status_code}")
    print(f"📊 Response Text: {response.text}")
    
    if response.status_code == 200 or response.status_code == 201:
        print("✅ Bucket 'banners' creado exitosamente")
    elif "already exists" in response.text or "duplicate" in response.text.lower():
        print("✅ Bucket 'banners' ya existe")
    else:
        print(f"❌ Error creando bucket: {response.status_code}")
        return False
    
    # 2. Verificar que el bucket existe
    print("\n2. Verificando bucket...")
    response = requests.get(f'{SUPABASE_URL}/storage/v1/bucket', headers=headers)
    print(f"📡 Response Status: {response.status_code}")
    
    if response.status_code == 200:
        buckets = response.json()
        banner_bucket = next((b for b in buckets if b['name'] == 'banners'), None)
        if banner_bucket:
            print("✅ Bucket 'banners' verificado")
            print(f"📋 Configuración: {json.dumps(banner_bucket, indent=2)}")
        else:
            print("❌ Bucket 'banners' no encontrado después de crear")
            return False
    else:
        print(f"❌ Error verificando bucket: {response.status_code}")
        return False
    
    print("\n✅ Configuración del bucket 'banners' completada")
    print("\n📋 INSTRUCCIONES PARA EL USUARIO:")
    print("1. Ve a Supabase Dashboard → Storage")
    print("2. Verifica que el bucket 'banners' existe")
    print("3. Ve a Authentication → Policies")
    print("4. Ejecuta el siguiente SQL en el SQL Editor:")
    print()
    print("-- Políticas RLS para el bucket 'banners'")
    print("CREATE POLICY \"Public Access Banners\" ON storage.objects FOR SELECT USING (bucket_id = 'banners');")
    print("CREATE POLICY \"Public Upload Banners\" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'banners');")
    print("CREATE POLICY \"Public Update Banners\" ON storage.objects FOR UPDATE USING (bucket_id = 'banners');")
    print("CREATE POLICY \"Public Delete Banners\" ON storage.objects FOR DELETE USING (bucket_id = 'banners');")
    
    return True

if __name__ == "__main__":
    setup_banners_bucket()





"""
Script para crear y configurar el bucket 'banners' en Supabase Storage
"""

import requests
import json

def setup_banners_bucket():
    """Crear bucket 'banners' y configurar políticas RLS"""
    
    # Configuración de Supabase
    SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
    SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.kUgRPYHRuWJVPfD8iVA7GDuOlj9Xwp6eQ2gH7FJqJ9s'
    
    headers = {
        'apikey': SERVICE_KEY,
        'Authorization': f'Bearer {SERVICE_KEY}',
        'Content-Type': 'application/json'
    }
    
    print("🔍 Configurando bucket 'banners' en Supabase Storage...")
    
    # 1. Crear bucket 'banners'
    print("\n1. Creando bucket 'banners'...")
    bucket_data = {
        'id': 'banners',
        'name': 'banners',
        'public': True,
        'file_size_limit': 5242880,  # 5MB
        'allowed_mime_types': ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    }
    
    response = requests.post(
        f'{SUPABASE_URL}/storage/v1/bucket',
        headers=headers,
        json=bucket_data
    )
    
    print(f"📡 Response Status: {response.status_code}")
    print(f"📊 Response Text: {response.text}")
    
    if response.status_code == 200 or response.status_code == 201:
        print("✅ Bucket 'banners' creado exitosamente")
    elif "already exists" in response.text or "duplicate" in response.text.lower():
        print("✅ Bucket 'banners' ya existe")
    else:
        print(f"❌ Error creando bucket: {response.status_code}")
        return False
    
    # 2. Verificar que el bucket existe
    print("\n2. Verificando bucket...")
    response = requests.get(f'{SUPABASE_URL}/storage/v1/bucket', headers=headers)
    print(f"📡 Response Status: {response.status_code}")
    
    if response.status_code == 200:
        buckets = response.json()
        banner_bucket = next((b for b in buckets if b['name'] == 'banners'), None)
        if banner_bucket:
            print("✅ Bucket 'banners' verificado")
            print(f"📋 Configuración: {json.dumps(banner_bucket, indent=2)}")
        else:
            print("❌ Bucket 'banners' no encontrado después de crear")
            return False
    else:
        print(f"❌ Error verificando bucket: {response.status_code}")
        return False
    
    print("\n✅ Configuración del bucket 'banners' completada")
    print("\n📋 INSTRUCCIONES PARA EL USUARIO:")
    print("1. Ve a Supabase Dashboard → Storage")
    print("2. Verifica que el bucket 'banners' existe")
    print("3. Ve a Authentication → Policies")
    print("4. Ejecuta el siguiente SQL en el SQL Editor:")
    print()
    print("-- Políticas RLS para el bucket 'banners'")
    print("CREATE POLICY \"Public Access Banners\" ON storage.objects FOR SELECT USING (bucket_id = 'banners');")
    print("CREATE POLICY \"Public Upload Banners\" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'banners');")
    print("CREATE POLICY \"Public Update Banners\" ON storage.objects FOR UPDATE USING (bucket_id = 'banners');")
    print("CREATE POLICY \"Public Delete Banners\" ON storage.objects FOR DELETE USING (bucket_id = 'banners');")
    
    return True

if __name__ == "__main__":
    setup_banners_bucket()





