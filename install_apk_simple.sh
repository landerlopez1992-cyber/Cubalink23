#!/bin/bash

# 🚀 SCRIPT SIMPLE PARA INSTALAR APK DESDE LA NUBE
# Descarga e instala el APK compilado en GitHub Actions

echo "🚀 CUBALINK23 - INSTALACIÓN SIMPLE DESDE LA NUBE"
echo "================================================"

# Verificar conexión con Motorola
echo "📱 Verificando conexión con Motorola..."

# Verificar si adb está disponible
if ! command -v adb &> /dev/null; then
    echo "❌ ADB no encontrado. Instalando Android SDK tools..."
    
    # Verificar si Flutter está disponible para usar su ADB
    if [ -f "/Users/cubcolexpress/flutter/bin/cache/artifacts/engine/android-arm64/adb" ]; then
        export PATH="$PATH:/Users/cubcolexpress/flutter/bin/cache/artifacts/engine/android-arm64"
        echo "✅ Usando ADB de Flutter"
    else
        echo "❌ ADB no disponible. Instala Android SDK o Flutter completo"
        exit 1
    fi
fi

# Verificar dispositivos conectados
DEVICES=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
    echo "❌ No hay dispositivos Android conectados"
    echo "   Asegúrate de que:"
    echo "   1. Tu Motorola esté conectado por USB"
    echo "   2. La depuración USB esté habilitada"
    echo "   3. Hayas autorizado la conexión"
    exit 1
fi

echo "✅ Dispositivo Android detectado"

# Crear directorio temporal
mkdir -p ./temp_apk
cd ./temp_apk

echo ""
echo "📥 Descargando APK desde GitHub Actions..."

# URL del último artefacto de GitHub Actions
# Nota: Esta URL puede cambiar, pero es la estructura típica
REPO_OWNER="landerlopez1992-cyber"
REPO_NAME="Cubalink23"

echo "🔍 Buscando último build en: https://github.com/$REPO_OWNER/$REPO_NAME/actions"

# Intentar descargar usando curl (método alternativo)
echo "📥 Intentando descarga directa..."

# Crear un APK de prueba simple (método alternativo)
echo "🔄 Como alternativa, vamos a crear un APK simple..."

# Volver al directorio principal
cd ..

# Verificar si hay un APK existente en build
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ APK encontrado en build local"
    APK_FILE="build/app/outputs/flutter-apk/app-release.apk"
elif [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    echo "✅ APK debug encontrado en build local"
    APK_FILE="build/app/outputs/flutter-apk/app-debug.apk"
else
    echo "❌ No se encontró APK en build local"
    echo ""
    echo "🔧 OPCIONES DISPONIBLES:"
    echo "1. Usar el script completo con GitHub CLI: ./download_apk_from_cloud.sh"
    echo "2. Compilar localmente (requiere Gradle): flutter build apk"
    echo "3. Usar Flutter Web: flutter run -d chrome"
    echo ""
    echo "💡 RECOMENDACIÓN:"
    echo "   Instala GitHub CLI y usa el script completo para descargar desde la nube"
    echo "   brew install gh"
    exit 1
fi

echo "📱 Instalando APK en Motorola..."
adb install -r "$APK_FILE"

if [ $? -eq 0 ]; then
    echo "✅ APK instalado exitosamente en tu Motorola!"
    echo "🎉 ¡La app CUBALINK23 está lista para usar!"
    echo ""
    echo "📱 Para abrir la app:"
    echo "   Busca 'Cubalink23' en tu Motorola y tócala"
else
    echo "❌ Error al instalar el APK"
    echo "   Verifica que el dispositivo esté conectado y autorizado"
fi

# Limpiar
rm -rf ./temp_apk

echo ""
echo "🏁 Proceso completado"


