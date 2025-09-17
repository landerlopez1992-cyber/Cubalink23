#!/bin/bash

# ⚡ SCRIPT PARA PROBAR SISTEMA DE RECARGAS TELEFÓNICAS
# Compila e instala la app con las nuevas funcionalidades de DingConnect

echo "📱 CUBALINK23 - TESTING RECARGAS TELEFÓNICAS"
echo "============================================"

# Verificar que Docker esté disponible
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker no está ejecutándose. Usando compilación local..."
    
    # Instalar dependencias
    echo "📦 Instalando nuevas dependencias..."
    flutter pub get
    
    if [ $? -eq 0 ]; then
        echo "✅ Dependencias instaladas"
        
        # Compilar APK debug
        echo "🔨 Compilando APK debug..."
        flutter build apk --debug
        
        if [ $? -eq 0 ]; then
            echo "✅ Compilación exitosa"
            
            # Instalar en dispositivos
            echo "📱 Instalando en dispositivos..."
            adb devices | grep -v "List of devices" | grep "device$" | while read device_id status; do
                if [ "$status" = "device" ]; then
                    echo "📱 Instalando en: $device_id"
                    adb -s $device_id install -r build/app/outputs/flutter-apk/app-debug.apk
                fi
            done
            
            echo ""
            echo "🎉 ¡TESTING DE RECARGAS LISTO!"
            echo "📱 Nuevas funcionalidades disponibles:"
            echo "   ✅ Integración con DingConnect API"
            echo "   ✅ Selector de contactos telefónicos"
            echo "   ✅ Ofertas por país"
            echo "   ✅ Validación de números"
            echo "   ✅ Conexión con pagos Square"
        else
            echo "❌ Error en compilación"
            exit 1
        fi
    else
        echo "❌ Error instalando dependencias"
        exit 1
    fi
else
    echo "🐳 Docker disponible - usando compilación Docker..."
    ./tools/docker/build.sh debug
    ./tools/docker/install.sh debug
fi

echo ""
echo "🧪 Para probar las recargas:"
echo "   1. Abre la app CubaLink23"
echo "   2. Ve a la sección 'Recargas'"
echo "   3. Prueba el selector de contactos"
echo "   4. Verifica las ofertas de Cuba"
echo "   5. Completa una recarga de prueba"







