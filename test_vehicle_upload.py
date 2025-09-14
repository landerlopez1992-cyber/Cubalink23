#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de prueba para funcionalidades de subida de imagenes y categorias de vehiculos
"""

import requests
import json
import os
from datetime import datetime

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
        
        if response.status_code in [200, 302]:  # Login exitoso
            print("✅ Login exitoso")
            return session  # Retornamos la sesión con cookies
        else:
            print(f"❌ Error HTTP en login: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error de conexión en login: {e}")
        return None

def test_vehicle_categories(session):
    """Probar obtención de categorías de vehículos"""
    try:
        response = session.get(f"{BASE_URL}/admin/api/vehicles/categories")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                categories = data.get('categories', [])
                print(f"✅ Categorías obtenidas: {len(categories)} categorías")
                
                for category in categories:
                    print(f"  - {category['name']}: {category['description']}")
                    print(f"    Rango de precio: {category['daily_rate_range']}")
                    print(f"    Asientos: {category['seats']}")
                    print(f"    Ejemplos: {', '.join(category['examples'])}")
                    print()
                
                return categories
            else:
                print(f"❌ Error al obtener categorías: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP al obtener categorías: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error de conexión al obtener categorías: {e}")
        return None

def test_vehicle_category_detail(session, category_id):
    """Probar obtención de detalles de una categoría específica"""
    try:
        response = session.get(f"{BASE_URL}/admin/api/vehicles/categories/{category_id}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                category = data.get('category')
                print(f"✅ Detalles de categoría '{category['name']}' obtenidos")
                print(f"  Descripción: {category['description']}")
                print(f"  Características: {', '.join(category['features'])}")
                return category
            else:
                print(f"❌ Error al obtener detalles de categoría: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP al obtener detalles de categoría: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error de conexión al obtener detalles de categoría: {e}")
        return None

def test_create_vehicle_with_category(session, category_id):
    """Probar creación de vehículo con categoría"""
    try:
        
        vehicle_data = {
            'license_plate': 'ABC123',
            'brand': 'Toyota',
            'model': 'Corolla',
            'year': 2022,
            'color': 'Blanco',
            'vehicle_type': 'sedan',
            'transmission': 'automático',
            'fuel_type': 'gasolina',
            'seats': 5,
            'daily_rate': 45.00,
            'location': 'La Habana',
            'category_id': category_id,
            'description': 'Vehículo en excelente estado, ideal para viajes de negocios',
            'features': ['Aire acondicionado', 'GPS', 'Bluetooth', 'Cámara de reversa'],
            'insurance_cost': 15.00,
            'deposit_amount': 200.00
        }
        
        response = session.post(f"{BASE_URL}/admin/api/vehicles/create-with-category", 
                               json=vehicle_data)
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                vehicle_id = data.get('vehicle_id')
                print(f"✅ Vehículo creado exitosamente con ID: {vehicle_id}")
                return vehicle_id
            else:
                print(f"❌ Error al crear vehículo: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP al crear vehículo: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error de conexión al crear vehículo: {e}")
        return None

def test_upload_vehicle_images(session, vehicle_id):
    """Probar subida de imágenes de vehículo"""
    try:
        
        # Crear archivos de prueba (simulando imágenes)
        test_images = []
        for i in range(3):
            image_path = f"test_image_{i}.jpg"
            with open(image_path, 'w') as f:
                f.write(f"Test image content {i}")
            test_images.append(image_path)
        
        # Preparar datos para subida
        files = []
        for image_path in test_images:
            with open(image_path, 'rb') as f:
                files.append(('images', (image_path, f.read(), 'image/jpeg')))
        
        data = {'vehicle_id': str(vehicle_id)}
        
        response = session.post(f"{BASE_URL}/admin/api/vehicles/upload-images", 
                               files=files, data=data)
        
        # Limpiar archivos de prueba
        for image_path in test_images:
            if os.path.exists(image_path):
                os.remove(image_path)
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                images = data.get('images', [])
                print(f"✅ {len(images)} imágenes subidas exitosamente")
                for image_url in images:
                    print(f"  - {image_url}")
                return images
            else:
                print(f"❌ Error al subir imágenes: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP al subir imágenes: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error de conexión al subir imágenes: {e}")
        return None

def test_delete_vehicle_image(session, vehicle_id, image_url):
    """Probar eliminación de imagen de vehículo"""
    try:
        
        data = {'image_url': image_url}
        
        response = session.delete(f"{BASE_URL}/admin/api/vehicles/{vehicle_id}/images", 
                                 json=data)
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print(f"✅ Imagen eliminada exitosamente: {image_url}")
                return True
            else:
                print(f"❌ Error al eliminar imagen: {data.get('error')}")
                return False
        else:
            print(f"❌ Error HTTP al eliminar imagen: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error de conexión al eliminar imagen: {e}")
        return False

def test_get_vehicles(session):
    """Probar obtención de vehículos"""
    try:
        response = session.get(f"{BASE_URL}/admin/api/vehicles")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                vehicles = data.get('vehicles', [])
                print(f"✅ Vehículos obtenidos: {len(vehicles)} vehículos")
                
                for vehicle in vehicles:
                    print(f"  - {vehicle['brand']} {vehicle['model']} ({vehicle['license_plate']})")
                    print(f"    Categoría: {vehicle.get('category_id', 'N/A')}")
                    print(f"    Precio por día: ${vehicle['daily_rate']}")
                    print(f"    Estado: {vehicle['status']}")
                    print()
                
                return vehicles
            else:
                print(f"❌ Error al obtener vehículos: {data.get('error')}")
                return None
        else:
            print(f"❌ Error HTTP al obtener vehículos: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error de conexión al obtener vehículos: {e}")
        return None

def main():
    """Función principal de prueba"""
    print("🚗 PRUEBAS DE SISTEMA DE VEHÍCULOS CON IMÁGENES Y CATEGORÍAS")
    print("=" * 60)
    
    # 1. Login
    session = login_admin()
    if not session:
        print("❌ No se pudo obtener sesión. Abortando pruebas.")
        return
    
    print("\n" + "=" * 60)
    
    # 2. Probar categorías
    print("📋 PROBANDO CATEGORÍAS DE VEHÍCULOS")
    categories = test_vehicle_categories(session)
    if not categories:
        print("❌ No se pudieron obtener categorías. Abortando pruebas.")
        return
    
    print("\n" + "=" * 60)
    
    # 3. Probar detalles de categoría
    print("🔍 PROBANDO DETALLES DE CATEGORÍA")
    category_id = categories[0]['id']  # Usar la primera categoría
    category_detail = test_vehicle_category_detail(session, category_id)
    if not category_detail:
        print("❌ No se pudieron obtener detalles de categoría.")
    
    print("\n" + "=" * 60)
    
    # 4. Probar creación de vehículo con categoría
    print("🚙 PROBANDO CREACIÓN DE VEHÍCULO CON CATEGORÍA")
    vehicle_id = test_create_vehicle_with_category(session, category_id)
    if not vehicle_id:
        print("❌ No se pudo crear vehículo. Continuando con otras pruebas.")
    
    print("\n" + "=" * 60)
    
    # 5. Probar subida de imágenes (solo si se creó el vehículo)
    if vehicle_id:
        print("📸 PROBANDO SUBIDA DE IMÁGENES")
        uploaded_images = test_upload_vehicle_images(session, vehicle_id)
        
        if uploaded_images:
            print("\n" + "=" * 60)
            print("🗑️ PROBANDO ELIMINACIÓN DE IMÁGENES")
            # Probar eliminar la primera imagen
            test_delete_vehicle_image(session, vehicle_id, uploaded_images[0])
    
    print("\n" + "=" * 60)
    
    # 6. Probar obtención de vehículos
    print("📋 PROBANDO OBTENCIÓN DE VEHÍCULOS")
    vehicles = test_get_vehicles(session)
    
    print("\n" + "=" * 60)
    print("✅ PRUEBAS COMPLETADAS")
    print(f"📅 Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    main()
