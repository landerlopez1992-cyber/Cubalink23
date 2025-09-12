#!/bin/bash

# 🚀 SCRIPT PARA EJECUTAR APP WEB EN MOTOROLA (SIN GRADLE)
# Ejecuta la app web y la hace accesible desde el navegador de tu Motorola

echo "🚀 CUBALINK23 - EJECUTAR WEB EN MOTOROLA"
echo "========================================"

# Configurar PATH de Flutter
export PATH="$PATH:/Users/cubcolexpress/flutter/bin"

# Verificar que Flutter esté disponible
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter no encontrado en el PATH"
    exit 1
fi

echo "🔧 Preparando dependencias..."
flutter pub get

echo ""
echo "🌐 Ejecutando app web para Motorola..."
echo "   La app se ejecutará en modo web"
echo "   Accesible desde el navegador de tu Motorola"

# Obtener la IP local de tu Mac
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

echo ""
echo "📱 INSTRUCCIONES PARA TU MOTOROLA:"
echo "1. Conecta tu Motorola a la misma red WiFi que tu Mac"
echo "2. Abre el navegador en tu Motorola"
echo "3. Ve a: http://$LOCAL_IP:8080"
echo "4. ¡La app se verá con el diseño móvil correcto!"

echo ""
echo "🚀 Iniciando servidor web..."

# Ejecutar en modo web accesible desde la red local
flutter run -d chrome --web-hostname=0.0.0.0 --web-port=8080 --web-renderer=canvaskit

echo ""
echo "🏁 App web ejecutándose"
echo "📱 Accede desde tu Motorola: http://$LOCAL_IP:8080"
