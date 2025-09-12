#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import requests
import json
import os
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

def test_duffel_api():
    """Probar API de Duffel directamente"""
    try:
        # Obtener API key
        api_token = os.environ.get('DUFFEL_API_KEY')
        if not api_token:
            print("ERROR: DUFFEL_API_KEY no configurada")
            return
            
        print("API Key encontrada, probando Duffel API...")
        
        # Headers para Duffel API
        headers = {
            'Accept': 'application/json',
            'Authorization': 'Bearer {}'.format(api_token),
            'Duffel-Version': 'v1',
            'Content-Type': 'application/json'
        }
        
        # Crear offer request
        url = 'https://api.duffel.com/air/offer_requests'
        payload = {
            "data": {
                "slices": [{
                    "origin": "MIA",
                    "destination": "HAV",
                    "departure_date": "2024-12-31"
                }],
                "passengers": [{"type": "adult"}],
                "cabin_class": "economy"
            }
        }
        
        print("Enviando request a Duffel...")
        response = requests.post(url, headers=headers, json=payload, timeout=30)
        print("Status: {}".format(response.status_code))
        
        if response.status_code == 201:
            offer_request = response.json()
            offer_request_id = offer_request['data']['id']
            print("Offer request creado: {}".format(offer_request_id))
            
            # Obtener ofertas
            offers_url = 'https://api.duffel.com/air/offers'
            params = {'offer_request_id': offer_request_id}
            
            print("Obteniendo ofertas...")
            offers_response = requests.get(offers_url, headers=headers, params=params, timeout=30)
            print("Status ofertas: {}".format(offers_response.status_code))
            
            if offers_response.status_code == 200:
                offers_data = offers_response.json()
                offers = offers_data.get('data', [])
                print("Ofertas encontradas: {}".format(len(offers)))
                
                if offers:
                    offer = offers[0]
                    print("\nPrimera oferta:")
                    print("ID: {}".format(offer.get('id')))
                    print("Total amount: {}".format(offer.get('total_amount')))
                    print("Currency: {}".format(offer.get('total_currency')))
                    
                    # Extraer información de aerolínea
                    if offer.get('slices') and len(offer['slices']) > 0:
                        slice_data = offer['slices'][0]
                        if slice_data.get('segments') and len(slice_data['segments']) > 0:
                            first_segment = slice_data['segments'][0]
                            
                            # Marketing carrier
                            if first_segment.get('marketing_carrier'):
                                carrier = first_segment['marketing_carrier']
                                print("Aerolinea: {}".format(carrier.get('name', 'N/A')))
                                print("Codigo: {}".format(carrier.get('iata_code', 'N/A')))
                                print("Logo: {}".format(carrier.get('logo_symbol_url', 'N/A')))
                            
                            # Operating carrier
                            if first_segment.get('operating_carrier'):
                                carrier = first_segment['operating_carrier']
                                print("Aerolinea operadora: {}".format(carrier.get('name', 'N/A')))
                                print("Codigo operador: {}".format(carrier.get('iata_code', 'N/A')))
            else:
                print("Error obteniendo ofertas: {}".format(offers_response.text))
        else:
            print("Error creando offer request: {}".format(response.text))
            
    except Exception as e:
        print("Error: {}".format(e))
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_duffel_api()
