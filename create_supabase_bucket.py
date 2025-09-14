#!/usr/bin/env python3
"""
Script para crear el bucket 'product-images' en Supabase Storage
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.wq_9zKkOWXHOXbRJrGZeVhERcJhcKlK5-PFVe5x8IUU'

def create_bucket():
    """Crear bucket product-images en Supabase Storage"""
    
    headers = {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
        'Content-Type': 'application/json'
    }
    
    bucket_data = {
        'id': 'product-images',
        'name': 'product-images',
        'public': True,
        'file_size_limit': 52428800,  # 50MB
        'allowed_mime_types': ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    }
    
    print("🔧 Creando bucket 'product-images' en Supabase Storage...")
    
    response = requests.post(
        f'{SUPABASE_URL}/storage/v1/bucket',
        headers=headers,
        json=bucket_data
    )
    
    print(f"📡 Status Code: {response.status_code}")
    print(f"📊 Response: {response.text}")
    
    if response.status_code == 200:
        print("✅ Bucket 'product-images' creado exitosamente!")
        return True
    elif response.status_code == 409:
        print("ℹ️ Bucket 'product-images' ya existe.")
        return True
    else:
        print(f"❌ Error creando bucket: {response.status_code} - {response.text}")
        return False

def set_bucket_policy():
    """Configurar política pública para el bucket"""
    
    headers = {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
        'Content-Type': 'application/json'
    }
    
    # Política para permitir lectura pública y escritura autenticada
    policy_data = {
        'policies': [
            {
                'id': 'product-images-public-read',
                'bucket_id': 'product-images',
                'policy': 'CREATE POLICY "Public read access" ON storage.objects FOR SELECT USING (bucket_id = \'product-images\');'
            },
            {
                'id': 'product-images-authenticated-write',
                'bucket_id': 'product-images', 
                'policy': 'CREATE POLICY "Authenticated users can upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = \'product-images\');'
            }
        ]
    }
    
    print("🔧 Configurando políticas del bucket...")
    
    # Nota: Las políticas se configuran mejor desde el dashboard de Supabase
    # Este script crea el bucket, las políticas se configuran manualmente
    
    return True

if __name__ == "__main__":
    print("🚀 Iniciando configuración de Supabase Storage...")
    
    if create_bucket():
        print("✅ Bucket configurado correctamente!")
        print("\n📋 Próximos pasos:")
        print("1. Ve a https://supabase.com/dashboard/project/zgqrhzuhrwudckwesybg/storage/buckets")
        print("2. Verifica que el bucket 'product-images' existe")
        print("3. Configura las políticas públicas si es necesario")
    else:
        print("❌ Error en la configuración del bucket")
