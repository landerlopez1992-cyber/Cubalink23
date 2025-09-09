from flask import Blueprint, render_template, request, jsonify, redirect, url_for
import json
import os
from datetime import datetime
import sqlite3
import base64
import uuid

# Importar sistema mejorado de upload de imágenes
try:
    from improved_image_upload import ImprovedImageUploader
    IMAGE_UPLOADER = ImprovedImageUploader()
    IMPROVED_UPLOAD_AVAILABLE = True
    print("✅ Sistema mejorado de upload de imágenes disponible")
except ImportError:
    IMAGE_UPLOADER = None
    IMPROVED_UPLOAD_AVAILABLE = False
    print("⚠️ Sistema mejorado de upload no disponible - usando método básico")

# Variable global para modo mantenimiento
MAINTENANCE_MODE = False

# Variables globales para actualizaciones forzadas
FORCE_UPDATE_MODE = False
IOS_APP_URL = ""
ANDROID_APP_URL = ""


def get_admin_user_id():
    """Obtener ID del usuario admin"""
    try:
        import requests
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        # Buscar usuario admin existente
        response = requests.get(f'{SUPABASE_URL}/rest/v1/users?email=eq.admin@cubalink23.com&select=id', headers=headers)
        if response.status_code == 200:
            users = response.json()
            if users:
                return users[0]['id']
        
        # Si no existe, crear usuario admin
        admin_user = {
            'email': 'admin@cubalink23.com',
            'role': 'admin'
        }
        response = requests.post(f'{SUPABASE_URL}/rest/v1/users', headers=headers, json=admin_user)
        if response.status_code == 201:
            return response.json()[0]['id']
        
        return None
    except Exception as e:
        print(f"Error obteniendo admin user: {e}")
        return None

admin = Blueprint('admin', __name__, url_prefix='/admin')

# Configuración del panel
ADMIN_CONFIG = {
    'app_name': 'Cubalink23',
    'version': '1.0.0',
    'admin_email': 'admin@cubalink23.com'
}

# Base de datos simple para estadísticas
def init_db():
    conn = sqlite3.connect('admin_stats.db')
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS stats
                 (id INTEGER PRIMARY KEY, date TEXT, searches INTEGER, 
                  users INTEGER, errors INTEGER)''')
    c.execute('''CREATE TABLE IF NOT EXISTS users
                 (id INTEGER PRIMARY KEY, user_id TEXT, searches INTEGER,
                  last_seen TEXT, blocked INTEGER DEFAULT 0)''')
    conn.commit()
    conn.close()

@admin.route('/')
def dashboard():
    """Panel principal de administración"""
    return render_template('admin/dashboard.html', config=ADMIN_CONFIG)

@admin.route('/stats')
def get_stats():
    """Obtener estadísticas en tiempo real"""
    try:
        # Simular estadísticas (en producción esto vendría de una base de datos real)
        stats = {
            'total_searches': 1250,
            'active_users': 45,
            'popular_routes': [
                {'route': 'MIA-HAV', 'searches': 156},
                {'route': 'MVD-MIA', 'searches': 89},
                {'route': 'LAX-HAV', 'searches': 67}
            ],
            'system_status': {
                'backend': 'Online',
                'cloudflare_tunnel': 'Active',
                'duffel_api': 'Connected'
            }
        }
        return jsonify(stats)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/users')
def users():
    """Gestión de usuarios"""
    return render_template('admin/users.html', config=ADMIN_CONFIG)

@admin.route('/flights')
def flights():
    """Gestión de vuelos y rutas"""
    return render_template('admin/flights.html', config=ADMIN_CONFIG)

@admin.route('/products')
def products():
    """Gestión de productos"""
    return render_template('admin/products.html', config=ADMIN_CONFIG)

@admin.route('/system')
def system():
    """Configuración del sistema"""
    return render_template('admin/system.html', config=ADMIN_CONFIG)

@admin.route('/orders')
def orders():
    """Gestión de órdenes"""
    return render_template('admin/orders.html', config=ADMIN_CONFIG)

@admin.route('/banners')
def banners():
    """Gestión de banners"""
    return render_template('admin/banners.html', config=ADMIN_CONFIG)

@admin.route('/api/banners', methods=['GET'])
def get_banners():
    """Obtener todos los banners desde Supabase"""
    try:
        import requests
        
        # Configuración de Supabase
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        response = requests.get(
            '{}/rest/v1/banners?select=*&order=display_order.asc'.format(SUPABASE_URL),
            headers=headers
        )
        
        if response.status_code == 200:
            banners_data = response.json()
            return jsonify({
                'success': True,
                'banners': banners_data,
                'total': len(banners_data)
            })
        else:
            return jsonify({
                'success': False,
                'error': 'Error obteniendo banners: {}'.format(response.status_code),
                'banners': []
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'banners': []
        }), 500

@admin.route('/api/banners', methods=['POST'])
def create_banner():
    """Crear nuevo banner en Supabase"""
    try:
        import requests
        import base64
        import uuid
        
        # Verificar que tenemos datos JSON válidos
        if not request.is_json:
            return jsonify({
                'success': False,
                'error': 'Content-Type debe ser application/json'
            }), 400
            
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': 'No se recibieron datos JSON'
            }), 400
        
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        # Manejar imagen del banner
        image_url = data.get('image_url', '')
        if data.get('image_base64'):
            try:
                # Si hay imagen en base64, subirla a Supabase Storage
                image_url = upload_banner_image_to_supabase(data.get('image_base64'), data.get('title', 'banner'))
                if not image_url:
                    print("⚠️ Upload de imagen falló, usando imagen de Unsplash")
                    image_url = f'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=400&fit=crop&crop=center'
            except Exception as e:
                print(f"❌ Error en upload de imagen: {e}")
                image_url = f'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=400&fit=crop&crop=center'
        
        # Preparar datos del banner
        banner_data = {
            'title': data.get('title'),
            'description': data.get('description', ''),
            'banner_type': data.get('banner_type'),
            'image_url': image_url,
            'display_order': int(data.get('display_order', 0)),
            'is_active': bool(data.get('is_active', True)),
            'auto_rotate': bool(data.get('auto_rotate', True)),
            'rotation_speed': int(data.get('rotation_speed', 5000))
        }
        
        # Validar datos requeridos
        if not banner_data['title'] or not banner_data['banner_type']:
            return jsonify({
                'success': False,
                'error': 'Título y tipo de banner son requeridos'
            }), 400
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/banners',
            headers=headers,
            json=banner_data
        )
        
        print(f"🔍 Supabase Response Status: {response.status_code}")
        print(f"🔍 Supabase Response Text: {response.text}")
        
        if response.status_code == 201:
            try:
                banner_response = response.json()
                return jsonify({
                    'success': True,
                    'message': 'Banner creado exitosamente',
                    'banner': banner_response
                })
            except Exception as e:
                return jsonify({
                    'success': True,
                    'message': 'Banner creado exitosamente',
                    'banner': {'id': 'created'}
                })
        else:
            return jsonify({
                'success': False,
                'error': f'Error creando banner: {response.status_code} - {response.text}'
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@admin.route('/vendors')
def vendors():
    """Gestión de vendedores"""
    return render_template('admin/vendors.html', config=ADMIN_CONFIG)

@admin.route('/drivers')
def drivers():
    """Gestión de repartidores"""
    return render_template('admin/drivers.html', config=ADMIN_CONFIG)

@admin.route('/vehicles')
def vehicles():
    """Gestión de vehículos"""
    return render_template('admin/vehicles.html', config=ADMIN_CONFIG)

@admin.route('/support-chat')
def support_chat():
    """Chat de soporte"""
    return render_template('admin/support_chat.html', config=ADMIN_CONFIG)

@admin.route('/alerts')
def alerts():
    """Gestión de alertas"""
    return render_template('admin/alerts.html', config=ADMIN_CONFIG)

@admin.route('/wallet')
def wallet():
    """Gestión de billetera"""
    return render_template('admin/wallet.html', config=ADMIN_CONFIG)

@admin.route('/payment-methods')
def payment_methods():
    """Métodos de pago"""
    return render_template('admin/payment_methods.html', config=ADMIN_CONFIG)

@admin.route('/payroll')
def payroll():
    """Gestión de nómina"""
    return render_template('admin/payroll.html', config=ADMIN_CONFIG)

@admin.route('/system-rules')
def system_rules():
    """Reglas del sistema"""
    return render_template('admin/system_rules.html', config=ADMIN_CONFIG)

@admin.route('/api/config', methods=['GET', 'POST'])
def api_config():
    """API para configurar la app Flutter"""
    if request.method == 'POST':
        data = request.json
        # Guardar configuración que afectará la app
        config_file = 'app_config.json'
        with open(config_file, 'w') as f:
            json.dump(data, f)
        return jsonify({'success': True, 'message': 'Configuración actualizada'})
    else:
        # Leer configuración actual
        config_file = 'app_config.json'
        if os.path.exists(config_file):
            with open(config_file, 'r') as f:
                return jsonify(json.load(f))
        return jsonify({'app_name': 'Cubalink23', 'maintenance_mode': False})

@admin.route('/api/notifications', methods=['POST', 'GET'])
def handle_notifications():
    """Manejar notificaciones - POST para enviar, GET para obtener"""
    if request.method == 'POST':
        # Enviar notificación
        data = request.json
        title = data.get('title', 'Sin título')
        message = data.get('message', 'Sin mensaje')
        
        # Agregar a la cola de notificaciones (importar desde app.py)
        from app import notification_queue, notification_counter
        import time
        from datetime import datetime, timedelta
        
        notification = {
            "id": notification_counter,
            "title": title,
            "message": message,
            "timestamp": time.time(),
            "user_id": "admin"
        }
        
        # Agregar a la cola para notificación inmediata
        notification_queue.append(notification)
        notification_counter += 1
        
        # Guardar en Supabase para historial
        try:
            import requests
            
            # Usar requests directo para Supabase
            supabase_url = 'https://zgqrhzuhrwudckwesybg.supabase.co'
            supabase_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
            
            headers = {
                'apikey': supabase_key,
                'Authorization': f'Bearer {supabase_key}',
                'Content-Type': 'application/json'
            }
            
            supabase_notification = {
                "title": title,
                "message": message,
                "user_id": "admin",  # String simple para compatibilidad
                "read": False
            }
            
            # CREAR nueva tabla con nombre diferente y TEXT para user_id
            create_table_sql = '''
            CREATE TABLE IF NOT EXISTS notifications_v2 (
                id SERIAL PRIMARY KEY,
                title TEXT NOT NULL,
                message TEXT NOT NULL,
                user_id TEXT NOT NULL DEFAULT 'admin',
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                read BOOLEAN DEFAULT FALSE
            );
            ALTER TABLE notifications_v2 ENABLE ROW LEVEL SECURITY;
            DROP POLICY IF EXISTS "Allow all access" ON notifications_v2;
            CREATE POLICY "Allow all access" ON notifications_v2 FOR ALL USING (true);
            '''
            
            # Intentar crear la tabla (si ya existe, no hace nada)
            try:
                sql_response = requests.post(
                    f"{supabase_url}/rest/v1/rpc/exec_sql",
                    headers=headers,
                    json={"sql": create_table_sql}
                )
            except:
                pass  # Ignorar errores de creación de tabla
            
            # Insertar la notificación
            response = requests.post(
                f"{supabase_url}/rest/v1/notifications_v2",
                headers=headers,
                json=supabase_notification
            )
            
            print(f"🔍 Status code al guardar: {response.status_code}")
            print(f"🔍 Response al guardar: {response.text[:200]}...")
            
            if response.status_code == 201:
                print(f"💾 Notificación guardada en Supabase para historial: {title}")
            else:
                print(f"⚠️ Error guardando en Supabase: {response.status_code} - {response.text}")
                
        except Exception as e:
            print(f"⚠️ Error guardando en Supabase: {e}")
        
        print(f"🔔 Notificación agregada desde admin_routes: {title}")
        
        return jsonify({'success': True, 'message': 'Notificación enviada'})
    
    elif request.method == 'GET':
        # Obtener notificaciones para la app (solo para clientes móviles)
        from app import notification_queue
        
        # Verificar si es la app móvil (User-Agent contiene "Dart")
        user_agent = request.headers.get('User-Agent', '')
        is_mobile_app = 'Dart' in user_agent
        
        try:
            if is_mobile_app and notification_queue:
                notification = notification_queue.popleft()
                print(f"📱 Notificación enviada a la APP MÓVIL: {notification['title']}")
                
                return jsonify({
                    "success": True,
                    "notifications": [notification]
                })
            elif is_mobile_app:
                print("📱 App móvil consultó, pero no hay notificaciones")
                return jsonify({
                    "success": True,
                    "notifications": []
                })
            else:
                # Para navegadores web, no dar notificaciones
                print(f"🌐 Navegador web consultó (User-Agent: {user_agent[:50]}...), ignorando")
                return jsonify({
                    "success": True,
                    "notifications": []
                })
                
        except Exception as e:
            print(f"❌ Error obteniendo notificaciones: {e}")
            return jsonify({
                "success": False,
                "message": f"Error: {str(e)}"
            }), 500

@admin.route('/api/notifications/history', methods=['GET'])
def get_notification_history():
    """Obtener historial de notificaciones para la campanita"""
    try:
        import requests
        from datetime import datetime
        
        # Usar requests directo para Supabase
        supabase_url = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        supabase_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        
        headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json'
        }
        
        # Obtener todas las notificaciones (tabla notifications_v2)
        url = f"{supabase_url}/rest/v1/notifications_v2?user_id=eq.admin&order=created_at.desc"
        
        print(f"🔍 URL de consulta: {url}")
        response = requests.get(url, headers=headers)
        print(f"🔍 Status code: {response.status_code}")
        print(f"🔍 Response: {response.text[:200]}...")
        
        if response.status_code == 200:
            notifications = response.json()
            print(f"📋 Historial de notificaciones obtenido: {len(notifications)} notificaciones")
            
            return jsonify({
                "success": True,
                "notifications": notifications
            })
        else:
            print(f"❌ Error obteniendo historial: {response.status_code} - {response.text}")
            return jsonify({
                "success": False,
                "message": f"Error: {response.status_code} - {response.text}"
            }), 500
        
    except Exception as e:
        print(f"❌ Error obteniendo historial: {e}")
        return jsonify({
            "success": False,
            "message": f"Error: {str(e)}"
        }), 500

@admin.route('/api/notifications/cleanup', methods=['POST'])
def cleanup_expired_notifications():
    """Limpiar notificaciones expiradas (se ejecuta automáticamente)"""
    try:
        import requests
        from datetime import datetime
        
        # Usar requests directo para Supabase
        supabase_url = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        supabase_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        
        headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json'
        }
        
        # Eliminar notificaciones antiguas (más de 30 días)
        thirty_days_ago = (datetime.now() - timedelta(days=30)).isoformat()
        url = f"{supabase_url}/rest/v1/notifications?created_at=lt.{thirty_days_ago}"
        
        response = requests.delete(url, headers=headers)
        
        if response.status_code == 204:
            print(f"🧹 Notificaciones expiradas eliminadas exitosamente")
            
            return jsonify({
                "success": True,
                "deleted_count": 1  # Supabase no devuelve count exacto
            })
        else:
            print(f"❌ Error limpiando notificaciones: {response.status_code} - {response.text}")
            return jsonify({
                "success": False,
                "message": f"Error: {response.status_code}"
            }), 500
        
    except Exception as e:
        print(f"❌ Error limpiando notificaciones: {e}")
        return jsonify({
            "success": False,
            "message": f"Error: {str(e)}"
        }), 500

@admin.route('/api/maintenance', methods=['POST'])
def toggle_maintenance():
    """Activar/desactivar modo mantenimiento"""
    data = request.json
    maintenance_mode = data.get('maintenance_mode', False)
    
    # Actualizar configuración que la app Flutter leerá
    config = {'maintenance_mode': maintenance_mode}
    with open('app_config.json', 'w') as f:
        json.dump(config, f)
    
    return jsonify({'success': True, 'maintenance_mode': maintenance_mode})

# ==================== PRODUCTOS API ====================

@admin.route('/api/products', methods=['GET'])
def get_products():
    """Obtener todos los productos desde Supabase"""
    try:
        import requests
        
        # Configuración de Supabase
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/store_products?select=*&order=created_at.desc',
            headers=headers
        )
        
        if response.status_code == 200:
            products = response.json()
            return jsonify({
                'success': True,
                'products': products,
                'total': len(products)
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Error de Supabase: {response.status_code}',
                'products': []
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'products': []
        }), 500

@admin.route('/api/products', methods=['POST'])
def create_product():
    """Crear nuevo producto en Supabase"""
    try:
        import requests
        
        # Verificar que tenemos datos JSON válidos
        if not request.is_json:
            return jsonify({
                'success': False,
                'error': 'Content-Type debe ser application/json'
            }), 400
            
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': 'No se recibieron datos JSON'
            }), 400
        
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        # Manejar imagen del producto
        image_url = data.get('image_url', '')
        if data.get('image_base64'):
            try:
                # Si hay imagen en base64, subirla a Supabase Storage
                image_url = upload_image_to_supabase(data.get('image_base64'), data.get('name', 'product'))
                if not image_url:
                    print("⚠️ Upload de imagen falló, usando imagen de Unsplash")
                    image_url = f'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop&crop=center'
            except Exception as e:
                print(f"❌ Error en upload de imagen: {e}")
                image_url = f'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop&crop=center'
        
        # Preparar datos del producto - SOLO campos que existen en Supabase
        product_data = {
            'name': data.get('name'),
            'description': data.get('description', ''),
            'price': float(data.get('price', 0)),
            'category': data.get('category'),
            'stock': int(data.get('stock', 0)),
            'image_url': image_url
        }
        
        # Agregar campos opcionales solo si existen en la tabla
        if data.get('subcategory'):
            product_data['subcategory'] = data.get('subcategory')
        if data.get('weight'):
            product_data['weight'] = data.get('weight')
        if data.get('shipping_cost'):
            product_data['shipping_cost'] = float(data.get('shipping_cost', 0))
        # Manejar vendor_id - debe ser UUID válido o usar admin por defecto
        vendor_id = data.get('vendor_id')
        if vendor_id and vendor_id != 'test-vendor':
            # Solo agregar si es un UUID válido
            try:
                import uuid
                uuid.UUID(vendor_id)  # Validar que sea UUID
                product_data['vendor_id'] = vendor_id
            except ValueError:
                # Si no es UUID válido, usar admin por defecto
                admin_id = get_admin_user_id()
                if admin_id:
                    product_data['vendor_id'] = admin_id
        else:
            # Usar admin por defecto si no se especifica o es un valor de prueba
            admin_id = get_admin_user_id()
            if admin_id:
                product_data['vendor_id'] = admin_id
        if data.get('shipping_methods'):
            product_data['shipping_methods'] = data.get('shipping_methods', [])
        if data.get('tags'):
            product_data['tags'] = data.get('tags', [])
        
        # Siempre agregar is_active si la columna existe
        product_data['is_active'] = True
        
        # Validar datos requeridos
        if not product_data['name'] or not product_data['category']:
            return jsonify({
                'success': False,
                'error': 'Nombre y categoría son requeridos'
            }), 400
        
        response = requests.post(
            f'{SUPABASE_URL}/rest/v1/store_products',
            headers=headers,
            json=product_data
        )
        
        print(f"🔍 Supabase Response Status: {response.status_code}")
        print(f"🔍 Supabase Response Text: {response.text}")
        
        if response.status_code == 201:
            try:
                product_response = response.json()
                return jsonify({
                    'success': True,
                    'message': 'Producto creado exitosamente',
                    'product': product_response
                })
            except Exception as e:
                return jsonify({
                    'success': True,
                    'message': 'Producto creado exitosamente',
                    'product': {'id': 'created'}
                })
        else:
            return jsonify({
                'success': False,
                'error': f'Error de Supabase: {response.status_code} - {response.text}'
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Error interno: {str(e)}'
        }), 500

def upload_image_to_supabase(image_base64, product_name):
    """Subir imagen a Supabase Storage - VERSIÓN MEJORADA"""
    
    # Usar sistema mejorado si está disponible
    if IMPROVED_UPLOAD_AVAILABLE and IMAGE_UPLOADER:
        try:
            print("📸 Usando sistema mejorado de upload...")
            return IMAGE_UPLOADER.upload_image_to_supabase(image_base64, product_name)
        except Exception as e:
            print(f"⚠️ Error en sistema mejorado, usando método mejorado: {e}")
    
    # Método mejorado con Service Key
    print("📸 Usando método mejorado de upload...")
    try:
        import requests
        import base64
        import uuid
        
        # Configuración de Supabase con Service Key
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.kUgRPYHRuWJVPfD8iVA7GDuOlj9Xwp6eQ2gH7FJqJ9s'
        
        # Generar nombre único para la imagen
        image_id = str(uuid.uuid4())
        filename = f"{product_name.replace(' ', '_')}_{image_id}.jpg"
        
        # Decodificar imagen base64
        image_data = base64.b64decode(image_base64.split(',')[1])
        
        # Determinar el tipo MIME correcto
        mime_type = 'image/jpeg'  # Por defecto
        if 'data:image/png' in image_base64:
            mime_type = 'image/png'
            filename = filename.replace('.jpg', '.png')
        elif 'data:image/gif' in image_base64:
            mime_type = 'image/gif'
            filename = filename.replace('.jpg', '.gif')
        elif 'data:image/webp' in image_base64:
            mime_type = 'image/webp'
            filename = filename.replace('.jpg', '.webp')
        
        # Headers para upload con Service Key
        upload_headers = {
            'apikey': SERVICE_KEY,
            'Authorization': f'Bearer {SERVICE_KEY}',
        }
        
        # Subir archivo usando multipart/form-data
        files = {
            'file': (filename, image_data, mime_type)
        }
        
        print(f"🔍 Subiendo imagen: {filename}")
        print(f"📸 MIME Type: {mime_type}")
        
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/object/product-images/{filename}',
            headers=upload_headers,
            files=files
        )
        
        print(f"📡 Response Status: {response.status_code}")
        print(f"📊 Response Text: {response.text}")
        
        if response.status_code == 200:
            # Retornar URL pública de la imagen
            public_url = f'{SUPABASE_URL}/storage/v1/object/public/product-images/{filename}'
            print(f"✅ Imagen subida exitosamente: {public_url}")
            return public_url
        else:
            print(f"❌ Error subiendo imagen: {response.status_code} - {response.text}")
            # Usar imagen de Unsplash como fallback
            return f'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop&crop=center'
            
    except Exception as e:
        print(f"Error en upload_image_to_supabase: {e}")
        # Usar placeholder como fallback
        return f'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop&crop=center'
@admin.route('/api/products/<product_id>', methods=['PUT'])
def update_product(product_id):
    """Actualizar producto en Supabase"""
    try:
        import requests
        
        data = request.json
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        # Manejar imagen del producto
        if data.get('image_base64'):
            # Si hay imagen en base64, subirla a Supabase Storage
            image_url = upload_image_to_supabase(data.get('image_base64'), data.get('name', 'product'))
            if image_url:
                data['image_url'] = image_url
        
        # Preparar datos actualizados con nuevas funcionalidades
        update_data = {}
        if 'name' in data:
            update_data['name'] = data['name']
        if 'description' in data:
            update_data['description'] = data['description']
        if 'price' in data:
            update_data['price'] = float(data['price'])
        if 'category' in data:
            update_data['category'] = data['category']
        if 'subcategory' in data:
            update_data['subcategory'] = data['subcategory']
        if 'stock' in data:
            update_data['stock'] = int(data['stock'])
        if 'weight' in data:
            update_data['weight'] = data['weight']
        if 'shipping_cost' in data:
            update_data['shipping_cost'] = float(data['shipping_cost']) if data['shipping_cost'] else 0
        if 'vendor_id' in data:
            update_data['vendor_id'] = data['vendor_id']
        if 'shipping_methods' in data:
            update_data['shipping_methods'] = data['shipping_methods']
        if 'tags' in data:
            update_data['tags'] = data['tags']
        if 'is_active' in data:
            update_data['is_active'] = data['is_active']
        if 'image_url' in data:
            update_data['image_url'] = data['image_url']
        
        response = requests.patch(
            f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product_id}',
            headers=headers,
            json=update_data
        )
        
        print(f"🔍 Update Response Status: {response.status_code}")
        print(f"🔍 Update Response Text: {response.text}")
        
        # Supabase devuelve 204 para actualizaciones exitosas
        if response.status_code in [200, 204]:
            return jsonify({
                'success': True,
                'message': 'Producto actualizado exitosamente'
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Error de Supabase: {response.status_code} - {response.text}'
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@admin.route('/api/products/<product_id>', methods=['DELETE'])
def delete_product(product_id):
    """Eliminar producto de Supabase y su imagen del Storage"""
    try:
        import requests
        import os
        
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.kUgRPYHRuWJVPfD8iVA7GDuOlj9Xwp6eQ2gH7FJqJ9s'
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        # Primero obtener el producto para obtener la URL de la imagen
        get_response = requests.get(
            f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product_id}&select=image_url',
            headers=headers
        )
        
        if get_response.status_code == 200:
            products = get_response.json()
            if products and len(products) > 0:
                product = products[0]
                image_url = product.get('image_url', '')
                
                # Si la imagen está en Supabase Storage, eliminarla
                if image_url and 'storage/v1/object/public/product-images/' in image_url:
                    try:
                        # Extraer el nombre del archivo de la URL
                        filename = os.path.basename(image_url)
                        
                        # Eliminar la imagen del Storage usando Service Key
                        storage_headers = {
                            'apikey': SERVICE_KEY,
                            'Authorization': f'Bearer {SERVICE_KEY}'
                        }
                        
                        delete_image_response = requests.delete(
                            f'{SUPABASE_URL}/storage/v1/object/product-images/{filename}',
                            headers=storage_headers
                        )
                        
                        if delete_image_response.status_code == 200:
                            print(f"✅ Imagen eliminada del Storage: {filename}")
                        else:
                            print(f"⚠️ No se pudo eliminar la imagen del Storage: {delete_image_response.status_code}")
                            
                    except Exception as e:
                        print(f"⚠️ Error eliminando imagen del Storage: {e}")
        
        # Eliminar el producto de la base de datos
        response = requests.delete(
            f'{SUPABASE_URL}/rest/v1/store_products?id=eq.{product_id}',
            headers=headers
        )
        
        if response.status_code == 204:
            return jsonify({
                'success': True,
                'message': 'Producto eliminado exitosamente'
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Error de Supabase: {response.status_code} - {response.text}'
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


def upload_banner_image_to_supabase(image_base64, banner_title):
    """Subir imagen de banner a Supabase Storage"""
    print("�� Subiendo imagen de banner...")
    try:
        import requests
        import base64
        import uuid
        
        # Configuración de Supabase con Anon Key (para Storage)
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        
        # Generar nombre único para la imagen
        image_id = str(uuid.uuid4())
        filename = f"{banner_title.replace(' ', '_')}_{image_id}.jpg"
        
        # Decodificar imagen base64
        image_data = base64.b64decode(image_base64.split(',')[1])
        
        # Determinar el tipo MIME correcto
        mime_type = 'image/jpeg'  # Por defecto
        if 'data:image/png' in image_base64:
            mime_type = 'image/png'
            filename = filename.replace('.jpg', '.png')
        elif 'data:image/gif' in image_base64:
            mime_type = 'image/gif'
            filename = filename.replace('.jpg', '.gif')
        elif 'data:image/webp' in image_base64:
            mime_type = 'image/webp'
            filename = filename.replace('.jpg', '.webp')
        
        # Headers para upload con Anon Key
        upload_headers = {
            'apikey': ANON_KEY,
            'Authorization': f'Bearer {ANON_KEY}',
            'Content-Type': mime_type,
        }
        
        print(f"🔍 Subiendo banner: {filename}")
        print(f"📸 MIME Type: {mime_type}")
        
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/object/banners/{filename}',
            headers=upload_headers,
            data=image_data
        )
        
        print(f"📡 Response Status: {response.status_code}")
        print(f"📊 Response Text: {response.text}")
        
        if response.status_code == 200:
            # Retornar URL pública de la imagen
            public_url = f'{SUPABASE_URL}/storage/v1/object/public/banners/{filename}'
            print(f"✅ Banner subido exitosamente: {public_url}")
            return public_url
        else:
            print(f"❌ Error subiendo banner: {response.status_code} - {response.text}")
            # Usar imagen de Unsplash como fallback
            return f'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=400&fit=crop&crop=center'
            
    except Exception as e:
        print(f"Error en upload_banner_image_to_supabase: {e}")
        # Usar imagen de Unsplash como fallback
        return f'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=400&fit=crop&crop=center'

@admin.route('/api/banners/<banner_id>', methods=['PUT'])
def update_banner(banner_id):
    """Actualizar banner en Supabase"""
    try:
        import requests
        
        data = request.json
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        # Manejar imagen del banner si se proporciona
        if data.get('image_base64'):
            try:
                image_url = upload_banner_image_to_supabase(data.get('image_base64'), data.get('title', 'banner'))
                data['image_url'] = image_url
            except Exception as e:
                print(f"❌ Error en upload de imagen: {e}")
        
        # Preparar datos del banner
        banner_data = {
            'title': data.get('title'),
            'description': data.get('description', ''),
            'banner_type': data.get('banner_type'),
            'display_order': int(data.get('display_order', 0)),
            'is_active': bool(data.get('is_active', True)),
            'auto_rotate': bool(data.get('auto_rotate', True)),
            'rotation_speed': int(data.get('rotation_speed', 5000))
        }
        
        # Agregar image_url si se actualizó
        if 'image_url' in data:
            banner_data['image_url'] = data['image_url']
        
        response = requests.patch(
            f'{SUPABASE_URL}/rest/v1/banners?id=eq.{banner_id}',
            headers=headers,
            json=banner_data
        )
        
        if response.status_code == 204:
            return jsonify({
                'success': True,
                'message': 'Banner actualizado exitosamente'
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Error actualizando banner: {response.status_code} - {response.text}'
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@admin.route('/api/banners/<banner_id>', methods=['DELETE'])
def delete_banner(banner_id):
    """Eliminar banner de Supabase y su imagen del Storage"""
    try:
        import requests
        import os
        
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.kUgRPYHRuWJVPfD8iVA7GDuOlj9Xwp6eQ2gH7FJqJ9s'
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        # Primero obtener el banner para obtener la URL de la imagen
        get_response = requests.get(
            f'{SUPABASE_URL}/rest/v1/banners?id=eq.{banner_id}&select=image_url',
            headers=headers
        )
        
        if get_response.status_code == 200:
            banners = get_response.json()
            if banners and len(banners) > 0:
                banner = banners[0]
                image_url = banner.get('image_url', '')
                
                # Si la imagen está en Supabase Storage, eliminarla
                if image_url and 'storage/v1/object/public/banners/' in image_url:
                    try:
                        # Extraer el nombre del archivo de la URL
                        filename = os.path.basename(image_url)
                        
                        # Eliminar la imagen del Storage usando Service Key
                        storage_headers = {
                            'apikey': SERVICE_KEY,
                            'Authorization': f'Bearer {SERVICE_KEY}'
                        }
                        
                        delete_image_response = requests.delete(
                            f'{SUPABASE_URL}/storage/v1/object/banners/{filename}',
                            headers=storage_headers
                        )
                        
                        if delete_image_response.status_code == 200:
                            print(f"✅ Imagen de banner eliminada del Storage: {filename}")
                        else:
                            print(f"⚠️ No se pudo eliminar la imagen del Storage: {delete_image_response.status_code}")
                            
                    except Exception as e:
                        print(f"⚠️ Error eliminando imagen del Storage: {e}")
        
        # Eliminar el banner de la base de datos
        response = requests.delete(
            f'{SUPABASE_URL}/rest/v1/banners?id=eq.{banner_id}',
            headers=headers
        )
        
        if response.status_code == 204:
            return jsonify({
                'success': True,
                'message': 'Banner eliminado exitosamente'
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Error eliminando banner: {response.status_code} - {response.text}'
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@admin.route('/api/upload-banners', methods=['POST'])
def upload_banners():
    """Subir banners desde el sistema actual (compatible con la interfaz existente)"""
    try:
        import requests
        import base64
        import uuid
        
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        uploaded_banners = []
        
        # Procesar Banner Principal (Home)
        if 'main_banner' in request.files:
            main_banner = request.files['main_banner']
            if main_banner and main_banner.filename:
                try:
                    # Convertir a base64
                    image_data = main_banner.read()
                    image_base64 = base64.b64encode(image_data).decode('utf-8')
                    image_base64 = f'data:image/jpeg;base64,{image_base64}'
                    
                    # Subir a Supabase Storage
                    image_url = upload_banner_image_to_supabase(image_base64, 'Banner Principal')
                    
                    # Crear banner en la base de datos
                    banner_data = {
                        'title': 'Banner Principal (Home)',
                        'description': 'Banner principal de la aplicación',
                        'banner_type': 'banner1',
                        'image_url': image_url,
                        'display_order': 1,
                        'is_active': True,
                        'auto_rotate': True,
                        'rotation_speed': 5000
                    }
                    
                    response = requests.post(
                        f'{SUPABASE_URL}/rest/v1/banners',
                        headers=headers,
                        json=banner_data
                    )
                    
                    if response.status_code == 201:
                        uploaded_banners.append('Banner Principal')
                    
                except Exception as e:
                    print(f"Error procesando banner principal: {e}")
        
        # Procesar Banner Secundario
        if 'secondary_banner' in request.files:
            secondary_banner = request.files['secondary_banner']
            if secondary_banner and secondary_banner.filename:
                try:
                    # Convertir a base64
                    image_data = secondary_banner.read()
                    image_base64 = base64.b64encode(image_data).decode('utf-8')
                    image_base64 = f'data:image/jpeg;base64,{image_base64}'
                    
                    # Subir a Supabase Storage
                    image_url = upload_banner_image_to_supabase(image_base64, 'Banner Secundario')
                    
                    # Crear banner en la base de datos
                    banner_data = {
                        'title': 'Banner Secundario',
                        'description': 'Banner secundario de la aplicación',
                        'banner_type': 'banner2',
                        'image_url': image_url,
                        'display_order': 2,
                        'is_active': True,
                        'auto_rotate': True,
                        'rotation_speed': 5000
                    }
                    
                    response = requests.post(
                        f'{SUPABASE_URL}/rest/v1/banners',
                        headers=headers,
                        json=banner_data
                    )
                    
                    if response.status_code == 201:
                        uploaded_banners.append('Banner Secundario')
                    
                except Exception as e:
                    print(f"Error procesando banner secundario: {e}")
        
        # Procesar Banner de Promociones
        if 'promo_banner' in request.files:
            promo_banner = request.files['promo_banner']
            if promo_banner and promo_banner.filename:
                try:
                    # Convertir a base64
                    image_data = promo_banner.read()
                    image_base64 = base64.b64encode(image_data).decode('utf-8')
                    image_base64 = f'data:image/jpeg;base64,{image_base64}'
                    
                    # Subir a Supabase Storage
                    image_url = upload_banner_image_to_supabase(image_base64, 'Banner de Promociones')
                    
                    # Crear banner en la base de datos
                    banner_data = {
                        'title': 'Banner de Promociones',
                        'description': 'Banner de promociones de la aplicación',
                        'banner_type': 'banner1',  # Agregar como banner1 adicional
                        'image_url': image_url,
                        'display_order': 3,
                        'is_active': True,
                        'auto_rotate': True,
                        'rotation_speed': 5000
                    }
                    
                    response = requests.post(
                        f'{SUPABASE_URL}/rest/v1/banners',
                        headers=headers,
                        json=banner_data
                    )
                    
                    if response.status_code == 201:
                        uploaded_banners.append('Banner de Promociones')
                    
                except Exception as e:
                    print(f"Error procesando banner de promociones: {e}")
        
        if uploaded_banners:
            return jsonify({
                'success': True,
                'message': f'Banners subidos exitosamente: {", ".join(uploaded_banners)}',
                'uploaded': uploaded_banners
            })
        else:
            return jsonify({
                'success': False,
                'message': 'No se pudieron subir los banners'
            }), 400
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

        
        response = requests.post(
            f'{SUPABASE_URL}/storage/v1/object/product-images/{filename}',
            headers=upload_headers,
            files=files
        )
        
        print(f"📡 Response Status: {response.status_code}")
        print(f"📊 Response Text: {response.text}")
        
        if response.status_code == 200:
            # Retornar URL pública de la imagen
            public_url = f'{SUPABASE_URL}/storage/v1/object/public/product-images/{filename}'
            print(f"✅ Imagen subida exitosamente: {public_url}")
            return public_url
        else:
            print(f"❌ Error subiendo imagen: {response.status_code} - {response.text}")
            # Usar imagen de Unsplash como fallback
            return f'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop&crop=center'
            
    except Exception as e:
        print(f"Error en upload_image_to_supabase: {e}")
        # Usar placeholder como fallback
        return f'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop&crop=center'


# ===== ENDPOINTS DE MODO MANTENIMIENTO =====

@admin.route('/api/maintenance/status', methods=['GET'])
def get_maintenance_status():
    """Obtener estado del modo mantenimiento"""
    global MAINTENANCE_MODE
    return jsonify({
        'maintenance_mode': MAINTENANCE_MODE,
        'message': 'Modo mantenimiento activo' if MAINTENANCE_MODE else 'Sistema operativo'
    })

@admin.route('/api/maintenance/toggle', methods=['POST'])
def toggle_maintenance_mode():
    """Activar/desactivar modo mantenimiento"""
    global MAINTENANCE_MODE
    
    try:
        data = request.get_json() or {}
        new_status = data.get('enabled', not MAINTENANCE_MODE)
        
        MAINTENANCE_MODE = new_status
        
        status_text = "ACTIVADO" if MAINTENANCE_MODE else "DESACTIVADO"
        print(f"🔧 Modo mantenimiento {status_text}")
        
        return jsonify({
            'success': True,
            'maintenance_mode': MAINTENANCE_MODE,
            'message': f'Modo mantenimiento {status_text.lower()}'
        })
        
    except Exception as e:
        print(f"❌ Error toggling maintenance mode: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


# ===== ENDPOINTS DE ACTUALIZACIONES FORZADAS =====

@admin.route('/api/force-update/status', methods=['GET'])
def get_force_update_status():
    """Obtener estado del modo actualización forzada"""
    global FORCE_UPDATE_MODE, IOS_APP_URL, ANDROID_APP_URL
    return jsonify({
        'force_update_mode': FORCE_UPDATE_MODE,
        'ios_app_url': IOS_APP_URL,
        'android_app_url': ANDROID_APP_URL,
        'message': 'Actualización forzada activa' if FORCE_UPDATE_MODE else 'Sistema operativo'
    })

@admin.route('/api/force-update/toggle', methods=['POST'])
def toggle_force_update_mode():
    """Activar/desactivar modo actualización forzada"""
    global FORCE_UPDATE_MODE, IOS_APP_URL, ANDROID_APP_URL
    
    try:
        data = request.get_json() or {}
        new_status = data.get('enabled', not FORCE_UPDATE_MODE)
        ios_url = data.get('ios_url', IOS_APP_URL)
        android_url = data.get('android_url', ANDROID_APP_URL)
        
        FORCE_UPDATE_MODE = new_status
        IOS_APP_URL = ios_url
        ANDROID_APP_URL = android_url
        
        status_text = "ACTIVADO" if FORCE_UPDATE_MODE else "DESACTIVADO"
        print(f"🔄 Modo actualización forzada {status_text}")
        print(f"📱 iOS URL: {IOS_APP_URL}")
        print(f"🤖 Android URL: {ANDROID_APP_URL}")
        
        return jsonify({
            'success': True,
            'force_update_mode': FORCE_UPDATE_MODE,
            'ios_app_url': IOS_APP_URL,
            'android_app_url': ANDROID_APP_URL,
            'message': f'Modo actualización forzada {status_text.lower()}'
        })
        
    except Exception as e:
        print(f"❌ Error toggling force update mode: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
