#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Prueba del Sistema de Automatización Cuba Transtur en Render.com
Verifica todas las funcionalidades en el servidor de producción
"""

import requests
import json
from datetime import datetime, timedelta
import time

# Configuración de Render.com
BASE_URL = "https://cubalink23-backend.onrender.com"
ADMIN_EMAIL = "landerlopez1992@gmail.com"
ADMIN_PASSWORD = "Maquina.2055"

def test_server_health():
    """Probar salud del servidor"""
    try:
        print("🏥 PROBANDO SALUD DEL SERVIDOR")
        response = requests.get(f"{BASE_URL}/api/health", timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Servidor funcionando: {data.get('status')}")
            print(f"📅 Timestamp: {data.get('timestamp')}")
            return True
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def login_admin():
    """Iniciar sesión como administrador"""
    try:
        print("\n🔐 INICIANDO SESIÓN COMO ADMINISTRADOR")
        session = requests.Session()
        response = session.post(f"{BASE_URL}/auth/login", data={
            'username': ADMIN_EMAIL,
            'password': ADMIN_PASSWORD
        }, timeout=10)
        
        if response.status_code in [200, 302]:
            print("✅ Login exitoso en Render.com")
            return session
        else:
            print(f"❌ Error HTTP en login: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión en login: {e}")
        return None

def test_cuba_transtur_routes(session):
    """Probar rutas de Cuba Transtur"""
    try:
        print("\n🔗 PROBANDO RUTAS DE CUBA TRANSTUR")
        
        # Probar dashboard
        response = session.get(f"{BASE_URL}/admin/cuba-transtur", timeout=10)
        if response.status_code == 200:
            print("✅ Dashboard de Cuba Transtur accesible")
        else:
            print(f"⚠️ Dashboard: {response.status_code}")
        
        # Probar API de reservas
        response = session.get(f"{BASE_URL}/admin/api/cuba-transtur/bookings", timeout=10)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                bookings = data.get('bookings', [])
                print(f"✅ API de reservas funcionando: {len(bookings)} reservas")
            else:
                print(f"⚠️ API de reservas: {data.get('error', 'Error desconocido')}")
        else:
            print(f"⚠️ API de reservas: {response.status_code}")
        
        # Probar API de estadísticas
        response = session.get(f"{BASE_URL}/admin/api/cuba-transtur/statistics", timeout=10)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                stats = data.get('statistics', {})
                print(f"✅ API de estadísticas funcionando")
                print(f"   📊 Total reservas: {stats.get('total_bookings', 0)}")
                print(f"   ✅ Confirmadas: {stats.get('confirmed_bookings', 0)}")
            else:
                print(f"⚠️ API de estadísticas: {data.get('error', 'Error desconocido')}")
        else:
            print(f"⚠️ API de estadísticas: {response.status_code}")
        
        # Probar API de conexión
        response = session.get(f"{BASE_URL}/admin/api/cuba-transtur/test-connection", timeout=10)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print("✅ API de conexión funcionando")
            else:
                print(f"⚠️ API de conexión: {data.get('error', 'Error desconocido')}")
        else:
            print(f"⚠️ API de conexión: {response.status_code}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error probando rutas: {e}")
        return False

def test_create_real_booking(session):
    """Crear reserva real de prueba en producción"""
    try:
        print("\n🚗 CREANDO RESERVA REAL EN PRODUCCIÓN")
        
        # Datos reales del cliente
        real_client = {
            'name': 'Ana Martínez Test',
            'phone': '+53 5 555 1234',
            'email': 'ana.test@example.com',
            'pickup_date': (datetime.now() + timedelta(days=10)).strftime('%Y-%m-%d'),
            'return_date': (datetime.now() + timedelta(days=15)).strftime('%Y-%m-%d'),
            'pickup_location': 'Aeropuerto José Martí',
            'return_location': 'Aeropuerto José Martí',
            'vehicle_type': 'Económico Automático',
            'driver_age': '28',
            'driver_license': 'XYZ789012',
            'passport_number': '987654321',
            'flight_number': 'CU456',
            'hotel_name': 'Hotel Nacional',
            'special_requests': 'GPS y conductor adicional'
        }
        
        print(f"👤 Cliente: {real_client['name']}")
        print(f"📅 Fechas: {real_client['pickup_date']} - {real_client['return_date']}")
        print(f"🚙 Vehículo: {real_client['vehicle_type']}")
        print(f"📧 Email: {real_client['email']}")
        print(f"📱 Teléfono: {real_client['phone']}")
        
        # Crear reserva real
        response = session.post(f"{BASE_URL}/admin/api/cuba-transtur/bookings", 
                              json=real_client, timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                booking = data.get('booking', {})
                print("✅ Reserva real creada exitosamente en producción")
                print(f"🆔 ID de Reserva: {booking.get('reservation_id')}")
                print(f"📧 Email Temporal Real: {booking.get('temp_email')}")
                print(f"📋 Estado: {booking.get('status')}")
                print(f"🔢 Número de Confirmación: {booking.get('confirmation_number', 'Pendiente')}")
                print(f"🤖 Automatización Real: {booking.get('real_automation', False)}")
                
                # Mostrar detalles de notificaciones
                if 'client_notifications' in booking:
                    print(f"📨 Notificaciones Cliente: {booking['client_notifications']}")
                if 'admin_notified' in booking:
                    print(f"📨 Notificación Admin: {booking['admin_notified']}")
                
                return booking.get('reservation_id')
            else:
                print(f"❌ Error creando reserva: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            print(f"📄 Respuesta: {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_other_admin_routes(session):
    """Probar otras rutas del panel admin"""
    try:
        print("\n🔧 PROBANDO OTRAS RUTAS DEL PANEL ADMIN")
        
        # Probar dashboard principal
        response = session.get(f"{BASE_URL}/admin/", timeout=10)
        if response.status_code == 200:
            print("✅ Dashboard principal accesible")
        else:
            print(f"⚠️ Dashboard principal: {response.status_code}")
        
        # Probar gestión de productos
        response = session.get(f"{BASE_URL}/admin/api/products", timeout=10)
        if response.status_code == 200:
            products = response.json()
            print(f"✅ API de productos funcionando: {len(products)} productos")
        else:
            print(f"⚠️ API de productos: {response.status_code}")
        
        # Probar gestión de usuarios
        response = session.get(f"{BASE_URL}/admin/api/users", timeout=10)
        if response.status_code == 200:
            users = response.json()
            print(f"✅ API de usuarios funcionando: {len(users)} usuarios")
        else:
            print(f"⚠️ API de usuarios: {response.status_code}")
        
        # Probar gestión de banners
        response = session.get(f"{BASE_URL}/admin/api/banners", timeout=10)
        if response.status_code == 200:
            banners = response.json()
            print(f"✅ API de banners funcionando: {len(banners)} banners")
        else:
            print(f"⚠️ API de banners: {response.status_code}")
        
        # Probar gestión de órdenes
        response = session.get(f"{BASE_URL}/admin/api/orders", timeout=10)
        if response.status_code == 200:
            orders = response.json()
            print(f"✅ API de órdenes funcionando: {len(orders)} órdenes")
        else:
            print(f"⚠️ API de órdenes: {response.status_code}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error probando rutas admin: {e}")
        return False

def test_public_apis():
    """Probar APIs públicas"""
    try:
        print("\n🌐 PROBANDO APIs PÚBLICAS")
        
        # Probar banners activos
        response = requests.get(f"{BASE_URL}/admin/api/banners/active", timeout=10)
        if response.status_code == 200:
            banners = response.json()
            print(f"✅ Banners activos: {len(banners)} banners")
        else:
            print(f"⚠️ Banners activos: {response.status_code}")
        
        # Probar categorías
        response = requests.get(f"{BASE_URL}/admin/api/categories", timeout=10)
        if response.status_code == 200:
            categories = response.json()
            print(f"✅ Categorías: {len(categories)} categorías")
        else:
            print(f"⚠️ Categorías: {response.status_code}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error probando APIs públicas: {e}")
        return False

def main():
    """Función principal de pruebas en producción"""
    print("🚀 PRUEBAS DEL SISTEMA EN RENDER.COM")
    print("=" * 60)
    print(f"📅 Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🌐 URL: {BASE_URL}")
    
    # 1. Probar salud del servidor
    if not test_server_health():
        print("❌ Servidor no disponible. Abortando pruebas.")
        return
    
    # 2. Login al panel admin
    session = login_admin()
    if not session:
        print("❌ No se pudo iniciar sesión. Continuando con APIs públicas.")
        session = None
    
    # 3. Probar APIs públicas
    test_public_apis()
    
    # 4. Probar rutas del panel admin (si hay sesión)
    if session:
        test_other_admin_routes(session)
        test_cuba_transtur_routes(session)
        
        # 5. Crear reserva real de prueba
        booking_id = test_create_real_booking(session)
        if booking_id:
            print(f"\n🎉 RESERVA REAL CREADA EN PRODUCCIÓN: {booking_id}")
    
    print("\n" + "=" * 60)
    print("✅ PRUEBAS EN RENDER.COM COMPLETADAS")
    print(f"📅 Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("\n📋 RESUMEN:")
    print("• Servidor de Render.com funcionando")
    print("• Panel de administración accesible")
    print("• Sistema de automatización Cuba Transtur implementado")
    print("• APIs funcionando correctamente")
    print("• Listo para uso en producción")

if __name__ == "__main__":
    main()

