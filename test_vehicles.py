#!/usr/bin/env python3
"""
Script de prueba para el Sistema de Gestión de Vehículos - Renta Car
Prueba todas las funcionalidades del sistema de vehículos
"""

import requests
import json
import time
from datetime import datetime, timedelta

# Configuración
BASE_URL = "http://localhost:3005"
ADMIN_EMAIL = "admin@cubalink23.com"
ADMIN_PASSWORD = "admin123"

def login_admin():
    """Iniciar sesión como administrador"""
    print("🔐 Iniciando sesión como administrador...")
    
    login_data = {
        "email": ADMIN_EMAIL,
        "password": ADMIN_PASSWORD
    }
    
    response = requests.post(f"{BASE_URL}/admin/api/login", json=login_data)
    
    if response.status_code == 200:
        data = response.json()
        if data.get('success'):
            print("✅ Login exitoso")
            return data.get('token')
        else:
            print(f"❌ Error en login: {data.get('error')}")
            return None
    else:
        print(f"❌ Error HTTP: {response.status_code}")
        return None

def test_health_check():
    """Probar conexión con el servidor"""
    print("\n🏥 Verificando salud del servidor...")
    
    try:
        response = requests.get(f"{BASE_URL}/api/health")
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print("✅ Servidor funcionando correctamente")
                return True
            else:
                print(f"❌ Error en servidor: {data.get('error')}")
                return False
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_get_vehicles(token):
    """Probar obtención de vehículos"""
    print("\n🚗 Obteniendo lista de vehículos...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/vehicles", headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                vehicles = data.get('vehicles', [])
                print(f"✅ Se encontraron {len(vehicles)} vehículos")
                return vehicles
            else:
                print(f"❌ Error: {data.get('error')}")
                return []
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error: {e}")
        return []

def test_add_vehicle(token):
    """Probar agregar vehículo"""
    print("\n➕ Agregando nuevo vehículo...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    vehicle_data = {
        "license_plate": "ABC123",
        "brand": "Toyota",
        "model": "Corolla",
        "year": 2022,
        "color": "Blanco",
        "vehicle_type": "sedan",
        "transmission": "automatic",
        "fuel_type": "gasolina",
        "seats": 5,
        "daily_rate": 50.0,
        "hourly_rate": 8.0,
        "weekly_rate": 300.0,
        "monthly_rate": 1200.0,
        "deposit_amount": 200.0,
        "insurance_cost": 15.0,
        "mileage": 15000,
        "fuel_level": "full",
        "status": "available",
        "location": "La Habana",
        "features": json.dumps(["AC", "GPS", "Bluetooth"]),
        "images": json.dumps(["https://example.com/car1.jpg"]),
        "description": "Toyota Corolla 2022 en excelente estado"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/vehicles", 
                               json=vehicle_data, headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                vehicle_id = data.get('vehicle_id')
                print(f"✅ Vehículo agregado exitosamente (ID: {vehicle_id})")
                return vehicle_id
            else:
                print(f"❌ Error: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def test_get_vehicle(token, vehicle_id):
    """Probar obtener vehículo específico"""
    print(f"\n🔍 Obteniendo vehículo ID: {vehicle_id}...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/vehicles/{vehicle_id}", headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                vehicle = data.get('vehicle')
                print(f"✅ Vehículo encontrado: {vehicle['brand']} {vehicle['model']}")
                return vehicle
            else:
                print(f"❌ Error: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def test_update_vehicle(token, vehicle_id):
    """Probar actualizar vehículo"""
    print(f"\n✏️ Actualizando vehículo ID: {vehicle_id}...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    update_data = {
        "daily_rate": 55.0,
        "description": "Toyota Corolla 2022 actualizado - Excelente para viajes"
    }
    
    try:
        response = requests.put(f"{BASE_URL}/admin/api/vehicles/{vehicle_id}", 
                              json=update_data, headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print("✅ Vehículo actualizado exitosamente")
                return True
            else:
                print(f"❌ Error: {data.get('error')}")
                return False
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_update_vehicle_status(token, vehicle_id):
    """Probar actualizar estado del vehículo"""
    print(f"\n🔄 Actualizando estado del vehículo ID: {vehicle_id}...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    status_data = {"status": "maintenance"}
    
    try:
        response = requests.put(f"{BASE_URL}/admin/api/vehicles/{vehicle_id}/status", 
                              json=status_data, headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print("✅ Estado del vehículo actualizado exitosamente")
                return True
            else:
                print(f"❌ Error: {data.get('error')}")
                return False
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_create_rental(token, vehicle_id):
    """Probar crear renta"""
    print(f"\n📋 Creando renta para vehículo ID: {vehicle_id}...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Fechas para la renta
    start_date = datetime.now() + timedelta(days=1)
    end_date = start_date + timedelta(days=3)
    
    rental_data = {
        "user_id": 1,  # Usuario de prueba
        "vehicle_id": vehicle_id,
        "start_date": start_date.isoformat(),
        "end_date": end_date.isoformat(),
        "pickup_location": "Aeropuerto José Martí",
        "return_location": "Aeropuerto José Martí",
        "rental_type": "daily",
        "total_days": 3,
        "daily_rate": 55.0,
        "total_amount": 165.0,
        "deposit_amount": 200.0,
        "insurance_amount": 45.0,
        "taxes_amount": 14.0,
        "final_amount": 224.0,
        "payment_method": "card",
        "pickup_notes": "Recoger en terminal 3"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/rentals", 
                               json=rental_data, headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                rental_id = data.get('rental_id')
                rental_code = data.get('rental_code')
                print(f"✅ Renta creada exitosamente (ID: {rental_id}, Código: {rental_code})")
                return rental_id
            else:
                print(f"❌ Error: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def test_get_rentals(token):
    """Probar obtener rentas"""
    print("\n📋 Obteniendo lista de rentas...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/rentals", headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                rentals = data.get('rentals', [])
                print(f"✅ Se encontraron {len(rentals)} rentas")
                return rentals
            else:
                print(f"❌ Error: {data.get('error')}")
                return []
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error: {e}")
        return []

def test_get_rental(token, rental_id):
    """Probar obtener renta específica"""
    print(f"\n🔍 Obteniendo renta ID: {rental_id}...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/rentals/{rental_id}", headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                rental = data.get('rental')
                print(f"✅ Renta encontrada: Código {rental['rental_code']}")
                return rental
            else:
                print(f"❌ Error: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def test_update_rental_status(token, rental_id):
    """Probar actualizar estado de renta"""
    print(f"\n🔄 Actualizando estado de renta ID: {rental_id}...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    status_data = {
        "rental_status": "active",
        "payment_status": "paid"
    }
    
    try:
        response = requests.put(f"{BASE_URL}/admin/api/rentals/{rental_id}/status", 
                              json=status_data, headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print("✅ Estado de renta actualizado exitosamente")
                return True
            else:
                print(f"❌ Error: {data.get('error')}")
                return False
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_add_rental_driver(token, rental_id):
    """Probar agregar conductor a renta"""
    print(f"\n👤 Agregando conductor a renta ID: {rental_id}...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    driver_data = {
        "driver_name": "Juan Pérez",
        "driver_license": "123456789",
        "driver_phone": "+53 555 123 4567",
        "driver_email": "juan.perez@email.com",
        "driver_age": 28,
        "additional_cost": 10.0
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/rentals/{rental_id}/drivers", 
                               json=driver_data, headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                driver_id = data.get('driver_id')
                print(f"✅ Conductor agregado exitosamente (ID: {driver_id})")
                return driver_id
            else:
                print(f"❌ Error: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def test_add_rental_service(token, rental_id):
    """Probar agregar servicio a renta"""
    print(f"\n🔧 Agregando servicio a renta ID: {rental_id}...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    service_data = {
        "service_name": "GPS",
        "service_type": "gps",
        "service_cost": 15.0,
        "service_description": "Sistema de navegación GPS"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/rentals/{rental_id}/services", 
                               json=service_data, headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                service_id = data.get('service_id')
                print(f"✅ Servicio agregado exitosamente (ID: {service_id})")
                return service_id
            else:
                print(f"❌ Error: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def test_get_rental_statistics(token):
    """Probar obtener estadísticas de rentas"""
    print("\n📊 Obteniendo estadísticas de rentas...")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/rentals/statistics", headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                stats = data.get('statistics')
                print("✅ Estadísticas obtenidas:")
                print(f"   - Total de rentas: {stats.get('total_rentals', 0)}")
                print(f"   - Rentas activas: {stats.get('active_rentals', 0)}")
                print(f"   - Rentas completadas: {stats.get('completed_rentals', 0)}")
                print(f"   - Ingresos totales: ${stats.get('total_income', 0):.2f}")
                print(f"   - Vehículos disponibles: {stats.get('available_vehicles', 0)}")
                print(f"   - Vehículos rentados: {stats.get('rented_vehicles', 0)}")
                return stats
            else:
                print(f"❌ Error: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def test_public_apis():
    """Probar APIs públicas para Flutter"""
    print("\n📱 Probando APIs públicas para Flutter...")
    
    # Probar obtener vehículos disponibles
    print("🔍 Obteniendo vehículos disponibles...")
    try:
        response = requests.get(f"{BASE_URL}/admin/api/vehicles/available")
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                vehicles = data.get('vehicles', [])
                print(f"✅ {len(vehicles)} vehículos disponibles")
            else:
                print(f"❌ Error: {data.get('error')}")
        else:
            print(f"❌ Error HTTP: {response.status_code}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # Probar verificar disponibilidad
    print("🔍 Verificando disponibilidad de vehículo...")
    try:
        start_date = (datetime.now() + timedelta(days=1)).isoformat()
        end_date = (datetime.now() + timedelta(days=3)).isoformat()
        
        response = requests.get(f"{BASE_URL}/admin/api/vehicles/1/check-availability", 
                              params={"start_date": start_date, "end_date": end_date})
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                available = data.get('available', False)
                print(f"✅ Vehículo disponible: {available}")
            else:
                print(f"❌ Error: {data.get('error')}")
        else:
            print(f"❌ Error HTTP: {response.status_code}")
    except Exception as e:
        print(f"❌ Error: {e}")

def simulate_vehicle_rental_flow():
    """Simular flujo completo de renta de vehículos"""
    print("🚗 === SIMULACIÓN DE SISTEMA DE VEHÍCULOS ===")
    
    # Verificar salud del servidor
    if not test_health_check():
        print("❌ No se puede conectar al servidor")
        return
    
    # Login como administrador
    token = login_admin()
    if not token:
        print("❌ No se pudo iniciar sesión")
        return
    
    # Probar gestión de vehículos
    print("\n" + "="*50)
    print("📋 GESTIÓN DE VEHÍCULOS")
    print("="*50)
    
    # Obtener vehículos existentes
    vehicles = test_get_vehicles(token)
    
    # Agregar nuevo vehículo
    vehicle_id = test_add_vehicle(token)
    if vehicle_id:
        # Obtener vehículo específico
        test_get_vehicle(token, vehicle_id)
        
        # Actualizar vehículo
        test_update_vehicle(token, vehicle_id)
        
        # Actualizar estado del vehículo
        test_update_vehicle_status(token, vehicle_id)
    
    # Probar gestión de rentas
    print("\n" + "="*50)
    print("📋 GESTIÓN DE RENTAS")
    print("="*50)
    
    # Obtener rentas existentes
    rentals = test_get_rentals(token)
    
    # Crear nueva renta
    rental_id = test_create_rental(token, vehicle_id) if vehicle_id else None
    if rental_id:
        # Obtener renta específica
        test_get_rental(token, rental_id)
        
        # Actualizar estado de renta
        test_update_rental_status(token, rental_id)
        
        # Agregar conductor
        test_add_rental_driver(token, rental_id)
        
        # Agregar servicio
        test_add_rental_service(token, rental_id)
    
    # Obtener estadísticas
    print("\n" + "="*50)
    print("📊 ESTADÍSTICAS")
    print("="*50)
    test_get_rental_statistics(token)
    
    # Probar APIs públicas
    print("\n" + "="*50)
    print("📱 APIs PÚBLICAS PARA FLUTTER")
    print("="*50)
    test_public_apis()
    
    print("\n" + "="*50)
    print("✅ SIMULACIÓN COMPLETADA")
    print("="*50)

if __name__ == "__main__":
    simulate_vehicle_rental_flow()

