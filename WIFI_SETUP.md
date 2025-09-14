# 📱 Configuración WiFi para Motorola Edge 2024

## 🎯 Objetivo
Conectar y ejecutar la app Cubalink23 en el Motorola Edge 2024 vía WiFi para ahorrar batería y evitar el uso del cable USB.

## 🔧 Configuración del Dispositivo

### 1. Activar Depuración Inalámbrica
1. Ve a **Configuración** > **Opciones de desarrollador**
2. Activa **Depuración inalámbrica**
3. Toca en **Usar depuración inalámbrica**
4. Anota la **IP y puerto** mostrados (ej: `192.168.1.210:42481`)

### 2. Verificar Conexión WiFi
- Asegúrate de que tanto tu Mac como el Motorola estén en la **misma red WiFi**
- La IP puede cambiar si te conectas a una red diferente

## 🚀 Uso de los Scripts

### Script Rápido (Recomendado)
```bash
./run_wifi.sh
```
Este script:
- Conecta automáticamente al dispositivo
- Ejecuta la app Cubalink23
- Maneja errores de conexión

### Script de Conexión Manual
```bash
./connect_wifi.sh
```
Este script solo conecta el dispositivo sin ejecutar la app.

## 📋 Comandos Manuales

### Conectar Dispositivo
```bash
export PATH="/Users/cubcolexpress/Library/Android/sdk/platform-tools:$PATH"
adb connect 192.168.1.210:42481
```

### Verificar Dispositivos
```bash
adb devices
flutter devices
```

### Ejecutar App
```bash
flutter run --device-id=192.168.1.210:42481
```

## 🔄 Actualizar IP del Dispositivo

Si la IP del dispositivo cambia:

1. **En el Motorola**: Ve a Configuración > Opciones de desarrollador > Depuración inalámbrica
2. **Anota la nueva IP y puerto**
3. **Edita los scripts**:
   ```bash
   nano connect_wifi.sh
   nano run_wifi.sh
   ```
4. **Cambia la variable** `DEVICE_IP` y `DEVICE_PORT`

## 🛠️ Solución de Problemas

### Error: "Device not found"
- Verifica que la depuración inalámbrica esté activada
- Confirma que ambos dispositivos estén en la misma red WiFi
- Reinicia la depuración inalámbrica en el dispositivo

### Error: "Connection refused"
- La IP del dispositivo puede haber cambiado
- Verifica la IP actual en Configuración > Opciones de desarrollador
- Actualiza los scripts con la nueva IP

### Error: "ADB not found"
- El script ya incluye la ruta correcta de ADB
- Si persiste, verifica que Android SDK esté instalado

## 💡 Ventajas de la Conexión WiFi

✅ **Ahorro de batería** - No necesitas mantener el cable conectado
✅ **Movilidad** - Puedes moverte libremente mientras desarrollas
✅ **Comodidad** - No hay cables que se enreden
✅ **Velocidad** - La conexión WiFi es rápida para desarrollo

## 📱 Información del Dispositivo

- **Modelo**: Motorola Edge 2024
- **IP Actual**: 192.168.1.210:42481
- **Sistema**: Android 15 (API 35)
- **Arquitectura**: android-arm64

---

*Última actualización: $(date)*





