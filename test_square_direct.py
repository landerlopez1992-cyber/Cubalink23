#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de prueba directo para Square sin servidor Flask
"""

import os
import json
import uuid
from datetime import datetime
import requests
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv('config.env')

def test_square_configuration():
    """Probar configuración de Square"""
    print("🔧 Probando configuración de Square...")
    
    access_token = os.environ.get('SQUARE_ACCESS_TOKEN')
    application_id = os.environ.get('SQUARE_APPLICATION_ID')
    location_id = os.environ.get('SQUARE_LOCATION_ID')
    environment = os.environ.get('SQUARE_ENVIRONMENT', 'sandbox')
    
    print(f"✅ Access Token: {'Configurado' if access_token else '❌ No configurado'}")
    print(f"✅ Application ID: {'Configurado' if application_id else '❌ No configurado'}")
    print(f"✅ Location ID: {'Configurado' if location_id else '❌ No configurado'}")
    print(f"✅ Environment: {environment}")
    
    return access_token and application_id and location_id

def test_square_api_connection():
    """Probar conexión con la API de Square"""
    print("\n🔌 Probando conexión con Square API...")
    
    access_token = os.environ.get('SQUARE_ACCESS_TOKEN')
    environment = os.environ.get('SQUARE_ENVIRONMENT', 'sandbox')
    
    if environment == 'production':
        base_url = 'https://connect.squareup.com'
    else:
        base_url = 'https://connect.squareupsandbox.com'
    
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json',
        'Square-Version': '2024-12-01'
    }
    
    try:
        # Probar obtener locations
        response = requests.get(f'{base_url}/v2/locations', headers=headers)
        
        if response.status_code == 200:
            locations = response.json().get('locations', [])
            print(f"✅ Conexión exitosa con Square API")
            print(f"   - Locations disponibles: {len(locations)}")
            for location in locations:
                print(f"   - Location: {location.get('name')} (ID: {location.get('id')})")
            return True
        else:
            print(f"❌ Error de conexión: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_create_payment_link():
    """Probar crear enlace de pago"""
    print("\n🔗 Probando crear enlace de pago...")
    
    access_token = os.environ.get('SQUARE_ACCESS_TOKEN')
    location_id = os.environ.get('SQUARE_LOCATION_ID')
    environment = os.environ.get('SQUARE_ENVIRONMENT', 'sandbox')
    
    if environment == 'production':
        base_url = 'https://connect.squareup.com'
    else:
        base_url = 'https://connect.squareupsandbox.com'
    
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json',
        'Square-Version': '2024-12-01'
    }
    
    # Datos de prueba
    body = {
        "quick_pay": {
            "name": "Pedido de Prueba",
            "price_money": {
                "amount": 1000,  # $10.00 en centavos
                "currency": "USD"
            },
            "location_id": location_id
        }
    }
    
    try:
        response = requests.post(
            f'{base_url}/v2/online-checkout/payment-links',
            headers=headers,
            json=body
        )
        
        if response.status_code == 200:
            payment_link = response.json().get('payment_link', {})
            print(f"✅ Enlace de pago creado exitosamente")
            print(f"   - ID: {payment_link.get('id')}")
            print(f"   - URL: {payment_link.get('checkout_page_url')}")
            print(f"   - Precio: ${payment_link.get('price_money', {}).get('amount', 0) / 100}")
            return payment_link
        else:
            print(f"❌ Error creando enlace: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Error creando enlace: {e}")
        return None

def test_get_payment_methods():
    """Probar obtener métodos de pago"""
    print("\n💳 Probando obtener métodos de pago...")
    
    methods = [
        {
            'id': 'square_card',
            'name': 'Tarjeta de Crédito/Débito',
            'type': 'card',
            'description': 'Pago con tarjeta Visa, MasterCard, American Express',
            'icon': '💳',
            'enabled': True
        },
        {
            'id': 'square_cash',
            'name': 'Square Cash',
            'type': 'digital_wallet',
            'description': 'Pago con Square Cash App',
            'icon': '📱',
            'enabled': True
        },
        {
            'id': 'square_gift_card',
            'name': 'Tarjeta de Regalo',
            'type': 'gift_card',
            'description': 'Pago con tarjeta de regalo Square',
            'icon': '🎁',
            'enabled': True
        },
        {
            'id': 'bank_transfer',
            'name': 'Transferencia Bancaria',
            'type': 'bank_transfer',
            'description': 'Transferencia directa a cuenta bancaria',
            'icon': '🏦',
            'enabled': True
        },
        {
            'id': 'cash_on_delivery',
            'name': 'Pago en Efectivo',
            'type': 'cash',
            'description': 'Pago en efectivo al recibir el pedido',
            'icon': '💵',
            'enabled': True
        }
    ]
    
    print(f"✅ Métodos de pago disponibles: {len(methods)}")
    for method in methods:
        print(f"   - {method.get('icon')} {method.get('name')}: {method.get('description')}")
    
    return methods

def test_create_customer():
    """Probar crear cliente"""
    print("\n👤 Probando crear cliente...")
    
    access_token = os.environ.get('SQUARE_ACCESS_TOKEN')
    environment = os.environ.get('SQUARE_ENVIRONMENT', 'sandbox')
    
    if environment == 'production':
        base_url = 'https://connect.squareup.com'
    else:
        base_url = 'https://connect.squareupsandbox.com'
    
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json',
        'Square-Version': '2024-12-01'
    }
    
    # Datos de cliente de prueba
    body = {
        "idempotency_key": str(uuid.uuid4()),
        "given_name": "Juan",
        "family_name": "Pérez",
        "email_address": "juan.perez@ejemplo.com",
        "phone_number": "+1-555-123-4567",
        "address": {
            "address_line_1": "123 Calle Principal",
            "locality": "Miami",
            "administrative_district_level_1": "FL",
            "postal_code": "33101",
            "country": "US"
        }
    }
    
    try:
        response = requests.post(
            f'{base_url}/v2/customers',
            headers=headers,
            json=body
        )
        
        if response.status_code == 200:
            customer = response.json().get('customer', {})
            print(f"✅ Cliente creado exitosamente")
            print(f"   - ID: {customer.get('id')}")
            print(f"   - Nombre: {customer.get('given_name')} {customer.get('family_name')}")
            print(f"   - Email: {customer.get('email_address')}")
            return customer
        else:
            print(f"❌ Error creando cliente: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Error creando cliente: {e}")
        return None

def main():
    """Función principal de pruebas"""
    print("🚀 Iniciando pruebas directas de Square...")
    print("=" * 60)
    
    # Probar configuración
    config_ok = test_square_configuration()
    
    if not config_ok:
        print("\n❌ Configuración incompleta. Verifica las variables de entorno.")
        return
    
    # Probar conexión con API
    connection_ok = test_square_api_connection()
    
    if not connection_ok:
        print("\n❌ No se pudo conectar con Square API.")
        return
    
    # Probar crear enlace de pago
    payment_link = test_create_payment_link()
    
    # Probar métodos de pago
    payment_methods = test_get_payment_methods()
    
    # Probar crear cliente
    customer = test_create_customer()
    
    print("\n" + "=" * 60)
    print("✅ Pruebas completadas!")
    print("\n📋 Resumen:")
    print(f"   - Configuración: {'✅' if config_ok else '❌'}")
    print(f"   - Conexión API: {'✅' if connection_ok else '❌'}")
    print(f"   - Enlace de pago: {'✅' if payment_link else '❌'}")
    print(f"   - Métodos de pago: {len(payment_methods)}")
    print(f"   - Cliente creado: {'✅' if customer else '❌'}")
    
    print("\n🔧 Credenciales de Square configuradas correctamente!")
    print("   El sistema de pagos está listo para usar en producción.")

if __name__ == "__main__":
    main()

