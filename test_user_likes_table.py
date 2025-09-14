#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import requests
import json

def test_user_likes_table():
    """Probar la tabla user_likes en Supabase"""
    
    # Cargar variables de entorno
    supabase_url = os.getenv('SUPABASE_URL')
    supabase_key = os.getenv('SUPABASE_ANON_KEY')
    
    if not supabase_url or not supabase_key:
        print("❌ Error: SUPABASE_URL o SUPABASE_ANON_KEY no configurados")
        return False
    
    try:
        print("🔗 Probando tabla user_likes...")
        
        # Headers para la petición
        headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json'
        }
        
        # URL para la tabla user_likes
        url = f"{supabase_url}/rest/v1/user_likes"
        
        # 1. Intentar hacer un SELECT
        print("\n1️⃣ Probando SELECT en user_likes...")
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ SELECT exitoso! Encontrados {len(data)} registros")
            
            if len(data) > 0:
                print("📋 Registros encontrados:")
                for i, record in enumerate(data[:3]):  # Mostrar solo los primeros 3
                    print(f"   {i+1}. Producto: {record.get('product_name', 'N/A')}")
                    print(f"      ID: {record.get('product_id', 'N/A')}")
                    print(f"      Usuario: {record.get('user_id', 'N/A')}")
                    print(f"      Precio: ${record.get('product_price', 'N/A')}")
                    print()
            else:
                print("ℹ️ No hay registros en la tabla user_likes")
                
        elif response.status_code == 404:
            print("❌ Tabla user_likes no existe (404)")
            return False
        else:
            print(f"❌ Error en SELECT: {response.status_code}")
            print(f"Response: {response.text}")
            return False
        
        # 2. Probar estructura de la tabla
        print("\n2️⃣ Probando estructura de la tabla...")
        
        # Intentar insertar un registro de prueba (fallará por foreign key, pero nos dirá si la estructura está bien)
        test_data = {
            'user_id': '00000000-0000-0000-0000-000000000000',  # UUID de prueba
            'product_id': 'test_product_123',
            'product_name': 'Producto de Prueba',
            'product_image_url': 'https://example.com/image.jpg',
            'product_price': 29.99
        }
        
        response = requests.post(url, headers=headers, json=test_data)
        
        if response.status_code == 201:
            print("✅ INSERT exitoso (inesperado)")
            # Eliminar el registro de prueba
            test_id = response.json()[0]['id']
            delete_url = f"{url}?id=eq.{test_id}"
            requests.delete(delete_url, headers=headers)
            print("🧹 Registro de prueba eliminado")
        elif response.status_code == 400:
            error_text = response.text
            if "foreign key" in error_text.lower():
                print("✅ Estructura correcta (error esperado por foreign key)")
            else:
                print(f"❌ Error en estructura: {error_text}")
                return False
        else:
            print(f"❌ Error inesperado en INSERT: {response.status_code}")
            print(f"Response: {response.text}")
            return False
        
        print("\n✅ Tabla user_likes está funcionando correctamente")
        return True
        
    except Exception as e:
        print(f"❌ Error general: {e}")
        return False

if __name__ == "__main__":
    success = test_user_likes_table()
    if success:
        print("\n🎉 ¡La tabla user_likes está funcionando correctamente!")
        print("El problema puede estar en el código de la app Flutter.")
    else:
        print("\n💥 Hay problemas con la tabla user_likes")
        sys.exit(1)






