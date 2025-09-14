#!/bin/bash

echo "🚀 Instalando Cubalink23 APK en Motorola..."
echo "=============================================="

# Verificar que ADB esté disponible
if ! command -v adb &> /dev/null; then
    echo "❌ ADB no está instalado. Instalando..."
    brew install android-platform-tools
fi

# Verificar dispositivos conectados
echo "📱 Verificando dispositivos conectados..."
adb devices

# Esperar a que el usuario conecte el dispositivo
echo ""
echo "⚠️  Asegúrate de que tu Motorola esté conectado y con depuración USB activada"
echo "   Presiona ENTER cuando esté listo..."
read

# Verificar nuevamente
DEVICES=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)
if [ $DEVICES -eq 0 ]; then
    echo "❌ No se detectó ningún dispositivo. Verifica la conexión USB y depuración."
    exit 1
fi

echo "✅ Dispositivo detectado. Instalando APK..."

# Instalar el APK
APK_PATH="./android/app/build/outputs/apk/debug/app-debug.apk"

if [ ! -f "$APK_PATH" ]; then
    echo "❌ APK no encontrado en: $APK_PATH"
    exit 1
fi

echo "📦 Instalando: $APK_PATH"
adb install -r "$APK_PATH"

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 ¡Instalación exitosa!"
    echo "📱 La app Cubalink23 ya está disponible en tu Motorola"
    echo ""
    echo "🔍 Para abrir la app:"
    echo "   adb shell am start -n com.cubalink23.app/.MainActivity"
else
    echo "❌ Error en la instalación. Verifica los permisos del dispositivo."
fi







