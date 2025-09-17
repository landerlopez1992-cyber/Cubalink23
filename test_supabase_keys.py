#!/usr/bin/env python3

import requests
import json

# Configuración de Supabase
SUPABASE_URL = "https://zgqrhzuhrwudckwesybg.supabase.co"

# Keys a probar
KEYS_TO_TEST = {
    "service_role": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNjY2NDgyOSwiZXhwIjoyMDQyMjQwODI5fQ.nMhOYDNNfq8NMqXvJKJT8SjLFjZJmVP9gDGGfcE8xhQ",
    "anon_old": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY2NjQ4MjksImV4cCI6MjA0MjI0MDgyOX0.ZHCjAeJnWMfYRWKnxjIhQG_5x8wJjm8nHlPfqXhT4-c",
    "anon_backend": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ"
}

def test_supabase_key(key_name, api_key):
    """Probar una API key de Supabase"""
    print(f"\n🔑 Probando {key_name}...")
    print(f"Key: {api_key[:50]}...")
    
    try:
        # Hacer request a la API REST de Supabase
        headers = {
            'apikey': api_key,
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json'
        }
        
        # Probar obtener órdenes
        url = f"{SUPABASE_URL}/rest/v1/orders"
        response = requests.get(url, headers=headers, params={'select': '*', 'limit': 5})
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ {key_name} FUNCIONA - {len(data)} órdenes encontradas")
            
            if data:
                print("📋 Primeras órdenes:")
                for i, order in enumerate(data[:3], 1):
                    print(f"   {i}. #{order.get('order_number', 'N/A')} - ${order.get('total', 0)} - {order.get('order_status', 'N/A')}")
            return True, len(data)
        else:
            print(f"❌ {key_name} FALLÓ")
            print(f"Error: {response.text}")
            return False, 0
            
    except Exception as e:
        print(f"❌ {key_name} ERROR: {e}")
        return False, 0

def main():
    print("🔍 PROBANDO API KEYS DE SUPABASE")
    print("=" * 50)
    
    working_keys = []
    
    for key_name, api_key in KEYS_TO_TEST.items():
        success, count = test_supabase_key(key_name, api_key)
        if success:
            working_keys.append((key_name, api_key, count))
    
    print("\n" + "=" * 50)
    print("🎯 RESUMEN:")
    
    if working_keys:
        print(f"✅ {len(working_keys)} keys funcionan:")
        for key_name, key, count in working_keys:
            print(f"   - {key_name}: {count} órdenes")
        
        # Recomendar la mejor key
        best_key = max(working_keys, key=lambda x: x[2])
        print(f"\n🏆 MEJOR KEY: {best_key[0]} (con {best_key[2]} órdenes)")
        print(f"🔑 Key recomendada: {best_key[1]}")
        
    else:
        print("❌ NINGUNA KEY FUNCIONA - Problema grave con Supabase")

if __name__ == "__main__":
    main()
