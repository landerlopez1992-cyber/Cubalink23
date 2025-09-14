# ⚙️ Sistema de Reglas y Configuraciones

## 📋 Descripción General

El sistema de Reglas y Configuraciones permite a los administradores gestionar todos los parámetros del sistema, reglas de negocio y límites operativos. Las configuraciones están disponibles tanto en el **panel de administración web** como en la **app Flutter**.

## 🏗️ Arquitectura del Sistema

### Base de Datos

#### Tabla: `system_configs`
```sql
CREATE TABLE system_configs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    config_key TEXT UNIQUE NOT NULL,
    config_value TEXT NOT NULL,
    config_type TEXT DEFAULT 'string',  -- string, number, boolean, json
    category TEXT DEFAULT 'general',  -- general, payment, flight, app, security
    description TEXT,
    is_public BOOLEAN DEFAULT 0,  -- Si es accesible desde app Flutter
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

#### Tabla: `business_rules`
```sql
CREATE TABLE business_rules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rule_name TEXT UNIQUE NOT NULL,
    rule_type TEXT NOT NULL,  -- validation, calculation, workflow
    rule_condition TEXT NOT NULL,  -- Condición en formato JSON
    rule_action TEXT NOT NULL,  -- Acción a ejecutar
    is_active BOOLEAN DEFAULT 1,
    priority INTEGER DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

#### Tabla: `system_limits`
```sql
CREATE TABLE system_limits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    limit_name TEXT UNIQUE NOT NULL,
    limit_type TEXT NOT NULL,  -- user, transaction, system
    limit_value REAL NOT NULL,
    limit_unit TEXT DEFAULT 'count',  -- count, amount, percentage
    applies_to TEXT DEFAULT 'all',  -- all, premium, basic
    description TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

## 🔧 Funcionalidades Implementadas

### Para Administradores

#### 1. Panel de Sistema
- **Ruta**: `/admin/system`
- **Descripción**: Panel principal para gestionar configuraciones del sistema
- **Acceso**: Requiere autenticación de administrador

#### 2. Gestión de Configuraciones
- **Ruta**: `GET /admin/api/system/configs`
- **Parámetros**: `category`, `public_only`
- **Respuesta**: Lista de configuraciones filtradas

#### 3. Actualizar Configuración
- **Ruta**: `PUT /admin/api/system/configs/<config_key>`
- **Datos**: `{"config_value": "nuevo_valor", "config_type": "string", "category": "general", "is_public": true}`

#### 4. Reglas de Negocio
- **Ruta**: `GET /admin/api/system/business-rules`
- **Parámetros**: `rule_type`, `active_only`
- **Respuesta**: Lista de reglas de negocio

#### 5. Agregar Regla
- **Ruta**: `POST /admin/api/system/business-rules`
- **Datos**: `{"rule_name": "nombre", "rule_type": "validation", "rule_condition": "{}", "rule_action": "reject"}`

#### 6. Límites del Sistema
- **Ruta**: `GET /admin/api/system/limits`
- **Parámetros**: `limit_type`, `active_only`
- **Respuesta**: Lista de límites del sistema

#### 7. Agregar Límite
- **Ruta**: `POST /admin/api/system/limits`
- **Datos**: `{"limit_name": "nombre", "limit_type": "user", "limit_value": 10, "limit_unit": "count"}`

#### 8. Inicializar Sistema
- **Ruta**: `POST /admin/api/system/initialize`
- **Descripción**: Cargar configuraciones por defecto

### Para Flutter App

#### 1. Configuraciones Públicas
- **Ruta**: `GET /admin/api/system/app-configs`
- **Respuesta**: Solo configuraciones marcadas como públicas

#### 2. Verificar Mantenimiento
- **Ruta**: `GET /admin/api/system/check-maintenance`
- **Respuesta**: Estado de mantenimiento y mensaje

## 📊 Categorías de Configuración

### General
- `app_name`: Nombre de la aplicación
- `app_version`: Versión actual
- `maintenance_mode`: Modo mantenimiento
- `debug_mode`: Modo debug

### Pagos
- `payment_enabled`: Habilitar pagos
- `payment_methods`: Métodos disponibles
- `payment_currency`: Moneda por defecto
- `payment_commission`: Comisión (%)
- `min_payment_amount`: Monto mínimo
- `max_payment_amount`: Monto máximo

### Vuelos
- `flight_search_enabled`: Habilitar búsqueda
- `flight_booking_enabled`: Habilitar reservas
- `flight_commission`: Comisión por vuelo (%)
- `max_flight_search_results`: Máximo resultados
- `flight_booking_timeout`: Timeout de reserva

### Billetera
- `wallet_enabled`: Habilitar billetera
- `wallet_currency`: Moneda de billetera
- `wallet_min_balance`: Saldo mínimo
- `wallet_max_balance`: Saldo máximo
- `wallet_transfer_enabled`: Habilitar transferencias
- `wallet_withdrawal_enabled`: Habilitar retiros

### Seguridad
- `max_login_attempts`: Máximo intentos de login
- `session_timeout`: Timeout de sesión
- `password_min_length`: Longitud mínima de contraseña
- `two_factor_enabled`: Autenticación de dos factores

### App
- `app_maintenance_message`: Mensaje de mantenimiento
- `app_contact_email`: Email de contacto
- `app_contact_phone`: Teléfono de contacto
- `app_support_hours`: Horarios de soporte
- `app_notifications_enabled`: Notificaciones push
- `app_auto_logout`: Auto logout

## 📋 Tipos de Reglas de Negocio

### Validación
- Validar montos mínimos/máximos
- Verificar saldos de billetera
- Validar límites de transacciones

### Cálculo
- Calcular comisiones
- Calcular descuentos
- Calcular totales

### Workflow
- Flujos de aprobación
- Procesos automáticos
- Escalación de tickets

## 🚫 Tipos de Límites

### Usuario
- Sesiones concurrentes
- Intentos de login
- Tiempo de sesión

### Transacción
- Transacciones por día
- Monto máximo por transacción
- Frecuencia de transacciones

### Sistema
- Usuarios concurrentes
- Límites de API
- Recursos del servidor

## 🔄 Flujo de Trabajo

### 1. Inicialización
1. Administrador accede al panel
2. Ejecuta inicialización del sistema
3. Se cargan configuraciones por defecto
4. Se crean reglas básicas de validación

### 2. Configuración
1. Administrador revisa configuraciones por categoría
2. Modifica valores según necesidades
3. Marca configuraciones como públicas si es necesario
4. Guarda cambios

### 3. Reglas de Negocio
1. Administrador define reglas específicas
2. Establece condiciones en formato JSON
3. Define acciones a ejecutar
4. Asigna prioridades

### 4. Límites
1. Administrador establece límites operativos
2. Define valores y unidades
3. Especifica a quién aplica
4. Activa/desactiva según necesidad

## 📈 Integración con Flutter

### Ejemplo de Obtención de Configuraciones
```dart
Future<Map<String, dynamic>> getAppConfigs() async {
  final response = await http.get(
    Uri.parse('$baseUrl/admin/api/system/app-configs'),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      final configs = data['configs'] as List;
      return Map.fromEntries(
        configs.map((config) => MapEntry(
          config['config_key'], 
          config['config_value']
        ))
      );
    }
  }
  return {};
}
```

### Ejemplo de Verificación de Mantenimiento
```dart
Future<bool> checkMaintenanceMode() async {
  final response = await http.get(
    Uri.parse('$baseUrl/admin/api/system/check-maintenance'),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      return data['maintenance_mode'] ?? false;
    }
  }
  return false;
}
```

### Ejemplo de Uso de Configuraciones
```dart
class AppConfig {
  static Map<String, dynamic> _configs = {};
  
  static Future<void> loadConfigs() async {
    _configs = await getAppConfigs();
  }
  
  static String get appName => _configs['app_name'] ?? 'Cubalink23';
  static bool get maintenanceMode => _configs['maintenance_mode'] == 'true';
  static String get contactEmail => _configs['app_contact_email'] ?? '';
  static double get minPaymentAmount => double.tryParse(_configs['min_payment_amount'] ?? '10.0') ?? 10.0;
  static bool get walletEnabled => _configs['wallet_enabled'] == 'true';
}
```

## 🔒 Seguridad

- **Autenticación**: Todas las rutas de admin requieren login
- **Autorización**: Solo administradores pueden modificar configuraciones
- **Validación**: Datos validados antes de guardar
- **Auditoría**: Timestamps automáticos para cambios
- **Públicas/Privadas**: Control de qué configuraciones son accesibles desde la app

## 🚀 Próximas Mejoras

1. **Configuraciones por Entorno**: Desarrollo, staging, producción
2. **Historial de Cambios**: Track de modificaciones
3. **Configuraciones por Usuario**: Personalización individual
4. **Configuraciones por Región**: Ajustes geográficos
5. **Backup Automático**: Respaldo de configuraciones
6. **Notificaciones**: Alertas de cambios críticos
7. **API Rate Limiting**: Límites de uso de API
8. **Configuraciones Dinámicas**: Cambios en tiempo real

## 📝 Notas de Implementación

- Sistema híbrido: Supabase + SQLite local
- Fallback automático a base de datos local si Supabase falla
- Configuraciones por defecto incluidas en la inicialización
- Tipos de datos validados automáticamente
- Configuraciones públicas accesibles sin autenticación
- Reglas de negocio con prioridades y estados activos/inactivos
- Límites flexibles con diferentes tipos y unidades

## 🧪 Pruebas

Ejecutar el script de prueba:
```bash
python3 test_system_configs.py
```

Este script prueba todas las funcionalidades del sistema de configuraciones.

## 📊 Configuraciones por Defecto

El sistema incluye más de **30 configuraciones predefinidas** organizadas en 6 categorías:

- **General**: 4 configuraciones
- **Pagos**: 6 configuraciones  
- **Vuelos**: 5 configuraciones
- **Billetera**: 6 configuraciones
- **Seguridad**: 4 configuraciones
- **App**: 6 configuraciones

Además incluye **3 reglas de negocio** y **3 límites del sistema** por defecto.

