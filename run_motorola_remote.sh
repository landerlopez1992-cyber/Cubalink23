#!/bin/bash

# 🚀 SCRIPT PARA EJECUTAR CUBALINK23 EN MOTOROLA DESDE REPOSITORIO REMOTO
# Este script sincroniza el código desde la nube y ejecuta la app en tu Motorola

echo "🚀 CUBALINK23 - EJECUCIÓN EN MOTOROLA EDGE 2024"
echo "================================================"

# Configurar PATH de Flutter
export PATH="$PATH:/Users/cubcolexpress/flutter/bin"

# Verificar que Flutter esté disponible
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter no encontrado en el PATH"
    echo "   Asegúrate de que Flutter esté instalado en /Users/cubcolexpress/flutter/bin"
    exit 1
fi

echo "📱 Verificando conexión con Motorola..."
MOTOROLA_DEVICE=$(flutter devices | grep "motorola edge 2024" | awk '{print $4}')

if [ -z "$MOTOROLA_DEVICE" ]; then
    echo "❌ Error: Motorola Edge 2024 no detectado"
    echo "   Asegúrate de que:"
    echo "   1. El dispositivo esté conectado por USB"
    echo "   2. La depuración USB esté habilitada"
    echo "   3. Hayas autorizado la conexión en el dispositivo"
    echo ""
    echo "📋 Dispositivos disponibles:"
    flutter devices
    exit 1
fi

echo "✅ Motorola Edge 2024 detectado: $MOTOROLA_DEVICE"

echo ""
echo "🔄 Sincronizando repositorio remoto..."
echo "   Rama: build-test"
echo "   Repositorio: origin"

# Sincronizar con el repositorio remoto
git fetch origin
if [ $? -ne 0 ]; then
    echo "❌ Error al sincronizar con el repositorio remoto"
    exit 1
fi

# Resetear al estado remoto
git reset --hard origin/build-test
if [ $? -ne 0 ]; then
    echo "❌ Error al resetear al estado remoto"
    exit 1
fi

echo "✅ Repositorio sincronizado con origin/build-test"

echo ""
echo "🧹 Limpiando build anterior..."
flutter clean

echo ""
echo "📦 Obteniendo dependencias..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Error al obtener dependencias"
    exit 1
fi

echo ""
echo "🚀 Ejecutando app en Motorola Edge 2024..."
echo "   Dispositivo: $MOTOROLA_DEVICE"
echo "   Modo: Debug"
echo ""

# Ejecutar la app en el Motorola
flutter run --device-id="$MOTOROLA_DEVICE" --debug

echo ""
echo "🏁 Ejecución completada"




