#!/usr/bin/env python3
"""
Script para asignar roles de vendedor y repartidor a usuarios de prueba
"""

import os
import sys
from supabase import create_client, Client

# Configuración de Supabase
SUPABASE_URL = "https://qjqjqjqjqjqjqjqjqjqj.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqcWpxanFqcWpxanFqcWpxanFqcWoiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY5OTk5OTk5OSwiZXhwIjoyMDE1NTc1OTk5fQ.example"

def get_supabase_client():
    """Crear cliente de Supabase"""
    try:
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        return supabase
    except Exception as e:
        print(f"❌ Error conectando a Supabase: {e}")
        return None

def assign_vendor_role(supabase: Client, email: str):
    """Asignar rol de vendedor a un usuario"""
    try:
        print(f"🛒 Asignando rol de vendedor a: {email}")
        
        # Buscar usuario por email
        response = supabase.table('users').select('*').eq('email', email).execute()
        
        if not response.data:
            print(f"⚠️ Usuario {email} no encontrado")
            return False
        
        user = response.data[0]
        user_id = user['id']
        
        # Actualizar rol del usuario
        update_response = supabase.table('users').update({
            'role': 'vendor',
            'updated_at': 'now()'
        }).eq('id', user_id).execute()
        
        if update_response.data:
            print(f"✅ Rol de vendedor asignado exitosamente a {email}")
            return True
        else:
            print(f"❌ Error asignando rol de vendedor a {email}")
            return False
            
    except Exception as e:
        print(f"❌ Error asignando rol de vendedor: {e}")
        return False

def assign_delivery_role(supabase: Client, email: str):
    """Asignar rol de repartidor a un usuario"""
    try:
        print(f"🚚 Asignando rol de repartidor a: {email}")
        
        # Buscar usuario por email
        response = supabase.table('users').select('*').eq('email', email).execute()
        
        if not response.data:
            print(f"⚠️ Usuario {email} no encontrado")
            return False
        
        user = response.data[0]
        user_id = user['id']
        
        # Actualizar rol del usuario
        update_response = supabase.table('users').update({
            'role': 'delivery',
            'updated_at': 'now()'
        }).eq('id', user_id).execute()
        
        if update_response.data:
            print(f"✅ Rol de repartidor asignado exitosamente a {email}")
            return True
        else:
            print(f"❌ Error asignando rol de repartidor a {email}")
            return False
            
    except Exception as e:
        print(f"❌ Error asignando rol de repartidor: {e}")
        return False

def remove_admin_role(supabase: Client, email: str):
    """Eliminar rol de administrador de un usuario"""
    try:
        print(f"🔧 Eliminando rol de administrador de: {email}")
        
        # Buscar usuario por email
        response = supabase.table('users').select('*').eq('email', email).execute()
        
        if not response.data:
            print(f"⚠️ Usuario {email} no encontrado")
            return False
        
        user = response.data[0]
        user_id = user['id']
        
        # Actualizar rol del usuario a 'user' (rol normal)
        update_response = supabase.table('users').update({
            'role': 'user',
            'updated_at': 'now()'
        }).eq('id', user_id).execute()
        
        if update_response.data:
            print(f"✅ Rol de administrador eliminado exitosamente de {email}")
            return True
        else:
            print(f"❌ Error eliminando rol de administrador de {email}")
            return False
            
    except Exception as e:
        print(f"❌ Error eliminando rol de administrador: {e}")
        return False

def verify_user_roles(supabase: Client):
    """Verificar roles de usuarios de prueba"""
    try:
        print("🔍 Verificando roles de usuarios de prueba...")
        
        test_emails = [
            'landerlopez1992@gmail.com',
            'landinstallationservice@gmail.com'
        ]
        
        for email in test_emails:
            response = supabase.table('users').select('id, email, role, name').eq('email', email).execute()
            
            if response.data:
                user = response.data[0]
                print(f"👤 {user['name']} ({user['email']}) - Rol: {user['role']}")
            else:
                print(f"⚠️ Usuario {email} no encontrado")
                
    except Exception as e:
        print(f"❌ Error verificando roles: {e}")

def main():
    """Función principal"""
    print("🚀 Asignando roles de prueba...")
    
    # Crear cliente de Supabase
    supabase = get_supabase_client()
    if not supabase:
        print("❌ No se pudo conectar a Supabase")
        return
    
    # Verificar roles actuales
    print("\n📊 Roles actuales:")
    verify_user_roles(supabase)
    
    # Asignar roles
    print("\n🔄 Asignando nuevos roles...")
    
    # Eliminar rol de admin de landerlopez1992@gmail.com
    remove_admin_role(supabase, 'landerlopez1992@gmail.com')
    
    # Asignar rol de vendedor a landerlopez1992@gmail.com
    assign_vendor_role(supabase, 'landerlopez1992@gmail.com')
    
    # Asignar rol de repartidor a landinstallationservice@gmail.com
    assign_delivery_role(supabase, 'landinstallationservice@gmail.com')
    
    # Verificar roles finales
    print("\n✅ Roles finales:")
    verify_user_roles(supabase)
    
    print("\n🎉 ¡Roles asignados exitosamente!")
    print("📱 Ahora puedes probar:")
    print("   • landerlopez1992@gmail.com - Panel de Vendedor")
    print("   • landinstallationservice@gmail.com - Panel de Repartidor")

if __name__ == "__main__":
    main()
