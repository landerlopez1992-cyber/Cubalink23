# FLUJO DE PEDIDOS - VENDEDOR Y REPARTIDOR

## LÓGICA PRINCIPAL DEL FLUJO

### 1. CUANDO SE CREA UNA ORDEN
- El user compra y paga la orden
- Se le crea al vendedor correspondiente o al sistema
- El vendedor debe aceptar el pedido lo más rápido posible

### 2. PREPARACIÓN Y ASIGNACIÓN
- Una vez que el vendedor acepta, debe preparar el pedido
- Si el vendedor NO configuró entrega propia:
  - El sistema asigna automáticamente un repartidor cercano
  - El vendedor ve los datos del repartidor asignado
  - El vendedor debe ponerse de acuerdo con el repartidor para entregarle el pedido
  - El repartidor sabe qué vendedor está preparando el pedido

### 3. COORDINACIÓN VENDEDOR-REPARTIDOR
- El vendedor prepara el pedido y marca como "Preparado"
- El vendedor contacta al repartidor para coordinar la entrega
- El repartidor puede ver la ubicación del vendedor
- El repartidor recoge el pedido del vendedor
- El repartidor continúa con la entrega al cliente final

### 4. FLUJO SIMILAR A UBER
- Sistema de asignación automática basado en cercanía
- Comunicación directa entre vendedor y repartidor
- Estados en tiempo real para todas las partes
- Optimización de rutas y tiempos

## PANTALLAS QUE NECESITAN CAMBIOS

### PANTALLA DE VENDEDOR - MIS ÓRDENES
- Mostrar datos del repartidor asignado cuando corresponda
- Botón para contactar al repartidor
- Ubicación del repartidor en mapa (opcional)
- Estado de "Listo para entregar al repartidor"

### PANTALLA DE REPARTIDOR - ÓRDENES ASIGNADAS  
- Mostrar datos del vendedor que prepara el pedido
- Botón para contactar al vendedor
- Ubicación del vendedor en mapa
- Estado de "Recoger del vendedor" → "Entregar al cliente"

### ESTADOS DE ORDEN ACTUALIZADOS
1. **Pendiente** - Esperando aceptación del vendedor
2. **Aceptada** - Vendedor aceptó, preparando pedido
3. **Preparando** - Vendedor preparando el producto
4. **Listo para Repartidor** - Preparado, esperando recogida
5. **Recogido por Repartidor** - Repartidor tiene el pedido
6. **En Camino al Cliente** - Repartidor va hacia cliente
7. **Entregado** - Pedido completado

## FUNCIONALIDADES A IMPLEMENTAR

### COMUNICACIÓN DIRECTA
- Chat directo vendedor ↔ repartidor
- Botones de llamada rápida
- Notificaciones push en tiempo real

### COORDINACIÓN DE UBICACIÓN
- Vendedor ve ubicación aproximada del repartidor
- Repartidor ve ubicación exacta del vendedor
- Tiempo estimado de llegada

### SISTEMA DE NOTIFICACIONES
- Al vendedor: "Repartidor [Nombre] asignado para recoger tu pedido"
- Al repartidor: "Vendedor [Nombre] preparando tu pedido para recoger"
- Actualizaciones de estado en tiempo real

## REGLAS DE NEGOCIO

### ASIGNACIÓN AUTOMÁTICA
- El sistema asigna el repartidor más cercano disponible
- Considera la calificación del repartidor
- Considera la carga de trabajo actual

### TIMEOUTS Y REASIGNACIÓN
- Si vendedor no acepta en X minutos → Se ofrece a otro vendedor
- Si repartidor no confirma recogida en Y minutos → Se reasigna
- Si vendedor no prepara en Z minutos → Notificación de retraso

### CALIFICACIONES
- Cliente califica al repartidor por la entrega
- Cliente puede calificar al vendedor por la preparación
- Repartidor puede calificar al vendedor por la coordinación

## IMPLEMENTACIÓN TÉCNICA

### BASE DE DATOS (SUPABASE)
```sql
-- Tabla de órdenes con campos adicionales
orders {
  id,
  vendor_id,
  delivery_person_id,
  customer_id,
  status,
  vendor_location,
  delivery_location,
  pickup_time,
  delivery_time,
  vendor_delivery_config
}

-- Tabla de asignaciones
order_assignments {
  order_id,
  vendor_id,
  delivery_person_id,
  assigned_at,
  status
}
```

### NOTIFICACIONES EN TIEMPO REAL
- WebSockets para actualizaciones instantáneas
- Push notifications para móvil
- Estados sincronizados entre todas las pantallas

## MEJORAS DE UX

### PANTALLA VENDEDOR
- Timeline visual del estado del pedido
- Información del repartidor (foto, nombre, calificación)
- Botón de emergencia "Repartidor no llegó"

### PANTALLA REPARTIDOR
- Información del vendedor (foto, nombre, dirección)
- Navegación GPS integrada
- Botón de confirmación "Pedido recogido"

### PANTALLA CLIENTE
- Seguimiento en tiempo real
- "Tu pedido está siendo preparado por [Vendedor]"
- "Tu pedido está en camino con [Repartidor]"





