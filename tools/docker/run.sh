#!/bin/bash

# 🏃 Script para ejecutar CubaLink23 en Docker
# Este script inicia un contenedor interactivo para desarrollo

set -e  # Salir si hay algún error

echo "🏃 CUBALINK23 - EJECUTAR EN DOCKER"
echo "=================================="

# Configuración
IMAGE_NAME="cubalink23-android-builder"
CONTAINER_NAME="cubalink23-android-builder"

# Verificar que Docker esté ejecutándose
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker no está ejecutándose"
    echo "   Por favor inicia Docker Desktop"
    exit 1
fi

echo "✅ Docker está ejecutándose"

# Verificar que la imagen existe
if ! docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
    echo "❌ Error: Imagen Docker no encontrada"
    echo "   Ejecuta primero: ./tools/docker/build.sh"
    exit 1
fi

echo "✅ Imagen Docker encontrada"

# Detener contenedor existente si está ejecutándose
if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
    echo "🛑 Deteniendo contenedor existente..."
    docker stop $CONTAINER_NAME
fi

# Remover contenedor existente si existe
if docker ps -aq -f name=$CONTAINER_NAME | grep -q .; then
    echo "🗑️ Removiendo contenedor existente..."
    docker rm $CONTAINER_NAME
fi

# Crear directorio de salida
mkdir -p build/outputs/docker

echo "🚀 Iniciando contenedor Docker..."
echo "📁 Montando proyecto en /workspace"
echo "🔧 Usuario: flutter"
echo ""

# Ejecutar contenedor interactivo
docker run -it --rm \
    -v "$(pwd):/workspace" \
    -w /workspace \
    --name $CONTAINER_NAME \
    -p 8080:8080 \
    $IMAGE_NAME \
    bash -c "
        echo '🎉 ¡Contenedor Docker iniciado exitosamente!'
        echo '📱 CubaLink23 Android Builder'
        echo '================================'
        echo ''
        echo '📁 Directorio de trabajo: /workspace'
        echo '👤 Usuario: flutter'
        echo '🔧 Flutter version:'
        flutter --version
        echo ''
        echo '📱 Android SDK:'
        echo '   ANDROID_HOME: \$ANDROID_HOME'
        echo '   ANDROID_SDK_ROOT: \$ANDROID_SDK_ROOT'
        echo ''
        echo '🚀 Comandos disponibles:'
        echo '   flutter pub get          - Instalar dependencias'
        echo '   flutter clean            - Limpiar build'
        echo '   flutter build apk --debug - Compilar APK debug'
        echo '   flutter build apk --release - Compilar APK release'
        echo '   flutter doctor           - Verificar configuración'
        echo ''
        echo '💡 Tip: Los archivos se sincronizan automáticamente'
        echo '   entre tu máquina local y el contenedor'
        echo ''
        bash
    "
