#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import requests
import json

def test_flight_search():
    """Probar endpoint de búsqueda de vuelos"""
    url = 'https://cubalink23-backend.onrender.com/admin/api/flights/search'
    payload = {
        'origin': 'MIA',
        'destination': 'HAV', 
        'departure_date': '2024-12-31',
        'passengers': 1,
        'airline_type': 'comerciales'
    }

    try:
        print("Probando endpoint de busqueda de vuelos...")
        response = requests.post(url, json=payload, timeout=30)
        print("Status: {}".format(response.status_code))
        
        if response.status_code == 200:
            data = response.json()
            print("Success: {}".format(data.get('success')))
            print("Total flights: {}".format(data.get('total', 0)))
            
            if data.get('data') and len(data['data']) > 0:
                flight = data['data'][0]
                print("\nPrimer vuelo encontrado:")
                for key, value in flight.items():
                    print("  {}: {}".format(key, value))
            else:
                print("No hay vuelos en la respuesta")
        else:
            print("Error: {}".format(response.text))
            
    except Exception as e:
        print("Error: {}".format(e))

if __name__ == "__main__":
    test_flight_search()
