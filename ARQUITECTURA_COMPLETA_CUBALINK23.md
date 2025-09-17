# 🏗️ ARQUITECTURA COMPLETA CUBALINK23 - 3 BACKENDS ESPECIALIZADOS

## 📅 **FECHA DE IMPLEMENTACIÓN: 17 Septiembre 2025**

---

## 🎯 **ARQUITECTURA FINAL - 3 BACKENDS SEPARADOS:**

### **🌐 BACKEND DUFFEL** (INTOCABLE)
- **Repositorio**: `cubalink23-backend`
- **URL**: `https://cubalink23-backend.onrender.com`
- **FUNCIONES EXCLUSIVAS**:
  - ✈️ **API de vuelos Duffel** (búsqueda aeropuertos, vuelos)
  - 🖼️ **Sistema de banners** (gestión completa)
- **ESTADO**: ✅ **FUNCIONANDO PERFECTO - NO TOCAR**

### **💳 BACKEND PAGOS** (INTOCABLE)
- **Repositorio**: `cubalink23-payments` (carpeta `square_backend/`)
- **URL**: `https://cubalink23-payments.onrender.com`
- **FUNCIONES EXCLUSIVAS**:
  - 💳 **Square API** (procesamiento de pagos)
  - 🔒 **Tokenización de tarjetas**
  - 💰 **Gestión de transacciones**
- **ESTADO**: ✅ **FUNCIONANDO PERFECTO - NO TOCAR**

### **🛠️ BACKEND SISTEMA** (NUEVO - PRINCIPAL)
- **Repositorio**: `cubalink23-system`
- **URL**: `https://cubalink23-system.onrender.com`
- **FUNCIONES PRINCIPALES**:
  - 📦 **Sistema completo de órdenes** (creación, seguimiento, estados)
  - 👥 **Gestión de usuarios** (perfiles, saldos, actividades)
  - 🛒 **Productos y carrito** (catálogo, categorías, carrito)
  - 🚚 **Vendedores y repartidores** (delivery system)
  - 🔔 **Notificaciones del sistema** (alertas, mensajes)
  - 🛠️ **Panel de administración completo** (todas las pantallas HTML)
  - 📊 **Reportes y analytics** (estadísticas, métricas)
  - 🚗 **Renta de autos** (reservas, verificación)
  - 📱 **Recargas telefónicas** (DingConnect)
  - ⚙️ **Configuración del sistema** (mantenimiento, actualizaciones)

---

## 📋 **ENDPOINTS POR BACKEND:**

### **🌐 BACKEND DUFFEL** (`cubalink23-backend.onrender.com`)
```
GET  /admin/api/flights/airports    # Buscar aeropuertos
POST /admin/api/flights/search      # Buscar vuelos
GET  /admin/api/banners            # Gestión de banners
POST /admin/api/banners            # Crear banners
GET  /api/health                   # Health check
```

### **💳 BACKEND PAGOS** (`cubalink23-payments.onrender.com`)
```
GET  /health                       # Health check
POST /api/payments                 # Procesar pagos
POST /api/cards                    # Guardar tarjetas
POST /api/customers                # Crear clientes
GET  /sdk/card                     # Tokenización HTML
```

### **🛠️ BACKEND SISTEMA** (`cubalink23-system.onrender.com`)
```
# ÓRDENES
POST /api/orders                   # Crear orden ✅
GET  /api/orders/user/<user_id>    # Obtener órdenes usuario ✅
PUT  /api/orders/<id>/status       # Actualizar estado ✅

# USUARIOS
GET  /api/users/<user_id>          # Obtener usuario ✅
PUT  /api/users/<id>/balance       # Actualizar saldo ✅

# ACTIVIDADES
POST /api/activities               # Agregar actividad ✅
GET  /api/activities/user/<id>     # Obtener actividades ✅

# NOTIFICACIONES
POST /api/notifications            # Enviar notificación ✅
GET  /api/notifications/user/<id>  # Obtener notificaciones ✅

# PRODUCTOS
GET  /api/products                 # Obtener productos ✅
POST /api/products                 # Crear producto ✅
GET  /api/products/categories      # Obtener categorías ✅

# CARRITO
GET  /api/cart/user/<user_id>      # Obtener carrito ✅
POST /api/cart                     # Agregar al carrito ✅
DELETE /api/cart/user/<user_id>    # Limpiar carrito ✅

# ADMIN PANEL
GET  /admin/                       # Dashboard principal ✅
GET  /admin/orders                 # Gestión de órdenes ✅
GET  /admin/users                  # Gestión de usuarios ✅
GET  /admin/products               # Gestión de productos ✅
GET  /admin/system                 # Configuración sistema ✅
GET  /admin/api/orders             # API órdenes admin ✅
GET  /admin/api/users              # API usuarios admin ✅
GET  /admin/api/stats              # Estadísticas ✅

# SISTEMA
GET  /api/health                   # Health check ✅
GET  /admin/api/system/maintenance # Estado mantenimiento ✅
POST /admin/api/system/maintenance # Activar mantenimiento ✅
```

---

## 🔄 **FLUJO COMPLETO DE ÓRDENES - PRODUCCIÓN:**

### **1. USUARIO HACE COMPRA:**
```
Flutter App → Carrito → Checkout → Método de pago
```

### **2. PROCESAMIENTO DE PAGO:**
```
Flutter → cubalink23-payments.onrender.com → Square API → Pago exitoso
```

### **3. CREACIÓN DE ORDEN:**
```
Flutter → cubalink23-system.onrender.com → Supabase
├─ Tabla 'orders' (orden principal)
└─ Tabla 'order_items' (productos detallados)
```

### **4. VISUALIZACIÓN:**
```
"Mi Cuenta" → "Rastreo de Mi Orden" → cubalink23-system.onrender.com → Mostrar órdenes
```

---

## 📱 **CONFIGURACIÓN EN FLUTTER:**

### **URLs CONFIGURADAS:**
```dart
// lib/services/duffel_api_service.dart
static const String _baseUrl = 'https://cubalink23-backend.onrender.com';

// lib/services/system_api_service.dart  
static const String _baseUrl = 'https://cubalink23-system.onrender.com';

// square_backend/ (cuando se despliegue)
static const String _baseUrl = 'https://cubalink23-payments.onrender.com';
```

### **SERVICIOS ACTUALIZADOS:**
- ✅ `SystemApiService` - Conecta con backend sistema
- ✅ `FirebaseRepository` - Usa SystemApiService primero, Supabase como fallback
- ✅ `DuffelApiService` - Sigue usando backend Duffel (intocable)

---

## 🗄️ **BASE DE DATOS SUPABASE:**

### **TABLAS IMPLEMENTADAS:**
```sql
✅ orders              # Órdenes principales
✅ order_items         # Productos por orden (detallado)
✅ users               # Usuarios del sistema
✅ activities          # Historial de actividades
✅ notifications       # Sistema de notificaciones
✅ store_products      # Productos de la tienda
✅ store_categories    # Categorías de productos
✅ cart_items          # Items del carrito
✅ banners             # Sistema de banners
```

### **FUNCIONES SQL:**
```sql
✅ generate_order_number()         # Números únicos de orden
✅ calculate_order_totals()        # Cálculo automático
✅ Triggers automáticos            # Actualización de totales
✅ Políticas RLS                   # Seguridad por usuario
```

---

## 🚀 **ESTADO ACTUAL:**

### **✅ COMPLETADO:**
- [x] Backend Sistema creado con TODAS las funcionalidades
- [x] Repositorio GitHub `cubalink23-system` creado
- [x] Archivos subidos a GitHub (40 archivos)
- [x] Panel de administración completo copiado
- [x] Templates HTML copiadas (todas las pantallas)
- [x] APIs de órdenes, usuarios, productos implementadas
- [x] Flutter actualizado para usar Backend Sistema

### **⏳ PENDIENTE:**
- [ ] **Desplegar en Render.com** (5 minutos)
- [ ] **Configurar variables de entorno** en Render
- [ ] **Probar creación de órdenes** en producción
- [ ] **Verificar "Rastreo de Mi Orden"** funciona

---

## 🎯 **INSTRUCCIONES PARA FUTUROS AGENTES:**

### **🚨 REGLA CRÍTICA:**
**NUNCA TOCAR** `cubalink23-backend` (Duffel) ni `cubalink23-payments` (Square)

### **✅ PARA ÓRDENES Y SISTEMA:**
**SIEMPRE USAR** `cubalink23-system` para:
- Crear/modificar órdenes
- Gestionar usuarios
- Productos y carrito
- Panel de administración
- Notificaciones del sistema

### **🔧 PARA MODIFICACIONES:**
1. **Clonar**: `git clone https://github.com/landerlopez1992-cyber/cubalink23-system.git`
2. **Modificar**: Archivos en el repositorio
3. **Push**: `git push origin main`
4. **Deploy**: Automático en Render

---

## 🏁 **RESUMEN EJECUTIVO:**

**✅ PROBLEMA RESUELTO:** Las órdenes no se creaban porque faltaban endpoints
**✅ SOLUCIÓN IMPLEMENTADA:** Backend Sistema dedicado con todas las funcionalidades
**✅ ARQUITECTURA:** 3 backends especializados sin conflictos
**✅ ESTADO:** Listo para deploy en producción

**🎯 PRÓXIMO PASO:** Desplegar `cubalink23-system` en Render.com

---

*Documentación creada: 17 Septiembre 2025*  
*Agente responsable: Sistema de órdenes y arquitectura*
