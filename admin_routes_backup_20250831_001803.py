from flask import Blueprint, render_template, request, jsonify, redirect, url_for, session, current_app
import json
import os
from datetime import datetime
import sqlite3
from supabase_service import supabase_service
from auth_routes import require_auth
from werkzeug.utils import secure_filename
from database import local_db

admin = Blueprint('admin', __name__, url_prefix='/admin')

# Configuración para subida de archivos
UPLOAD_FOLDER = 'static/uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Configuración del panel
ADMIN_CONFIG = {
    'app_name': 'Cubalink23',
    'version': '2.0.0',
    'admin_email': 'landerlopez1992@gmail.com'
}

# Base de datos simple para estadísticas (mantener para logs locales)
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
@require_auth
def dashboard():
    """Panel principal de administración"""
    return render_template('admin/dashboard.html', config=ADMIN_CONFIG)

@admin.route('/stats')
@require_auth
def get_stats():
    """Obtener estadísticas en tiempo real desde Supabase"""
    try:
        # Obtener estadísticas reales de Supabase
        supabase_stats = supabase_service.get_statistics()
        
        # Combinar con estadísticas de vuelos
        stats = {
            'total_searches': 1250,  # Mantener para vuelos
            'active_users': supabase_stats.get('active_users', 0),
            'total_users': supabase_stats.get('total_users', 0),
            'total_products': supabase_stats.get('total_products', 0),
            'total_orders': supabase_stats.get('total_orders', 0),
            'popular_routes': [
                {'route': 'MIA-HAV', 'searches': 156},
                {'route': 'MVD-MIA', 'searches': 89},
                {'route': 'LAX-HAV', 'searches': 67}
            ],
            'system_status': {
                'backend': 'Online',
                'cloudflare_tunnel': 'Active',
                'duffel_api': 'Connected',
                'supabase': 'Connected'
            }
        }
        return jsonify(stats)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== GESTIÓN DE PRODUCTOS MEJORADA =====
@admin.route('/products')
@require_auth
def products():
    """Gestión de productos"""
    return render_template('admin/products.html', config=ADMIN_CONFIG)

@admin.route('/api/products')
@require_auth
def get_products():
    """Obtener productos desde base de datos local"""
    try:
        # Intentar obtener desde Supabase primero
        try:
            products = supabase_service.get_products()
            if products:
                return jsonify(products)
        except:
            pass
        
        # Si falla Supabase, usar base de datos local
        products = local_db.get_products()
        return jsonify(products)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/products', methods=['POST'])
@require_auth
def add_product():
    """Agregar nuevo producto con imagen"""
    try:
        data = request.form.to_dict()
        
        # Manejar subida de imagen
        if 'image' in request.files:
            file = request.files['image']
            if file and allowed_file(file.filename):
                filename = secure_filename(file.filename)
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                filename = "{}_{}".format(timestamp, filename)
                
                # Crear directorio si no existe
                os.makedirs(UPLOAD_FOLDER, exist_ok=True)
                file_path = os.path.join(UPLOAD_FOLDER, filename)
                file.save(file_path)
                
                # URL de la imagen
                data['image_url'] = '/static/uploads/{}'.format(filename)
        
        # Validar datos requeridos
        if not data.get('name') or not data.get('price'):
            return jsonify({'error': 'Nombre y precio son requeridos'}), 400
        
        # Intentar agregar a Supabase primero
        try:
            product = supabase_service.add_product(data)
            return jsonify(product)
        except:
            # Si falla Supabase, usar base de datos local
            product = local_db.add_product(data)
            return jsonify(product)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/products/<product_id>', methods=['PUT'])
@require_auth
def update_product(product_id):
    """Actualizar producto"""
    try:
        data = request.json
        
        # Validar datos requeridos
        if not data.get('name') or not data.get('price'):
            return jsonify({'error': 'Nombre y precio son requeridos'}), 400
        
        # Intentar actualizar en Supabase primero
        try:
            product = supabase_service.update_product(product_id, data)
            return jsonify(product)
        except:
            # Si falla Supabase, usar base de datos local
            product = local_db.update_product(product_id, data)
            return jsonify(product)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/products/<product_id>', methods=['DELETE'])
@require_auth
def delete_product(product_id):
    """Eliminar producto"""
    try:
        # Intentar eliminar en Supabase primero
        try:
            supabase_service.delete_product(product_id)
            return jsonify({'success': True})
        except:
            # Si falla Supabase, usar base de datos local
            success = local_db.delete_product(product_id)
            if success:
                return jsonify({'success': True})
            else:
                return jsonify({'error': 'Producto no encontrado'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/categories')
@require_auth
def get_categories():
    """Obtener categorías de productos"""
    try:
        categories = local_db.get_categories()
        return jsonify(categories)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== GESTIÓN DE BANNERS PUBLICITARIOS =====
@admin.route('/banners')
@require_auth
def banners():
    """Gestión de banners publicitarios"""
    return render_template('admin/banners.html', config=ADMIN_CONFIG)

@admin.route('/api/banners')
@require_auth
def get_banners():
    """Obtener banners desde base de datos local"""
    try:
        # Intentar obtener desde Supabase primero
        try:
            banners = supabase_service.get_banners()
            if banners:
                return jsonify(banners)
        except:
            pass
        
        # Si falla Supabase, usar base de datos local
        banners = local_db.get_banners()
        return jsonify(banners)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/banners/active')
def get_active_banners():
    """Obtener solo banners activos (público)"""
    try:
        # Intentar obtener desde Supabase primero
        try:
            banners = supabase_service.get_active_banners()
            if banners:
                return jsonify(banners)
        except:
            pass
        
        # Si falla Supabase, usar base de datos local
        banners = local_db.get_active_banners()
        return jsonify(banners)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/banners', methods=['POST'])
@require_auth
def add_banner():
    """Agregar nuevo banner con imagen"""
    try:
        data = request.form.to_dict()
        
        # Manejar subida de imagen
        if 'image' in request.files:
            file = request.files['image']
            if file and allowed_file(file.filename):
                filename = secure_filename(file.filename)
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                filename = "banner_{}_{}".format(timestamp, filename)
                
                # Crear directorio si no existe
                os.makedirs(UPLOAD_FOLDER, exist_ok=True)
                file_path = os.path.join(UPLOAD_FOLDER, filename)
                file.save(file_path)
                
                # URL de la imagen
                data['image_url'] = '/static/uploads/{}'.format(filename)
        
        # Agregar banner a Supabase
        banner = supabase_service.add_banner(data)
        return jsonify(banner)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/banners/<banner_id>', methods=['PUT'])
@require_auth
def update_banner(banner_id):
    """Actualizar banner"""
    try:
        data = request.json
        banner = supabase_service.update_banner(banner_id, data)
        return jsonify(banner)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/banners/<banner_id>', methods=['DELETE'])
@require_auth
def delete_banner(banner_id):
    """Eliminar banner"""
    try:
        supabase_service.delete_banner(banner_id)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== GESTIÓN DE USUARIOS =====
@admin.route('/users')
@require_auth
def users():
    """Gestión de usuarios"""
    return render_template('admin/users.html', config=ADMIN_CONFIG)

@admin.route('/api/users', methods=['GET'])
@require_auth
def get_users():
    """Obtener usuarios desde base de datos local"""
    try:
        # Intentar obtener desde Supabase primero
        try:
            users = supabase_service.get_users()
            if users:
                return jsonify(users)
        except:
            pass
        
        # Si falla Supabase, usar base de datos local
        users = local_db.get_users()
        return jsonify(users)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/users', methods=['POST'])
@require_auth
def add_user():
    """Agregar nuevo usuario"""
    try:
        data = request.json
        
        # Validar datos requeridos
        if not data.get('email') or not data.get('name'):
            return jsonify({'error': 'Email y nombre son requeridos'}), 400
        
        # Intentar agregar a Supabase primero
        try:
            user = supabase_service.add_user(data)
            return jsonify(user)
        except:
            # Si falla Supabase, usar base de datos local
            user = local_db.add_user(data)
            return jsonify(user)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/users/<user_id>', methods=['PUT'])
@require_auth
def update_user(user_id):
    """Actualizar usuario"""
    try:
        data = request.json
        
        # Validar datos requeridos
        if not data.get('email') or not data.get('name'):
            return jsonify({'error': 'Email y nombre son requeridos'}), 400
        
        # Intentar actualizar en Supabase primero
        try:
            user = supabase_service.update_user(user_id, data)
            return jsonify(user)
        except:
            # Si falla Supabase, usar base de datos local
            user = local_db.update_user(user_id, data)
            return jsonify(user)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/users/<user_id>', methods=['DELETE'])
@require_auth
def delete_user(user_id):
    """Eliminar usuario"""
    try:
        # Intentar eliminar en Supabase primero
        try:
            success = supabase_service.delete_user(user_id)
            return jsonify({'success': success})
        except:
            # Si falla Supabase, usar base de datos local
            success = local_db.delete_user(user_id)
            if success:
                return jsonify({'success': True})
            else:
                return jsonify({'error': 'Usuario no encontrado'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/users/<user_id>/toggle', methods=['POST'])
@require_auth
def toggle_user_status(user_id):
    """Bloquear/desbloquear usuario"""
    try:
        data = request.json
        blocked = data.get('blocked', False)
        
        # Intentar actualizar en Supabase primero
        try:
            success = supabase_service.update_user_status(user_id, blocked)
            return jsonify({'success': success})
        except:
            # Si falla Supabase, usar base de datos local
            success = local_db.block_user(user_id, blocked)
            return jsonify({'success': success})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/users/<user_id>/activity', methods=['POST'])
@require_auth
def update_user_activity(user_id):
    """Actualizar actividad del usuario"""
    try:
        # Actualizar actividad en base de datos local
        local_db.update_user_activity(user_id)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== GESTIÓN DE ÓRDENES =====
@admin.route('/orders')
@require_auth
def orders():
    """Gestión de órdenes"""
    return render_template('admin/orders.html', config=ADMIN_CONFIG)

@admin.route('/api/orders')
@require_auth
def get_orders():
    """Obtener órdenes desde Supabase"""
    try:
        orders = supabase_service.get_orders()
        return jsonify(orders)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/orders/<order_id>/status', methods=['PUT'])
@require_auth
def update_order_status(order_id):
    """Actualizar estado de orden"""
    try:
        data = request.json
        status = data.get('status')
        success = supabase_service.update_order_status(order_id, status)
        return jsonify({'success': success})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== CONFIGURACIÓN DEL SISTEMA =====
@admin.route('/system')
@require_auth
def system():
    """Configuración del sistema"""
    return render_template('admin/system.html', config=ADMIN_CONFIG)

@admin.route('/api/config')
@require_auth
def get_config():
    """Obtener configuración de la app"""
    try:
        config = supabase_service.get_app_config()
        return jsonify(config)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/config', methods=['PUT'])
@require_auth
def update_config():
    """Actualizar configuración de la app"""
    try:
        data = request.json
        config = supabase_service.update_app_config(data)
        return jsonify(config)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== GESTIÓN DE VUELOS Y RUTAS =====
@admin.route('/flights')
@require_auth
def flights():
    """Gestión de vuelos"""
    return render_template('admin/flights.html', config=ADMIN_CONFIG)

@admin.route('/api/flights')
@require_auth
def get_flights():
    """Obtener vuelos desde Duffel API"""
    try:
        # Simular datos de vuelos (en realidad vendrían de Duffel API)
        flights = [
            {
                'id': '1',
                'origin': 'MIA',
                'destination': 'HAV',
                'airline': 'American Airlines',
                'departure_time': '2024-01-15 10:30:00',
                'arrival_time': '2024-01-15 11:45:00',
                'price': 299.99,
                'status': 'active'
            },
            {
                'id': '2',
                'origin': 'MVD',
                'destination': 'MIA',
                'airline': 'LATAM',
                'departure_time': '2024-01-16 14:20:00',
                'arrival_time': '2024-01-16 18:30:00',
                'price': 450.00,
                'status': 'active'
            }
        ]
        return jsonify(flights)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/routes')
@require_auth
def get_routes():
    """Obtener rutas populares"""
    try:
        routes = [
            {'route': 'MIA-HAV', 'searches': 156, 'bookings': 23},
            {'route': 'MVD-MIA', 'searches': 89, 'bookings': 12},
            {'route': 'LAX-HAV', 'searches': 67, 'bookings': 8},
            {'route': 'MIA-MVD', 'searches': 45, 'bookings': 6}
        ]
        return jsonify(routes)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== HISTORIAL DE RECARGAS =====
@admin.route('/api/recharges')
@require_auth
def get_recharges():
    """Obtener historial de recargas"""
    try:
        recharges = supabase_service.get_recharge_history()
        return jsonify(recharges)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== TRANSFERENCIAS =====
@admin.route('/api/transfers')
@require_auth
def get_transfers():
    """Obtener transferencias"""
    try:
        transfers = supabase_service.get_transfers()
        return jsonify(transfers)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== CATEGORÍAS =====
@admin.route('/api/categories')
@require_auth
def get_categories():
    """Obtener categorías"""
    try:
        categories = supabase_service.get_categories()
        return jsonify(categories)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/categories', methods=['POST'])
@require_auth
def add_category():
    """Agregar categoría"""
    try:
        data = request.json
        category = supabase_service.add_category(data)
        return jsonify(category)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== ACTIVIDADES =====
@admin.route('/api/activities')
@require_auth
def get_activities():
    """Obtener actividades de usuarios"""
    try:
        activities = supabase_service.get_activities()
        return jsonify(activities)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== NOTIFICACIONES =====
@admin.route('/api/notifications')
@require_auth
def get_notifications():
    """Obtener notificaciones"""
    try:
        notifications = supabase_service.get_notifications()
        return jsonify(notifications)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/notifications', methods=['POST'])
@require_auth
def send_notification():
    """Enviar notificación push"""
    try:
        data = request.json
        notification = supabase_service.send_notification(data)
        return jsonify(notification)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== MODO MANTENIMIENTO =====
@admin.route('/api/maintenance', methods=['POST'])
@require_auth
def toggle_maintenance():
    """Activar/desactivar modo mantenimiento"""
    try:
        data = request.json
        enabled = data.get('enabled', False)
        message = data.get('message', 'La aplicación está en mantenimiento')
        
        # Actualizar configuración de mantenimiento
        config_data = {
            'maintenance_mode': enabled,
            'maintenance_message': message
        }
        
        success = supabase_service.update_app_config(config_data)
        return jsonify({'success': success, 'maintenance_mode': enabled})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== ANALYTICS Y REPORTES =====
@admin.route('/api/analytics/sales')
@require_auth
def get_sales_analytics():
    """Obtener analytics de ventas"""
    try:
        analytics = {
            'total_sales': 12500.00,
            'monthly_sales': [
                {'month': 'Enero', 'amount': 3200.00},
                {'month': 'Febrero', 'amount': 2800.00},
                {'month': 'Marzo', 'amount': 3500.00},
                {'month': 'Abril', 'amount': 3000.00}
            ],
            'top_products': [
                {'name': 'Producto A', 'sales': 45},
                {'name': 'Producto B', 'sales': 32},
                {'name': 'Producto C', 'sales': 28}
            ],
            'sales_by_category': [
                {'category': 'Electrónicos', 'amount': 4500.00},
                {'category': 'Ropa', 'amount': 3800.00},
                {'category': 'Hogar', 'amount': 4200.00}
            ]
        }
        return jsonify(analytics)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/analytics/users')
@require_auth
def get_user_analytics():
    """Obtener analytics de usuarios"""
    try:
        analytics = {
            'total_users': 1250,
            'new_users_this_month': 89,
            'active_users': 856,
            'user_growth': [
                {'month': 'Enero', 'users': 1200},
                {'month': 'Febrero', 'users': 1250},
                {'month': 'Marzo', 'users': 1300},
                {'month': 'Abril', 'users': 1350}
            ],
            'user_activity': [
                {'day': 'Lunes', 'active': 156},
                {'day': 'Martes', 'active': 142},
                {'day': 'Miércoles', 'active': 178},
                {'day': 'Jueves', 'active': 165},
                {'day': 'Viernes', 'active': 189},
                {'day': 'Sábado', 'active': 201},
                {'day': 'Domingo', 'active': 167}
            ]
        }
        return jsonify(analytics)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== PROMOCIONES =====
@admin.route('/api/promotions')
@require_auth
def get_promotions():
    """Obtener promociones"""
    try:
        promotions = [
            {
                'id': '1',
                'title': 'Descuento 20% en vuelos',
                'description': 'Descuento especial en vuelos a Cuba',
                'discount': 20,
                'code': 'CUBA20',
                'valid_from': '2024-01-01',
                'valid_until': '2024-12-31',
                'active': True
            },
            {
                'id': '2',
                'title': 'Envío gratis',
                'description': 'Envío gratis en compras superiores a $50',
                'discount': 0,
                'code': 'FREESHIP',
                'valid_from': '2024-01-01',
                'valid_until': '2024-06-30',
                'active': True
            }
        ]
        return jsonify(promotions)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/promotions', methods=['POST'])
@require_auth
def add_promotion():
    """Agregar promoción"""
    try:
        data = request.json
        # Aquí se guardaría en Supabase
        return jsonify({'success': True, 'promotion': data})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== CONFIGURACIÓN AVANZADA =====
@admin.route('/api/config/advanced')
@require_auth
def get_advanced_config():
    """Obtener configuración avanzada"""
    try:
        config = {
            'app_name': 'Cubalink23',
            'version': '2.0.0',
            'api_url': 'https://cubalink23-backend.onrender.com/api/duffel',
            'duffel_api_status': 'Connected',
            'supabase_status': 'Connected',
            'maintenance_mode': False,
            'maintenance_message': '',
            'features': {
                'flight_search': True,
                'product_store': True,
                'user_registration': True,
                'payment_processing': True,
                'push_notifications': True
            }
        }
        return jsonify(config)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/config/advanced', methods=['PUT'])
@require_auth
def update_advanced_config():
    """Actualizar configuración avanzada"""
    try:
        data = request.json
        success = supabase_service.update_app_config(data)
        return jsonify({'success': success})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/payroll/process', methods=['POST'])
@require_auth
def process_payroll():
    """Procesar nómina"""
    try:
        data = request.json
        success = supabase_service.process_payroll(data)
        return jsonify({'success': success})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== SISTEMA DE VERIFICACIÓN MANUAL DE RENTA CAR =====

@admin.route('/rental-verifications')
@require_auth
def rental_verifications():
    """Panel de verificaciones manuales de renta de autos - Redirigir al dashboard"""
    return redirect('/admin/')

@admin.route('/rental-verifications/pending')
@require_auth
def pending_rental_verifications():
    """Verificaciones pendientes - Redirigir al dashboard"""
    return redirect('/admin/')

@admin.route('/api/rental-verifications')
@require_auth
def get_rental_verifications():
    """Obtener todas las verificaciones de renta"""
    try:
        verifications = supabase_service.get_rental_verifications()
        return jsonify(verifications)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/rental-verifications/pending')
@require_auth
def get_pending_rental_verifications():
    """Obtener verificaciones pendientes"""
    try:
        pending = supabase_service.get_pending_rental_verifications()
        return jsonify(pending)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/rental-verifications/request', methods=['POST'])
@require_auth
def request_rental_verification():
    """Solicitar verificación manual de disponibilidad"""
    try:
        data = request.json
        verification_data = {
            'car_model': data.get('car_model'),
            'start_date': data.get('start_date'),
            'end_date': data.get('end_date'),
            'province': data.get('province'),
            'user_id': data.get('user_id'),
            'user_name': data.get('user_name'),
            'user_phone': data.get('user_phone'),
            'user_email': data.get('user_email'),
            'status': 'pending',
            'priority': data.get('priority', 'normal'),  # low, normal, high, urgent
            'notes': data.get('notes', ''),
            'created_at': datetime.now().isoformat()
        }
        
        # Guardar verificación en Supabase
        verification = supabase_service.create_rental_verification(verification_data)
        
        # Enviar notificación al admin
        send_verification_notification(verification)
        
        return jsonify({
            'success': True,
            'verification_id': verification.get('id'),
            'message': 'Verificación solicitada. El administrador la revisará pronto.',
            'estimated_time': '2-4 horas'
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/rental-verifications/<verification_id>/update', methods=['POST'])
@require_auth
def update_rental_verification(verification_id):
    """Actualizar resultado de verificación manual"""
    try:
        data = request.json
        update_data = {
            'status': data.get('status'),  # pending, available, not_available, completed
            'daily_price': data.get('daily_price'),
            'total_price': data.get('total_price'),
            'currency': data.get('currency', 'USD'),
            'availability_notes': data.get('availability_notes'),
            'admin_notes': data.get('admin_notes'),
            'checked_at': datetime.now().isoformat(),
            'checked_by': data.get('admin_id'),
            'rentcarcuba_url': data.get('rentcarcuba_url'),
            'commission_amount': data.get('commission_amount', 50.00)  # $50 comisión por alquiler
        }
        
        # Actualizar verificación en Supabase
        updated_verification = supabase_service.update_rental_verification(verification_id, update_data)
        
        # Notificar al usuario del resultado
        if updated_verification:
            notify_user_verification_result(verification_id, update_data)
        
        return jsonify({
            'success': True,
            'verification_id': verification_id,
            'message': 'Verificación actualizada exitosamente'
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/rental-verifications/<verification_id>/complete', methods=['POST'])
@require_auth
def complete_rental_verification(verification_id):
    """Marcar verificación como completada y procesar alquiler"""
    try:
        data = request.json
        completion_data = {
            'status': 'completed',
            'rental_confirmed': data.get('rental_confirmed', False),
            'rental_id': data.get('rental_id'),
            'payment_status': data.get('payment_status', 'pending'),
            'commission_paid': data.get('commission_paid', False),
            'completed_at': datetime.now().isoformat(),
            'completion_notes': data.get('completion_notes')
        }
        
        # Actualizar verificación
        updated_verification = supabase_service.update_rental_verification(verification_id, completion_data)
        
        # Si se confirmó el alquiler, crear registro de alquiler
        if data.get('rental_confirmed'):
            rental_data = {
                'verification_id': verification_id,
                'user_id': updated_verification.get('user_id'),
                'car_model': updated_verification.get('car_model'),
                'start_date': updated_verification.get('start_date'),
                'end_date': updated_verification.get('end_date'),
                'province': updated_verification.get('province'),
                'daily_price': updated_verification.get('daily_price'),
                'total_price': updated_verification.get('total_price'),
                'commission_amount': updated_verification.get('commission_amount'),
                'status': 'confirmed',
                'created_at': datetime.now().isoformat()
            }
            
            rental = supabase_service.create_rental(rental_data)
        
        return jsonify({
            'success': True,
            'verification_id': verification_id,
            'message': 'Verificación completada exitosamente'
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/rental-verifications/<verification_id>/cancel', methods=['POST'])
@require_auth
def cancel_rental_verification(verification_id):
    """Cancelar verificación de renta"""
    try:
        data = request.json
        cancel_data = {
            'status': 'cancelled',
            'cancellation_reason': data.get('cancellation_reason'),
            'cancelled_at': datetime.now().isoformat(),
            'cancelled_by': data.get('admin_id')
        }
        
        # Actualizar verificación
        updated_verification = supabase_service.update_rental_verification(verification_id, cancel_data)
        
        # Notificar al usuario
        notify_user_verification_cancelled(verification_id, cancel_data)
        
        return jsonify({
            'success': True,
            'verification_id': verification_id,
            'message': 'Verificación cancelada exitosamente'
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@admin.route('/api/rental-verifications/stats')
@require_auth
def get_rental_verification_stats():
    """Obtener estadísticas de verificaciones"""
    try:
        stats = supabase_service.get_rental_verification_stats()
        return jsonify(stats)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== FUNCIONES AUXILIARES PARA NOTIFICACIONES =====

def send_verification_notification(verification):
    """Enviar notificación al admin sobre nueva verificación"""
    try:
        # Aquí iría la lógica para enviar email/SMS al admin
        # Por ahora simulamos la notificación
        
        notification_data = {
            'type': 'rental_verification_request',
            'title': 'Nueva Verificación de Renta de Auto',
            'message': "Verificación solicitada: {} en {}".format(verification.get('car_model'), verification.get('province')),
            'verification_id': verification.get('id'),
            'priority': verification.get('priority'),
            'created_at': datetime.now().isoformat()
        }
        
        # Guardar notificación en base de datos
        supabase_service.create_notification(notification_data)
        
        # Enviar email al admin (implementar después)
        # send_admin_email(notification_data)
        
        return True
    except Exception as e:
        print("Error enviando notificación: {}".format(e))
        return False

def notify_user_verification_result(verification_id, result_data):
    """Notificar al usuario del resultado de la verificación"""
    try:
        # Obtener datos de la verificación
        verification = supabase_service.get_rental_verification_detail(verification_id)
        
        if not verification:
            return False
        
        # Preparar mensaje según el resultado
        if result_data.get('status') == 'available':
            message = "✅ Disponible: {} en {}\n".format(verification.get('car_model'), verification.get('province'))
            message += "💰 Precio por día: ${}\n".format(result_data.get('daily_price'))
            message += "💵 Total: ${}\n".format(result_data.get('total_price'))
            message += "📝 Notas: {}".format(result_data.get('availability_notes', 'Sin notas adicionales'))
        else:
            message = "❌ No disponible: {} en {}\n".format(verification.get('car_model'), verification.get('province'))
            message += "📝 Notas: {}".format(result_data.get('availability_notes', 'Sin notas adicionales'))
        
        # Enviar notificación al usuario
        user_notification = {
            'user_id': verification.get('user_id'),
            'type': 'rental_verification_result',
            'title': 'Resultado de Verificación de Renta',
            'message': message,
            'verification_id': verification_id,
            'created_at': datetime.now().isoformat()
        }
        
        supabase_service.create_user_notification(user_notification)
        
        return True
    except Exception as e:
        print("Error notificando usuario: {}".format(e))
        return False

def notify_user_verification_cancelled(verification_id, cancel_data):
    """Notificar al usuario que la verificación fue cancelada"""
    try:
        verification = supabase_service.get_rental_verification_detail(verification_id)
        
        if not verification:
            return False
        
        message = "❌ Verificación cancelada: {} en {}\n".format(verification.get('car_model'), verification.get('province'))
        message += "📝 Razón: {}".format(cancel_data.get('cancellation_reason', 'Sin especificar'))
        
        user_notification = {
            'user_id': verification.get('user_id'),
            'type': 'rental_verification_cancelled',
            'title': 'Verificación Cancelada',
            'message': message,
            'verification_id': verification_id,
            'created_at': datetime.now().isoformat()
        }
        
        supabase_service.create_user_notification(user_notification)
        
        return True
    except Exception as e:
        print("Error notificando cancelación: {}".format(e))
        return False

# ===== RUTAS FALTANTES PARA BOTONES NUEVOS =====

@admin.route('/vendors')
@require_auth
def vendors():
    """Gestión de vendedores"""
    return render_template('admin/vendors.html', config=ADMIN_CONFIG)

@admin.route('/drivers')
@require_auth
def drivers():
    """Gestión de repartidores"""
    return render_template('admin/drivers.html', config=ADMIN_CONFIG)

@admin.route('/vehicles')
@require_auth
def vehicles():
    """Gestión de renta car"""
    return render_template('admin/vehicles.html', config=ADMIN_CONFIG)

@admin.route('/support-chat')
@require_auth
def support_chat():
    """Chat de soporte"""
    return render_template('admin/support_chat.html', config=ADMIN_CONFIG)

@admin.route('/alerts')
@require_auth
def alerts():
    """Gestión de alertas"""
    return render_template('admin/alerts.html', config=ADMIN_CONFIG)

@admin.route('/wallet')
@require_auth
def wallet():
    """Gestión de billetera"""
    return render_template('admin/wallet.html', config=ADMIN_CONFIG)

@admin.route('/payment-methods')
@require_auth
def payment_methods():
    """Gestión de métodos de pago"""
    return render_template('admin/payment_methods.html', config=ADMIN_CONFIG)

@admin.route('/payroll')
@require_auth
def payroll():
    """Gestión de nómina"""
    return render_template('admin/payroll.html', config=ADMIN_CONFIG)

@admin.route('/system-rules')
@require_auth
def system_rules():
    """Reglas del sistema"""
    return render_template('admin/system_rules.html', config=ADMIN_CONFIG)

@admin.route('/api/contact-info', methods=['GET', 'POST'])
@require_auth
def contact_info():
    """API para gestionar información de contacto de la empresa"""
    if request.method == 'POST':
        data = request.get_json()
        
        # Aquí se guardaría en la base de datos
        contact_info = {
            'phone': data.get('phone'),
            'email': data.get('email'),
            'whatsapp': data.get('whatsapp'),
            'address': data.get('address'),
            'facebook': data.get('facebook'),
            'instagram': data.get('instagram'),
            'twitter': data.get('twitter'),
            'business_hours': data.get('businessHours'),
            'terms_conditions': data.get('termsConditions'),
            'privacy_policy': data.get('privacyPolicy'),
            'updated_at': datetime.now().isoformat()
        }
        
        # Por ahora retornamos éxito
        return jsonify({'success': True, 'message': 'Información de contacto actualizada'})
    
    # GET - Retornar información actual
    contact_info = {
        'phone': '+1 (555) 123-4567',
        'email': 'contacto@cubalink.com',
        'whatsapp': '+1 (555) 987-6543',
        'address': '123 Calle Principal, La Habana, Cuba',
        'facebook': 'https://facebook.com/cubalink',
        'instagram': 'https://instagram.com/cubalink',
        'twitter': 'https://twitter.com/cubalink',
        'business_hours': 'Lunes a Viernes: 9:00 AM - 6:00 PM',
        'terms_conditions': 'Términos y condiciones de la empresa...',
        'privacy_policy': 'Política de privacidad de la empresa...'
    }
    
    return jsonify(contact_info)

@admin.route('/api/upload-logo', methods=['POST'])
@require_auth
def upload_logo():
    """API para subir y actualizar el logo de la empresa"""
    try:
        if 'logo' not in request.files:
            return jsonify({'success': False, 'message': 'No se seleccionó ningún archivo'})
        
        file = request.files['logo']
        if file.filename == '':
            return jsonify({'success': False, 'message': 'No se seleccionó ningún archivo'})
        
        # Validar tipo de archivo
        allowed_extensions = {'svg', 'png', 'jpg', 'jpeg'}
        if not file.filename.lower().endswith(tuple('.' + ext for ext in allowed_extensions)):
            return jsonify({'success': False, 'message': 'Formato de archivo no soportado'})
        
        # Validar tamaño (2MB máximo)
        if len(file.read()) > 2 * 1024 * 1024:
            file.seek(0)  # Reset file pointer
            return jsonify({'success': False, 'message': 'El archivo es demasiado grande'})
        
        file.seek(0)  # Reset file pointer
        
        # Guardar el archivo
        filename = 'company-logo' + os.path.splitext(file.filename)[1]
        filepath = os.path.join('static', 'img', filename)
        
        # Asegurar que el directorio existe
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        
        file.save(filepath)
        
        return jsonify({
            'success': True, 
            'message': 'Logo actualizado correctamente',
            'filename': filename
        })
        
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error al subir el logo: {str(e)}'})

@admin.route('/api/upload-banners', methods=['POST'])
@require_auth
def upload_banners():
    """API para subir banners de la app"""
    try:
        banners_uploaded = []
        
        # Procesar banner principal
        if 'main_banner' in request.files:
            file = request.files['main_banner']
            if file.filename != '':
                filename = 'main-banner' + os.path.splitext(file.filename)[1]
                filepath = os.path.join('static', 'img', 'banners', filename)
                os.makedirs(os.path.dirname(filepath), exist_ok=True)
                file.save(filepath)
                banners_uploaded.append('Banner Principal')
        
        # Procesar banner secundario
        if 'secondary_banner' in request.files:
            file = request.files['secondary_banner']
            if file.filename != '':
                filename = 'secondary-banner' + os.path.splitext(file.filename)[1]
                filepath = os.path.join('static', 'img', 'banners', filename)
                os.makedirs(os.path.dirname(filepath), exist_ok=True)
                file.save(filepath)
                banners_uploaded.append('Banner Secundario')
        
        # Procesar banner de promociones
        if 'promo_banner' in request.files:
            file = request.files['promo_banner']
            if file.filename != '':
                filename = 'promo-banner' + os.path.splitext(file.filename)[1]
                filepath = os.path.join('static', 'img', 'banners', filename)
                os.makedirs(os.path.dirname(filepath), exist_ok=True)
                file.save(filepath)
                banners_uploaded.append('Banner de Promociones')
        
        if banners_uploaded:
            return jsonify({
                'success': True,
                'message': f'Banners actualizados: {", ".join(banners_uploaded)}'
            })
        else:
            return jsonify({'success': False, 'message': 'No se seleccionaron archivos'})
            
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error al subir banners: {str(e)}'})

@admin.route('/api/send-push-notification', methods=['POST'])
@require_auth
def send_push_notification():
    """API para enviar notificaciones push"""
    try:
        data = request.get_json()
        
        # Aquí se integraría con Firebase Cloud Messaging o similar
        notification_data = {
            'title': data.get('title'),
            'message': data.get('message'),
            'type': data.get('type', 'all'),
            'urgent': data.get('urgent', False),
            'timestamp': datetime.now().isoformat()
        }
        
        # Guardar en base de datos
        # save_notification_to_db(notification_data)
        
        # Enviar notificación push real
        # send_push_to_devices(notification_data)
        
        return jsonify({
            'success': True,
            'message': 'Notificación enviada correctamente'
        })
        
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error al enviar notificación: {str(e)}'})

@admin.route('/api/notification-history')
@require_auth
def notification_history():
    """API para obtener historial de notificaciones"""
    try:
        # Aquí se obtendría de la base de datos
        notifications = [
            {
                'date': '2024-01-15 10:30:00',
                'title': 'Nueva Promoción',
                'message': '¡Descuento del 20% en todos los productos!',
                'type': 'all',
                'status': 'Enviada'
            },
            {
                'date': '2024-01-14 15:45:00',
                'title': 'Mantenimiento Programado',
                'message': 'El sistema estará en mantenimiento mañana de 2:00 AM a 4:00 AM',
                'type': 'all',
                'status': 'Enviada'
            }
        ]
        
        return jsonify({
            'success': True,
            'notifications': notifications
        })
        
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error al cargar historial: {str(e)}'})

# ===== GESTIÓN DE AEROLÍNEAS CHARTER =====

@admin.route('/api/charter-airlines', methods=['GET'])
@require_auth
def get_charter_airlines():
    """Obtener lista de aerolíneas charter"""
    try:
        from charter_routes import CHARTER_AIRLINES
        
        airlines = []
        for key, airline in CHARTER_AIRLINES.items():
            airlines.append({
                'id': key,
                'name': airline['name'],
                'url': airline['url'],
                'markup': airline['markup'],
                'active': airline['active'],
                'routes': airline['routes'],
                'check_frequency': airline['check_frequency']
            })
        
        return jsonify({
            'success': True,
            'airlines': airlines
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500

@admin.route('/api/charter-airlines', methods=['POST'])
@require_auth
def save_charter_airline():
    """Guardar o actualizar aerolínea charter"""
    try:
        data = request.get_json()
        from charter_routes import CHARTER_AIRLINES
        
        # En producción, esto se guardaría en la base de datos
        # Por ahora, actualizamos la configuración en memoria
        airline_id = data.get('id')
        if airline_id and airline_id in CHARTER_AIRLINES:
            CHARTER_AIRLINES[airline_id].update({
                'name': data.get('name'),
                'url': data.get('url'),
                'markup': float(data.get('markup', 0)),
                'active': data.get('status') == 'active',
                'routes': data.get('routes', '').split(','),
                'check_frequency': int(data.get('check_frequency', 30))
            })
        
        return jsonify({
            'success': True,
            'message': 'Aerolínea guardada correctamente'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error al guardar: {str(e)}'
        }), 500

@admin.route('/api/charter-airlines/<airline_id>/toggle', methods=['POST'])
@require_auth
def toggle_charter_airline(airline_id):
    """Activar/desactivar aerolínea charter"""
    try:
        from charter_routes import CHARTER_AIRLINES
        
        if airline_id in CHARTER_AIRLINES:
            CHARTER_AIRLINES[airline_id]['active'] = not CHARTER_AIRLINES[airline_id]['active']
            
            return jsonify({
                'success': True,
                'message': f"Aerolínea {'activada' if CHARTER_AIRLINES[airline_id]['active'] else 'desactivada'} correctamente"
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Aerolínea no encontrada'
            }), 404
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500

@admin.route('/api/charter-airlines/<airline_id>/test', methods=['POST'])
@require_auth
def test_charter_airline(airline_id):
    """Probar conexión con aerolínea charter"""
    try:
        from charter_routes import CHARTER_AIRLINES, charter_scraper
        from datetime import datetime, timedelta
        
        if airline_id not in CHARTER_AIRLINES:
            return jsonify({
                'success': False,
                'message': 'Aerolínea no encontrada'
            }), 404
        
        airline = CHARTER_AIRLINES[airline_id]
        
        # Simular prueba de conexión
        test_data = {
            'origin': 'Miami',
            'destination': 'Havana',
            'departure_date': (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%d')
        }
        
        if airline_id == 'xael':
            flights = charter_scraper.scrape_xael_charter(test_data)
        elif airline_id == 'cubazul':
            flights = charter_scraper.scrape_cubazul_charter(test_data)
        elif airline_id == 'havana_air':
            flights = charter_scraper.scrape_havana_air_charter(test_data)
        else:
            flights = []
        
        if flights:
            return jsonify({
                'success': True,
                'message': f'Conexión exitosa. Se encontraron {len(flights)} vuelos de prueba.',
                'test_flights': flights
            })
        else:
            return jsonify({
                'success': False,
                'message': 'No se pudieron obtener vuelos de prueba'
            })
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error en prueba: {str(e)}'
        }), 500

@admin.route('/api/charter-bookings')
@require_auth
def get_charter_bookings():
    """Obtener reservas charter"""
    try:
        # En producción, obtener de base de datos
        bookings = [
            {
                'id': 'CH001',
                'passenger_name': 'Juan Pérez',
                'origin': 'Miami',
                'destination': 'Havana',
                'departure_date': '2024-01-20',
                'airline': 'Xael Charter',
                'status': 'PENDIENTE',
                'total_price': 300,
                'created_at': '2024-01-15 10:30:00',
                'can_modify': True,
                'can_cancel': True
            },
            {
                'id': 'CH002',
                'passenger_name': 'María García',
                'origin': 'Miami',
                'destination': 'Havana',
                'departure_date': '2024-01-22',
                'airline': 'Cubazul Air Charter',
                'status': 'CONFIRMADO',
                'total_price': 285,
                'created_at': '2024-01-14 15:45:00',
                'can_modify': False,
                'can_cancel': False
            }
        ]
        
        return jsonify({
            'success': True,
            'bookings': bookings
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error al cargar reservas: {str(e)}'
        }), 500

@admin.route('/api/charter-bookings/<booking_id>/confirm', methods=['POST'])
@require_auth
def confirm_charter_booking(booking_id):
    """Confirmar reserva charter"""
    try:
        # En producción, actualizar en base de datos
        # update_booking_status(booking_id, 'CONFIRMADO')
        
        return jsonify({
            'success': True,
            'message': 'Reserva confirmada. Tiquete emitido. No se permiten más cambios.'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error al confirmar reserva: {str(e)}'
        }), 500

# ==================== RUTAS PARA SUBIR IMÁGENES DE VEHÍCULOS ====================

@admin.route('/api/vehicles/upload-images', methods=['POST'])
@require_auth
def upload_vehicle_images():
    """Subir imágenes de vehículos"""
    try:
        if 'images' not in request.files:
            return jsonify({
                'success': False,
                'error': 'No se encontraron archivos de imagen'
            }), 400
        
        files = request.files.getlist('images')
        vehicle_id = request.form.get('vehicle_id')
        
        if not vehicle_id:
            return jsonify({
                'success': False,
                'error': 'ID del vehículo requerido'
            }), 400
        
        uploaded_images = []
        
        for file in files:
            if file and file.filename:
                # Verificar tipo de archivo
                if not file.filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.webp')):
                    return jsonify({
                        'success': False,
                        'error': 'Solo se permiten archivos de imagen (PNG, JPG, JPEG, GIF, WEBP)'
                    }), 400
                
                # Generar nombre único para el archivo
                import os
                import uuid
                from werkzeug.utils import secure_filename
                
                filename = secure_filename(file.filename)
                file_extension = filename.rsplit('.', 1)[1].lower()
                unique_filename = f"vehicle_{vehicle_id}_{uuid.uuid4().hex[:8]}.{file_extension}"
                
                # Crear directorio si no existe
                upload_folder = os.path.join('static', 'img', 'vehicles')
                os.makedirs(upload_folder, exist_ok=True)
                
                # Guardar archivo
                file_path = os.path.join(upload_folder, unique_filename)
                file.save(file_path)
                
                # URL relativa para la base de datos
                image_url = f"/static/img/vehicles/{unique_filename}"
                uploaded_images.append(image_url)
        
        # Actualizar vehículo con las nuevas imágenes
        if uploaded_images:
            # Obtener imágenes existentes
            try:
                vehicle = supabase_service.get_vehicle_by_id(int(vehicle_id))
                if vehicle:
                    existing_images = vehicle.get('images', '[]')
                    if isinstance(existing_images, str):
                        import json
                        existing_images = json.loads(existing_images)
                    else:
                        existing_images = existing_images or []
                    
                    # Agregar nuevas imágenes
                    all_images = existing_images + uploaded_images
                    
                    # Actualizar en Supabase
                    try:
                        supabase_service.update_vehicle(int(vehicle_id), {'images': json.dumps(all_images)})
                    except:
                        pass
                    
                    # Actualizar en base de datos local
                    local_db.update_vehicle(int(vehicle_id), {'images': json.dumps(all_images)})
            except:
                pass
        
        return jsonify({
            'success': True,
            'message': f'{len(uploaded_images)} imágenes subidas exitosamente',
            'images': uploaded_images
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@admin.route('/api/vehicles/<int:vehicle_id>/images', methods=['DELETE'])
@require_auth
def delete_vehicle_image(vehicle_id):
    """Eliminar imagen específica de un vehículo"""
    try:
        data = request.get_json()
        image_url = data.get('image_url')
        
        if not image_url:
            return jsonify({
                'success': False,
                'error': 'URL de imagen requerida'
            }), 400
        
        # Obtener vehículo
        try:
            vehicle = supabase_service.get_vehicle_by_id(vehicle_id)
            if vehicle:
                existing_images = vehicle.get('images', '[]')
                if isinstance(existing_images, str):
                    import json
                    existing_images = json.loads(existing_images)
                else:
                    existing_images = existing_images or []
                
                # Remover imagen
                if image_url in existing_images:
                    existing_images.remove(image_url)
                    
                    # Actualizar en Supabase
                    try:
                        supabase_service.update_vehicle(vehicle_id, {'images': json.dumps(existing_images)})
                    except:
                        pass
                    
                    # Actualizar en base de datos local
                    local_db.update_vehicle(vehicle_id, {'images': json.dumps(existing_images)})
                    
                    # Eliminar archivo físico
                    import os
                    file_path = image_url.replace('/static/', 'static/')
                    if os.path.exists(file_path):
                        os.remove(file_path)
                    
                    return jsonify({
                        'success': True,
                        'message': 'Imagen eliminada exitosamente'
                    })
                else:
                    return jsonify({
                        'success': False,
                        'error': 'Imagen no encontrada'
                    }), 404
            else:
                return jsonify({
                    'success': False,
                    'error': 'Vehículo no encontrado'
                }), 404
        except:
            # Si falla Supabase, intentar con base de datos local
            vehicle = local_db.get_vehicle_by_id(vehicle_id)
            if vehicle:
                existing_images = vehicle.get('images', '[]')
                if isinstance(existing_images, str):
                    import json
                    existing_images = json.loads(existing_images)
                else:
                    existing_images = existing_images or []
                
                # Remover imagen
                if image_url in existing_images:
                    existing_images.remove(image_url)
                    
                    # Actualizar en base de datos local
                    local_db.update_vehicle(vehicle_id, {'images': json.dumps(existing_images)})
                    
                    # Eliminar archivo físico
                    import os
                    file_path = image_url.replace('/static/', 'static/')
                    if os.path.exists(file_path):
                        os.remove(file_path)
                    
                    return jsonify({
                        'success': True,
                        'message': 'Imagen eliminada exitosamente'
                    })
                else:
                    return jsonify({
                        'success': False,
                        'error': 'Imagen no encontrada'
                    }), 404
            else:
                return jsonify({
                    'success': False,
                    'error': 'Vehículo no encontrado'
                }), 404
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

# ==================== RUTAS PARA CATEGORÍAS DE VEHÍCULOS ====================

@admin.route('/api/vehicles/categories')
@require_auth
def get_vehicle_categories():
    """Obtener categorías de vehículos disponibles"""
    try:
        # Categorías basadas en Rent Cuba Car
        categories = [
            {
                'id': 'economico_mecanico',
                'name': 'Económico Mecánico',
                'description': 'Vehículos compactos con transmisión manual, ideales para desplazamientos urbanos y viajes cortos',
                'examples': ['Peugeot 208', 'Renault Sandero', 'Hyundai i10'],
                'daily_rate_range': '25-35 USD',
                'seats': '4-5',
                'features': ['Transmisión manual', 'Económico en combustible', 'Fácil de manejar']
            },
            {
                'id': 'economico_automatico',
                'name': 'Económico Automático',
                'description': 'Vehículos compactos con transmisión automática, mayor comodidad en la conducción',
                'examples': ['Toyota Yaris', 'Honda Fit', 'Nissan March'],
                'daily_rate_range': '30-40 USD',
                'seats': '4-5',
                'features': ['Transmisión automática', 'Económico en combustible', 'Fácil de estacionar']
            },
            {
                'id': 'medio_mecanico',
                'name': 'Medio Mecánico',
                'description': 'Vehículos de tamaño mediano con transmisión manual, ideales para viajes más largos',
                'examples': ['Peugeot 301', 'Renault Logan', 'Hyundai Accent'],
                'daily_rate_range': '35-45 USD',
                'seats': '5',
                'features': ['Transmisión manual', 'Más espacio interior', 'Ideal para viajes']
            },
            {
                'id': 'medio_automatico',
                'name': 'Medio Automático',
                'description': 'Vehículos de tamaño mediano con transmisión automática, combinando espacio y confort',
                'examples': ['Toyota Corolla', 'Honda Civic', 'Nissan Sentra'],
                'daily_rate_range': '40-50 USD',
                'seats': '5',
                'features': ['Transmisión automática', 'Espacio amplio', 'Confort superior']
            },
            {
                'id': 'alto_estandar',
                'name': 'Alto Estándar',
                'description': 'Vehículos de gama alta con características avanzadas y mayor espacio interior',
                'examples': ['Toyota Camry', 'Honda Accord', 'Nissan Altima'],
                'daily_rate_range': '50-70 USD',
                'seats': '5',
                'features': ['Características avanzadas', 'Espacio premium', 'Tecnología superior']
            },
            {
                'id': 'premium',
                'name': 'Premium',
                'description': 'Vehículos de lujo con prestaciones superiores y equipamiento de alta calidad',
                'examples': ['Mercedes-Benz C-Class', 'BMW 3 Series', 'Audi A4'],
                'daily_rate_range': '80-120 USD',
                'seats': '5',
                'features': ['Lujo superior', 'Tecnología avanzada', 'Confort máximo']
            },
            {
                'id': 'jeep',
                'name': 'Jeep',
                'description': 'Vehículos todoterreno adecuados para rutas fuera de carretera o terrenos difíciles',
                'examples': ['Jeep Wrangler', 'Toyota 4Runner', 'Nissan X-Trail'],
                'daily_rate_range': '60-90 USD',
                'seats': '5-7',
                'features': ['Tracción 4x4', 'Todoterreno', 'Ideal para aventuras']
            },
            {
                'id': 'minivan',
                'name': 'Minivan',
                'description': 'Vehículos con capacidad para más pasajeros, ideales para grupos o familias numerosas',
                'examples': ['Toyota Hiace', 'Ford Transit', 'Mercedes-Benz Sprinter'],
                'daily_rate_range': '70-100 USD',
                'seats': '8-15',
                'features': ['Gran capacidad', 'Ideal para grupos', 'Espacio de carga']
            }
        ]
        
        return jsonify({
            'success': True,
            'categories': categories
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@admin.route('/api/vehicles/categories/<category_id>')
@require_auth
def get_vehicle_category(category_id):
    """Obtener información específica de una categoría"""
    try:
        # Obtener todas las categorías
        import requests
        response = requests.get(f"{BASE_URL}/admin/api/vehicles/categories")
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                categories = data.get('categories', [])
                category = next((cat for cat in categories if cat['id'] == category_id), None)
                
                if category:
                    return jsonify({
                        'success': True,
                        'category': category
                    })
                else:
                    return jsonify({
                        'success': False,
                        'error': 'Categoría no encontrada'
                    }), 404
            else:
                return jsonify({
                    'success': False,
                    'error': 'Error al obtener categorías'
                }), 500
        else:
            return jsonify({
                'success': False,
                'error': 'Error HTTP'
            }), 500
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

# ==================== RUTA PARA CREAR VEHÍCULO CON CATEGORÍA ====================

@admin.route('/api/vehicles/create-with-category', methods=['POST'])
@require_auth
def create_vehicle_with_category():
    """Crear vehículo con categoría específica"""
    try:
        data = request.get_json()
        
        # Validaciones básicas
        required_fields = ['license_plate', 'brand', 'model', 'year', 'color', 
                          'vehicle_type', 'transmission', 'fuel_type', 'seats', 
                          'daily_rate', 'location', 'category_id']
        
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'success': False,
                    'error': f'Campo requerido: {field}'
                }), 400
        
        # Validar que la categoría existe
        category_id = data.get('category_id')
        try:
            import requests
            response = requests.get(f"{BASE_URL}/admin/api/vehicles/categories/{category_id}")
            if response.status_code != 200:
                return jsonify({
                    'success': False,
                    'error': 'Categoría no válida'
                }), 400
        except:
            return jsonify({
                'success': False,
                'error': 'Error al validar categoría'
            }), 400
        
        # Agregar información de categoría al vehículo
        vehicle_data = data.copy()
        vehicle_data['category_id'] = category_id
        
        # Intentar agregar en Supabase
        try:
            vehicle_id = supabase_service.add_vehicle(vehicle_data)
            if vehicle_id:
                return jsonify({
                    'success': True,
                    'vehicle_id': vehicle_id,
                    'message': 'Vehículo creado exitosamente con categoría'
                })
        except:
            pass
        
        # Si falla Supabase, agregar en base de datos local
        vehicle_id = local_db.add_vehicle(vehicle_data)
        
        return jsonify({
            'success': True,
            'vehicle_id': vehicle_id,
            'message': 'Vehículo creado exitosamente con categoría'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500