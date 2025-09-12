# 🚀 Instrucciones para Ejecutar CubaLink23

## ✅ Configuración Completada

La app está configurada para ejecutarse automáticamente en el navegador web cuando uses el botón "Run and Debug" de VS Code.

## 🎯 Cómo Ejecutar la App

### ✅ **SOLUCIÓN AL ERROR "Device chrome was not found"**

**Problema resuelto:** La configuración de VS Code ahora usa el ID correcto del dispositivo.

### Opción 1: Botón "Run and Debug" en VS Code (Recomendado)
1. **Abre VS Code** en la carpeta del proyecto
2. **Presiona F5** o haz clic en el botón "Run and Debug" (▶️🐛)
3. **Selecciona** "CubaLink23 - Mobile Chrome (412x915)" de la lista
4. **La app se abrirá automáticamente** en Chrome con dimensiones móviles (412x915)

**✅ Verificado:** El comando `flutter run -d chrome --web-port 8080` funciona correctamente

### 🎯 **NUEVA OPCIÓN: Chrome en Modo Móvil (412x915)**
- **Configuración:** "CubaLink23 - Mobile Chrome (412x915)"
- **Dimensiones:** 412x915 (simula iPhone)
- **Posición:** 60,60
- **Perfil:** Edge2024Profile

### Opción 2: Script de Inicio Rápido
```bash
./start_web_app.sh
```

### 🎯 **Opción 3: Script Móvil (Recomendado)**
```bash
./run_mobile_app.sh
```
**Este script:**
- Inicia Flutter automáticamente
- Abre Chrome con dimensiones móviles (412x915)
- Posiciona la ventana en (60,60)
- Usa tu perfil Edge2024Profile
- Activa Hot Reload

### Opción 3: Comando Manual
```bash
flutter run -d chrome --web-port 8080
```

## 🔧 Configuraciones Creadas

### `.vscode/launch.json`
- **CubaLink23 - Web (Chrome)**: Configuración principal para debug
- **CubaLink23 - Web (Chrome) - Release**: Configuración para versión de producción

### `.vscode/settings.json`
- Configuración optimizada para desarrollo Flutter
- Hot reload habilitado
- DevTools configurado

### `.vscode/tasks.json`
- Tareas automatizadas para limpiar y ejecutar
- Comandos de Flutter preconfigurados

## 🌐 Acceso desde Dispositivos

### Desde el iPad (mismo WiFi):
```
http://192.168.2.1:8080
```
o
```
http://10.102.47.136:8080
```

### Desde cualquier dispositivo en la red:
- Busca la IP de tu Mac: `ifconfig | grep "inet " | grep -v 127.0.0.1`
- Usa: `http://[TU_IP]:8080`

## 🛠️ Solución de Problemas

### Si no funciona el botón "Run and Debug":
1. **Reinicia VS Code**
2. **Verifica** que Flutter esté en el PATH
3. **Ejecuta** `flutter doctor` para verificar la instalación

### Si hay errores de dependencias:
```bash
flutter clean
flutter pub get
```

### Si Chrome no se abre:
- Verifica que Chrome esté instalado
- Usa el script: `./start_web_app.sh`

## ✅ Estado Actual

- ✅ **App funcionando** en navegador web
- ✅ **Errores críticos corregidos**
- ✅ **VS Code configurado** para Run and Debug
- ✅ **Scripts de inicio** creados
- ✅ **Acceso desde iPad** disponible

## 🎉 ¡Listo para Usar!

Ahora puedes presionar **F5** o el botón **"Run and Debug"** en VS Code y la app se ejecutará automáticamente en Chrome sin depender de nada más.
