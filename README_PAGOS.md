# 💳 Sistema de Métodos de Pago - Cubalink23

## 📋 Descripción
Sistema completo de métodos de pago para Cubalink23 integrado con **Square** como pasarela principal. Incluye procesamiento de pagos, enlaces de pago, reembolsos, gestión de clientes y reportes detallados.

## 🚀 Funcionalidades Implementadas

### ✅ Integración con Square
- **Procesamiento de pagos** con tarjetas de crédito/débito
- **Enlaces de pago** para checkout online
- **Square Cash** para pagos móviles
- **Tarjetas de regalo** Square
- **Gestión de clientes** en Square
- **Reembolsos** automáticos y manuales

### ✅ Métodos de Pago Disponibles
- **💳 Tarjeta de Crédito/Débito** - Visa, MasterCard, American Express
- **📱 Square Cash** - Pago con Square Cash App
- **🎁 Tarjeta de Regalo** - Tarjetas de regalo Square
- **🏦 Transferencia Bancaria** - Transferencia directa
- **💵 Pago en Efectivo** - Pago al recibir el pedido

### ✅ Gestión de Pagos
- **Crear enlaces de pago** para pedidos
- **Procesar pagos** en tiempo real
- **Verificar estados** de pagos
- **Reembolsar pagos** completos o parciales
- **Historial de transacciones** detallado

### ✅ Gestión de Clientes
- **Crear clientes** en Square
- **Información completa** de contacto
- **Direcciones múltiples** por cliente
- **Historial de pagos** por cliente

### ✅ Reportes y Analytics
- **Transacciones por período** con filtros
- **Estadísticas de pagos** en tiempo real
- **Análisis de métodos** de pago más usados
- **Reportes de reembolsos** y devoluciones

### ✅ Seguridad
- **Autenticación requerida** para operaciones
- **Validación de datos** obligatorios
- **Logs de auditoría** completos
- **Modo sandbox** para desarrollo

## 🛠️ Instalación y Configuración

### 1. Instalar Dependencias
```bash
pip install -r requirements.txt
```

### 2. Configurar Square
Obtener credenciales de Square Developer Dashboard:
- **Access Token** - Token de acceso para la API
- **Application ID** - ID de la aplicación
- **Location ID** - ID de la ubicación de negocio

### 3. Configurar Variables de Entorno
```bash
# Configuración de Square
SQUARE_ACCESS_TOKEN=tu-access-token-de-square
SQUARE_APPLICATION_ID=tu-application-id-de-square
SQUARE_LOCATION_ID=tu-location-id-de-square
SQUARE_ENVIRONMENT=sandbox  # o production
```

### 4. Iniciar el Servidor
```bash
python start_server.py
```

## 📊 Endpoints Disponibles

### 🔐 Autenticación
- `POST /auth/login` - Login del administrador
- `GET /auth/logout` - Cerrar sesión

### 💳 Métodos de Pago (Admin)
- `GET /admin/api/payment-methods` - Obtener métodos disponibles
- `POST /admin/api/payments/create-link` - Crear enlace de pago
- `POST /admin/api/payments/process` - Procesar pago
- `GET /admin/api/payments/<id>/status` - Obtener estado de pago
- `POST /admin/api/payments/<id>/refund` - Reembolsar pago
- `GET /admin/api/payments/transactions` - Historial de transacciones

### 👤 Clientes
- `POST /admin/api/payments/customers` - Crear cliente

### 🔧 Configuración
- `GET /admin/api/payments/square-status` - Estado de Square
- `GET /admin/api/payments/test-connection` - Probar conexión

### 🏥 Health Check
- `GET /api/health` - Estado del servidor

## 🧪 Pruebas del Sistema

### Ejecutar Pruebas Automáticas
```bash
python test_payments.py
```

### Pruebas Manuales
1. **Acceder al panel**: http://localhost:3005/admin
2. **Login**: Usar credenciales del archivo config.env
3. **Navegar a Pagos** y probar las funcionalidades

## 📁 Estructura de Archivos

```
backend-duffel/
├── app.py                 # Aplicación principal Flask
├── admin_routes.py        # Rutas del panel de administración
├── square_service.py      # Servicio de integración con Square
├── auth_routes.py         # Rutas de autenticación
├── database.py           # Clase de base de datos local
├── supabase_service.py   # Servicio de Supabase
├── start_server.py       # Script de inicio
├── test_payments.py      # Pruebas del sistema de pagos
├── config.env            # Configuración de entorno
├── requirements.txt      # Dependencias
└── static/
    └── uploads/          # Archivos subidos
```

## 🔧 Configuración Avanzada

### Variables de Entorno Importantes
```env
# Square Configuration
SQUARE_ACCESS_TOKEN=tu-access-token-de-square
SQUARE_APPLICATION_ID=tu-application-id-de-square
SQUARE_LOCATION_ID=tu-location-id-de-square
SQUARE_ENVIRONMENT=sandbox

# Otras configuraciones
SECRET_KEY=tu-clave-secreta
ADMIN_USERNAME=tu-email@ejemplo.com
ADMIN_PASSWORD=tu-contraseña
```

### Configuración de Square
- **Sandbox**: Para desarrollo y pruebas
- **Production**: Para operaciones reales
- **Webhooks**: Para notificaciones automáticas

## 📊 Estructura de Datos

### Enlace de Pago
```json
{
  "success": true,
  "payment_link_id": "link_123456",
  "checkout_url": "https://checkout.square.site/...",
  "order_id": 1,
  "amount": 99.99,
  "currency": "USD"
}
```

### Pago Procesado
```json
{
  "success": true,
  "payment_id": "payment_123456",
  "status": "COMPLETED",
  "amount": 99.99,
  "currency": "USD",
  "receipt_url": "https://receipt.square.com/...",
  "order_id": 1
}
```

### Cliente
```json
{
  "success": true,
  "customer_id": "customer_123456",
  "email": "cliente@ejemplo.com",
  "name": "Juan Pérez"
}
```

## 🎯 Funcionalidades Específicas

### Procesamiento de Pagos
- **Múltiples métodos** de pago
- **Validación automática** de tarjetas
- **Procesamiento en tiempo real** con Square
- **Fallback a modo mock** si Square no está disponible
- **Soporte para pagos internacionales**

### Enlaces de Pago
- **Generación automática** de enlaces únicos
- **Personalización** con logo y colores
- **Expiración configurable** de enlaces
- **Seguimiento** de clics y conversiones
- **Integración** con sistema de pedidos

### Gestión de Reembolsos
- **Reembolsos completos** y parciales
- **Múltiples razones** de reembolso
- **Procesamiento automático** con Square
- **Notificaciones** al cliente
- **Historial** de reembolsos

### Reportes y Analytics
- **Dashboard en tiempo real** de transacciones
- **Análisis por método** de pago
- **Tendencias** de pagos por período
- **Exportación** de datos (futuro)
- **Alertas** de transacciones sospechosas

### Seguridad y Compliance
- **PCI DSS Compliance** a través de Square
- **Encriptación** de datos sensibles
- **Logs de auditoría** completos
- **Detección de fraudes** (futuro)
- **Backup automático** de transacciones

## 🎯 Próximos Pasos

### Funcionalidades Pendientes
1. **Sistema de Billetera** - Gestión de saldos
2. **Chat de Soporte** - Sistema de mensajería
3. **Reglas del Sistema** - Configuraciones avanzadas
4. **Gestión de Vehículos** - Sistema de renta car

### Mejoras Futuras
- **Integración con PayPal** como alternativa
- **Sistema de cupones** y descuentos
- **Pagos recurrentes** y suscripciones
- **Split payments** para múltiples métodos
- **Pagos en criptomonedas** (Bitcoin, etc.)
- **Sistema de lealtad** y puntos

## 🐛 Solución de Problemas

### Error de Conexión con Square
```bash
# Verificar configuración
python -c "from square_service import square_service; print(square_service.is_available())"

# Verificar variables de entorno
echo $SQUARE_ACCESS_TOKEN
echo $SQUARE_APPLICATION_ID
echo $SQUARE_LOCATION_ID
```

### Error de Procesamiento de Pago
```bash
# Verificar logs de Square
tail -f square_service.log

# Probar conexión
curl -X GET "http://localhost:3005/admin/api/payments/test-connection"
```

### Error de Dependencias
```bash
# Reinstalar dependencias de Square
pip install square==35.0.0 --force-reinstall

# Verificar instalación
python -c "import square; print('Square instalado correctamente')"
```

### Problemas de Configuración
```bash
# Verificar estado de Square
curl -X GET "http://localhost:3005/admin/api/payments/square-status"

# Resetear configuración
export SQUARE_ENVIRONMENT=sandbox
python start_server.py
```

### Error de Webhooks
```bash
# Verificar endpoint de webhooks
curl -X POST "http://localhost:3005/webhooks/square" \
  -H "Content-Type: application/json" \
  -d '{"test": "webhook"}'

# Configurar webhook en Square Dashboard
# URL: https://tu-dominio.com/webhooks/square
```

## 📞 Soporte

### Square Developer Support
- **Documentación**: https://developer.squareup.com/
- **API Reference**: https://developer.squareup.com/reference
- **Support Center**: https://developer.squareup.com/support

### Cubalink23 Support
Para soporte técnico o preguntas sobre el sistema, contactar al equipo de desarrollo de Cubalink23.

---
**Versión**: 1.0.0  
**Última actualización**: Diciembre 2024  
**Desarrollado por**: Equipo Cubalink23  
**Integración**: Square Payments

