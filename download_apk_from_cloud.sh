#!/bin/bash

# 🚀 SCRIPT PARA DESCARGAR APK DESDE LA NUBE A MOTOROLA
# Este script descarga el APK compilado en GitHub Actions y lo instala en tu Motorola

echo "🚀 CUBALINK23 - DESCARGAR APK DESDE LA NUBE"
echo "============================================"

# Configurar PATH de Flutter
export PATH="$PATH:/Users/cubcolexpress/flutter/bin"

# Verificar que Flutter esté disponible
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter no encontrado en el PATH"
    echo "   Asegúrate de que Flutter esté instalado en /Users/cubcolexpress/flutter/bin"
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
    echo ""
    echo "📋 Dispositivos disponibles:"
    flutter devices
    exit 1
fi

echo "✅ Motorola Edge 2024 detectado: $MOTOROLA_DEVICE"

echo ""
echo "🔄 Verificando último build en GitHub Actions..."

# Obtener el último workflow run
REPO_OWNER="landerlopez1992-cyber"
REPO_NAME="Cubalink23"
WORKFLOW_NAME="Android APK (build-test)"

echo "   Repositorio: $REPO_OWNER/$REPO_NAME"
echo "   Workflow: $WORKFLOW_NAME"

# Verificar si GitHub CLI está instalado
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI encontrado"
    
    # Obtener el último run del workflow
    echo "🔍 Buscando último build exitoso..."
    LATEST_RUN=$(gh run list --workflow="Android APK (build-test).yml" --repo="$REPO_OWNER/$REPO_NAME" --status=success --limit=1 --json databaseId --jq '.[0].databaseId')
    
    if [ "$LATEST_RUN" = "null" ] || [ -z "$LATEST_RUN" ]; then
        echo "❌ No se encontró un build exitoso reciente"
        echo "   Ejecutando build manualmente..."
        
        # Trigger manual del workflow
        echo "🚀 Ejecutando build en GitHub Actions..."
        gh workflow run "Android APK (build-test).yml" --repo="$REPO_OWNER/$REPO_NAME"
        
        echo "⏳ Esperando a que termine el build (esto puede tomar 5-10 minutos)..."
        echo "   Puedes monitorear el progreso en:"
        echo "   https://github.com/$REPO_OWNER/$REPO_NAME/actions"
        
        # Esperar a que termine el build
        while true; do
            sleep 30
            LATEST_RUN=$(gh run list --workflow="Android APK (build-test).yml" --repo="$REPO_OWNER/$REPO_NAME" --status=success --limit=1 --json databaseId --jq '.[0].databaseId')
            if [ "$LATEST_RUN" != "null" ] && [ -n "$LATEST_RUN" ]; then
                break
            fi
            echo "   ⏳ Build en progreso..."
        done
    fi
    
    echo "✅ Build encontrado: $LATEST_RUN"
    
    # Descargar el APK
    echo "📥 Descargando APK desde GitHub Actions..."
    gh run download "$LATEST_RUN" --repo="$REPO_OWNER/$REPO_NAME" --dir="./temp_apk"
    
    if [ $? -eq 0 ]; then
        echo "✅ APK descargado exitosamente"
        
        # Buscar el archivo APK
        APK_FILE=$(find ./temp_apk -name "*.apk" | head -1)
        
        if [ -n "$APK_FILE" ]; then
            echo "📱 Instalando APK en Motorola Edge 2024..."
            adb install -r "$APK_FILE"
            
            if [ $? -eq 0 ]; then
                echo "✅ APK instalado exitosamente en tu Motorola!"
                echo "🎉 ¡La app está lista para usar!"
            else
                echo "❌ Error al instalar el APK"
                exit 1
            fi
        else
            echo "❌ No se encontró el archivo APK en la descarga"
            exit 1
        fi
        
        # Limpiar archivos temporales
        rm -rf ./temp_apk
        echo "🧹 Archivos temporales eliminados"
        
    else
        echo "❌ Error al descargar el APK"
        exit 1
    fi
    
else
    echo "❌ GitHub CLI no encontrado"
    echo "   Instalando GitHub CLI..."
    
    # Instalar GitHub CLI en macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install gh
        else
            echo "❌ Homebrew no encontrado. Instala GitHub CLI manualmente:"
            echo "   https://cli.github.com/"
            exit 1
        fi
    else
        echo "❌ Sistema operativo no soportado para instalación automática"
        echo "   Instala GitHub CLI manualmente: https://cli.github.com/"
        exit 1
    fi
    
    echo "✅ GitHub CLI instalado. Ejecuta el script nuevamente."
fi

echo ""
echo "🏁 Proceso completado"
echo "📱 La app CUBALINK23 está instalada en tu Motorola Edge 2024"


