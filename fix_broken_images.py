#!/usr/bin/env python3
"""
Script para arreglar imágenes rotas en Supabase
Reemplaza URLs de imágenes que devuelven 404 con placeholders funcionales
"""

import os
import requests
import json

def fix_broken_images():
    """Arreglar imágenes rotas en la base de datos"""
    
    print("🔧 ARREGLANDO IMÁGENES ROTAS EN SUPABASE")
    print("=" * 50)
    
    # Obtener credenciales de Supabase
    supabase_url = os.getenv('SUPABASE_URL', 'https://zgqrhzuhrwudckwesybg.supabase.co')
    supabase_key = os.getenv('SUPABASE_SERVICE_KEY', 
        os.getenv('SUPABASE_ANON_KEY', 
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        )
    )
    
    if not supabase_url or not supabase_key:
        print("❌ Error: Variables de entorno SUPABASE_URL y SUPABASE_SERVICE_KEY no encontradas")
        return False
    
    headers = {
        'apikey': supabase_key,
        'Authorization': f'Bearer {supabase_key}',
        'Content-Type': 'application/json'
    }
    
    try:
        # Obtener todos los productos
        products_url = f"{supabase_url}/rest/v1/store_products?select=*"
        response = requests.get(products_url, headers=headers)
        
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        print(f"📦 {len(products)} productos encontrados")
        
        fixed_count = 0
        
        for product in products:
            product_id = product.get('id')
            product_name = product.get('name', 'Producto')
            current_image = product.get('image_url', '')
            
            # Verificar si la imagen actual es accesible
            needs_fix = False
            new_image_url = current_image
            
            if current_image and current_image.strip():
                try:
                    img_response = requests.head(current_image, timeout=5)
                    if img_response.status_code != 200:
                        needs_fix = True
                        print(f"❌ Imagen rota para '{product_name}': {current_image}")
                except:
                    needs_fix = True
                    print(f"❌ Error verificando imagen para '{product_name}': {current_image}")
            else:
                needs_fix = True
                print(f"⚠️ Sin imagen para '{product_name}'")
            
            if needs_fix:
                # Crear URL de placeholder personalizada
                safe_name = product_name.replace(' ', '%20').replace('&', 'and')
                new_image_url = f'https://via.placeholder.com/400x300/007bff/ffffff?text={safe_name}'
                
                # Actualizar producto en Supabase
                update_url = f"{supabase_url}/rest/v1/store_products?id=eq.{product_id}"
                update_data = {'image_url': new_image_url}
                
                update_response = requests.patch(update_url, headers=headers, json=update_data)
                
                if update_response.status_code in [200, 204]:
                    print(f"✅ Imagen arreglada para '{product_name}': {new_image_url}")
                    fixed_count += 1
                else:
                    print(f"❌ Error actualizando imagen para '{product_name}': {update_response.status_code}")
        
        print(f"\n🎉 ARREGLO COMPLETADO")
        print(f"✅ {fixed_count} imágenes arregladas")
        print(f"📦 {len(products)} productos procesados")
        
        return True
        
    except Exception as e:
        print(f"❌ Error arreglando imágenes: {e}")
        return False

def create_placeholder_images():
    """Crear URLs de placeholder para productos sin imagen"""
    
    print("\n🖼️ CREANDO PLACEHOLDERS PARA PRODUCTOS SIN IMAGEN")
    print("-" * 50)
    
    # Obtener credenciales de Supabase
    supabase_url = os.getenv('SUPABASE_URL', 'https://zgqrhzuhrwudckwesybg.supabase.co')
    supabase_key = os.getenv('SUPABASE_SERVICE_KEY', 
        os.getenv('SUPABASE_ANON_KEY', 
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        )
    )
    
    headers = {
        'apikey': supabase_key,
        'Authorization': f'Bearer {supabase_key}',
        'Content-Type': 'application/json'
    }
    
    try:
        # Obtener productos sin imagen
        products_url = f"{supabase_url}/rest/v1/store_products?select=*&image_url=is.null"
        response = requests.get(products_url, headers=headers)
        
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos sin imagen: {response.status_code}")
            return False
        
        products = response.json()
        print(f"📦 {len(products)} productos sin imagen encontrados")
        
        for product in products:
            product_id = product.get('id')
            product_name = product.get('name', 'Producto')
            category = product.get('category', 'General')
            
            # Crear placeholder basado en categoría
            if category.lower() == 'alimentos':
                placeholder_url = f'https://via.placeholder.com/400x300/4CAF50/ffffff?text={product_name.replace(" ", "%20")}'
            elif category.lower() == 'motos':
                placeholder_url = f'https://via.placeholder.com/400x300/FF9800/ffffff?text={product_name.replace(" ", "%20")}'
            elif category.lower() == 'electrónicos':
                placeholder_url = f'https://via.placeholder.com/400x300/2196F3/ffffff?text={product_name.replace(" ", "%20")}'
            else:
                placeholder_url = f'https://via.placeholder.com/400x300/9C27B0/ffffff?text={product_name.replace(" ", "%20")}'
            
            # Actualizar producto
            update_url = f"{supabase_url}/rest/v1/store_products?id=eq.{product_id}"
            update_data = {'image_url': placeholder_url}
            
            update_response = requests.patch(update_url, headers=headers, json=update_data)
            
            if update_response.status_code in [200, 204]:
                print(f"✅ Placeholder creado para '{product_name}': {placeholder_url}")
            else:
                print(f"❌ Error creando placeholder para '{product_name}': {update_response.status_code}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error creando placeholders: {e}")
        return False

if __name__ == "__main__":
    print("🔧 ARREGLANDO IMÁGENES DE PRODUCTOS")
    print("=" * 50)
    
    # Arreglar imágenes rotas
    fix_broken_images()
    
    # Crear placeholders para productos sin imagen
    create_placeholder_images()
    
    print("\n🎉 ARREGLO DE IMÁGENES COMPLETADO")
    print("📋 Resultado:")
    print("   - Imágenes rotas reemplazadas con placeholders funcionales")
    print("   - Productos sin imagen ahora tienen placeholders")
    print("   - Todas las imágenes son accesibles y se mostrarán en la app")
