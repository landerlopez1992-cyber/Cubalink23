# -*- coding: utf-8 -*-
import requests
import json
import os
from datetime import datetime
from dotenv import load_dotenv

# En producción (Render.com) no cargar archivo .env
# Las variables de entorno se configuran directamente en el dashboard

class SupabaseService:
    def __init__(self):
        # Configuración de Supabase - MISMAS credenciales que usa Flutter
        self.supabase_url = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        self.supabase_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        self.supabase_service_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTc5Mjc5OCwiZXhwIjoyMDcxMzY4Nzk4fQ.wq_9zKkOWXHOXbRJrGZeVhERcJhcKlK5-PFVe5x8IUU'
        
        self.headers = {
            'apikey': self.supabase_key,
            'Authorization': 'Bearer ' + self.supabase_key,
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
                f'{self.supabase_url}/rest/v1/users?id=eq.{user_id}',
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
                f'{self.supabase_url}/rest/v1/users?id=eq.{user_id}',
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
                f'{self.supabase_url}/rest/v1/users?id=eq.{user_id}',
                headers=self.headers
            )
            
            return response.status_code == 204
        except Exception as e:
            print("Error deleting user: " + str(e))
            return False
    
    def get_products(self):
        """Obtener productos con imágenes"""
        try:
            response = requests.get(f'{self.supabase_url}/rest/v1/store_products?select=*', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                print(f"Error getting products: {response.status_code} - {response.text}")
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
                f'{self.supabase_url}/rest/v1/store_products',
                headers=self.headers,
                json=product_data
            )
            
            if response.status_code == 201:
                return response.json()
            else:
                raise Exception(f"Error adding product: {response.text}")
        except Exception as e:
            print(f"Error adding product: {e}")
            raise e
    
    def update_product(self, product_id, data):
        """Actualizar producto"""
        try:
            response = requests.patch(
                f'{self.supabase_url}/rest/v1/store_products?id=eq.{product_id}',
                headers=self.headers,
                json=data
            )
            
            if response.status_code == 204:
                return {'success': True}
            else:
                raise Exception(f"Error updating product: {response.text}")
        except Exception as e:
            print(f"Error updating product: {e}")
            raise e
    
    def delete_product(self, product_id):
        """Eliminar producto"""
        try:
            response = requests.delete(
                f'{self.supabase_url}/rest/v1/store_products?id=eq.{product_id}',
                headers=self.headers
            )
            
            if response.status_code == 204:
                return True
            else:
                raise Exception(f"Error deleting product: {response.text}")
        except Exception as e:
            print(f"Error deleting product: {e}")
            raise e

    # ===== GESTIÓN DE BANNERS PUBLICITARIOS =====
    def get_banners(self):
        """Obtener banners publicitarios"""
        try:
            response = requests.get(f'{self.supabase_url}/rest/v1/banners?select=*', headers=self.headers)
            if response.status_code == 200:
                return response.json()
            else:
                return []
        except Exception as e:
            print(f"Error getting banners: {e}")
            return []
    
    def add_banner(self, data):
        """Agregar banner con imagen"""
        try:
            banner_data = {
                'title': data.get('title', ''),
                'description': data.get('description', ''),
                'image_url': data.get('image_url', ''),
                'banner_type': data.get('banner_type', 'welcome'),  # 'welcome' o 'flights'
                'active': data.get('active', True),
                'order': int(data.get('order', 0)),
                'created_at': datetime.now().isoformat()
            }
            
            response = requests.post(
                f'{self.supabase_url}/rest/v1/banners',
                headers=self.headers,
                json=banner_data
            )
            
            if response.status_code == 201:
                return response.json()
            else:
                raise Exception(f"Error adding banner: {response.text}")
        except Exception as e:
            print(f"Error adding banner: {e}")
            raise e
    
    def update_banner(self, banner_id, data):
        """Actualizar banner"""
        try:
            response = requests.patch(
                f'{self.supabase_url}/rest/v1/banners?id=eq.{banner_id}',
                headers=self.headers,
                json=data
            )
            
            if response.status_code == 204:
                return {'success': True}
            else:
                raise Exception(f"Error updating banner: {response.text}")
        except Exception as e:
            print(f"Error updating banner: {e}")
            raise e
    
    def delete_banner(self, banner_id):
        """Eliminar banner"""
        try:
            response = requests.delete(
                f'{self.supabase_url}/rest/v1/banners?id=eq.{banner_id}',
                headers=self.headers
            )
            
            if response.status_code == 204:
                return True
            else:
                raise Exception(f"Error deleting banner: {response.text}")
        except Exception as e:
            print(f"Error deleting banner: {e}")
            raise e
    
    def get_orders(self):
        """Obtener todas las órdenes"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/orders',
                headers=self.headers
            )
            return response.json() if response.status_code == 200 else []
        except Exception as e:
            print(f"Error getting orders: {e}")
            return []
    
    def update_order_status(self, order_id, status):
        """Actualizar estado de orden"""
        try:
            data = {'status': status, 'updated_at': datetime.now().isoformat()}
            response = requests.patch(
                f'{self.supabase_url}/rest/v1/orders?id=eq.{order_id}',
                headers=self.headers,
                json=data
            )
            return response.status_code == 204
        except Exception as e:
            print(f"Error updating order status: {e}")
            return False
    
    def get_recharge_history(self):
        """Obtener historial de recargas"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/recharge_history',
                headers=self.headers
            )
            return response.json() if response.status_code == 200 else []
        except Exception as e:
            print(f"Error getting recharge history: {e}")
            return []
    
    def get_transfers(self):
        """Obtener transferencias"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/transfers',
                headers=self.headers
            )
            return response.json() if response.status_code == 200 else []
        except Exception as e:
            print(f"Error getting transfers: {e}")
            return []
    
    def get_categories(self):
        """Obtener categorías"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/store_categories',
                headers=self.headers
            )
            return response.json() if response.status_code == 200 else []
        except Exception as e:
            print(f"Error getting categories: {e}")
            return []
    
    def add_category(self, category_data):
        """Agregar categoría"""
        try:
            response = requests.post(
                f'{self.supabase_url}/rest/v1/store_categories',
                headers=self.headers,
                json=category_data
            )
            return response.json() if response.status_code == 201 else None
        except Exception as e:
            print(f"Error adding category: {e}")
            return None
    
    def get_activities(self):
        """Obtener actividades de usuarios"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/activities',
                headers=self.headers
            )
            return response.json() if response.status_code == 200 else []
        except Exception as e:
            print(f"Error getting activities: {e}")
            return []
    
    def get_notifications(self):
        """Obtener notificaciones"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/notifications',
                headers=self.headers
            )
            return response.json() if response.status_code == 200 else []
        except Exception as e:
            print(f"Error getting notifications: {e}")
            return []
    
    def send_notification(self, notification_data):
        """Enviar notificación"""
        try:
            response = requests.post(
                f'{self.supabase_url}/rest/v1/notifications',
                headers=self.headers,
                json=notification_data
            )
            return response.json() if response.status_code == 201 else None
        except Exception as e:
            print(f"Error sending notification: {e}")
            return None
    
    def get_app_config(self):
        """Obtener configuración de la app"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/app_config',
                headers=self.headers
            )
            return response.json()[0] if response.status_code == 200 and response.json() else {}
        except Exception as e:
            print(f"Error getting app config: {e}")
            return {}
    
    def update_app_config(self, config_data):
        """Actualizar configuración de la app"""
        try:
            response = requests.patch(
                f'{self.supabase_url}/rest/v1/app_config?id=eq.1',
                headers=self.headers,
                json=config_data
            )
            return response.status_code == 204
        except Exception as e:
            print(f"Error updating app config: {e}")
            return False
    
    def get_statistics(self):
        """Obtener estadísticas generales"""
        try:
            # Obtener conteos de diferentes tablas
            users_response = requests.get(
                f'{self.supabase_url}/rest/v1/users?select=count',
                headers=self.headers
            )
            products_response = requests.get(
                f'{self.supabase_url}/rest/v1/store_products?select=count',
                headers=self.headers
            )
            orders_response = requests.get(
                f'{self.supabase_url}/rest/v1/orders?select=count',
                headers=self.headers
            )
            
            stats = {
                'total_users': len(users_response.json()) if users_response.status_code == 200 else 0,
                'total_products': len(products_response.json()) if products_response.status_code == 200 else 0,
                'total_orders': len(orders_response.json()) if orders_response.status_code == 200 else 0,
                'active_users': len([u for u in users_response.json() if not u.get('blocked', False)]) if users_response.status_code == 200 else 0
            }
            
            return stats
        except Exception as e:
            print(f"Error getting statistics: {e}")
            return {
                'total_users': 0,
                'total_products': 0,
                'total_orders': 0,
                'active_users': 0
            }

    def add_rental_service(self, service_data):
        """Agregar servicio a una renta en Supabase"""
        try:
            response = self.supabase.table('rental_services').insert(service_data).execute()
            return response.data[0]['id'] if response.data else None
        except Exception as e:
            print(f"Error adding rental service to Supabase: {e}")
            return None

    # ==================== FUNCIONES DE IMÁGENES DE VEHÍCULOS ====================
    
    def update_vehicle_images(self, vehicle_id, images):
        """Actualizar imágenes de un vehículo en Supabase"""
        try:
            # Obtener imágenes existentes
            vehicle = self.get_vehicle_by_id(vehicle_id)
            if vehicle:
                existing_images = vehicle.get('images', [])
                if isinstance(existing_images, str):
                    import json
                    existing_images = json.loads(existing_images)
                else:
                    existing_images = existing_images or []
                
                # Agregar nuevas imágenes
                all_images = existing_images + images
                
                # Actualizar vehículo
                response = self.supabase.table('vehicles').update({
                    'images': json.dumps(all_images)
                }).eq('id', vehicle_id).execute()
                
                return len(response.data) > 0 if response.data else False
            return False
        except Exception as e:
            print(f"Error updating vehicle images in Supabase: {e}")
            return False
    
    def remove_vehicle_image(self, vehicle_id, image_url):
        """Eliminar una imagen específica de un vehículo en Supabase"""
        try:
            # Obtener imágenes existentes
            vehicle = self.get_vehicle_by_id(vehicle_id)
            if vehicle:
                existing_images = vehicle.get('images', [])
                if isinstance(existing_images, str):
                    import json
                    existing_images = json.loads(existing_images)
                else:
                    existing_images = existing_images or []
                
                # Remover imagen
                if image_url in existing_images:
                    existing_images.remove(image_url)
                    
                    # Actualizar vehículo
                    response = self.supabase.table('vehicles').update({
                        'images': json.dumps(existing_images)
                    }).eq('id', vehicle_id).execute()
                    
                    return len(response.data) > 0 if response.data else False
            return False
        except Exception as e:
            print(f"Error removing vehicle image in Supabase: {e}")
            return False
    
    # ===== FUNCIONES CRUD PARA VEHÍCULOS =====
    
    def add_vehicle(self, vehicle_data):
        """Agregar nuevo vehículo a Supabase"""
        try:
            response = requests.post(
                f'{self.supabase_url}/rest/v1/vehicles',
                headers=self.headers,
                json={
                    'name': vehicle_data['name'],
                    'category': vehicle_data['category'],
                    'daily_price': vehicle_data['daily_price'],
                    'transmission': vehicle_data.get('transmission', ''),
                    'passenger_capacity': vehicle_data.get('passenger_capacity', 0),
                    'air_conditioning': vehicle_data.get('air_conditioning', ''),
                    'description': vehicle_data.get('description', ''),
                    'features': json.dumps(vehicle_data.get('features', [])),
                    'photos': json.dumps(vehicle_data.get('photos', [])),
                    'active': vehicle_data.get('active', True),
                    'created_at': datetime.now().isoformat()
                }
            )
            
            if response.status_code == 201:
                return response.json()[0]['id']
            else:
                raise Exception(f"Error adding vehicle: {response.text}")
        except Exception as e:
            print(f"Error adding vehicle to Supabase: {e}")
            raise e
    
    def get_vehicles(self):
        """Obtener todos los vehículos desde Supabase"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/vehicles?order=created_at.desc',
                headers=self.headers
            )
            if response.status_code == 200:
                vehicles = response.json()
                # Parsear JSON strings
                for vehicle in vehicles:
                    if vehicle.get('features'):
                        vehicle['features'] = json.loads(vehicle['features'])
                    if vehicle.get('photos'):
                        vehicle['photos'] = json.loads(vehicle['photos'])
                return vehicles
            else:
                return []
        except Exception as e:
            print(f"Error getting vehicles from Supabase: {e}")
            return []
    
    def get_vehicle_by_id(self, vehicle_id):
        """Obtener vehículo por ID desde Supabase"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/vehicles?id=eq.{vehicle_id}',
                headers=self.headers
            )
            if response.status_code == 200 and response.json():
                vehicle = response.json()[0]
                # Parsear JSON strings
                if vehicle.get('features'):
                    vehicle['features'] = json.loads(vehicle['features'])
                if vehicle.get('photos'):
                    vehicle['photos'] = json.loads(vehicle['photos'])
                return vehicle
            return None
        except Exception as e:
            print(f"Error getting vehicle by ID from Supabase: {e}")
            return None
    
    def update_vehicle(self, vehicle_id, vehicle_data):
        """Actualizar vehículo en Supabase"""
        try:
            response = requests.patch(
                f'{self.supabase_url}/rest/v1/vehicles?id=eq.{vehicle_id}',
                headers=self.headers,
                json={
                    'name': vehicle_data['name'],
                    'category': vehicle_data['category'],
                    'daily_price': vehicle_data['daily_price'],
                    'transmission': vehicle_data.get('transmission', ''),
                    'passenger_capacity': vehicle_data.get('passenger_capacity', 0),
                    'air_conditioning': vehicle_data.get('air_conditioning', ''),
                    'description': vehicle_data.get('description', ''),
                    'features': json.dumps(vehicle_data.get('features', [])),
                    'photos': json.dumps(vehicle_data.get('photos', [])),
                    'active': vehicle_data.get('active', True),
                    'updated_at': datetime.now().isoformat()
                }
            )
            
            return response.status_code == 204
        except Exception as e:
            print(f"Error updating vehicle in Supabase: {e}")
            return False
    
    def delete_vehicle(self, vehicle_id):
        """Eliminar vehículo de Supabase"""
        try:
            response = requests.delete(
                f'{self.supabase_url}/rest/v1/vehicles?id=eq.{vehicle_id}',
                headers=self.headers
            )
            
            return response.status_code == 204
        except Exception as e:
            print(f"Error deleting vehicle from Supabase: {e}")
            return False
    
    def add_phone_booking(self, booking_data):
        """Agregar reserva por teléfono a Supabase"""
        try:
            response = requests.post(
                f'{self.supabase_url}/rest/v1/phone_bookings',
                headers=self.headers,
                json={
                    'reservation_id': booking_data['reservation_id'],
                    'client_name': booking_data['client_name'],
                    'client_phone': booking_data['client_phone'],
                    'client_email': booking_data.get('client_email', ''),
                    'vehicle_type': booking_data['vehicle_type'],
                    'pickup_date': booking_data['pickup_date'],
                    'return_date': booking_data['return_date'],
                    'pickup_location': booking_data['pickup_location'],
                    'return_location': booking_data.get('return_location', ''),
                    'total_price': booking_data['total_price'],
                    'commission': booking_data['commission'],
                    'status': booking_data['status'],
                    'confirmation_number': booking_data.get('confirmation_number', ''),
                    'temp_email': booking_data.get('temp_email', ''),
                    'booking_type': booking_data.get('booking_type', 'phone'),
                    'admin_created': booking_data.get('admin_created', True),
                    'automation_result': json.dumps(booking_data.get('automation_result', {})),
                    'booking_date': datetime.now().isoformat()
                }
            )
            
            if response.status_code == 201:
                return response.json()[0]['id']
            else:
                raise Exception(f"Error adding phone booking: {response.text}")
        except Exception as e:
            print(f"Error adding phone booking to Supabase: {e}")
            raise e
    
    def get_phone_bookings(self):
        """Obtener todas las reservas por teléfono desde Supabase"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/phone_bookings?order=booking_date.desc',
                headers=self.headers
            )
            if response.status_code == 200:
                bookings = response.json()
                # Parsear JSON strings
                for booking in bookings:
                    if booking.get('automation_result'):
                        booking['automation_result'] = json.loads(booking['automation_result'])
                return bookings
            else:
                return []
        except Exception as e:
            print(f"Error getting phone bookings from Supabase: {e}")
            return []
    
    def get_phone_booking_by_id(self, booking_id):
        """Obtener reserva por teléfono por ID desde Supabase"""
        try:
            response = requests.get(
                f'{self.supabase_url}/rest/v1/phone_bookings?id=eq.{booking_id}',
                headers=self.headers
            )
            if response.status_code == 200 and response.json():
                booking = response.json()[0]
                # Parsear JSON strings
                if booking.get('automation_result'):
                    booking['automation_result'] = json.loads(booking['automation_result'])
                return booking
            return None
        except Exception as e:
            print(f"Error getting phone booking by ID from Supabase: {e}")
            return None

# Instancia global del servicio
supabase_service = SupabaseService()
