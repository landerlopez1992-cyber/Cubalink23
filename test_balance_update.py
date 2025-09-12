#!/usr/bin/env python3
"""
Script para probar la actualización de saldo después del pago
"""

import requests
import json
import time

def test_balance_update():
    """Probar que el saldo se actualiza correctamente después del pago"""
    
    print("🧪 === PRUEBA DE ACTUALIZACIÓN DE SALDO ===")
    
    # URL del backend
    backend_url = "https://cubalink23-backend.onrender.com"
    
    # Datos de prueba
    test_user_id = "test_user_123"
    test_amount = 50.0
    
    print(f"💰 Probando actualización de saldo para usuario: {test_user_id}")
    print(f"💰 Monto a agregar: ${test_amount}")
    
    # Simular pago exitoso
    payment_data = {
        "user_id": test_user_id,
        "amount": test_amount,
        "payment_method": "square",
        "transaction_id": f"SQ_TEST_{int(time.time())}",
        "status": "completed"
    }
    
    try:
        # Hacer petición al endpoint de pago
        response = requests.post(
            f"{backend_url}/api/payments/process",
            json=payment_data,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        if response.status_code == 200:
            print("✅ Pago procesado exitosamente")
            result = response.json()
            print(f"📊 Resultado: {result}")
            
            # Verificar que el saldo se actualizó
            time.sleep(2)  # Esperar un poco
            
            # Hacer petición para verificar el saldo
            balance_response = requests.get(
                f"{backend_url}/api/users/{test_user_id}/balance",
                timeout=30
            )
            
            if balance_response.status_code == 200:
                balance_data = balance_response.json()
                print(f"💰 Saldo actual: {balance_data}")
            else:
                print(f"❌ Error verificando saldo: {balance_response.status_code}")
                
        else:
            print(f"❌ Error procesando pago: {response.status_code}")
            print(f"📄 Respuesta: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Error de conexión: {e}")
    except Exception as e:
        print(f"❌ Error inesperado: {e}")

def test_square_connection():
    """Probar conexión con Square"""
    
    print("\n🔗 === PRUEBA DE CONEXIÓN CON SQUARE ===")
    
    backend_url = "https://cubalink23-backend.onrender.com"
    
    try:
        response = requests.get(
            f"{backend_url}/api/payments/square-status",
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Conexión con Square exitosa")
            print(f"📊 Estado: {result}")
        else:
            print(f"❌ Error conectando con Square: {response.status_code}")
            print(f"📄 Respuesta: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Error de conexión: {e}")
    except Exception as e:
        print(f"❌ Error inesperado: {e}")

if __name__ == "__main__":
    print("🚀 Iniciando pruebas de actualización de saldo...")
    
    # Probar conexión con Square
    test_square_connection()
    
    # Probar actualización de saldo
    test_balance_update()
    
    print("\n✅ Pruebas completadas")



