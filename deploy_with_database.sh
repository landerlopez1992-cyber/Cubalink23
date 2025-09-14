#!/bin/bash
# Script de deployment automático con configuración de base de datos
# Para usar en Render.com o cualquier servicio de hosting

echo "🚀 INICIANDO DEPLOYMENT CON CONFIGURACIÓN AUTOMÁTICA DE DB"
echo "=" * 60

# 1. Verificar archivos necesarios
echo "📋 Verificando archivos necesarios..."
if [ ! -f "setup_database.py" ]; then
    echo "❌ Error: setup_database.py no encontrado"
    exit 1
fi

if [ ! -f "create_user_carts_table.sql" ]; then
    echo "❌ Error: create_user_carts_table.sql no encontrado"
    exit 1
fi

if [ ! -f "app.py" ]; then
    echo "❌ Error: app.py no encontrado"
    exit 1
fi

echo "✅ Todos los archivos necesarios encontrados"

# 2. Instalar dependencias
echo "📦 Instalando dependencias..."
pip install -r requirements.txt

# 3. Configurar variables de entorno (ejemplo)
echo "🔧 Configurando variables de entorno..."
echo "   SUPABASE_URL: ${SUPABASE_URL:-'NO_CONFIGURADA'}"
echo "   SUPABASE_SERVICE_KEY: ${SUPABASE_SERVICE_KEY:-'NO_CONFIGURADA'}"

# 4. Ejecutar configuración de base de datos
echo "📊 Configurando base de datos..."
python3 setup_database.py

# 5. Iniciar servidor Flask
echo "🚀 Iniciando servidor..."
python3 app.py

echo "✅ DEPLOYMENT COMPLETADO"
