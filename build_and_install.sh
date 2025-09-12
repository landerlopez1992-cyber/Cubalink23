#!/bin/bash

# 🚀 SCRIPT PARA COMPILAR E INSTALAR EN MOTOROLA (MÉTODO SIMPLE)
# Este script evita los problemas de Gradle compilando de forma básica

echo "🚀 CUBALINK23 - COMPILAR E INSTALAR EN MOTOROLA"
echo "==============================================="

# Configurar PATH completo
export PATH="$PATH:/Users/cubcolexpress/flutter/bin:/Users/cubcolexpress/Library/Android/sdk/platform-tools"

# Verificar que Flutter esté disponible
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter no encontrado en el PATH"
    exit 1
fi

echo "📱 Verificando conexión con Motorola..."
MOTOROLA_DEVICE=$(flutter devices | grep "motorola edge 2024" | awk '{print $4}')

if [ -z "$MOTOROLA_DEVICE" ]; then
    echo "❌ Error: Motorola Edge 2024 no detectado"
    echo "   Asegúrate de que:"
    echo "   1. El dispositivo esté conectado por USB"
    echo "   2. La depuración USB esté habilitada"
    echo "   3. Hayas autorizado la conexión en el dispositivo"
    exit 1
fi

echo "✅ Motorola Edge 2024 detectado: $MOTOROLA_DEVICE"

echo ""
echo "🔧 Preparando dependencias..."
flutter pub get

echo ""
echo "🏗️ Compilando APK (método básico)..."
# Usar el método más simple posible
flutter build apk --debug --no-tree-shake-icons --no-shrink

if [ $? -eq 0 ]; then
    echo "✅ APK compilado exitosamente"
    
    # Buscar el APK generado
    APK_PATH=""
    if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
        APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
    elif [ -f "build/app/outputs/apk/debug/app-debug.apk" ]; then
        APK_PATH="build/app/outputs/apk/debug/app-debug.apk"
    fi
    
    if [ -n "$APK_PATH" ]; then
        echo "✅ APK encontrado: $APK_PATH"
        
        echo ""
        echo "📱 Instalando APK en Motorola Edge 2024..."
        adb install -r "$APK_PATH"
        
        if [ $? -eq 0 ]; then
            echo "✅ APK instalado exitosamente en tu Motorola!"
            echo "🎉 ¡La app CUBALINK23 está lista para usar!"
            echo ""
            echo "📱 Para abrir la app:"
            echo "   Busca 'Cubalink23' en tu Motorola y tócala"
        else
            echo "❌ Error al instalar el APK"
            exit 1
        fi
    else
        echo "❌ No se encontró el APK compilado"
        exit 1
    fi
else
    echo "❌ Error al compilar el APK"
    exit 1
fi

echo ""
echo "🏁 Proceso completado"
echo "📱 La app está instalada en tu Motorola Edge 2024"
