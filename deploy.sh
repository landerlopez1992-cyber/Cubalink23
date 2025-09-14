#!/bin/bash

echo "🚀 INICIANDO DESPLIEGUE A RENDER.COM"
echo "=================================="

# Verificar si git está inicializado
if [ ! -d ".git" ]; then
    echo "📁 Inicializando repositorio Git..."
    git init
    git add .
    git commit -m "Initial commit - Charter Airlines Backend with Web Scraping"
    echo "✅ Repositorio Git inicializado"
else
    echo "📁 Repositorio Git ya existe"
    git add .
    git commit -m "Update - Charter Airlines Backend with Web Scraping"
fi

echo ""
echo "📋 ARCHIVOS PREPARADOS:"
echo "✅ requirements.txt - Dependencias de Python"
echo "✅ Procfile - Configuración de Render.com"
echo "✅ runtime.txt - Versión de Python"
echo "✅ app.py - Aplicación Flask"
echo "✅ charter_scraper.py - Web Scraping Real"
echo "✅ database.py - Base de datos SQLite"
echo "✅ README.md - Documentación"
echo ""

echo "🌐 PRÓXIMOS PASOS:"
echo "1. Crear repositorio en GitHub"
echo "2. Ejecutar: git remote add origin https://github.com/TU_USUARIO/TU_REPO.git"
echo "3. Ejecutar: git push -u origin main"
echo "4. Ir a Render.com y crear Web Service"
echo "5. Conectar con GitHub y desplegar"
echo ""

echo "🔧 CONFIGURACIÓN EN RENDER.COM:"
echo "Name: cubalink23-backend"
echo "Environment: Python 3"
echo "Build Command: pip install -r requirements.txt"
echo "Start Command: gunicorn app:app --bind 0.0.0.0:\$PORT"
echo ""

echo "🔑 VARIABLES DE ENTORNO:"
echo "DUFFEL_API_TOKEN=tu_token_aqui"
echo "FLASK_ENV=production"
echo "SECRET_KEY=cubalink23-secret-key-2023"
echo ""

echo "🎯 ¡LISTO PARA DESPLEGAR!"
echo "Tu backend estará disponible en: https://tu-app.onrender.com"

