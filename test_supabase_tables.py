#!/usr/bin/env python3
"""
Test para verificar si las tablas necesarias existen en Supabase
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = "https://zgqrhzuhrwudckwesybg.supabase.co"
# Usamos la clave anon para verificar acceso básico
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU2MzQ5NzAsImV4cCI6MjA0MTIxMDk3MH0.7uM1T7l7_hHF5D5VxuF3N8g2XH5vR9PQ_8K3Q1x0ABC"

def test_table_structure(table_name):
    """Verificar estructura de tabla haciendo una consulta con límite 0"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/{table_name}"
        headers = {
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
            "Content-Type": "application/json",
            "Prefer": "count=exact"
        }
        
        # Intentar hacer SELECT con límite 0 para verificar estructura
        params = {"select": "*", "limit": "0"}
        response = requests.get(url, headers=headers, params=params)
        
        if response.status_code == 200:
            print(f"✅ Tabla '{table_name}' existe y es accesible")
            return True
        elif response.status_code == 401:
            print(f"🔒 Tabla '{table_name}' existe pero requiere autenticación (RLS activo)")
            return True
        elif response.status_code == 404:
            print(f"❌ Tabla '{table_name}' NO existe")
            return False
        else:
            print(f"⚠️ Tabla '{table_name}' - Estado: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error verificando tabla '{table_name}': {e}")
        return False

def main():
    print("🔍 VERIFICANDO EXISTENCIA DE TABLAS EN SUPABASE")
    print("=" * 50)
    
    # Tablas críticas para el flujo de pagos
    critical_tables = [
        "users",           # Para saldos de usuarios
        "payment_cards",   # Para tarjetas guardadas
        "user_addresses",  # Para direcciones de usuarios
        "transfers",       # Para transferencias
        "activities",      # Para historial
        "notifications"    # Para notificaciones
    ]
    
    missing_tables = []
    existing_tables = []
    
    for table in critical_tables:
        if test_table_structure(table):
            existing_tables.append(table)
        else:
            missing_tables.append(table)
    
    print("\n" + "=" * 50)
    print("📊 RESUMEN:")
    
    if existing_tables:
        print(f"✅ Tablas EXISTENTES ({len(existing_tables)}):")
        for table in existing_tables:
            print(f"   - {table}")
    
    if missing_tables:
        print(f"\n❌ Tablas FALTANTES ({len(missing_tables)}):")
        for table in missing_tables:
            print(f"   - {table}")
        
        print("\n🔧 NECESITAS EJECUTAR EL SQL EN SUPABASE:")
        print("   1. Ve a Supabase Dashboard > SQL Editor")
        print("   2. Ejecuta el archivo: create_missing_tables.sql")
        print("   3. O ejecuta estos comandos manualmente:")
        
        if "payment_cards" in missing_tables:
            print("\n   -- Crear tabla payment_cards")
            print("   CREATE TABLE payment_cards (")
            print("       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),")
            print("       user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,")
            print("       card_number TEXT NOT NULL,")
            print("       card_type TEXT NOT NULL,")
            print("       expiry_month TEXT NOT NULL,")
            print("       expiry_year TEXT NOT NULL,")
            print("       holder_name TEXT NOT NULL,")
            print("       is_default BOOLEAN DEFAULT FALSE,")
            print("       created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),")
            print("       updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()")
            print("   );")
            print("   ALTER TABLE payment_cards ENABLE ROW LEVEL SECURITY;")
            
        if "user_addresses" in missing_tables:
            print("\n   -- Crear tabla user_addresses")
            print("   CREATE TABLE user_addresses (")
            print("       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),")
            print("       user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,")
            print("       name TEXT NOT NULL,")
            print("       address_line_1 TEXT NOT NULL,")
            print("       city TEXT NOT NULL,")
            print("       province TEXT NOT NULL,")
            print("       country TEXT DEFAULT 'Cuba',")
            print("       is_default BOOLEAN DEFAULT FALSE,")
            print("       created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()")
            print("   );")
            print("   ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;")
    else:
        print("\n🎉 TODAS LAS TABLAS CRÍTICAS EXISTEN!")
        print("✅ Tu app debería poder guardar tarjetas y direcciones sin problemas.")
    
    print("\n" + "=" * 50)

if __name__ == "__main__":
    main()


