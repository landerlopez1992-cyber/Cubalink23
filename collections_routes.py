"""
Rutas para gestión de colecciones/categorías
"""

from flask import Blueprint, render_template, request, jsonify
import requests
import base64
import uuid

collections_bp = Blueprint('collections', __name__)

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

def upload_image_to_supabase(image_base64, collection_name):
    """Subir imagen a Supabase Storage con manejo mejorado de errores"""
    try:
        # Generar nombre único para la imagen
        image_id = str(uuid.uuid4())
        filename = f"{collection_name.replace(' ', '_')}_{image_id}.jpg"
        
        # Decodificar imagen base64
        image_data = base64.b64decode(image_base64.split(',')[1])
        
        # Determinar el tipo MIME correcto
        mime_type = 'image/jpeg'  # Por defecto
        if 'data:image/png' in image_base64:
            mime_type = 'image/png'
        elif 'data:image/gif' in image_base64:
            mime_type = 'image/gif'
        elif 'data:image/webp' in image_base64:
            mime_type = 'image/webp'
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': mime_type,
        }
        
        # Intentar diferentes buckets en orden de prioridad
        buckets_to_try = ['product-images', 'images', 'public']
        
        for bucket_name in buckets_to_try:
            print(f"🔍 Intentando subir imagen de colección a bucket: {bucket_name}")
            print(f"📸 MIME Type: {mime_type}")
            print(f"📁 Filename: {filename}")
            
            response = requests.post(
                f'{SUPABASE_URL}/storage/v1/object/{bucket_name}/{filename}',
                headers=headers,
                data=image_data
            )
            
            print(f"📡 Response Status: {response.status_code}")
            print(f"📊 Response Text: {response.text}")
            
            if response.status_code == 200:
                # Retornar URL pública de la imagen
                public_url = f'{SUPABASE_URL}/storage/v1/object/public/{bucket_name}/{filename}'
                print(f"✅ Imagen de colección subida exitosamente a {bucket_name}: {public_url}")
                return public_url
            elif response.status_code == 404 and "bucket not found" in response.text.lower():
                print(f"⚠️ Bucket {bucket_name} no existe, probando siguiente...")
                continue
            else:
                print(f"❌ Error en bucket {bucket_name}: {response.status_code} - {response.text}")
                continue
        
        # Si todos los buckets fallan, usar placeholder
        print("❌ Todos los buckets fallaron, usando placeholder")
        return f'https://via.placeholder.com/400x300/007bff/ffffff?text={filename.replace("_", "%20")}'
            
    except Exception as e:
        print(f"Error en upload_image_to_supabase: {e}")
        return ''

@collections_bp.route('/collections')
def collections():
    """Página de gestión de colecciones"""
    return render_template('admin/collections.html')

@collections_bp.route('/api/collections', methods=['GET'])
def get_collections():
    """Obtener todas las colecciones"""
    try:
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json'
        }
        
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/collections?select=*',
            headers=headers
        )
        
        if response.status_code == 200:
            collections = response.json()
            print(f"📋 Colecciones obtenidas: {len(collections)}")
            
            return jsonify({
                'success': True,
                'collections': collections
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Error de Supabase: {response.status_code} - {response.text}'
            }), 500
        
    except Exception as e:
        print(f"❌ Error obteniendo colecciones: {e}")
        return jsonify({
            'success': False,
            'error': f'Error interno: {str(e)}'
        }), 500

@collections_bp.route('/api/collections', methods=['POST'])
def create_collection():
    """Crear nueva colección"""
    try:
        data = request.get_json()
        
        print(f"📝 Creando colección: {data.get('title')}")
        
        # Subir imagen si existe
        image_url = ''
        if data.get('image_base64'):
            image_url = upload_image_to_supabase(data['image_base64'], data.get('title', 'collection'))
        
        # Preparar datos de la colección
        collection_data = {
            'title': data.get('title'),
            'description': data.get('description', ''),
            'sort_order': data.get('sort_order', 'newest'),
            'show_in_menu': data.get('show_in_menu', False),
            'is_active': data.get('is_active', True),
            'featured': data.get('featured', False),
            'meta_title': data.get('meta_title', ''),
            'meta_description': data.get('meta_description', ''),
            'image_url': image_url,
            'product_count': 0
        }
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json'
        }
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/collections',
            headers=headers,
            json=collection_data
        )
        
        if response.status_code == 201:
            collection = response.json()
            print(f"✅ Colección creada: {collection}")
            
            return jsonify({
                'success': True,
                'collection': collection[0] if isinstance(collection, list) else collection,
                'message': 'Colección creada exitosamente'
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Error de Supabase: {response.status_code} - {response.text}'
            }), 500
        
    except Exception as e:
        print(f"❌ Error creando colección: {e}")
        return jsonify({
            'success': False,
            'error': f'Error interno: {str(e)}'
        }), 500

@collections_bp.route('/api/collections/<collection_id>', methods=['PUT'])
def update_collection(collection_id):
    """Actualizar colección"""
    try:
        data = request.get_json()
        
        print(f"✏️ Actualizando colección: {collection_id}")
        
        # Preparar datos actualizados
        update_data = {}
        if 'title' in data:
            update_data['title'] = data['title']
        if 'description' in data:
            update_data['description'] = data['description']
        if 'sort_order' in data:
            update_data['sort_order'] = data['sort_order']
        if 'show_in_menu' in data:
            update_data['show_in_menu'] = data['show_in_menu']
        if 'is_active' in data:
            update_data['is_active'] = data['is_active']
        if 'featured' in data:
            update_data['featured'] = data['featured']
        if 'meta_title' in data:
            update_data['meta_title'] = data['meta_title']
        if 'meta_description' in data:
            update_data['meta_description'] = data['meta_description']
        
        # Subir nueva imagen si existe
        if data.get('image_base64'):
            update_data['image_url'] = upload_image_to_supabase(data['image_base64'], data.get('title', 'collection'))
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json'
        }
        
        response = requests.patch(
            f'{SUPABASE_URL}/rest/v1/collections?id=eq.{collection_id}',
            headers=headers,
            json=update_data
        )
        
        if response.status_code in [200, 204]:
            print(f"✅ Colección actualizada: {collection_id}")
            
            return jsonify({
                'success': True,
                'message': 'Colección actualizada exitosamente'
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Error de Supabase: {response.status_code} - {response.text}'
            }), 500
        
    except Exception as e:
        print(f"❌ Error actualizando colección: {e}")
        return jsonify({
            'success': False,
            'error': f'Error interno: {str(e)}'
        }), 500

@collections_bp.route('/api/collections/<collection_id>', methods=['DELETE'])
def delete_collection(collection_id):
    """Eliminar colección"""
    try:
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json'
        }
        
        response = requests.delete(
            f'{SUPABASE_URL}/rest/v1/collections?id=eq.{collection_id}',
            headers=headers
        )
        
        if response.status_code == 204:
            print(f"🗑️ Colección eliminada: {collection_id}")
            
            return jsonify({
                'success': True,
                'message': 'Colección eliminada exitosamente'
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Error de Supabase: {response.status_code} - {response.text}'
            }), 500
        
    except Exception as e:
        print(f"❌ Error eliminando colección: {e}")
        return jsonify({
            'success': False,
            'error': f'Error interno: {str(e)}'
        }), 500

@collections_bp.route('/api/collections/<collection_id>/products', methods=['GET'])
def get_collection_products(collection_id):
    """Obtener productos de una colección"""
    try:
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}',
            'Content-Type': 'application/json'
        }
        
        # Obtener productos de la colección
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/collection_products?collection_id=eq.{collection_id}&select=*,store_products(*)',
            headers=headers
        )
        
        if response.status_code == 200:
            collection_products = response.json()
            products = []
            
            for item in collection_products:
                if item.get('store_products'):
                    products.append(item['store_products'])
            
            print(f"📦 Productos de colección {collection_id}: {len(products)}")
            
            return jsonify({
                'success': True,
                'products': products
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Error de Supabase: {response.status_code} - {response.text}'
            }), 500
        
    except Exception as e:
        print(f"❌ Error obteniendo productos de colección: {e}")
        return jsonify({
            'success': False,
            'error': f'Error interno: {str(e)}'
        }), 500
