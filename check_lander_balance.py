#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import json

# Configuración de Supabase
SUPABASE_URL = "https://zgqrhzuhrwudckwesybg.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ"

def check_user_balance():
    """Verificar el saldo actual del usuario Lander López"""
    
    # Headers para Supabase
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }
    
    # Buscar usuario por email
    email = "landerlopez1992@gmail.com"
    print(f"🔍 Buscando usuario: {email}")
    
    try:
        # Obtener datos del usuario
        response = requests.get(
            f"{SUPABASE_URL}/rest/v1/users?email=eq.{email}&select=*",
            headers=headers
        )
        
        print(f"📊 Status Code: {response.status_code}")
        
        if response.status_code == 200:
            users = response.json()
            
            if users:
                user = users[0]
                print("✅ Usuario encontrado!")
                print(f"📧 Email: {user.get('email')}")
                print(f"👤 Nombre: {user.get('name')}")
                print(f"💰 Saldo actual: ${user.get('balance', 0)}")
                print(f"📅 Última actualización: {user.get('updated_at')}")
                print(f"🆔 User ID: {user.get('id')}")
                
                # Verificar historial de recargas
                print("\n🔍 Verificando historial de recargas...")
                recharge_response = requests.get(
                    f"{SUPABASE_URL}/rest/v1/recharge_history?user_id=eq.{user.get('id')}&select=*&order=created_at.desc&limit=10",
                    headers=headers
                )
                
                if recharge_response.status_code == 200:
                    recharges = recharge_response.json()
                    print(f"📈 Total de recargas encontradas: {len(recharges)}")
                    
                    for i, recharge in enumerate(recharges):
                        print(f"💳 Recarga {i+1}:")
                        print(f"   💵 Monto: ${recharge.get('amount', 0)}")
                        print(f"   💰 Comisión: ${recharge.get('fee', 0)}")
                        print(f"   ✅ Estado: {recharge.get('status', 'N/A')}")
                        print(f"   📅 Fecha: {recharge.get('created_at', 'N/A')}")
                        print(f"   🔗 ID Square: {recharge.get('square_transaction_id', 'N/A')}")
                        print()
                else:
                    print(f"❌ Error obteniendo historial: {recharge_response.status_code}")
                    print(recharge_response.text)
                
            else:
                print("❌ Usuario no encontrado")
                
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            
    except Exception as e:
        print(f"❌ Error de conexión: {str(e)}")

if __name__ == "__main__":
    check_user_balance()
