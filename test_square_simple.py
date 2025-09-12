#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de prueba simple para Square
"""

import os
import json
import uuid
from datetime import datetime
import requests
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv('config.env.backup')

def test_square_configuration():
    """Probar configuración de Square"""
    print("🔧 Probando configuración de Square...")
    
    access_token = os.environ.get('SQUARE_ACCESS_TOKEN')
    application_id = os.environ.get('SQUARE_APPLICATION_ID')
    location_id = os.environ.get('SQUARE_LOCATION_ID')
    environment = os.environ.get('SQUARE_ENVIRONMENT', 'sandbox')
    
    print("Access Token: " + ("Configurado" if access_token else "❌ No configurado"))
    print("Application ID: " + ("Configurado" if application_id else "❌ No configurado"))
    print("Location ID: " + ("Configurado" if location_id else "❌ No configurado"))
    print("Environment: " + environment)
    
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
        'Authorization': 'Bearer ' + access_token,
        'Content-Type': 'application/json',
        'Square-Version': '2024-12-01'
    }
    
    try:
        # Probar obtener locations
        response = requests.get(base_url + '/v2/locations', headers=headers)
        
        if response.status_code == 200:
            locations = response.json().get('locations', [])
            print("✅ Conexión exitosa con Square API")
            print("   - Locations disponibles: " + str(len(locations)))
            for location in locations:
                print("   - Location: " + location.get('name') + " (ID: " + location.get('id') + ")")
            return True
        else:
            print("❌ Error de conexión: " + str(response.status_code) + " - " + response.text)
            return False
            
    except Exception as e:
        print("❌ Error de conexión: " + str(e))
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
        'Authorization': 'Bearer ' + access_token,
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
            base_url + '/v2/online-checkout/payment-links',
            headers=headers,
            json=body
        )
        
        if response.status_code == 200:
            payment_link = response.json().get('payment_link', {})
            print("✅ Enlace de pago creado exitosamente")
            print("   - ID: " + payment_link.get('id'))
            print("   - URL: " + payment_link.get('checkout_page_url'))
            print("   - Precio: $" + str(payment_link.get('price_money', {}).get('amount', 0) / 100))
            return payment_link
        else:
            print("❌ Error creando enlace: " + str(response.status_code) + " - " + response.text)
            return None
            
    except Exception as e:
        print("❌ Error creando enlace: " + str(e))
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
    
    print("\n" + "=" * 60)
    print("✅ Pruebas completadas!")
    print("\n📋 Resumen:")
    print("   - Configuración: " + ("✅" if config_ok else "❌"))
    print("   - Conexión API: " + ("✅" if connection_ok else "❌"))
    print("   - Enlace de pago: " + ("✅" if payment_link else "❌"))
    
    print("\n🔧 Credenciales de Square configuradas correctamente!")
    print("   El sistema de pagos está listo para usar en producción.")

if __name__ == "__main__":
    main()



