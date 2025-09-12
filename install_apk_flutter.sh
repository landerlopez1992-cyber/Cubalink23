#!/bin/bash

# 🚀 SCRIPT PARA INSTALAR APK USANDO FLUTTER (SIN GRADLE)
# Este script usa Flutter para instalar APK existente, evita análisis de Gradle

echo "🚀 CUBALINK23 - INSTALACIÓN APK CON FLUTTER (SIN GRADLE)"
echo "========================================================"

# Configurar PATH de Flutter
export PATH="$PATH:/Users/cubcolexpress/flutter/bin"

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

echo "📱 Instalando APK en Motorola usando Flutter..."
echo "   Archivo: $APK_FILE"
echo "   Dispositivo: $MOTOROLA_DEVICE"

# Usar Flutter para instalar el APK (evita análisis de Gradle)
flutter install --device-id="$MOTOROLA_DEVICE" "$APK_FILE"

if [ $? -eq 0 ]; then
    echo "✅ APK instalado exitosamente en tu Motorola!"
    echo "🎉 ¡La app CUBALINK23 está lista para usar!"
    echo ""
    echo "📱 Para abrir la app:"
    echo "   Busca 'Cubalink23' en tu Motorola y tócala"
else
    echo "❌ Error al instalar el APK"
    echo "   Intentando método alternativo..."
    
    # Método alternativo usando adb directamente
    echo "🔧 Usando método alternativo con adb..."
    
    # Buscar adb en Flutter
    ADB_PATH=""
    if [ -f "/Users/cubcolexpress/flutter/bin/cache/artifacts/engine/android-arm64/adb" ]; then
        ADB_PATH="/Users/cubcolexpress/flutter/bin/cache/artifacts/engine/android-arm64/adb"
    elif [ -f "/Users/cubcolexpress/flutter/bin/cache/artifacts/engine/android-x64/adb" ]; then
        ADB_PATH="/Users/cubcolexpress/flutter/bin/cache/artifacts/engine/android-x64/adb"
    fi
    
    if [ -n "$ADB_PATH" ]; then
        echo "📱 Instalando con adb directo..."
        "$ADB_PATH" install -r "$APK_FILE"
        
        if [ $? -eq 0 ]; then
            echo "✅ APK instalado exitosamente con adb!"
            echo "🎉 ¡La app CUBALINK23 está lista para usar!"
        else
            echo "❌ Error al instalar con adb también"
            exit 1
        fi
    else
        echo "❌ No se pudo encontrar adb"
        exit 1
    fi
fi

echo ""
echo "🏁 Proceso completado"
echo "📱 La app está instalada en tu Motorola Edge 2024"


