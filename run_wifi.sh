#!/bin/bash

# Script para conectar y ejecutar app en Motorola Edge 2024 vía WiFi
# Autor: Asistente AI
# Fecha: $(date)

echo "🚀 Iniciando Cubalink23 en Motorola Edge 2024 vía WiFi..."

# Configurar PATH para ADB
export PATH="/Users/cubcolexpress/Library/Android/sdk/platform-tools:$PATH"

# IP y puerto del dispositivo
DEVICE_IP="192.168.1.210"
DEVICE_PORT="42481"
FULL_ADDRESS="$DEVICE_IP:$DEVICE_PORT"

echo "📱 Conectando a $FULL_ADDRESS..."

# Conectar vía ADB
adb connect $FULL_ADDRESS

# Esperar un momento para que se establezca la conexión
sleep 2

# Verificar que el dispositivo esté conectado
if adb devices | grep -q "$FULL_ADDRESS.*device"; then
    echo "✅ Dispositivo conectado exitosamente"
    
    # Ejecutar la app
    echo "🚀 Ejecutando Cubalink23..."
    flutter run --device-id=$FULL_ADDRESS
else
    echo "❌ Error: No se pudo conectar al dispositivo"
    echo "🔍 Verificando dispositivos disponibles..."
    adb devices
    echo ""
    echo "💡 Soluciones posibles:"
    echo "   1. Verifica que la depuración inalámbrica esté activada"
    echo "   2. Asegúrate de estar en la misma red WiFi"
    echo "   3. Revisa que la IP del dispositivo no haya cambiado"
    echo "   4. Reinicia la depuración inalámbrica en el dispositivo"
fi





