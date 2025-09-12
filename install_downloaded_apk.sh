#!/bin/bash

# 🚀 SCRIPT PARA INSTALAR APK DESCARGADO
# Instala el APK que se descargó previamente

echo "🚀 CUBALINK23 - INSTALAR APK DESCARGADO"
echo "======================================="

# Configurar PATH de Flutter
export PATH="$PATH:/Users/cubcolexpress/flutter/bin"

# Configurar PATH completo
export PATH="$PATH:/Users/cubcolexpress/flutter/bin:/Users/cubcolexpress/Library/Android/sdk/platform-tools"

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
    echo ""
    echo "📋 Dispositivos disponibles:"
    flutter devices
    exit 1
fi

echo "✅ Motorola Edge 2024 detectado: $MOTOROLA_DEVICE"

# Verificar que el APK existe
if [ ! -f "./apk_downloads/app-release.apk" ]; then
    echo "❌ No se encontró APK descargado"
    echo "   Ejecuta primero: ./download_apk_standalone.sh"
    exit 1
fi

echo "✅ APK encontrado: ./apk_downloads/app-release.apk"

echo ""
echo "📱 Instalando APK en Motorola Edge 2024..."

# Usar adb directamente (más confiable)
echo "📱 Instalando con adb directo..."
adb install -r "./apk_downloads/app-release.apk"

if [ $? -eq 0 ]; then
    echo "✅ APK instalado exitosamente en tu Motorola!"
    echo "🎉 ¡La app CUBALINK23 está lista para usar!"
    echo ""
    echo "📱 Para abrir la app:"
    echo "   Busca 'Cubalink23' en tu Motorola y tócala"
else
    echo "❌ Error al instalar el APK"
    echo "   Verifica que el dispositivo esté conectado y autorizado"
    exit 1
fi

echo ""
echo "🏁 Proceso completado"
echo "📱 La app está instalada en tu Motorola Edge 2024"
