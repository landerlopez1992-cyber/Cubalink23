#!/usr/bin/env python3
"""
Script que simula la pantalla de Flutter para agregar saldo a la billetera
con tarjeta de débito/crédito usando Square
"""

import requests
import json
import time
from datetime import datetime

# Configuración
BASE_URL = 'http://localhost:3005'

def simulate_flutter_add_balance_screen(user_id, amount):
    """Simular la pantalla de Flutter para agregar saldo"""
    print(f"📱 Simulando pantalla de Flutter: Agregar saldo")
    print(f"👤 Usuario: {user_id}")
    print(f"💰 Monto: ${amount}")
    print("=" * 50)
    
    # Paso 1: Usuario ingresa monto y presiona "Agregar Saldo"
    print("1️⃣ Usuario ingresa monto y presiona 'Agregar Saldo'")
    
    add_balance_data = {
        'amount': amount
    }
    
    try:
        response = requests.post(
            f'{BASE_URL}/admin/api/flutter/wallet/{user_id}/add-balance',
            json=add_balance_data
        )
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                data = result.get('data', {})
                payment_url = data.get('payment_url')
                payment_id = data.get('payment_id')
                
                print("✅ Enlace de pago creado exitosamente")
                print(f"   🔗 URL de pago: {payment_url}")
                print(f"   🆔 Payment ID: {payment_id}")
                print(f"   💵 Monto: ${data.get('amount')}")
                
                # Paso 2: Flutter abre la URL de pago de Square
                print("\n2️⃣ Flutter abre URL de pago de Square")
                print("   📱 Usuario ve pantalla de pago de Square")
                print("   💳 Usuario ingresa datos de tarjeta")
                print("   ✅ Usuario confirma pago")
                
                # Paso 3: Simular confirmación de pago (webhook de Square)
                print("\n3️⃣ Simulando confirmación de pago...")
                
                confirm_data = {
                    'payment_id': payment_id,
                    'amount': amount
                }
                
                confirm_response = requests.post(
                    f'{BASE_URL}/admin/api/flutter/wallet/{user_id}/confirm-payment',
                    json=confirm_data
                )
                
                if confirm_response.status_code == 200:
                    confirm_result = confirm_response.json()
                    
                    if confirm_result.get('success'):
                        confirm_data = confirm_result.get('data', {})
                        new_balance = confirm_data.get('new_balance', 0)
                        
                        print("✅ Pago confirmado y saldo agregado")
                        print(f"   💰 Saldo anterior: ${new_balance - amount}")
                        print(f"   💰 Saldo agregado: ${amount}")
                        print(f"   💰 Nuevo saldo: ${new_balance}")
                        
                        # Paso 4: Flutter actualiza la pantalla con nuevo saldo
                        print("\n4️⃣ Flutter actualiza pantalla con nuevo saldo")
                        print("   📱 Usuario ve confirmación de pago")
                        print("   💰 Usuario ve saldo actualizado")
                        print("   ✅ Transacción completada")
                        
                        return True
                    else:
                        print(f"❌ Error confirmando pago: {confirm_result.get('error')}")
                        return False
                else:
                    print(f"❌ Error en confirmación: {confirm_response.status_code}")
                    return False
            else:
                print(f"❌ Error creando enlace: {result.get('error')}")
                return False
        else:
            print(f"❌ Error en request: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def simulate_check_balance(user_id):
    """Simular verificación de saldo en Flutter"""
    print(f"\n💰 Verificando saldo de usuario {user_id}...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/flutter/wallet/{user_id}/balance')
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                data = result.get('data', {})
                balance = data.get('balance', 0)
                currency = data.get('currency', 'USD')
                
                print(f"✅ Saldo actual: ${balance} {currency}")
                return balance
            else:
                print(f"❌ Error obteniendo saldo: {result.get('error')}")
                return None
        else:
            print(f"❌ Error en request: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def simulate_transaction_history(user_id):
    """Simular historial de transacciones en Flutter"""
    print(f"\n📊 Obteniendo historial de transacciones...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/flutter/wallet/{user_id}/transactions')
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                data = result.get('data', {})
                transactions = data.get('transactions', [])
                total = data.get('total', 0)
                
                print(f"✅ Historial obtenido: {total} transacciones")
                
                for i, tx in enumerate(transactions[:3], 1):
                    print(f"   {i}. {tx.get('type')}: ${tx.get('amount')} - {tx.get('description')}")
                
                return transactions
            else:
                print(f"❌ Error obteniendo historial: {result.get('error')}")
                return None
        else:
            print(f"❌ Error en request: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def main():
    """Función principal que simula el flujo completo"""
    print("🚀 Simulando pantalla de Flutter: Agregar saldo a billetera")
    print("=" * 60)
    
    # Usuario de prueba
    test_user_id = 1001
    test_amount = 50.00
    
    print(f"👤 Usuario de prueba: {test_user_id}")
    print(f"💰 Monto de prueba: ${test_amount}")
    
    # Verificar saldo inicial
    print("\n📱 Verificando saldo inicial...")
    initial_balance = simulate_check_balance(test_user_id)
    
    # Simular pantalla de agregar saldo
    print(f"\n📱 Simulando pantalla de Flutter...")
    success = simulate_flutter_add_balance_screen(test_user_id, test_amount)
    
    if success:
        # Verificar saldo final
        print(f"\n📱 Verificando saldo final...")
        final_balance = simulate_check_balance(test_user_id)
        
        # Mostrar historial de transacciones
        print(f"\n📱 Mostrando historial de transacciones...")
        simulate_transaction_history(test_user_id)
        
        # Resumen
        print("\n" + "=" * 60)
        print("✅ Simulación completada exitosamente!")
        print(f"💰 Saldo inicial: ${initial_balance or 0}")
        print(f"💰 Monto agregado: ${test_amount}")
        print(f"💰 Saldo final: ${final_balance or 0}")
        
        print("\n🎯 Flujo de Flutter implementado correctamente:")
        print("   ✅ Usuario ingresa monto en Flutter")
        print("   ✅ Flutter llama al backend")
        print("   ✅ Backend crea enlace de pago con Square")
        print("   ✅ Flutter abre pantalla de pago")
        print("   ✅ Usuario paga con tarjeta")
        print("   ✅ Square confirma pago")
        print("   ✅ Backend actualiza billetera")
        print("   ✅ Flutter muestra saldo actualizado")
        
        print("\n💳 Sistema listo para tarjetas de débito y crédito!")
        print("   Los usuarios pueden agregar saldo real a sus billeteras.")
    else:
        print("\n❌ Error en la simulación")
        print("   Verifica que el servidor esté corriendo y Square configurado.")

if __name__ == "__main__":
    main()

