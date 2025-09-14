#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import requests
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv('config.env.backup')

def test_create_payment_link():
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
            "name": "Pedido de Prueba Cubalink23",
            "price_money": {
                "amount": 1000,  # $10.00 en centavos
                "currency": "USD"
            },
            "location_id": location_id
        }
    }
    
    print("Testing Square Payment Link creation...")
    print("Base URL:", base_url)
    print("Location ID:", location_id)
    print("Amount: $10.00")
    
    try:
        response = requests.post(
            base_url + '/v2/online-checkout/payment-links',
            headers=headers,
            json=body
        )
        
        print("Status Code:", response.status_code)
        
        if response.status_code == 200:
            response_data = response.json()
            print("📡 Respuesta completa:", response_data)
            payment_link = response_data.get('payment_link', {})
            print("✅ Enlace de pago creado exitosamente!")
            print("ID:", payment_link.get('id'))
            print("URL:", payment_link.get('url'))
            print("Long URL:", payment_link.get('long_url'))
            print("Precio: $" + str(payment_link.get('price_money', {}).get('amount', 0) / 100))
            return payment_link
        else:
            print("❌ Error creando enlace:", response.text)
            return None
            
    except Exception as e:
        print("❌ Error:", str(e))
        return None

if __name__ == "__main__":
    test_create_payment_link()



