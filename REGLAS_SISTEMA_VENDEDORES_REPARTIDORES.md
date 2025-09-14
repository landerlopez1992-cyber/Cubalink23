# SISTEMA DE VENDEDORES Y REPARTIDORES - REGLAS Y FUNCIONALIDADES

## SISTEMA DE REPARTIDORES

### 1. Pantalla de Notificaciones
- Recibe alertas del panel admin web
- Pedidos atrasados, dañados, etc.
- Notificaciones en tiempo real

### 2. Pantalla de Órdenes Asignadas
- Muestra todas las órdenes asignadas
- Puede aceptar y cancelar rápidamente
- **REGLA IMPORTANTE**: Si cancela, el sistema reenvía la orden al repartidor más cercano
- Interfaz rápida para decisión inmediata

### 3. Pantalla Mi Billetera
- Ver saldo total de sus entregas
- Retirar dinero a tarjeta débito/crédito
- Transferir a cualquier otro usuario
- Historial de transacciones

### 4. Pantalla de Perfil de Repartidor
- Nombre completo
- Foto profesional
- Datos personales (teléfono, edad)
- **FOTO DEL AUTO** - Para que el usuario vea en qué recibirá el pedido y tenga más confianza
- Información de contacto

### 5. Pantalla de Chat de Soporte
- Comunicación directa con panel admin web
- Soporte técnico
- Resolución de problemas

### 6. Dashboard de Repartidor (EXISTENTE - MEJORAR)
- Al final mostrar cantidad de órdenes pendientes y entregadas
- Como un registro de todo
- Al hacer clic redirige a "Órdenes Asignadas"

## SISTEMA DE VENDEDORES

### 1. Pantalla Mis Órdenes
- Muestra todas las órdenes que debe preparar
- **LÓGICA IMPORTANTE**:
  - Si el vendedor configuró entrega propia: puede cambiar estados (preparando, enviada, en reparto, etc.)
  - Si NO configuró entrega propia: se asigna a repartidor y YA NO puede cambiarlo
- Estados de orden según configuración previa

### 2. Pantalla Agregar Producto
- Herramientas iguales al panel admin
- **RESTRICCIÓN**: Solo puede editar/subir SUS productos
- NO puede ver/editar productos de otros vendedores
- NO puede ver/editar productos del sistema

### 3. Pantalla Mi Billetera
- Mismas funciones que repartidor
- Saldo total, retiros, transferencias
- Historial de transacciones

### 4. Pantalla de Soporte
- Igual que repartidor
- Comunicación con panel admin web

### 5. Dashboard de Vendedor (EXISTENTE - MEJORAR)
- Mostrar pedidos pendientes y entregados
- Como registro de todo
- Estadísticas de ventas

### 6. Pantalla de Notificaciones
- Igual que repartidor
- Alertas del panel admin web

## NOTAS TÉCNICAS IMPORTANTES

### Estados de Órdenes
- **Preparando orden**: Vendedor preparando
- **Orden enviada**: Vendedor envió
- **En reparto**: En camino al cliente
- **Entregada**: Completada

### Lógica de Asignación
- Si vendedor NO configuró entrega propia → Se asigna a repartidor automáticamente
- Si vendedor SÍ configuró entrega propia → Puede manejar estados manualmente

### Sistema de Reasignación
- Si repartidor cancela → Sistema busca repartidor más cercano
- Reenvío automático de órdenes

### Restricciones de Acceso
- Vendedores solo ven SUS productos
- No pueden acceder a productos de otros vendedores
- No pueden acceder a productos del sistema

## ESTADO ACTUAL
- ✅ Dashboards creados con botones
- ✅ Sistema de roles implementado
- ✅ Conexión a Supabase configurada
- ⏳ **PENDIENTE**: Crear todas las pantallas mencionadas
- ⏳ **PENDIENTE**: Conectar pantallas a botones existentes

## PRÓXIMOS PASOS
1. Crear pantallas de repartidor (notificaciones, órdenes, billetera, perfil, chat)
2. Crear pantallas de vendedor (mis órdenes, agregar producto, billetera, soporte, notificaciones)
3. Conectar todas las pantallas a los botones existentes
4. Implementar lógica de estados y asignaciones
5. Probar funcionalidad completa





