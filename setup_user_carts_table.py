#!/usr/bin/env python3
"""
Script para crear la tabla user_carts en Supabase
"""

import os
import sys
from supabase import create_client, Client

def setup_user_carts_table():
    """Crear tabla user_carts en Supabase"""
    
    # Configuración de Supabase
    SUPABASE_URL = "https://your-project.supabase.co"  # Reemplaza con tu URL
    SUPABASE_KEY = "your-anon-key"  # Reemplaza con tu anon key
    
    try:
        # Crear cliente de Supabase
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        # Leer el archivo SQL
        with open('create_user_carts_table.sql', 'r') as f:
            sql_content = f.read()
        
        print("📋 SQL a ejecutar:")
        print(sql_content)
        print("\n" + "="*50)
        
        # Ejecutar el SQL usando rpc (función personalizada)
        # Nota: Necesitarás crear una función en Supabase para ejecutar SQL dinámico
        print("⚠️  IMPORTANTE: Ejecuta manualmente el SQL en el editor de Supabase:")
        print("1. Ve a https://supabase.com/dashboard")
        print("2. Selecciona tu proyecto")
        print("3. Ve a SQL Editor")
        print("4. Copia y pega el contenido de create_user_carts_table.sql")
        print("5. Ejecuta el SQL")
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Configurando tabla user_carts en Supabase...")
    success = setup_user_carts_table()
    
    if success:
        print("✅ Instrucciones generadas correctamente")
        print("📝 Sigue los pasos mostrados arriba para crear la tabla")
    else:
        print("❌ Error en la configuración")
        sys.exit(1)