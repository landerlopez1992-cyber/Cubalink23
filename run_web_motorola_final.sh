#!/bin/bash

# 🚀 SCRIPT FINAL PARA MOTOROLA - SIN FIREBASE
# Ejecuta la app en web accesible desde el navegador del Motorola

echo "🚀 CUBALINK23 - WEB FINAL PARA MOTOROLA"
echo "========================================"

# Configurar PATH de Flutter
export PATH="$PATH:/Users/cubcolexpress/flutter/bin"

# Obtener la IP local de tu Mac
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

echo "📱 INSTRUCCIONES PARA TU MOTOROLA:"
echo "1. Conecta tu Motorola a la misma red WiFi que tu Mac"
echo "2. Abre el navegador en tu Motorola"
echo "3. Ve a: http://$LOCAL_IP:8080"
echo "4. ¡La app se verá con el diseño móvil correcto!"

echo ""
echo "🔧 Preparando dependencias..."
flutter pub get

echo ""
echo "🚀 Iniciando servidor web para Motorola..."

# Ejecutar en modo web accesible desde la red local
# Usar --web-renderer=html para evitar problemas de CanvasKit
flutter run -d chrome --web-hostname=0.0.0.0 --web-port=8080 --web-renderer=html

echo ""
echo "🏁 App web ejecutándose"
echo "📱 Accede desde tu Motorola: http://$LOCAL_IP:8080"
