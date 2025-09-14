#!/usr/bin/env python3
"""
Verificar que el producto se guardó correctamente
"""

import requests
import json

SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

print('🔍 Verificando el producto más reciente...')
response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=*&order=created_at.desc&limit=1', headers=headers)
if response.status_code == 200:
    products = response.json()
    if products:
        product = products[0]
        print(f'📦 Producto: {product.get("name", "Sin nombre")}')
        print(f'💰 Precio: ${product.get("price", 0)}')
        print(f'📦 Stock: {product.get("stock", 0)}')
        print(f'🚚 Shipping Cost: ${product.get("shipping_cost", 0)}')
        print(f'⚖️ Weight: {product.get("weight", 0)} kg')
        print(f'📂 Subcategory: {product.get("subcategory", "N/A")}')
        print(f'🚚 Shipping Methods: {product.get("shipping_methods", [])}')
        print(f'🏷️ Tags: {product.get("tags", [])}')
        print(f'🖼️ Imagen: {product.get("image_url", "Sin imagen")[:80]}...')
        print(f'📅 Creado: {product.get("created_at", "N/A")}')
        print('✅ ¡PRODUCTO GUARDADO EXITOSAMENTE CON TODAS LAS COLUMNAS!')
    else:
        print('❌ No se encontraron productos')
else:
    print(f'❌ Error: {response.status_code}')





"""
Verificar que el producto se guardó correctamente
"""

import requests
import json

SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

print('🔍 Verificando el producto más reciente...')
response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=*&order=created_at.desc&limit=1', headers=headers)
if response.status_code == 200:
    products = response.json()
    if products:
        product = products[0]
        print(f'📦 Producto: {product.get("name", "Sin nombre")}')
        print(f'💰 Precio: ${product.get("price", 0)}')
        print(f'📦 Stock: {product.get("stock", 0)}')
        print(f'🚚 Shipping Cost: ${product.get("shipping_cost", 0)}')
        print(f'⚖️ Weight: {product.get("weight", 0)} kg')
        print(f'📂 Subcategory: {product.get("subcategory", "N/A")}')
        print(f'🚚 Shipping Methods: {product.get("shipping_methods", [])}')
        print(f'🏷️ Tags: {product.get("tags", [])}')
        print(f'🖼️ Imagen: {product.get("image_url", "Sin imagen")[:80]}...')
        print(f'📅 Creado: {product.get("created_at", "N/A")}')
        print('✅ ¡PRODUCTO GUARDADO EXITOSAMENTE CON TODAS LAS COLUMNAS!')
    else:
        print('❌ No se encontraron productos')
else:
    print(f'❌ Error: {response.status_code}')





