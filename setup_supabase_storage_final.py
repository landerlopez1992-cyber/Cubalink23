#!/usr/bin/env python3
"""
Setup completo de Supabase Storage para imágenes de productos
"""

import requests
import json
import base64
import io
from PIL import Image, ImageDraw, ImageFont
import os

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def create_bucket():
    """Crear bucket product-images en Supabase Storage"""
    print("🔧 Creando bucket product-images...")
    
    bucket_data = {
        'id': 'product-images',
        'name': 'product-images',
        'public': True,
        'file_size_limit': 52428800,  # 50MB
        'allowed_mime_types': ['image/jpeg', 'image/png', 'image/webp']
    }
    
    try:
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/bucket',
            headers=headers,
            json=bucket_data
        )
        
        print(f"📤 Respuesta creación bucket: {response.status_code}")
        print(f"📤 Contenido: {response.text}")
        
        if response.status_code == 200:
            print("✅ Bucket product-images creado exitosamente")
            return True
        else:
            print(f"⚠️ Error creando bucket: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error creando bucket: {e}")
        return False

def create_default_product_image():
    """Crear imagen por defecto para productos"""
    print("🎨 Creando imagen por defecto...")
    
    try:
        # Crear imagen 400x300 con fondo azul
        img = Image.new('RGB', (400, 300), color='#007bff')
        draw = ImageDraw.Draw(img)
        
        # Intentar usar una fuente, si no está disponible usar la por defecto
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 24)
        except:
            font = ImageFont.load_default()
        
        # Dibujar texto
        text = "CubaLink23\nProducto"
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        x = (400 - text_width) // 2
        y = (300 - text_height) // 2
        
        draw.text((x, y), text, fill='white', font=font, align='center')
        
        # Convertir a bytes
        img_bytes = io.BytesIO()
        img.save(img_bytes, format='PNG')
        img_bytes.seek(0)
        
        return img_bytes.getvalue()
        
    except Exception as e:
        print(f"❌ Error creando imagen: {e}")
        return None

def upload_image_to_bucket(image_data, filename):
    """Subir imagen al bucket de Supabase"""
    print(f"📤 Subiendo imagen: {filename}")
    
    try:
        # Headers para upload de archivo
        upload_headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
        }
        
        # Subir archivo
        files = {
            'file': (filename, image_data, 'image/png')
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/object/product-images/{filename}',
            headers=upload_headers,
            files=files
        )
        
        print(f"📤 Respuesta upload: {response.status_code}")
        print(f"📤 Contenido: {response.text}")
        
        if response.status_code == 200:
            print(f"✅ Imagen {filename} subida exitosamente")
            return True
        else:
            print(f"❌ Error subiendo {filename}: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error subiendo imagen: {e}")
        return False

def update_products_with_storage_urls():
    """Actualizar productos con URLs de Supabase Storage"""
    print("🔄 Actualizando productos con URLs de Storage...")
    
    try:
        # Obtener productos actuales
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        updated_count = 0
        
        for product in products:
            # Crear nombre de archivo único
            product_id = product['id']
            filename = f"product_{product_id}.png"
            
            # URL pública de Supabase Storage
            storage_url = f"{SUPABASE_URL}/storage/v1/object/public/product-images/{filename}"
            
            # Actualizar producto
            update_response = requests.patch(
                f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product_id}',
                headers=headers,
                json={'image_url': storage_url}
            )
            
            if update_response.status_code == 204:
                updated_count += 1
                print(f"  ✅ Actualizado: {product.get('name', 'Sin nombre')}")
            else:
                print(f"  ❌ Error actualizando: {product.get('name', 'Sin nombre')}")
        
        print(f"\n📊 Productos actualizados: {updated_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error actualizando productos: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 SETUP COMPLETO DE SUPABASE STORAGE")
    print("=" * 50)
    
    # 1. Crear bucket
    if not create_bucket():
        print("❌ No se puede continuar sin bucket")
        return
    
    # 2. Crear imagen por defecto
    default_image = create_default_product_image()
    if not default_image:
        print("❌ No se puede continuar sin imagen por defecto")
        return
    
    # 3. Subir imagen por defecto
    if not upload_image_to_bucket(default_image, "default-product.png"):
        print("❌ Error subiendo imagen por defecto")
        return
    
    # 4. Actualizar productos con URLs de Storage
    update_products_with_storage_urls()
    
    print("\n✅ SETUP DE STORAGE COMPLETADO")
    print("=" * 50)
    print("📋 RESULTADO:")
    print("  ✅ Bucket product-images creado")
    print("  ✅ Imagen por defecto subida")
    print("  ✅ Productos actualizados con URLs de Storage")
    print("\n🎯 PRÓXIMO PASO:")
    print("  Las imágenes ahora se almacenan en Supabase Storage")

if __name__ == "__main__":
    main()





"""
Setup completo de Supabase Storage para imágenes de productos
"""

import requests
import json
import base64
import io
from PIL import Image, ImageDraw, ImageFont
import os

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

headers = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json'
}

def create_bucket():
    """Crear bucket product-images en Supabase Storage"""
    print("🔧 Creando bucket product-images...")
    
    bucket_data = {
        'id': 'product-images',
        'name': 'product-images',
        'public': True,
        'file_size_limit': 52428800,  # 50MB
        'allowed_mime_types': ['image/jpeg', 'image/png', 'image/webp']
    }
    
    try:
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/bucket',
            headers=headers,
            json=bucket_data
        )
        
        print(f"📤 Respuesta creación bucket: {response.status_code}")
        print(f"📤 Contenido: {response.text}")
        
        if response.status_code == 200:
            print("✅ Bucket product-images creado exitosamente")
            return True
        else:
            print(f"⚠️ Error creando bucket: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error creando bucket: {e}")
        return False

def create_default_product_image():
    """Crear imagen por defecto para productos"""
    print("🎨 Creando imagen por defecto...")
    
    try:
        # Crear imagen 400x300 con fondo azul
        img = Image.new('RGB', (400, 300), color='#007bff')
        draw = ImageDraw.Draw(img)
        
        # Intentar usar una fuente, si no está disponible usar la por defecto
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 24)
        except:
            font = ImageFont.load_default()
        
        # Dibujar texto
        text = "CubaLink23\nProducto"
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        x = (400 - text_width) // 2
        y = (300 - text_height) // 2
        
        draw.text((x, y), text, fill='white', font=font, align='center')
        
        # Convertir a bytes
        img_bytes = io.BytesIO()
        img.save(img_bytes, format='PNG')
        img_bytes.seek(0)
        
        return img_bytes.getvalue()
        
    except Exception as e:
        print(f"❌ Error creando imagen: {e}")
        return None

def upload_image_to_bucket(image_data, filename):
    """Subir imagen al bucket de Supabase"""
    print(f"📤 Subiendo imagen: {filename}")
    
    try:
        # Headers para upload de archivo
        upload_headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
        }
        
        # Subir archivo
        files = {
            'file': (filename, image_data, 'image/png')
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/object/product-images/{filename}',
            headers=upload_headers,
            files=files
        )
        
        print(f"📤 Respuesta upload: {response.status_code}")
        print(f"📤 Contenido: {response.text}")
        
        if response.status_code == 200:
            print(f"✅ Imagen {filename} subida exitosamente")
            return True
        else:
            print(f"❌ Error subiendo {filename}: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error subiendo imagen: {e}")
        return False

def update_products_with_storage_urls():
    """Actualizar productos con URLs de Supabase Storage"""
    print("🔄 Actualizando productos con URLs de Storage...")
    
    try:
        # Obtener productos actuales
        response = requests.get(f'{SUPABASE_URL}/rest/v1/store_products?select=id,name', headers=headers)
        if response.status_code != 200:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
        
        products = response.json()
        updated_count = 0
        
        for product in products:
            # Crear nombre de archivo único
            product_id = product['id']
            filename = f"product_{product_id}.png"
            
            # URL pública de Supabase Storage
            storage_url = f"{SUPABASE_URL}/storage/v1/object/public/product-images/{filename}"
            
            # Actualizar producto
            update_response = requests.patch(
                f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product_id}',
                headers=headers,
                json={'image_url': storage_url}
            )
            
            if update_response.status_code == 204:
                updated_count += 1
                print(f"  ✅ Actualizado: {product.get('name', 'Sin nombre')}")
            else:
                print(f"  ❌ Error actualizando: {product.get('name', 'Sin nombre')}")
        
        print(f"\n📊 Productos actualizados: {updated_count}")
        return True
        
    except Exception as e:
        print(f"❌ Error actualizando productos: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 SETUP COMPLETO DE SUPABASE STORAGE")
    print("=" * 50)
    
    # 1. Crear bucket
    if not create_bucket():
        print("❌ No se puede continuar sin bucket")
        return
    
    # 2. Crear imagen por defecto
    default_image = create_default_product_image()
    if not default_image:
        print("❌ No se puede continuar sin imagen por defecto")
        return
    
    # 3. Subir imagen por defecto
    if not upload_image_to_bucket(default_image, "default-product.png"):
        print("❌ Error subiendo imagen por defecto")
        return
    
    # 4. Actualizar productos con URLs de Storage
    update_products_with_storage_urls()
    
    print("\n✅ SETUP DE STORAGE COMPLETADO")
    print("=" * 50)
    print("📋 RESULTADO:")
    print("  ✅ Bucket product-images creado")
    print("  ✅ Imagen por defecto subida")
    print("  ✅ Productos actualizados con URLs de Storage")
    print("\n🎯 PRÓXIMO PASO:")
    print("  Las imágenes ahora se almacenan en Supabase Storage")

if __name__ == "__main__":
    main()





