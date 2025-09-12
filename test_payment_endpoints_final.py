#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de prueba para verificar que los endpoints de pagos Square funcionen correctamente
"""

import requests
import json
from datetime import datetime

def test_payment_endpoints():
    """Probar todos los endpoints de pagos"""
    
    # URL base del servidor local
    base_url = "http://localhost:10000"
    
    print("🧪 PROBANDO ENDPOINTS DE PAGOS SQUARE")
    print("=" * 50)
    
    # 1. Probar endpoint de salud
    print("\n1️⃣ Probando endpoint de salud...")
    try:
        response = requests.get(f"{base_url}/api/health")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Servidor funcionando")
            print(f"   📋 Endpoints disponibles: {len(data.get('endpoints', []))}")
        else:
            print(f"   ❌ Error en salud del servidor")
    except Exception as e:
        print(f"   ❌ Error conectando: {e}")
        return
    
    # 2. Probar endpoint de estado de Square
    print("\n2️⃣ Probando estado de Square...")
    try:
        response = requests.get(f"{base_url}/api/payments/square-status")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Square configurado: {data.get('configured', False)}")
            print(f"   🌍 Ambiente: {data.get('environment', 'unknown')}")
        else:
            print(f"   ❌ Error en estado de Square")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    # 3. Probar endpoint de procesamiento de pago
    print("\n3️⃣ Probando procesamiento de pago...")
    try:
        test_payment = {
            "amount": 1000,  # $10.00 en centavos
            "currency": "USD",
            "source_id": "cnon:card-nonce-ok",  # Nonce de prueba
            "idempotency_key": f"test-{datetime.now().timestamp()}"
        }
        
        response = requests.post(
            f"{base_url}/api/payments/process",
            json=test_payment,
            headers={'Content-Type': 'application/json'}
        )
        
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Pago procesado exitosamente")
            print(f"   💰 ID de pago: {data.get('payment_id', 'N/A')}")
        else:
            print(f"   ❌ Error en procesamiento: {response.text}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    # 4. Probar endpoint de test
    print("\n4️⃣ Probando endpoint de test...")
    try:
        response = requests.get(f"{base_url}/api/payments/test")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Test exitoso: {data.get('message', 'N/A')}")
        else:
            print(f"   ❌ Error en test")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    print("\n" + "=" * 50)
    print("🏁 PRUEBA COMPLETADA")

if __name__ == "__main__":
    test_payment_endpoints()








