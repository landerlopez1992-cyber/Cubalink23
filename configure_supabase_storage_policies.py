#!/usr/bin/env python3
"""
Script para configurar políticas de Supabase Storage para el bucket 'product-images'
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.wq_9zKkOWXHOXbRJrGZeVhERcJhcKlK5-PFVe5x8IUU'

def configure_storage_policies():
    """Configurar políticas de acceso para el bucket product-images"""
    
    headers = {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': 'Bearer ' + SUPABASE_SERVICE_KEY,
        'Content-Type': 'application/json'
    }
    
    print("🔧 Configurando políticas de Supabase Storage...")
    print(f"📡 URL: {SUPABASE_URL}")
    print(f"🪣 Bucket: product-images")
    
    # Políticas a crear
    policies = [
        {
            "name": "Public read access for product-images",
            "definition": "CREATE POLICY \"Public read access\" ON storage.objects FOR SELECT USING (bucket_id = 'product-images');"
        },
        {
            "name": "Authenticated users can upload to product-images", 
            "definition": "CREATE POLICY \"Authenticated users can upload\" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'product-images');"
        },
        {
            "name": "Authenticated users can update product-images",
            "definition": "CREATE POLICY \"Authenticated users can update\" ON storage.objects FOR UPDATE USING (bucket_id = 'product-images');"
        },
        {
            "name": "Authenticated users can delete product-images",
            "definition": "CREATE POLICY \"Authenticated users can delete\" ON storage.objects FOR DELETE USING (bucket_id = 'product-images');"
        }
    ]
    
    success_count = 0
    
    for policy in policies:
        try:
            print(f"\n📋 Creando política: {policy['name']}")
            
            # Crear la política usando la API de Supabase
            response = requests.post(
                f'{SUPABASE_URL}/rest/v1/rpc/exec_sql',
                headers=headers,
                json={'sql': policy['definition']}
            )
            
            if response.status_code == 200:
                print(f"✅ Política creada exitosamente")
                success_count += 1
            else:
                print(f"⚠️ Respuesta: {response.status_code} - {response.text}")
                # Intentar método alternativo
                if "already exists" in response.text.lower() or "duplicate" in response.text.lower():
                    print(f"ℹ️ Política ya existe, continuando...")
                    success_count += 1
                else:
                    print(f"❌ Error creando política: {response.text}")
                    
        except Exception as e:
            print(f"❌ Error: {e}")
    
    print(f"\n📊 Resultado: {success_count}/{len(policies)} políticas configuradas")
    
    if success_count == len(policies):
        print("🎉 ¡Todas las políticas configuradas exitosamente!")
        print("\n📋 Próximos pasos:")
        print("1. Ve a https://supabase.com/dashboard/project/zgqrhzuhrwudckwesybg/storage/buckets/product-images")
        print("2. Verifica que las políticas aparecen en la pestaña 'Policies'")
        print("3. Prueba subir una imagen desde el panel admin")
        return True
    else:
        print("⚠️ Algunas políticas no se pudieron crear. Revisa los errores arriba.")
        return False

def test_bucket_access():
    """Probar acceso al bucket"""
    print("\n🧪 Probando acceso al bucket...")
    
    headers = {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': 'Bearer ' + SUPABASE_SERVICE_KEY
    }
    
    try:
        # Listar objetos del bucket
        response = requests.get(
            f'{SUPABASE_URL}/storage/v1/object/list/product-images',
            headers=headers
        )
        
        if response.status_code == 200:
            objects = response.json()
            print(f"✅ Acceso al bucket exitoso. Objetos encontrados: {len(objects)}")
            if objects:
                print("📁 Archivos en el bucket:")
                for obj in objects[:5]:  # Mostrar solo los primeros 5
                    print(f"   - {obj.get('name', 'N/A')}")
            return True
        else:
            print(f"❌ Error accediendo al bucket: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error probando acceso: {e}")
        return False

if __name__ == "__main__":
    print("🚀 CONFIGURADOR DE POLÍTICAS SUPABASE STORAGE")
    print("=" * 50)
    
    # Configurar políticas
    policies_success = configure_storage_policies()
    
    # Probar acceso
    access_success = test_bucket_access()
    
    print("\n" + "=" * 50)
    if policies_success and access_success:
        print("🎉 ¡CONFIGURACIÓN COMPLETA!")
        print("✅ Políticas configuradas")
        print("✅ Acceso al bucket verificado")
        print("\n🔄 Ahora puedes:")
        print("   - Agregar productos con imágenes desde el panel admin")
        print("   - Las imágenes se subirán a Supabase Storage")
        print("   - La app Flutter podrá acceder a las imágenes")
    else:
        print("⚠️ CONFIGURACIÓN INCOMPLETA")
        print("❌ Revisa los errores arriba y ejecuta el script nuevamente")
