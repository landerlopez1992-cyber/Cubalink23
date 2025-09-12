#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para probar transacción REAL con Square API
Usando las credenciales reales proporcionadas
"""

import requests
import json
import uuid
from datetime import datetime

# Credenciales reales de Square Sandbox
SQUARE_ACCESS_TOKEN = 'EAAAl4WnC2APxLhZXN1HJrn5CPWQGd-wXe_PpQm6vPvdOBHj1xWINxP3s7uOpvYO'
SQUARE_APPLICATION_ID = 'sandbox-sq0idb-IsIJtKqx2OHdVJjYmg6puA'
SQUARE_LOCATION_ID = 'LZVTP0YQ9YQBB'
SQUARE_ENVIRONMENT = 'sandbox'
BASE_URL = 'https://connect.squareupsandbox.com'

def test_real_payment_link():
    """Crear enlace de pago REAL con Square"""
    print('🔥 CREANDO ENLACE DE PAGO REAL CON SQUARE')
    print('=' * 50)
    
    # Datos del pago
    amount = 2035  # $20.35 en centavos
    description = 'Recarga de saldo Cubalink23 - Usuario Lander López'
    
    print('💰 Monto: ${:.2f} USD'.format(amount/100))
    print('📝 Descripción: {}'.format(description))
    print('👤 Usuario: Lander López')
    
    # Headers para la API
    headers = {
        'Authorization': 'Bearer {}'.format(SQUARE_ACCESS_TOKEN),
        'Content-Type': 'application/json',
        'Square-Version': '2024-12-01',
    }
    
    # Datos para el enlace de pago
    payment_data = {
        'idempotency_key': str(uuid.uuid4()),
        'checkout_options': {
            'ask_for_shipping_address': False,
            'merchant_support_email': 'support@cubalink23.com',
        },
        'order': {
            'location_id': SQUARE_LOCATION_ID,
            'reference_id': f'LANDER_LOPEZ_{datetime.now().strftime("%Y%m%d_%H%M%S")}',
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
            ],
            'taxes': [
                {
                    'name': 'Costo de Procesamiento',
                    'type': 'ADDITIVE',
                    'percentage': '1.75',
                    'scope': 'ORDER'
                }
            ]
        },
        'pre_populate_buyer_email': 'lander.lopez@cubalink23.com',
        'pre_populate_shipping_address': {
            'address_line_1': '1600 Pennsylvania Ave NW',
            'locality': 'Washington',
            'administrative_district_level_1': 'DC',
            'postal_code': '20500',
            'country': 'US'
        },
        'redirect_url': 'https://cubalink23.com/payment-success',
        'note': f'Recarga para usuario: Lander López - {datetime.now().isoformat()}'
    }
    
    print('\n📤 ENVIANDO SOLICITUD A SQUARE...')
    print(f'🔗 URL: {BASE_URL}/v2/online-checkout/payment-links')
    print(f'🆔 Idempotency Key: {payment_data["idempotency_key"]}')
    print(f'📍 Location ID: {SQUARE_LOCATION_ID}')
    
    try:
        # Hacer la solicitud real a Square
        response = requests.post(
            '{}'.format(BASE_URL) + '/v2/online-checkout/payment-links',
            headers=headers,
            json=payment_data,
            timeout=30
        )
        
        print(f'\n📊 RESPUESTA DE SQUARE:')
        print(f'Status Code: {response.status_code}')
        print(f'Headers: {dict(response.headers)}')
        
        if response.status_code == 200:
            result = response.json()
            payment_link = result.get('payment_link', {})
            
            print(f'\n✅ ENLACE DE PAGO CREADO EXITOSAMENTE!')
            print(f'🆔 Payment Link ID: {payment_link.get("id")}')
            print(f'🔗 URL: {payment_link.get("url")}')
            print(f'📱 Long URL: {payment_link.get("long_url")}')
            print(f'💰 Precio: ${payment_link.get("order", {}).get("total_money", {}).get("amount", 0) / 100:.2f} USD')
            print(f'📅 Creado: {payment_link.get("created_at")}')
            print(f'🔄 Estado: {payment_link.get("payment_note")}')
            
            # Guardar detalles en archivo para referencia
            with open('square_transaction_details.json', 'w') as f:
                json.dump(result, f, indent=2)
            
            print(f'\n💾 Detalles guardados en: square_transaction_details.json')
            print(f'\n🎯 ESTA TRANSACCIÓN APARECERÁ EN LOS LOGS DE SQUARE')
            print(f'👤 Usuario: Lander López')
            print(f'💰 Monto: $20.35')
            print(f'🆔 ID: {payment_link.get("id")}')
            
            return payment_link.get("id")
            
        else:
            print(f'\n❌ ERROR EN LA SOLICITUD:')
            print(f'Status: {response.status_code}')
            print(f'Error: {response.text}')
            return None
            
    except Exception as e:
        print(f'\n❌ ERROR DE CONEXIÓN: {e}')
        return None

def check_payment_status(payment_link_id):
    """Verificar estado del pago"""
    if not payment_link_id:
        return
        
    print(f'\n🔍 VERIFICANDO ESTADO DEL PAGO: {payment_link_id}')
    
    headers = {
        'Authorization': 'Bearer {}'.format(SQUARE_ACCESS_TOKEN),
        'Content-Type': 'application/json',
        'Square-Version': '2024-12-01',
    }
    
    try:
        response = requests.get(
            f'{BASE_URL}/v2/online-checkout/payment-links/{payment_link_id}',
            headers=headers,
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            payment_link = result.get('payment_link', {})
            
            print(f'✅ Estado: {payment_link.get("payment_note", "Pendiente")}')
            print(f'💰 Total: {payment_link.get("order", {}).get("total_money", {}).get("amount", 0) / 100:.2f} USD')
            print(f'📅 Actualizado: {payment_link.get("updated_at")}')
            
        else:
            print(f'❌ Error verificando estado: {response.status_code}')
            
    except Exception as e:
        print(f'❌ Error: {e}')

if __name__ == '__main__':
    print('🚀 INICIANDO PRUEBA REAL CON SQUARE API')
    print('👤 Usuario: Lander López')
    print('💰 Monto: $20.35')
    print('🔗 Environment: Sandbox')
    print()
    
    # Crear enlace de pago real
    payment_id = test_real_payment_link()
    
    if payment_id:
        # Verificar estado
        check_payment_status(payment_id)
        
        print(f'\n🎉 TRANSACCIÓN REAL CREADA EN SQUARE')
        print(f'🆔 ID: {payment_id}')
        print(f'📊 Revisa los logs de Square para ver esta transacción')
        print(f'🔗 Dashboard: https://squareup.com/dashboard/items')
    else:
        print('\n❌ No se pudo crear la transacción')
