#!/usr/bin/env python3
"""
Keep-Alive Script para CubaLink23 Backend
Mantiene el servicio activo en Render.com para evitar hibernación
"""

import requests
import time
import schedule
import logging
from datetime import datetime

# Configuración
RENDER_URL = "https://cubalink23-backend.onrender.com"
KEEP_ALIVE_ENDPOINTS = [
    "/",
    "/admin",
    "/admin/products",
    "/admin/api/products"
]

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('keep_alive.log'),
        logging.StreamHandler()
    ]
)

def ping_endpoint(endpoint):
    """Hace ping a un endpoint específico"""
    try:
        url = f"{RENDER_URL}{endpoint}"
        response = requests.get(url, timeout=30)
        
        if response.status_code == 200:
            logging.info(f"✅ Ping exitoso: {endpoint} - Status: {response.status_code}")
            return True
        else:
            logging.warning(f"⚠️ Ping con status inesperado: {endpoint} - Status: {response.status_code}")
            return False
            
    except requests.exceptions.Timeout:
        logging.error(f"⏰ Timeout en ping: {endpoint}")
        return False
    except requests.exceptions.ConnectionError:
        logging.error(f"🔌 Error de conexión en ping: {endpoint}")
        return False
    except Exception as e:
        logging.error(f"❌ Error inesperado en ping {endpoint}: {str(e)}")
        return False

def keep_alive_cycle():
    """Ejecuta un ciclo completo de keep-alive"""
    logging.info("🔄 Iniciando ciclo de keep-alive...")
    
    successful_pings = 0
    total_pings = len(KEEP_ALIVE_ENDPOINTS)
    
    for endpoint in KEEP_ALIVE_ENDPOINTS:
        if ping_endpoint(endpoint):
            successful_pings += 1
        time.sleep(2)  # Pausa entre pings
    
    success_rate = (successful_pings / total_pings) * 100
    logging.info(f"📊 Ciclo completado: {successful_pings}/{total_pings} pings exitosos ({success_rate:.1f}%)")
    
    if success_rate >= 75:
        logging.info("✅ Servicio manteniéndose activo correctamente")
    else:
        logging.warning("⚠️ Servicio puede estar hibernando o con problemas")

def main():
    """Función principal"""
    logging.info("🚀 Iniciando Keep-Alive para CubaLink23 Backend")
    logging.info(f"🎯 URL objetivo: {RENDER_URL}")
    logging.info(f"📋 Endpoints a monitorear: {len(KEEP_ALIVE_ENDPOINTS)}")
    
    # Ejecutar inmediatamente
    keep_alive_cycle()
    
    # Programar ejecución cada 10 minutos
    schedule.every(10).minutes.do(keep_alive_cycle)
    
    logging.info("⏰ Keep-alive programado cada 10 minutos")
    logging.info("🔄 Manteniendo servicio activo...")
    
    try:
        while True:
            schedule.run_pending()
            time.sleep(60)  # Verificar cada minuto
    except KeyboardInterrupt:
        logging.info("🛑 Keep-alive detenido por el usuario")
    except Exception as e:
        logging.error(f"❌ Error en keep-alive: {str(e)}")

if __name__ == "__main__":
    main()

