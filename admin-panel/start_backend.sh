#!/bin/bash
cd "$(dirname "$0")/backend-duffel"
python3 app.py > backend.log 2>&1 &
echo "Backend iniciado en puerto 3005"
echo "Panel de administración: http://localhost:3005/auth/login"
echo "Usuario: landerlopez1992@gmail.com"
echo "Contraseña: Maquina.2055"
