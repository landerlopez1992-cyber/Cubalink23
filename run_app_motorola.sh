#!/bin/bash

# 🚀 SCRIPT COMPLETO PARA EJECUTAR APP EN MOTOROLA (SIN GRADLE)
# Este script descarga e instala la app automáticamente

echo "🚀 CUBALINK23 - EJECUTAR APP EN MOTOROLA"
echo "========================================"

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
    exit 1
fi

echo "✅ Motorola Edge 2024 detectado: $MOTOROLA_DEVICE"

# Verificar si ya existe un APK descargado
if [ ! -f "./apk_downloads/app-release.apk" ]; then
    echo ""
    echo "📥 Descargando APK desde GitHub Actions..."
    
    # Crear directorio para APK
    mkdir -p ./apk_downloads
    cd ./apk_downloads
    
    # Descargar APK
    curl -L -o "app-release.apk" "https://github.com/landerlopez1992-cyber/Cubalink23/actions/runs/latest/downloads/app-release" -H "Accept: application/octet-stream" --silent --show-error
    
    if [ $? -eq 0 ] && [ -f "app-release.apk" ] && [ -s "app-release.apk" ]; then
        echo "✅ APK descargado exitosamente"
        cd ..
    else
        echo "❌ Error al descargar APK"
        cd ..
        exit 1
    fi
else
    echo "✅ APK ya existe, usando versión descargada"
fi

echo ""
echo "📱 Instalando APK en Motorola Edge 2024..."

# Instalar APK usando adb
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

