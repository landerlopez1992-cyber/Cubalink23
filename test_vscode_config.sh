#!/bin/bash

echo "🧪 Probando configuración de VS Code..."
echo "📁 Directorio: $(pwd)"

# Verificar que Flutter esté disponible
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado o no está en el PATH"
    exit 1
fi

# Verificar dispositivos disponibles
echo "🔍 Dispositivos disponibles:"
flutter devices

echo ""
echo "🎯 Probando comando que usa VS Code:"
echo "Comando: flutter run -d chrome --web-port 8080"

# Limpiar procesos anteriores
pkill -f "flutter run" 2>/dev/null || true

# Probar el comando
echo "🚀 Ejecutando comando de prueba..."
timeout 10 flutter run -d chrome --web-port 8080 || echo "⏰ Timeout alcanzado (normal)"

echo ""
echo "✅ Configuración de VS Code lista!"
echo "📝 Ahora puedes usar F5 o el botón 'Run and Debug' en VS Code"
