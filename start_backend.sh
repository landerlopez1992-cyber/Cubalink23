#!/bin/bash

# 🚀 Script para iniciar el backend de CubaLink23
echo "🚀 Iniciando backend de CubaLink23..."

# Cambiar al directorio del backend
cd /Users/cubcolexpress/Desktop/turecarga/backend-duffel

# Verificar si Python está disponible
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 no está instalado"
    exit 1
fi

# Verificar si pip está disponible
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 no está instalado"
    exit 1
fi

# Instalar dependencias si no existen
echo "📦 Verificando dependencias..."
pip3 install flask flask-cors python-dotenv requests beautifulsoup4 > /dev/null 2>&1

# Configurar variables de entorno si no existen
if [ ! -f config.env ]; then
    echo "📝 Creando archivo de configuración..."
    cat > config.env << EOL
SECRET_KEY=tu-clave-secreta-super-segura-aqui
PORT=3005
DEBUG=False
DATABASE_URL=sqlite:///./database.db
EOL
fi

echo "🔥 Iniciando servidor Flask en puerto 3005..."
echo "🌐 Acceso local: http://localhost:3005"
echo "🌐 API de vuelos: http://localhost:3005/admin/api/flights/search"
echo "📱 Panel admin: http://localhost:3005/admin/"
echo ""
echo "🛑 Para detener el servidor: Ctrl+C"
echo ""

# Iniciar el servidor
python3 app.py
