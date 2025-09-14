#!/usr/bin/env python3
"""
Script simple para verificar el saldo del usuario Lander
"""

import requests
import json

# URL del backend (asumiendo que está corriendo)
BACKEND_URL = "https://cubalink23-backend.onrender.com"

def test_balance_display():
    """Verificar el saldo del usuario Lander"""
    try:
        print("🔍 === VERIFICANDO SALDO DE LANDER ===")
        
        # Hacer petición al backend para obtener datos del usuario
        response = requests.get(f"{BACKEND_URL}/api/user/profile", timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Respuesta del backend:")
            print(f"   - Usuario: {data.get('name', 'N/A')}")
            print(f"   - Email: {data.get('email', 'N/A')}")
            print(f"   - Saldo: ${data.get('balance', 'N/A')}")
        else:
            print(f"❌ Error del backend: {response.status_code}")
            print(f"   Respuesta: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Error de conexión: {e}")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_balance_display()


