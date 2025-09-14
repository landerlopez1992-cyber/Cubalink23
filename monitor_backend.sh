#!/bin/bash

# 🔄 Monitor automático del backend CubaLink23
# Vigila el backend y lo reinicia automáticamente si se cae

BACKEND_DIR="/Users/cubcolexpress/Desktop/turecarga/backend-duffel"
BACKEND_PORT=3005
LOG_FILE="/Users/cubcolexpress/Desktop/turecarga/backend_monitor.log"

echo "🔄 Iniciando monitor automático del backend..." | tee -a "$LOG_FILE"
echo "📅 $(date): Monitor iniciado" >> "$LOG_FILE"

while true; do
    # Verificar si el backend está funcionando
    if ! curl -s http://localhost:$BACKEND_PORT/api/health > /dev/null 2>&1; then
        echo "❌ $(date): Backend caído. Reiniciando..." | tee -a "$LOG_FILE"
        
        # Matar procesos previos del backend
        pkill -f "python3 app.py" 2>/dev/null
        pkill -f "python app.py" 2>/dev/null
        lsof -ti:$BACKEND_PORT | xargs kill -9 2>/dev/null
        
        sleep 2
        
        # Reiniciar backend
        cd "$BACKEND_DIR"
        nohup python3 app.py > backend.log 2>&1 &
        
        echo "🔄 $(date): Backend reiniciado" | tee -a "$LOG_FILE"
        sleep 5
        
        # Verificar que se reinició correctamente
        if curl -s http://localhost:$BACKEND_PORT/api/health > /dev/null 2>&1; then
            echo "✅ $(date): Backend funcionando correctamente" | tee -a "$LOG_FILE"
        else
            echo "❌ $(date): Error al reiniciar backend" | tee -a "$LOG_FILE"
        fi
    else
        echo "✅ $(date): Backend funcionando" >> "$LOG_FILE"
    fi
    
    # Esperar 10 segundos antes de la siguiente verificación
    sleep 10
done
