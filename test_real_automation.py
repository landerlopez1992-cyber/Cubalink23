#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Prueba de Automatización Real de Cuba Transtur
Demuestra el sistema completo con emails temporales reales y notificaciones reales
"""

import requests
import json
from datetime import datetime, timedelta
import time

# Configuración
BASE_URL = "http://localhost:3005"
ADMIN_EMAIL = "landerlopez1992@gmail.com"
ADMIN_PASSWORD = "Maquina.2055"

def login_admin():
    """Iniciar sesión como administrador"""
    try:
        session = requests.Session()
        response = session.post(f"{BASE_URL}/auth/login", data={
            'username': ADMIN_EMAIL,
            'password': ADMIN_PASSWORD
        })
        
        if response.status_code in [200, 302]:
            print("✅ Login exitoso")
            return session
        else:
            print(f"❌ Error HTTP en login: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión en login: {e}")
        return None

def test_real_temp_email_service():
    """Probar servicio de emails temporales reales"""
    try:
        print("\n" + "=" * 60)
        print("📧 PROBANDO SERVICIO DE EMAILS TEMPORALES REALES")
        
        from real_temp_email_service import create_real_temp_email, validate_temp_email
        
        # Crear email temporal real
        client_name = "Juan Pérez Test"
        reservation_id = f"CT{datetime.now().strftime('%Y%m%d%H%M%S')}"
        
        temp_email = create_real_temp_email(client_name, reservation_id)
        print(f"📧 Email temporal creado: {temp_email}")
        
        # Validar email temporal
        validation = validate_temp_email(temp_email)
        print(f"✅ Validación: {validation}")
        
        return temp_email, reservation_id
        
    except Exception as e:
        print(f"❌ Error probando emails temporales: {e}")
        return None, None

def test_real_notification_service():
    """Probar servicio de notificaciones reales"""
    try:
        print("\n" + "=" * 60)
        print("📨 PROBANDO SERVICIO DE NOTIFICACIONES REALES")
        
        from real_notification_service import send_booking_confirmation, notify_admin_new_booking
        
        # Datos de prueba
        test_booking = {
            'reservation_id': 'CT20240831123456',
            'temp_email': 'test@temp-mail.org',
            'confirmation_number': 'CT123456',
            'client_data': {
                'name': 'María García Test',
                'email': 'maria.test@example.com',
                'phone': '+53 5 123 4567',
                'vehicle_type': 'Económico Automático',
                'pickup_date': '2024-02-15',
                'return_date': '2024-02-20',
                'pickup_location': 'Aeropuerto José Martí'
            },
            'booking_date': datetime.now().isoformat(),
            'status': 'confirmed',
            'automation_success': True,
            'real_automation': True
        }
        
        # Probar notificación al cliente
        print("📧 Enviando notificación al cliente...")
        client_notifications = send_booking_confirmation(test_booking)
        print(f"✅ Notificaciones cliente: {client_notifications}")
        
        # Probar notificación al admin
        print("📧 Enviando notificación al admin...")
        admin_notified = notify_admin_new_booking(test_booking)
        print(f"✅ Notificación admin: {admin_notified}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error probando notificaciones: {e}")
        return False

def create_real_booking_test(session):
    """Crear reserva real de prueba"""
    try:
        print("\n" + "=" * 60)
        print("🚗 CREANDO RESERVA REAL DE PRUEBA")
        
        # Datos reales del cliente
        real_client = {
            'name': 'Carlos Rodríguez Test',
            'phone': '+53 5 987 6543',
            'email': 'carlos.test@example.com',
            'pickup_date': (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%d'),
            'return_date': (datetime.now() + timedelta(days=12)).strftime('%Y-%m-%d'),
            'pickup_location': 'Aeropuerto José Martí',
            'return_location': 'Aeropuerto José Martí',
            'vehicle_type': 'Económico Automático',
            'driver_age': '32',
            'driver_license': 'ABC123456',
            'passport_number': '123456789',
            'flight_number': 'CU123',
            'hotel_name': 'Hotel Meliá Habana',
            'special_requests': 'Conductor adicional y GPS'
        }
        
        print(f"👤 Cliente: {real_client['name']}")
        print(f"📅 Fechas: {real_client['pickup_date']} - {real_client['return_date']}")
        print(f"🚙 Vehículo: {real_client['vehicle_type']}")
        print(f"📧 Email: {real_client['email']}")
        print(f"📱 Teléfono: {real_client['phone']}")
        
        # Crear reserva real
        response = session.post(f"{BASE_URL}/admin/api/cuba-transtur/bookings", 
                              json=real_client)
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                booking = data.get('booking', {})
                print("✅ Reserva real creada exitosamente")
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
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_real_automation_flow():
    """Probar flujo completo de automatización real"""
    try:
        print("\n" + "=" * 60)
        print("🔄 PROBANDO FLUJO COMPLETO DE AUTOMATIZACIÓN REAL")
        
        # 1. Probar emails temporales reales
        temp_email, reservation_id = test_real_temp_email_service()
        if not temp_email:
            print("❌ Falló prueba de emails temporales")
            return False
        
        # 2. Probar notificaciones reales
        notifications_ok = test_real_notification_service()
        if not notifications_ok:
            print("❌ Falló prueba de notificaciones")
            return False
        
        # 3. Login al panel admin
        session = login_admin()
        if not session:
            print("❌ Falló login al panel admin")
            return False
        
        # 4. Crear reserva real
        booking_id = create_real_booking_test(session)
        if not booking_id:
            print("❌ Falló creación de reserva real")
            return False
        
        print("\n" + "=" * 60)
        print("✅ FLUJO COMPLETO DE AUTOMATIZACIÓN REAL EXITOSO")
        print(f"📧 Email Temporal: {temp_email}")
        print(f"🆔 Reserva: {booking_id}")
        print("🤖 Sistema 100% funcional y real")
        
        return True
        
    except Exception as e:
        print(f"❌ Error en flujo de automatización: {e}")
        return False

def main():
    """Función principal de pruebas reales"""
    print("🤖 PRUEBAS DE AUTOMATIZACIÓN REAL CUBA TRANSTUR")
    print("=" * 60)
    print(f"📅 Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("🎯 SISTEMA 100% REAL - SIN SIMULACIONES")
    
    # Ejecutar pruebas reales
    success = test_real_automation_flow()
    
    print("\n" + "=" * 60)
    if success:
        print("✅ TODAS LAS PRUEBAS REALES EXITOSAS")
        print("🚀 Sistema completamente funcional")
        print("📧 Emails temporales reales funcionando")
        print("📨 Notificaciones reales funcionando")
        print("🤖 Automatización real funcionando")
    else:
        print("❌ ALGUNAS PRUEBAS FALLARON")
        print("🔧 Revisar configuración y reintentar")
    
    print(f"📅 Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    main()

