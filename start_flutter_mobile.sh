#!/bin/bash

echo "🚀 CubaLink23 - Inicio Automático Móvil"
echo "======================================"
echo ""

# Función para limpiar procesos
cleanup() {
    echo ""
    echo "🧹 Limpiando procesos..."
    pkill -f "flutter run" 2>/dev/null || true
    pkill -f "Google Chrome.*localhost:8080" 2>/dev/null || true
    exit 0
}

# Capturar Ctrl+C
trap cleanup SIGINT

# Limpiar procesos anteriores
echo "🧹 Limpiando procesos anteriores..."
pkill -f "flutter run" 2>/dev/null || true
pkill -f "Google Chrome.*localhost:8080" 2>/dev/null || true

# Verificar que Flutter esté disponible
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado o no está en el PATH"
    exit 1
fi

# Verificar dispositivos
echo "🔍 Verificando dispositivos disponibles..."
flutter devices

echo ""
echo "🔥 Iniciando Flutter en modo web..."
echo "⏳ Esto puede tomar unos segundos..."

# Iniciar Flutter en background
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

# Verificar que Flutter esté realmente funcionando
if ! curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo "❌ Flutter no se inició correctamente"
    kill $FLUTTER_PID 2>/dev/null || true
    exit 1
fi

echo ""
echo "📱 Abriendo Chrome en modo móvil..."
echo "   Dimensiones: 412x915 (iPhone)"
echo "   Posición: 60,60"
echo "   URL: http://localhost:8080/#/welcome"

# Abrir Chrome en modo móvil
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
echo ""

# Mantener el script ejecutándose y mostrar logs
wait $FLUTTER_PID
