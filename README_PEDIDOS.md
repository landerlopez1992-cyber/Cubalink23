# 📦 Sistema de Gestión de Pedidos - Cubalink23

## 📋 Descripción
Sistema completo de gestión de pedidos para el panel de administración de Cubalink23. Incluye funcionalidades CRUD completas, gestión de estados, seguimiento de pagos, estadísticas avanzadas y reportes detallados.

## 🚀 Funcionalidades Implementadas

### ✅ Gestión de Pedidos
- **Crear pedidos** con productos, cantidades y precios
- **Listar pedidos** con filtros y ordenamiento
- **Actualizar pedidos** existentes
- **Eliminar pedidos** del sistema
- **Números de pedido únicos** generados automáticamente
- **Historial completo** de cambios

### ✅ Estados de Pedido
- **Pending** - Pendiente de procesamiento
- **Processing** - En procesamiento
- **Shipped** - Enviado
- **Delivered** - Entregado
- **Cancelled** - Cancelado
- **Refunded** - Reembolsado

### ✅ Estados de Pago
- **Pending** - Pago pendiente
- **Paid** - Pagado
- **Failed** - Fallido
- **Refunded** - Reembolsado
- **Partially Refunded** - Reembolso parcial

### ✅ Gestión de Clientes
- **Asociación con usuarios** del sistema
- **Información de contacto** completa
- **Historial de pedidos** por cliente
- **Direcciones de envío** múltiples

### ✅ Estadísticas y Reportes
- **Total de pedidos** por período
- **Ventas totales** y por mes
- **Pedidos por estado** y método de pago
- **Análisis de tendencias** de ventas
- **Reportes exportables**

### ✅ Base de Datos
- **SQLite local** como respaldo principal
- **Integración con Supabase** (opcional)
- **Sistema híbrido** que funciona con o sin conexión a internet

### ✅ Seguridad
- **Autenticación requerida** para operaciones administrativas
- **Validación de datos** obligatorios
- **Control de acceso** por estado de pedido
- **Logs de auditoría** completos

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

### 📦 Pedidos (Admin)
- `GET /admin/api/orders` - Obtener todos los pedidos
- `POST /admin/api/orders` - Crear nuevo pedido
- `PUT /admin/api/orders/<id>` - Actualizar pedido
- `DELETE /admin/api/orders/<id>` - Eliminar pedido
- `GET /admin/api/orders/user/<user_id>` - Obtener pedidos de un usuario
- `GET /admin/api/orders/status/<status>` - Obtener pedidos por estado

### 🔄 Estados
- `PUT /admin/api/orders/<id>/status` - Actualizar estado del pedido
- `PUT /admin/api/orders/<id>/payment-status` - Actualizar estado de pago

### 📈 Estadísticas
- `GET /admin/api/orders/statistics` - Obtener estadísticas de pedidos

### 🏥 Health Check
- `GET /api/health` - Estado del servidor

## 🧪 Pruebas del Sistema

### Ejecutar Pruebas Automáticas
```bash
python test_orders.py
```

### Pruebas Manuales
1. **Acceder al panel**: http://localhost:3005/admin
2. **Login**: Usar credenciales del archivo config.env
3. **Navegar a Pedidos** y probar las funcionalidades

## 📁 Estructura de Archivos

```
backend-duffel/
├── app.py                 # Aplicación principal Flask
├── admin_routes.py        # Rutas del panel de administración
├── auth_routes.py         # Rutas de autenticación
├── database.py           # Clase de base de datos local
├── supabase_service.py   # Servicio de Supabase
├── start_server.py       # Script de inicio
├── test_orders.py        # Pruebas del sistema de pedidos
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

## 📊 Estructura de Datos de Pedido

```json
{
  "id": 1,
  "order_number": "ORD-20241230-1703987654",
  "user_id": 1,
  "customer_name": "Juan Pérez",
  "customer_email": "juan@ejemplo.com",
  "items": [
    {
      "product_id": 1,
      "name": "Producto Ejemplo",
      "price": 29.99,
      "quantity": 2,
      "subtotal": 59.98
    }
  ],
  "total_amount": 59.98,
  "currency": "USD",
  "status": "pending",
  "payment_method": "credit_card",
  "payment_status": "pending",
  "shipping_address": {
    "street": "123 Calle Principal",
    "city": "Miami",
    "state": "FL",
    "zip_code": "33101",
    "country": "USA"
  },
  "notes": "Notas del pedido",
  "created_at": "2024-12-30T22:30:00"
}
```

## 🎯 Funcionalidades Específicas

### Gestión de Productos en Pedidos
- **Múltiples productos** por pedido
- **Cantidades variables** por producto
- **Cálculo automático** de subtotales
- **Precios históricos** preservados
- **Stock tracking** (futuro)

### Estados de Pedido
- **Flujo de trabajo** configurable
- **Notificaciones automáticas** por cambio de estado
- **Historial de cambios** completo
- **Estados personalizables** por negocio

### Gestión de Pagos
- **Múltiples métodos** de pago
- **Estados de pago** independientes
- **Integración con pasarelas** (futuro)
- **Reembolsos** y devoluciones

### Reportes y Analytics
- **Dashboard en tiempo real** de ventas
- **Análisis de tendencias** por período
- **Top productos** más vendidos
- **Análisis de clientes** recurrentes
- **Exportación a Excel/PDF** (futuro)

### Notificaciones
- **Email automático** al crear pedido
- **SMS de confirmación** (futuro)
- **Notificaciones push** (futuro)
- **Alertas de stock** bajo (futuro)

## 🎯 Próximos Pasos

### Funcionalidades Pendientes
1. **Métodos de Pago** - Integración de pagos
2. **Sistema de Billetera** - Gestión de saldos
3. **Chat de Soporte** - Sistema de mensajería
4. **Reglas del Sistema** - Configuraciones avanzadas
5. **Gestión de Vehículos** - Sistema de renta car

### Mejoras Futuras
- **Integración con pasarelas** de pago (Stripe, PayPal)
- **Sistema de cupones** y descuentos
- **Gestión de inventario** automática
- **Seguimiento de envíos** con APIs de courier
- **Sistema de reseñas** y calificaciones
- **Programa de fidelización** de clientes

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

### Error de Pedidos
```bash
# Verificar estructura de datos
python -c "from database import local_db; print(local_db.get_orders())"
# Revisar logs de errores
tail -f app.log
```

### Error de Dependencias
```bash
# Reinstalar dependencias
pip install -r requirements.txt --force-reinstall
```

### Problemas de Estados
```bash
# Verificar estados válidos
python -c "from database import local_db; print(local_db.get_orders_by_status('pending'))"
# Resetear estado de pedido
python -c "from database import local_db; local_db.update_order_status(1, 'pending')"
```

## 📞 Soporte
Para soporte técnico o preguntas sobre el sistema, contactar al equipo de desarrollo de Cubalink23.

---
**Versión**: 1.0.0  
**Última actualización**: Diciembre 2024  
**Desarrollado por**: Equipo Cubalink23

