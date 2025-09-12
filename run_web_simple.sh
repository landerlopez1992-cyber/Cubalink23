#!/bin/bash

# 🚀 SCRIPT SIMPLE PARA EJECUTAR WEB EN MOTOROLA
# Versión simplificada que evita errores de compilación

echo "🚀 CUBALINK23 - WEB SIMPLE EN MOTOROLA"
echo "======================================"

# Configurar PATH de Flutter
export PATH="$PATH:/Users/cubcolexpress/flutter/bin"

# Verificar que Flutter esté disponible
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter no encontrado en el PATH"
    exit 1
fi

echo "🔧 Preparando dependencias..."
flutter pub get

# Obtener la IP local de tu Mac
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

echo ""
echo "📱 INSTRUCCIONES PARA TU MOTOROLA:"
echo "1. Conecta tu Motorola a la misma red WiFi que tu Mac"
echo "2. Abre el navegador en tu Motorola"
echo "3. Ve a: http://$LOCAL_IP:8080"
echo "4. ¡La app se verá con el diseño móvil correcto!"

echo ""
echo "🚀 Iniciando servidor web simple..."

# Ejecutar en modo web simple (sin renderer específico)
flutter run -d chrome --web-hostname=0.0.0.0 --web-port=8080

echo ""
echo "🏁 App web ejecutándose"
echo "📱 Accede desde tu Motorola: http://$LOCAL_IP:8080"
