#!/bin/bash

echo "🐳 Compilando app Flutter con Docker..."

# Crear directorio para la APK si no existe
mkdir -p build/apk

# Construir imagen Docker
echo "📦 Construyendo imagen Docker..."
docker build -t cubalink23-flutter .

# Ejecutar contenedor y copiar APK
echo "🚀 Ejecutando compilación..."
docker run --rm -v "$(pwd)/build/apk:/app/build/app/outputs/flutter-apk" cubalink23-flutter

# Verificar que se generó la APK
if [ -f "build/apk/app-release.apk" ]; then
    echo "✅ APK generada exitosamente: build/apk/app-release.apk"
    ls -la build/apk/
else
    echo "❌ No se pudo generar la APK"
    echo "📁 Contenido del directorio build/apk:"
    ls -la build/apk/ || echo "Directorio vacío"
fi




