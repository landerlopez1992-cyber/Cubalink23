#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import requests
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv('config.env.backup')

def test_square():
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
    
    print("Testing Square API connection...")
    print("Base URL:", base_url)
    print("Environment:", environment)
    
    try:
        response = requests.get(base_url + '/v2/locations', headers=headers)
        print("Status Code:", response.status_code)
        
        if response.status_code == 200:
            data = response.json()
            locations = data.get('locations', [])
            print("Success! Found", len(locations), "locations")
            for loc in locations:
                print("-", loc.get('name'), "ID:", loc.get('id'))
        else:
            print("Error:", response.text)
            
    except Exception as e:
        print("Exception:", str(e))

if __name__ == "__main__":
    test_square()



