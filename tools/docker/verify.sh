#!/bin/bash

# 🔍 Script de verificación para CubaLink23 Docker Setup
# Este script verifica que toda la configuración esté correcta

echo "🔍 CUBALINK23 - VERIFICACIÓN DOCKER SETUP"
echo "========================================"

# Configuración
IMAGE_NAME="cubalink23-android-builder"
CONTAINER_NAME="cubalink23-android-builder"

# Función para verificar archivos
check_file() {
    if [ -f "$1" ]; then
        echo "✅ $1"
        return 0
    else
        echo "❌ $1 (FALTANTE)"
        return 1
    fi
}

# Función para verificar permisos
check_permissions() {
    if [ -x "$1" ]; then
        echo "✅ Permisos: $1"
        return 0
    else
        echo "❌ Permisos: $1 (NO EJECUTABLE)"
        return 1
    fi
}

echo ""
echo "📁 Verificando estructura de archivos..."
echo "========================================"

# Verificar archivos principales
check_file "Dockerfile"
check_file "docker-compose.yml"
check_file ".dockerignore"
check_file "build.sh"
check_file "install.sh"
check_file "run.sh"
check_file "verify.sh"
check_file "README.md"

echo ""
echo "🔧 Verificando permisos de ejecución..."
echo "======================================"

# Verificar permisos
check_permissions "build.sh"
check_permissions "install.sh"
check_permissions "run.sh"
check_permissions "verify.sh"

echo ""
echo "🐳 Verificando Docker..."
echo "======================="

# Verificar Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker instalado: $(docker --version)"
else
    echo "❌ Docker no encontrado"
    exit 1
fi

# Verificar Docker daemon
if docker info > /dev/null 2>&1; then
    echo "✅ Docker daemon ejecutándose"
else
    echo "❌ Docker daemon no ejecutándose"
    exit 1
fi

# Verificar imagen
if docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
    echo "✅ Imagen Docker construida: $IMAGE_NAME"
else
    echo "⚠️  Imagen Docker no construida aún"
    echo "   Ejecuta: docker build -t $IMAGE_NAME -f Dockerfile ."
fi

echo ""
echo "📱 Verificando herramientas Android..."
echo "===================================="

# Verificar ADB
if command -v adb &> /dev/null; then
    echo "✅ ADB disponible: $(adb version | head -n1)"
else
    echo "⚠️  ADB no encontrado (opcional para compilación)"
fi

echo ""
echo "📊 Resumen de verificación..."
echo "============================"

# Contar archivos verificados
TOTAL_FILES=8
EXISTING_FILES=$(ls -1 Dockerfile docker-compose.yml .dockerignore build.sh install.sh run.sh verify.sh README.md 2>/dev/null | wc -l)

echo "📁 Archivos creados: $EXISTING_FILES/$TOTAL_FILES"

if [ $EXISTING_FILES -eq $TOTAL_FILES ]; then
    echo "🎉 ¡TODA LA ESTRUCTURA DOCKER ESTÁ COMPLETA!"
    echo ""
    echo "🚀 Próximos pasos:"
    echo "   1. Construir imagen: docker build -t $IMAGE_NAME -f Dockerfile ."
    echo "   2. Probar compilación: ./build.sh debug"
    echo "   3. Instalar en dispositivo: ./install.sh debug"
    echo ""
    echo "📖 Documentación completa: README.md"
else
    echo "❌ Algunos archivos faltan. Revisa la estructura."
    exit 1
fi







