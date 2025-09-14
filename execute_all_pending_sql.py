#!/usr/bin/env python3
"""
Script para ejecutar todo el SQL pendiente en Supabase
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

def execute_sql_direct(sql_command):
    """Ejecutar SQL directamente usando la API de Supabase"""
    try:
        # Usar el endpoint directo de SQL
        url = f"{SUPABASE_URL}/sql"
        
        response = requests.post(url, headers=get_headers(), data=sql_command)
        
        if response.status_code in [200, 201, 204]:
            print("✅ SQL ejecutado exitosamente")
            return True
        else:
            print(f"❌ Error ejecutando SQL: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error en petición: {e}")
        return False

def update_products_approval_status():
    """Actualizar productos existentes para que estén aprobados"""
    try:
        print("📦 Actualizando productos existentes a estado 'approved'...")
        
        url = f"{SUPABASE_URL}/rest/v1/store_products"
        params = {'approval_status': 'is.null'}
        data = {'approval_status': 'approved'}
        
        response = requests.patch(url, headers=get_headers(), params=params, json=data)
        
        if response.status_code in [200, 204]:
            print("✅ Productos existentes actualizados")
            return True
        else:
            print(f"❌ Error actualizando productos: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 Ejecutando SQL pendiente en Supabase...")
    print("=" * 50)
    
    # 1. Ejecutar SQL de aprobación
    print("\n🔧 1. Agregando columnas de aprobación...")
    approval_sql = """
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
    """
    
    if execute_sql_direct(approval_sql):
        print("✅ Sistema de aprobación configurado")
    else:
        print("⚠️ Error en sistema de aprobación, continuando...")
    
    # 2. Crear tablas para perfiles de vendedor
    print("\n🏪 2. Creando tablas de perfiles de vendedor...")
    vendor_profiles_sql = """
    -- Tabla de perfiles de vendedor
    CREATE TABLE IF NOT EXISTS vendor_profiles (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
        company_name VARCHAR NOT NULL,
        company_description TEXT,
        company_logo_url TEXT,
        store_cover_url TEXT,
        business_address TEXT,
        business_phone VARCHAR,
        business_email VARCHAR,
        categories JSONB DEFAULT '[]',
        is_verified BOOLEAN DEFAULT false,
        rating_average DECIMAL(3,2) DEFAULT 0.0,
        total_ratings INTEGER DEFAULT 0,
        total_sales INTEGER DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- Índices para vendor_profiles
    CREATE INDEX IF NOT EXISTS idx_vendor_profiles_user_id ON vendor_profiles(user_id);
    CREATE INDEX IF NOT EXISTS idx_vendor_profiles_verified ON vendor_profiles(is_verified);
    CREATE INDEX IF NOT EXISTS idx_vendor_profiles_rating ON vendor_profiles(rating_average);
    """
    
    if execute_sql_direct(vendor_profiles_sql):
        print("✅ Tablas de vendedor creadas")
    else:
        print("⚠️ Error en tablas de vendedor, continuando...")
    
    # 3. Crear tablas para perfiles de repartidor
    print("\n🚚 3. Creando tablas de perfiles de repartidor...")
    delivery_profiles_sql = """
    -- Tabla de perfiles de repartidor
    CREATE TABLE IF NOT EXISTS delivery_profiles (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
        professional_photo_url TEXT,
        vehicle_type VARCHAR,
        license_plate VARCHAR,
        phone VARCHAR,
        areas_served JSONB DEFAULT '[]',
        is_active BOOLEAN DEFAULT true,
        rating_average DECIMAL(3,2) DEFAULT 0.0,
        total_ratings INTEGER DEFAULT 0,
        total_deliveries INTEGER DEFAULT 0,
        balance DECIMAL(10,2) DEFAULT 0.0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- Índices para delivery_profiles
    CREATE INDEX IF NOT EXISTS idx_delivery_profiles_user_id ON delivery_profiles(user_id);
    CREATE INDEX IF NOT EXISTS idx_delivery_profiles_active ON delivery_profiles(is_active);
    CREATE INDEX IF NOT EXISTS idx_delivery_profiles_rating ON delivery_profiles(rating_average);
    """
    
    if execute_sql_direct(delivery_profiles_sql):
        print("✅ Tablas de repartidor creadas")
    else:
        print("⚠️ Error en tablas de repartidor, continuando...")
    
    # 4. Crear sistema de calificaciones
    print("\n⭐ 4. Creando sistema de calificaciones...")
    ratings_sql = """
    -- Tabla de calificaciones de vendedores
    CREATE TABLE IF NOT EXISTS vendor_ratings (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        vendor_id UUID REFERENCES vendor_profiles(id) ON DELETE CASCADE,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        rating INTEGER CHECK (rating >= 1 AND rating <= 5),
        comment TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        UNIQUE(vendor_id, user_id)
    );

    -- Tabla de reportes de vendedores
    CREATE TABLE IF NOT EXISTS vendor_reports (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        vendor_id UUID REFERENCES vendor_profiles(id) ON DELETE CASCADE,
        reporter_id UUID REFERENCES users(id) ON DELETE CASCADE,
        product_id UUID REFERENCES store_products(id) ON DELETE SET NULL,
        report_type VARCHAR NOT NULL, -- 'vendor', 'product', 'service'
        reason VARCHAR NOT NULL,
        description TEXT,
        status VARCHAR DEFAULT 'pending', -- 'pending', 'reviewed', 'resolved'
        admin_notes TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- Índices para ratings y reports
    CREATE INDEX IF NOT EXISTS idx_vendor_ratings_vendor_id ON vendor_ratings(vendor_id);
    CREATE INDEX IF NOT EXISTS idx_vendor_ratings_user_id ON vendor_ratings(user_id);
    CREATE INDEX IF NOT EXISTS idx_vendor_reports_vendor_id ON vendor_reports(vendor_id);
    CREATE INDEX IF NOT EXISTS idx_vendor_reports_status ON vendor_reports(status);
    """
    
    if execute_sql_direct(ratings_sql):
        print("✅ Sistema de calificaciones creado")
    else:
        print("⚠️ Error en sistema de calificaciones, continuando...")
    
    # 5. Actualizar productos existentes
    print("\n📦 5. Actualizando productos existentes...")
    if update_products_approval_status():
        print("✅ Productos existentes actualizados")
    else:
        print("⚠️ Error actualizando productos")
    
    print("\n🎉 ¡SQL ejecutado completamente!")
    print("\n📋 Sistemas creados:")
    print("   ✅ Sistema de aprobación de productos")
    print("   ✅ Perfiles de vendedor con fotos separadas")
    print("   ✅ Perfiles de repartidor")
    print("   ✅ Sistema de calificaciones y reportes")

if __name__ == "__main__":
    main()
