#!/bin/bash

echo "📱 CubaLink23 - Chrome Móvil (412x915)"
echo "====================================="
echo ""

# Limpiar procesos anteriores
echo "🧹 Limpiando procesos anteriores..."
pkill -f "flutter run" 2>/dev/null || true
pkill -f "Google Chrome" 2>/dev/null || true

echo "🔥 Iniciando Flutter..."
flutter run -d chrome --web-port 8080 &
FLUTTER_PID=$!

# Esperar a que Flutter esté listo
echo "⏳ Esperando a que Flutter esté listo..."
for i in {1..30}; do
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo "✅ Flutter listo!"
        break
    fi
    sleep 2
    echo "⏳ Esperando... ($i/30)"
done

echo "⏳ Esperando 4 segundos para que Flutter abra su Chrome..."
sleep 4

echo "🧹 Cerrando Chrome grande de Flutter..."
pkill -f "Google Chrome.*localhost:8080" 2>/dev/null || true

echo "⏳ Esperando 2 segundos..."
sleep 2

echo "📱 Abriendo Chrome en modo móvil..."
echo "   Dimensiones: 412x915 (iPhone)"
echo "   Posición: 60,60"

# Tu comando exacto
open -na "Google Chrome" --args \
  --app="http://localhost:8080/#/welcome" \
  --window-size=412,915 \
  --window-position=60,60 \
  --user-data-dir="$HOME/Edge2024Profile"

echo ""
echo "✅ ¡Listo! Chrome móvil abierto"
echo "🔥 Hot Reload activado"
echo "💡 Guarda archivos (Ctrl+S) para ver cambios instantáneos"
echo ""
echo "🎯 Para detener: Ctrl+C en esta terminal"

# Mantener el script ejecutándose
wait $FLUTTER_PID
