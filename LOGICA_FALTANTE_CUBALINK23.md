# 🧠 LÓGICA FALTANTE POR IMPLEMENTAR - CUBALINK23

## 🚨 **ANÁLISIS COMPLETO: LÓGICAS CRÍTICAS QUE FALTAN**

### 🎯 **FASE 1: SISTEMA DE ASIGNACIÓN AUTOMÁTICA DE REPARTIDORES**

#### **1.1 Algoritmo de Asignación Inteligente**
```sql
-- Tabla para configurar algoritmo de asignación
CREATE TABLE delivery_assignment_algorithm (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Factores de asignación con pesos
    distance_weight DECIMAL(3,2) DEFAULT 0.4,  -- 40% peso por distancia
    rating_weight DECIMAL(3,2) DEFAULT 0.3,    -- 30% peso por calificación
    workload_weight DECIMAL(3,2) DEFAULT 0.2,  -- 20% peso por carga actual
    availability_weight DECIMAL(3,2) DEFAULT 0.1, -- 10% peso por disponibilidad
    
    -- Parámetros del algoritmo
    max_distance_km DECIMAL(8,2) DEFAULT 15.0,
    max_current_orders INTEGER DEFAULT 5,
    min_rating_required DECIMAL(3,2) DEFAULT 3.0,
    
    -- Tiempos límite
    auto_assign_timeout_minutes INTEGER DEFAULT 10,
    repartidor_response_timeout_minutes INTEGER DEFAULT 5,
    vendor_preparation_timeout_minutes INTEGER DEFAULT 30,
    
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### **1.2 Sistema de Puntuación de Repartidores**
- **FALTA**: Calcular score automático para cada repartidor basado en:
  - Distancia al punto de recogida
  - Calificación promedio
  - Número de órdenes activas
  - Historial de cancelaciones
  - Tiempo promedio de entrega

### 🎯 **FASE 2: SISTEMA DE TIMEOUTS Y REASIGNACIÓN AUTOMÁTICA**

#### **2.1 Timeouts Automáticos (CRÍTICO - FALTA COMPLETAMENTE)**
```sql
-- Tabla de timeouts del sistema
CREATE TABLE system_timeouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timeout_type TEXT NOT NULL CHECK (timeout_type IN (
        'vendor_accept_order',
        'vendor_prepare_order', 
        'delivery_accept_assignment',
        'delivery_pickup_order',
        'delivery_complete_order',
        'payment_timeout',
        'car_rental_payment'
    )),
    
    timeout_minutes INTEGER NOT NULL,
    warning_minutes INTEGER DEFAULT 5, -- Avisar X minutos antes
    
    -- Acciones automáticas
    auto_action TEXT CHECK (auto_action IN (
        'reassign', 'cancel', 'notify_admin', 'suspend_user'
    )),
    
    -- Configuración por rol
    applies_to_role TEXT CHECK (applies_to_role IN ('vendor', 'delivery', 'customer', 'all')),
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla para trackear timeouts activos
CREATE TABLE active_timeouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    timeout_type TEXT NOT NULL,
    
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    warning_sent BOOLEAN DEFAULT FALSE,
    
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Datos adicionales para contexto
    context_data JSONB DEFAULT '{}'
);
```

#### **2.2 Sistema de Reasignación (FALTA LÓGICA)**
- **FALTA**: Cuando un repartidor cancela o no responde:
  1. Buscar automáticamente el siguiente repartidor más cercano
  2. Excluir repartidores que ya cancelaron esa orden
  3. Notificar al vendedor sobre el cambio
  4. Actualizar tiempos estimados

### 🎯 **FASE 3: SISTEMA DE SANCIONES Y SUSPENSIONES AUTOMÁTICAS**

#### **3.1 Sistema de Sanciones (FALTA COMPLETAMENTE)**
```sql
-- Tabla de tipos de sanciones
CREATE TABLE sanction_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sanction_code TEXT UNIQUE NOT NULL,
    sanction_name TEXT NOT NULL,
    description TEXT,
    
    -- Severidad de la sanción
    severity_level INTEGER DEFAULT 1 CHECK (severity_level >= 1 AND severity_level <= 5),
    
    -- Acciones automáticas
    auto_suspend BOOLEAN DEFAULT FALSE,
    suspension_hours INTEGER DEFAULT 0,
    affects_rating BOOLEAN DEFAULT FALSE,
    rating_penalty DECIMAL(3,2) DEFAULT 0.0,
    
    -- Límites antes de sanción mayor
    max_occurrences INTEGER DEFAULT 3,
    period_days INTEGER DEFAULT 30, -- En qué período contar ocurrencias
    
    applies_to_role TEXT[] DEFAULT ARRAY['vendor', 'delivery'],
    is_active BOOLEAN DEFAULT TRUE
);

-- Tabla de historial de sanciones
CREATE TABLE user_sanctions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sanction_type_id UUID NOT NULL REFERENCES sanction_types(id),
    
    -- Detalles de la sanción
    reason TEXT NOT NULL,
    related_order_id UUID REFERENCES orders(id),
    severity_level INTEGER NOT NULL,
    
    -- Estado de la sanción
    is_active BOOLEAN DEFAULT TRUE,
    starts_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ends_at TIMESTAMP WITH TIME ZONE,
    
    -- Seguimiento automático
    auto_applied BOOLEAN DEFAULT FALSE,
    applied_by UUID REFERENCES users(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar tipos de sanciones comunes
INSERT INTO sanction_types (sanction_code, sanction_name, description, severity_level, max_occurrences, auto_suspend, suspension_hours) VALUES
('VENDOR_LATE_PROCESSING', 'Procesamiento Tardío', 'Vendedor no procesa pedido en tiempo estimado', 2, 4, TRUE, 24),
('VENDOR_NO_RESPONSE', 'No Respuesta', 'Vendedor no acepta ni rechaza pedido', 3, 3, TRUE, 48),
('DELIVERY_CANCEL_FREQUENT', 'Cancelaciones Frecuentes', 'Repartidor cancela demasiadas órdenes', 2, 5, TRUE, 12),
('DELIVERY_NO_PICKUP', 'No Recoge Pedido', 'Repartidor no recoge pedido del vendedor', 3, 3, TRUE, 24),
('DELIVERY_LATE_DELIVERY', 'Entrega Tardía', 'Repartidor entrega fuera de tiempo estimado', 1, 7, FALSE, 0),
('LOW_RATING_PATTERN', 'Patrón de Calificaciones Bajas', 'Calificaciones consistentemente bajas', 4, 10, TRUE, 72);
```

#### **3.2 Sistema de Suspensión Automática (CRÍTICO - FALTA)**
- **FALTA**: Lógica para suspender automáticamente a vendedores/repartidores cuando:
  - 4ª vez que no procesan pedidos a tiempo → SUSPENSIÓN AUTOMÁTICA
  - Demasiadas cancelaciones en período corto
  - Calificaciones muy bajas consistentes
  - No respuesta a órdenes asignadas

### 🎯 **FASE 4: SISTEMA DE COMUNICACIÓN Y CHAT DIRECTO**

#### **4.1 Chat Directo Entre Roles (FALTA IMPLEMENTACIÓN)**
```sql
-- Tabla de conversaciones directas
CREATE TABLE direct_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Participantes
    participant1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    participant2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Contexto de la conversación
    conversation_type TEXT NOT NULL CHECK (conversation_type IN (
        'vendor_delivery', 'customer_vendor', 'customer_delivery', 
        'customer_support', 'vendor_support', 'delivery_support'
    )),
    
    -- Orden relacionada (si aplica)
    related_order_id UUID REFERENCES orders(id),
    
    -- Estado
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'closed', 'archived')),
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de mensajes directos
CREATE TABLE direct_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES direct_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    message_text TEXT NOT NULL,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'location', 'voice')),
    
    -- Metadatos
    is_read BOOLEAN DEFAULT FALSE,
    is_urgent BOOLEAN DEFAULT FALSE,
    
    -- Archivos adjuntos
    attachment_url TEXT,
    attachment_type TEXT,
    
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### **4.2 Sistema de Llamadas Rápidas (FALTA)**
- **FALTA**: Botones de llamada directa entre:
  - Vendedor ↔ Repartidor
  - Cliente ↔ Repartidor  
  - Cliente ↔ Vendedor
  - Todos ↔ Soporte

### 🎯 **FASE 5: SISTEMA DE TRACKING Y UBICACIÓN EN TIEMPO REAL**

#### **5.1 Tracking Avanzado (PARCIALMENTE IMPLEMENTADO)**
```sql
-- Extender tabla de ubicaciones existente
ALTER TABLE delivery_locations 
ADD COLUMN IF NOT EXISTS speed_kmh DECIMAL(6,2);

ALTER TABLE delivery_locations 
ADD COLUMN IF NOT EXISTS battery_level INTEGER;

ALTER TABLE delivery_locations 
ADD COLUMN IF NOT EXISTS network_quality TEXT CHECK (network_quality IN ('excellent', 'good', 'poor', 'offline'));

-- Tabla de zonas de entrega definidas
CREATE TABLE delivery_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_name TEXT NOT NULL,
    zone_type TEXT NOT NULL CHECK (zone_type IN ('vendor', 'customer', 'restricted', 'priority')),
    
    -- Definición geográfica (polígono)
    zone_polygon JSONB NOT NULL, -- Array de coordenadas [lat, lng]
    center_latitude DECIMAL(10,8) NOT NULL,
    center_longitude DECIMAL(11,8) NOT NULL,
    radius_meters INTEGER DEFAULT 1000,
    
    -- Configuración especial
    priority_level INTEGER DEFAULT 1,
    special_instructions TEXT,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de alertas geográficas
CREATE TABLE geo_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_id UUID NOT NULL REFERENCES delivery_profiles(id),
    order_id UUID REFERENCES orders(id),
    
    alert_type TEXT NOT NULL CHECK (alert_type IN (
        'entered_zone', 'left_zone', 'delayed_route', 'off_route', 
        'speed_limit', 'low_battery', 'emergency'
    )),
    
    -- Ubicación del evento
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    
    alert_data JSONB DEFAULT '{}',
    requires_action BOOLEAN DEFAULT FALSE,
    is_resolved BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 🎯 **FASE 6: SISTEMA DE DETECCIÓN DE DIFERENCIAS AUTOMÁTICO**

#### **6.1 Motor de Detección (FALTA LÓGICA COMPLETA)**
```sql
-- Tabla de reglas de detección
CREATE TABLE order_difference_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name TEXT NOT NULL,
    rule_type TEXT NOT NULL CHECK (rule_type IN (
        'vendor_difference', 'shipping_method_difference', 
        'delivery_time_difference', 'weight_difference'
    )),
    
    -- Condiciones para activar la regla
    condition_field TEXT NOT NULL,
    condition_operator TEXT NOT NULL,
    condition_value TEXT NOT NULL,
    
    -- Acción a tomar
    action_type TEXT NOT NULL CHECK (action_type IN (
        'warn_user', 'auto_separate', 'require_confirmation', 'block_checkout'
    )),
    
    -- Configuración de la alerta
    alert_title TEXT,
    alert_message TEXT,
    alert_severity TEXT DEFAULT 'warning' CHECK (alert_severity IN ('info', 'warning', 'error')),
    
    is_active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de diferencias detectadas
CREATE TABLE detected_order_differences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_session_id TEXT NOT NULL, -- ID temporal del carrito
    user_id UUID REFERENCES users(id),
    
    difference_type TEXT NOT NULL,
    difference_description TEXT NOT NULL,
    
    -- Items afectados
    affected_items JSONB NOT NULL DEFAULT '[]',
    
    -- Sugerencias del sistema
    suggested_action TEXT NOT NULL CHECK (suggested_action IN (
        'separate_orders', 'remove_items', 'change_shipping', 'continue_anyway'
    )),
    
    -- Respuesta del usuario
    user_action TEXT CHECK (user_action IN (
        'separated', 'removed_items', 'changed_shipping', 'continued', 'cancelled'
    )),
    user_responded_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### **6.2 Separación Automática de Órdenes (FALTA ALGORITMO)**
- **FALTA**: Algoritmo que automáticamente:
  1. Detecta diferencias entre productos en carrito
  2. Agrupa productos por vendedor/método de envío
  3. Calcula tiempos de entrega separados
  4. Genera órdenes separadas automáticamente
  5. Mantiene seguimiento individual

### 🎯 **FASE 7: SISTEMA DE PESO Y DIMENSIONES INTELIGENTE**

#### **7.1 Cálculo Automático Avanzado (MEJORAR EXISTENTE)**
```sql
-- Tabla de configuración volumétrica avanzada
CREATE TABLE volumetric_calculation_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Factores de conversión
    cubic_inch_to_lb_factor DECIMAL(10,6) DEFAULT 139.0, -- DIM weight factor
    volumetric_threshold_lb DECIMAL(8,3) DEFAULT 1.0,
    
    -- Límites por método de envío
    express_max_dimensions JSONB DEFAULT '{"length": 48, "width": 48, "height": 48}', -- pulgadas
    maritime_max_dimensions JSONB DEFAULT '{"length": 120, "width": 80, "height": 80}',
    
    -- Restricciones especiales
    oversize_threshold_inches DECIMAL(8,2) DEFAULT 48.0,
    overweight_threshold_lb DECIMAL(8,3) DEFAULT 70.0,
    
    -- Recargos automáticos
    oversize_surcharge_percentage DECIMAL(5,2) DEFAULT 50.0,
    overweight_surcharge_per_lb DECIMAL(8,2) DEFAULT 2.0,
    
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Función para calcular peso volumétrico automáticamente
CREATE OR REPLACE FUNCTION calculate_volumetric_weight(
    length_inches DECIMAL,
    width_inches DECIMAL, 
    height_inches DECIMAL,
    actual_weight_lb DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    volumetric_weight DECIMAL;
    config_factor DECIMAL;
BEGIN
    -- Obtener factor de configuración
    SELECT cubic_inch_to_lb_factor INTO config_factor 
    FROM volumetric_calculation_config 
    WHERE is_active = TRUE 
    LIMIT 1;
    
    -- Calcular peso volumétrico
    volumetric_weight := (length_inches * width_inches * height_inches) / COALESCE(config_factor, 139.0);
    
    -- Retornar el mayor entre peso real y volumétrico
    RETURN GREATEST(actual_weight_lb, volumetric_weight);
END;
$$ LANGUAGE plpgsql;
```

### 🎯 **FASE 8: SISTEMA DE RENTA DE AUTOS COMPLETO**

#### **8.1 Gestión Completa de Vehículos (FALTA MUCHO)**
```sql
-- Extender sistema de vehículos existente
CREATE TABLE vehicle_availability_calendar (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL, -- Referencia a tabla vehicles existente
    
    date_from DATE NOT NULL,
    date_to DATE NOT NULL,
    
    availability_status TEXT NOT NULL CHECK (availability_status IN (
        'available', 'reserved', 'maintenance', 'blocked'
    )),
    
    -- Precios dinámicos por fecha
    daily_rate_override DECIMAL(10,2),
    special_conditions TEXT,
    
    -- Si está reservado
    reserved_by_user_id UUID REFERENCES users(id),
    reservation_id UUID,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de reservas con contador de 30 minutos
CREATE TABLE car_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL,
    
    -- Fechas de alquiler
    pickup_date DATE NOT NULL,
    return_date DATE NOT NULL,
    total_days INTEGER NOT NULL,
    
    -- Precios calculados
    daily_rate DECIMAL(10,2) NOT NULL,
    total_base_cost DECIMAL(10,2) NOT NULL,
    insurance_cost DECIMAL(10,2) DEFAULT 0.0,
    additional_services_cost DECIMAL(10,2) DEFAULT 0.0,
    total_amount DECIMAL(10,2) NOT NULL,
    
    -- Sistema de contador de 30 minutos
    payment_deadline TIMESTAMP WITH TIME ZONE NOT NULL, -- NOW() + 30 minutes
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'expired', 'cancelled')),
    
    -- Datos del conductor
    driver_name TEXT NOT NULL,
    driver_email TEXT NOT NULL,
    driver_license TEXT NOT NULL,
    driver_passport TEXT NOT NULL,
    
    -- Estado de la reserva
    reservation_status TEXT DEFAULT 'pending_payment' CHECK (reservation_status IN (
        'pending_payment', 'confirmed', 'in_progress', 'completed', 'cancelled'
    )),
    
    -- Verificación manual del admin
    admin_verified BOOLEAN DEFAULT FALSE,
    admin_verification_notes TEXT,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID REFERENCES users(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Función para cancelar reservas expiradas automáticamente
CREATE OR REPLACE FUNCTION cancel_expired_reservations()
RETURNS void AS $$
BEGIN
    UPDATE car_reservations 
    SET 
        payment_status = 'expired',
        reservation_status = 'cancelled',
        updated_at = NOW()
    WHERE 
        payment_status = 'pending' 
        AND payment_deadline < NOW()
        AND reservation_status = 'pending_payment';
        
    -- Liberar disponibilidad
    DELETE FROM vehicle_availability_calendar 
    WHERE reservation_id IN (
        SELECT id FROM car_reservations 
        WHERE payment_status = 'expired'
    );
END;
$$ LANGUAGE plpgsql;
```

#### **8.2 Verificación Manual de rentcarcuba.com (FALTA WORKFLOW)**
- **FALTA**: Workflow completo para que admin verifique en rentcarcuba.com
- **FALTA**: Estados intermedios: "verificando disponibilidad", "disponible", "no disponible"
- **FALTA**: Notificaciones automáticas al usuario con resultados

### 🎯 **FASE 9: SISTEMA DE CALIFICACIONES AVANZADO**

#### **9.1 Calificaciones Multi-Categoría (MEJORAR EXISTENTE)**
```sql
-- Extender sistema de calificaciones existente
ALTER TABLE ratings 
ADD COLUMN IF NOT EXISTS product_quality_rating INTEGER CHECK (product_quality_rating >= 1 AND product_quality_rating <= 5);

ALTER TABLE ratings 
ADD COLUMN IF NOT EXISTS packaging_rating INTEGER CHECK (packaging_rating >= 1 AND packaging_rating <= 5);

ALTER TABLE ratings 
ADD COLUMN IF NOT EXISTS delivery_condition_rating INTEGER CHECK (delivery_condition_rating >= 1 AND delivery_condition_rating <= 5);

-- Tabla de categorías de calificación configurables
CREATE TABLE rating_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_code TEXT UNIQUE NOT NULL,
    category_name TEXT NOT NULL,
    description TEXT,
    
    applies_to_role TEXT NOT NULL CHECK (applies_to_role IN ('vendor', 'delivery')),
    is_required BOOLEAN DEFAULT FALSE,
    weight_percentage DECIMAL(5,2) DEFAULT 20.0, -- Para cálculo de promedio ponderado
    
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de impacto de calificaciones en ranking
CREATE TABLE rating_impact_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    rating_threshold DECIMAL(3,2) NOT NULL, -- ej: 4.5
    comparison_operator TEXT NOT NULL CHECK (comparison_operator IN ('>=', '<=', '=', '>', '<')),
    
    -- Efectos en el ranking
    ranking_boost INTEGER DEFAULT 0, -- Puntos de boost positivo/negativo
    priority_multiplier DECIMAL(5,3) DEFAULT 1.0,
    
    -- Efectos en asignaciones
    affects_auto_assignment BOOLEAN DEFAULT FALSE,
    assignment_penalty_percentage DECIMAL(5,2) DEFAULT 0.0,
    
    applies_to_role TEXT NOT NULL CHECK (applies_to_role IN ('vendor', 'delivery')),
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 🎯 **FASE 10: SISTEMA DE NOTIFICACIONES INTELIGENTE**

#### **10.1 Motor de Notificaciones Avanzado (MEJORAR EXISTENTE)**
```sql
-- Tabla de plantillas de notificaciones
CREATE TABLE notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_code TEXT UNIQUE NOT NULL,
    template_name TEXT NOT NULL,
    
    -- Contenido de la plantilla
    title_template TEXT NOT NULL, -- Puede usar variables {{variable}}
    message_template TEXT NOT NULL,
    
    -- Configuración por rol
    target_roles TEXT[] DEFAULT ARRAY['usuario'],
    
    -- Configuración de entrega
    delivery_methods TEXT[] DEFAULT ARRAY['push'], -- push, email, sms, popup
    priority_level TEXT DEFAULT 'normal' CHECK (priority_level IN ('low', 'normal', 'high', 'urgent')),
    
    -- Condiciones para envío
    conditions JSONB DEFAULT '{}',
    
    -- Configuración de sonido
    sound_enabled BOOLEAN DEFAULT FALSE,
    custom_sound_url TEXT,
    can_override_silent BOOLEAN DEFAULT FALSE,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sistema de colas de notificaciones
CREATE TABLE notification_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    template_id UUID REFERENCES notification_templates(id),
    
    -- Contenido procesado (con variables reemplazadas)
    processed_title TEXT NOT NULL,
    processed_message TEXT NOT NULL,
    
    -- Configuración de envío
    delivery_method TEXT NOT NULL,
    priority_level TEXT NOT NULL,
    
    -- Scheduling
    scheduled_for TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Estado
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed', 'cancelled')),
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    
    -- Metadatos
    context_data JSONB DEFAULT '{}',
    error_message TEXT,
    
    sent_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 🎯 **FASE 11: SISTEMA DE MONITOREO Y ALERTAS AUTOMÁTICAS**

#### **11.1 Monitoreo del Sistema (FALTA COMPLETAMENTE)**
```sql
-- Tabla de métricas del sistema
CREATE TABLE system_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_type TEXT NOT NULL CHECK (metric_type IN (
        'order_processing_time', 'delivery_completion_rate', 'vendor_response_time',
        'delivery_assignment_time', 'customer_satisfaction', 'system_uptime',
        'payment_success_rate', 'cancellation_rate'
    )),
    
    metric_value DECIMAL(15,6) NOT NULL,
    metric_unit TEXT, -- minutes, percentage, count, etc.
    
    -- Contexto
    entity_type TEXT, -- vendor, delivery, order, etc.
    entity_id UUID,
    
    -- Tiempo
    measured_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    period_start TIMESTAMP WITH TIME ZONE,
    period_end TIMESTAMP WITH TIME ZONE,
    
    -- Metadatos
    additional_data JSONB DEFAULT '{}'
);

-- Tabla de alertas automáticas
CREATE TABLE automated_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_type TEXT NOT NULL CHECK (alert_type IN (
        'high_cancellation_rate', 'slow_processing', 'low_satisfaction',
        'system_error', 'payment_issues', 'delivery_delays'
    )),
    
    -- Condiciones para disparar alerta
    metric_threshold DECIMAL(10,6) NOT NULL,
    time_window_minutes INTEGER DEFAULT 60,
    
    -- Destinatarios
    notify_admins BOOLEAN DEFAULT TRUE,
    notify_roles TEXT[] DEFAULT ARRAY[]::TEXT[],
    
    -- Configuración de la alerta
    alert_title TEXT NOT NULL,
    alert_message TEXT NOT NULL,
    severity_level TEXT DEFAULT 'warning' CHECK (severity_level IN ('info', 'warning', 'error', 'critical')),
    
    -- Estado
    is_active BOOLEAN DEFAULT TRUE,
    last_triggered TIMESTAMP WITH TIME ZONE,
    trigger_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🎯 **RESUMEN DE LÓGICAS FALTANTES MÁS CRÍTICAS:**

### 🚨 **URGENTE - IMPLEMENTAR PRIMERO:**
1. **Sistema de Timeouts y Reasignación Automática**
2. **Sistema de Sanciones Automáticas** (4ª vez = suspensión)
3. **Algoritmo de Asignación Inteligente de Repartidores**
4. **Chat Directo entre Vendedor ↔ Repartidor**
5. **Detección Automática de Diferencias en Carrito**

### 🔧 **IMPORTANTE - IMPLEMENTAR SEGUNDO:**
6. **Sistema de Tracking Avanzado con Alertas**
7. **Contador de 30 minutos para Renta de Autos**
8. **Verificación Manual de rentcarcuba.com Workflow**
9. **Calificaciones Multi-Categoría**
10. **Motor de Notificaciones Inteligente**

### 📊 **OPCIONAL - IMPLEMENTAR TERCERO:**
11. **Sistema de Monitoreo y Alertas Automáticas**
12. **Métricas Avanzadas del Sistema**
13. **Análisis Predictivo de Comportamiento**

## 💡 **PROPUESTA DE IMPLEMENTACIÓN:**

¿Quieres que empecemos implementando las **5 lógicas más críticas** primero? Podemos comenzar con el **Sistema de Timeouts y Reasignación Automática** que es fundamental para el funcionamiento del sistema.

**¿Cuál prefieres que implementemos primero?**




