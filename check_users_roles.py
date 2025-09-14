#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import json
from datetime import datetime

def check_users_with_roles():
    """Verificar usuarios con roles de vendedor y repartidor en Supabase"""
    
    # Configuración de Supabase - MISMAS credenciales que usa Flutter
    supabase_url = 'https://zgqrhzuhrwudckwesybg.supabase.co'
    supabase_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
    
    headers = {
        'apikey': supabase_key,
        'Authorization': 'Bearer ' + supabase_key,
        'Content-Type': 'application/json'
    }
    
    print("🔍 VERIFICANDO USUARIOS CON ROLES EN SUPABASE")
    print("=" * 50)
    print(f"URL: {supabase_url}")
    print(f"Key: {supabase_key[:20]}...")
    print()
    
    try:
        # 1. Verificar tabla de usuarios (auth.users)
        print("📋 1. VERIFICANDO TABLA auth.users...")
        try:
            response = requests.get(
                supabase_url + '/rest/v1/auth/users',
                headers=headers
            )
            if response.status_code == 200:
                auth_users = response.json()
                print(f"✅ Encontrados {len(auth_users)} usuarios en auth.users")
                for user in auth_users:
                    print(f"   - ID: {user.get('id', 'N/A')}")
                    print(f"     Email: {user.get('email', 'N/A')}")
                    print(f"     Creado: {user.get('created_at', 'N/A')}")
                    print(f"     Último login: {user.get('last_sign_in_at', 'N/A')}")
                    print()
            else:
                print(f"❌ Error accediendo auth.users: {response.status_code}")
                print(f"   Respuesta: {response.text}")
        except Exception as e:
            print(f"❌ Error con auth.users: {e}")
        
        print("-" * 50)
        
        # 2. Verificar tabla de perfiles/usuarios personalizada
        print("📋 2. VERIFICANDO TABLA users (perfiles)...")
        try:
            response = requests.get(
                supabase_url + '/rest/v1/users',
                headers=headers
            )
            if response.status_code == 200:
                users = response.json()
                print(f"✅ Encontrados {len(users)} usuarios en tabla users")
                
                vendors = []
                delivery = []
                admins = []
                moderators = []
                regular = []
                
                for user in users:
                    role = user.get('role', 'Usuario')
                    print(f"   - ID: {user.get('id', 'N/A')}")
                    print(f"     Email: {user.get('email', 'N/A')}")
                    print(f"     Nombre: {user.get('name', 'N/A')}")
                    print(f"     Rol: {role}")
                    print(f"     Bloqueado: {user.get('blocked', False)}")
                    print(f"     Creado: {user.get('created_at', 'N/A')}")
                    print()
                    
                    # Categorizar por rol
                    if role == 'vendor':
                        vendors.append(user)
                    elif role == 'delivery':
                        delivery.append(user)
                    elif role == 'Admin':
                        admins.append(user)
                    elif role == 'Moderador':
                        moderators.append(user)
                    else:
                        regular.append(user)
                
                print("=" * 50)
                print("📊 RESUMEN DE ROLES:")
                print(f"   🏪 VENDEDORES: {len(vendors)}")
                for vendor in vendors:
                    print(f"      - {vendor.get('email', 'N/A')} ({vendor.get('name', 'Sin nombre')})")
                
                print(f"   🚚 REPARTIDORES: {len(delivery)}")
                for repartidor in delivery:
                    print(f"      - {repartidor.get('email', 'N/A')} ({repartidor.get('name', 'Sin nombre')})")
                
                print(f"   👑 ADMINISTRADORES: {len(admins)}")
                for admin in admins:
                    print(f"      - {admin.get('email', 'N/A')} ({admin.get('name', 'Sin nombre')})")
                
                print(f"   🛡️ MODERADORES: {len(moderators)}")
                for mod in moderators:
                    print(f"      - {mod.get('email', 'N/A')} ({mod.get('name', 'Sin nombre')})")
                
                print(f"   👤 USUARIOS REGULARES: {len(regular)}")
                for user in regular:
                    print(f"      - {user.get('email', 'N/A')} ({user.get('name', 'Sin nombre')})")
                
            else:
                print(f"❌ Error accediendo tabla users: {response.status_code}")
                print(f"   Respuesta: {response.text}")
        except Exception as e:
            print(f"❌ Error con tabla users: {e}")
        
        print("-" * 50)
        
        # 3. Verificar otras tablas relacionadas
        print("📋 3. VERIFICANDO OTRAS TABLAS...")
        
        # Verificar si existe tabla de roles
        try:
            response = requests.get(
                supabase_url + '/rest/v1/user_roles',
                headers=headers
            )
            if response.status_code == 200:
                roles = response.json()
                print(f"✅ Tabla user_roles encontrada: {len(roles)} registros")
                for role in roles:
                    print(f"   - {role}")
            else:
                print("ℹ️ Tabla user_roles no existe o no accesible")
        except Exception as e:
            print("ℹ️ Tabla user_roles no existe o no accesible")
        
        # Verificar si existe tabla de perfiles
        try:
            response = requests.get(
                supabase_url + '/rest/v1/profiles',
                headers=headers
            )
            if response.status_code == 200:
                profiles = response.json()
                print(f"✅ Tabla profiles encontrada: {len(profiles)} registros")
                for profile in profiles:
                    print(f"   - {profile}")
            else:
                print("ℹ️ Tabla profiles no existe o no accesible")
        except Exception as e:
            print("ℹ️ Tabla profiles no existe o no accesible")
        
    except Exception as e:
        print(f"❌ Error general: {e}")
    
    print("\n" + "=" * 50)
    print("✅ VERIFICACIÓN COMPLETADA")

if __name__ == "__main__":
    check_users_with_roles()





