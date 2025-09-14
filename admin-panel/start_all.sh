#!/bin/bash
echo "🚀 INICIANDO CUBALINK23 BACKEND AUTOMÁTICAMENTE..."
echo "================================================"

# Iniciar backend
echo "1️⃣ Iniciando backend..."
./start_backend.sh

# Esperar 5 segundos
sleep 5

# Verificar que el backend esté funcionando
echo "2️⃣ Verificando backend..."
if curl -s http://localhost:3005/ > /dev/null; then
    echo "✅ Backend funcionando correctamente"
else
    echo "❌ Error: Backend no responde"
    exit 1
fi

# Iniciar túnel
echo "3️⃣ Iniciando Cloudflare Tunnel..."
./start_tunnel.sh &

echo "================================================"
echo "🎉 TODO CONFIGURADO AUTOMÁTICAMENTE!"
echo ""
echo "📱 Panel de Administración LOCAL:"
echo "   http://localhost:3005/auth/login"
echo "   Usuario: landerlopez1992@gmail.com"
echo "   Contraseña: Maquina.2055"
echo ""
echo "🌐 Panel de Administración ONLINE:"
echo "   https://backend.cubalink23.com/auth/login"
echo "   (Disponible en 1-2 minutos)"
echo ""
echo "📊 Logs del backend: tail -f backend.log"
echo "================================================"
