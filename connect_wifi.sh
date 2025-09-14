#!/bin/bash

# Script para conectar Motorola Edge 2024 vía WiFi
# Autor: Asistente AI
# Fecha: $(date)

echo "🔗 Conectando Motorola Edge 2024 vía WiFi..."

# Configurar PATH para ADB
export PATH="/Users/cubcolexpress/Library/Android/sdk/platform-tools:$PATH"

# IP y puerto del dispositivo (desde la configuración de depuración inalámbrica)
DEVICE_IP="192.168.1.210"
DEVICE_PORT="42481"
FULL_ADDRESS="$DEVICE_IP:$DEVICE_PORT"

echo "📱 Conectando a $FULL_ADDRESS..."

# Conectar vía ADB
adb connect $FULL_ADDRESS

# Verificar conexión
echo "🔍 Verificando dispositivos conectados..."
adb devices

# Verificar que Flutter detecte el dispositivo
echo "📱 Verificando dispositivos Flutter..."
flutter devices

echo "✅ ¡Conexión WiFi configurada!"
echo "🚀 Para ejecutar la app, usa:"
echo "   flutter run --device-id=$FULL_ADDRESS"
echo ""
echo "💡 Consejos:"
echo "   - Asegúrate de que el dispositivo esté en la misma red WiFi"
echo "   - Mantén la depuración inalámbrica activada"
echo "   - Si cambias de red, actualiza la IP en este script"





