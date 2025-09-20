#!/bin/bash

# ⚡ SCRIPT SÚPER RÁPIDO PARA TESTING DIARIO
# Este script hace: build + install en ambos dispositivos automáticamente

echo "⚡ CUBALINK23 - QUICK TEST"
echo "========================="

# Configuración
BUILD_TYPE=${1:-"debug"}  # debug por defecto, puede ser release

echo "🚀 Compilando APK ($BUILD_TYPE)..."
./tools/docker/build.sh $BUILD_TYPE

if [ $? -eq 0 ]; then
    echo "✅ Compilación exitosa!"
    echo "📱 Instalando en dispositivos..."
    ./tools/docker/install.sh $BUILD_TYPE
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 ¡LISTO PARA TESTING!"
        echo "📱 App instalada en:"
        echo "   - Emulador Samsung Galaxy S24"
        echo "   - Motorola Edge 2024"
        echo ""
        echo "🔧 Para probar cambios:"
        echo "   ./quick-test.sh debug"
    else
        echo "❌ Error instalando en dispositivos"
        exit 1
    fi
else
    echo "❌ Error en compilación"
    exit 1
fi











