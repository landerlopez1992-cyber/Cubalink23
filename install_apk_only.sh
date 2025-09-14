#!/bin/bash

# 🚀 SCRIPT PARA INSTALAR APK SIN ANÁLISIS DE GRADLE
# Este script solo instala APK existente, evita completamente Gradle

echo "🚀 CUBALINK23 - INSTALACIÓN APK (SIN GRADLE)"
echo "============================================="

# Verificar conexión con Motorola usando adb directamente
echo "📱 Verificando conexión con Motorola..."

# Usar adb directamente (evita Flutter)
if command -v adb &> /dev/null; then
    ADB_CMD="adb"
elif [ -f "/Users/cubcolexpress/flutter/bin/cache/artifacts/engine/android-arm64/adb" ]; then
    ADB_CMD="/Users/cubcolexpress/flutter/bin/cache/artifacts/engine/android-arm64/adb"
else
    echo "❌ ADB no encontrado"
    echo "   Instalando Android SDK tools..."
    # Intentar usar el ADB de Flutter
    export PATH="$PATH:/Users/cubcolexpress/flutter/bin/cache/artifacts/engine/android-arm64"
    ADB_CMD="adb"
fi

# Verificar dispositivos
DEVICES=$($ADB_CMD devices | grep -v "List of devices" | grep -v "^$" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
    echo "❌ No hay dispositivos Android conectados"
    echo "   Asegúrate de que:"
    echo "   1. Tu Motorola esté conectado por USB"
    echo "   2. La depuración USB esté habilitada"
    echo "   3. Hayas autorizado la conexión"
    exit 1
fi

echo "✅ Dispositivo Android detectado"

# Buscar APK existente
echo ""
echo "🔍 Buscando APK existente..."

APK_FILE=""

# Buscar en diferentes ubicaciones
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    APK_FILE="build/app/outputs/flutter-apk/app-release.apk"
    echo "✅ APK release encontrado"
elif [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    APK_FILE="build/app/outputs/flutter-apk/app-debug.apk"
    echo "✅ APK debug encontrado"
elif [ -f "app-release.apk" ]; then
    APK_FILE="app-release.apk"
    echo "✅ APK encontrado en directorio raíz"
elif [ -f "app-debug.apk" ]; then
    APK_FILE="app-debug.apk"
    echo "✅ APK debug encontrado en directorio raíz"
else
    echo "❌ No se encontró APK existente"
    echo ""
    echo "🔧 OPCIONES DISPONIBLES:"
    echo "1. Descargar desde GitHub Actions: ./download_apk_from_cloud.sh"
    echo "2. Usar Flutter Web: flutter run -d chrome"
    echo "3. Compilar localmente (requiere Gradle): flutter build apk"
    echo ""
    echo "💡 RECOMENDACIÓN:"
    echo "   Usa el script de GitHub Actions para descargar desde la nube"
    exit 1
fi

echo "📱 Instalando APK en Motorola..."
echo "   Archivo: $APK_FILE"

# Instalar APK
$ADB_CMD install -r "$APK_FILE"

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


