#!/bin/bash

# Script para compilar e instalar en Motorola
echo "🚀 Compilando para Motorola Edge 2024..."

# Compilar APK
cd android && ./gradlew assembleDebug

if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "✅ APK compilado!"
    
    # Desinstalar versión anterior
    echo "🗑️ Desinstalando versión anterior..."
    adb -s ZY22L2BWH6 uninstall com.cubalink23.cubalink23
    
    # Instalar nueva versión
    echo "📱 Instalando en Motorola..."
    adb -s ZY22L2BWH6 install app/build/outputs/apk/debug/app-debug.apk
    
    # Lanzar app
    echo "🚀 Lanzando TureCarga..."
    adb -s ZY22L2BWH6 shell am start -n com.cubalink23.cubalink23/.MainActivity
    
    echo "🎉 ¡Listo! TureCarga corriendo en tu Motorola"
else
    echo "❌ Error en compilación"
fi
