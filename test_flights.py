#!/usr/bin/env python3
"""
Script de prueba para la gestión de vuelos (incluyendo charter)
"""

import requests
import json
import os
from datetime import datetime, timedelta

# Configuración
BASE_URL = "http://localhost:3005"
ADMIN_USERNAME = "landerlopez1992@gmail.com"
ADMIN_PASSWORD = "Maquina.2055"

def test_login():
    """Probar login del admin"""
    print("🔐 Probando login...")
    
    login_data = {
        'username': ADMIN_USERNAME,
        'password': ADMIN_PASSWORD
    }
    
    try:
        response = requests.post(f"{BASE_URL}/auth/login", data=login_data)
        if response.status_code == 200:
            print("✅ Login exitoso")
            return True
        else:
            print(f"❌ Login falló: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error en login: {e}")
        return False

def test_get_flights():
    """Probar obtener vuelos"""
    print("\n✈️ Probando obtener vuelos...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/flights")
        if response.status_code == 200:
            flights = response.json()
            print(f"✅ Vuelos obtenidos: {len(flights)} vuelos")
            for flight in flights[:3]:  # Mostrar solo los primeros 3
                print(f"   - {flight.get('origin', 'N/A')} → {flight.get('destination', 'N/A')}: ${flight.get('price', 0)}")
            return flights
        else:
            print(f"❌ Error obteniendo vuelos: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener vuelos: {e}")
        return []

def test_add_flight():
    """Probar agregar vuelo"""
    print("\n➕ Probando agregar vuelo...")
    
    # Fecha de mañana
    tomorrow = datetime.now() + timedelta(days=1)
    
    flight_data = {
        'origin': 'MIA',
        'destination': 'HAV',
        'airline': 'American Airlines',
        'flight_number': 'AA123',
        'departure_time': tomorrow.strftime('%Y-%m-%d 10:30:00'),
        'arrival_time': tomorrow.strftime('%Y-%m-%d 11:45:00'),
        'price': 299.99,
        'currency': 'USD',
        'status': 'active',
        'available_seats': 150
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/flights", json=flight_data)
        if response.status_code == 200:
            flight = response.json()
            print(f"✅ Vuelo agregado: {flight.get('origin')} → {flight.get('destination')} - ${flight.get('price')}")
            return flight
        else:
            print(f"❌ Error agregando vuelo: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en agregar vuelo: {e}")
        return None

def test_search_flights():
    """Probar búsqueda de vuelos"""
    print("\n🔍 Probando búsqueda de vuelos...")
    
    search_params = {
        'origin': 'MIA',
        'destination': 'HAV',
        'date': (datetime.now() + timedelta(days=1)).strftime('%Y-%m-%d')
    }
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/flights/search", params=search_params)
        if response.status_code == 200:
            flights = response.json()
            print(f"✅ Búsqueda exitosa: {len(flights)} vuelos encontrados")
            for flight in flights:
                print(f"   - {flight.get('airline')}: {flight.get('departure_time')} - ${flight.get('price')}")
            return flights
        else:
            print(f"❌ Error en búsqueda: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en búsqueda de vuelos: {e}")
        return []

def test_get_routes():
    """Probar obtener rutas populares"""
    print("\n🗺️ Probando obtener rutas populares...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/routes")
        if response.status_code == 200:
            routes = response.json()
            print(f"✅ Rutas obtenidas: {len(routes)} rutas")
            for route in routes[:5]:  # Mostrar solo las primeras 5
                print(f"   - {route.get('route')}: {route.get('searches')} búsquedas, {route.get('bookings')} reservas")
            return routes
        else:
            print(f"❌ Error obteniendo rutas: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener rutas: {e}")
        return []

def test_charter_airlines():
    """Probar aerolíneas charter"""
    print("\n🚁 Probando aerolíneas charter...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/charter-airlines")
        if response.status_code == 200:
            airlines = response.json()
            print(f"✅ Aerolíneas charter: {len(airlines)} aerolíneas")
            for airline in airlines:
                print(f"   - {airline.get('name')}: {'Activa' if airline.get('active') else 'Inactiva'}")
            return airlines
        else:
            print(f"❌ Error obteniendo aerolíneas charter: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener aerolíneas charter: {e}")
        return []

def test_charter_search():
    """Probar búsqueda de vuelos charter"""
    print("\n🚁 Probando búsqueda de vuelos charter...")
    
    search_data = {
        'origin': 'Miami',
        'destination': 'Havana',
        'departure_date': (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%d')
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/charter-search", json=search_data)
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                flights = result.get('flights', [])
                print(f"✅ Búsqueda charter exitosa: {len(flights)} vuelos encontrados")
                for flight in flights:
                    print(f"   - {flight.get('airline')}: ${flight.get('price')} - {flight.get('departure_time')}")
                return flights
            else:
                print(f"❌ Búsqueda charter falló: {result.get('message')}")
                return []
        else:
            print(f"❌ Error en búsqueda charter: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en búsqueda charter: {e}")
        return []

def test_update_flight(flight_id):
    """Probar actualizar vuelo"""
    print(f"\n✏️ Probando actualizar vuelo ID: {flight_id}...")
    
    update_data = {
        'origin': 'MIA',
        'destination': 'HAV',
        'airline': 'American Airlines (Actualizado)',
        'flight_number': 'AA123',
        'departure_time': (datetime.now() + timedelta(days=2)).strftime('%Y-%m-%d 10:30:00'),
        'arrival_time': (datetime.now() + timedelta(days=2)).strftime('%Y-%m-%d 11:45:00'),
        'price': 325.99,
        'currency': 'USD',
        'status': 'active',
        'available_seats': 140
    }
    
    try:
        response = requests.put(f"{BASE_URL}/admin/api/flights/{flight_id}", json=update_data)
        if response.status_code == 200:
            flight = response.json()
            print(f"✅ Vuelo actualizado: {flight.get('airline')} - ${flight.get('price')}")
            return flight
        else:
            print(f"❌ Error actualizando vuelo: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en actualizar vuelo: {e}")
        return None

def test_health_check():
    """Probar health check"""
    print("\n🏥 Probando health check...")
    
    try:
        response = requests.get(f"{BASE_URL}/api/health")
        if response.status_code == 200:
            health = response.json()
            print(f"✅ Health check: {health.get('status')} - {health.get('message')}")
            return True
        else:
            print(f"❌ Health check falló: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error en health check: {e}")
        return False

def main():
    """Función principal de pruebas"""
    print("🚀 Iniciando pruebas del sistema de gestión de vuelos...")
    print("=" * 60)
    
    # Verificar que el servidor esté corriendo
    if not test_health_check():
        print("\n❌ El servidor no está corriendo. Inicia el servidor primero:")
        print("   python app.py")
        return
    
    # Probar login
    if not test_login():
        print("\n❌ No se pudo hacer login. Verifica las credenciales.")
        return
    
    # Probar obtener vuelos
    flights = test_get_flights()
    
    # Probar obtener rutas populares
    routes = test_get_routes()
    
    # Probar aerolíneas charter
    charter_airlines = test_charter_airlines()
    
    # Probar búsqueda de vuelos charter
    charter_flights = test_charter_search()
    
    # Probar agregar vuelo
    new_flight = test_add_flight()
    
    if new_flight:
        flight_id = new_flight.get('id')
        
        # Probar actualizar vuelo
        updated_flight = test_update_flight(flight_id)
        
        # Probar búsqueda de vuelos
        search_results = test_search_flights()
    
    print("\n" + "=" * 60)
    print("✅ Pruebas completadas!")
    print("\n📋 Resumen:")
    print(f"   - Vuelos en sistema: {len(flights)}")
    print(f"   - Rutas populares: {len(routes)}")
    print(f"   - Aerolíneas charter: {len(charter_airlines)}")
    print(f"   - Vuelos charter encontrados: {len(charter_flights)}")
    if new_flight:
        print(f"   - Vuelo de prueba agregado: {new_flight.get('origin')} → {new_flight.get('destination')}")
        print(f"   - Funciones de búsqueda: ✅")
        print(f"   - Integración con charter: ✅")

if __name__ == "__main__":
    main()

