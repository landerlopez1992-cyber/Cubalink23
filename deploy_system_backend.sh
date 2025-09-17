#!/bin/bash
# 🚀 SCRIPT PARA DESPLEGAR BACKEND SISTEMA EN PRODUCCIÓN

echo "🛠️ ===== DESPLEGANDO CUBALINK23 SYSTEM BACKEND ====="
echo "📅 Fecha: $(date)"
echo ""

# 1. Ir a la carpeta de archivos del sistema
cd /Users/cubcolexpress/Desktop/turecarga/cubalink23-system-files

echo "📁 Verificando archivos preparados..."
ls -la

echo ""
echo "🔄 Inicializando repositorio Git..."
git init

echo ""
echo "➕ Agregando archivos..."
git add .

echo ""
echo "📝 Creando commit inicial..."
git commit -m "BACKEND SISTEMA COMPLETO: Órdenes, usuarios, productos, admin panel

✅ Funcionalidades implementadas:
- 📦 Sistema completo de órdenes con order_items
- 👥 Gestión de usuarios y saldos
- 🛒 Productos y carrito
- 🔔 Notificaciones del sistema
- 🛠️ Panel de administración completo
- 📊 Estadísticas y reportes
- 🖼️ Sistema de banners
- ⚙️ Configuración del sistema

🌐 Listo para deploy en Render.com
🔗 URL: https://cubalink23-system.onrender.com"

echo ""
echo "🔗 Conectando con repositorio GitHub..."
git branch -M main
git remote add origin https://github.com/landerlopez1992-cyber/cubalink23-system.git

echo ""
echo "🚀 Subiendo a GitHub..."
git push -u origin main

echo ""
echo "✅ ===== BACKEND SISTEMA SUBIDO A GITHUB ====="
echo ""
echo "🎯 PRÓXIMOS PASOS:"
echo "1. 🌐 Ir a Render.com"
echo "2. ➕ Crear nuevo servicio: cubalink23-system"
echo "3. 🔗 Conectar repositorio: cubalink23-system"
echo "4. ⚙️ Configurar variables de entorno:"
echo "   - SUPABASE_URL=https://zgqrhzuhrwudckwesybg.supabase.co"
echo "   - SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
echo "5. 🚀 Deploy automático"
echo ""
echo "🏁 ===== SCRIPT COMPLETADO ====="
