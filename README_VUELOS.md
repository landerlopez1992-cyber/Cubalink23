# ✈️ Sistema de Gestión de Vuelos - Cubalink23

## 📋 Descripción
Sistema completo de gestión de vuelos para el panel de administración de Cubalink23. Incluye funcionalidades CRUD completas, búsqueda avanzada, rutas populares e integración con APIs de vuelos charter.

## 🚀 Funcionalidades Implementadas

### ✅ Gestión de Vuelos
- **Crear vuelos** con información completa (origen, destino, aerolínea, horarios, precio)
- **Listar vuelos** con filtros y ordenamiento
- **Actualizar vuelos** existentes
- **Eliminar vuelos** del sistema
- **Búsqueda avanzada** por origen, destino, fecha y aerolínea
- **Rutas populares** con estadísticas de búsquedas y reservas

### ✅ Integración con Charter
- **Aerolíneas charter** configuradas (Xael, Cubazul, Havana Air)
- **Scraping automático** de vuelos charter
- **Markup configurable** por aerolínea
- **Búsqueda unificada** de vuelos regulares y charter
- **Gestión de reservas** charter

### ✅ Base de Datos
- **SQLite local** como respaldo principal
- **Integración con Supabase** (opcional)
- **Sistema híbrido** que funciona con o sin conexión a internet

### ✅ Seguridad
- **Autenticación requerida** para operaciones administrativas
- **Validación de datos** obligatorios
- **Control de acceso** por estado de vuelo

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

### ✈️ Vuelos (Admin)
- `GET /admin/api/flights` - Obtener todos los vuelos
- `POST /admin/api/flights` - Crear nuevo vuelo
- `PUT /admin/api/flights/<id>` - Actualizar vuelo
- `DELETE /admin/api/flights/<id>` - Eliminar vuelo
- `GET /admin/api/flights/search` - Buscar vuelos con filtros

### 🗺️ Rutas
- `GET /admin/api/routes` - Obtener rutas populares

### 🚁 Charter
- `GET /admin/api/charter-airlines` - Obtener aerolíneas charter
- `POST /admin/api/charter-search` - Buscar vuelos charter
- `POST /admin/api/charter-airlines/<id>/toggle` - Activar/desactivar aerolínea
- `POST /admin/api/charter-airlines/<id>/test` - Probar conexión

### 🏥 Health Check
- `GET /api/health` - Estado del servidor

## 🧪 Pruebas del Sistema

### Ejecutar Pruebas Automáticas
```bash
python test_flights.py
```

### Pruebas Manuales
1. **Acceder al panel**: http://localhost:3005/admin
2. **Login**: Usar credenciales del archivo config.env
3. **Navegar a Vuelos** y probar las funcionalidades

## 📁 Estructura de Archivos

```
backend-duffel/
├── app.py                 # Aplicación principal Flask
├── admin_routes.py        # Rutas del panel de administración
├── charter_routes.py      # Rutas específicas de charter
├── charter_scraper.py     # Scraper de vuelos charter
├── auth_routes.py         # Rutas de autenticación
├── database.py           # Clase de base de datos local
├── supabase_service.py   # Servicio de Supabase
├── start_server.py       # Script de inicio
├── test_flights.py       # Pruebas del sistema de vuelos
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
DUFFEL_API_KEY=tu-clave-de-duffel
```

### Base de Datos
- **SQLite**: Se crea automáticamente en `products.db`
- **Supabase**: Configurar en variables de entorno
- **Híbrido**: Funciona con ambos sistemas

## 📊 Estructura de Datos de Vuelo

```json
{
  "id": 1,
  "origin": "MIA",
  "destination": "HAV",
  "airline": "American Airlines",
  "flight_number": "AA123",
  "departure_time": "2024-12-31T10:30:00",
  "arrival_time": "2024-12-31T11:45:00",
  "price": 299.99,
  "currency": "USD",
  "status": "active",
  "available_seats": 150,
  "created_at": "2024-12-30T22:30:00"
}
```

## 🎯 Funcionalidades Específicas

### Búsqueda de Vuelos
- **Filtros múltiples**: Origen, destino, fecha, aerolínea
- **Búsqueda en tiempo real**: Resultados instantáneos
- **Ordenamiento**: Por precio, horario, duración
- **Paginación**: Resultados paginados para mejor rendimiento

### Integración Charter
- **Scraping automático**: Actualización periódica de vuelos charter
- **Markup configurable**: Margen de ganancia por aerolínea
- **Fallback**: Sistema de respaldo si falla el scraping
- **Logs detallados**: Registro de todas las operaciones

### Rutas Populares
- **Análisis de datos**: Estadísticas de búsquedas y reservas
- **Top 10 rutas**: Las rutas más populares
- **Tendencias**: Análisis de patrones de viaje
- **Reportes**: Informes detallados de actividad

### Gestión de Aerolíneas
- **Configuración flexible**: Parámetros por aerolínea
- **Estado activo/inactivo**: Control de disponibilidad
- **Frecuencia de actualización**: Configurable por aerolínea
- **Pruebas de conexión**: Verificación de disponibilidad

## 🎯 Próximos Pasos

### Funcionalidades Pendientes
1. **Gestión de Pedidos** - Sistema de órdenes
2. **Métodos de Pago** - Integración de pagos
3. **Sistema de Billetera** - Gestión de saldos
4. **Chat de Soporte** - Sistema de mensajería
5. **Reglas del Sistema** - Configuraciones avanzadas
6. **Gestión de Vehículos** - Sistema de renta car

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

### Error de Charter
```bash
# Verificar configuración de aerolíneas
python -c "from charter_routes import CHARTER_AIRLINES; print(CHARTER_AIRLINES)"
# Revisar logs de scraping
tail -f charter_scraper.log
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

