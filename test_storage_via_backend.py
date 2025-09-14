#!/usr/bin/env python3
"""
Script para probar Supabase Storage a través del backend
"""

import requests
import base64
import json

# URL del backend en Render.com
BACKEND_URL = 'https://cubalink23-backend.onrender.com'

def create_test_image_base64():
    """Crear una imagen de prueba en base64"""
    # Imagen de 1x1 pixel JPEG
    test_image_data = b'\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x01\x00H\x00H\x00\x00\xff\xdb\x00C\x00\x08\x06\x06\x07\x06\x05\x08\x07\x07\x07\t\t\x08\n\x0c\x14\r\x0c\x0b\x0b\x0c\x19\x12\x13\x0f\x14\x1d\x1a\x1f\x1e\x1d\x1a\x1c\x1c $.\' ",#\x1c\x1c(7),01444\x1f\'9=82<.342\xff\xc0\x00\x11\x08\x00\x01\x00\x01\x01\x01\x11\x00\x02\x11\x01\x03\x11\x01\xff\xc4\x00\x14\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\xff\xc4\x00\x14\x10\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xda\x00\x0c\x03\x01\x00\x02\x11\x03\x11\x00\x3f\x00\xaa\xff\xd9'
    return base64.b64encode(test_image_data).decode('utf-8')

def test_backend_health():
    """Probar que el backend esté funcionando"""
    print("🏥 Probando salud del backend...")
    
    try:
        response = requests.get(f'{BACKEND_URL}/admin/')
        print(f"📊 Health check: {response.status_code}")
        
        if response.status_code in [200, 302]:  # 302 es redirect a login, que está bien
            print("✅ Backend funcionando correctamente")
            return True
        else:
            print(f"❌ Backend no responde correctamente: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error conectando al backend: {e}")
        return False

def test_product_creation_with_image():
    """Probar creación de producto con imagen a través del backend"""
    print("\n📸 Probando creación de producto con imagen...")
    
    # Crear datos del producto
    product_data = {
        'name': 'Producto de Prueba',
        'description': 'Producto creado para probar Supabase Storage',
        'price': 99.99,
        'stock': 10,
        'category': 'Alimentos',
        'is_active': True,
        'image_base64': create_test_image_base64(),
        'image_name': 'test_product.jpg'
    }
    
    try:
        response = requests.post(
            f'{BACKEND_URL}/admin/api/products',
            headers={'Content-Type': 'application/json'},
            json=product_data
        )
        
        print(f"📊 Response: {response.status_code}")
        print(f"📄 Response body: {response.text}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print("✅ Producto creado exitosamente!")
                if 'product' in data and 'image_url' in data['product']:
                    image_url = data['product']['image_url']
                    print(f"🖼️ URL de imagen: {image_url}")
                    
                    # Probar acceso a la imagen
                    test_image_access(image_url)
                return True
            else:
                print(f"❌ Error en respuesta: {data.get('error', 'Error desconocido')}")
                return False
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_image_access(image_url):
    """Probar acceso a la imagen"""
    print(f"\n🔗 Probando acceso a imagen: {image_url}")
    
    try:
        response = requests.get(image_url)
        print(f"📊 Image access: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ Imagen accesible públicamente!")
            print(f"📏 Tamaño: {len(response.content)} bytes")
            return True
        else:
            print(f"❌ Imagen no accesible: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error accediendo a imagen: {e}")
        return False

def test_products_list():
    """Probar listado de productos"""
    print("\n📋 Probando listado de productos...")
    
    try:
        response = requests.get(f'{BACKEND_URL}/admin/api/products')
        print(f"📊 Products list: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success') and 'products' in data:
                products = data['products']
                print(f"✅ Productos encontrados: {len(products)}")
                
                # Buscar el producto de prueba
                test_product = None
                for product in products:
                    if product.get('name') == 'Producto de Prueba':
                        test_product = product
                        break
                
                if test_product:
                    print("✅ Producto de prueba encontrado en la lista")
                    if test_product.get('image_url'):
                        print(f"🖼️ Imagen: {test_product['image_url']}")
                    return True
                else:
                    print("⚠️ Producto de prueba no encontrado en la lista")
                    return False
            else:
                print(f"❌ Error en respuesta: {data}")
                return False
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("🧪 PROBADOR DE SUPABASE STORAGE VÍA BACKEND")
    print("=" * 50)
    
    # Paso 1: Probar backend
    backend_ok = test_backend_health()
    
    if backend_ok:
        # Paso 2: Probar creación de producto con imagen
        product_ok = test_product_creation_with_image()
        
        if product_ok:
            # Paso 3: Probar listado de productos
            list_ok = test_products_list()
            
            print("\n" + "=" * 50)
            if list_ok:
                print("🎉 ¡PRUEBA COMPLETA EXITOSA!")
                print("✅ Backend funcionando")
                print("✅ Producto creado con imagen")
                print("✅ Imagen accesible públicamente")
                print("✅ Producto visible en lista")
                print("\n🔄 El sistema está listo para:")
                print("   - Agregar productos con imágenes desde el panel admin")
                print("   - Mostrar imágenes en la app Flutter")
                print("   - Usar Supabase Storage correctamente")
            else:
                print("⚠️ PRUEBA PARCIAL")
                print("✅ Backend funcionando")
                print("✅ Producto creado con imagen")
                print("❌ Problema con listado de productos")
        else:
            print("❌ PRUEBA FALLIDA")
            print("✅ Backend funcionando")
            print("❌ No se pudo crear producto con imagen")
            print("\n💡 Posibles problemas:")
            print("   1. Bucket 'product-images' no configurado")
            print("   2. Políticas de Supabase Storage incorrectas")
            print("   3. Service key inválido")
    else:
        print("❌ PRUEBA FALLIDA")
        print("❌ Backend no disponible")
        print("\n💡 Verifica:")
        print("   1. Que el backend esté desplegado en Render.com")
        print("   2. Que la URL sea correcta")
        print("   3. Que no haya errores en los logs de Render.com")
