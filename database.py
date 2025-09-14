# -*- coding: utf-8 -*-
"""
Módulo de base de datos simple para el backend
"""

import sqlite3
import json
from datetime import datetime
import os

class LocalDatabase:
    def __init__(self, db_path='products.db'):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """Inicializar la base de datos local"""
        conn = sqlite3.connect(self.db_path)
        conn.text_factory = str
        cursor = conn.cursor()
        
        # Tabla de productos
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS products (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                price REAL NOT NULL,
                category TEXT,
                image_url TEXT,
                stock INTEGER DEFAULT 0,
                active BOOLEAN DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Tabla de categorías
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS categories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                description TEXT,
                active BOOLEAN DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Tabla de banners
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS banners (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT,
                image_url TEXT,
                link_url TEXT,
                active BOOLEAN DEFAULT 1,
                position INTEGER DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Tabla de usuarios
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT UNIQUE,
                email TEXT,
                name TEXT,
                searches INTEGER DEFAULT 0,
                last_seen TIMESTAMP,
                blocked BOOLEAN DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Insertar categorías por defecto
        default_categories = [
            ('Vuelos', 'Servicios de vuelos y aerolíneas'),
            ('Hoteles', 'Reservas de hoteles y alojamiento'),
            ('Paquetes', 'Paquetes turísticos completos'),
            ('Transporte', 'Servicios de transporte terrestre'),
            ('Actividades', 'Tours y actividades turísticas')
        ]
        
        for category in default_categories:
            cursor.execute('''
                INSERT OR IGNORE INTO categories (name, description)
                VALUES (?, ?)
            ''', category)
        
        # Crear tabla de reservas por teléfono
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS phone_bookings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                reservation_id TEXT UNIQUE NOT NULL,
                client_name TEXT NOT NULL,
                client_phone TEXT NOT NULL,
                client_email TEXT,
                vehicle_type TEXT NOT NULL,
                pickup_date TEXT NOT NULL,
                return_date TEXT NOT NULL,
                pickup_location TEXT NOT NULL,
                return_location TEXT,
                total_price REAL NOT NULL,
                commission REAL NOT NULL,
                status TEXT DEFAULT 'pending',
                confirmation_number TEXT,
                temp_email TEXT,
                booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                booking_type TEXT DEFAULT 'phone',
                admin_created BOOLEAN DEFAULT 1,
                automation_result TEXT
            )
        ''')
        
        # Tabla de vehículos
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS vehicles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                category TEXT NOT NULL,
                daily_price REAL NOT NULL,
                transmission TEXT,
                passenger_capacity INTEGER,
                air_conditioning TEXT,
                description TEXT,
                features TEXT,
                photos TEXT,
                active BOOLEAN DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        conn.commit()
        conn.close()
        
        # Inicializar tabla de recargas telefónicas
        self.init_phone_recharges_table()
    
    def get_products(self):
        """Obtener todos los productos"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT p.*, c.name as category_name 
            FROM products p 
            LEFT JOIN categories c ON p.category = c.id
            ORDER BY p.created_at DESC
        ''')
        
        products = []
        for row in cursor.fetchall():
            products.append({
                'id': row[0],
                'name': row[1],
                'description': row[2],
                'price': row[3],
                'category': row[4],
                'category_name': row[9],
                'image_url': row[5],
                'stock': row[6],
                'active': bool(row[7]),
                'created_at': row[8],
                'updated_at': row[9]
            })
        
        conn.close()
        return products
    
    def get_product_by_id(self, product_id):
        """Obtener producto por ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT p.*, c.name as category_name 
            FROM products p 
            LEFT JOIN categories c ON p.category = c.id
            WHERE p.id = ?
        ''', (product_id,))
        
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return {
                'id': row[0],
                'name': row[1],
                'description': row[2],
                'price': row[3],
                'category': row[4],
                'category_name': row[9],
                'image_url': row[5],
                'stock': row[6],
                'active': bool(row[7]),
                'created_at': row[8],
                'updated_at': row[9]
            }
        return None
    
    def add_product(self, data):
        """Agregar nuevo producto"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO products (name, description, price, category, image_url, stock, active)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            data.get('name'),
            data.get('description'),
            data.get('price'),
            data.get('category'),
            data.get('image_url'),
            data.get('stock', 0),
            data.get('active', True)
        ))
        
        product_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return self.get_product_by_id(product_id)
    
    def update_product(self, product_id, data):
        """Actualizar producto"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE products 
            SET name = ?, description = ?, price = ?, category = ?, 
                image_url = ?, stock = ?, active = ?, updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ''', (
            data.get('name'),
            data.get('description'),
            data.get('price'),
            data.get('category'),
            data.get('image_url'),
            data.get('stock'),
            data.get('active'),
            product_id
        ))
        
        conn.commit()
        conn.close()
        
        return self.get_product_by_id(product_id)
    
    def delete_product(self, product_id):
        """Eliminar producto"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('DELETE FROM products WHERE id = ?', (product_id,))
        success = cursor.rowcount > 0
        
        conn.commit()
        conn.close()
        
        return success
    
    def get_categories(self):
        """Obtener todas las categorías"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM categories WHERE active = 1 ORDER BY name')
        categories = []
        
        for row in cursor.fetchall():
            categories.append({
                'id': row[0],
                'name': row[1],
                'description': row[2],
                'active': bool(row[3]),
                'created_at': row[4]
            })
        
        conn.close()
        return categories
    
    # ===== GESTIÓN DE USUARIOS =====
    def get_users(self):
        """Obtener todos los usuarios"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM users 
            ORDER BY created_at DESC
        ''')
        
        users = []
        for row in cursor.fetchall():
            users.append({
                'id': row[0],
                'user_id': row[1],
                'email': row[2],
                'name': row[3],
                'searches': row[4],
                'last_seen': row[5],
                'blocked': bool(row[6]),
                'created_at': row[7]
            })
        
        conn.close()
        return users
    
    def get_user_by_id(self, user_id):
        """Obtener usuario por ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM users WHERE id = ? OR user_id = ?', (user_id, user_id))
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return {
                'id': row[0],
                'user_id': row[1],
                'email': row[2],
                'name': row[3],
                'searches': row[4],
                'last_seen': row[5],
                'blocked': bool(row[6]),
                'created_at': row[7]
            }
        return None
    
    def add_user(self, data):
        """Agregar nuevo usuario"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO users (user_id, email, name, searches, last_seen, blocked)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            data.get('user_id'),
            data.get('email'),
            data.get('name'),
            data.get('searches', 0),
            data.get('last_seen', datetime.now().isoformat()),
            data.get('blocked', False)
        ))
        
        user_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return self.get_user_by_id(user_id)
    
    def update_user(self, user_id, data):
        """Actualizar usuario"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE users 
            SET email = ?, name = ?, searches = ?, last_seen = ?, blocked = ?
            WHERE id = ? OR user_id = ?
        ''', (
            data.get('email'),
            data.get('name'),
            data.get('searches'),
            data.get('last_seen'),
            data.get('blocked'),
            user_id,
            user_id
        ))
        
        conn.commit()
        conn.close()
        
        return self.get_user_by_id(user_id)
    
    def delete_user(self, user_id):
        """Eliminar usuario"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('DELETE FROM users WHERE id = ? OR user_id = ?', (user_id, user_id))
        success = cursor.rowcount > 0
        
        conn.commit()
        conn.close()
        
        return success
    
    def block_user(self, user_id, blocked=True):
        """Bloquear/desbloquear usuario"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE users 
            SET blocked = ?
            WHERE id = ? OR user_id = ?
        ''', (blocked, user_id, user_id))
        
        success = cursor.rowcount > 0
        conn.commit()
        conn.close()
        
        return success
    
    def update_user_activity(self, user_id):
        """Actualizar actividad del usuario"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE users 
            SET last_seen = ?, searches = searches + 1
            WHERE id = ? OR user_id = ?
        ''', (datetime.now().isoformat(), user_id, user_id))
        
        conn.commit()
        conn.close()
    
    # ===== GESTIÓN DE BANNERS =====
    def get_banners(self):
        """Obtener todos los banners"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM banners 
            ORDER BY position ASC, created_at DESC
        ''')
        
        banners = []
        for row in cursor.fetchall():
            banners.append({
                'id': row[0],
                'title': row[1],
                'description': row[2],
                'image_url': row[3],
                'link_url': row[4],
                'active': bool(row[5]),
                'position': row[6],
                'created_at': row[7]
            })
        
        conn.close()
        return banners
    
    def get_banner_by_id(self, banner_id):
        """Obtener banner por ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM banners WHERE id = ?', (banner_id,))
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return {
                'id': row[0],
                'title': row[1],
                'description': row[2],
                'image_url': row[3],
                'link_url': row[4],
                'active': bool(row[5]),
                'position': row[6],
                'created_at': row[7]
            }
        return None
    
    def add_banner(self, data):
        """Agregar nuevo banner"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO banners (title, description, image_url, link_url, active, position)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            data.get('title'),
            data.get('description'),
            data.get('image_url'),
            data.get('link_url'),
            data.get('active', True),
            data.get('position', 0)
        ))
        
        banner_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return self.get_banner_by_id(banner_id)
    
    def update_banner(self, banner_id, data):
        """Actualizar banner"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE banners 
            SET title = ?, description = ?, image_url = ?, link_url = ?, 
                active = ?, position = ?
            WHERE id = ?
        ''', (
            data.get('title'),
            data.get('description'),
            data.get('image_url'),
            data.get('link_url'),
            data.get('active'),
            data.get('position'),
            banner_id
        ))
        
        conn.commit()
        conn.close()
        
        return self.get_banner_by_id(banner_id)
    
    def delete_banner(self, banner_id):
        """Eliminar banner"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('DELETE FROM banners WHERE id = ?', (banner_id,))
        success = cursor.rowcount > 0
        
        conn.commit()
        conn.close()
        
        return success
    
    def toggle_banner_status(self, banner_id, active=True):
        """Activar/desactivar banner"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE banners 
            SET active = ?
            WHERE id = ?
        ''', (active, banner_id))
        
        success = cursor.rowcount > 0
        conn.commit()
        conn.close()
        
        return success
    
    def update_banner_position(self, banner_id, position):
        """Actualizar posición del banner"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE banners 
            SET position = ?
            WHERE id = ?
        ''', (position, banner_id))
        
        success = cursor.rowcount > 0
        conn.commit()
        conn.close()
        
        return success
    
    def get_active_banners(self):
        """Obtener solo banners activos"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM banners 
            WHERE active = 1
            ORDER BY position ASC, created_at DESC
        ''')
        
        banners = []
        for row in cursor.fetchall():
            banners.append({
                'id': row[0],
                'title': row[1],
                'description': row[2],
                'image_url': row[3],
                'link_url': row[4],
                'active': bool(row[5]),
                'position': row[6],
                'created_at': row[7]
            })
        
        conn.close()
        return banners

    # ==================== FUNCIONES DE IMÁGENES DE VEHÍCULOS ====================
    
    def update_vehicle_images(self, vehicle_id, images):
        """Actualizar imágenes de un vehículo en base de datos local"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Obtener imágenes existentes
            cursor.execute('SELECT images FROM vehicles WHERE id = ?', (vehicle_id,))
            result = cursor.fetchone()
            
            if result:
                existing_images = result[0]
                if existing_images:
                    try:
                        existing_images = json.loads(existing_images)
                    except:
                        existing_images = []
                else:
                    existing_images = []
                
                # Agregar nuevas imágenes
                all_images = existing_images + images
                
                # Actualizar vehículo
                cursor.execute('UPDATE vehicles SET images = ? WHERE id = ?', 
                             (json.dumps(all_images), vehicle_id))
                conn.commit()
                conn.close()
                return True
            
            conn.close()
            return False
        except Exception as e:
            print("Error updating vehicle images in local database: " + str(e))
            return False
    
    def remove_vehicle_image(self, vehicle_id, image_url):
        """Eliminar una imagen específica de un vehículo en base de datos local"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Obtener imágenes existentes
            cursor.execute('SELECT images FROM vehicles WHERE id = ?', (vehicle_id,))
            result = cursor.fetchone()
            
            if result:
                existing_images = result[0]
                if existing_images:
                    try:
                        existing_images = json.loads(existing_images)
                    except:
                        existing_images = []
                else:
                    existing_images = []
                
                # Remover imagen
                if image_url in existing_images:
                    existing_images.remove(image_url)
                    
                    # Actualizar vehículo
                    cursor.execute('UPDATE vehicles SET images = ? WHERE id = ?', 
                                 (json.dumps(existing_images), vehicle_id))
                    conn.commit()
                    conn.close()
                    return True
            
            conn.close()
            return False
        except Exception as e:
            print("Error removing vehicle image in local database: " + str(e))
            return False

    def add_phone_booking(self, booking_data):
        """Agregar reserva por teléfono"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO phone_bookings (
                reservation_id, client_name, client_phone, client_email,
                vehicle_type, pickup_date, return_date, pickup_location,
                return_location, total_price, commission, status,
                confirmation_number, temp_email, booking_type, admin_created,
                automation_result
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            booking_data['reservation_id'],
            booking_data['client_name'],
            booking_data['client_phone'],
            booking_data.get('client_email', ''),
            booking_data['vehicle_type'],
            booking_data['pickup_date'],
            booking_data['return_date'],
            booking_data['pickup_location'],
            booking_data.get('return_location', ''),
            booking_data['total_price'],
            booking_data['commission'],
            booking_data['status'],
            booking_data.get('confirmation_number', ''),
            booking_data.get('temp_email', ''),
            booking_data.get('booking_type', 'phone'),
            booking_data.get('admin_created', True),
            json.dumps(booking_data.get('automation_result', {}))
        ))
        
        booking_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return booking_id
    
    def get_phone_bookings(self):
        """Obtener todas las reservas por teléfono"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM phone_bookings 
            ORDER BY booking_date DESC
        ''')
        
        bookings = []
        for row in cursor.fetchall():
            bookings.append({
                'id': row[0],
                'reservation_id': row[1],
                'client_name': row[2],
                'client_phone': row[3],
                'client_email': row[4],
                'vehicle_type': row[5],
                'pickup_date': row[6],
                'return_date': row[7],
                'pickup_location': row[8],
                'return_location': row[9],
                'total_price': row[10],
                'commission': row[11],
                'status': row[12],
                'confirmation_number': row[13],
                'temp_email': row[14],
                'booking_date': row[15],
                'booking_type': row[16],
                'admin_created': bool(row[17]),
                'automation_result': json.loads(row[18]) if row[18] else {}
            })
        
        conn.close()
        return bookings
    
    def get_phone_booking_by_id(self, booking_id):
        """Obtener reserva por teléfono por ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM phone_bookings WHERE id = ?
        ''', (booking_id,))
        
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return {
                'id': row[0],
                'reservation_id': row[1],
                'client_name': row[2],
                'client_phone': row[3],
                'client_email': row[4],
                'vehicle_type': row[5],
                'pickup_date': row[6],
                'return_date': row[7],
                'pickup_location': row[8],
                'return_location': row[9],
                'total_price': row[10],
                'commission': row[11],
                'status': row[12],
                'confirmation_number': row[13],
                'temp_email': row[14],
                'booking_date': row[15],
                'booking_type': row[16],
                'admin_created': bool(row[17]),
                'automation_result': json.loads(row[18]) if row[18] else {}
            }
        
        return None
    
    # ===== FUNCIONES CRUD PARA VEHÍCULOS =====
    
    def add_vehicle(self, vehicle_data):
        """Agregar nuevo vehículo"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO vehicles (name, category, daily_price, transmission, passenger_capacity, 
                                air_conditioning, description, features, photos, active)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            vehicle_data['name'],
            vehicle_data['category'],
            vehicle_data['daily_price'],
            vehicle_data.get('transmission', ''),
            vehicle_data.get('passenger_capacity', 0),
            vehicle_data.get('air_conditioning', ''),
            vehicle_data.get('description', ''),
            json.dumps(vehicle_data.get('features', [])),
            json.dumps(vehicle_data.get('photos', [])),
            vehicle_data.get('active', True)
        ))
        
        vehicle_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return vehicle_id
    
    def get_vehicles(self):
        """Obtener todos los vehículos"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM vehicles 
            ORDER BY created_at DESC
        ''')
        
        vehicles = []
        for row in cursor.fetchall():
            vehicles.append({
                'id': row[0],
                'name': row[1],
                'category': row[2],
                'daily_price': row[3],
                'transmission': row[4],
                'passenger_capacity': row[5],
                'air_conditioning': row[6],
                'description': row[7],
                'features': json.loads(row[8]) if row[8] else [],
                'photos': json.loads(row[9]) if row[9] else [],
                'active': bool(row[10]),
                'created_at': row[11],
                'updated_at': row[12]
            })
        
        conn.close()
        return vehicles
    
    def get_vehicle_by_id(self, vehicle_id):
        """Obtener vehículo por ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM vehicles WHERE id = ?
        ''', (vehicle_id,))
        
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return {
                'id': row[0],
                'name': row[1],
                'category': row[2],
                'daily_price': row[3],
                'transmission': row[4],
                'passenger_capacity': row[5],
                'air_conditioning': row[6],
                'description': row[7],
                'features': json.loads(row[8]) if row[8] else [],
                'photos': json.loads(row[9]) if row[9] else [],
                'active': bool(row[10]),
                'created_at': row[11],
                'updated_at': row[12]
            }
        
        return None
    
    def update_vehicle(self, vehicle_id, vehicle_data):
        """Actualizar vehículo"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE vehicles 
            SET name = ?, category = ?, daily_price = ?, transmission = ?, 
                passenger_capacity = ?, air_conditioning = ?, description = ?, 
                features = ?, photos = ?, active = ?, updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ''', (
            vehicle_data['name'],
            vehicle_data['category'],
            vehicle_data['daily_price'],
            vehicle_data.get('transmission', ''),
            vehicle_data.get('passenger_capacity', 0),
            vehicle_data.get('air_conditioning', ''),
            vehicle_data.get('description', ''),
            json.dumps(vehicle_data.get('features', [])),
            json.dumps(vehicle_data.get('photos', [])),
            vehicle_data.get('active', True),
            vehicle_id
        ))
        
        success = cursor.rowcount > 0
        conn.commit()
        conn.close()
        
        return success
    
    def delete_vehicle(self, vehicle_id):
        """Eliminar vehículo"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('DELETE FROM vehicles WHERE id = ?', (vehicle_id,))
        
        success = cursor.rowcount > 0
        conn.commit()
        conn.close()
        
        return success
    
    def add_vehicle(self, vehicle_data):
        """Agregar nuevo vehículo"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO vehicles (
                name, category, daily_price, transmission, passenger_capacity,
                air_conditioning, description, features, photos, active
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            vehicle_data['name'],
            vehicle_data['category'],
            vehicle_data['daily_price'],
            vehicle_data.get('transmission', ''),
            vehicle_data.get('passenger_capacity', 0),
            vehicle_data.get('air_conditioning', ''),
            vehicle_data.get('description', ''),
            json.dumps(vehicle_data.get('features', [])),
            json.dumps(vehicle_data.get('photos', [])),
            vehicle_data.get('active', True)
        ))
        
        vehicle_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return vehicle_id
    
    # ===== SISTEMA DE RECARGAS TELEFÓNICAS =====
    
    def init_phone_recharges_table(self):
        """Inicializar tabla de recargas telefónicas"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS phone_recharges (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                user_name TEXT NOT NULL,
                user_phone TEXT NOT NULL,
                user_email TEXT,
                phone_number TEXT NOT NULL,
                operator TEXT NOT NULL,
                amount REAL NOT NULL,
                status TEXT DEFAULT 'pending',
                dingconnect_id TEXT,
                error_message TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def add_phone_recharge(self, recharge_data):
        """Agregar nueva recarga telefónica"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO phone_recharges (
                user_id, user_name, user_phone, user_email, phone_number,
                operator, amount, status, dingconnect_id, error_message
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            recharge_data['user_id'],
            recharge_data['user_name'],
            recharge_data['user_phone'],
            recharge_data.get('user_email', ''),
            recharge_data['phone_number'],
            recharge_data['operator'],
            recharge_data['amount'],
            recharge_data.get('status', 'pending'),
            recharge_data.get('dingconnect_id', ''),
            recharge_data.get('error_message', '')
        ))
        
        recharge_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return recharge_id
    
    def get_phone_recharges(self):
        """Obtener todas las recargas telefónicas"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT * FROM phone_recharges 
            ORDER BY created_at DESC
        ''')
        
        recharges = []
        for row in cursor.fetchall():
            recharges.append({
                'id': row[0],
                'user_id': row[1],
                'user_name': row[2],
                'user_phone': row[3],
                'user_email': row[4],
                'phone_number': row[5],
                'operator': row[6],
                'amount': row[7],
                'status': row[8],
                'dingconnect_id': row[9],
                'error_message': row[10],
                'created_at': row[11],
                'updated_at': row[12]
            })
        
        conn.close()
        return recharges
    
    def search_phone_recharges(self, search_params):
        """Buscar recargas por parámetros"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        query = '''
            SELECT * FROM phone_recharges 
            WHERE 1=1
        '''
        params = []
        
        if search_params.get('user_name'):
            query += ' AND user_name LIKE ?'
            params.append('%' + search_params['user_name'] + '%')
        
        if search_params.get('user_phone'):
            query += ' AND user_phone LIKE ?'
            params.append('%' + search_params['user_phone'] + '%')
        
        if search_params.get('user_email'):
            query += ' AND user_email LIKE ?'
            params.append('%' + search_params['user_email'] + '%')
        
        if search_params.get('status'):
            query += ' AND status = ?'
            params.append(search_params['status'])
        
        if search_params.get('date_from'):
            query += ' AND DATE(created_at) >= ?'
            params.append(search_params['date_from'])
        
        if search_params.get('date_to'):
            query += ' AND DATE(created_at) <= ?'
            params.append(search_params['date_to'])
        
        query += ' ORDER BY created_at DESC'
        
        cursor.execute(query, params)
        
        recharges = []
        for row in cursor.fetchall():
            recharges.append({
                'id': row[0],
                'user_id': row[1],
                'user_name': row[2],
                'user_phone': row[3],
                'user_email': row[4],
                'phone_number': row[5],
                'operator': row[6],
                'amount': row[7],
                'status': row[8],
                'dingconnect_id': row[9],
                'error_message': row[10],
                'created_at': row[11],
                'updated_at': row[12]
            })
        
        conn.close()
        return recharges
    
    def update_recharge_status(self, recharge_id, new_status):
        """Actualizar estado de recarga"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE phone_recharges 
            SET status = ?, updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ''', (new_status, recharge_id))
        
        success = cursor.rowcount > 0
        conn.commit()
        conn.close()
        
        return success
    
    def reprocess_recharge(self, recharge_id):
        """Reprocesar recarga fallida"""
        # Aquí se integraría con la API de DingConnect
        # Por ahora solo actualizamos el estado
        return self.update_recharge_status(recharge_id, 'pending')
    
    def delete_recharge(self, recharge_id):
        """Eliminar recarga"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('DELETE FROM phone_recharges WHERE id = ?', (recharge_id,))
        
        success = cursor.rowcount > 0
        conn.commit()
        conn.close()
        
        return success
    
    def get_dingconnect_balance(self):
        """Obtener saldo de DingConnect (simulado)"""
        # Aquí se integraría con la API real de DingConnect
        return 100.00  # Saldo simulado
    
    def add_dingconnect_balance(self, amount):
        """Agregar saldo a DingConnect (simulado)"""
        # Aquí se integraría con la API real de DingConnect
        return True  # Simulado

# Instancia global de la base de datos
local_db = LocalDatabase()

