# 👥 Sistema de Gestión de Usuarios - Cubalink23

## 📋 Descripción
Sistema completo de gestión de usuarios para el panel de administración de Cubalink23. Incluye funcionalidades CRUD completas, bloqueo/desbloqueo de usuarios y seguimiento de actividad.

## 🚀 Funcionalidades Implementadas

### ✅ Gestión de Usuarios
- **Crear usuarios** con información completa (nombre, email, ID único)
- **Listar usuarios** con estadísticas de actividad
- **Actualizar usuarios** existentes
- **Eliminar usuarios** del sistema
- **Bloquear/desbloquear usuarios** para control de acceso
- **Seguimiento de actividad** (última vez visto, búsquedas realizadas)

### ✅ Base de Datos
- **SQLite local** como respaldo principal
- **Integración con Supabase** (opcional)
- **Sistema híbrido** que funciona con o sin conexión a internet

### ✅ Seguridad
- **Autenticación requerida** para todas las operaciones
- **Validación de datos** obligatorios
- **Control de acceso** por estado de usuario

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

### 👥 Usuarios
- `GET /admin/api/users` - Obtener todos los usuarios
- `POST /admin/api/users` - Crear nuevo usuario
- `PUT /admin/api/users/<id>` - Actualizar usuario
- `DELETE /admin/api/users/<id>` - Eliminar usuario
- `POST /admin/api/users/<id>/toggle` - Bloquear/desbloquear usuario
- `POST /admin/api/users/<id>/activity` - Actualizar actividad del usuario

### 🏥 Health Check
- `GET /api/health` - Estado del servidor

## 🧪 Pruebas del Sistema

### Ejecutar Pruebas Automáticas
```bash
python test_users.py
```

### Pruebas Manuales
1. **Acceder al panel**: http://localhost:3005/admin
2. **Login**: Usar credenciales del archivo config.env
3. **Navegar a Usuarios** y probar las funcionalidades

## 📁 Estructura de Archivos

```
backend-duffel/
├── app.py                 # Aplicación principal Flask
├── admin_routes.py        # Rutas del panel de administración
├── auth_routes.py         # Rutas de autenticación
├── database.py           # Clase de base de datos local
├── supabase_service.py   # Servicio de Supabase
├── start_server.py       # Script de inicio
├── test_users.py         # Pruebas del sistema de usuarios
├── config.env            # Configuración de entorno
├── requirements.txt      # Dependencias
└── static/
    └── uploads/          # Archivos subidos
```

## 🔧 Configuración Avanzada

### Variables de Entorno Importantes
```env
SECRET_KEY=tu-clave-secreta
ADMIN_USERNAME=tu-email@ejemplo.com
ADMIN_PASSWORD=tu-contraseña
SUPABASE_URL=tu-url-de-supabase
SUPABASE_SERVICE_KEY=tu-clave-de-supabase
```

### Base de Datos
- **SQLite**: Se crea automáticamente en `products.db`
- **Supabase**: Configurar en variables de entorno
- **Híbrido**: Funciona con ambos sistemas

## 📊 Estructura de Datos de Usuario

```json
{
  "id": 1,
  "user_id": "user_123",
  "email": "usuario@ejemplo.com",
  "name": "Nombre del Usuario",
  "searches": 15,
  "last_seen": "2024-12-30T22:30:00",
  "blocked": false,
  "created_at": "2024-12-01T10:00:00"
}
```

## 🎯 Funcionalidades Específicas

### Bloqueo de Usuarios
- **Bloquear usuario**: Impide acceso al sistema
- **Desbloquear usuario**: Restaura acceso normal
- **Estado persistente**: Se mantiene en base de datos

### Seguimiento de Actividad
- **Última actividad**: Registra cuando el usuario estuvo activo
- **Contador de búsquedas**: Cuenta las búsquedas realizadas
- **Actualización automática**: Se actualiza con cada acción

### Validaciones
- **Email requerido**: Debe ser un email válido
- **Nombre requerido**: No puede estar vacío
- **ID único**: Cada usuario debe tener un ID único

## 🎯 Próximos Pasos

### Funcionalidades Pendientes
1. **Gestión de Banners** - Banners publicitarios
2. **Gestión de Vuelos** - Integración con APIs de vuelos
3. **Gestión de Pedidos** - Sistema de órdenes
4. **Métodos de Pago** - Integración de pagos
5. **Sistema de Billetera** - Gestión de saldos
6. **Chat de Soporte** - Sistema de mensajería
7. **Reglas del Sistema** - Configuraciones avanzadas
8. **Gestión de Vehículos** - Sistema de transporte
9. **Sistema de Nómina** - Gestión de empleados

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
