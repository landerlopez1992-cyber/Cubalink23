#!/usr/bin/env python3
"""
🖼️ SCRIPT PARA CONFIGURAR BUCKET DE FOTOS DE PERFIL EN SUPABASE
Crea bucket 'user-profiles' con políticas de seguridad
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.wq_9zKkOWXHOXbRJrGZeVhERcJhcKlK5-PFVe5x8IUU'

def create_profiles_bucket():
    """Crear bucket user-profiles en Supabase Storage"""
    
    headers = {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
        'Content-Type': 'application/json'
    }
    
    bucket_data = {
        'id': 'user-profiles',
        'name': 'user-profiles',
        'public': True,
        'file_size_limit': 10485760,  # 10MB para fotos de perfil
        'allowed_mime_types': ['image/jpeg', 'image/png', 'image/webp']
    }
    
    print("🪣 Creando bucket 'user-profiles' en Supabase Storage...")
    
    try:
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/bucket',
            headers=headers,
            json=bucket_data
        )
        
        print(f"📡 Status Code: {response.status_code}")
        print(f"📊 Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ Bucket 'user-profiles' creado exitosamente!")
            return True
        elif response.status_code == 409:
            print("ℹ️ Bucket 'user-profiles' ya existe.")
            return True
        else:
            print(f"❌ Error creando bucket: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def create_storage_policies():
    """Crear políticas RLS para el bucket user-profiles"""
    
    print("🔒 Configurando políticas de seguridad para fotos de perfil...")
    
    headers = {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
        'Content-Type': 'application/json'
    }
    
    policies = [
        {
            'name': 'Public read access for profile images',
            'definition': "bucket_id = 'user-profiles'",
            'action': 'SELECT',
            'roles': ['public']
        },
        {
            'name': 'Users can upload their own profile images',
            'definition': "bucket_id = 'user-profiles' AND auth.uid()::text = (storage.foldername(name))[1]",
            'action': 'INSERT',
            'roles': ['authenticated']
        },
        {
            'name': 'Users can update their own profile images', 
            'definition': "bucket_id = 'user-profiles' AND auth.uid()::text = (storage.foldername(name))[1]",
            'action': 'UPDATE',
            'roles': ['authenticated']
        },
        {
            'name': 'Users can delete their own profile images',
            'definition': "bucket_id = 'user-profiles' AND auth.uid()::text = (storage.foldername(name))[1]",
            'action': 'DELETE', 
            'roles': ['authenticated']
        }
    ]
    
    success_count = 0
    
    for policy in policies:
        try:
            policy_data = {
                'name': policy['name'],
                'definition': policy['definition'],
                'action': policy['action'],
                'roles': policy['roles']
            }
            
            response = requests.post(
                f'{SUPABASE_URL}/rest/v1/rpc/create_storage_policy',
                headers=headers,
                json=policy_data
            )
            
            if response.status_code in [200, 201]:
                print(f"✅ Política creada: {policy['name']}")
                success_count += 1
            else:
                print(f"⚠️ Error en política: {policy['name']} - {response.text}")
                
        except Exception as e:
            print(f"❌ Error creando política {policy['name']}: {e}")
    
    print(f"📊 Políticas creadas: {success_count}/{len(policies)}")
    return success_count == len(policies)

def test_bucket_access():
    """Probar acceso al bucket user-profiles"""
    
    print("🧪 Probando acceso al bucket...")
    
    headers = {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}'
    }
    
    try:
        response = requests.get(
            f'{SUPABASE_URL}/storage/v1/bucket/user-profiles',
            headers=headers
        )
        
        if response.status_code == 200:
            print("✅ Bucket 'user-profiles' accesible correctamente!")
            bucket_info = response.json()
            print(f"📄 Configuración del bucket:")
            print(f"   - Público: {bucket_info.get('public', False)}")
            print(f"   - Límite de tamaño: {bucket_info.get('file_size_limit', 0)} bytes")
            return True
        else:
            print(f"❌ Error accediendo al bucket: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 === CONFIGURACIÓN DE FOTOS DE PERFIL SUPABASE ===")
    print()
    
    # Paso 1: Crear bucket
    if create_profiles_bucket():
        print()
        
        # Paso 2: Crear políticas
        create_storage_policies()
        print()
        
        # Paso 3: Probar acceso
        test_bucket_access()
        print()
        
        print("🎉 === CONFIGURACIÓN COMPLETADA ===")
        print("📱 La app ahora puede:")
        print("   ✅ Subir fotos de perfil a Supabase")
        print("   ✅ Acceder a fotos públicamente")
        print("   ✅ Solo cada usuario puede modificar su propia foto")
        print()
        print("🔗 URLs de ejemplo:")
        print(f"   📁 Bucket: {SUPABASE_URL}/storage/v1/bucket/user-profiles")
        print(f"   🖼️ Imagen: {SUPABASE_URL}/storage/v1/object/public/user-profiles/USER_ID/avatar.jpg")
    else:
        print("❌ No se pudo crear el bucket. Verifica la configuración.")

if __name__ == "__main__":
    main()



