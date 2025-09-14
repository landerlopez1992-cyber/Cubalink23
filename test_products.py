#!/usr/bin/env python3
"""
Script de prueba para la gestión de productos
"""

import requests
import json
import os

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

def test_get_products():
    """Probar obtener productos"""
    print("\n📦 Probando obtener productos...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/products")
        if response.status_code == 200:
            products = response.json()
            print(f"✅ Productos obtenidos: {len(products)} productos")
            for product in products[:3]:  # Mostrar solo los primeros 3
                print(f"   - {product.get('name', 'Sin nombre')}: ${product.get('price', 0)}")
            return products
        else:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener productos: {e}")
        return []

def test_add_product():
    """Probar agregar producto"""
    print("\n➕ Probando agregar producto...")
    
    product_data = {
        'name': 'Vuelo Miami-Habana',
        'description': 'Vuelo directo desde Miami a La Habana',
        'price': 299.99,
        'category': '1',  # Vuelos
        'stock': 10,
        'active': True
    }
    
    try:
        response = requests.post(f"{BASE_URL}/admin/api/products", data=product_data)
        if response.status_code == 200:
            product = response.json()
            print(f"✅ Producto agregado: {product.get('name')} - ID: {product.get('id')}")
            return product
        else:
            print(f"❌ Error agregando producto: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en agregar producto: {e}")
        return None

def test_update_product(product_id):
    """Probar actualizar producto"""
    print(f"\n✏️ Probando actualizar producto ID: {product_id}...")
    
    update_data = {
        'name': 'Vuelo Miami-Habana (Actualizado)',
        'description': 'Vuelo directo desde Miami a La Habana - Precio especial',
        'price': 279.99,
        'category': '1',
        'stock': 15,
        'active': True
    }
    
    try:
        response = requests.put(f"{BASE_URL}/admin/api/products/{product_id}", 
                              json=update_data)
        if response.status_code == 200:
            product = response.json()
            print(f"✅ Producto actualizado: {product.get('name')} - Precio: ${product.get('price')}")
            return product
        else:
            print(f"❌ Error actualizando producto: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error en actualizar producto: {e}")
        return None

def test_get_categories():
    """Probar obtener categorías"""
    print("\n📂 Probando obtener categorías...")
    
    try:
        response = requests.get(f"{BASE_URL}/admin/api/categories")
        if response.status_code == 200:
            categories = response.json()
            print(f"✅ Categorías obtenidas: {len(categories)} categorías")
            for category in categories:
                print(f"   - {category.get('name')}: {category.get('description')}")
            return categories
        else:
            print(f"❌ Error obteniendo categorías: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error en obtener categorías: {e}")
        return []

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
    print("🚀 Iniciando pruebas del sistema de gestión de productos...")
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
    
    # Probar obtener categorías
    categories = test_get_categories()
    
    # Probar obtener productos
    products = test_get_products()
    
    # Probar agregar producto
    new_product = test_add_product()
    
    if new_product:
        # Probar actualizar producto
        updated_product = test_update_product(new_product.get('id'))
    
    print("\n" + "=" * 60)
    print("✅ Pruebas completadas!")
    print("\n📋 Resumen:")
    print(f"   - Categorías disponibles: {len(categories)}")
    print(f"   - Productos en sistema: {len(products)}")
    if new_product:
        print(f"   - Producto de prueba agregado: {new_product.get('name')}")

if __name__ == "__main__":
    main()
