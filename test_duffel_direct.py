#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import os
sys.path.append('backend')

# Cargar variables de entorno
from dotenv import load_dotenv
load_dotenv()

from duffel_service import DuffelService

def test_duffel_direct():
    """Probar servicio Duffel directamente"""
    try:
        print("Inicializando DuffelService...")
        service = DuffelService()
        print("DuffelService inicializado correctamente")
        
        # Probar búsqueda de vuelos
        print("Buscando vuelos MIA -> HAV...")
        flights = service.search_flights('MIA', 'HAV', '2024-12-31', 1, 'economy')
        print("Vuelos encontrados: {}".format(len(flights)))
        
        if flights:
            flight = flights[0]
            print("\nPrimer vuelo:")
            for key, value in flight.items():
                print("  {}: {}".format(key, value))
        else:
            print("No se encontraron vuelos")
            
    except Exception as e:
        print("Error: {}".format(e))
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_duffel_direct()
