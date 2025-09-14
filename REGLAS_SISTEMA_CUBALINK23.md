# REGLAS DEL SISTEMA CUBALINK23 - FUNCIONAMIENTO COMPLETO

## 1. FLUJO DE ESTADOS DE ÓRDENES

### Creación de Orden
- Al realizar compra/pago → "Orden Creada"

### Procesamiento de Orden
- Vendedor (para órdenes de vendedor) o Administrador (para órdenes del sistema como Amazon) → "Procesando Orden"

### Envío y Entrega
- **Envío Express (Sistema/Admin):** Orden va a repartidores → "Aceptar Orden" → "Orden en Tránsito" → "Orden en Reparto" → "Orden Entregada" (con foto)
- **Envío Express (Vendedor):** Vendedor elige usar repartidores de la app → mismo flujo que sistema
- **Envío Barco:** Solo administrador maneja estados
- **Envío Vendedor:** Vendedor maneja todos los estados con misma botonera

## 2. CONFIGURACIÓN DE ENTREGA POR VENDEDOR

### Configuración por Producto
- Vendedor marca qué productos puede entregar él mismo. Si no marca producto como "entregable por vendedor", cliente NO puede elegir ese método.

### Control Automático
- Sistema detecta automáticamente qué métodos de envío están disponibles según configuración del vendedor.

## 3. SISTEMA DE ENVÍOS

### Tipos de Envío Disponibles
- **Envío Express (Sistema/Admin):** Para productos del sistema como Amazon, gestionado por administrador
- **Envío Express (Vendedor):** Vendedor puede elegir usar repartidores de la app para sus productos
- **Envío Vendedor:** Vendedor entrega personalmente sus productos
- **Envío Barco:** Solo administrador maneja estados

### Configuración de Entrega por Producto
- Vendedor marca qué productos puede entregar él mismo. Si no marca producto como "entregable por vendedor", cliente NO puede elegir ese método de envío.

### Control Automático de Métodos
- Sistema detecta automáticamente qué métodos de envío están disponibles según configuración del vendedor y filtra opciones para el cliente.

## 4. DETECCIÓN DE DIFERENCIAS DE ENTREGA

### Detección Automática de Diferencias
- Sistema detecta automáticamente diferentes vendedores (Amazon USA vs Vendedor Cuba), métodos de envío y tiempos de entrega cuando usuario agrega productos al carrito.

### Notificación al Usuario
- Sistema muestra alerta: "Sus productos tienen diferentes tiempos de entrega" con opciones: CONTINUAR (pedidos separados), QUITAR PRODUCTOS, o REVISAR detalles.

### Separación Automática de Órdenes
- Si usuario continúa: sistema crea órdenes separadas automáticamente con seguimiento individual de cada pedido y notificaciones separadas por cada entrega.

### Ejemplos de Diferencias Detectadas
- Producto A (Amazon): 15-30 días vs Producto B (Vendedor): 1-2 días vs Producto C (Sistema): 3-5 días → Sistema detecta y separa automáticamente.

## 5. GESTIÓN DE VUELOS

### Integración con Duffel API
- Sistema integrado completamente con Duffel API para búsqueda, reserva y gestión de vuelos en tiempo real.

### Edición de Boletos
- Solo si Duffel API permite: editar fechas de ida/regreso, cancelar, cambiar asiento. Depende de si boleto es reembolsable/cambiable.

### Edición de Boletos YA COMPRADOS Y PAGADOS
- Administrador puede editar fechas de ida y regreso, cambiar asientos y cancelar boletos YA COMPRADOS Y PAGADOS desde el panel web.

### Restricciones de Duffel API
- Las opciones de edición/cancelación dependen de las políticas de Duffel API al momento de la compra. Si un pasaje no es reembolsable, no se puede cancelar.

### Control Automático de Opciones
- El sistema automáticamente desactiva opciones (editar, cancelar, reembolsar) según las políticas del boleto obtenido de Duffel API.

### Políticas de Boleto
- Ejemplo: Si un pasaje no permite cambios, no se podrá cambiar. Si no es reembolsable, no se podrá reembolsar. El sistema respeta estas políticas automáticamente.

### Verificación de Políticas
- Sistema verifica automáticamente políticas de reembolso y cambio de Duffel API antes de permitir modificaciones a boletos adquiridos.

### Gestión de Reservas
- Administrador puede gestionar todas las reservas de vuelos desde el panel, incluyendo verificación de estado y comunicación con usuarios.

## 6. RENTA DE AUTOS

### Sistema Completamente Manual
- Flujo manual: usuario solicita verificación → sistema notifica administrador → administrador verifica en rentcarcuba.com → actualiza sistema → comunica resultado al usuario.

### Verificación en rentcarcuba.com
- Administrador debe verificar manualmente disponibilidad y precios en rentcarcuba.com para cada solicitud de alquiler de auto.

### Comisión por Alquiler
- $50 comisión por alquiler exitoso. Usuario NO debe conocer sitio de referencia (rentcarcuba.com).

### Notificación de Resultados
- Sistema notifica automáticamente al usuario el resultado de la verificación con detalles de disponibilidad y precios.

## 7. RECARGAS TELEFÓNICAS

### Integración con DingConnect API
- Sistema integrado con DingConnect API para procesamiento automático de recargas telefónicas en tiempo real.

### Manejo de Errores por Saldo Insuficiente
- Si error por saldo insuficiente en DingConnect: alerta completa en panel admin, pero usuario solo ve "recarga pendiente en trámite".

### Alertas Automáticas al Administrador
- Sistema genera alertas automáticas en panel de administración cuando hay errores de DingConnect API o saldo insuficiente.

### Gestión de Recargas Pendientes
- Administrador puede gestionar recargas pendientes desde el panel, incluyendo reembolsos o reprocesamiento cuando sea necesario.

## 8. BILLETERA DIGITAL

### Transferencias
- Usuarios/vendedores/repartidores pueden transferirse saldo entre sí y pagar servicios dentro de la app.

## 9. MÉTODOS DE PAGO

### Opciones para Vendedores/Repartidores
- CASH y tarjeta de crédito/débito. Administrador puede activar/desactivar CASH como método de cobro.

## 10. CHAT DE SOPORTE Y COMUNICACIÓN

### WebSockets para Comunicación en Tiempo Real
- Sistema utiliza WebSockets para comunicación instantánea entre usuarios, vendedores, repartidores y administradores sin necesidad de refrescar página.

### Atención al Cliente
- Usuarios, vendedores y repartidores pueden escribir para soporte y dudas desde sus respectivas interfaces con respuesta inmediata.

### Notificaciones Push
- Sistema envía notificaciones push automáticas cuando hay nuevos mensajes, cambios de estado de pedidos o alertas importantes.

### 10.1. COMUNICACIÓN ENTRE USUARIOS

#### Chat Directo por Pedido
- Usuarios pueden enviar mensajes directamente al vendedor, repartidor o administrador según el type de pedido creado.

#### Alertas Automáticas por Demoras
- Si pedido se demora más del tiempo estimado: sistema envía alerta automática al administrador + mensaje de preocupación del cliente.

#### Comunicación Directa con Repartidor
- Cliente puede contactar directamente al repartidor durante el proceso de entrega para consultas sobre ubicación, estado del pedido y tiempo de llegada.

#### Chat en Tiempo Real
- Sistema de chat en tiempo real entre cliente y repartidor durante todo el proceso de entrega, con notificaciones automáticas.

#### Sistema de Sanciones para Vendedores
- Si vendedor no procesa pedido a tiempo: sistema transmite mensaje de preocupación al vendedor obligándolo a procesar. A la 4ª vez del mismo problema → VENDEDOR SUSPENDIDO automáticamente.

#### Comunicación con Repartidor
- Cliente puede contactar directamente al repartidor durante el proceso de entrega para consultas sobre ubicación o estado.

### 10.2. SISTEMA DE CALIFICACIONES

#### Calificación Post-Entrega
- Al cambiar a "Orden Entregada" y ver foto: sistema muestra cortina modal automáticamente para calificar repartidor y vendedor con estrellas (1-5) y comentarios detallados.

#### Posicionamiento Automático por Calificaciones
- Sistema de ranking automático por calificaciones. Vendedores y repartidores con mejores calificaciones aparecen primero en listas.

#### Historial de Calificaciones
- Todas las calificaciones se guardan en historial. Usuarios pueden ver calificaciones de vendedores y repartidores antes de hacer pedidos.

#### Promedio de Calificaciones
- Sistema calcula automáticamente promedio de calificaciones para cada vendedor y repartidor.

#### Comentarios Detallados
- Usuarios pueden escribir comentarios detallados además de las estrellas. Comentarios se muestran en perfil del vendedor/repartidor.

#### Calificaciones por Categoría
- Sistema permite calificar diferentes aspectos: puntualidad, calidad del producto, atención al cliente, etc.

## 11. GESTIÓN DE MÉTODOS DE PAGO

### Métodos de Pago Guardados
- Los métodos de pago se guardan de forma segura. Solo se muestran los últimos 4 dígitos para referencia del usuario.

### Uso de Métodos de Pago
- Los métodos de pago guardados solo se pueden usar dentro de la app cuando el cliente autoriza una transacción específica.

### Seguridad de Datos
- Los datos de pago están encriptados y no se pueden copiar ni ver completos. Solo la empresa tiene acceso para procesar transacciones autorizadas.

### Fotos de Transacciones Zelle
- Administrador puede ver y verificar todas las fotos de transacciones Zelle enviadas por usuarios para confirmar pagos.

### Estados de Pago
- Control completo de estados de pago: Pendiente, Pagado, Cancelado. Administrador puede cambiar estados según verificación.

## 12. SEGURIDAD DE MÉTODOS DE PAGO

### Encriptación de Datos
- Todos los datos de métodos de pago están encriptados y almacenados de forma segura en la base de datos.

### Visualización Limitada
- Solo se muestran los últimos 4 dígitos de tarjetas de crédito/débito para identificación del usuario.

### Autorización Requerida
- Los métodos de pago guardados solo se pueden usar cuando el cliente autoriza explícitamente una transacción específica.

### Acceso Restringido
- Solo el sistema de la empresa puede acceder a los datos completos para procesar transacciones autorizadas.

### No Copia de Datos
- Los datos de pago no se pueden copiar, exportar ni ver completos desde la interfaz de usuario.

### Auditoría de Acceso
- Se registra cada acceso a datos de pago para auditoría y seguridad del sistema.

## 13. INFORMACIÓN DE CONTACTO DE LA EMPRESA

### Configuración de Contacto
- Administrador puede configurar desde el panel web: teléfono de contacto, email, WhatsApp, dirección de la empresa.

### Visualización en App
- La información de contacto se muestra automáticamente en todas las pantallas de la app donde sea necesaria.

### Términos y Políticas
- Administrador puede editar términos y condiciones, políticas de privacidad desde el panel web.

### Actualización Automática
- Los cambios en información de contacto se reflejan inmediatamente en la app sin necesidad de actualización.

### Múltiples Canales
- Soporte para múltiples canales de contacto: teléfono, email, WhatsApp, dirección física, redes sociales.

## 14. SISTEMA DE RENTA DE AUTOS

### Gestión Completa de Vehículos
- Administrador puede agregar vehículos con: foto de portada, precio por día, precio tanque lleno, políticas, términos y condiciones, disponibilidad.

### Restricciones de Tiempo
- Anticipación mínima: 4 días (no se puede rentar para recoger mañana). Tiempo máximo de alquiler: 1 mes. Sistema valida automáticamente estas restricciones.

### Flujo de Alquiler
- Usuario elige vehículo y fechas → Sistema crea pedido pendiente → Admin verifica disponibilidad → Admin acepta → Usuario paga → Se crea reserva.

### Sistema de Pago con Contador
- Usuario debe pagar rápidamente. Contador de 30 minutos en pedidos pendientes. Si llega a 0 sin pago, se cancela automáticamente y otro usuario puede rentar ese auto.

### Métodos de Pago de la App
- Usuarios pueden pagar con: tarjetas de crédito/débito, Zelle, saldo de billetera digital. Todos los métodos están integrados en la app.

### Formulario Obligatorio de Pago
- Usuario debe completar: nombre completo, correo electrónico, número de licencia, número de pasaporte. Correo recibe recibo de reserva.

### Política de Responsabilidad
- Si cliente se equivoca en datos, fechas, lugar o hora, no nos hacemos responsables. Cliente debe resolver en Cuba por sus medios.

### Comisión y Precios
- Precios de primera mano de rentcarcuba.com. Nuestra ganancia: $50 por reserva. Incluye: tanque lleno, seguro, cambio de lugar, chofer adicional.

### Competencia por Vehículos
- Si un usuario demora en pagar, otro usuario puede rentar el mismo auto si hace el pedido y paga primero. Sistema prioriza pagos completados.

### Contador de Tiempo en App Usuario
- En la app del usuario, al lado del pedido pendiente aparece un contador de 30 minutos. Si llega a 0 sin pago, el pedido se cancela automáticamente.

### Notificaciones Automáticas
- Sistema envía notificaciones y correos automáticamente: confirmación de disponibilidad, recordatorio de pago, confirmación de reserva, alertas de tiempo límite.

## 15. VISUALIZACIÓN DE REPARTIDORES

### Foto y Nombre del Repartidor
- En el estado de la orden, el usuario puede ver la foto de perfil del repartidor a cargo de su pedido, además del nombre completo.

### Información del Repartidor
- Usuario ve: foto de perfil, nombre completo, estado actual del repartidor (en tránsito, en reparto, etc.) en tiempo real.

### Seguimiento en Tiempo Real
- La información del repartidor se actualiza automáticamente según el estado de la orden y la ubicación del repartidor.

## 16. SISTEMA DE NOTIFICACIONES

### Notificaciones para Usuarios
- Todas las notificaciones enviadas a los usuarios entran por la campanita de notificaciones. El usuario debe abrir la campanita para ver las notificaciones.

### Notificaciones para Repartidores/Vendedores
- Todas las notificaciones enviadas a repartidores y vendedores aparecen como una ventana emergente en la pantalla cuando abren la app.

### Tipos de Notificaciones
- Notificaciones incluyen: nuevos pedidos, cambios de estado, recordatorios de pago, confirmaciones, alertas de tiempo límite, mensajes de soporte.

### Prioridad de Notificaciones
- Notificaciones urgentes (pagos pendientes, tiempo límite) aparecen inmediatamente. Notificaciones normales se acumulan en la campanita.

### Configuración de Notificaciones
- Usuarios pueden configurar qué notificaciones recibir. Repartidores/vendedores reciben todas las notificaciones relacionadas con su trabajo.

### Notificaciones Push
- Sistema envía notificaciones push al dispositivo. Usuarios: campanita. Repartidores/Vendedores: ventana emergente al abrir app.

### Ventanas Emergentes
- Repartidores y vendedores ven notificaciones como ventanas emergentes que aparecen automáticamente al abrir la aplicación.

### Historial de Notificaciones
- Todas las notificaciones se guardan en historial. Usuarios pueden ver historial en campanita. Repartidores/vendedores en sección de notificaciones.

### Marcado de Leídas
- Notificaciones se marcan como leídas automáticamente al abrirlas. Contador de no leídas se actualiza en tiempo real.

### Notificaciones con Sonido para Repartidores/Vendedores
- Las notificaciones para repartidores y vendedores (pedidos pendientes, pedidos atrasados, notificaciones del sistema/admin) deben sonar. El sistema pedirá acceso a los tonos del teléfono y notificaciones de sonidos aunque el teléfono esté en modo silencio.

### Acceso a Tonos del Teléfono
- La app solicita permisos para acceder a los tonos del teléfono y reproducir notificaciones de sonido incluso cuando el dispositivo está en modo silencio o vibración.

### Tipos de Notificaciones con Sonido
- Pedidos pendientes, pedidos atrasados, alertas del sistema, mensajes del administrador, recordatorios de entrega, y todas las notificaciones críticas para el trabajo.

### Prioridad de Sonido
- Las notificaciones de trabajo tienen prioridad alta y pueden sobrescribir la configuración de silencio del teléfono para asegurar que repartidores y vendedores no pierdan pedidos importantes.

### Configuración de Permisos
- Al instalar la app, repartidores y vendedores deben otorgar permisos para: notificaciones push, acceso a tonos del sistema, reproducción de audio en segundo plano, y sobrescribir modo silencio.

### Sonidos Personalizados
- Diferentes tipos de notificaciones tienen sonidos distintos: pedido nuevo (tono alto), pedido atrasado (tono urgente), mensaje admin (tono medio), recordatorio (tono suave).

### Configuración de Usuario
- Los usuarios pueden configurar el volumen de las notificaciones, pero no pueden desactivar completamente el sonido para notificaciones críticas de trabajo.

---

**ESTAS SON LAS REGLAS COMPLETAS DEL SISTEMA CUBALINK23 QUE DEBEN IMPLEMENTARSE EN LA APP Y PANEL ADMIN**
