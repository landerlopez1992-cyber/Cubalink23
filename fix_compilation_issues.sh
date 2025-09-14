#!/bin/bash

# Script para prevenir y corregir problemas de compilación Flutter/Android
# Autor: Sistema de mantenimiento automático
# Fecha: $(date)

echo "🔧 Verificando y corrigiendo problemas de compilación Flutter/Android..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
log_info() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    log_error "No se encontró pubspec.yaml. Ejecuta este script desde la raíz del proyecto Flutter."
    exit 1
fi

log_info "Directorio del proyecto verificado"

# 2. Verificar configuración de Gradle
log_info "Verificando configuración de Gradle..."

# Verificar que no existan archivos .kts conflictivos
if [ -f "android/app/build.gradle.kts" ]; then
    log_warning "Eliminando archivo build.gradle.kts conflictivo..."
    rm -f android/app/build.gradle.kts
fi

if [ -f "android/build.gradle.kts" ]; then
    log_warning "Eliminando archivo build.gradle.kts conflictivo..."
    rm -f android/build.gradle.kts
fi

# 3. Verificar y corregir gradle.properties
log_info "Verificando gradle.properties..."

GRADLE_PROPS="android/gradle.properties"
if [ -f "$GRADLE_PROPS" ]; then
    # Verificar que tenga la configuración correcta
    if ! grep -q "android.suppressUnsupportedCompileSdk=36" "$GRADLE_PROPS"; then
        log_warning "Agregando suppressUnsupportedCompileSdk a gradle.properties..."
        echo "android.suppressUnsupportedCompileSdk=36" >> "$GRADLE_PROPS"
    fi
    
    if ! grep -q "org.gradle.jvmargs=-Xmx4g" "$GRADLE_PROPS"; then
        log_warning "Configurando memoria JVM en gradle.properties..."
        sed -i '' 's/org.gradle.jvmargs=.*/org.gradle.jvmargs=-Xmx4g -Dkotlin.daemon.jvm.options="-Xmx2g"/' "$GRADLE_PROPS"
    fi
fi

# 4. Verificar configuración de build.gradle
log_info "Verificando build.gradle..."

BUILD_GRADLE="android/app/build.gradle"
if [ -f "$BUILD_GRADLE" ]; then
    # Verificar compileSdkVersion
    if ! grep -q "compileSdkVersion 36" "$BUILD_GRADLE"; then
        log_warning "Corrigiendo compileSdkVersion a 36..."
        sed -i '' 's/compileSdkVersion [0-9]*/compileSdkVersion 36/' "$BUILD_GRADLE"
    fi
    
    # Verificar versión de Java
    if ! grep -q "JavaVersion.VERSION_11" "$BUILD_GRADLE"; then
        log_warning "Corrigiendo versión de Java a 11..."
        sed -i '' 's/JavaVersion.VERSION_[0-9]*/JavaVersion.VERSION_11/g' "$BUILD_GRADLE"
        sed -i '' "s/jvmTarget = '[0-9]*'/jvmTarget = '11'/" "$BUILD_GRADLE"
    fi
fi

# 5. Verificar versión de Gradle
log_info "Verificando versión de Gradle..."

TOP_BUILD_GRADLE="android/build.gradle"
if [ -f "$TOP_BUILD_GRADLE" ]; then
    if ! grep -q "gradle:8.7.2" "$TOP_BUILD_GRADLE"; then
        log_warning "Actualizando versión de Gradle a 8.7.2..."
        sed -i '' 's/gradle:[0-9.]*/gradle:8.7.2/' "$TOP_BUILD_GRADLE"
    fi
fi

# 6. Limpiar y reconstruir
log_info "Limpiando proyecto..."
flutter clean

log_info "Obteniendo dependencias..."
flutter pub get

# 7. Crear estructura de directorios para APK
log_info "Creando estructura de directorios para APK..."
mkdir -p build/app/outputs/flutter-apk

# 8. Verificar compilación
log_info "Verificando compilación..."
if flutter build apk --debug; then
    log_info "✅ Compilación exitosa!"
    
    # Copiar APK a la ubicación esperada por Flutter
    if [ -f "android/app/build/outputs/flutter-apk/app-debug.apk" ]; then
        cp android/app/build/outputs/flutter-apk/app-debug.apk build/app/outputs/flutter-apk/
        log_info "APK copiado a ubicación esperada por Flutter"
    fi
else
    log_error "❌ Error en la compilación. Revisa los logs arriba."
    exit 1
fi

# 9. Verificar que los APK existen
log_info "Verificando archivos APK generados..."
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    log_info "✅ APK debug generado correctamente"
    ls -lh build/app/outputs/flutter-apk/app-debug.apk
else
    log_error "❌ APK debug no encontrado"
fi

if [ -f "android/app/build/outputs/apk/release/app-release.apk" ]; then
    log_info "✅ APK release generado correctamente"
    ls -lh android/app/build/outputs/apk/release/app-release.apk
else
    log_warning "⚠️  APK release no encontrado (esto es normal si no se compiló en release)"
fi

log_info "🎉 Verificación completada. El proyecto debería compilar correctamente ahora."

# 10. Mostrar resumen de cambios
echo ""
echo "📋 RESUMEN DE CAMBIOS APLICADOS:"
echo "   • Eliminados archivos .kts conflictivos"
echo "   • Configurado compileSdkVersion a 36"
echo "   • Actualizado Java a versión 11"
echo "   • Configurado Gradle 8.7.2"
echo "   • Agregado suppressUnsupportedCompileSdk=36"
echo "   • Configurado memoria JVM optimizada"
echo "   • Creada estructura de directorios para APK"
echo ""
echo "💡 Para evitar futuros problemas:"
echo "   • No mezcles archivos .gradle y .gradle.kts"
echo "   • Mantén las versiones de SDK actualizadas"
echo "   • Ejecuta este script periódicamente"
echo "   • Usa 'flutter clean' antes de compilar"



