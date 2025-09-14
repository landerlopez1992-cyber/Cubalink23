#!/usr/bin/env python3
"""
🚨 VALIDACIÓN CRÍTICA PRE-DEPLOY PARA DUFFEL
Este script DEBE ejecutarse antes de cada deploy para asegurar
que el backend de Duffel no haya sido dañado.
"""

import os
import sys
import requests
import json

class DuffelPreDeployValidator:
    def __init__(self):
        self.critical_checks = [
            self.check_airports_endpoint,
            self.check_duffel_service_params,
            self.check_app_py_endpoint,
            self.test_airports_api
        ]
        
    def check_airports_endpoint(self):
        """Verificar que app.py use el endpoint correcto"""
        if not os.path.exists('app.py'):
            return False, "app.py no existe"
            
        with open('app.py', 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Verificar endpoint correcto
        if "url = f'https://api.duffel.com/air/airports?search={query}&limit=20'" not in content:
            return False, "Endpoint incorrecto en app.py - debe usar /air/airports?search="
            
        # Verificar que NO use el endpoint incorrecto
        if "/places?query=" in content:
            return False, "ENCONTRADO ENDPOINT INCORRECTO /places en app.py"
            
        return True, "app.py endpoint correcto"
        
    def check_duffel_service_params(self):
        """Verificar que duffel_service.py use parámetros correctos"""
        if not os.path.exists('duffel_service.py'):
            return False, "duffel_service.py no existe"
            
        with open('duffel_service.py', 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Verificar parámetro correcto
        if "'search': query," not in content:
            return False, "Parámetro incorrecto en duffel_service.py - debe usar 'search'"
            
        # Verificar que NO use el parámetro incorrecto
        if "'name': query," in content:
            return False, "ENCONTRADO PARÁMETRO INCORRECTO 'name' en duffel_service.py"
            
        return True, "duffel_service.py parámetros correctos"
        
    def check_app_py_endpoint(self):
        """Verificar estructura de datos en app.py"""
        if not os.path.exists('app.py'):
            return False, "app.py no existe"
            
        with open('app.py', 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Verificar estructura correcta para city/country
        if "airport.get('city', {}).get('name', '')" not in content:
            return False, "Estructura de datos incorrecta para city en app.py"
            
        return True, "app.py estructura de datos correcta"
        
    def test_airports_api(self):
        """Probar la API de aeropuertos directamente"""
        try:
            # Simular test con API key (si está disponible)
            api_key = os.environ.get('DUFFEL_API_KEY')
            if not api_key:
                return True, "API key no disponible para test directo"
                
            headers = {
                'Accept': 'application/json',
                'Authorization': f'Bearer {api_key}',
                'Duffel-Version': 'v2'
            }
            
            # Test con búsqueda simple
            url = 'https://api.duffel.com/air/airports?search=MIA&limit=5'
            response = requests.get(url, headers=headers, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if 'data' in data and len(data['data']) > 0:
                    return True, f"API Duffel funcionando - {len(data['data'])} aeropuertos encontrados"
                else:
                    return False, "API Duffel responde pero sin datos"
            else:
                return False, f"API Duffel error: {response.status_code}"
                
        except Exception as e:
            return False, f"Error probando API Duffel: {str(e)}"
            
    def run_validation(self):
        """Ejecutar todas las validaciones"""
        print("🚨 VALIDACIÓN CRÍTICA PRE-DEPLOY DUFFEL")
        print("=" * 60)
        
        all_passed = True
        
        for i, check_func in enumerate(self.critical_checks, 1):
            print(f"\n{i}. Ejecutando: {check_func.__name__}")
            try:
                passed, message = check_func()
                if passed:
                    print(f"   ✅ {message}")
                else:
                    print(f"   ❌ {message}")
                    all_passed = False
            except Exception as e:
                print(f"   💥 Error: {str(e)}")
                all_passed = False
                
        print("\n" + "=" * 60)
        
        if all_passed:
            print("🎉 TODAS LAS VALIDACIONES PASARON")
            print("✅ SEGURO PARA DEPLOY")
            return True
        else:
            print("🚨 VALIDACIONES FALLARON")
            print("❌ NO HACER DEPLOY - CORREGIR PRIMERO")
            print("\n🔧 ACCIONES REQUERIDAS:")
            print("1. Revisar archivos app.py y duffel_service.py")
            print("2. Usar endpoint: /air/airports?search=")
            print("3. Usar parámetro: 'search' (no 'name')")
            print("4. Ejecutar este script nuevamente")
            return False

if __name__ == "__main__":
    validator = DuffelPreDeployValidator()
    success = validator.run_validation()
    
    # Salir con código de error si falló
    if not success:
        sys.exit(1)
