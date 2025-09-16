#!/bin/bash

# Script para configurar Android Studio y compilar APK
echo "🚀 Configurando Android Studio para encontrar APK..."

# Crear directorio de build personalizado
mkdir -p build/app/outputs/flutter-apk

# Compilar con Gradle directamente
echo "🔨 Compilando con Gradle..."
cd android && ./gradlew assembleDebug

# Verificar compilación
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "✅ APK compilado exitosamente!"
    
    # Copiar a ubicación esperada por Flutter
    echo "📋 Copiando APK a ubicación de Flutter..."
    cp app/build/outputs/apk/debug/app-debug.apk ../build/app/outputs/flutter-apk/
    
    # También copiar a la raíz del proyecto para fácil acceso
    cp app/build/outputs/apk/debug/app-debug.apk ../turecarga-debug.apk
    
    echo "🎉 ¡APK listo!"
    echo "📍 Ubicaciones:"
    echo "   - Flutter: build/app/outputs/flutter-apk/app-debug.apk"
    echo "   - Fácil acceso: turecarga-debug.apk"
    echo "📱 Tamaño: $(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)"
    
    # Instalar automáticamente si hay dispositivo conectado
    if adb devices | grep -q "device$"; then
        echo "📱 Instalando en dispositivo conectado..."
        adb install app/build/outputs/apk/debug/app-debug.apk
        echo "🚀 Lanzando aplicación..."
        adb shell am start -n com.cubalink23.cubalink23/.MainActivity
    fi
else
    echo "❌ Error en la compilación"
    exit 1
fi
