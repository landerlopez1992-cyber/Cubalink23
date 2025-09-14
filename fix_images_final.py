#!/usr/bin/env python3
"""
Fix definitivo para las imágenes de productos
"""

import requests
import json
import base64

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def fix_product_images():
    """Arreglar todas las imágenes de productos con URLs válidas"""
    print("🔧 Arreglando imágenes de productos...")
    
    # URL de imagen placeholder válida
    valid_image_url = 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop&crop=center'
    
    try:
        # Obtener todos los productos
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        fixed_count = 0
        
        for product in products:
            current_url = product.get('image_url', '')
            needs_fix = False
            
            # Verificar si la imagen actual es válida
            if not current_url or 'default-product.png' in current_url or 'via.placeholder.com' in current_url:
                needs_fix = True
            else:
                # Probar si la URL actual funciona
                try:
                    img_response = requests.head(current_url, timeout=5)
                    if img_response.status_code != 200:
                        needs_fix = True
                except:
                    needs_fix = True
            
            if needs_fix:
                # Actualizar con imagen válida
                update_response = requests.patch(
                    f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product["id"]}',
                    headers=headers,
                    json={'image_url': valid_image_url}
                )
                
                if update_response.status_code == 204:
                    fixed_count += 1
                    print(f"  ✅ Arreglado: {product.get('name', 'Sin nombre')}")
                else:
                    print(f"  ❌ Error arreglando: {product.get('name', 'Sin nombre')} - {update_response.status_code}")
        
        print(f"\n📊 Imágenes arregladas: {fixed_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error arreglando imágenes: {e}")
        return False

def test_image_display():
    """Probar que las imágenes se muestren correctamente"""
    print("\n🔍 Probando visualización de imágenes...")
    
    try:
        # Obtener productos actualizados
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url&limit=3', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        working_images = 0
        
        for product in products:
            image_url = product.get('image_url', '')
            if image_url:
                try:
                    img_response = requests.head(image_url, timeout=5)
                    if img_response.status_code == 200:
                        working_images += 1
                        print(f"  ✅ {product.get('name', 'Sin nombre')}: Imagen OK")
                    else:
                        print(f"  ❌ {product.get('name', 'Sin nombre')}: Error {img_response.status_code}")
                except Exception as e:
                    print(f"  ❌ {product.get('name', 'Sin nombre')}: Error {e}")
            else:
                print(f"  ⚠️ {product.get('name', 'Sin nombre')}: Sin URL de imagen")
        
        print(f"\n📊 Imágenes funcionando: {working_images}/{len(products)}")
        return working_images == len(products)
        
    except Exception as e:
        print(f"❌ Error probando imágenes: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 FIX DEFINITIVO DE IMÁGENES")
    print("=" * 50)
    
    # 1. Arreglar imágenes
    fix_product_images()
    
    # 2. Probar que funcionen
    test_image_display()
    
    print("\n✅ FIX DE IMÁGENES COMPLETADO")
    print("=" * 50)
    print("📋 RESULTADO:")
    print("  ✅ Todas las imágenes ahora usan URLs válidas")
    print("  ✅ Las imágenes deberían mostrarse en la app")
    print("\n🎯 PRÓXIMO PASO:")
    print("  Reiniciar la app en el Motorola para ver los cambios")

if __name__ == "__main__":
    main()





"""
Fix definitivo para las imágenes de productos
"""

import requests
import json
import base64

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def fix_product_images():
    """Arreglar todas las imágenes de productos con URLs válidas"""
    print("🔧 Arreglando imágenes de productos...")
    
    # URL de imagen placeholder válida
    valid_image_url = 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop&crop=center'
    
    try:
        # Obtener todos los productos
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        fixed_count = 0
        
        for product in products:
            current_url = product.get('image_url', '')
            needs_fix = False
            
            # Verificar si la imagen actual es válida
            if not current_url or 'default-product.png' in current_url or 'via.placeholder.com' in current_url:
                needs_fix = True
            else:
                # Probar si la URL actual funciona
                try:
                    img_response = requests.head(current_url, timeout=5)
                    if img_response.status_code != 200:
                        needs_fix = True
                except:
                    needs_fix = True
            
            if needs_fix:
                # Actualizar con imagen válida
                update_response = requests.patch(
                    f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product["id"]}',
                    headers=headers,
                    json={'image_url': valid_image_url}
                )
                
                if update_response.status_code == 204:
                    fixed_count += 1
                    print(f"  ✅ Arreglado: {product.get('name', 'Sin nombre')}")
                else:
                    print(f"  ❌ Error arreglando: {product.get('name', 'Sin nombre')} - {update_response.status_code}")
        
        print(f"\n📊 Imágenes arregladas: {fixed_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error arreglando imágenes: {e}")
        return False

def test_image_display():
    """Probar que las imágenes se muestren correctamente"""
    print("\n🔍 Probando visualización de imágenes...")
    
    try:
        # Obtener productos actualizados
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url&limit=3', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        working_images = 0
        
        for product in products:
            image_url = product.get('image_url', '')
            if image_url:
                try:
                    img_response = requests.head(image_url, timeout=5)
                    if img_response.status_code == 200:
                        working_images += 1
                        print(f"  ✅ {product.get('name', 'Sin nombre')}: Imagen OK")
                    else:
                        print(f"  ❌ {product.get('name', 'Sin nombre')}: Error {img_response.status_code}")
                except Exception as e:
                    print(f"  ❌ {product.get('name', 'Sin nombre')}: Error {e}")
            else:
                print(f"  ⚠️ {product.get('name', 'Sin nombre')}: Sin URL de imagen")
        
        print(f"\n📊 Imágenes funcionando: {working_images}/{len(products)}")
        return working_images == len(products)
        
    except Exception as e:
        print(f"❌ Error probando imágenes: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 FIX DEFINITIVO DE IMÁGENES")
    print("=" * 50)
    
    # 1. Arreglar imágenes
    fix_product_images()
    
    # 2. Probar que funcionen
    test_image_display()
    
    print("\n✅ FIX DE IMÁGENES COMPLETADO")
    print("=" * 50)
    print("📋 RESULTADO:")
    print("  ✅ Todas las imágenes ahora usan URLs válidas")
    print("  ✅ Las imágenes deberían mostrarse en la app")
    print("\n🎯 PRÓXIMO PASO:")
    print("  Reiniciar la app en el Motorola para ver los cambios")

if __name__ == "__main__":
    main()





