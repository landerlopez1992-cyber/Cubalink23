#!/usr/bin/env python3
"""
🧪 PRUEBA INTERNA - LOGOS DE AEROLÍNEAS
Simula búsqueda MIA → PUJ para verificar que los logos PNG funcionen
"""

import requests
import json

# URL del backend local
BACKEND_URL = "http://localhost:3005/api/flights/search"

# Datos de prueba (simulando MIA → HAV - ruta que SABEMOS que funciona)
test_payload = {
    "origin": "MIA",
    "destination": "HAV", 
    "departure_date": "2025-09-20",
    "passengers": 1,
    "cabin_class": "economy",
    "airline_type": "comerciales"
}

print("🧪 ===== PRUEBA INTERNA DE LOGOS =====")
print(f"🔗 Endpoint: {BACKEND_URL}")
print(f"📋 Payload: {json.dumps(test_payload, indent=2)}")
print()

try:
    print("📤 Enviando solicitud al backend...")
    response = requests.post(BACKEND_URL, json=test_payload, timeout=30)
    
    print(f"📡 Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"🔍 Respuesta completa: {json.dumps(data, indent=2)}")
        flights = data.get('data', [])
        
        print(f"✈️ Vuelos encontrados: {len(flights)}")
        print()
        
        # Verificar los primeros 3 vuelos
        for i, flight in enumerate(flights[:3], 1):
            airline = flight.get('airline', 'N/A')
            logo_url = flight.get('airline_logo', '')
            price = flight.get('price', 0)
            
            print(f"🔍 Vuelo {i}:")
            print(f"   🏢 Aerolínea: {airline}")
            print(f"   💰 Precio: ${price}")
            print(f"   🖼️ Logo: {logo_url}")
            
            # ✅ VERIFICACIÓN CRÍTICA
            if logo_url:
                if '.png' in logo_url:
                    print(f"   ✅ LOGO PNG: ¡CORRECTO!")
                elif '.svg' in logo_url:
                    print(f"   ❌ LOGO SVG: ¡ERROR! Flutter no puede mostrar SVG")
                else:
                    print(f"   ⚠️ LOGO DESCONOCIDO: {logo_url}")
            else:
                print(f"   ❌ SIN LOGO: Campo vacío")
            print()
        
        # 🎯 RESUMEN FINAL
        png_count = sum(1 for f in flights if '.png' in f.get('airline_logo', ''))
        svg_count = sum(1 for f in flights if '.svg' in f.get('airline_logo', ''))
        no_logo_count = sum(1 for f in flights if not f.get('airline_logo', ''))
        
        print("📊 RESUMEN:")
        print(f"   ✅ Logos PNG (FUNCIONA): {png_count}")
        print(f"   ❌ Logos SVG (ERROR): {svg_count}") 
        print(f"   🚫 Sin logo: {no_logo_count}")
        
        if png_count == len(flights):
            print("\n🎉 ¡ÉXITO TOTAL! Todos los logos son PNG")
        elif svg_count > 0:
            print("\n⚠️ PROBLEMA: Hay logos SVG que Flutter no puede mostrar")
        else:
            print("\n❓ ESTADO MIXTO: Revisar configuración")
            
    else:
        print(f"❌ Error del backend: {response.status_code}")
        print(f"Respuesta: {response.text}")
        
except requests.exceptions.ConnectionError:
    print("❌ ERROR: No se puede conectar al backend en puerto 3005")
    print("🔧 Asegúrate que el backend esté ejecutándose")
except Exception as e:
    print(f"❌ ERROR INESPERADO: {e}")

print("\n🔚 Prueba interna completada")
