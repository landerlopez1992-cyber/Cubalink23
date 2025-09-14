#!/usr/bin/env python3
"""
Script para configurar automáticamente el bucket de Supabase Storage
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

def create_bucket():
    """Crear el bucket product-images"""
    print("🪣 Creando bucket 'product-images'...")
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    bucket_data = {
        "id": "product-images",
        "name": "product-images",
        "public": True,
        "file_size_limit": 52428800,  # 50MB
        "allowed_mime_types": ["image/jpeg", "image/png", "image/gif", "image/webp"]
    }
    
    response = requests.post(
        f'{SUPABASE_URL}/storage/v1/bucket',
        headers=headers,
        json=bucket_data
    )
    
    print(f"📡 Status Code: {response.status_code}")
    print(f"📊 Response: {response.text}")
    
    if response.status_code == 200 or response.status_code == 201:
        print("✅ Bucket creado exitosamente")
        return True
    elif "already exists" in response.text.lower():
        print("ℹ️ El bucket ya existe")
        return True
    else:
        print("❌ Error creando bucket")
        return False

def create_rls_policies():
    """Crear políticas RLS para el bucket"""
    print("\n🔒 Creando políticas RLS...")
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    policies = [
        {
            "name": "Public read access",
            "policy_type": "SELECT",
            "target_roles": ["public"],
            "policy_definition": "bucket_id = 'product-images'"
        },
        {
            "name": "Authenticated users can upload",
            "policy_type": "INSERT", 
            "target_roles": ["authenticated"],
            "policy_definition": "bucket_id = 'product-images'"
        },
        {
            "name": "Authenticated users can update",
            "policy_type": "UPDATE",
            "target_roles": ["authenticated"], 
            "policy_definition": "bucket_id = 'product-images'"
        }
    ]
    
    success_count = 0
    for policy in policies:
        print(f"📝 Creando política: {policy['name']}")
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/storage.policies',
            headers=headers,
            json=policy
        )
        
        print(f"   Status: {response.status_code}")
        if response.status_code in [200, 201]:
            print(f"   ✅ Política '{policy['name']}' creada")
            success_count += 1
        else:
            print(f"   ❌ Error: {response.text}")
    
    return success_count == len(policies)

def test_bucket_after_setup():
    """Probar el bucket después de la configuración"""
    print("\n🧪 Probando bucket después de configuración...")
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
    }
    
    # Listar buckets
    response = requests.get(
        f'{SUPABASE_URL}/storage/v1/bucket',
        headers=headers
    )
    
    print(f"📡 Status Code: {response.status_code}")
    if response.status_code == 200:
        buckets = response.json()
        print(f"📊 Buckets disponibles: {[b['id'] for b in buckets]}")
        
        # Verificar si nuestro bucket existe
        product_bucket = next((b for b in buckets if b['id'] == 'product-images'), None)
        if product_bucket:
            print("✅ Bucket 'product-images' encontrado")
            print(f"   Público: {product_bucket.get('public', False)}")
            return True
        else:
            print("❌ Bucket 'product-images' no encontrado")
            return False
    else:
        print(f"❌ Error: {response.text}")
        return False

def main():
    print("🔧 CONFIGURANDO BUCKET DE SUPABASE STORAGE")
    print("=" * 50)
    
    # Crear bucket
    bucket_created = create_bucket()
    
    if bucket_created:
        # Crear políticas RLS
        policies_created = create_rls_policies()
        
        # Probar configuración
        test_passed = test_bucket_after_setup()
        
        print("\n" + "=" * 50)
        print("📋 RESUMEN DE CONFIGURACIÓN:")
        print(f"🪣 Bucket creado: {'✅ OK' if bucket_created else '❌ ERROR'}")
        print(f"🔒 Políticas RLS: {'✅ OK' if policies_created else '❌ ERROR'}")
        print(f"🧪 Prueba final: {'✅ OK' if test_passed else '❌ ERROR'}")
        
        if bucket_created and policies_created and test_passed:
            print("\n🎉 ¡CONFIGURACIÓN COMPLETADA EXITOSAMENTE!")
            print("Ahora puedes subir imágenes desde el panel admin.")
        else:
            print("\n⚠️ Configuración incompleta. Revisa los errores arriba.")
    else:
        print("\n❌ No se pudo crear el bucket. Verifica tu configuración de Supabase.")

if __name__ == "__main__":
    main()
