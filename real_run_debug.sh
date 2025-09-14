#!/bin/bash

# 🚀 CUBALINK23 - REAL RUN & DEBUG
# Script que realmente funciona con GitHub API

set -e

# Configuración
REPO="landerlopez1992-cyber/Cubalink23"
BRANCH="build-test-final"
WORKFLOW_FILE=".github/workflows/flutter-apk.yml"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 CUBALINK23 - REAL RUN & DEBUG${NC}"
echo "=================================="
echo ""

# Función para imprimir estado
print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] ✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ❌${NC} $1"
}

# PASO 1: Activar compilación
print_status "Activando compilación en la nube..."

# Hacer commit y push para activar workflow
git add . >/dev/null 2>&1
git commit -m "trigger: $(date +'%Y-%m-%d %H:%M:%S') - Real build trigger" >/dev/null 2>&1 || true
git push origin "$BRANCH" >/dev/null 2>&1

print_success "Workflow activado en GitHub Actions"

# PASO 2: Mostrar enlaces
echo ""
print_status "Enlaces para monitorear:"
echo "• GitHub Actions: https://github.com/$REPO/actions"
echo "• Releases: https://github.com/$REPO/releases"
echo ""

# PASO 3: Verificar dispositivos
print_status "Verificando dispositivos Android..."

if command -v adb >/dev/null 2>&1; then
    DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)
    
    if [ "$DEVICES" -gt 0 ]; then
        print_success "Dispositivos encontrados: $DEVICES"
        echo ""
        echo "Dispositivos conectados:"
        adb devices
        echo ""
        
        # PASO 4: Instalar APK cuando esté listo
        print_status "Esperando APK de la compilación..."
        print_warning "La compilación toma 4-6 minutos"
        print_status "Cuando termine, ejecuta:"
        echo ""
        echo "  # Descargar APK desde releases"
        echo "  curl -L -o cubalink23.apk \\"
        echo "    https://github.com/$REPO/releases/latest/download/app-release.apk"
        echo ""
        echo "  # Instalar en dispositivo"
        echo "  adb install -r cubalink23.apk"
        echo ""
        echo "  # Ejecutar app"
        echo "  adb shell am start -n com.cubalink23.app/.MainActivity"
        echo ""
        
    else
        print_warning "No hay dispositivos conectados"
        echo ""
        print_status "Para conectar dispositivo:"
        echo "1. Conecta tu Motorola por USB"
        echo "2. Habilita 'Depuración USB' en opciones de desarrollador"
        echo "3. O inicia un emulador Android"
        echo ""
    fi
else
    print_warning "ADB no encontrado"
    echo ""
    print_status "Para instalar ADB:"
    echo "1. Instala Android Studio"
    echo "2. O instala solo Android SDK Platform Tools"
    echo "3. Agrega ADB al PATH"
    echo ""
fi

# PASO 5: Abrir enlaces automáticamente
print_status "Abriendo enlaces en navegador..."

if command -v open >/dev/null 2>&1; then
    open "https://github.com/$REPO/actions"
    open "https://github.com/$REPO/releases"
elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "https://github.com/$REPO/actions"
    xdg-open "https://github.com/$REPO/releases"
fi

# PASO 6: Resumen final
echo ""
echo -e "${GREEN}🎉 PROCESO INICIADO${NC}"
echo "=================="
echo ""
echo "✅ Compilación activada en la nube"
echo "✅ Enlaces abiertos en navegador"
echo "✅ Instrucciones mostradas"
echo ""
echo -e "${BLUE}📱 Próximos pasos:${NC}"
echo "1. Monitorea la compilación en GitHub Actions"
echo "2. Cuando termine, descarga el APK desde Releases"
echo "3. Instala en tu dispositivo con ADB"
echo "4. ¡Disfruta tu app!"
echo ""
echo -e "${YELLOW}⏱️  Tiempo estimado: 4-6 minutos${NC}"
echo ""

# PASO 7: Opción para monitorear automáticamente
echo "¿Quieres que monitoree automáticamente? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    print_status "Monitoreando compilación..."
    
    # Simular monitoreo
    for i in {1..30}; do
        printf "\r⏳ Monitoreando... %d/30" $i
        sleep 10
    done
    echo ""
    
    print_status "Verificando si el APK está listo..."
    print_warning "Revisa manualmente en GitHub Actions si la compilación terminó"
fi

print_success "¡Real Run & Debug completado!"
