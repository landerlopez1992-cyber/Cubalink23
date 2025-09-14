# 📞 Sistema de Chat de Soporte

## 📋 Descripción General

El sistema de Chat de Soporte permite a los usuarios crear tickets de soporte y comunicarse con los administradores en tiempo real. Los administradores pueden gestionar tickets, responder mensajes y actualizar estados.

## 🏗️ Arquitectura del Sistema

### Base de Datos

#### Tabla: `support_tickets`
```sql
CREATE TABLE support_tickets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticket_number TEXT UNIQUE NOT NULL,  -- TKT-XXXXXXXX
    user_id INTEGER NOT NULL,
    subject TEXT NOT NULL,
    description TEXT NOT NULL,
    priority TEXT DEFAULT 'medium',  -- low, medium, high, urgent
    status TEXT DEFAULT 'open',  -- open, in_progress, resolved, closed
    category TEXT DEFAULT 'general',  -- general, technical, billing, flight, order
    assigned_to INTEGER,  -- admin user id
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id)
)
```

#### Tabla: `support_messages`
```sql
CREATE TABLE support_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticket_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,
    sender_type TEXT NOT NULL,  -- user, admin
    message TEXT NOT NULL,
    message_type TEXT DEFAULT 'text',  -- text, image, file
    file_url TEXT,
    is_read BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES support_tickets (id)
)
```

## 🔧 Funcionalidades Implementadas

### Para Administradores

#### 1. Panel de Soporte
- **Ruta**: `/admin/support`
- **Descripción**: Panel principal para gestionar tickets de soporte
- **Acceso**: Requiere autenticación de administrador

#### 2. Listar Tickets
- **Ruta**: `GET /admin/api/support/tickets`
- **Parámetros**: `status` (opcional)
- **Respuesta**: Lista de tickets con información completa

#### 3. Ver Detalles de Ticket
- **Ruta**: `GET /admin/api/support/tickets/<ticket_id>`
- **Respuesta**: Ticket completo con todos los mensajes

#### 4. Actualizar Estado
- **Ruta**: `PUT /admin/api/support/tickets/<ticket_id>/status`
- **Datos**: `{"status": "in_progress", "assigned_to": 1}`
- **Estados**: `open`, `in_progress`, `resolved`, `closed`

#### 5. Enviar Mensaje
- **Ruta**: `POST /admin/api/support/tickets/<ticket_id>/messages`
- **Datos**: `{"message": "Respuesta del admin", "message_type": "text"}`

#### 6. Estadísticas
- **Ruta**: `GET /admin/api/support/statistics`
- **Respuesta**: Estadísticas completas del sistema

### Para Usuarios (Flutter App)

#### 1. Crear Ticket
- **Ruta**: `POST /admin/api/support/create-ticket`
- **Datos**:
```json
{
    "user_id": 1,
    "subject": "Problema con reserva",
    "description": "Descripción del problema",
    "priority": "high",
    "category": "flight"
}
```

#### 2. Ver Mis Tickets
- **Ruta**: `GET /admin/api/support/user/<user_id>/tickets`
- **Respuesta**: Lista de tickets del usuario

#### 3. Enviar Mensaje
- **Ruta**: `POST /admin/api/support/tickets/<ticket_id>/user-message`
- **Datos**:
```json
{
    "user_id": 1,
    "message": "Mensaje del usuario",
    "message_type": "text"
}
```

## 📊 Estados y Prioridades

### Estados de Ticket
- **`open`**: Ticket recién creado
- **`in_progress`**: En proceso de resolución
- **`resolved`**: Problema resuelto
- **`closed`**: Ticket cerrado

### Prioridades
- **`low`**: Baja prioridad
- **`medium`**: Prioridad media (por defecto)
- **`high`**: Alta prioridad
- **`urgent`**: Urgente

### Categorías
- **`general`**: General (por defecto)
- **`technical`**: Problemas técnicos
- **`billing`**: Problemas de facturación
- **`flight`**: Problemas con vuelos
- **`order`**: Problemas con pedidos

## 🔄 Flujo de Trabajo

### 1. Creación de Ticket
1. Usuario crea ticket desde la app Flutter
2. Sistema genera número único (TKT-XXXXXXXX)
3. Ticket se crea con estado `open`
4. Administrador recibe notificación

### 2. Gestión de Ticket
1. Administrador ve ticket en panel
2. Puede cambiar estado a `in_progress`
3. Responde mensajes del usuario
4. Usuario puede enviar más mensajes

### 3. Resolución
1. Administrador marca como `resolved`
2. Se registra fecha de resolución
3. Ticket puede cerrarse automáticamente

## 📈 Estadísticas Disponibles

- **Total de tickets**: Número total de tickets creados
- **Tickets por estado**: Distribución por estado actual
- **Tickets por prioridad**: Distribución por nivel de prioridad
- **Mensajes no leídos**: Mensajes pendientes de lectura

## 🛠️ Integración con Flutter

### Ejemplo de Creación de Ticket
```dart
Future<void> createSupportTicket() async {
  final response = await http.post(
    Uri.parse('$baseUrl/admin/api/support/create-ticket'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': currentUser.id,
      'subject': 'Problema con pago',
      'description': 'No puedo completar mi reserva',
      'priority': 'high',
      'category': 'billing'
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      print('Ticket creado: ${data['data']['ticket_number']}');
    }
  }
}
```

### Ejemplo de Envío de Mensaje
```dart
Future<void> sendMessage(int ticketId, String message) async {
  final response = await http.post(
    Uri.parse('$baseUrl/admin/api/support/tickets/$ticketId/user-message'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': currentUser.id,
      'message': message,
      'message_type': 'text'
    }),
  );
  
  if (response.statusCode == 200) {
    print('Mensaje enviado exitosamente');
  }
}
```

## 🔒 Seguridad

- **Autenticación**: Todas las rutas de admin requieren login
- **Validación**: Datos requeridos validados en cada endpoint
- **Autorización**: Usuarios solo pueden ver sus propios tickets
- **Sanitización**: Mensajes sanitizados antes de guardar

## 🚀 Próximas Mejoras

1. **Notificaciones Push**: Enviar notificaciones en tiempo real
2. **Archivos Adjuntos**: Soporte para imágenes y documentos
3. **Respuestas Automáticas**: Bot para respuestas básicas
4. **Escalación**: Transferir tickets entre administradores
5. **Reportes**: Reportes detallados de rendimiento
6. **Integración Email**: Notificaciones por correo electrónico

## 📝 Notas de Implementación

- Sistema híbrido: Supabase + SQLite local
- Fallback automático a base de datos local si Supabase falla
- Números de ticket únicos generados automáticamente
- Timestamps automáticos para auditoría
- Mensajes marcados como leídos automáticamente

## 🧪 Pruebas

Ejecutar el script de prueba:
```bash
python3 test_support_chat.py
```

Este script prueba todas las funcionalidades del sistema de chat de soporte.

