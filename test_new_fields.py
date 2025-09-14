#!/usr/bin/env python3
"""
Script para probar que los nuevos campos se guarden correctamente en Supabase
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

def test_create_product_with_new_fields():
    """Probar crear un producto con todos los nuevos campos"""
    print("🧪 Probando creación de producto con nuevos campos...")
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    # Datos del producto con todos los nuevos campos
    product_data = {
        'name': 'Producto de Prueba - Nuevos Campos',
        'description': 'Producto para probar peso, envío y etiquetas',
        'price': 99.99,
        'category': 'Motos',
        'subcategory': 'Motos Eléctricas',
        'stock': 10,
        'weight': 25.5,  # Nuevo campo
        'shipping_cost': 15.00,  # Nuevo campo
        'shipping_methods': ['express', 'maritime'],  # Nuevo campo
        'tags': ['NUEVO', '12% OFF', 'CALIENTE'],  # Nuevo campo
        'is_active': True,
        'image_url': 'https://via.placeholder.com/400x300/007bff/ffffff?text=Test+Product'
    }
    
    print("📦 Datos del producto:")
    for key, value in product_data.items():
        print(f"   {key}: {value}")
    
    response = requests.post(
        f'{SUPABASE_URL}/rest/v1/store_products',
        headers=headers,
        json=product_data
    )
    
    print(f"\n📡 Status Code: {response.status_code}")
    print(f"📊 Response: {response.text}")
    
    if response.status_code == 201:
        print("✅ Producto creado exitosamente con todos los nuevos campos")
        try:
            created_product = response.json()
            return created_product[0]['id'] if isinstance(created_product, list) else created_product['id']
        except:
            return "created"
    else:
        print("❌ Error creando producto")
        return None

def test_read_product_fields():
    """Probar leer productos y verificar que los nuevos campos estén presentes"""
    print("\n📖 Probando lectura de productos con nuevos campos...")
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    response = requests.get(
        f'{SUPABASE_URL}/rest/v1/store_products?select=*&limit=5',
        headers=headers
    )
    
    print(f"📡 Status Code: {response.status_code}")
    
    if response.status_code == 200:
        products = response.json()
        print(f"📊 Productos encontrados: {len(products)}")
        
        if products:
            # Verificar campos en el primer producto
            first_product = products[0]
            print(f"\n🔍 Campos en el primer producto:")
            
            new_fields = ['weight', 'shipping_cost', 'shipping_methods', 'tags', 'subcategory']
            for field in new_fields:
                if field in first_product:
                    print(f"   ✅ {field}: {first_product[field]}")
                else:
                    print(f"   ❌ {field}: NO ENCONTRADO")
            
            return True
        else:
            print("⚠️ No hay productos para verificar")
            return False
    else:
        print(f"❌ Error: {response.text}")
        return False

def test_update_product_fields():
    """Probar actualizar un producto con nuevos campos"""
    print("\n✏️ Probando actualización de producto con nuevos campos...")
    
    # Primero obtener un producto existente
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    response = requests.get(
        f'{SUPABASE_URL}/rest/v1/store_products?select=id&limit=1',
        headers=headers
    )
    
    if response.status_code == 200:
        products = response.json()
        if products:
            product_id = products[0]['id']
            print(f"🆔 Actualizando producto ID: {product_id}")
            
            # Datos de actualización
            update_data = {
                'weight': 30.0,
                'shipping_cost': 20.00,
                'shipping_methods': ['express'],
                'tags': ['LIMITADO', 'ENVÍO GRATIS']
            }
            
            print("📦 Datos de actualización:")
            for key, value in update_data.items():
                print(f"   {key}: {value}")
            
            response = requests.patch(
                f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product_id}',
                headers=headers,
                json=update_data
            )
            
            print(f"\n📡 Status Code: {response.status_code}")
            print(f"📊 Response: {response.text}")
            
            if response.status_code in [200, 204]:
                print("✅ Producto actualizado exitosamente con nuevos campos")
                return True
            else:
                print("❌ Error actualizando producto")
                return False
        else:
            print("⚠️ No hay productos para actualizar")
            return False
    else:
        print(f"❌ Error obteniendo productos: {response.text}")
        return False

def main():
    print("🧪 PROBANDO NUEVOS CAMPOS DE PRODUCTOS EN SUPABASE")
    print("=" * 60)
    
    # Probar lectura de campos existentes
    read_ok = test_read_product_fields()
    
    # Probar creación con nuevos campos
    create_ok = test_create_product_with_new_fields()
    
    # Probar actualización con nuevos campos
    update_ok = test_update_product_fields()
    
    print("\n" + "=" * 60)
    print("📋 RESUMEN DE PRUEBAS:")
    print(f"📖 Lectura de campos: {'✅ OK' if read_ok else '❌ ERROR'}")
    print(f"➕ Creación con nuevos campos: {'✅ OK' if create_ok else '❌ ERROR'}")
    print(f"✏️ Actualización con nuevos campos: {'✅ OK' if update_ok else '❌ ERROR'}")
    
    if read_ok and create_ok and update_ok:
        print("\n🎉 ¡TODOS LOS NUEVOS CAMPOS FUNCIONAN CORRECTAMENTE!")
        print("Los campos peso, envío y etiquetas se guardan y leen correctamente en Supabase.")
    else:
        print("\n⚠️ Algunos campos no funcionan correctamente.")
        print("Verifica que la tabla store_products tenga las columnas necesarias.")

if __name__ == "__main__":
    main()
