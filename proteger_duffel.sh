#!/bin/bash

# 🛡️ SCRIPT DE PROTECCIÓN SIMPLE PARA DUFFEL
# Este script protege los archivos críticos del backend de Duffel

echo "🛡️ INICIANDO PROTECCIÓN DUFFEL"
echo "=================================="

# Crear directorio de backups
mkdir -p BACKUPS_DUFFEL_FUNCIONANDO

# Crear timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Hacer backup de archivos críticos
if [ -f "app.py" ]; then
    cp app.py "BACKUPS_DUFFEL_FUNCIONANDO/app.py_FUNCIONANDO_${TIMESTAMP}.py"
    echo "✅ Backup de app.py creado"
else
    echo "❌ app.py no encontrado"
fi

if [ -f "duffel_service.py" ]; then
    cp duffel_service.py "BACKUPS_DUFFEL_FUNCIONANDO/duffel_service.py_FUNCIONANDO_${TIMESTAMP}.py"
    echo "✅ Backup de duffel_service.py creado"
else
    echo "❌ duffel_service.py no encontrado"
fi

# Verificar que los archivos tengan el código correcto
echo ""
echo "🔍 VERIFICANDO CÓDIGO CRÍTICO..."

# Verificar app.py
if grep -q "url = f'https://api.duffel.com/air/airports?search={query}&limit=20'" app.py; then
    echo "✅ app.py: Endpoint correcto encontrado"
else
    echo "❌ app.py: Endpoint incorrecto o faltante"
fi

# Verificar duffel_service.py
if grep -q "'search': query," duffel_service.py; then
    echo "✅ duffel_service.py: Parámetro correcto encontrado"
else
    echo "❌ duffel_service.py: Parámetro incorrecto o faltante"
fi

# Verificar que NO tenga código incorrecto
if grep -q "/places?query=" app.py; then
    echo "🚨 PELIGRO: app.py contiene endpoint incorrecto /places"
fi

if grep -q "'name': query," duffel_service.py; then
    echo "🚨 PELIGRO: duffel_service.py contiene parámetro incorrecto 'name'"
fi

echo ""
echo "=================================="
echo "🛡️ PROTECCIÓN COMPLETADA"
echo ""
echo "📋 PRÓXIMOS PASOS:"
echo "1. Hacer deploy de los cambios"
echo "2. Probar búsqueda de aeropuertos"
echo "3. Si algo falla, usar rollback automático"





