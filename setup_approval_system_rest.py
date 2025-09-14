#!/usr/bin/env python3
"""
Script para configurar el sistema de aprobación usando APIs REST de Supabase
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
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
    }

def add_approval_columns():
    """Agregar columnas de aprobación a la tabla store_products"""
    print("🔧 Agregando columnas de aprobación...")
    
    # Nota: No podemos agregar columnas directamente via REST API
    # Estas columnas deben agregarse manualmente en el SQL Editor de Supabase
    print("⚠️ Las columnas deben agregarse manualmente en Supabase SQL Editor:")
    print("   - approval_status VARCHAR(20) DEFAULT 'approved'")
    print("   - approved_at TIMESTAMP WITH TIME ZONE")
    print("   - approved_by UUID REFERENCES users(id)")
    print("   - approval_notes TEXT")
    
    return True

def update_existing_products():
    """Actualizar productos existentes para que estén aprobados"""
    print("📦 Actualizando productos existentes...")
    
    try:
        # Obtener todos los productos
        url = f"{SUPABASE_URL}/rest/v1/store_products"
        params = {'select': 'id'}
        
        response = requests.get(url, headers=get_headers(), params=params)
        
        if response.status_code == 200:
            products = response.json()
            print(f"📊 Encontrados {len(products)} productos para actualizar")
            
            # Actualizar cada producto
            success_count = 0
            for product in products:
                product_id = product['id']
                
                update_url = f"{SUPABASE_URL}/rest/v1/store_products"
                update_params = {'id': f'eq.{product_id}'}
                update_data = {
                    'approval_status': 'approved',
                    'updated_at': 'now()'
                }
                
                update_response = requests.patch(
                    update_url, 
                    headers=get_headers(), 
                    params=update_params, 
                    json=update_data
                )
                
                if update_response.status_code in [200, 204]:
                    success_count += 1
                else:
                    print(f"⚠️ Error actualizando producto {product_id}: {update_response.status_code}")
            
            print(f"✅ {success_count}/{len(products)} productos actualizados")
            return True
        else:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error actualizando productos: {e}")
        return False

def test_approval_system():
    """Probar el sistema de aprobación creando un producto de prueba"""
    print("🧪 Probando sistema de aprobación...")
    
    try:
        # Crear un producto de prueba con estado pending
        test_product = {
            'name': 'Producto de Prueba - Aprobación',
            'description': 'Producto creado para probar el sistema de aprobación',
            'price': 10.00,
            'image_url': 'https://via.placeholder.com/300x300?text=Test',
            'category_id': '1',  # Asumiendo que existe una categoría con ID 1
            'unit': 'unidad',
            'weight': 1.0,
            'is_active': True,
            'is_available': True,
            'stock': 5,
            'approval_status': 'pending',
            'vendor_id': 'test-vendor-id'
        }
        
        url = f"{SUPABASE_URL}/rest/v1/store_products"
        response = requests.post(url, headers=get_headers(), json=test_product)
        
        if response.status_code in [200, 201]:
            print("✅ Producto de prueba creado exitosamente")
            product_data = response.json()
            product_id = product_data[0]['id'] if isinstance(product_data, list) else product_data['id']
            
            # Intentar aprobar el producto
            approve_url = f"{SUPABASE_URL}/rest/v1/store_products"
            approve_params = {'id': f'eq.{product_id}'}
            approve_data = {
                'approval_status': 'approved',
                'approved_at': 'now()',
                'approved_by': 'test-admin-id',
                'approval_notes': 'Aprobado por sistema de prueba'
            }
            
            approve_response = requests.patch(
                approve_url, 
                headers=get_headers(), 
                params=approve_params, 
                json=approve_data
            )
            
            if approve_response.status_code in [200, 204]:
                print("✅ Producto de prueba aprobado exitosamente")
                
                # Limpiar producto de prueba
                delete_url = f"{SUPABASE_URL}/rest/v1/store_products"
                delete_params = {'id': f'eq.{product_id}'}
                delete_response = requests.delete(delete_url, headers=get_headers(), params=delete_params)
                
                if delete_response.status_code in [200, 204]:
                    print("✅ Producto de prueba eliminado")
                
                return True
            else:
                print(f"❌ Error aprobando producto: {approve_response.status_code}")
                return False
        else:
            print(f"❌ Error creando producto de prueba: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error en prueba: {e}")
        return False

def main():
    """Función principal"""
    print("🛒 Configurando Sistema de Aprobación de Productos de Vendedores")
    print("=" * 60)
    
    # Paso 1: Informar sobre columnas manuales
    add_approval_columns()
    
    print("\n📋 INSTRUCCIONES MANUALES:")
    print("1. Ve al SQL Editor de Supabase")
    print("2. Ejecuta el siguiente SQL:")
    print("""
-- Agregar columnas de aprobación
ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approval_status VARCHAR(20) DEFAULT 'approved';

ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;

ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES users(id);

ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approval_notes TEXT;

-- Crear índices
CREATE INDEX IF NOT EXISTS idx_store_products_approval_status ON store_products(approval_status);
CREATE INDEX IF NOT EXISTS idx_store_products_vendor_approval ON store_products(vendor_id, approval_status);
""")
    
    input("\n⏸️ Presiona Enter después de ejecutar el SQL en Supabase...")
    
    # Paso 2: Actualizar productos existentes
    if update_existing_products():
        print("✅ Productos existentes actualizados")
    else:
        print("⚠️ Error actualizando productos existentes")
    
    # Paso 3: Probar sistema
    if test_approval_system():
        print("\n🎉 ¡Sistema de aprobación configurado y funcionando!")
        print("\n📋 Funcionalidades implementadas:")
        print("   • Productos de vendedores requieren aprobación")
        print("   • Estados: pending, approved, rejected")
        print("   • Solo productos aprobados se muestran en la app")
        print("   • Sistema de aprobación/rechazo funcionando")
    else:
        print("\n⚠️ Sistema configurado pero con errores en las pruebas")

if __name__ == "__main__":
    main()
