#!/usr/bin/env python3
"""
Script para configurar el sistema de aprobación de productos de vendedores
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

def execute_sql(sql_query):
    """Ejecutar consulta SQL en Supabase"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/rpc/exec_sql"
        data = {'query': sql_query}
        
        response = requests.post(url, headers=get_headers(), json=data)
        
        if response.status_code in [200, 201, 204]:
            print("✅ SQL ejecutado exitosamente")
            return True
        else:
            print(f"❌ Error ejecutando SQL: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error en petición: {e}")
        return False

def setup_approval_system():
    """Configurar sistema de aprobación"""
    print("🚀 Configurando sistema de aprobación de productos...")
    
    # Leer el archivo SQL
    try:
        with open('add_approval_system.sql', 'r') as f:
            sql_content = f.read()
        
        # Dividir en comandos individuales
        sql_commands = [cmd.strip() for cmd in sql_content.split(';') if cmd.strip()]
        
        success_count = 0
        total_commands = len(sql_commands)
        
        for i, command in enumerate(sql_commands, 1):
            if command:
                print(f"📝 Ejecutando comando {i}/{total_commands}...")
                if execute_sql(command):
                    success_count += 1
                else:
                    print(f"⚠️ Comando {i} falló, continuando...")
        
        print(f"\n📊 Resultado: {success_count}/{total_commands} comandos ejecutados exitosamente")
        
        if success_count == total_commands:
            print("🎉 ¡Sistema de aprobación configurado completamente!")
            return True
        else:
            print("⚠️ Sistema configurado parcialmente, revisar errores")
            return False
            
    except FileNotFoundError:
        print("❌ Archivo add_approval_system.sql no encontrado")
        return False
    except Exception as e:
        print(f"❌ Error leyendo archivo SQL: {e}")
        return False

def verify_approval_system():
    """Verificar que el sistema de aprobación esté funcionando"""
    print("\n🔍 Verificando sistema de aprobación...")
    
    try:
        # Verificar que la tabla tenga las nuevas columnas
        url = f"{SUPABASE_URL}/rest/v1/store_products"
        params = {'select': 'id,approval_status,approved_at,approved_by,approval_notes', 'limit': '1'}
        
        response = requests.get(url, headers=get_headers(), params=params)
        
        if response.status_code == 200:
            print("✅ Tabla store_products actualizada correctamente")
            data = response.json()
            if data:
                print(f"📋 Ejemplo de producto: {data[0]}")
            return True
        else:
            print(f"❌ Error verificando tabla: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error en verificación: {e}")
        return False

def main():
    """Función principal"""
    print("🛒 Configurando Sistema de Aprobación de Productos de Vendedores")
    print("=" * 60)
    
    # Configurar sistema
    if setup_approval_system():
        # Verificar configuración
        if verify_approval_system():
            print("\n🎉 ¡Sistema de aprobación listo!")
            print("\n📋 Funcionalidades implementadas:")
            print("   • Productos de vendedores requieren aprobación")
            print("   • Estados: pending, approved, rejected")
            print("   • Solo productos aprobados se muestran en la app")
            print("   • Panel de admin para aprobar/rechazar productos")
            print("   • RLS configurado para seguridad")
        else:
            print("\n⚠️ Sistema configurado pero con errores de verificación")
    else:
        print("\n❌ Error configurando sistema de aprobación")

if __name__ == "__main__":
    main()
