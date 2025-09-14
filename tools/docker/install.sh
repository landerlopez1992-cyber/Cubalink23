#!/bin/bash

# 📱 Script de instalación Android con Docker para CubaLink23
# Este script instala el APK compilado en dispositivos conectados

set -e  # Salir si hay algún error

echo "📱 CUBALINK23 - INSTALACIÓN ANDROID CON DOCKER"
echo "=============================================="

# Configuración
BUILD_TYPE=${1:-"debug"}  # debug o release
APK_PATH="build/outputs/docker/app-$BUILD_TYPE.apk"

echo "📱 Tipo de APK: $BUILD_TYPE"
echo "📁 Ruta del APK: $APK_PATH"

# Verificar que el APK existe
if [ ! -f "$APK_PATH" ]; then
    echo "❌ Error: APK no encontrado en $APK_PATH"
    echo "   Ejecuta primero: ./tools/docker/build.sh $BUILD_TYPE"
    exit 1
fi

echo "✅ APK encontrado: $APK_PATH"

# Verificar que ADB esté disponible
if ! command -v adb &> /dev/null; then
    echo "❌ Error: ADB no encontrado"
    echo "   Instala Android SDK Platform Tools"
    exit 1
fi

echo "✅ ADB disponible"

# Verificar dispositivos conectados
echo "🔍 Verificando dispositivos conectados..."
DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)

if [ $DEVICES -eq 0 ]; then
    echo "❌ Error: No hay dispositivos Android conectados"
    echo "   Conecta tu dispositivo y habilita la depuración USB"
    exit 1
fi

echo "✅ Dispositivos conectados: $DEVICES"

# Mostrar dispositivos
echo "📱 Dispositivos disponibles:"
adb devices

# Instalar APK en todos los dispositivos conectados
echo "📦 Instalando APK en dispositivos conectados..."

adb devices | grep -v "List of devices" | grep "device$" | while read device_id status; do
    if [ "$status" = "device" ]; then
        echo "📱 Instalando en dispositivo: $device_id"
        
        # Desinstalar versión anterior si existe
        adb -s $device_id uninstall com.cubalink23.cubalink23 2>/dev/null || true
        
        # Instalar nueva versión
        if adb -s $device_id install "$APK_PATH"; then
            echo "✅ Instalación exitosa en $device_id"
            
            # Opcional: abrir la aplicación
            echo "🚀 Abriendo aplicación..."
            adb -s $device_id shell am start -n com.cubalink23.cubalink23/.MainActivity
        else
            echo "❌ Error instalando en $device_id"
        fi
    fi
done

echo ""
echo "🎉 ¡INSTALACIÓN COMPLETADA!"
echo "📱 La aplicación CubaLink23 está instalada en todos los dispositivos"
echo ""
echo "🔧 Para verificar la instalación:"
echo "   adb shell pm list packages | grep cubalink"
