#!/bin/bash

# Script para iniciar CubaLink23 en navegador web
# Este script asegura que la app siempre se ejecute en Chrome

echo "🚀 Iniciando CubaLink23 en navegador web..."
echo "📁 Directorio: $(pwd)"

# Verificar que Flutter esté disponible
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado o no está en el PATH"
    exit 1
fi

# Verificar que Chrome esté disponible
if ! command -v google-chrome &> /dev/null && ! command -v chrome &> /dev/null; then
    echo "⚠️ Chrome no encontrado, usando navegador por defecto"
fi

# Limpiar procesos anteriores de Flutter
echo "🧹 Limpiando procesos anteriores..."
pkill -f "flutter run" 2>/dev/null || true
pkill -f "Google Chrome.*localhost:8080" 2>/dev/null || true

# Limpiar cache si es necesario
if [ "$1" = "--clean" ]; then
    echo "🧹 Limpiando cache de Flutter..."
    flutter clean
    flutter pub get
fi

# Verificar dependencias
echo "📦 Verificando dependencias..."
flutter pub get

# Iniciar la app en Chrome
echo "🌐 Iniciando app en Chrome (puerto 8080)..."
echo "🔗 URL: http://localhost:8080"
echo "⏹️ Presiona Ctrl+C para detener"
echo ""

flutter run -d chrome --web-port 8080
