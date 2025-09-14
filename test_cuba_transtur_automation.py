#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Prueba para Automatización de Cuba Transtur
Demuestra el funcionamiento del sistema de automatización
"""

import requests
import json
from datetime import datetime, timedelta

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

def test_cuba_transtur_connection(session):
    """Probar conexión con Cuba Transtur"""
    try:
        print("\n" + "=" * 60)
        print("🔗 PROBANDO CONEXIÓN CON CUBA TRANSTUR")
        
        response = session.get(f"{BASE_URL}/admin/api/cuba-transtur/test-connection")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print("✅ Conexión exitosa con Cuba Transtur")
                return True
            else:
                print(f"❌ Error en conexión: {data.get('error')}")
                return False
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def create_test_booking(session):
    """Crear reserva de prueba automatizada"""
    try:
        print("\n" + "=" * 60)
        print("🚗 CREANDO RESERVA AUTOMATIZADA DE PRUEBA")
        
        # Datos de prueba del cliente
        test_client = {
            'name': 'María García López',
            'phone': '+53 5 987 6543',
            'pickup_date': (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%d'),
            'return_date': (datetime.now() + timedelta(days=12)).strftime('%Y-%m-%d'),
            'pickup_location': 'Aeropuerto José Martí',
            'return_location': 'Aeropuerto José Martí',
            'vehicle_type': 'Económico Automático',
            'driver_age': '28',
            'driver_license': 'XYZ789012',
            'passport_number': '987654321',
            'flight_number': 'CU123',
            'hotel_name': 'Hotel Meliá Habana',
            'special_requests': 'Conductor adicional y GPS'
        }
        
        print(f"👤 Cliente: {test_client['name']}")
        print(f"📅 Fechas: {test_client['pickup_date']} - {test_client['return_date']}")
        print(f"🚙 Vehículo: {test_client['vehicle_type']}")
        
        response = session.post(f"{BASE_URL}/admin/api/cuba-transtur/bookings", 
                              json=test_client)
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                booking = data.get('booking', {})
                print("✅ Reserva automatizada creada exitosamente")
                print(f"🆔 ID de Reserva: {booking.get('reservation_id')}")
                print(f"📧 Email Temporal: {booking.get('temp_email')}")
                print(f"📋 Estado: {booking.get('status')}")
                print(f"🔢 Número de Confirmación: {booking.get('confirmation_number', 'Pendiente')}")
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

def check_booking_status(session, reservation_id):
    """Verificar estado de una reserva"""
    try:
        print("\n" + "=" * 60)
        print(f"📋 VERIFICANDO ESTADO DE RESERVA: {reservation_id}")
        
        response = session.get(f"{BASE_URL}/admin/api/cuba-transtur/bookings/{reservation_id}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                booking = data.get('booking', {})
                print("✅ Estado de reserva obtenido")
                print(f"📊 Estado: {booking.get('status')}")
                print(f"📧 Email: {booking.get('temp_email')}")
                print(f"🔢 Confirmación: {booking.get('confirmation_number', 'Pendiente')}")
                print(f"📅 Fecha: {booking.get('booking_date')}")
                return True
            else:
                print(f"❌ Error obteniendo estado: {data.get('error')}")
                return False
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def get_booking_history(session):
    """Obtener historial de reservas"""
    try:
        print("\n" + "=" * 60)
        print("📚 OBTENIENDO HISTORIAL DE RESERVAS")
        
        response = session.get(f"{BASE_URL}/admin/api/cuba-transtur/bookings")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                bookings = data.get('bookings', [])
                print(f"✅ Historial obtenido: {len(bookings)} reservas")
                
                for i, booking in enumerate(bookings, 1):
                    print(f"\n📋 Reserva {i}:")
                    print(f"   🆔 ID: {booking.get('reservation_id')}")
                    print(f"   👤 Cliente: {booking.get('client_data', {}).get('name', 'N/A')}")
                    print(f"   📊 Estado: {booking.get('status')}")
                    print(f"   📅 Fecha: {booking.get('booking_date', 'N/A')}")
                
                return True
            else:
                print(f"❌ Error obteniendo historial: {data.get('error')}")
                return False
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def get_statistics(session):
    """Obtener estadísticas de reservas"""
    try:
        print("\n" + "=" * 60)
        print("📊 OBTENIENDO ESTADÍSTICAS")
        
        response = session.get(f"{BASE_URL}/admin/api/cuba-transtur/statistics")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                stats = data.get('statistics', {})
                print("✅ Estadísticas obtenidas")
                print(f"📈 Total de reservas: {stats.get('total_bookings', 0)}")
                print(f"✅ Confirmadas: {stats.get('confirmed_bookings', 0)}")
                print(f"⏳ Pendientes: {stats.get('pending_bookings', 0)}")
                print(f"❌ Errores: {stats.get('error_bookings', 0)}")
                print(f"📊 Tasa de éxito: {stats.get('success_rate', 0):.1f}%")
                print(f"💰 Ingresos totales: ${stats.get('total_income', 0):.2f}")
                print(f"💵 Valor promedio: ${stats.get('average_booking_value', 0):.2f}")
                return True
            else:
                print(f"❌ Error obteniendo estadísticas: {data.get('error')}")
                return False
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def main():
    """Función principal de pruebas"""
    print("🤖 PRUEBAS DE AUTOMATIZACIÓN CUBA TRANSTUR")
    print("=" * 60)
    print(f"📅 Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # 1. Login
    session = login_admin()
    if not session:
        print("❌ No se pudo obtener sesión. Abortando pruebas.")
        return
    
    # 2. Probar conexión
    if not test_cuba_transtur_connection(session):
        print("❌ No se pudo conectar con Cuba Transtur. Continuando con otras pruebas.")
    
    # 3. Crear reserva de prueba
    reservation_id = create_test_booking(session)
    
    # 4. Verificar estado de reserva
    if reservation_id:
        check_booking_status(session, reservation_id)
    
    # 5. Obtener historial
    get_booking_history(session)
    
    # 6. Obtener estadísticas
    get_statistics(session)
    
    print("\n" + "=" * 60)
    print("✅ PRUEBAS COMPLETADAS")
    print(f"📅 Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    main()

