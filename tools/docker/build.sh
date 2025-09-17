#!/bin/bash

# 🚀 Script de compilación Android con Docker para CubaLink23
# Este script garantiza compilaciones consistentes sin dependencias locales

set -e  # Salir si hay algún error

echo "🚀 CUBALINK23 - COMPILACIÓN ANDROID CON DOCKER"
echo "=============================================="

# Configuración
IMAGE_NAME="cubalink23-android-builder"
CONTAINER_NAME="cubalink23-android-builder"
BUILD_TYPE=${1:-"debug"}  # debug o release

echo "📱 Tipo de compilación: $BUILD_TYPE"

# Verificar que Docker esté ejecutándose
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker no está ejecutándose"
    echo "   Por favor inicia Docker Desktop"
    exit 1
fi

echo "✅ Docker está ejecutándose"

# Construir la imagen si no existe
if ! docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
    echo "🏗️ Construyendo imagen Docker..."
    docker build -t $IMAGE_NAME -f tools/docker/Dockerfile .
    echo "✅ Imagen Docker construida exitosamente"
else
    echo "✅ Imagen Docker ya existe"
fi

# Crear directorio de salida si no existe
mkdir -p build/outputs/docker

# Ejecutar compilación en Docker
echo "🔨 Compilando APK en Docker..."
docker run --rm \
    -v "$(pwd):/workspace" \
    -w /workspace \
    --name $CONTAINER_NAME \
    $IMAGE_NAME \
    bash -c "
        echo '📦 Instalando dependencias...'
        flutter pub get
        
        echo '🧹 Limpiando build anterior...'
        flutter clean
        
        echo '🏗️ Compilando APK ($BUILD_TYPE)...'
        if [ '$BUILD_TYPE' = 'release' ]; then
            flutter build apk --release --no-tree-shake-icons
        else
            flutter build apk --debug --no-tree-shake-icons
        fi
        
        echo '📁 Copiando APK a directorio de salida...'
        cp build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk build/outputs/docker/
        
        echo '✅ Compilación completada exitosamente'
        ls -la build/outputs/docker/
    "

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 ¡COMPILACIÓN EXITOSA!"
    echo "📱 APK generado: build/outputs/docker/app-$BUILD_TYPE.apk"
    echo ""
    echo "📊 Información del APK:"
    ls -la build/outputs/docker/app-$BUILD_TYPE.apk
    echo ""
    echo "🚀 Para instalar en dispositivo:"
    echo "   adb install build/outputs/docker/app-$BUILD_TYPE.apk"
else
    echo "❌ Error en la compilación"
    exit 1
fi







