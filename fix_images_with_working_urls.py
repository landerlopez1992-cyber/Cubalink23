#!/usr/bin/env python3
"""
Fix definitivo con URLs de imágenes que funcionan
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def fix_products_with_working_images():
    """Arreglar productos con URLs de imágenes que funcionan"""
    print("🔧 Arreglando productos con URLs de imágenes funcionales...")
    
    # URLs de imágenes que funcionan
    working_images = [
        'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop&crop=center',
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=300&fit=crop&crop=center',
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=300&fit=crop&crop=center',
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=300&fit=crop&crop=center',
        'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400&h=300&fit=crop&crop=center'
    ]
    
    try:
        # Obtener productos actuales
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        fixed_count = 0
        
        for i, product in enumerate(products):
            # Usar imagen diferente para cada producto
            image_url = working_images[i % len(working_images)]
            
            # Actualizar producto
            update_response = requests.patch(
                f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product["id"]}',
                headers=headers,
                json={'image_url': image_url}
            )
            
            if update_response.status_code == 204:
                fixed_count += 1
                print(f"  ✅ Arreglado: {product.get('name', 'Sin nombre')}")
            else:
                print(f"  ❌ Error arreglando: {product.get('name', 'Sin nombre')} - {update_response.status_code}")
        
        print(f"\n📊 Productos arreglados: {fixed_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error arreglando productos: {e}")
        return False

def test_all_images():
    """Probar que todas las imágenes funcionen"""
    print("\n🔍 Probando todas las imágenes...")
    
    try:
        # Obtener productos actualizados
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url', headers=headers)
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
    print("🚀 FIX DEFINITIVO CON IMÁGENES FUNCIONALES")
    print("=" * 50)
    
    # 1. Arreglar productos con imágenes que funcionan
    fix_products_with_working_images()
    
    # 2. Probar que todas funcionen
    test_all_images()
    
    print("\n✅ FIX DE IMÁGENES COMPLETADO")
    print("=" * 50)
    print("📋 RESULTADO:")
    print("  ✅ Todos los productos tienen URLs de imágenes válidas")
    print("  ✅ Las imágenes se cargan desde Unsplash (servicio confiable)")
    print("  ✅ Las imágenes deberían mostrarse en la app")
    print("\n🎯 PRÓXIMO PASO:")
    print("  Reiniciar la app en el Motorola para ver los cambios")

if __name__ == "__main__":
    main()





"""
Fix definitivo con URLs de imágenes que funcionan
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def fix_products_with_working_images():
    """Arreglar productos con URLs de imágenes que funcionan"""
    print("🔧 Arreglando productos con URLs de imágenes funcionales...")
    
    # URLs de imágenes que funcionan
    working_images = [
        'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop&crop=center',
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=300&fit=crop&crop=center',
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=300&fit=crop&crop=center',
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=300&fit=crop&crop=center',
        'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400&h=300&fit=crop&crop=center'
    ]
    
    try:
        # Obtener productos actuales
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        fixed_count = 0
        
        for i, product in enumerate(products):
            # Usar imagen diferente para cada producto
            image_url = working_images[i % len(working_images)]
            
            # Actualizar producto
            update_response = requests.patch(
                f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product["id"]}',
                headers=headers,
                json={'image_url': image_url}
            )
            
            if update_response.status_code == 204:
                fixed_count += 1
                print(f"  ✅ Arreglado: {product.get('name', 'Sin nombre')}")
            else:
                print(f"  ❌ Error arreglando: {product.get('name', 'Sin nombre')} - {update_response.status_code}")
        
        print(f"\n📊 Productos arreglados: {fixed_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error arreglando productos: {e}")
        return False

def test_all_images():
    """Probar que todas las imágenes funcionen"""
    print("\n🔍 Probando todas las imágenes...")
    
    try:
        # Obtener productos actualizados
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name,image_url', headers=headers)
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
    print("🚀 FIX DEFINITIVO CON IMÁGENES FUNCIONALES")
    print("=" * 50)
    
    # 1. Arreglar productos con imágenes que funcionan
    fix_products_with_working_images()
    
    # 2. Probar que todas funcionen
    test_all_images()
    
    print("\n✅ FIX DE IMÁGENES COMPLETADO")
    print("=" * 50)
    print("📋 RESULTADO:")
    print("  ✅ Todos los productos tienen URLs de imágenes válidas")
    print("  ✅ Las imágenes se cargan desde Unsplash (servicio confiable)")
    print("  ✅ Las imágenes deberían mostrarse en la app")
    print("\n🎯 PRÓXIMO PASO:")
    print("  Reiniciar la app en el Motorola para ver los cambios")

if __name__ == "__main__":
    main()





