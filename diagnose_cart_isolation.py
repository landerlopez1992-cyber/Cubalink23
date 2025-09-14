#!/usr/bin/env python3
"""
Script para diagnosticar problemas de aislamiento del carrito de compras
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

def check_cart_items_table():
    """Verificar la tabla cart_items"""
    print("🛒 Verificando tabla cart_items...")
    
    try:
        url = f"{SUPABASE_URL}/rest/v1/cart_items"
        params = {'select': 'id,user_id,product_name,created_at', 'limit': '10'}
        
        response = requests.get(url, headers=get_headers(), params=params)
        
        if response.status_code == 200:
            data = response.json()
            print(f"📊 Encontrados {len(data)} items en cart_items")
            
            # Agrupar por user_id
            users = {}
            for item in data:
                user_id = item.get('user_id', 'unknown')
                if user_id not in users:
                    users[user_id] = []
                users[user_id].append(item)
            
            print(f"👥 Items por usuario:")
            for user_id, items in users.items():
                print(f"   Usuario {user_id[:8]}...: {len(items)} items")
                for item in items:
                    print(f"      - {item.get('product_name', 'Sin nombre')}")
            
            return True
        else:
            print(f"❌ Error consultando cart_items: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def check_duplicate_items():
    """Verificar si hay items duplicados entre usuarios"""
    print("\n🔍 Verificando duplicados entre usuarios...")
    
    try:
        url = f"{SUPABASE_URL}/rest/v1/cart_items"
        params = {'select': 'user_id,product_id,product_name,quantity'}
        
        response = requests.get(url, headers=get_headers(), params=params)
        
        if response.status_code == 200:
            data = response.json()
            
            # Buscar productos que aparezcan en múltiples usuarios
            product_users = {}
            for item in data:
                product_id = item.get('product_id')
                user_id = item.get('user_id')
                product_name = item.get('product_name', 'Sin nombre')
                
                if product_id not in product_users:
                    product_users[product_id] = {'name': product_name, 'users': []}
                
                product_users[product_id]['users'].append(user_id)
            
            duplicated_products = {k: v for k, v in product_users.items() if len(v['users']) > 1}
            
            if duplicated_products:
                print(f"⚠️ Encontrados {len(duplicated_products)} productos en múltiples carritos:")
                for product_id, info in duplicated_products.items():
                    print(f"   Producto '{info['name']}' en {len(info['users'])} usuarios")
            else:
                print("✅ No se encontraron productos duplicados entre usuarios")
            
            return len(duplicated_products) == 0
        else:
            print(f"❌ Error: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def clean_orphaned_cart_items():
    """Limpiar items de carrito huérfanos"""
    print("\n🧹 Limpiando items de carrito huérfanos...")
    
    try:
        # Obtener todos los cart_items
        url = f"{SUPABASE_URL}/rest/v1/cart_items"
        params = {'select': 'id,user_id,product_name'}
        
        response = requests.get(url, headers=get_headers(), params=params)
        
        if response.status_code == 200:
            cart_items = response.json()
            print(f"📊 Total items en carrito: {len(cart_items)}")
            
            # Obtener usuarios válidos
            users_url = f"{SUPABASE_URL}/rest/v1/users"
            users_params = {'select': 'id'}
            
            users_response = requests.get(users_url, headers=get_headers(), params=users_params)
            
            if users_response.status_code == 200:
                valid_users = {user['id'] for user in users_response.json()}
                print(f"👥 Usuarios válidos: {len(valid_users)}")
                
                # Encontrar items huérfanos
                orphaned_items = []
                for item in cart_items:
                    if item['user_id'] not in valid_users:
                        orphaned_items.append(item['id'])
                
                if orphaned_items:
                    print(f"🗑️ Encontrados {len(orphaned_items)} items huérfanos")
                    
                    # Eliminar items huérfanos
                    for item_id in orphaned_items:
                        delete_url = f"{SUPABASE_URL}/rest/v1/cart_items"
                        delete_params = {'id': f'eq.{item_id}'}
                        
                        delete_response = requests.delete(delete_url, headers=get_headers(), params=delete_params)
                        
                        if delete_response.status_code in [200, 204]:
                            print(f"✅ Item {item_id} eliminado")
                        else:
                            print(f"❌ Error eliminando item {item_id}")
                else:
                    print("✅ No se encontraron items huérfanos")
                
                return True
            else:
                print(f"❌ Error obteniendo usuarios: {users_response.status_code}")
                return False
        else:
            print(f"❌ Error obteniendo cart_items: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    """Función principal"""
    print("🛒 DIAGNÓSTICO DE AISLAMIENTO DEL CARRITO DE COMPRAS")
    print("=" * 60)
    
    # 1. Verificar tabla cart_items
    if check_cart_items_table():
        print("✅ Tabla cart_items accesible")
    else:
        print("❌ Problema con tabla cart_items")
        return
    
    # 2. Verificar duplicados
    if check_duplicate_items():
        print("✅ No hay productos duplicados entre usuarios")
    else:
        print("⚠️ Hay productos compartidos entre usuarios")
    
    # 3. Limpiar items huérfanos
    if clean_orphaned_cart_items():
        print("✅ Limpieza completada")
    else:
        print("❌ Error en limpieza")
    
    print("\n📋 RECOMENDACIONES:")
    print("1. Verificar que CartService.initializeCart() se llame al hacer login")
    print("2. Verificar que CartService.clearCart() se llame al hacer logout")
    print("3. Verificar que loadFromSupabase() filtre correctamente por user_id")
    print("4. Asegurar que _saveToSupabase() elimine items del usuario anterior")

if __name__ == "__main__":
    main()
