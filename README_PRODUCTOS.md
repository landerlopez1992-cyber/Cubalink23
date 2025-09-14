# 🛍️ Sistema de Gestión de Productos - Cubalink23

## 📋 Descripción
Sistema completo de gestión de productos para el panel de administración de Cubalink23. Incluye funcionalidades CRUD completas con soporte para imágenes y categorías.

## 🚀 Funcionalidades Implementadas

### ✅ Gestión de Productos
- **Crear productos** con nombre, descripción, precio, categoría, stock e imagen
- **Listar productos** con información completa
- **Actualizar productos** existentes
- **Eliminar productos** del sistema
- **Categorías automáticas** (Vuelos, Hoteles, Paquetes, Transporte, Actividades)

### ✅ Base de Datos
- **SQLite local** como respaldo principal
- **Integración con Supabase** (opcional)
- **Sistema híbrido** que funciona con o sin conexión a internet

### ✅ Autenticación
- **Sistema de login** seguro
- **Protección de rutas** con decoradores
- **Sesiones persistentes**

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

### 📦 Productos
- `GET /admin/api/products` - Obtener todos los productos
- `POST /admin/api/products` - Crear nuevo producto
- `PUT /admin/api/products/<id>` - Actualizar producto
- `DELETE /admin/api/products/<id>` - Eliminar producto

### 📂 Categorías
- `GET /admin/api/categories` - Obtener todas las categorías

### 🏥 Health Check
- `GET /api/health` - Estado del servidor

## 🧪 Pruebas del Sistema

### Ejecutar Pruebas Automáticas
```bash
python test_products.py
```

### Pruebas Manuales
1. **Acceder al panel**: http://localhost:3005/admin
2. **Login**: Usar credenciales del archivo config.env
3. **Navegar a Productos** y probar las funcionalidades

## 📁 Estructura de Archivos

```
backend-duffel/
├── app.py                 # Aplicación principal Flask
├── admin_routes.py        # Rutas del panel de administración
├── auth_routes.py         # Rutas de autenticación
├── database.py           # Clase de base de datos local
├── supabase_service.py   # Servicio de Supabase
├── start_server.py       # Script de inicio
├── test_products.py      # Pruebas del sistema
├── config.env            # Configuración de entorno
├── requirements.txt      # Dependencias
└── static/
    └── uploads/          # Imágenes subidas
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

## 🎯 Próximos Pasos

### Funcionalidades Pendientes
1. **Gestión de Usuarios** - Sistema completo de usuarios
2. **Gestión de Banners** - Banners publicitarios
3. **Gestión de Vuelos** - Integración con APIs de vuelos
4. **Gestión de Pedidos** - Sistema de órdenes
5. **Métodos de Pago** - Integración de pagos
6. **Sistema de Billetera** - Gestión de saldos
7. **Chat de Soporte** - Sistema de mensajería
8. **Reglas del Sistema** - Configuraciones avanzadas
9. **Gestión de Vehículos** - Sistema de transporte
10. **Sistema de Nómina** - Gestión de empleados

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
