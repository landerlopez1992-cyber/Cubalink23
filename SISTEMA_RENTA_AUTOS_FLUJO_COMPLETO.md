# 🚗 SISTEMA DE RENTA DE AUTOS - FLUJO COMPLETO

## 🏢 **INFORMACIÓN DE RENTCARCUBA.COM:**

### **Tipos de Vehículos Disponibles:**
- **Autos** - Vehículos estándar
- **Autos de Lujo** - Vehículos premium (REX)
- **Motos** - Motocicletas
- **Shuttle** - Servicio de transporte con rutas fijas
- **Bus Tour** - Tours panorámicos
- **Autos Eléctricos** - Vehículos ecológicos
- **Ecotur** - Safari 4x4 y aventuras

### **Rutas de Shuttle:**
- **Vedado**: 9:40 AM - 10:40 PM
- **Habana Vieja**: 9:55 AM - 10:55 PM  
- **Playa**: 9:30 AM - 10:35 PM

### **Disponibilidad:**
- Reservas disponibles desde **diciembre 2024 hasta junio 2025**
- Sistema de verificación de disponibilidad en tiempo real

## 💰 **MODELO DE NEGOCIO:**

### **Precios:**
- **Cubalink23 NO altera los precios** de rentcarcuba.com
- **Precios son los mismos** de primera mano de Cuba
- **Comisión fija**: $30 USD por cada reserva realizada
- **Comisión se cobra** cuando usuario paga en los 5 minutos

### **Términos y Condiciones:**
- Cubalink23 actúa como **proveedor de servicios de renta de autos**
- **Notificaciones y correos** mantienen branding Cubalink23
- **Términos y condiciones** de Cubalink23 aplican
- **Precios finales** incluyen comisión de $30
- **NUNCA mencionar** sitios externos ni nombres de terceros

## 📋 **FLUJO DEL USUARIO:**

### **1. Selección de Auto:**
- Usuario ve autos disponibles (agregados desde panel admin)
- Usuario selecciona: **provincia**, **fechas**, **tipo de auto**
- Sistema muestra **precio de Cubalink23** (precio base + comisión de $30)
- **Precio final** = Precio base + $30 USD
- Usuario puede hacer **PRERESERVA**

### **2. Prerreserva:**
- Se guarda en **reservas pendientes** del usuario
- Sistema envía **notificación/email** explicando:
  - "Sistema está verificando disponibilidad"
  - "Recibirá notificación para realizar pago si hay disponibilidad"
  - "O recibirá notificación si no hay disponibilidad"

### **3. Respuesta del Sistema:**
- **Si hay disponibilidad**: Usuario recibe notificación + **5 minutos para pagar**
- **Si no hay disponibilidad**: Usuario recibe notificación de cancelación

### **4. Pago y Confirmación:**
- Usuario paga dentro de 5 minutos
- Recibe **reserva confirmada** en su cuenta
- Puede ver **reservas pendientes** y **confirmadas** en la app

---

## 🔧 **FLUJO DEL ADMIN:**

### **1. Verificación de Prerreserva:**
- Admin ve prerreserva en **panel web**
- Admin entra al **sitio web externo** para verificar disponibilidad

### **2. Decisión de Disponibilidad:**
- **Si hay disponibilidad**: 
  - Admin presiona **"Aceptar prerreserva"**
  - Usuario recibe notificación + **5 minutos para pagar**
- **Si no hay disponibilidad**:
  - Admin presiona **"Rechazar prerreserva"**
  - Usuario recibe notificación de cancelación

### **3. Proceso de Pago:**
- Una vez que usuario paga: **Admin recibe el dinero** (precio base + $30 comisión)
- Admin verifica disponibilidad y hace la **reserva real** con precio base
- Admin presiona botón para **enviar boucher** de reserva confirmada al usuario
- **Cubalink23 se queda con $30** de comisión por servicio

---

## 🗄️ **ESTADOS DEL SISTEMA:**

| Estado | Descripción | Acción Requerida |
|--------|-------------|------------------|
| `prerreserva_pendiente` | Usuario hizo prerreserva, esperando verificación admin | Admin verificar disponibilidad |
| `disponibilidad_verificada` | Admin confirmó disponibilidad, usuario tiene 5 min para pagar | Usuario pagar en 5 minutos |
| `pago_pendiente` | Usuario debe pagar en 5 minutos | Usuario realizar pago |
| `pago_realizado` | Usuario pagó, admin debe hacer reserva real | Admin hacer reserva externa |
| `reserva_confirmada` | Admin hizo reserva real y envió boucher | Usuario recibir boucher |
| `cancelada` | Por timeout de pago o falta de disponibilidad | Sistema automático |

---

## ⏰ **TIMEOUTS Y TIEMPOS:**

- **Verificación admin**: Sin límite (admin decide cuándo verificar)
- **Pago usuario**: **5 minutos** después de confirmar disponibilidad
- **Reserva externa**: Admin debe hacer reserva real después del pago
- **Envío boucher**: Admin envía boucher después de reserva externa

---

## 🔔 **NOTIFICACIONES:**

### **Para Usuario:**
1. **Prerreserva creada**: "Cubalink23 está verificando disponibilidad..."
2. **Disponibilidad confirmada**: "¡Disponible! Tienes 5 minutos para pagar"
3. **Disponibilidad rechazada**: "No disponible para esas fechas"
4. **Pago exitoso**: "Pago confirmado, Cubalink23 procesando tu reserva..."
5. **Reserva confirmada**: "¡Reserva confirmada! Aquí está tu boucher de Cubalink23"

### **Para Admin:**
1. **Nueva prerreserva**: "Nueva prerreserva pendiente de verificación"
2. **Pago recibido**: "Usuario pagó, hacer reserva real"
3. **Reserva completada**: "Enviar boucher al usuario"

---

## 📱 **PANTALLAS NECESARIAS:**

### **Para Usuario:**
- ✅ Pantalla de selección de autos (ya existe)
- ❌ **FALTA**: Pantalla de reservas del usuario (pendientes y confirmadas)
- ❌ **FALTA**: Pantalla de detalles de reserva con boucher

### **Para Admin:**
- ❌ **FALTA**: Panel de prerreservas pendientes
- ❌ **FALTA**: Botones de aceptar/rechazar prerreserva
- ❌ **FALTA**: Panel de reservas pagadas (para hacer reserva externa)
- ❌ **FALTA**: Botón para enviar boucher

---

## 🗃️ **TABLAS DE BASE DE DATOS NECESARIAS:**

1. **`car_rental_reservations`** - Reservas de autos
2. **`car_rental_vehicles`** - Vehículos disponibles (tipos: autos, lujo, motos, shuttle, bus_tour, electricos, ecotur)
3. **`car_rental_payments`** - Pagos de reservas (precio original + comisión $30)
4. **`car_rental_bouchers`** - Bouchers de reservas confirmadas
5. **`car_rental_shuttle_routes`** - Rutas de shuttle (Vedado, Habana Vieja, Playa)
6. **`car_rental_commissions`** - Comisiones de $30 por reserva

---

## 🎯 **PRÓXIMOS PASOS:**

1. **Crear tablas de base de datos** para el sistema de renta
2. **Implementar lógica de prerreservas** con timeouts de 5 minutos
3. **Crear panel admin** para gestión de prerreservas
4. **Crear pantallas de usuario** para ver reservas
5. **Implementar notificaciones** automáticas con branding Cubalink23
6. **Integrar sistema de pagos** con comisión de $30
7. **Implementar verificación** de disponibilidad del sistema
8. **Crear sistema de bouchers** para reservas confirmadas

## 🔗 **INTEGRACIÓN DEL SISTEMA:**

- **Verificación de disponibilidad** en tiempo real
- **Precios base** sin alteración
- **Comisión fija** de $30 por reserva
- **Branding Cubalink23** en notificaciones y correos
- **Términos y condiciones** de Cubalink23
- **NUNCA mencionar** sitios externos ni nombres de terceros

---

*¿Entiendes el flujo completo? ¿Procedemos con la implementación de la FASE 6?*
