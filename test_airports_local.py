#!/usr/bin/env python3
import requests
import json

# API Key de Duffel
API_KEY = "duffel_live_Rj6u0G0cT2hUeIw53ou2HRTNNf0tXl6oP-pVzcGvI7e"

def search_airports(query):
    """Buscar aeropuertos usando la API de Duffel"""
    headers = {
        'Accept': 'application/json',
        'Authorization': f'Bearer {API_KEY}',
        'Duffel-Version': 'v2'
    }
    
    # Usar endpoint /places que funciona
    url = f'https://api.duffel.com/places?query={query}'
    
    try:
        response = requests.get(url, headers=headers, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            airports = []
            
            if 'data' in data:
                for place in data['data']:
                    if place.get('type') == 'airport':
                        airport_data = {
                            'code': place.get('iata_code', ''),
                            'iata_code': place.get('iata_code', ''),
                            'name': place.get('name', ''),
                            'display_name': f"{place.get('name', '')} ({place.get('iata_code', '')})",
                            'city': place.get('city_name', ''),
                            'country': place.get('iata_country_code', ''),
                            'time_zone': place.get('time_zone', '')
                        }
                        if airport_data['iata_code'] and airport_data['name']:
                            airports.append(airport_data)
            
            print(f"✅ Encontrados {len(airports)} aeropuertos para: {query}")
            for i, airport in enumerate(airports[:5]):
                print(f"   {i+1}. {airport['iata_code']} - {airport['name']}")
            
            return airports
        else:
            print(f"❌ Error: {response.status_code}")
            print(f"Response: {response.text}")
            return []
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return []

if __name__ == "__main__":
    # Probar con diferentes consultas
    queries = ["MIA", "HAV", "Miami", "Havana", "JFK"]
    
    for query in queries:
        print(f"\n🔍 Buscando: {query}")
        airports = search_airports(query)
        if airports:
            print(f"✅ {len(airports)} aeropuertos encontrados")
        else:
            print("❌ No se encontraron aeropuertos")
