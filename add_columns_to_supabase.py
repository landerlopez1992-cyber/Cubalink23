#!/usr/bin/env python3
"""
Script para agregar las columnas faltantes a la tabla store_products en Supabase
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

def execute_sql(sql_command):
    """Ejecutar comando SQL en Supabase"""
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    data = {
        'query': sql_command
    }
    
    response = requests.post(
        f'{SUPABASE_URL}/rest/v1/rpc/exec_sql',
        headers=headers,
        json=data
    )
    
    return response

def add_missing_columns():
    """Agregar las columnas faltantes a la tabla store_products"""
    print("🔧 Agregando columnas faltantes a la tabla store_products...")
    
    # Lista de comandos SQL para agregar las columnas
    sql_commands = [
        "ALTER TABLE store_products ADD COLUMN IF NOT EXISTS subcategory TEXT;",
        "ALTER TABLE store_products ADD COLUMN IF NOT EXISTS weight DECIMAL(10,2);",
        "ALTER TABLE store_products ADD COLUMN IF NOT EXISTS shipping_cost DECIMAL(10,2) DEFAULT 0;",
        "ALTER TABLE store_products ADD COLUMN IF NOT EXISTS shipping_methods JSONB DEFAULT '[]'::jsonb;",
        "ALTER TABLE store_products ADD COLUMN IF NOT EXISTS tags JSONB DEFAULT '[]'::jsonb;"
    ]
    
    success_count = 0
    
    for i, sql in enumerate(sql_commands, 1):
        print(f"📝 Ejecutando comando {i}/{len(sql_commands)}: {sql[:50]}...")
        
        response = execute_sql(sql)
        
        print(f"   Status: {response.status_code}")
        if response.status_code in [200, 201]:
            print(f"   ✅ Comando ejecutado exitosamente")
            success_count += 1
        else:
            print(f"   ❌ Error: {response.text}")
    
    return success_count == len(sql_commands)

def verify_columns():
    """Verificar que las columnas se agregaron correctamente"""
    print("\n🔍 Verificando que las columnas se agregaron correctamente...")
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    # Intentar leer un producto con los nuevos campos
    response = requests.get(
        f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,subcategory,weight,shipping_cost,shipping_methods,tags&limit=1',
        headers=headers
    )
    
    print(f"📡 Status Code: {response.status_code}")
    
    if response.status_code == 200:
        products = response.json()
        if products:
            product = products[0]
            print("✅ Columnas verificadas exitosamente:")
            for field in ['subcategory', 'weight', 'shipping_cost', 'shipping_methods', 'tags']:
                if field in product:
                    print(f"   ✅ {field}: {product[field]}")
                else:
                    print(f"   ❌ {field}: NO ENCONTRADO")
            return True
        else:
            print("⚠️ No hay productos para verificar")
            return False
    else:
        print(f"❌ Error: {response.text}")
        return False

def test_create_with_new_fields():
    """Probar crear un producto con los nuevos campos"""
    print("\n🧪 Probando creación de producto con nuevos campos...")
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    product_data = {
        'name': 'Producto Test - Nuevos Campos',
        'description': 'Producto de prueba',
        'price': 50.00,
        'category': 'Motos',
        'subcategory': 'Motos Eléctricas',
        'stock': 5,
        'weight': 20.5,
        'shipping_cost': 10.00,
        'shipping_methods': ['express'],
        'tags': ['NUEVO', 'TEST'],
        'is_active': True,
        'image_url': 'https://via.placeholder.com/400x300/007bff/ffffff?text=Test'
    }
    
    response = requests.post(
        f'{SUPABASE_URL}/rest/v1/store_products',
        headers=headers,
        json=product_data
    )
    
    print(f"📡 Status Code: {response.status_code}")
    print(f"📊 Response: {response.text}")
    
    if response.status_code == 201:
        print("✅ Producto creado exitosamente con todos los nuevos campos")
        return True
    else:
        print("❌ Error creando producto")
        return False

def main():
    print("🔧 AGREGANDO COLUMNAS FALTANTES A SUPABASE")
    print("=" * 50)
    
    # Agregar columnas
    columns_added = add_missing_columns()
    
    if columns_added:
        # Verificar columnas
        verification_ok = verify_columns()
        
        if verification_ok:
            # Probar creación
            test_ok = test_create_with_new_fields()
            
            print("\n" + "=" * 50)
            print("📋 RESUMEN:")
            print(f"🔧 Columnas agregadas: {'✅ OK' if columns_added else '❌ ERROR'}")
            print(f"🔍 Verificación: {'✅ OK' if verification_ok else '❌ ERROR'}")
            print(f"🧪 Prueba de creación: {'✅ OK' if test_ok else '❌ ERROR'}")
            
            if columns_added and verification_ok and test_ok:
                print("\n🎉 ¡TODAS LAS COLUMNAS AGREGADAS EXITOSAMENTE!")
                print("Ahora el panel admin puede guardar peso, envío y etiquetas correctamente.")
            else:
                print("\n⚠️ Algunos pasos fallaron. Revisa los errores arriba.")
        else:
            print("\n❌ Error en la verificación de columnas")
    else:
        print("\n❌ Error agregando columnas")

if __name__ == "__main__":
    main()
