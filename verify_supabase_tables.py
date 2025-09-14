#!/usr/bin/env python3
"""
Script para verificar y crear las tablas necesarias en Supabase
para almacenar tarjetas, direcciones y saldos de usuarios
"""

import requests
import json
import os
from datetime import datetime

# Configuración de Supabase
SUPABASE_URL = "https://zgqrhzuhrwudckwesybg.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU2MzQ5NzAsImV4cCI6MjA0MTIxMDk3MH0.ZhJ8VhGJ8VhGJ8VhGJ8VhGJ8VhGJ8VhGJ8VhGJ8VhGJ8"

def check_table_exists(table_name):
    """Verificar si una tabla existe en Supabase"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/{table_name}"
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}",
            "Content-Type": "application/json"
        }
        
        response = requests.get(url, headers=headers, params={"select": "*", "limit": "1"})
        
        if response.status_code == 200:
            print(f"✅ Tabla '{table_name}' existe")
            return True
        elif response.status_code == 404:
            print(f"❌ Tabla '{table_name}' NO existe")
            return False
        else:
            print(f"⚠️ Error verificando tabla '{table_name}': {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error verificando tabla '{table_name}': {e}")
        return False

def execute_sql(sql_command):
    """Ejecutar comando SQL en Supabase"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/rpc/exec_sql"
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}",
            "Content-Type": "application/json"
        }
        
        payload = {"sql": sql_command}
        response = requests.post(url, headers=headers, json=payload)
        
        if response.status_code == 200:
            print(f"✅ SQL ejecutado exitosamente")
            return True
        else:
            print(f"❌ Error ejecutando SQL: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error ejecutando SQL: {e}")
        return False

def main():
    print("🔍 VERIFICANDO TABLAS NECESARIAS EN SUPABASE")
    print("=" * 50)
    
    # Tablas críticas que necesitamos
    critical_tables = [
        "users",
        "payment_cards", 
        "user_addresses",
        "transfers",
        "activities",
        "notifications"
    ]
    
    missing_tables = []
    
    for table in critical_tables:
        if not check_table_exists(table):
            missing_tables.append(table)
    
    print("\n" + "=" * 50)
    
    if missing_tables:
        print(f"❌ FALTAN {len(missing_tables)} TABLAS CRÍTICAS:")
        for table in missing_tables:
            print(f"   - {table}")
        
        print("\n🔧 CREANDO TABLAS FALTANTES...")
        
        # SQL para crear las tablas faltantes
        create_tables_sql = """
        -- Crear tabla payment_cards si no existe
        CREATE TABLE IF NOT EXISTS payment_cards (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            card_number TEXT NOT NULL,
            card_type TEXT NOT NULL,
            expiry_month TEXT NOT NULL,
            expiry_year TEXT NOT NULL,
            holder_name TEXT NOT NULL,
            is_default BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Crear tabla user_addresses si no existe
        CREATE TABLE IF NOT EXISTS user_addresses (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            address_line_1 TEXT NOT NULL,
            address_line_2 TEXT,
            city TEXT NOT NULL,
            province TEXT NOT NULL,
            postal_code TEXT,
            country TEXT DEFAULT 'Cuba',
            phone TEXT,
            is_default BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Crear tabla transfers si no existe
        CREATE TABLE IF NOT EXISTS transfers (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            from_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            to_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            amount DECIMAL(10,2) NOT NULL,
            type TEXT NOT NULL CHECK (type IN ('send', 'request')),
            status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
            description TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Crear tabla activities si no existe
        CREATE TABLE IF NOT EXISTS activities (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            amount DECIMAL(10,2),
            status TEXT DEFAULT 'completed',
            metadata JSONB DEFAULT '{}',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Crear tabla notifications si no existe
        CREATE TABLE IF NOT EXISTS notifications (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            type TEXT DEFAULT 'general',
            is_read BOOLEAN DEFAULT FALSE,
            metadata JSONB DEFAULT '{}',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Habilitar RLS en las tablas
        ALTER TABLE payment_cards ENABLE ROW LEVEL SECURITY;
        ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;
        ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;
        ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
        ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
        """
        
        if execute_sql(create_tables_sql):
            print("✅ Tablas creadas exitosamente")
        else:
            print("❌ Error creando tablas")
            
    else:
        print("✅ TODAS LAS TABLAS CRÍTICAS EXISTEN")
    
    print("\n🎉 VERIFICACIÓN COMPLETADA")
    print("=" * 50)

if __name__ == "__main__":
    main()


