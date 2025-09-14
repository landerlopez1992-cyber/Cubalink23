#!/bin/bash

# 🚀 SCRIPT PARA EJECUTAR DIRECTAMENTE EN MOTOROLA (SIN GRADLE)
# Usa Flutter Web pero accesible desde el navegador del Motorola

echo "🚀 CUBALINK23 - EJECUTAR EN MOTOROLA VIA USB"
echo "============================================="

# Configurar PATH de Flutter
export PATH="$PATH:/Users/cubcolexpress/flutter/bin"

# Verificar que Flutter esté disponible
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter no encontrado en el PATH"
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
    exit 1
fi

echo "✅ Motorola Edge 2024 detectado: $MOTOROLA_DEVICE"

# Obtener la IP local de tu Mac
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

echo ""
echo "🔧 Preparando dependencias..."
flutter pub get

echo ""
echo "📱 INSTRUCCIONES PARA TU MOTOROLA:"
echo "1. Conecta tu Motorola a la misma red WiFi que tu Mac"
echo "2. Abre el navegador en tu Motorola"
echo "3. Ve a: http://$LOCAL_IP:8080"
echo "4. ¡La app se verá con el diseño móvil correcto!"

echo ""
echo "🚀 Iniciando servidor web para Motorola..."

# Ejecutar en modo web accesible desde la red local
flutter run -d chrome --web-hostname=0.0.0.0 --web-port=8080

echo ""
echo "🏁 App web ejecutándose"
echo "📱 Accede desde tu Motorola: http://$LOCAL_IP:8080"
