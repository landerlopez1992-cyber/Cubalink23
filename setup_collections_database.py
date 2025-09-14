#!/usr/bin/env python3
"""
Script para configurar las tablas de colecciones en Supabase
"""

import requests
import json

# Configuración de Supabase
SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'

def execute_sql_file():
    """Ejecutar el archivo SQL de creación de tablas"""
    try:
        # Leer el archivo SQL
        with open('create_collections_tables.sql', 'r', encoding='utf-8') as file:
            sql_content = file.read()
        
        print("📄 Contenido del archivo SQL:")
        print("=" * 50)
        print(sql_content)
        print("=" * 50)
        
        print("\n🔧 INSTRUCCIONES PARA EJECUTAR EN SUPABASE:")
        print("1. Ve a https://supabase.com/dashboard")
        print("2. Selecciona tu proyecto: zgqrhzuhrwudckwesybg")
        print("3. Ve al SQL Editor")
        print("4. Copia y pega el contenido SQL mostrado arriba")
        print("5. Haz clic en 'Run' para ejecutar")
        print("6. Verifica que las tablas se crearon correctamente")
        
        return True
        
    except FileNotFoundError:
        print("❌ Error: No se encontró el archivo create_collections_tables.sql")
        return False
    except Exception as e:
        print(f"❌ Error leyendo archivo SQL: {e}")
        return False

def test_collections_api():
    """Probar que las rutas de colecciones funcionen"""
    print("\n🧪 PROBANDO RUTAS DE COLECCIONES:")
    
    # Probar endpoint de colecciones
    try:
        response = requests.get(f'{SUPABASE_URL}/rest/v1/collections?select=*', 
                              headers={
                                  'apikey': SUPABASE_KEY,
                                  'Authorization': f'Bearer {SUPABASE_KEY}',
                                  'Content-Type': 'application/json'
                              })
        
        print(f"📡 Status Code: {response.status_code}")
        print(f"📊 Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ Tabla 'collections' existe y es accesible")
            return True
        else:
            print("❌ Tabla 'collections' no existe o no es accesible")
            print("💡 Necesitas ejecutar el SQL en Supabase primero")
            return False
            
    except Exception as e:
        print(f"❌ Error probando API: {e}")
        return False

def main():
    print("🔧 CONFIGURACIÓN DE BASE DE DATOS PARA COLECCIONES")
    print("=" * 60)
    
    # Mostrar contenido del SQL
    sql_ok = execute_sql_file()
    
    if sql_ok:
        print("\n" + "=" * 60)
        print("📋 RESUMEN:")
        print("✅ Archivo SQL leído correctamente")
        print("📝 Instrucciones mostradas arriba")
        print("🔧 Ejecuta el SQL en Supabase para crear las tablas")
        print("🧪 Después ejecuta este script nuevamente para probar")
        
        # Preguntar si quiere probar la API
        print("\n¿Quieres probar si las tablas ya existen? (y/n): ", end="")
        try:
            response = input().lower().strip()
            if response in ['y', 'yes', 'sí', 'si']:
                test_collections_api()
        except:
            pass

if __name__ == "__main__":
    main()
