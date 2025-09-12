#!/bin/bash

echo "📱 Configurando Chrome para Desarrollo Móvil"
echo "==========================================="
echo ""

# Crear directorio para perfil móvil
MOBILE_PROFILE_DIR="$HOME/ChromeMobileProfile"
echo "📁 Creando perfil móvil en: $MOBILE_PROFILE_DIR"
mkdir -p "$MOBILE_PROFILE_DIR"

echo "🔧 Configurando Chrome con dimensiones móviles..."
echo "   Dimensiones: 412x915 (iPhone)"
echo "   Posición: 60,60"
echo ""

# Crear script de lanzamiento de Chrome móvil
cat > "$HOME/launch_chrome_mobile.sh" << 'EOF'
#!/bin/bash
open -na "Google Chrome" --args \
  --user-data-dir="$HOME/ChromeMobileProfile" \
  --window-size=412,915 \
  --window-position=60,60 \
  --app="$1"
EOF

chmod +x "$HOME/launch_chrome_mobile.sh"

echo "✅ Script de lanzamiento creado: $HOME/launch_chrome_mobile.sh"
echo ""

# Crear alias para uso fácil
echo "🔗 Creando alias 'chrome-mobile'..."
echo "alias chrome-mobile='$HOME/launch_chrome_mobile.sh'" >> ~/.zshrc

echo "✅ Configuración completada!"
echo ""
echo "🎯 Cómo usar:"
echo "   1. Reinicia la terminal o ejecuta: source ~/.zshrc"
echo "   2. Usa: chrome-mobile http://localhost:8080"
echo "   3. Chrome se abrirá con dimensiones móviles (412x915)"
echo ""
echo "📱 Chrome móvil configurado permanentemente!"
