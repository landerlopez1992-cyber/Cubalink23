#!/bin/bash

echo "🚀 CubaLink23 - Modo Móvil (412x915)"
echo "===================================="
echo ""

# Detener procesos anteriores
echo "🧹 Limpiando procesos anteriores..."
pkill -f "flutter run" 2>/dev/null || true
pkill -f "Google Chrome.*localhost:8080" 2>/dev/null || true

# Iniciar Flutter
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

# Abrir Chrome en modo móvil
echo "📱 Abriendo Chrome en modo móvil..."
echo "   Dimensiones: 412x915"
echo "   Posición: 60,60"
echo "   URL: http://localhost:8080/#/welcome"

open -na "Google Chrome" --args \
  --app="http://localhost:8080/#/welcome" \
  --window-size=412,915 \
  --window-position=60,60 \
  --user-data-dir="$HOME/Edge2024Profile"

echo ""
echo "✅ ¡Listo! Chrome abierto en modo móvil"
echo "🔥 Hot Reload activado"
echo "💡 Guarda archivos (Ctrl+S) para ver cambios instantáneos"
echo ""
echo "🎯 Para detener: Ctrl+C en esta terminal"
echo "🔄 Para reiniciar: Ejecuta este script de nuevo"

# Mantener el script ejecutándose
wait $FLUTTER_PID
