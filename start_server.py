#!/usr/bin/env python3
"""
Script para iniciar el servidor de administración
"""

import os
import sys
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv('config.env')

def check_dependencies():
    """Verificar que todas las dependencias estén instaladas"""
    required_packages = [
        'flask',
        'flask-cors',
        'requests',
        'python-dotenv'
    ]
    
    missing_packages = []
    for package in required_packages:
        try:
            __import__(package.replace('-', '_'))
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        print("❌ Faltan las siguientes dependencias:")
        for package in missing_packages:
            print(f"   - {package}")
        print("\nInstala las dependencias con:")
        print("   pip install -r requirements.txt")
        return False
    
    return True

def create_directories():
    """Crear directorios necesarios"""
    directories = [
        'static/uploads',
        'static/images',
        'logs'
    ]
    
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"✅ Directorio creado: {directory}")

def main():
    """Función principal"""
    print("🚀 Iniciando servidor de administración Cubalink23...")
    print("=" * 50)
    
    # Verificar dependencias
    if not check_dependencies():
        sys.exit(1)
    
    # Crear directorios
    print("\n📁 Creando directorios necesarios...")
    create_directories()
    
    # Configurar variables de entorno
    port = int(os.environ.get('PORT', 3005))
    host = os.environ.get('HOST', '0.0.0.0')
    debug = os.environ.get('DEBUG', 'False').lower() == 'true'
    
    print(f"\n⚙️ Configuración del servidor:")
    print(f"   - Puerto: {port}")
    print(f"   - Host: {host}")
    print(f"   - Debug: {debug}")
    
    # Importar y ejecutar la aplicación
    try:
        from app import app
        
        print(f"\n🌐 Servidor iniciado en: http://{host}:{port}")
        print("📊 Panel de administración: http://localhost:3005/admin")
        print("🔐 Login: http://localhost:3005/auth/login")
        print("\nPresiona Ctrl+C para detener el servidor")
        print("=" * 50)
        
        app.run(host=host, port=port, debug=debug)
        
    except ImportError as e:
        print(f"❌ Error importando la aplicación: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error iniciando el servidor: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
