#!/bin/bash

# 🚀 SCRIPT PARA EJECUTAR APP EN WEB (SIN GRADLE)
# Evita completamente los problemas de Gradle

echo "🚀 CUBALINK23 - EJECUTAR APP EN WEB (SIN GRADLE)"
echo "================================================"

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
echo "🌐 Ejecutando app en Chrome..."
echo "   La app se abrirá automáticamente en tu navegador"
echo "   Esto evita completamente los problemas de Gradle"

# Ejecutar en web
flutter run -d chrome --web-renderer canvaskit

echo ""
echo "🏁 App ejecutándose en web"
echo "🌐 Puedes probar todas las funcionalidades en el navegador"
