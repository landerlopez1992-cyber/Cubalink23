# 🎨 Sistema de Gestión de Banners - Cubalink23

## 📋 Descripción
Sistema completo de gestión de banners publicitarios para el panel de administración de Cubalink23. Incluye funcionalidades CRUD completas, control de posiciones, activación/desactivación y subida de imágenes.

## 🚀 Funcionalidades Implementadas

### ✅ Gestión de Banners
- **Crear banners** con título, descripción, imagen y enlace
- **Listar banners** con información completa
- **Actualizar banners** existentes
- **Eliminar banners** del sistema
- **Activar/desactivar banners** para control de visibilidad
- **Control de posiciones** para ordenar banners
- **Subida de imágenes** con validación de formatos

### ✅ Base de Datos
- **SQLite local** como respaldo principal
- **Integración con Supabase** (opcional)
- **Sistema híbrido** que funciona con o sin conexión a internet

### ✅ Seguridad
- **Autenticación requerida** para operaciones administrativas
- **Endpoint público** para obtener banners activos
- **Validación de archivos** de imagen
- **Control de acceso** por estado de banner

## 🛠️ Instalación y Configuración

### 1. Instalar Dependencias
```bash
pip install -r requirements.txt
```

### 2. Configurar Variables de Entorno
Copia el archivo `config.env` y ajusta las variables:
```bash
cp config.env .env
```

### 3. Iniciar el Servidor
```bash
python start_server.py
```

## 📊 Endpoints Disponibles

### 🔐 Autenticación
- `POST /auth/login` - Login del administrador
- `GET /auth/logout` - Cerrar sesión

### 🎨 Banners (Admin)
- `GET /admin/api/banners` - Obtener todos los banners
- `POST /admin/api/banners` - Crear nuevo banner
- `PUT /admin/api/banners/<id>` - Actualizar banner
- `DELETE /admin/api/banners/<id>` - Eliminar banner
- `POST /admin/api/banners/<id>/toggle` - Activar/desactivar banner
- `PUT /admin/api/banners/<id>/position` - Actualizar posición

### 🌟 Banners (Público)
- `GET /admin/api/banners/active` - Obtener solo banners activos

### 🏥 Health Check
- `GET /api/health` - Estado del servidor

## 🧪 Pruebas del Sistema

### Ejecutar Pruebas Automáticas
```bash
python test_banners.py
```

### Pruebas Manuales
1. **Acceder al panel**: http://localhost:3005/admin
2. **Login**: Usar credenciales del archivo config.env
3. **Navegar a Banners** y probar las funcionalidades

## 📁 Estructura de Archivos

```
backend-duffel/
├── app.py                 # Aplicación principal Flask
├── admin_routes.py        # Rutas del panel de administración
├── auth_routes.py         # Rutas de autenticación
├── database.py           # Clase de base de datos local
├── supabase_service.py   # Servicio de Supabase
├── start_server.py       # Script de inicio
├── test_banners.py       # Pruebas del sistema de banners
├── config.env            # Configuración de entorno
├── requirements.txt      # Dependencias
└── static/
    └── uploads/          # Imágenes de banners
```

## 🔧 Configuración Avanzada

### Variables de Entorno Importantes
```env
SECRET_KEY=tu-clave-secreta
ADMIN_USERNAME=tu-email@ejemplo.com
ADMIN_PASSWORD=tu-contraseña
SUPABASE_URL=tu-url-de-supabase
SUPABASE_SERVICE_KEY=tu-clave-de-supabase
UPLOAD_FOLDER=static/uploads
MAX_CONTENT_LENGTH=16777216
```

### Base de Datos
- **SQLite**: Se crea automáticamente en `products.db`
- **Supabase**: Configurar en variables de entorno
- **Híbrido**: Funciona con ambos sistemas

## 📊 Estructura de Datos de Banner

```json
{
  "id": 1,
  "title": "Banner Promocional",
  "description": "Descripción del banner publicitario",
  "image_url": "/static/uploads/banner_20241230_223000_image.jpg",
  "link_url": "https://ejemplo.com/promocion",
  "active": true,
  "position": 1,
  "created_at": "2024-12-30T22:30:00"
}
```

## 🎯 Funcionalidades Específicas

### Control de Posiciones
- **Ordenamiento**: Los banners se muestran por posición ascendente
- **Reposicionamiento**: Cambiar la posición de cualquier banner
- **Organización**: Sistema de prioridades visual

### Activación/Desactivación
- **Control de visibilidad**: Mostrar/ocultar banners sin eliminarlos
- **Estado persistente**: Se mantiene en base de datos
- **Filtrado automático**: Solo banners activos en endpoint público

### Gestión de Imágenes
- **Formatos soportados**: PNG, JPG, JPEG, GIF, WEBP
- **Nombres únicos**: Timestamp + nombre original
- **Validación**: Verificación de tipos de archivo
- **Almacenamiento**: Directorio `/static/uploads/`

### Endpoint Público
- **Sin autenticación**: Accesible para frontend público
- **Solo activos**: Filtra automáticamente banners inactivos
- **Ordenado**: Por posición y fecha de creación

## 🎯 Próximos Pasos

### Funcionalidades Pendientes
1. **Gestión de Vuelos** - Integración con APIs de vuelos
2. **Gestión de Pedidos** - Sistema de órdenes
3. **Métodos de Pago** - Integración de pagos
4. **Sistema de Billetera** - Gestión de saldos
5. **Chat de Soporte** - Sistema de mensajería
6. **Reglas del Sistema** - Configuraciones avanzadas
7. **Gestión de Vehículos** - Sistema de renta car

## 🐛 Solución de Problemas

### Error de Conexión
```bash
# Verificar que el puerto esté libre
lsof -i :3005
# Si está ocupado, cambiar en config.env
```

### Error de Base de Datos
```bash
# Eliminar archivo de base de datos corrupto
rm products.db
# Reiniciar servidor (se creará automáticamente)
```

### Error de Subida de Imágenes
```bash
# Verificar permisos del directorio
chmod 755 static/uploads
# Verificar espacio en disco
df -h
```

### Error de Dependencias
```bash
# Reinstalar dependencias
pip install -r requirements.txt --force-reinstall
```

## 📞 Soporte
Para soporte técnico o preguntas sobre el sistema, contactar al equipo de desarrollo de Cubalink23.

---
**Versión**: 1.0.0  
**Última actualización**: Diciembre 2024  
**Desarrollado por**: Equipo Cubalink23

