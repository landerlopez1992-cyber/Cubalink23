# -*- coding: utf-8 -*-
import requests
import json
import os
from datetime import datetime
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

class SupabaseService:
    def __init__(self):
        # Configuración de Supabase desde variables de entorno
        self.supabase_url = os.getenv('SUPABASE_URL', 'https://your-project.supabase.co')
        self.supabase_key = os.getenv('SUPABASE_ANON_KEY', 'your-anon-key')
        self.supabase_service_key = os.getenv('SUPABASE_SERVICE_KEY', 'your-service-key')
        
        self.headers = {
            'apikey': self.supabase_service_key,
            'Authorization': 'Bearer ' + self.supabase_service_key,
            'Content-Type': 'application/json'
        }
    
    def get_users(self):
        """Obtener todos los usuarios"""
        try:
            response = requests.get(
                self.supabase_url + '/rest/v1/users',
                headers=self.headers
            )
            return response.json() if response.status_code == 200 else []
        except Exception as e:
            print("Error getting users: " + str(e))
            return []
    
    def get_user_by_id(self, user_id):
        """Obtener usuario específico"""
        try:
            response = requests.get(
                self.supabase_url + '/rest/v1/users?id=eq.' + user_id,
                headers=self.headers
            )
            return response.json()[0] if response.status_code == 200 and response.json() else None
        except Exception as e:
            print("Error getting user: " + str(e))
            return None
    
    def update_user_status(self, user_id, blocked):
        """Bloquear/desbloquear usuario"""
        try:
            data = {'blocked': blocked}
            response = requests.patch(
                self.supabase_url + '/rest/v1/users?id=eq.' + user_id,
                headers=self.headers,
                json=data
            )
            return response.status_code == 204
        except Exception as e:
            print("Error updating user status: " + str(e))
            return False
    
    def add_user(self, data):
        """Agregar nuevo usuario"""
        try:
            user_data = {
                'user_id': data.get('user_id', ''),
                'email': data.get('email', ''),
                'name': data.get('name', ''),
                'searches': data.get('searches', 0),
                'last_seen': data.get('last_seen', datetime.now().isoformat()),
                'blocked': data.get('blocked', False),
                'created_at': datetime.now().isoformat()
            }
            
            response = requests.post(
                self.supabase_url + '/rest/v1/users',
                headers=self.headers,
                json=user_data
            )
            
            if response.status_code == 201:
                return response.json()
            else:
                raise Exception("Error adding user: " + response.text)
        except Exception as e:
            print("Error adding user: " + str(e))
            raise e
    
    def update_user(self, user_id, data):
        """Actualizar usuario"""
        try:
            response = requests.patch(
                self.supabase_url + '/rest/v1/users?id=eq.' + user_id,
                headers=self.headers,
                json=data
            )
            
            if response.status_code == 204:
                return self.get_user_by_id(user_id)
            else:
                raise Exception("Error updating user: " + response.text)
        except Exception as e:
            print("Error updating user: " + str(e))
            raise e
    
    def delete_user(self, user_id):
        """Eliminar usuario"""
        try:
            response = requests.delete(
                self.supabase_url + '/rest/v1/users?id=eq.' + user_id,
                headers=self.headers
            )
            
            return response.status_code == 204
        except Exception as e:
            print("Error deleting user: " + str(e))
            return False
    
    def get_products(self):
        """Obtener productos con imágenes"""
        try:
            response = requests.get(self.supabase_url + '/rest/v1/products?select=*', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting products: " + str(e))
            return []
    
    def add_product(self, data):
        """Agregar producto con imagen"""
        try:
            product_data = {
                'name': data.get('name', ''),
                'description': data.get('description', ''),
                'price': float(data.get('price', 0)),
                'category': data.get('category', ''),
                'image_url': data.get('image_url', ''),
                'stock': int(data.get('stock', 0)),
                'active': data.get('active', True),
                'created_at': datetime.now().isoformat()
            }
            
            response = requests.post(
                self.supabase_url + '/rest/v1/products',
                headers=self.headers,
                json=product_data
            )
            
            if response.status_code == 201:
                return response.json()
            else:
                raise Exception("Error adding product: " + response.text)
        except Exception as e:
            print("Error adding product: " + str(e))
            raise e
    
    def update_product(self, product_id, data):
        """Actualizar producto"""
        try:
            response = requests.patch(
                self.supabase_url + '/rest/v1/products?id=eq.' + product_id,
                headers=self.headers,
                json=data
            )
            
            if response.status_code == 204:
                return self.get_product_by_id(product_id)
            else:
                raise Exception("Error updating product: " + response.text)
        except Exception as e:
            print("Error updating product: " + str(e))
            raise e
    
    def delete_product(self, product_id):
        """Eliminar producto"""
        try:
            response = requests.delete(
                self.supabase_url + '/rest/v1/products?id=eq.' + product_id,
                headers=self.headers
            )
            
            return response.status_code == 204
        except Exception as e:
            print("Error deleting product: " + str(e))
            return False
    
    def get_product_by_id(self, product_id):
        """Obtener producto específico"""
        try:
            response = requests.get(
                self.supabase_url + '/rest/v1/products?id=eq.' + product_id,
                headers=self.headers
            )
            return response.json()[0] if response.status_code == 200 and response.json() else None
        except Exception as e:
            print("Error getting product: " + str(e))
            return None
    
    def get_banners(self):
        """Obtener banners"""
        try:
            response = requests.get(self.supabase_url + '/rest/v1/banners?select=*', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting banners: " + str(e))
            return []
    
    def add_banner(self, data):
        """Agregar banner"""
        try:
            banner_data = {
                'title': data.get('title', ''),
                'image_url': data.get('image_url', ''),
                'link_url': data.get('link_url', ''),
                'active': data.get('active', True),
                'created_at': datetime.now().isoformat()
            }
            
            response = requests.post(
                self.supabase_url + '/rest/v1/banners',
                headers=self.headers,
                json=banner_data
            )
            
            if response.status_code == 201:
                return response.json()
            else:
                raise Exception("Error adding banner: " + response.text)
        except Exception as e:
            print("Error adding banner: " + str(e))
            raise e
    
    def update_banner(self, banner_id, data):
        """Actualizar banner"""
        try:
            response = requests.patch(
                self.supabase_url + '/rest/v1/banners?id=eq.' + banner_id,
                headers=self.headers,
                json=data
            )
            
            if response.status_code == 204:
                return self.get_banner_by_id(banner_id)
            else:
                raise Exception("Error updating banner: " + response.text)
        except Exception as e:
            print("Error updating banner: " + str(e))
            raise e
    
    def delete_banner(self, banner_id):
        """Eliminar banner"""
        try:
            response = requests.delete(
                self.supabase_url + '/rest/v1/banners?id=eq.' + banner_id,
                headers=self.headers
            )
            
            return response.status_code == 204
        except Exception as e:
            print("Error deleting banner: " + str(e))
            return False
    
    def get_banner_by_id(self, banner_id):
        """Obtener banner específico"""
        try:
            response = requests.get(
                self.supabase_url + '/rest/v1/banners?id=eq.' + banner_id,
                headers=self.headers
            )
            return response.json()[0] if response.status_code == 200 and response.json() else None
        except Exception as e:
            print("Error getting banner: " + str(e))
            return None
    
    def get_orders(self):
        """Obtener pedidos"""
        try:
            response = requests.get(self.supabase_url + '/rest/v1/orders', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting orders: " + str(e))
            return []
    
    def get_order_by_id(self, order_id):
        """Obtener pedido específico"""
        try:
            response = requests.get(
                self.supabase_url + '/rest/v1/orders?id=eq.' + order_id,
                headers=self.headers
            )
            return response.json()[0] if response.status_code == 200 and response.json() else None
        except Exception as e:
            print("Error getting order: " + str(e))
            return None
    
    def get_recharge_history(self):
        """Obtener historial de recargas"""
        try:
            response = requests.get(self.supabase_url + '/rest/v1/recharge_history', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting recharge history: " + str(e))
            return []
    
    def get_transfers(self):
        """Obtener transferencias"""
        try:
            response = requests.get(self.supabase_url + '/rest/v1/transfers', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting transfers: " + str(e))
            return []
    
    def get_categories(self):
        """Obtener categorías"""
        try:
            response = requests.get(self.supabase_url + '/rest/v1/store_categories', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting categories: " + str(e))
            return []
    
    def add_category(self, data):
        """Agregar categoría"""
        try:
            category_data = {
                'name': data.get('name', ''),
                'description': data.get('description', ''),
                'active': data.get('active', True),
                'created_at': datetime.now().isoformat()
            }
            
            response = requests.post(
                self.supabase_url + '/rest/v1/store_categories',
                headers=self.headers,
                json=category_data
            )
            
            if response.status_code == 201:
                return response.json()
            else:
                raise Exception("Error adding category: " + response.text)
        except Exception as e:
            print("Error adding category: " + str(e))
            raise e
    
    def get_activities(self):
        """Obtener actividades"""
        try:
            response = requests.get(self.supabase_url + '/rest/v1/activities', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting activities: " + str(e))
            return []
    
    def get_notifications(self):
        """Obtener notificaciones"""
        try:
            response = requests.get(self.supabase_url + '/rest/v1/notifications', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting notifications: " + str(e))
            return []
    
    def add_notification(self, data):
        """Agregar notificación"""
        try:
            notification_data = {
                'title': data.get('title', ''),
                'message': data.get('message', ''),
                'type': data.get('type', 'info'),
                'user_id': data.get('user_id', None),
                'read': data.get('read', False),
                'created_at': datetime.now().isoformat()
            }
            
            response = requests.post(
                self.supabase_url + '/rest/v1/notifications',
                headers=self.headers,
                json=notification_data
            )
            
            if response.status_code == 201:
                return response.json()
            else:
                raise Exception("Error adding notification: " + response.text)
        except Exception as e:
            print("Error adding notification: " + str(e))
            raise e
    
    def get_config(self):
        """Obtener configuración de la aplicación"""
        try:
            response = requests.get(self.supabase_url + '/rest/v1/app_config', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting config: " + str(e))
            return []
    
    def update_config(self, data):
        """Actualizar configuración de la aplicación"""
        try:
            response = requests.patch(
                self.supabase_url + '/rest/v1/app_config?id=eq.1',
                headers=self.headers,
                json=data
            )
            
            if response.status_code == 204:
                return self.get_config()
            else:
                raise Exception("Error updating config: " + response.text)
        except Exception as e:
            print("Error updating config: " + str(e))
            raise e
    
    def get_statistics(self):
        """Obtener estadísticas"""
        try:
            stats = {}
            
            # Usuarios
            response = requests.get(self.supabase_url + '/rest/v1/users?select=count', headers=self.headers)
            if response.status_code == 200:
                stats['total_users'] = response.json()[0]['count'] if response.json() else 0
            
            # Productos
            response = requests.get(self.supabase_url + '/rest/v1/products?select=count', headers=self.headers)
            if response.status_code == 200:
                stats['total_products'] = response.json()[0]['count'] if response.json() else 0
            
            # Pedidos
            response = requests.get(self.supabase_url + '/rest/v1/orders?select=count', headers=self.headers)
            if response.status_code == 200:
                stats['total_orders'] = response.json()[0]['count'] if response.json() else 0
            
            return stats
        except Exception as e:
            print("Error getting statistics: " + str(e))
            return {}
    
    def get_vehicles(self):
        """Obtener vehículos"""
        try:
            response = requests.get(self.supabase_url + '/rest/v1/vehicles', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting vehicles: " + str(e))
            return []
    
    def add_vehicle(self, data):
        """Agregar vehículo"""
        try:
            vehicle_data = {
                'name': data.get('name', ''),
                'category': data.get('category', ''),
                'daily_price': float(data.get('daily_price', 0)),
                'transmission': data.get('transmission', ''),
                'passenger_capacity': int(data.get('passenger_capacity', 0)),
                'air_conditioning': data.get('air_conditioning', ''),
                'description': data.get('description', ''),
                'features': data.get('features', ''),
                'photos': data.get('photos', ''),
                'active': data.get('active', True),
                'created_at': datetime.now().isoformat()
            }
            
            response = requests.post(
                self.supabase_url + '/rest/v1/vehicles',
                headers=self.headers,
                json=vehicle_data
            )
            
            if response.status_code == 201:
                return response.json()
            else:
                raise Exception("Error adding vehicle: " + response.text)
        except Exception as e:
            print("Error adding vehicle: " + str(e))
            raise e
    
    def get_vehicles_with_pagination(self, page=1, limit=10):
        """Obtener vehículos con paginación"""
        try:
            offset = (page - 1) * limit
            response = requests.get(
                self.supabase_url + '/rest/v1/vehicles?order=created_at.desc&limit=' + str(limit) + '&offset=' + str(offset),
                headers=self.headers
            )
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting vehicles: " + str(e))
            return []
    
    def get_vehicle_by_id(self, vehicle_id):
        """Obtener vehículo específico"""
        try:
            response = requests.get(
                self.supabase_url + '/rest/v1/vehicles?id=eq.' + vehicle_id,
                headers=self.headers
            )
            return response.json()[0] if response.status_code == 200 and response.json() else None
        except Exception as e:
            print("Error getting vehicle: " + str(e))
            return None
    
    def update_vehicle(self, vehicle_id, data):
        """Actualizar vehículo"""
        try:
            response = requests.patch(
                self.supabase_url + '/rest/v1/vehicles?id=eq.' + vehicle_id,
                headers=self.headers,
                json=data
            )
            
            if response.status_code == 204:
                return self.get_vehicle_by_id(vehicle_id)
            else:
                raise Exception("Error updating vehicle: " + response.text)
        except Exception as e:
            print("Error updating vehicle: " + str(e))
            raise e
    
    def delete_vehicle(self, vehicle_id):
        """Eliminar vehículo"""
        try:
            response = requests.delete(
                self.supabase_url + '/rest/v1/vehicles?id=eq.' + vehicle_id,
                headers=self.headers
            )
            
            return response.status_code == 204
        except Exception as e:
            print("Error deleting vehicle: " + str(e))
            return False
    
    def get_phone_bookings(self):
        """Obtener reservas por teléfono"""
        try:
            response = requests.get(self.supabase_url + '/rest/v1/phone_bookings', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting phone bookings: " + str(e))
            return []
    
    def add_phone_booking(self, data):
        """Agregar reserva por teléfono"""
        try:
            booking_data = {
                'client_name': data.get('client_name', ''),
                'client_phone': data.get('client_phone', ''),
                'vehicle_type': data.get('vehicle_type', ''),
                'pickup_date': data.get('pickup_date', ''),
                'return_date': data.get('return_date', ''),
                'pickup_location': data.get('pickup_location', ''),
                'return_location': data.get('return_location', ''),
                'total_price': float(data.get('total_price', 0)),
                'status': data.get('status', 'PENDIENTE'),
                'automation_result': data.get('automation_result', ''),
                'created_at': datetime.now().isoformat()
            }
            
            response = requests.post(
                self.supabase_url + '/rest/v1/phone_bookings',
                headers=self.headers,
                json=booking_data
            )
            
            if response.status_code == 201:
                return response.json()
            else:
                raise Exception("Error adding phone booking: " + response.text)
        except Exception as e:
            print("Error adding phone booking: " + str(e))
            raise e
    
    def get_phone_bookings_with_pagination(self, page=1, limit=10):
        """Obtener reservas por teléfono con paginación"""
        try:
            offset = (page - 1) * limit
            response = requests.get(
                self.supabase_url + '/rest/v1/phone_bookings?order=booking_date.desc&limit=' + str(limit) + '&offset=' + str(offset),
                headers=self.headers
            )
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print("Error getting phone bookings: " + str(e))
            return []
    
    def get_phone_booking_by_id(self, booking_id):
        """Obtener reserva por teléfono específica"""
        try:
            response = requests.get(
                self.supabase_url + '/rest/v1/phone_bookings?id=eq.' + booking_id,
                headers=self.headers
            )
            return response.json()[0] if response.status_code == 200 and response.json() else None
        except Exception as e:
            print("Error getting phone booking: " + str(e))
            return None

# Instancia global
supabase_service = SupabaseService()

