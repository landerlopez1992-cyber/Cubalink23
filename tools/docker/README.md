# 🚀 CubaLink23 Android Builder con Docker

Este directorio contiene toda la configuración de Docker para compilaciones Android consistentes y reproducibles de CubaLink23.

## 📁 Estructura de Archivos

```
tools/docker/
├── Dockerfile              # Imagen base con Flutter + Android SDK
├── docker-compose.yml      # Configuración de servicios Docker
├── .dockerignore           # Archivos a ignorar en el build context
├── build.sh                # Script de compilación automatizada
├── install.sh              # Script de instalación en dispositivos
├── run.sh                  # Script para desarrollo interactivo
└── README.md               # Esta documentación
```

## 🛠️ Configuración Incluida

### Imagen Docker Base
- **Ubuntu 22.04** (ARM64 compatible)
- **Java 17** (OpenJDK)
- **Android SDK 34** con build-tools 34.0.0
- **Flutter 3.24.5** (estable)
- **Usuario flutter** para seguridad

### Herramientas Incluidas
- ✅ Flutter SDK completo
- ✅ Android SDK y build-tools
- ✅ Gradle wrapper
- ✅ ADB (Android Debug Bridge)
- ✅ Licencias de Android aceptadas automáticamente

## 🚀 Uso Rápido

### 1. Compilar APK
```bash
# Compilar APK debug
./tools/docker/build.sh debug

# Compilar APK release
./tools/docker/build.sh release
```

### 2. Instalar en Dispositivos
```bash
# Instalar APK debug
./tools/docker/install.sh debug

# Instalar APK release
./tools/docker/install.sh release
```

### 3. Desarrollo Interactivo
```bash
# Abrir shell interactivo en Docker
./tools/docker/run.sh
```

## 📱 Comandos Disponibles

### Scripts Principales

| Script | Descripción | Uso |
|--------|-------------|-----|
| `build.sh` | Compila APK en Docker | `./tools/docker/build.sh [debug\|release]` |
| `install.sh` | Instala APK en dispositivos | `./tools/docker/install.sh [debug\|release]` |
| `run.sh` | Shell interactivo | `./tools/docker/run.sh` |

### Comandos Docker Directos

```bash
# Construir imagen
docker build -t cubalink23-android-builder -f tools/docker/Dockerfile .

# Ejecutar contenedor
docker run -it --rm -v "$(pwd):/workspace" cubalink23-android-builder

# Usar docker-compose
docker-compose -f tools/docker/docker-compose.yml up
```

## 🔧 Configuración Avanzada

### Variables de Entorno
```bash
export FLUTTER_VERSION=3.24.5
export ANDROID_SDK_VERSION=34
export ANDROID_BUILD_TOOLS_VERSION=34.0.0
```

### Volúmenes Docker
- **Gradle Cache**: `/home/flutter/.gradle`
- **Flutter Cache**: `/home/flutter/.flutter`
- **Proyecto**: `/workspace` (montado desde directorio actual)

## 🐛 Solución de Problemas

### Error: JAVA_HOME inválido
```bash
# Verificar versión de Java
docker run --rm cubalink23-android-builder java -version
```

### Error: Dispositivo no detectado
```bash
# Verificar dispositivos ADB
adb devices

# Reiniciar servidor ADB
adb kill-server && adb start-server
```

### Error: Permisos de archivos
```bash
# Dar permisos a scripts
chmod +x tools/docker/*.sh
```

## 📊 Beneficios

✅ **Consistencia**: Mismo entorno en cualquier máquina  
✅ **Reproducibilidad**: Builds idénticos siempre  
✅ **Aislamiento**: No afecta configuración local  
✅ **Escalabilidad**: Fácil de usar en CI/CD  
✅ **Mantenibilidad**: Una sola fuente de verdad  

## 🔄 Flujo de Trabajo Recomendado

1. **Desarrollo**: Usar `run.sh` para desarrollo interactivo
2. **Compilación**: Usar `build.sh` para generar APK
3. **Instalación**: Usar `install.sh` para probar en dispositivos
4. **CI/CD**: Usar comandos Docker directos en pipelines

## 📝 Notas Importantes

- La primera compilación puede tomar 10-15 minutos
- Los archivos se sincronizan automáticamente entre host y contenedor
- El cache de Gradle se mantiene entre builds para acelerar compilaciones
- Compatible con macOS ARM64 (Apple Silicon)

---

**🚀 ¡Disfruta de compilaciones Android consistentes y sin problemas de configuración!**











