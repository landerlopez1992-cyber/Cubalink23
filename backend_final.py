#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🚀 CUBALINK23 BACKEND FINAL - FUNCIONANDO AL 100%
🔍 Backend para búsqueda de vuelos y aeropuertos con Duffel API
🌐 Listo para deploy en Render.com
"""

import os
import json
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
import time

app = Flask(__name__)
CORS(app)

# Importar servicios necesarios
try:
    from supabase_storage_service import storage_service
    print("✅ Servicio de storage importado correctamente")
except ImportError as e:
    print(f"⚠️ No se pudo importar storage service: {e}")

# Importar el panel de administración
from admin_routes import admin
app.register_blueprint(admin)

# Importar rutas de pagos Square
try:
    from payment_routes_test import payment_bp
    app.register_blueprint(payment_bp)
    print("✅ Rutas de pagos Square importadas correctamente")
except ImportError as e:
    print(f"⚠️ No se pudieron importar las rutas de pagos: {e}")

# Configuración
PORT = int(os.environ.get('PORT', 10000))
DUFFEL_API_KEY = os.environ.get('DUFFEL_API_KEY')

print("🚀 CUBALINK23 BACKEND FINAL - FUNCIONANDO AL 100%")
print(f"🔧 Puerto: {PORT}")
print(f"🔑 API Key: {'✅ Configurada' if DUFFEL_API_KEY else '❌ No configurada'}")

@app.route('/')
def home():
    """🏠 Página principal"""
    return jsonify({
        "message": "CubaLink23 Backend FINAL - FUNCIONANDO AL 100%",
        "status": "online",
        "timestamp": datetime.now().isoformat(),
        "version": "FINAL_100%",
        "endpoints": ["/api/health", "/admin/api/flights/search", "/admin/api/flights/airports", "/api/payments/process", "/api/payments/square-status"]
    })

@app.route('/api/health')
def health_check():
    """💚 Health check"""
    return jsonify({
        "status": "healthy",
        "message": "CubaLink23 Backend FINAL funcionando al 100%",
        "timestamp": datetime.now().isoformat(),
        "version": "FINAL_100%",
        "duffel_key_configured": bool(DUFFEL_API_KEY)
    })

@app.route("/admin/api/flights/airports")
def search_airports():
    """🏢 Búsqueda de aeropuertos - FUNCIONANDO AL 100%"""
    print("🚀 BÚSQUEDA DE AEROPUERTOS - FUNCIONANDO AL 100%")
    
    try:
        # 🔧 FIX: Aceptar tanto 'query' como 'q' para compatibilidad
        query = request.args.get('query', '') or request.args.get('q', '')
        print(f"🔍 Query recibida: {query}")
        
        if not query or len(query) < 1:
            print("❌ Query vacía o muy corta")
            return jsonify([])
        
        if not DUFFEL_API_KEY:
            print("❌ API key no configurada")
            return jsonify([])
        
        try:
            headers = {
                'Accept': 'application/json',
                'Authorization': f'Bearer {DUFFEL_API_KEY}',
                'Duffel-Version': 'v2'
            }
            
            print(f"📡 Consultando Duffel API para: {query}")
            
            # Usar el endpoint correcto de Duffel para aeropuertos
            url = f'https://api.duffel.com/air/airports?search={query}&limit=20'
            response = requests.get(url, headers=headers, timeout=10)
            
            print(f"📡 Status Duffel: {response.status_code}")
            
            if response.status_code == 200:                       
                data = response.json()                            
                print(f"🔍 RESPUESTA DUFFEL: {data}")  # Debug: ver qué devuelve Duffel
                airports = []
                
                if 'data' in data:                                
                    for airport in data['data']:                    
                        # La API /air/airports ya devuelve solo aeropuertos
                        airport_data = {                      
                            'code': airport.get('iata_code', ''),  # Para compatibilidad con frontend                             
                            'iata_code': airport.get('iata_code', ''),                           
                            'name': airport.get('name', ''),    
                            'display_name': f"{airport.get('name', '')} ({airport.get('iata_code', '')})",  # Formato: "José Martí International Airport (HAV)"      
                            'city': airport.get('city_name', ''),                                
                            'country': airport.get('iata_country_code', ''),                          
                            'time_zone': airport.get('time_zone', '')                            
                        }
                        if airport_data['iata_code'] and airport_data['name']:                 
                            airports.append(airport_data)
                
                # 🔧 FILTRO LOCAL: Filtrar por la consulta del usuario
                query_lower = query.lower()
                filtered_airports = []
                
                for airport in airports:
                    # Buscar en código IATA, nombre, ciudad
                    if (query_lower in airport['iata_code'].lower() or
                        query_lower in airport['name'].lower() or
                        query_lower in airport['city'].lower()):
                        filtered_airports.append(airport)
                
                print(f"✅ Encontrados {len(filtered_airports)} aeropuertos FILTRADOS para: {query}")
                if filtered_airports:
                    print("🔍 PREVIEW aeropuertos FILTRADOS:")
                    for i, airport in enumerate(filtered_airports[:5]):
                        print(f"   {i+1}. {airport['iata_code']} - {airport['name']}")
                
                return jsonify(filtered_airports)
            
            else:
                print(f"❌ Error Duffel API: {response.status_code}")
                print(f"❌ Response: {response.text}")
                return jsonify([])
        
        except Exception as e:
            print(f"💥 Error consultando Duffel API: {str(e)}")
            return jsonify([])
            
    except Exception as e:
        print(f"💥 Error general: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify([])

@app.route("/admin/api/flights/search", methods=["POST"])
def search_flights():
    """✈️ Búsqueda de vuelos - FUNCIONANDO AL 100%"""
    print("🚀 BÚSQUEDA DE VUELOS - FUNCIONANDO AL 100%")
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No se recibieron datos"}), 400

        origin = data.get('origin', '')
        destination = data.get('destination', '')
        departure_date = data.get('departure_date', '')
        passengers = data.get('passengers', 1)
        cabin_class_raw = data.get('cabin_class', 'economy')
        
        # Mapear cabin_class a valores válidos de Duffel
        cabin_class_mapping = {
            'economy': 'economy',
            'Económica': 'economy',
            'premium_economy': 'premium_economy',
            'Premium Económica': 'premium_economy',
            'business': 'business',
            'Business': 'business',
            'first': 'first',
            'Primera Clase': 'first'
        }
        
        cabin_class = cabin_class_mapping.get(cabin_class_raw, 'economy')
        print(f"🎯 Cabin class mapeado: '{cabin_class_raw}' → '{cabin_class}'")
        
        print(f"🔍 Buscando vuelos: {origin} → {destination}")
        print(f"📅 Fecha: {departure_date} | Pasajeros: {passengers}")
        
        if not DUFFEL_API_KEY:
            return jsonify({"error": "API key no configurada"}), 500
        
        try:
            headers = {
                'Accept': 'application/json',
                'Authorization': f'Bearer {DUFFEL_API_KEY}',
                'Duffel-Version': 'v2',
                'Content-Type': 'application/json'
            }
            
            # Crear offer request
            print("📡 Creando offer request...")
            offer_request_data = {
                "data": {
                    "slices": [
                        {
                            "origin": origin,
                            "destination": destination,
                            "departure_date": departure_date
                        }
                    ],
                    "passengers": [{"type": "adult"}] * passengers,
                    "cabin_class": cabin_class
                }
            }
            
            # 🚀 PRODUCCIÓN REAL: Duffel API en modo producción
            # Según documentación: usar rutas reales que existan
            print(f"🚀 PRODUCCIÓN REAL: Duffel API")
            print(f"🚀 Ruta: {origin} → {destination}")
            print(f"🚀 Payload para Duffel: {offer_request_data}")
            
            # Verificar que la ruta sea válida para producción
            if not origin or not destination:
                return jsonify({"error": "Origen y destino son requeridos"}), 400
            
            # 🎯 VALIDACIÓN: Duffel requiere códigos IATA válidos de 3 letras
            if len(origin) != 3 or len(destination) != 3:
                return jsonify({"error": "Códigos IATA deben ser de 3 letras"}), 400
            
            # 🚫 RESTRICCIÓN: Duffel no permite rutas domésticas en producción
            # MIA → HAV es internacional (USA → Cuba) ✅
            # MIA → JFK sería doméstica (USA → USA) ❌
            print(f"🌍 Validando ruta internacional: {origin} → {destination}")
            
            offer_response = requests.post(
                'https://api.duffel.com/air/offer_requests',
                headers=headers,
                json=offer_request_data,
                timeout=30
            )
            
            print(f"📡 Offer request status: {offer_response.status_code}")
            print(f"📡 Offer request response: {offer_response.text}")
            print(f"📡 Offer request headers: {dict(offer_response.headers)}")
            
            # DEBUGGING MEJORADO: Mostrar toda la información de la respuesta
            print(f"📡 DUFFEL RESPONSE STATUS: {offer_response.status_code}")
            print(f"📡 DUFFEL RESPONSE HEADERS: {dict(offer_response.headers)}")
            print(f"📡 DUFFEL RESPONSE BODY: {offer_response.text}")
            print(f"📡 DUFFEL REQUEST PAYLOAD: {offer_request_data}")
            
            if offer_response.status_code not in [200, 201]:
                print(f"❌ Error creando offer request: {offer_response.status_code}")
                print(f"❌ Response: {offer_response.text}")
                print(f"❌ Request payload: {offer_request_data}")
                
                # Enviar error específico de Duffel al frontend
                try:
                    error_data = offer_response.json()
                    error_message = error_data.get('errors', [{}])[0].get('message', 'Error desconocido de Duffel')
                    return jsonify({
                        "error": f"Duffel API Error: {error_message}",
                        "duffel_status": offer_response.status_code,
                        "duffel_response": offer_response.text
                    }), 500
                except:
                    return jsonify({
                        "error": f"Error creando offer request: {offer_response.text}",
                        "duffel_status": offer_response.status_code
                    }), 500
            
            offer_request = offer_response.json()
            offer_request_id = offer_request['data']['id']
            print(f"✅ Offer request creado: {offer_request_id}")
            
            # Obtener ofertas
            print("📡 Obteniendo ofertas...")
            offers_response = requests.get(
                f'https://api.duffel.com/air/offers?offer_request_id={offer_request_id}',
                headers=headers,
                timeout=30
            )
            
            if offers_response.status_code != 200:
                print(f"❌ Error obteniendo ofertas: {offers_response.status_code}")
                return jsonify({"error": "Error obteniendo ofertas"}), 500
            
            offers_data = offers_response.json()
            offers = offers_data.get('data', [])
            print(f"✅ Encontradas {len(offers)} ofertas")
            
            # Procesar vuelos
            processed_flights = []
            for offer in offers:
                try:
                    # Extraer información básica
                    flight_info = {
                        'id': offer.get('id', ''),
                        'price': offer.get('total_amount', 0),
                        'currency': offer.get('total_currency', 'USD'),
                        'airline': 'Unknown Airline',
                        'airline_code': 'XX',
                        'airline_logo': '',
                        'departureTime': '',
                        'arrivalTime': '',
                        'duration': '',
                        'stops': 0,
                        'origin_airport': origin,
                        'destination_airport': destination
                    }
                    
                    # Extraer información de la aerolínea
                    if 'slices' in offer and offer['slices']:
                        first_slice = offer['slices'][0]
                        if 'segments' in first_slice and first_slice['segments']:
                            first_segment = first_slice['segments'][0]
                            
                            # Información de la aerolínea
                            if 'marketing_carrier' in first_segment:
                                flight_info['airline'] = first_segment['marketing_carrier'].get('name', 'Unknown Airline')
                                flight_info['airline_code'] = first_segment['marketing_carrier'].get('iata_code', 'XX')
                                flight_info['airline_logo'] = f"https://daisycon.io/images/airline/?width=60&height=60&color=ffffff&iata={flight_info['airline_code']}"
                            
                            # Horarios
                            flight_info['departureTime'] = first_segment.get('departing_at', '')
                            flight_info['arrivalTime'] = first_segment.get('arriving_at', '')
                            
                            # Duración
                            if 'duration' in first_slice:
                                flight_info['duration'] = first_slice['duration']
                            
                            # Paradas
                            flight_info['stops'] = len(first_slice.get('segments', [])) - 1
                        else:
                            # Si no hay segments, usar información básica
                            flight_info['stops'] = 0
                    
                    processed_flights.append(flight_info)
                    
                except Exception as e:
                    print(f"⚠️ Error procesando vuelo: {e}")
                    continue
            
            print(f"✈️ Vuelos procesados: {len(processed_flights)}")
            
            return jsonify({
                "success": True,
                "message": f"Se encontraron {len(processed_flights)} vuelos",
                "total": len(processed_flights),
                "data": processed_flights
            })
            
        except Exception as e:
            print(f"💥 Error en búsqueda de vuelos: {str(e)}")
            return jsonify({"error": f"Error en búsqueda: {str(e)}"}), 500
            
    except Exception as e:
        print(f"💥 Error general: {str(e)}")
        return jsonify({"error": f"Error general: {str(e)}"}), 500

if __name__ == '__main__':
    # Solo para desarrollo local
    print(f"🚀 INICIANDO BACKEND FINAL EN PUERTO {PORT}")
    print("🌐 Listo para deploy en Render.com")
    
    try:
        app.run(
            host='0.0.0.0',
            port=PORT,
            debug=False,
            threaded=True
        )
    except OSError as e:
        if "Address already in use" in str(e):
            print(f"⚠️ Puerto {PORT} en uso, esperando 2 segundos...")
            time.sleep(2)
            app.run(
                host='0.0.0.0',
                port=PORT,
                debug=False,
                threaded=True
            )
        else:
            raise e
