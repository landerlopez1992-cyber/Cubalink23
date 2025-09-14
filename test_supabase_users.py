#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import requests
import json
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv('config.env')

def test_supabase_connection():
    """Probar conexión con Supabase"""
    
    # Configuración de Supabase
    supabase_url = os.getenv('SUPABASE_URL', 'https://zgqrhzuhrwudckwesybg.supabase.co')
    supabase_key = os.getenv('SUPABASE_ANON_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ')
    
    headers = {
        'apikey': supabase_key,
        'Authorization': 'Bearer ' + supabase_key,
        'Content-Type': 'application/json'
    }
    
    print("🔍 Probando conexión con Supabase...")
    print(f"URL: {supabase_url}")
    print(f"Key: {supabase_key[:20]}...")
    
    try:
        # Probar obtener usuarios
        print("\n📋 Obteniendo usuarios...")
        response = requests.get(
            supabase_url + '/rest/v1/users',
            headers=headers
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            users = response.json()
            print(f"✅ Conexión exitosa! Encontrados {len(users)} usuarios:")
            
            for i, user in enumerate(users, 1):
                print(f"\n👤 Usuario {i}:")
                print(f"   ID: {user.get('id', 'N/A')}")
                print(f"   Email: {user.get('email', 'N/A')}")
                print(f"   Nombre: {user.get('name', 'N/A')}")
                print(f"   Teléfono: {user.get('phone', 'N/A')}")
                print(f"   Balance: {user.get('balance', 'N/A')}")
                print(f"   Estado: {user.get('status', 'N/A')}")
                print(f"   Creado: {user.get('created_at', 'N/A')}")
                
        elif response.status_code == 401:
            print("❌ Error 401: No autorizado. Verificar credenciales.")
            print(f"Response: {response.text}")
        elif response.status_code == 404:
            print("❌ Error 404: Tabla 'users' no encontrada.")
            print(f"Response: {response.text}")
        else:
            print(f"❌ Error {response.status_code}: {response.text}")
            
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
    
    # Probar obtener información de la tabla
    try:
        print("\n📊 Obteniendo información de la tabla...")
        response = requests.get(
            supabase_url + '/rest/v1/',
            headers=headers
        )
        
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            print("✅ Información de la tabla obtenida")
            print(f"Response: {response.text[:200]}...")
        else:
            print(f"❌ Error obteniendo información: {response.text}")
            
    except Exception as e:
        print(f"❌ Error obteniendo información: {e}")

if __name__ == "__main__":
    test_supabase_connection()
