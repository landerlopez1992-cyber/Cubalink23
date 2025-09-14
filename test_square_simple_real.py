#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script simple para crear transacción REAL con Square API
"""

import requests
import json
import uuid
from datetime import datetime

# Credenciales reales de Square Sandbox
SQUARE_ACCESS_TOKEN = 'EAAAl4WnC2APxLhZXN1HJrn5CPWQGd-wXe_PpQm6vPvdOBHj1xWINxP3s7uOpvYO'
SQUARE_LOCATION_ID = 'LZVTP0YQ9YQBB'
BASE_URL = 'https://connect.squareupsandbox.com'

def crear_transaccion_real():
    """Crear transacción REAL con Square"""
    print('🔥 CREANDO TRANSACCION REAL CON SQUARE')
    print('=' * 50)
    
    # Datos del pago para Lander López
    amount = 2035  # $20.35 en centavos
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    print('💰 Monto: 20.35 USD')
    print('👤 Usuario: Lander López')
    print('📅 Timestamp: ' + timestamp)
    
    # Headers
    headers = {
        'Authorization': 'Bearer ' + SQUARE_ACCESS_TOKEN,
        'Content-Type': 'application/json',
        'Square-Version': '2024-12-01',
    }
    
    # Datos del pago
    payment_data = {
        'idempotency_key': str(uuid.uuid4()),
        'checkout_options': {
            'ask_for_shipping_address': False,
        },
        'order': {
            'location_id': SQUARE_LOCATION_ID,
            'reference_id': 'LANDER_LOPEZ_' + timestamp,
            'line_items': [
                {
                    'name': 'Recarga de Saldo Cubalink23',
                    'quantity': '1',
                    'item_type': 'ITEM',
                    'base_price_money': {
                        'amount': amount,
                        'currency': 'USD'
                    }
                }
            ]
        },
        'redirect_url': 'https://cubalink23.com/payment-success',
        'note': 'Recarga para usuario: Lander López'
    }
    
    print('\n📤 ENVIANDO A SQUARE...')
    print('🔗 URL: ' + BASE_URL + '/v2/online-checkout/payment-links')
    print('🆔 ID: ' + payment_data['idempotency_key'])
    
    try:
        # Solicitud real a Square
        response = requests.post(
            BASE_URL + '/v2/online-checkout/payment-links',
            headers=headers,
            json=payment_data,
            timeout=30
        )
        
        print('\n📊 RESPUESTA DE SQUARE:')
        print('Status Code: ' + str(response.status_code))
        
        if response.status_code == 200:
            result = response.json()
            payment_link = result.get('payment_link', {})
            
            print('\n✅ TRANSACCION CREADA EXITOSAMENTE!')
            print('🆔 Payment Link ID: ' + str(payment_link.get('id', 'N/A')))
            print('🔗 URL: ' + str(payment_link.get('url', 'N/A')))
            print('💰 Total: ' + str(payment_link.get('order', {}).get('total_money', {}).get('amount', 0) / 100) + ' USD')
            print('📅 Creado: ' + str(payment_link.get('created_at', 'N/A')))
            
            # Guardar detalles
            with open('square_transaction_lander.json', 'w') as f:
                json.dump(result, f, indent=2)
            
            print('\n💾 Detalles guardados en: square_transaction_lander.json')
            print('\n🎯 ESTA TRANSACCION APARECERA EN LOS LOGS DE SQUARE')
            print('👤 Usuario: Lander López')
            print('💰 Monto: $20.35')
            print('🆔 ID: ' + str(payment_link.get('id', 'N/A')))
            
            return payment_link.get('id')
            
        else:
            print('\n❌ ERROR EN LA SOLICITUD:')
            print('Status: ' + str(response.status_code))
            print('Error: ' + response.text)
            return None
            
    except Exception as e:
        print('\n❌ ERROR DE CONEXION: ' + str(e))
        return None

if __name__ == '__main__':
    print('🚀 INICIANDO PRUEBA REAL CON SQUARE API')
    print('👤 Usuario: Lander López')
    print('💰 Monto: $20.35')
    print('🔗 Environment: Sandbox')
    print()
    
    # Crear transacción real
    payment_id = crear_transaccion_real()
    
    if payment_id:
        print('\n🎉 TRANSACCION REAL CREADA EN SQUARE')
        print('🆔 ID: ' + str(payment_id))
        print('📊 Revisa los logs de Square para ver esta transaccion')
        print('🔗 Dashboard: https://squareup.com/dashboard/items')
    else:
        print('\n❌ No se pudo crear la transaccion')



