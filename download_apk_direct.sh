#!/bin/bash

# 🚀 SCRIPT PARA DESCARGAR APK DIRECTAMENTE DESDE GITHUB ACTIONS
# Usa curl para descargar sin necesidad de GitHub CLI

echo "🚀 CUBALINK23 - DESCARGAR APK DESDE GITHUB ACTIONS"
echo "=================================================="

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

echo ""
echo "🔄 Verificando último build en GitHub Actions..."

# URL del repositorio
REPO_OWNER="landerlopez1992-cyber"
REPO_NAME="Cubalink23"

echo "   Repositorio: $REPO_OWNER/$REPO_NAME"
echo "   Workflow: Android APK (build-test)"

# Crear directorio temporal
mkdir -p ./temp_apk
cd ./temp_apk

echo ""
echo "📥 Descargando APK desde GitHub Actions..."

# URL del último artefacto (esto puede cambiar según la estructura de GitHub)
# Vamos a intentar descargar el último build
ARTIFACT_URL="https://github.com/$REPO_OWNER/$REPO_NAME/actions/runs/latest/downloads/app-release"

echo "🔗 URL: $ARTIFACT_URL"

# Intentar descargar
curl -L -o "app-release.apk" "$ARTIFACT_URL" -H "Accept: application/octet-stream"

if [ $? -eq 0 ] && [ -f "app-release.apk" ]; then
    echo "✅ APK descargado exitosamente"
    
    # Verificar que el archivo no esté vacío
    if [ -s "app-release.apk" ]; then
        echo "📱 Instalando APK en Motorola Edge 2024..."
        
        # Volver al directorio principal
        cd ..
        
        # Instalar usando Flutter
        flutter install --device-id="$MOTOROLA_DEVICE" "./temp_apk/app-release.apk"
        
        if [ $? -eq 0 ]; then
            echo "✅ APK instalado exitosamente en tu Motorola!"
            echo "🎉 ¡La app CUBALINK23 está lista para usar!"
        else
            echo "❌ Error al instalar el APK"
            echo "   Intentando método alternativo..."
            
            # Método alternativo usando adb
            ADB_PATH=""
            if [ -f "/Users/cubcolexpress/flutter/bin/cache/artifacts/engine/android-arm64/adb" ]; then
                ADB_PATH="/Users/cubcolexpress/flutter/bin/cache/artifacts/engine/android-arm64/adb"
            fi
            
            if [ -n "$ADB_PATH" ]; then
                echo "📱 Instalando con adb directo..."
                "$ADB_PATH" install -r "./temp_apk/app-release.apk"
                
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
    else
        echo "❌ El archivo APK descargado está vacío"
        echo "   El build puede no estar disponible aún"
        exit 1
    fi
else
    echo "❌ Error al descargar el APK"
    echo "   El build puede no estar disponible aún"
    echo ""
    echo "🔧 OPCIONES ALTERNATIVAS:"
    echo "1. Usar Flutter Web: flutter run -d chrome"
    echo "2. Compilar localmente: flutter build apk"
    echo "3. Verificar builds en: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
    exit 1
fi

# Limpiar archivos temporales
rm -rf ./temp_apk
echo "🧹 Archivos temporales eliminados"

echo ""
echo "🏁 Proceso completado"
echo "📱 La app CUBALINK23 está instalada en tu Motorola Edge 2024"

