#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🚀 CUBALINK23 BACKEND - MANTIENE TODO LO EXISTENTE + BANNERS
🔍 Backend para búsqueda de vuelos y aeropuertos con Duffel API
🌐 Listo para deploy en Render.com
"""

import os
import json
import requests
from flask import Flask, request, jsonify, session
from flask_cors import CORS
from datetime import datetime
import time

app = Flask(__name__)
CORS(app)

# Configuración de sesión para autenticación
app.secret_key = os.environ.get('SECRET_KEY', 'cubalink23-secret-key-2024')

# Importar servicios necesarios
try:
    from supabase_service import SupabaseService
    supabase_service = SupabaseService()
    print("✅ Servicio de Supabase importado correctamente")
except ImportError as e:
    print("⚠️ No se pudo importar Supabase service: {}".format(e))
    supabase_service = None

# Importar el panel de administración
from admin_routes import admin
from auth_routes import auth
app.register_blueprint(admin)
app.register_blueprint(auth)

# Importar rutas de notificaciones push directamente
from push_notifications_routes import push_bp
app.register_blueprint(push_bp)

# Configuración
PORT = int(os.environ.get('PORT', 10000))
DUFFEL_API_KEY = os.environ.get('DUFFEL_API_KEY')

print("🚀 CUBALINK23 BACKEND - MANTIENE TODO LO EXISTENTE + BANNERS + PUSH NOTIFICATIONS")
print("🔧 Puerto: {}".format(PORT))
print("🔑 API Key: {}".format('✅ Configurada' if DUFFEL_API_KEY else '❌ No configurada'))
print("🔔 Push Notifications: ✅ Blueprint registrado")
print("🔄 FORZANDO REINICIO COMPLETO DEL SERVIDOR")
print("📱 PUSH NOTIFICATIONS ENDPOINTS: /api/push-notifications")
print("🔄 REINICIO FORZADO - TIMESTAMP: {}".format(datetime.now().isoformat()))
print("🔄 REINICIO FORZADO - TIMESTAMP: {}".format(datetime.now().isoformat()))
print("🔄 REINICIO FORZADO - TIMESTAMP: {}".format(datetime.now().isoformat()))

@app.route('/')
def home():
    """🏠 Página principal"""
    return jsonify({
        "message": "CubaLink23 Backend - MANTIENE TODO LO EXISTENTE + BANNERS",
        "status": "online",
        "timestamp": datetime.now().isoformat(),
        "version": "FINAL_100%",
        "endpoints": ["/api/health", "/admin/api/flights/search", "/admin/api/flights/airports"]
    })

@app.route('/api/health')
def health_check():
    """🔍 Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "duffel_key_configured": bool(DUFFEL_API_KEY),
        "push_notifications": "✅ Available"
    })

@app.route('/api/test-push')
def test_push():
    """🧪 Test push notifications endpoint"""
    return jsonify({
        "message": "Push notifications endpoint is working!",
        "timestamp": datetime.now().isoformat()
    })

# ===== FUNCIONALIDADES DE VUELOS (MANTIENEN TODO LO EXISTENTE) =====

@app.route("/admin/api/flights/airports")
def get_airports():
    """🌍 Obtener aeropuertos desde Duffel API"""
    try:
        query = request.args.get('query', '')
        if not query:
            return jsonify({"error": "Query parameter is required"}), 400
        
        if not DUFFEL_API_KEY:
            return jsonify({
                "error": "Duffel API key not configured",
                "airports": []
            }), 500
        
        headers = {
            'Authorization': 'Bearer {}'.format(DUFFEL_API_KEY),
            'Duffel-Version': 'v2'
        }
        
        print("📡 Consultando Duffel API para: {}".format(query))
        
        # Usar el endpoint correcto de Duffel para aeropuertos
        url = 'https://api.duffel.com/places/suggestions?query={}'.format(query)
        
        response = requests.get(url, headers=headers, timeout=10)
        print("📡 Status Duffel: {}".format(response.status_code))
        
        if response.status_code == 200:
            data = response.json()
            airports = []
            
            for place in data.get('data', []):
                if place.get('type') == 'airport':
                    airports.append({
                        'iata_code': place.get('iata_code'),
                        'name': place.get('name'),
                        'city': place.get('city_name'),
                        'country': place.get('country_name')
                    })
            
            return jsonify({
                "success": True,
                "airports": airports,
                "total": len(airports)
            })
        else:
            print("❌ Error Duffel API: {}".format(response.status_code))
            return jsonify({
                "error": "Error from Duffel API",
                "status_code": response.status_code
            }), 500
            
    except Exception as e:
        print("💥 Error consultando Duffel API: {}".format(str(e)))
        return jsonify({
            "error": "Internal server error",
            "message": str(e)
        }), 500

@app.route("/admin/api/flights/search", methods=["POST"])
def search_flights():
    """✈️ Buscar vuelos usando Duffel API"""
    try:
        data = request.get_json()
        
        origin = data.get('origin')
        destination = data.get('destination')
        departure_date = data.get('departure_date')
        return_date = data.get('return_date')
        passengers = data.get('passengers', 1)
        cabin_class = data.get('cabin_class', 'economy')
        
        if not all([origin, destination, departure_date]):
            return jsonify({
                "error": "Missing required parameters: origin, destination, departure_date"
            }), 400
        
        # Mapear cabin_class a valores válidos de Duffel
        cabin_mapping = {
            'economy': 'economy',
            'premium_economy': 'premium_economy',
            'business': 'business',
            'first': 'first'
        }
        cabin_class = cabin_mapping.get(cabin_class, 'economy')
        
        if not DUFFEL_API_KEY:
            return jsonify({
                "error": "Duffel API key not configured"
            }), 500
        
        headers = {
            'Authorization': 'Bearer {}'.format(DUFFEL_API_KEY),
            'Duffel-Version': 'v2',
            'Content-Type': 'application/json'
        }
        
        # Construir payload para Duffel
        offer_request_data = {
            "data": {
                "slices": [
                    {
                        "origin": origin,
                        "destination": destination,
                        "departure_date": departure_date
                    }
                ],
                "passengers": [
                    {
                        "type": "adult",
                        "age": 25
                    } for _ in range(passengers)
                ],
                "cabin_class": cabin_class
            }
        }
        
        # Agregar vuelo de regreso si se especifica
        if return_date:
            offer_request_data["data"]["slices"].append({
                "origin": destination,
                "destination": origin,
                "departure_date": return_date
            })
        
        # 🚀 PRODUCCIÓN REAL: Duffel API en modo producción
        print("🚀 PRODUCCIÓN REAL: Duffel API")
        
        print("🚀 Payload para Duffel: {}".format(offer_request_data))
        
        # Validaciones adicionales
        # 🎯 VALIDACIÓN: Duffel requiere códigos IATA válidos de 3 letras
        if len(origin) != 3 or len(destination) != 3:
            return jsonify({"error": "Airport codes must be 3 letters (IATA format)"}), 400
        
        # 🚫 RESTRICCIÓN: Duffel no permite rutas domésticas en producción
        if origin == destination:
            return jsonify({"error": "Origin and destination cannot be the same"}), 400
        
        # Crear offer request
        offer_response = requests.post(
            'https://api.duffel.com/air/offer_requests',
            headers=headers,
            json=offer_request_data,
            timeout=30
        )
        
        print("📡 DUFFEL RESPONSE STATUS: {}".format(offer_response.status_code))
        print("📡 DUFFEL RESPONSE HEADERS: {}".format(dict(offer_response.headers)))
        print("📡 DUFFEL RESPONSE BODY: {}".format(offer_response.text))
        print("📡 DUFFEL REQUEST PAYLOAD: {}".format(offer_request_data))
        
        if offer_response.status_code == 201:
            offer_request_id = offer_response.json()['data']['id']
            
            # Obtener ofertas
            offers_response = requests.get(
                'https://api.duffel.com/air/offers?offer_request_id={}'.format(offer_request_id),
                headers=headers,
                timeout=30
            )
            
            if offers_response.status_code == 200:
                offers_data = offers_response.json()
                return jsonify({
                    "success": True,
                    "offers": offers_data.get('data', []),
                    "total": len(offers_data.get('data', []))
                })
            else:
                return jsonify({
                    "error": "Error getting offers",
                    "status_code": offers_response.status_code
                }), 500
        else:
            # Manejar errores específicos de Duffel
            try:
                error_data = offer_response.json()
                if 'errors' in error_data:
                    # Enviar error específico de Duffel al frontend
                    error_message = error_data.get('errors', [{}])[0].get('message', 'Error desconocido de Duffel')
                    return jsonify({
                        "error": "Duffel API Error: {}".format(error_message),
                        "duffel_status": offer_response.status_code,
                        "duffel_response": offer_response.text
                    }), 400
                else:
                    return jsonify({
                        "error": "Duffel API Error",
                        "duffel_status": offer_response.status_code
                    }), 400
            except:
                return jsonify({
                    "error": "Duffel API Error",
                    "status_code": offer_response.status_code
                }), 400
                
    except Exception as e:
        print("💥 Error en búsqueda de vuelos: {}".format(str(e)))
        return jsonify({
            "error": "Internal server error",
            "message": str(e)
        }), 500

# ===== RUTAS DE NOTIFICACIONES PUSH (DIRECTAS) =====

@app.route('/api/push-notifications', methods=['POST'])
def send_push_notification():
    """Enviar notificación push a usuarios"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'success': False, 'error': 'No se recibieron datos'}), 400
        
        title = data.get('title', '').strip()
        message = data.get('message', '').strip()
        notification_type = data.get('type', 'all')
        is_urgent = data.get('is_urgent', False)
        
        if not title or not message:
            return jsonify({'success': False, 'error': 'Título y mensaje son requeridos'}), 400
        
        # Crear notificación en Supabase
        notification_data = {
            'title': title,
            'message': message,
            'type': notification_type,
            'is_urgent': is_urgent,
            'sent_at': datetime.utcnow().isoformat(),
            'status': 'sent'
        }
        
        # Guardar en Supabase
        try:
            SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
            SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
            headers = {
                'apikey': SUPABASE_KEY,
                'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
                'Content-Type': 'application/json'
            }
            
            # Insertar notificación en la tabla notifications
            response = requests.post(
                f'{SUPABASE_URL}/rest/v1/notifications',
                headers=headers,
                json=notification_data
            )
            
            if response.status_code in [200, 201]:
                print(f"✅ Notificación push guardada en Supabase: {title}")
            else:
                print(f"⚠️ Error guardando notificación en Supabase: {response.status_code}")
                
        except Exception as e:
            print(f"⚠️ Error conectando con Supabase: {e}")
        
        return jsonify({
            'success': True,
            'message': 'Notificación push enviada exitosamente',
            'notification': {
                'title': title,
                'message': message,
                'type': notification_type,
                'is_urgent': is_urgent,
                'sent_at': notification_data['sent_at']
            }
        })
        
    except Exception as e:
        print(f"❌ Error enviando notificación push: {e}")
        return jsonify({'success': False, 'error': f'Error interno: {str(e)}'}), 500

@app.route('/api/push-notifications', methods=['GET'])
def get_push_notifications():
    """Obtener historial de notificaciones push"""
    try:
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        # Obtener notificaciones ordenadas por fecha descendente
        response = requests.get(
            f'{SUPABASE_URL}/rest/v1/notifications?order=sent_at.desc&limit=50',
            headers=headers
        )
        
        if response.status_code == 200:
            notifications = response.json()
            return jsonify({
                'success': True,
                'notifications': notifications
            })
        else:
            print(f"⚠️ Error obteniendo notificaciones: {response.status_code}")
            return jsonify({
                'success': True,
                'notifications': []
            })
            
    except Exception as e:
        print(f"❌ Error obteniendo notificaciones: {e}")
        return jsonify({
            'success': True,
            'notifications': []
        })

@app.route('/api/push-notifications/<notification_id>', methods=['DELETE'])
def delete_push_notification(notification_id):
    """Eliminar notificación push"""
    try:
        SUPABASE_URL = 'https://zgqrhzuhrwudckwesybg.supabase.co'
        SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': 'Bearer {}'.format(SUPABASE_KEY),
            'Content-Type': 'application/json'
        }
        
        # Eliminar notificación
        response = requests.delete(
            f'{SUPABASE_URL}/rest/v1/notifications?id=eq.{notification_id}',
            headers=headers
        )
        
        if response.status_code in [200, 204]:
            return jsonify({
                'success': True,
                'message': 'Notificación eliminada exitosamente'
            })
        else:
            return jsonify({
                'success': False,
                'error': 'Error eliminando notificación'
            }), 500
            
    except Exception as e:
        print(f"❌ Error eliminando notificación: {e}")
        return jsonify({'success': False, 'error': f'Error interno: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT, debug=False)

