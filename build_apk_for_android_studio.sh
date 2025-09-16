#!/bin/bash

# Script para compilar APK y configurar Android Studio
echo "🚀 Compilando APK para Android Studio..."

# Limpiar proyecto
echo "🧹 Limpiando proyecto..."
flutter clean

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Compilar APK
echo "🔨 Compilando APK..."
cd android && ./gradlew assembleDebug

# Verificar que el APK se generó
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "✅ APK generado exitosamente!"
    echo "📍 Ubicación: $(pwd)/app/build/outputs/apk/debug/app-debug.apk"
    
    # Copiar APK a la ubicación que espera Flutter
    echo "📋 Copiando APK a ubicación esperada por Flutter..."
    mkdir -p ../../build/app/outputs/flutter-apk
    cp app/build/outputs/apk/debug/app-debug.apk ../../build/app/outputs/flutter-apk/
    
    echo "🎉 ¡APK listo para Android Studio!"
    echo "📱 Tamaño: $(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)"
else
    echo "❌ Error: No se pudo generar el APK"
    exit 1
fi
