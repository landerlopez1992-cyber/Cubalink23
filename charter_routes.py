from flask import Blueprint, request, jsonify
import requests
from bs4 import BeautifulSoup
import re
import json
from datetime import datetime, timedelta
import time
import threading
from database import get_db_connection
# Importar el scraper real
try:
    from charter_scraper import charter_scraper
    REAL_SCRAPER_AVAILABLE = True
except ImportError:
    REAL_SCRAPER_AVAILABLE = False

charter_bp = Blueprint('charter', __name__)

# Configuración de aerolíneas charter
CHARTER_AIRLINES = {
    'xael': {
        'name': 'Xael Charter',
        'url': 'https://www.xaelcharter.com/wp-content/uploads/Flight%20Widget/flight-widget.html',
        'markup': 50,
        'active': True,
        'routes': ['Miami-Havana', 'Tampa-Havana'],
        'check_frequency': 30  # minutos
    },
    'cubazul': {
        'name': 'Cubazul Air Charter',
        'url': 'https://cubazulaircharter.com/',
        'markup': 45,
        'active': True,
        'routes': ['Miami-Havana', 'Fort Lauderdale-Havana'],
        'check_frequency': 30
    },
    'havana_air': {
        'name': 'Havana Air Charter',
        'url': 'https://havanaair.com/',
        'markup': 55,
        'active': True,
        'routes': ['Miami-Havana', 'Orlando-Havana'],
        'check_frequency': 30
    }
}

class CharterFlightScraper:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        })

    def scrape_xael_charter(self, search_data):
        """Scraping específico para Xael Charter"""
        try:
            # Usar el scraper real
            flights = charter_scraper.scrape_xael_charter_real(search_data)
            
            # Aplicar markup si no está aplicado
            for flight in flights:
                if 'markup' not in flight:
                    flight['original_price'] = flight['price']
                    flight['price'] += CHARTER_AIRLINES['xael']['markup']
                    flight['markup'] = CHARTER_AIRLINES['xael']['markup']
            
            return flights
            
        except Exception as e:
            print(f"Error scraping Xael Charter: {e}")
            return []

    def scrape_cubazul_charter(self, search_data):
        """Scraping específico para Cubazul Air Charter"""
        try:
            # Usar el scraper real
            flights = charter_scraper.scrape_cubazul_charter_real(search_data)
            
            # Aplicar markup si no está aplicado
            for flight in flights:
                if 'markup' not in flight:
                    flight['original_price'] = flight['price']
                    flight['price'] += CHARTER_AIRLINES['cubazul']['markup']
                    flight['markup'] = CHARTER_AIRLINES['cubazul']['markup']
            
            return flights
            
        except Exception as e:
            print(f"Error scraping Cubazul Charter: {e}")
            return []

    def scrape_havana_air_charter(self, search_data):
        """Scraping específico para Havana Air Charter"""
        try:
            # Usar el scraper real
            flights = charter_scraper.scrape_havana_air_charter_real(search_data)
            
            # Aplicar markup si no está aplicado
            for flight in flights:
                if 'markup' not in flight:
                    flight['original_price'] = flight['price']
                    flight['price'] += CHARTER_AIRLINES['havana_air']['markup']
                    flight['markup'] = CHARTER_AIRLINES['havana_air']['markup']
            
            return flights
            
        except Exception as e:
            print(f"Error scraping Havana Air Charter: {e}")
            return []

    def search_all_charters(self, search_data):
        """Buscar en todas las aerolíneas charter activas"""
        try:
            # Usar el scraper real si está disponible
            if REAL_SCRAPER_AVAILABLE:
                all_flights = charter_scraper.search_all_charters_real(search_data)
                
                # Aplicar markup según configuración
                for flight in all_flights:
                    airline_name = flight['airline']
                    for airline_id, airline_config in CHARTER_AIRLINES.items():
                        if airline_config['active'] and airline_name in airline_config['name']:
                            if 'markup' not in flight:
                                flight['original_price'] = flight['price']
                                flight['price'] += airline_config['markup']
                                flight['markup'] = airline_config['markup']
                            break
                
                return all_flights
            else:
                # Fallback a método original
                all_flights = []
                
                if CHARTER_AIRLINES['xael']['active']:
                    xael_flights = self.scrape_xael_charter(search_data)
                    all_flights.extend(xael_flights)
                
                if CHARTER_AIRLINES['cubazul']['active']:
                    cubazul_flights = self.scrape_cubazul_charter(search_data)
                    all_flights.extend(cubazul_flights)
                
                if CHARTER_AIRLINES['havana_air']['active']:
                    havana_flights = self.scrape_havana_air_charter(search_data)
                    all_flights.extend(havana_flights)
                
                return all_flights
            
        except Exception as e:
            print(f"Error en búsqueda de charters: {e}")
            # Fallback a método original
            all_flights = []
            
            if CHARTER_AIRLINES['xael']['active']:
                xael_flights = self.scrape_xael_charter(search_data)
                all_flights.extend(xael_flights)
            
            if CHARTER_AIRLINES['cubazul']['active']:
                cubazul_flights = self.scrape_cubazul_charter(search_data)
                all_flights.extend(cubazul_flights)
            
            if CHARTER_AIRLINES['havana_air']['active']:
                havana_flights = self.scrape_havana_air_charter(search_data)
                all_flights.extend(havana_flights)
            
            return all_flights

# Instancia global del scraper
charter_scraper = CharterFlightScraper()

@charter_bp.route('/api/charter/search', methods=['POST'])
def search_charter_flights():
    """Buscar vuelos charter"""
    try:
        data = request.get_json()
        
        # Validar datos requeridos
        required_fields = ['origin', 'destination', 'departure_date']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'success': False,
                    'message': f'Campo requerido: {field}'
                }), 400
        
        # Realizar búsqueda en todas las aerolíneas charter
        flights = charter_scraper.search_all_charters(data)
        
        return jsonify({
            'success': True,
            'flights': flights,
            'total': len(flights),
            'search_data': data
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error en búsqueda: {str(e)}'
        }), 500

@charter_bp.route('/api/charter/airlines', methods=['GET'])
def get_charter_airlines():
    """Obtener lista de aerolíneas charter"""
    try:
        airlines = []
        for key, airline in CHARTER_AIRLINES.items():
            airlines.append({
                'id': key,
                'name': airline['name'],
                'url': airline['url'],
                'markup': airline['markup'],
                'active': airline['active'],
                'routes': airline['routes'],
                'check_frequency': airline['check_frequency']
            })
        
        return jsonify({
            'success': True,
            'airlines': airlines
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500

@charter_bp.route('/api/charter/airlines', methods=['POST'])
def save_charter_airline():
    """Guardar o actualizar aerolínea charter"""
    try:
        data = request.get_json()
        
        # En producción, esto se guardaría en la base de datos
        # Por ahora, actualizamos la configuración en memoria
        airline_id = data.get('id')
        if airline_id and airline_id in CHARTER_AIRLINES:
            CHARTER_AIRLINES[airline_id].update({
                'name': data.get('name'),
                'url': data.get('url'),
                'markup': float(data.get('markup', 0)),
                'active': data.get('status') == 'active',
                'routes': data.get('routes', '').split(','),
                'check_frequency': int(data.get('check_frequency', 30))
            })
        
        return jsonify({
            'success': True,
            'message': 'Aerolínea guardada correctamente'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error al guardar: {str(e)}'
        }), 500

@charter_bp.route('/api/charter/airlines/<airline_id>/toggle', methods=['POST'])
def toggle_charter_airline(airline_id):
    """Activar/desactivar aerolínea charter"""
    try:
        if airline_id in CHARTER_AIRLINES:
            CHARTER_AIRLINES[airline_id]['active'] = not CHARTER_AIRLINES[airline_id]['active']
            
            return jsonify({
                'success': True,
                'message': f"Aerolínea {'activada' if CHARTER_AIRLINES[airline_id]['active'] else 'desactivada'} correctamente"
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Aerolínea no encontrada'
            }), 404
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500

@charter_bp.route('/api/charter/airlines/<airline_id>/test', methods=['POST'])
def test_charter_airline(airline_id):
    """Probar conexión con aerolínea charter"""
    try:
        if airline_id not in CHARTER_AIRLINES:
            return jsonify({
                'success': False,
                'message': 'Aerolínea no encontrada'
            }), 404
        
        airline = CHARTER_AIRLINES[airline_id]
        
        # Simular prueba de conexión
        test_data = {
            'origin': 'Miami',
            'destination': 'Havana',
            'departure_date': (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%d')
        }
        
        if airline_id == 'xael':
            flights = charter_scraper.scrape_xael_charter_real(test_data)
        elif airline_id == 'cubazul':
            flights = charter_scraper.scrape_cubazul_charter_real(test_data)
        elif airline_id == 'havana_air':
            flights = charter_scraper.scrape_havana_air_charter_real(test_data)
        else:
            flights = []
        
        if flights:
            return jsonify({
                'success': True,
                'message': f'Conexión exitosa. Se encontraron {len(flights)} vuelos de prueba.',
                'test_flights': flights
            })
        else:
            return jsonify({
                'success': False,
                'message': 'No se pudieron obtener vuelos de prueba'
            })
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error en prueba: {str(e)}'
        }), 500

@charter_bp.route('/api/charter/booking', methods=['POST'])
def create_charter_booking():
    """Crear reserva charter (estado PENDIENTE)"""
    try:
        data = request.get_json()
        
        # Validar datos requeridos
        required_fields = ['flight_data', 'passenger_info', 'payment_info']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'success': False,
                    'message': f'Campo requerido: {field}'
                }), 400
        
        # Crear reserva en estado PENDIENTE
        booking = {
            'id': f"CH{int(time.time())}",
            'flight_data': data['flight_data'],
            'passenger_info': data['passenger_info'],
            'payment_info': data['payment_info'],
            'status': 'PENDIENTE',
            'created_at': datetime.now().isoformat(),
            'total_price': data['flight_data']['price'],
            'airline': data['flight_data']['airline'],
            'can_modify': True,
            'can_cancel': True
        }
        
        # En producción, guardar en base de datos
        # save_booking_to_db(booking)
        
        return jsonify({
            'success': True,
            'booking': booking,
            'message': 'Reserva creada en estado PENDIENTE. El administrador realizará la reserva real.'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error al crear reserva: {str(e)}'
        }), 500

@charter_bp.route('/api/charter/booking/<booking_id>/confirm', methods=['POST'])
def confirm_charter_booking(booking_id):
    """Confirmar reserva charter (cambiar a CONFIRMADO)"""
    try:
        # En producción, obtener de base de datos
        # booking = get_booking_from_db(booking_id)
        
        # Simular confirmación
        booking = {
            'id': booking_id,
            'status': 'CONFIRMADO',
            'confirmed_at': datetime.now().isoformat(),
            'ticket_number': f"TK{int(time.time())}",
            'can_modify': False,
            'can_cancel': False
        }
        
        # En producción, actualizar en base de datos
        # update_booking_in_db(booking_id, booking)
        
        return jsonify({
            'success': True,
            'booking': booking,
            'message': 'Reserva confirmada. Tiquete emitido. No se permiten más cambios.'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error al confirmar reserva: {str(e)}'
        }), 500

@charter_bp.route('/api/charter/booking/<booking_id>/modify', methods=['POST'])
def modify_charter_booking(booking_id):
    """Modificar reserva charter (solo si está PENDIENTE)"""
    try:
        data = request.get_json()
        
        # En producción, verificar estado en base de datos
        # booking = get_booking_from_db(booking_id)
        
        # Simular verificación
        booking = {
            'id': booking_id,
            'status': 'PENDIENTE',  # Simulado
            'can_modify': True
        }
        
        if booking['status'] != 'PENDIENTE':
            return jsonify({
                'success': False,
                'message': 'No se puede modificar una reserva confirmada'
            }), 400
        
        if not booking['can_modify']:
            return jsonify({
                'success': False,
                'message': 'Esta reserva no permite modificaciones'
            }), 400
        
        # En producción, actualizar en base de datos
        # update_booking_in_db(booking_id, data)
        
        return jsonify({
            'success': True,
            'message': 'Reserva modificada correctamente'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error al modificar reserva: {str(e)}'
        }), 500

@charter_bp.route('/api/charter/booking/<booking_id>/cancel', methods=['POST'])
def cancel_charter_booking(booking_id):
    """Cancelar reserva charter (solo si está PENDIENTE)"""
    try:
        # En producción, verificar estado en base de datos
        # booking = get_booking_from_db(booking_id)
        
        # Simular verificación
        booking = {
            'id': booking_id,
            'status': 'PENDIENTE',  # Simulado
            'can_cancel': True
        }
        
        if booking['status'] != 'PENDIENTE':
            return jsonify({
                'success': False,
                'message': 'No se puede cancelar una reserva confirmada'
            }), 400
        
        if not booking['can_cancel']:
            return jsonify({
                'success': False,
                'message': 'Esta reserva no permite cancelaciones'
            }), 400
        
        # En producción, actualizar estado y procesar reembolso
        # update_booking_status(booking_id, 'CANCELADO')
        # process_refund(booking_id)
        
        return jsonify({
            'success': True,
            'message': 'Reserva cancelada. Reembolso procesado.'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error al cancelar reserva: {str(e)}'
        }), 500