#!/bin/bash

echo "📱 Iniciando CubaLink23 en modo móvil..."
echo "🔧 Dimensiones: 412x915 (simulando iPhone)"
echo "📍 Posición: 60,60"
echo ""

# Verificar que Flutter esté ejecutándose
if ! curl -s http://localhost:8080 > /dev/null; then
    echo "❌ Flutter no está ejecutándose en localhost:8080"
    echo "🚀 Iniciando Flutter primero..."
    
    # Iniciar Flutter en background
    flutter run -d chrome --web-port 8080 &
    FLUTTER_PID=$!
    
    # Esperar a que Flutter esté listo
    echo "⏳ Esperando a que Flutter esté listo..."
    for i in {1..30}; do
        if curl -s http://localhost:8080 > /dev/null; then
            echo "✅ Flutter listo!"
            break
        fi
        sleep 2
        echo "⏳ Esperando... ($i/30)"
    done
fi

echo "🌐 Abriendo Chrome en modo móvil..."
echo "📱 URL: http://localhost:8080/#/welcome"

# Tu comando exacto
open -na "Google Chrome" --args \
  --app="http://localhost:8080/#/welcome" \
  --window-size=412,915 \
  --window-position=60,60 \
  --user-data-dir="$HOME/Edge2024Profile"

echo "✅ Chrome abierto en modo móvil!"
echo "🔥 Hot Reload activado - guarda archivos para ver cambios"
echo "💡 Presiona Ctrl+S en VS Code para ver cambios instantáneos"
