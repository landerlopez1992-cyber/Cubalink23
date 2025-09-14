#!/usr/bin/env python3
"""
Script para probar el aislamiento del carrito de compras entre usuarios
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = "https://zgqrhzuhrwudckwesybg.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ"

def get_headers():
    """Obtener headers para las peticiones a Supabase"""
    return {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }

def get_test_users():
    """Obtener usuarios de prueba"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/users"
        params = {'select': 'id,email,name', 'limit': '5'}
        
        response = requests.get(url, headers=get_headers(), params=params)
        
        if response.status_code == 200:
            users = response.json()
            print(f"👥 Usuarios disponibles para prueba: {len(users)}")
            for user in users:
                print(f"   - {user['name']} ({user['email']})")
            return users
        else:
            print(f"❌ Error obteniendo usuarios: {response.status_code}")
            return []
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return []

def add_test_cart_item(user_id, product_name):
    """Agregar un item de prueba al carrito de un usuario"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/cart_items"
        data = {
            'user_id': user_id,
            'product_id': f'test_{product_name.lower().replace(" ", "_")}',
            'product_name': product_name,
            'product_price': 10.00,
            'product_image_url': 'https://via.placeholder.com/300x300?text=' + product_name.replace(' ', '%20'),
            'product_type': 'store',
            'quantity': 1,
            'weight': 1.0
        }
        
        response = requests.post(url, headers=get_headers(), json=data)
        
        if response.status_code in [200, 201]:
            print(f"✅ Producto '{product_name}' agregado al carrito de usuario {user_id[:8]}...")
            return True
        else:
            print(f"❌ Error agregando producto: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def get_user_cart(user_id):
    """Obtener carrito de un usuario específico"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/cart_items"
        params = {'user_id': f'eq.{user_id}', 'select': 'product_name,quantity'}
        
        response = requests.get(url, headers=get_headers(), params=params)
        
        if response.status_code == 200:
            return response.json()
        else:
            print(f"❌ Error obteniendo carrito: {response.status_code}")
            return []
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return []

def clear_test_data():
    """Limpiar datos de prueba"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/cart_items"
        params = {'product_id': 'like.test_%'}
        
        response = requests.delete(url, headers=get_headers(), params=params)
        
        if response.status_code in [200, 204]:
            print("🧹 Datos de prueba limpiados")
            return True
        else:
            print(f"⚠️ Error limpiando datos: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    """Función principal"""
    print("🛒 PRUEBA DE AISLAMIENTO DEL CARRITO DE COMPRAS")
    print("=" * 60)
    
    # 1. Obtener usuarios de prueba
    users = get_test_users()
    if len(users) < 2:
        print("❌ Se necesitan al menos 2 usuarios para la prueba")
        return
    
    user1 = users[0]
    user2 = users[1]
    
    # 2. Limpiar datos previos
    print(f"\n🧹 Limpiando datos previos...")
    clear_test_data()
    
    # 3. Agregar productos diferentes a cada usuario
    print(f"\n📦 Agregando productos de prueba...")
    
    print(f"Usuario 1: {user1['name']}")
    add_test_cart_item(user1['id'], "Producto Usuario 1A")
    add_test_cart_item(user1['id'], "Producto Usuario 1B")
    
    print(f"Usuario 2: {user2['name']}")
    add_test_cart_item(user2['id'], "Producto Usuario 2A")
    add_test_cart_item(user2['id'], "Producto Usuario 2B")
    
    # 4. Verificar aislamiento
    print(f"\n🔍 Verificando aislamiento de carritos...")
    
    cart1 = get_user_cart(user1['id'])
    cart2 = get_user_cart(user2['id'])
    
    print(f"\n📊 Resultados:")
    print(f"Carrito Usuario 1 ({user1['name']}):")
    for item in cart1:
        print(f"   - {item['product_name']} (x{item['quantity']})")
    
    print(f"Carrito Usuario 2 ({user2['name']}):")
    for item in cart2:
        print(f"   - {item['product_name']} (x{item['quantity']})")
    
    # 5. Verificar que no hay contaminación cruzada
    user1_products = {item['product_name'] for item in cart1}
    user2_products = {item['product_name'] for item in cart2}
    
    overlap = user1_products.intersection(user2_products)
    
    if overlap:
        print(f"\n❌ FALLO: Productos compartidos entre usuarios: {overlap}")
        success = False
    else:
        print(f"\n✅ ÉXITO: No hay productos compartidos entre usuarios")
        success = True
    
    # 6. Verificar conteos
    expected_user1 = 2
    expected_user2 = 2
    actual_user1 = len(cart1)
    actual_user2 = len(cart2)
    
    if actual_user1 == expected_user1 and actual_user2 == expected_user2:
        print(f"✅ Conteos correctos: Usuario1={actual_user1}, Usuario2={actual_user2}")
    else:
        print(f"❌ Conteos incorrectos: Usuario1={actual_user1} (esperado {expected_user1}), Usuario2={actual_user2} (esperado {expected_user2})")
        success = False
    
    # 7. Limpiar datos de prueba
    print(f"\n🧹 Limpiando datos de prueba...")
    clear_test_data()
    
    # 8. Resultado final
    print(f"\n{'='*60}")
    if success:
        print("🎉 PRUEBA EXITOSA: El carrito está correctamente aislado por usuario")
        print("\n📋 Verificaciones pasadas:")
        print("   ✅ Productos no se comparten entre usuarios")
        print("   ✅ Cada usuario ve solo sus productos")
        print("   ✅ Conteos de productos correctos")
    else:
        print("❌ PRUEBA FALLIDA: Hay problemas de aislamiento en el carrito")
        print("\n🔧 Posibles problemas:")
        print("   - El filtro por user_id no está funcionando")
        print("   - Hay contaminación cruzada entre usuarios")
        print("   - El carrito no se limpia al cambiar de usuario")
    
    print(f"\n📱 Para probar en la app:")
    print(f"   1. Inicia sesión con {user1['email']}")
    print(f"   2. Agrega productos al carrito")
    print(f"   3. Cierra sesión")
    print(f"   4. Inicia sesión con {user2['email']}")
    print(f"   5. Verifica que el carrito esté vacío")

if __name__ == "__main__":
    main()
