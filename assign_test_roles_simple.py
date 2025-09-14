#!/usr/bin/env python3
"""
Script simple para asignar roles de vendedor y repartidor a usuarios de prueba
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

def get_user_by_email(email):
    """Buscar usuario por email"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/users"
        params = {'email': f'eq.{email}'}
        
        response = requests.get(url, headers=get_headers(), params=params)
        
        if response.status_code == 200:
            data = response.json()
            return data[0] if data else None
        else:
            print(f"❌ Error buscando usuario {email}: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error en petición: {e}")
        return None

def update_user_role(user_id, role):
    """Actualizar rol de usuario"""
    try:
        url = f"{SUPABASE_URL}/rest/v1/users"
        params = {'id': f'eq.{user_id}'}
        data = {'role': role}
        
        response = requests.patch(url, headers=get_headers(), params=params, json=data)
        
        if response.status_code in [200, 204]:
            return True
        else:
            print(f"❌ Error actualizando rol: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error en petición: {e}")
        return False

def assign_vendor_role(email):
    """Asignar rol de vendedor"""
    print(f"🛒 Asignando rol de vendedor a: {email}")
    
    user = get_user_by_email(email)
    if not user:
        print(f"⚠️ Usuario {email} no encontrado")
        return False
    
    success = update_user_role(user['id'], 'vendor')
    if success:
        print(f"✅ Rol de vendedor asignado exitosamente a {email}")
        return True
    else:
        print(f"❌ Error asignando rol de vendedor a {email}")
        return False

def assign_delivery_role(email):
    """Asignar rol de repartidor"""
    print(f"🚚 Asignando rol de repartidor a: {email}")
    
    user = get_user_by_email(email)
    if not user:
        print(f"⚠️ Usuario {email} no encontrado")
        return False
    
    success = update_user_role(user['id'], 'delivery')
    if success:
        print(f"✅ Rol de repartidor asignado exitosamente a {email}")
        return True
    else:
        print(f"❌ Error asignando rol de repartidor a {email}")
        return False

def remove_admin_role(email):
    """Eliminar rol de administrador"""
    print(f"🔧 Eliminando rol de administrador de: {email}")
    
    user = get_user_by_email(email)
    if not user:
        print(f"⚠️ Usuario {email} no encontrado")
        return False
    
    success = update_user_role(user['id'], 'user')
    if success:
        print(f"✅ Rol de administrador eliminado exitosamente de {email}")
        return True
    else:
        print(f"❌ Error eliminando rol de administrador de {email}")
        return False

def verify_user_roles():
    """Verificar roles de usuarios de prueba"""
    print("🔍 Verificando roles de usuarios de prueba...")
    
    test_emails = [
        'landerlopez1992@gmail.com',
        'tallercell0133@gmail.com'
    ]
    
    for email in test_emails:
        user = get_user_by_email(email)
        if user:
            print(f"👤 {user.get('name', 'Sin nombre')} ({user['email']}) - Rol: {user.get('role', 'Sin rol')}")
        else:
            print(f"⚠️ Usuario {email} no encontrado")

def main():
    """Función principal"""
    print("🚀 Asignando roles de prueba...")
    
    # Verificar roles actuales
    print("\n📊 Roles actuales:")
    verify_user_roles()
    
    # Asignar roles
    print("\n🔄 Asignando nuevos roles...")
    
    # Eliminar rol de admin de landerlopez1992@gmail.com
    remove_admin_role('landerlopez1992@gmail.com')
    
    # Asignar rol de vendedor a landerlopez1992@gmail.com
    assign_vendor_role('landerlopez1992@gmail.com')
    
    # Asignar rol de repartidor a tallercell0133@gmail.com
    assign_delivery_role('tallercell0133@gmail.com')
    
    # Verificar roles finales
    print("\n✅ Roles finales:")
    verify_user_roles()
    
    print("\n🎉 ¡Roles asignados exitosamente!")
    print("📱 Ahora puedes probar:")
    print("   • landerlopez1992@gmail.com - Panel de Vendedor")
    print("   • tallercell0133@gmail.com - Panel de Repartidor")

if __name__ == "__main__":
    main()
