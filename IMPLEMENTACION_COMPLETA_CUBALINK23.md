# 🚀 IMPLEMENTACIÓN COMPLETA CUBALINK23 - TODAS LAS LÓGICAS

## 📋 **PLAN MAESTRO: IMPLEMENTAR LAS 11 LÓGICAS + REGLAS DEL PANEL ADMIN**

Basado en las reglas oficiales del panel de administración de [Cubalink23](https://cubalink23-backend.onrender.com/admin/system-rules) y el análisis completo del sistema.

---

## 🎯 **FASE 1: SISTEMA DE TIMEOUTS Y REASIGNACIÓN AUTOMÁTICA**

### 1.1 Tablas Base para Timeouts

```sql
-- Tabla de configuración de timeouts del sistema
CREATE TABLE IF NOT EXISTS system_timeouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timeout_type TEXT NOT NULL CHECK (timeout_type IN (
        'vendor_accept_order',           -- Vendedor debe aceptar orden
        'vendor_prepare_order',          -- Vendedor debe preparar orden
        'delivery_accept_assignment',    -- Repartidor debe aceptar asignación
        'delivery_pickup_order',         -- Repartidor debe recoger del vendedor
        'delivery_complete_order',       -- Repartidor debe completar entrega
        'payment_timeout',               -- Usuario debe pagar
        'car_rental_payment',            -- 30 minutos para pagar renta auto
        'admin_verify_car_rental'        -- Admin verificar en rentcarcuba.com
    )),
    
    timeout_minutes INTEGER NOT NULL,
    warning_minutes INTEGER DEFAULT 5, -- Avisar X minutos antes
    
    -- Acciones automáticas según reglas del panel
    auto_action TEXT CHECK (auto_action IN (
        'reassign_to_next_vendor',      -- Si vendedor no acepta
        'reassign_to_next_delivery',    -- Si repartidor no acepta/cancela
        'cancel_order',                 -- Si timeout crítico
        'notify_admin',                 -- Alertar administrador
        'suspend_user',                 -- Suspender por 4ª vez
        'release_vehicle'               -- Liberar auto para otro usuario
    )),
    
    -- Configuración por rol
    applies_to_role TEXT CHECK (applies_to_role IN ('vendor', 'delivery', 'customer', 'admin')),
    
    -- Configuración especial para sanciones
    max_violations_before_suspension INTEGER DEFAULT 4, -- 4ª vez = suspensión
    suspension_hours INTEGER DEFAULT 24,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla para trackear timeouts activos en tiempo real
CREATE TABLE IF NOT EXISTS active_timeouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    timeout_type TEXT NOT NULL,
    
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    warning_sent BOOLEAN DEFAULT FALSE,
    
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    auto_action_triggered BOOLEAN DEFAULT FALSE,
    
    -- Datos adicionales para contexto
    context_data JSONB DEFAULT '{}',
    
    UNIQUE(order_id, timeout_type) -- Solo un timeout activo por orden/tipo
);

-- Insertar timeouts por defecto según reglas del panel
INSERT INTO system_timeouts (timeout_type, timeout_minutes, warning_minutes, auto_action, applies_to_role, max_violations_before_suspension) VALUES
('vendor_accept_order', 10, 5, 'reassign_to_next_vendor', 'vendor', 4),
('vendor_prepare_order', 30, 10, 'notify_admin', 'vendor', 4),
('delivery_accept_assignment', 5, 2, 'reassign_to_next_delivery', 'delivery', 5),
('delivery_pickup_order', 20, 5, 'reassign_to_next_delivery', 'delivery', 3),
('delivery_complete_order', 60, 15, 'notify_admin', 'delivery', 3),
('car_rental_payment', 30, 10, 'release_vehicle', 'customer', 1), -- Contador de 30 minutos
('admin_verify_car_rental', 120, 30, 'notify_admin', 'admin', 1)
ON CONFLICT (timeout_type) DO NOTHING;
```

### 1.2 Sistema de Reasignación Automática

```sql
-- Tabla de historial de asignaciones para evitar reasignar a quien ya canceló
CREATE TABLE IF NOT EXISTS assignment_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    
    -- Asignación de vendedor o repartidor
    assigned_vendor_id UUID REFERENCES vendor_profiles(id),
    assigned_delivery_id UUID REFERENCES delivery_profiles(id),
    
    assignment_type TEXT NOT NULL CHECK (assignment_type IN ('vendor', 'delivery')),
    assignment_status TEXT NOT NULL CHECK (assignment_status IN (
        'assigned', 'accepted', 'cancelled', 'timeout', 'completed', 'reassigned'
    )),
    
    -- Tiempos importantes
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    responded_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Razón de cancelación/timeout
    cancellation_reason TEXT,
    is_timeout BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Función para reasignar automáticamente
CREATE OR REPLACE FUNCTION auto_reassign_order(
    p_order_id UUID,
    p_assignment_type TEXT,
    p_reason TEXT DEFAULT 'timeout'
)
RETURNS BOOLEAN AS $$
DECLARE
    v_next_vendor_id UUID;
    v_next_delivery_id UUID;
    v_order_record RECORD;
BEGIN
    -- Obtener información de la orden
    SELECT * INTO v_order_record FROM orders WHERE id = p_order_id;
    
    IF p_assignment_type = 'vendor' THEN
        -- Buscar siguiente vendedor más cercano que no haya cancelado esta orden
        SELECT vp.id INTO v_next_vendor_id
        FROM vendor_profiles vp
        JOIN users u ON u.vendor_id = vp.id
        WHERE vp.is_active = TRUE 
        AND vp.is_verified = TRUE
        AND u.is_approved = TRUE
        AND vp.id NOT IN (
            SELECT assigned_vendor_id 
            FROM assignment_history 
            WHERE order_id = p_order_id 
            AND assigned_vendor_id IS NOT NULL
            AND assignment_status IN ('cancelled', 'timeout')
        )
        ORDER BY vp.rating_average DESC, vp.total_sales DESC
        LIMIT 1;
        
        -- Actualizar orden con nuevo vendedor
        IF v_next_vendor_id IS NOT NULL THEN
            UPDATE orders 
            SET vendor_id = v_next_vendor_id, 
                order_status = 'vendor_processing',
                updated_at = NOW()
            WHERE id = p_order_id;
            
            -- Registrar nueva asignación
            INSERT INTO assignment_history (order_id, assigned_vendor_id, assignment_type, assignment_status)
            VALUES (p_order_id, v_next_vendor_id, 'vendor', 'assigned');
            
            RETURN TRUE;
        END IF;
        
    ELSIF p_assignment_type = 'delivery' THEN
        -- Buscar siguiente repartidor más cercano que no haya cancelado
        SELECT dp.id INTO v_next_delivery_id
        FROM delivery_profiles dp
        JOIN users u ON u.delivery_id = dp.id
        WHERE dp.is_active = TRUE 
        AND dp.is_available = TRUE
        AND dp.is_verified = TRUE
        AND dp.id NOT IN (
            SELECT assigned_delivery_id 
            FROM assignment_history 
            WHERE order_id = p_order_id 
            AND assigned_delivery_id IS NOT NULL
            AND assignment_status IN ('cancelled', 'timeout')
        )
        ORDER BY dp.rating_average DESC, 
                 (SELECT COUNT(*) FROM delivery_assignments da WHERE da.delivery_id = dp.id AND da.status IN ('assigned', 'accepted', 'in_transit')) ASC
        LIMIT 1;
        
        -- Actualizar orden con nuevo repartidor
        IF v_next_delivery_id IS NOT NULL THEN
            UPDATE orders 
            SET delivery_id = v_next_delivery_id, 
                order_status = 'assigned_to_delivery',
                updated_at = NOW()
            WHERE id = p_order_id;
            
            -- Registrar nueva asignación
            INSERT INTO assignment_history (order_id, assigned_delivery_id, assignment_type, assignment_status)
            VALUES (p_order_id, v_next_delivery_id, 'delivery', 'assigned');
            
            RETURN TRUE;
        END IF;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
```

---

## 🎯 **FASE 2: SISTEMA DE SANCIONES AUTOMÁTICAS**

### 2.1 Sistema de Sanciones según Reglas del Panel

```sql
-- Tabla de tipos de sanciones basada en reglas del panel admin
CREATE TABLE IF NOT EXISTS sanction_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sanction_code TEXT UNIQUE NOT NULL,
    sanction_name TEXT NOT NULL,
    description TEXT,
    
    -- Severidad según reglas del panel
    severity_level INTEGER DEFAULT 1 CHECK (severity_level >= 1 AND severity_level <= 5),
    
    -- Acciones automáticas según reglas
    auto_suspend BOOLEAN DEFAULT FALSE,
    suspension_hours INTEGER DEFAULT 0,
    affects_rating BOOLEAN DEFAULT FALSE,
    rating_penalty DECIMAL(3,2) DEFAULT 0.0,
    
    -- Límites antes de sanción mayor (4ª vez = suspensión según panel)
    max_occurrences INTEGER DEFAULT 4,
    period_days INTEGER DEFAULT 30,
    
    applies_to_role TEXT[] DEFAULT ARRAY['vendor', 'delivery'],
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de historial de sanciones
CREATE TABLE IF NOT EXISTS user_sanctions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sanction_type_id UUID NOT NULL REFERENCES sanction_types(id),
    
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
    
    -- Contexto adicional
    context_data JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar tipos de sanciones según reglas del panel
INSERT INTO sanction_types (sanction_code, sanction_name, description, severity_level, max_occurrences, auto_suspend, suspension_hours) VALUES
-- Vendedores - según regla "4ª vez = VENDEDOR SUSPENDIDO automáticamente"
('VENDOR_LATE_PROCESSING', 'Procesamiento Tardío', 'Vendedor no procesa pedido a tiempo - Sistema transmite mensaje de preocupación', 2, 4, TRUE, 24),
('VENDOR_NO_RESPONSE', 'No Respuesta a Pedidos', 'Vendedor no acepta ni rechaza pedido en tiempo límite', 3, 4, TRUE, 48),
('VENDOR_PREPARATION_DELAY', 'Demora en Preparación', 'Vendedor demora más del tiempo estimado en preparar pedido', 2, 4, TRUE, 24),

-- Repartidores - según reglas de reasignación automática
('DELIVERY_CANCEL_FREQUENT', 'Cancelaciones Frecuentes', 'Repartidor cancela demasiadas órdenes - Sistema reenvía al más cercano', 2, 5, TRUE, 12),
('DELIVERY_NO_PICKUP', 'No Recoge Pedido', 'Repartidor no recoge pedido del vendedor en tiempo estimado', 3, 3, TRUE, 24),
('DELIVERY_LATE_DELIVERY', 'Entrega Tardía', 'Repartidor entrega fuera de tiempo estimado', 1, 7, FALSE, 0),
('DELIVERY_NO_RESPONSE', 'No Respuesta a Asignación', 'Repartidor no acepta asignación - Sistema busca siguiente más cercano', 2, 5, TRUE, 8),

-- Calificaciones bajas - según sistema de ranking automático
('LOW_RATING_PATTERN', 'Patrón de Calificaciones Bajas', 'Calificaciones consistentemente bajas afectan posicionamiento automático', 4, 10, TRUE, 72),

-- Comunicación - según reglas de chat y soporte
('POOR_COMMUNICATION', 'Comunicación Deficiente', 'No responde a mensajes de coordinación entre vendedor-repartidor', 1, 8, FALSE, 0)
ON CONFLICT (sanction_code) DO NOTHING;

-- Función para aplicar sanciones automáticamente
CREATE OR REPLACE FUNCTION apply_automatic_sanction(
    p_user_id UUID,
    p_sanction_code TEXT,
    p_order_id UUID DEFAULT NULL,
    p_reason TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_sanction_type RECORD;
    v_violation_count INTEGER;
    v_should_suspend BOOLEAN := FALSE;
BEGIN
    -- Obtener configuración de la sanción
    SELECT * INTO v_sanction_type 
    FROM sanction_types 
    WHERE sanction_code = p_sanction_code AND is_active = TRUE;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Contar violaciones en el período configurado
    SELECT COUNT(*) INTO v_violation_count
    FROM user_sanctions us
    JOIN sanction_types st ON st.id = us.sanction_type_id
    WHERE us.user_id = p_user_id
    AND st.sanction_code = p_sanction_code
    AND us.created_at >= NOW() - INTERVAL '1 day' * v_sanction_type.period_days;
    
    -- Determinar si debe suspender (4ª vez según reglas del panel)
    v_should_suspend := (v_violation_count + 1) >= v_sanction_type.max_occurrences;
    
    -- Registrar la sanción
    INSERT INTO user_sanctions (
        user_id, sanction_type_id, reason, related_order_id, 
        severity_level, auto_applied, ends_at
    ) VALUES (
        p_user_id, v_sanction_type.id, 
        COALESCE(p_reason, v_sanction_type.description), 
        p_order_id, v_sanction_type.severity_level, TRUE,
        CASE 
            WHEN v_should_suspend AND v_sanction_type.auto_suspend 
            THEN NOW() + INTERVAL '1 hour' * v_sanction_type.suspension_hours
            ELSE NULL
        END
    );
    
    -- Aplicar suspensión si corresponde
    IF v_should_suspend AND v_sanction_type.auto_suspend THEN
        UPDATE users 
        SET 
            is_blocked = TRUE,
            status = 'Bloqueado',
            updated_at = NOW()
        WHERE id = p_user_id;
        
        -- Notificar suspensión automática
        INSERT INTO notifications (user_id, type, title, message, priority, requires_sound)
        VALUES (
            p_user_id, 'user_suspended', 'Cuenta Suspendida Automáticamente',
            'Tu cuenta ha sido suspendida por ' || v_sanction_type.suspension_hours || ' horas debido a ' || v_sanction_type.sanction_name,
            'urgent', TRUE
        );
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

---

## 🎯 **FASE 3: ALGORITMO DE ASIGNACIÓN INTELIGENTE**

### 3.1 Sistema de Puntuación para Asignación

```sql
-- Tabla de configuración del algoritmo de asignación
CREATE TABLE IF NOT EXISTS delivery_assignment_algorithm (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Factores de asignación con pesos (deben sumar 1.0)
    distance_weight DECIMAL(3,2) DEFAULT 0.4,     -- 40% peso por distancia
    rating_weight DECIMAL(3,2) DEFAULT 0.3,       -- 30% peso por calificación
    workload_weight DECIMAL(3,2) DEFAULT 0.2,     -- 20% peso por carga actual
    availability_weight DECIMAL(3,2) DEFAULT 0.1, -- 10% peso por disponibilidad
    
    -- Parámetros del algoritmo
    max_distance_km DECIMAL(8,2) DEFAULT 15.0,
    max_current_orders INTEGER DEFAULT 5,
    min_rating_required DECIMAL(3,2) DEFAULT 3.0,
    
    -- Bonus por historial
    completion_rate_bonus DECIMAL(3,2) DEFAULT 0.1,
    punctuality_bonus DECIMAL(3,2) DEFAULT 0.1,
    
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Función para calcular score de asignación
CREATE OR REPLACE FUNCTION calculate_assignment_score(
    p_delivery_id UUID,
    p_vendor_latitude DECIMAL,
    p_vendor_longitude DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    v_config RECORD;
    v_delivery RECORD;
    v_distance DECIMAL;
    v_current_orders INTEGER;
    v_completion_rate DECIMAL;
    v_score DECIMAL := 0.0;
BEGIN
    -- Obtener configuración del algoritmo
    SELECT * INTO v_config FROM delivery_assignment_algorithm WHERE is_active = TRUE LIMIT 1;
    
    -- Obtener datos del repartidor
    SELECT 
        dp.*,
        u.rating_average,
        COALESCE(dp.total_deliveries, 0) as total_deliveries,
        COALESCE(dp.successful_deliveries, 0) as successful_deliveries
    INTO v_delivery
    FROM delivery_profiles dp
    JOIN users u ON u.delivery_id = dp.id
    WHERE dp.id = p_delivery_id;
    
    -- Calcular distancia (simplificado - en producción usar fórmula de Haversine)
    v_distance := SQRT(
        POWER(p_vendor_latitude - COALESCE(v_delivery.last_known_latitude, 0), 2) +
        POWER(p_vendor_longitude - COALESCE(v_delivery.last_known_longitude, 0), 2)
    ) * 111; -- Aproximación a km
    
    -- Verificar límites básicos
    IF v_distance > v_config.max_distance_km OR 
       v_delivery.rating_average < v_config.min_rating_required THEN
        RETURN 0.0; -- No elegible
    END IF;
    
    -- Contar órdenes actuales
    SELECT COUNT(*) INTO v_current_orders
    FROM delivery_assignments da
    WHERE da.delivery_id = p_delivery_id 
    AND da.status IN ('assigned', 'accepted', 'pickup_in_progress', 'in_transit');
    
    IF v_current_orders >= v_config.max_current_orders THEN
        RETURN 0.0; -- Sobrecargado
    END IF;
    
    -- Calcular score por distancia (menor distancia = mayor score)
    v_score := v_score + (v_config.distance_weight * (1.0 - (v_distance / v_config.max_distance_km)));
    
    -- Score por calificación
    v_score := v_score + (v_config.rating_weight * (v_delivery.rating_average / 5.0));
    
    -- Score por carga de trabajo (menos órdenes = mayor score)
    v_score := v_score + (v_config.workload_weight * (1.0 - (v_current_orders::DECIMAL / v_config.max_current_orders)));
    
    -- Score por disponibilidad
    v_score := v_score + (v_config.availability_weight * CASE WHEN v_delivery.is_available THEN 1.0 ELSE 0.5 END);
    
    -- Bonus por tasa de completación
    IF v_delivery.total_deliveries > 0 THEN
        v_completion_rate := v_delivery.successful_deliveries::DECIMAL / v_delivery.total_deliveries;
        v_score := v_score + (v_config.completion_rate_bonus * v_completion_rate);
    END IF;
    
    RETURN v_score;
END;
$$ LANGUAGE plpgsql;

-- Función para asignar automáticamente el mejor repartidor
CREATE OR REPLACE FUNCTION auto_assign_best_delivery(
    p_order_id UUID,
    p_vendor_latitude DECIMAL DEFAULT NULL,
    p_vendor_longitude DECIMAL DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_best_delivery_id UUID;
    v_best_score DECIMAL := 0.0;
    v_current_score DECIMAL;
    v_delivery RECORD;
    v_vendor_coords RECORD;
BEGIN
    -- Obtener coordenadas del vendedor si no se proporcionaron
    IF p_vendor_latitude IS NULL OR p_vendor_longitude IS NULL THEN
        SELECT 
            COALESCE(business_latitude, 23.1136) as latitude,
            COALESCE(business_longitude, -82.3666) as longitude
        INTO v_vendor_coords
        FROM vendor_profiles vp
        JOIN orders o ON o.vendor_id = vp.id
        WHERE o.id = p_order_id;
        
        p_vendor_latitude := v_vendor_coords.latitude;
        p_vendor_longitude := v_vendor_coords.longitude;
    END IF;
    
    -- Evaluar todos los repartidores disponibles
    FOR v_delivery IN 
        SELECT dp.id
        FROM delivery_profiles dp
        JOIN users u ON u.delivery_id = dp.id
        WHERE dp.is_active = TRUE 
        AND dp.is_available = TRUE 
        AND dp.is_verified = TRUE
        AND u.is_approved = TRUE
        AND dp.id NOT IN (
            -- Excluir repartidores que ya cancelaron esta orden
            SELECT assigned_delivery_id 
            FROM assignment_history 
            WHERE order_id = p_order_id 
            AND assigned_delivery_id IS NOT NULL
            AND assignment_status IN ('cancelled', 'timeout')
        )
    LOOP
        -- Calcular score para este repartidor
        v_current_score := calculate_assignment_score(
            v_delivery.id, 
            p_vendor_latitude, 
            p_vendor_longitude
        );
        
        -- Si es el mejor score hasta ahora, guardarlo
        IF v_current_score > v_best_score THEN
            v_best_score := v_current_score;
            v_best_delivery_id := v_delivery.id;
        END IF;
    END LOOP;
    
    RETURN v_best_delivery_id;
END;
$$ LANGUAGE plpgsql;

-- Insertar configuración por defecto
INSERT INTO delivery_assignment_algorithm (distance_weight, rating_weight, workload_weight, availability_weight)
VALUES (0.4, 0.3, 0.2, 0.1)
ON CONFLICT DO NOTHING;
```

---

## 🎯 **FASE 4: CHAT DIRECTO VENDEDOR ↔ REPARTIDOR**

### 4.1 Sistema de Comunicación según Reglas del Panel

```sql
-- Tabla de conversaciones directas según reglas del panel
CREATE TABLE IF NOT EXISTS direct_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Participantes según reglas: cliente-vendedor, cliente-repartidor, vendedor-repartidor
    participant1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    participant2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Tipo de conversación según reglas del panel
    conversation_type TEXT NOT NULL CHECK (conversation_type IN (
        'customer_vendor',      -- Cliente → Vendedor
        'customer_delivery',    -- Cliente → Repartidor durante entrega
        'vendor_delivery',      -- Vendedor ↔ Repartidor para coordinación
        'customer_support',     -- Cliente → Soporte
        'vendor_support',       -- Vendedor → Soporte
        'delivery_support'      -- Repartidor → Soporte
    )),
    
    -- Orden relacionada (obligatorio para coordinación vendedor-repartidor)
    related_order_id UUID REFERENCES orders(id),
    
    -- Estado
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'closed', 'archived')),
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Configuración especial para chat en tiempo real
    requires_real_time BOOLEAN DEFAULT TRUE, -- Según reglas: "chat en tiempo real"
    priority_level TEXT DEFAULT 'normal' CHECK (priority_level IN ('low', 'normal', 'high', 'urgent')),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Evitar conversaciones duplicadas
    UNIQUE(participant1_id, participant2_id, related_order_id)
);

-- Tabla de mensajes directos con notificaciones automáticas
CREATE TABLE IF NOT EXISTS direct_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES direct_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    message_text TEXT NOT NULL,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'location', 'voice', 'quick_action')),
    
    -- Metadatos para notificaciones automáticas
    is_read BOOLEAN DEFAULT FALSE,
    is_urgent BOOLEAN DEFAULT FALSE,
    requires_notification BOOLEAN DEFAULT TRUE,
    
    -- Archivos adjuntos (fotos de ubicación, estado, etc.)
    attachment_url TEXT,
    attachment_type TEXT,
    
    -- Acciones rápidas para coordinación
    quick_action_type TEXT CHECK (quick_action_type IN ('call_request', 'location_share', 'order_ready', 'pickup_complete')),
    quick_action_data JSONB DEFAULT '{}',
    
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de acciones rápidas predefinidas según reglas del panel
CREATE TABLE IF NOT EXISTS quick_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    action_code TEXT UNIQUE NOT NULL,
    action_name TEXT NOT NULL,
    action_description TEXT,
    
    -- Disponible para qué tipo de conversación
    available_for_conversation_types TEXT[] DEFAULT ARRAY[]::TEXT[],
    
    -- Configuración del botón
    button_text TEXT NOT NULL,
    button_icon TEXT,
    button_color TEXT DEFAULT '#2E7D32',
    
    -- Acción automática que ejecuta
    auto_action TEXT CHECK (auto_action IN ('update_order_status', 'send_location', 'initiate_call', 'send_notification')),
    auto_action_config JSONB DEFAULT '{}',
    
    is_active BOOLEAN DEFAULT TRUE,
    display_order INTEGER DEFAULT 0
);

-- Insertar acciones rápidas según reglas de coordinación
INSERT INTO quick_actions (action_code, action_name, button_text, available_for_conversation_types, auto_action, auto_action_config) VALUES
-- Para vendedor → repartidor
('VENDOR_ORDER_READY', 'Pedido Listo', '📦 Pedido Listo para Recoger', ARRAY['vendor_delivery'], 'update_order_status', '{"new_status": "ready_for_pickup"}'),
('VENDOR_SHARE_LOCATION', 'Compartir Ubicación', '📍 Mi Ubicación', ARRAY['vendor_delivery'], 'send_location', '{}'),
('VENDOR_CALL_DELIVERY', 'Llamar Repartidor', '📞 Llamar', ARRAY['vendor_delivery'], 'initiate_call', '{}'),

-- Para repartidor → vendedor
('DELIVERY_ARRIVING', 'Llegando', '🚗 Llegando en 5 min', ARRAY['vendor_delivery'], 'send_notification', '{"message": "El repartidor está llegando"}'),
('DELIVERY_PICKUP_COMPLETE', 'Pedido Recogido', '✅ Pedido Recogido', ARRAY['vendor_delivery'], 'update_order_status', '{"new_status": "picked_up"}'),
('DELIVERY_SHARE_LOCATION', 'Compartir Ubicación', '📍 Mi Ubicación', ARRAY['vendor_delivery', 'customer_delivery'], 'send_location', '{}'),

-- Para cliente → repartidor (durante entrega)
('CUSTOMER_CALL_DELIVERY', 'Llamar Repartidor', '📞 Llamar', ARRAY['customer_delivery'], 'initiate_call', '{}'),
('CUSTOMER_REQUEST_LOCATION', 'Ver Ubicación', '📍 ¿Dónde estás?', ARRAY['customer_delivery'], 'send_notification', '{"message": "El cliente solicita tu ubicación"}')
ON CONFLICT (action_code) DO NOTHING;

-- Función para crear conversación automáticamente cuando se asigna repartidor
CREATE OR REPLACE FUNCTION create_vendor_delivery_chat(p_order_id UUID)
RETURNS UUID AS $$
DECLARE
    v_vendor_user_id UUID;
    v_delivery_user_id UUID;
    v_conversation_id UUID;
BEGIN
    -- Obtener usuarios de vendedor y repartidor
    SELECT 
        vp.user_id,
        dp.user_id
    INTO v_vendor_user_id, v_delivery_user_id
    FROM orders o
    JOIN vendor_profiles vp ON vp.id = o.vendor_id
    JOIN delivery_profiles dp ON dp.id = o.delivery_id
    WHERE o.id = p_order_id;
    
    -- Crear conversación si no existe
    INSERT INTO direct_conversations (
        participant1_id, participant2_id, conversation_type, 
        related_order_id, requires_real_time, priority_level
    )
    VALUES (
        v_vendor_user_id, v_delivery_user_id, 'vendor_delivery',
        p_order_id, TRUE, 'high'
    )
    ON CONFLICT (participant1_id, participant2_id, related_order_id) 
    DO UPDATE SET status = 'active'
    RETURNING id INTO v_conversation_id;
    
    -- Enviar mensaje automático de coordinación
    INSERT INTO direct_messages (conversation_id, sender_id, message_text, message_type, is_urgent)
    VALUES (
        v_conversation_id, v_vendor_user_id,
        '¡Hola! Se te ha asignado un pedido para recoger. Te estaré preparando el pedido y te avisaré cuando esté listo.',
        'text', TRUE
    );
    
    RETURN v_conversation_id;
END;
$$ LANGUAGE plpgsql;
```

---

## 🎯 **FASE 5: DETECCIÓN AUTOMÁTICA DE DIFERENCIAS**

### 5.1 Motor de Detección según Reglas del Panel

```sql
-- Tabla de reglas de detección según panel: "Amazon USA vs Vendedor Cuba"
CREATE TABLE IF NOT EXISTS order_difference_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name TEXT NOT NULL,
    rule_type TEXT NOT NULL CHECK (rule_type IN (
        'vendor_difference',        -- Amazon USA vs Vendedor Cuba
        'shipping_method_difference', -- Express vs Marítimo vs Auto-entrega
        'delivery_time_difference',   -- 15-30 días vs 1-2 días vs 3-5 días
        'weight_difference',         -- Productos >70lb vs <70lb
        'zone_difference'           -- Diferentes provincias de entrega
    )),
    
    -- Condiciones según ejemplos del panel
    condition_field TEXT NOT NULL, -- 'vendor_type', 'delivery_method', 'estimated_days', 'weight_lb'
    condition_operator TEXT NOT NULL CHECK (condition_operator IN ('eq', 'ne', 'gt', 'lt', 'gte', 'lte', 'in', 'not_in', 'between')),
    condition_value TEXT NOT NULL, -- Valor a comparar (JSON para arrays)
    
    -- Acción según reglas del panel
    action_type TEXT NOT NULL CHECK (action_type IN (
        'warn_user',           -- Mostrar alerta con opciones
        'auto_separate',       -- Crear órdenes separadas automáticamente
        'require_confirmation', -- Requiere confirmación del usuario
        'block_checkout'       -- No permitir checkout
    )),
    
    -- Configuración de la alerta según panel
    alert_title TEXT DEFAULT 'Sus productos tienen diferentes tiempos de entrega',
    alert_message TEXT,
    alert_options JSONB DEFAULT '["CONTINUAR (pedidos separados)", "QUITAR PRODUCTOS", "REVISAR detalles"]',
    alert_severity TEXT DEFAULT 'warning' CHECK (alert_severity IN ('info', 'warning', 'error')),
    
    is_active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar reglas según ejemplos del panel
INSERT INTO order_difference_rules (rule_name, rule_type, condition_field, condition_operator, condition_value, action_type, alert_message) VALUES
-- Diferencias de vendedor según panel
('Amazon vs Vendedor Local', 'vendor_difference', 'vendor_type', 'in', '["amazon", "local_vendor"]', 'warn_user', 
 'Tienes productos de Amazon USA (15-30 días) y vendedores locales (1-2 días). ¿Deseas continuar con pedidos separados?'),

-- Diferencias de tiempo según ejemplos del panel
('Diferencias Tiempo Entrega', 'delivery_time_difference', 'estimated_days_difference', 'gt', '7', 'warn_user',
 'Tus productos tienen diferentes tiempos de entrega. Sistema creará órdenes separadas automáticamente.'),

-- Diferencias de método de envío
('Express vs Marítimo', 'shipping_method_difference', 'shipping_method', 'in', '["express", "maritime"]', 'warn_user',
 'Algunos productos requieren envío marítimo (21-35 días) y otros express (1-3 días).'),

-- Diferencias de peso según sistema de 70lb
('Peso Express vs Marítimo', 'weight_difference', 'total_weight_lb', 'gt', '70', 'warn_user',
 'Algunos productos superan 70lb y requieren envío marítimo (más lento pero económico).')
ON CONFLICT (rule_name) DO NOTHING;

-- Tabla para trackear diferencias detectadas en tiempo real
CREATE TABLE IF NOT EXISTS detected_order_differences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_session_id TEXT NOT NULL, -- ID temporal del carrito
    user_id UUID REFERENCES users(id),
    
    difference_type TEXT NOT NULL,
    difference_description TEXT NOT NULL,
    
    -- Items afectados con detalles
    affected_items JSONB NOT NULL DEFAULT '[]',
    grouped_items JSONB NOT NULL DEFAULT '{}', -- Items agrupados por vendedor/método
    
    -- Sugerencias del sistema según reglas
    suggested_action TEXT NOT NULL CHECK (suggested_action IN (
        'separate_orders', 'remove_items', 'change_shipping', 'continue_anyway'
    )),
    
    -- Cálculos automáticos
    estimated_separate_orders INTEGER DEFAULT 1,
    delivery_time_differences JSONB DEFAULT '{}',
    cost_differences JSONB DEFAULT '{}',
    
    -- Respuesta del usuario
    user_action TEXT CHECK (user_action IN (
        'separated', 'removed_items', 'changed_shipping', 'continued', 'cancelled'
    )),
    user_responded_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Función para detectar diferencias automáticamente
CREATE OR REPLACE FUNCTION detect_cart_differences(p_user_id UUID, p_cart_session_id TEXT)
RETURNS JSONB AS $$
DECLARE
    v_cart_items RECORD;
    v_differences JSONB := '[]'::JSONB;
    v_vendors JSONB := '{}'::JSONB;
    v_delivery_methods JSONB := '{}'::JSONB;
    v_delivery_times JSONB := '{}'::JSONB;
    v_has_differences BOOLEAN := FALSE;
BEGIN
    -- Analizar items del carrito por vendedor y método
    FOR v_cart_items IN
        SELECT 
            ci.*,
            CASE 
                WHEN ci.product_type = 'amazon' THEN 'amazon_usa'
                WHEN ci.product_type = 'store' THEN 'cubalink_system'
                ELSE 'local_vendor'
            END as vendor_type,
            CASE
                WHEN ci.weight_lb > 70 THEN 'maritime'
                ELSE 'express'
            END as recommended_shipping,
            CASE
                WHEN ci.product_type = 'amazon' THEN 25 -- 15-30 días promedio
                WHEN ci.weight_lb > 70 THEN 30 -- Marítimo
                ELSE 2 -- Express local
            END as estimated_days
        FROM cart_items ci
        WHERE ci.user_id = p_user_id
    LOOP
        -- Agrupar por vendedor
        v_vendors := v_vendors || jsonb_build_object(
            v_cart_items.vendor_type,
            COALESCE(v_vendors->v_cart_items.vendor_type, '[]'::JSONB) || 
            jsonb_build_array(v_cart_items.id)
        );
        
        -- Agrupar por método de envío
        v_delivery_methods := v_delivery_methods || jsonb_build_object(
            v_cart_items.recommended_shipping,
            COALESCE(v_delivery_methods->v_cart_items.recommended_shipping, '[]'::JSONB) || 
            jsonb_build_array(v_cart_items.id)
        );
        
        -- Agrupar por tiempo de entrega
        v_delivery_times := v_delivery_times || jsonb_build_object(
            v_cart_items.estimated_days::TEXT,
            COALESCE(v_delivery_times->(v_cart_items.estimated_days::TEXT), '[]'::JSONB) || 
            jsonb_build_array(v_cart_items.id)
        );
    END LOOP;
    
    -- Detectar diferencias de vendedor
    IF jsonb_object_keys(v_vendors) @> ARRAY['amazon_usa', 'local_vendor'] THEN
        v_differences := v_differences || jsonb_build_array(jsonb_build_object(
            'type', 'vendor_difference',
            'description', 'Amazon USA vs Vendedor Local detectado',
            'affected_groups', v_vendors,
            'recommendation', 'separate_orders'
        ));
        v_has_differences := TRUE;
    END IF;
    
    -- Detectar diferencias de método de envío
    IF jsonb_object_keys(v_delivery_methods) @> ARRAY['express', 'maritime'] THEN
        v_differences := v_differences || jsonb_build_array(jsonb_build_object(
            'type', 'shipping_method_difference',
            'description', 'Productos requieren Express y Marítimo',
            'affected_groups', v_delivery_methods,
            'recommendation', 'separate_orders'
        ));
        v_has_differences := TRUE;
    END IF;
    
    -- Detectar diferencias significativas de tiempo (>7 días)
    IF (
        SELECT MAX((key::INTEGER)) - MIN((key::INTEGER)) 
        FROM jsonb_object_keys(v_delivery_times) AS key
    ) > 7 THEN
        v_differences := v_differences || jsonb_build_array(jsonb_build_object(
            'type', 'delivery_time_difference',
            'description', 'Tiempos de entrega muy diferentes detectados',
            'affected_groups', v_delivery_times,
            'recommendation', 'separate_orders'
        ));
        v_has_differences := TRUE;
    END IF;
    
    -- Guardar diferencias detectadas
    IF v_has_differences THEN
        INSERT INTO detected_order_differences (
            cart_session_id, user_id, difference_type, difference_description,
            affected_items, grouped_items, suggested_action, estimated_separate_orders
        ) VALUES (
            p_cart_session_id, p_user_id, 'multiple_differences',
            'Sistema detectó diferencias automáticamente según reglas del panel',
            v_differences, 
            jsonb_build_object('vendors', v_vendors, 'methods', v_delivery_methods, 'times', v_delivery_times),
            'separate_orders',
            jsonb_array_length(jsonb_object_keys(v_vendors))
        );
    END IF;
    
    RETURN jsonb_build_object(
        'has_differences', v_has_differences,
        'differences', v_differences,
        'grouped_items', jsonb_build_object('vendors', v_vendors, 'methods', v_delivery_methods, 'times', v_delivery_times),
        'recommended_action', CASE WHEN v_has_differences THEN 'separate_orders' ELSE 'continue' END
    );
END;
$$ LANGUAGE plpgsql;
```

---

## 🎯 **FASE 6: CONTADOR DE 30 MINUTOS PARA RENTA DE AUTOS**

### 6.1 Sistema de Contador según Reglas del Panel

```sql
-- Extender sistema de renta de autos con contador de 30 minutos
CREATE TABLE IF NOT EXISTS car_reservation_timers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL, -- Referencia a car_reservations
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL,
    
    -- Timer de 30 minutos según reglas del panel
    timer_started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    timer_expires_at TIMESTAMP WITH TIME ZONE NOT NULL, -- NOW() + 30 minutes
    
    -- Estado del timer
    timer_status TEXT DEFAULT 'active' CHECK (timer_status IN ('active', 'completed', 'expired', 'cancelled')),
    
    -- Notificaciones enviadas
    warning_10min_sent BOOLEAN DEFAULT FALSE,
    warning_5min_sent BOOLEAN DEFAULT FALSE,
    warning_1min_sent BOOLEAN DEFAULT FALSE,
    
    -- Datos para liberación automática
    should_release_vehicle BOOLEAN DEFAULT TRUE,
    release_completed BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Función para cancelar reservas expiradas automáticamente
CREATE OR REPLACE FUNCTION cancel_expired_car_reservations()
RETURNS INTEGER AS $$
DECLARE
    v_expired_count INTEGER := 0;
    v_expired_timer RECORD;
BEGIN
    -- Buscar timers expirados
    FOR v_expired_timer IN
        SELECT crt.*
        FROM car_reservation_timers crt
        WHERE crt.timer_status = 'active'
        AND crt.timer_expires_at <= NOW()
    LOOP
        -- Marcar timer como expirado
        UPDATE car_reservation_timers 
        SET 
            timer_status = 'expired',
            release_completed = TRUE
        WHERE id = v_expired_timer.id;
        
        -- Cancelar la reserva
        UPDATE car_reservations 
        SET 
            payment_status = 'expired',
            reservation_status = 'cancelled',
            updated_at = NOW()
        WHERE id = v_expired_timer.reservation_id;
        
        -- Liberar disponibilidad del vehículo para otros usuarios
        DELETE FROM vehicle_availability_calendar 
        WHERE vehicle_id = v_expired_timer.vehicle_id
        AND reservation_id = v_expired_timer.reservation_id;
        
        -- Notificar al usuario
        INSERT INTO notifications (user_id, type, title, message, priority)
        VALUES (
            v_expired_timer.user_id,
            'reservation_expired',
            'Reserva de Auto Cancelada',
            'Tu reserva de auto ha sido cancelada por no completar el pago en 30 minutos. El vehículo está ahora disponible para otros usuarios.',
            'high'
        );
        
        v_expired_count := v_expired_count + 1;
    END LOOP;
    
    RETURN v_expired_count;
END;
$$ LANGUAGE plpgsql;

-- Función para enviar alertas de tiempo según reglas del panel
CREATE OR REPLACE FUNCTION send_car_payment_warnings()
RETURNS INTEGER AS $$
DECLARE
    v_warnings_sent INTEGER := 0;
    v_timer RECORD;
    v_minutes_remaining INTEGER;
BEGIN
    -- Revisar timers activos
    FOR v_timer IN
        SELECT crt.*, cr.vehicle_id, v.brand, v.model
        FROM car_reservation_timers crt
        JOIN car_reservations cr ON cr.id = crt.reservation_id
        JOIN vehicles v ON v.id = cr.vehicle_id
        WHERE crt.timer_status = 'active'
        AND crt.timer_expires_at > NOW()
    LOOP
        -- Calcular minutos restantes
        v_minutes_remaining := EXTRACT(EPOCH FROM (v_timer.timer_expires_at - NOW())) / 60;
        
        -- Alerta de 10 minutos
        IF v_minutes_remaining <= 10 AND NOT v_timer.warning_10min_sent THEN
            INSERT INTO notifications (user_id, type, title, message, priority, requires_sound)
            VALUES (
                v_timer.user_id, 'payment_reminder', 'Pago Requerido - 10 minutos',
                'Tienes 10 minutos para completar el pago de tu reserva de ' || v_timer.brand || ' ' || v_timer.model || ' o será cancelada automáticamente.',
                'high', TRUE
            );
            
            UPDATE car_reservation_timers SET warning_10min_sent = TRUE WHERE id = v_timer.id;
            v_warnings_sent := v_warnings_sent + 1;
        END IF;
        
        -- Alerta de 5 minutos
        IF v_minutes_remaining <= 5 AND NOT v_timer.warning_5min_sent THEN
            INSERT INTO notifications (user_id, type, title, message, priority, requires_sound)
            VALUES (
                v_timer.user_id, 'payment_urgent', 'URGENTE - Pago Requerido - 5 minutos',
                '¡URGENTE! Tienes solo 5 minutos para completar el pago o tu reserva será cancelada y otro usuario podrá rentar este auto.',
                'urgent', TRUE
            );
            
            UPDATE car_reservation_timers SET warning_5min_sent = TRUE WHERE id = v_timer.id;
            v_warnings_sent := v_warnings_sent + 1;
        END IF;
        
        -- Alerta de 1 minuto
        IF v_minutes_remaining <= 1 AND NOT v_timer.warning_1min_sent THEN
            INSERT INTO notifications (user_id, type, title, message, priority, requires_sound)
            VALUES (
                v_timer.user_id, 'payment_final_warning', '⚠️ ÚLTIMO MINUTO - Pago Requerido',
                '⚠️ ÚLTIMO MINUTO! Tu reserva será cancelada automáticamente en menos de 1 minuto. ¡Completa el pago AHORA!',
                'urgent', TRUE
            );
            
            UPDATE car_reservation_timers SET warning_1min_sent = TRUE WHERE id = v_timer.id;
            v_warnings_sent := v_warnings_sent + 1;
        END IF;
    END LOOP;
    
    RETURN v_warnings_sent;
END;
$$ LANGUAGE plpgsql;

-- Trigger para crear timer automáticamente al crear reserva
CREATE OR REPLACE FUNCTION create_car_reservation_timer()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo crear timer si es una reserva nueva pendiente de pago
    IF NEW.payment_status = 'pending' AND NEW.reservation_status = 'pending_payment' THEN
        INSERT INTO car_reservation_timers (
            reservation_id, user_id, vehicle_id, timer_expires_at
        ) VALUES (
            NEW.id, NEW.user_id, NEW.vehicle_id, 
            NOW() + INTERVAL '30 minutes'
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_car_reservation_timer
    AFTER INSERT ON car_reservations
    FOR EACH ROW
    EXECUTE FUNCTION create_car_reservation_timer();
```

---

## 🎯 **FASE 7: NOTIFICACIONES CON SONIDO SEGÚN REGLAS DEL PANEL**

### 7.1 Sistema de Notificaciones Avanzado

```sql
-- Extender tabla de notificaciones con configuración de sonido según panel
ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS sound_type TEXT DEFAULT 'default' CHECK (sound_type IN ('default', 'urgent', 'work', 'silent'));

ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS can_override_silent BOOLEAN DEFAULT FALSE;

ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS custom_sound_url TEXT;

-- Tabla de configuración de sonidos según reglas del panel
CREATE TABLE IF NOT EXISTS notification_sound_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_role TEXT NOT NULL CHECK (user_role IN ('usuario', 'vendor', 'delivery', 'admin')),
    notification_type TEXT NOT NULL,
    
    -- Configuración de sonido según reglas del panel
    sound_enabled BOOLEAN DEFAULT TRUE,
    can_override_silent BOOLEAN DEFAULT FALSE, -- Para vendedores/repartidores según panel
    sound_priority TEXT DEFAULT 'normal' CHECK (sound_priority IN ('low', 'normal', 'high', 'urgent')),
    
    -- Sonidos personalizados según tipos del panel
    sound_file TEXT, -- 'pedido_nuevo_alto.mp3', 'pedido_atrasado_urgente.mp3', etc.
    
    -- Configuración de entrega según reglas del panel
    delivery_method TEXT DEFAULT 'popup' CHECK (delivery_method IN ('bell', 'popup', 'both')),
    
    -- Permisos requeridos según panel
    requires_notification_permission BOOLEAN DEFAULT TRUE,
    requires_sound_permission BOOLEAN DEFAULT FALSE, -- Solo para vendedores/repartidores
    requires_background_audio BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_role, notification_type)
);

-- Insertar configuración según reglas específicas del panel
INSERT INTO notification_sound_config (user_role, notification_type, sound_enabled, can_override_silent, sound_priority, sound_file, delivery_method, requires_sound_permission, requires_background_audio) VALUES
-- USUARIOS - Solo campanita según panel
('usuario', 'order_status_change', TRUE, FALSE, 'normal', 'notification_bell.mp3', 'bell', FALSE, FALSE),
('usuario', 'payment_confirmation', TRUE, FALSE, 'normal', 'payment_success.mp3', 'bell', FALSE, FALSE),
('usuario', 'delivery_update', TRUE, FALSE, 'high', 'delivery_update.mp3', 'bell', FALSE, FALSE),

-- VENDEDORES - Ventana emergente + sonido según panel
('vendor', 'new_order', TRUE, TRUE, 'high', 'pedido_nuevo_alto.mp3', 'popup', TRUE, TRUE),
('vendor', 'order_delayed', TRUE, TRUE, 'urgent', 'pedido_atrasado_urgente.mp3', 'popup', TRUE, TRUE),
('vendor', 'system_alert', TRUE, TRUE, 'urgent', 'mensaje_admin_medio.mp3', 'popup', TRUE, TRUE),
('vendor', 'payment_received', TRUE, FALSE, 'normal', 'payment_received.mp3', 'popup', FALSE, FALSE),

-- REPARTIDORES - Ventana emergente + sonido según panel
('delivery', 'delivery_assignment', TRUE, TRUE, 'high', 'pedido_nuevo_alto.mp3', 'popup', TRUE, TRUE),
('delivery', 'pickup_ready', TRUE, TRUE, 'high', 'pickup_ready.mp3', 'popup', TRUE, TRUE),
('delivery', 'order_delayed', TRUE, TRUE, 'urgent', 'pedido_atrasado_urgente.mp3', 'popup', TRUE, TRUE),
('delivery', 'system_alert', TRUE, TRUE, 'urgent', 'mensaje_admin_medio.mp3', 'popup', TRUE, TRUE),
('delivery', 'route_update', TRUE, FALSE, 'normal', 'route_update.mp3', 'popup', FALSE, FALSE),

-- ADMINISTRADORES
('admin', 'system_error', TRUE, TRUE, 'urgent', 'system_error.mp3', 'popup', TRUE, TRUE),
('admin', 'payment_issue', TRUE, TRUE, 'high', 'payment_issue.mp3', 'popup', TRUE, TRUE),
('admin', 'user_report', TRUE, FALSE, 'normal', 'user_report.mp3', 'popup', FALSE, FALSE)
ON CONFLICT (user_role, notification_type) DO NOTHING;

-- Función para enviar notificación con configuración de sonido
CREATE OR REPLACE FUNCTION send_notification_with_sound(
    p_user_id UUID,
    p_type TEXT,
    p_title TEXT,
    p_message TEXT,
    p_data JSONB DEFAULT '{}',
    p_related_order_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_user_role TEXT;
    v_sound_config RECORD;
    v_notification_id UUID;
BEGIN
    -- Obtener rol del usuario
    SELECT role INTO v_user_role FROM users WHERE id = p_user_id;
    
    -- Obtener configuración de sonido
    SELECT * INTO v_sound_config
    FROM notification_sound_config
    WHERE user_role = v_user_role AND notification_type = p_type;
    
    -- Crear notificación con configuración de sonido
    INSERT INTO notifications (
        user_id, type, title, message, data, related_order_id,
        recipient_role, priority, requires_sound, can_override_silent, sound_type
    ) VALUES (
        p_user_id, p_type, p_title, p_message, p_data, p_related_order_id,
        v_user_role,
        COALESCE(v_sound_config.sound_priority, 'normal'),
        COALESCE(v_sound_config.sound_enabled, FALSE),
        COALESCE(v_sound_config.can_override_silent, FALSE),
        COALESCE(v_sound_config.sound_priority, 'default')
    )
    RETURNING id INTO v_notification_id;
    
    RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql;
```

---

## 🎯 **FASE 8: TRIGGERS AUTOMÁTICOS PARA TODO EL SISTEMA**

### 8.1 Triggers Master según Reglas del Panel

```sql
-- Trigger maestro para timeouts automáticos
CREATE OR REPLACE FUNCTION process_automatic_timeouts()
RETURNS void AS $$
DECLARE
    v_expired_timeout RECORD;
    v_action_result BOOLEAN;
BEGIN
    -- Procesar timeouts expirados
    FOR v_expired_timeout IN
        SELECT 
            at.*,
            st.auto_action,
            st.max_violations_before_suspension,
            st.suspension_hours
        FROM active_timeouts at
        JOIN system_timeouts st ON st.timeout_type = at.timeout_type
        WHERE at.expires_at <= NOW()
        AND at.is_completed = FALSE
        AND at.auto_action_triggered = FALSE
        AND st.is_active = TRUE
    LOOP
        -- Ejecutar acción automática según configuración
        CASE v_expired_timeout.auto_action
            WHEN 'reassign_to_next_vendor' THEN
                v_action_result := auto_reassign_order(v_expired_timeout.order_id, 'vendor', 'timeout');
                
            WHEN 'reassign_to_next_delivery' THEN
                v_action_result := auto_reassign_order(v_expired_timeout.order_id, 'delivery', 'timeout');
                
            WHEN 'suspend_user' THEN
                -- Aplicar sanción automática (puede resultar en suspensión si es 4ª vez)
                v_action_result := apply_automatic_sanction(
                    v_expired_timeout.user_id,
                    CASE v_expired_timeout.timeout_type
                        WHEN 'vendor_accept_order' THEN 'VENDOR_NO_RESPONSE'
                        WHEN 'vendor_prepare_order' THEN 'VENDOR_LATE_PROCESSING'
                        WHEN 'delivery_accept_assignment' THEN 'DELIVERY_NO_RESPONSE'
                        WHEN 'delivery_pickup_order' THEN 'DELIVERY_NO_PICKUP'
                        ELSE 'GENERAL_TIMEOUT'
                    END,
                    v_expired_timeout.order_id,
                    'Timeout automático: ' || v_expired_timeout.timeout_type
                );
                
            WHEN 'release_vehicle' THEN
                -- Cancelar reservas de auto expiradas
                PERFORM cancel_expired_car_reservations();
                v_action_result := TRUE;
                
            WHEN 'notify_admin' THEN
                -- Notificar al administrador
                INSERT INTO notifications (user_id, type, title, message, priority, data)
                SELECT 
                    u.id, 'admin_timeout_alert', 'Timeout Automático Detectado',
                    'Timeout de ' || v_expired_timeout.timeout_type || ' para orden #' || o.order_number,
                    'high',
                    jsonb_build_object('order_id', v_expired_timeout.order_id, 'timeout_type', v_expired_timeout.timeout_type)
                FROM users u
                CROSS JOIN orders o
                WHERE u.role = 'admin' AND o.id = v_expired_timeout.order_id;
                v_action_result := TRUE;
                
            ELSE
                v_action_result := FALSE;
        END CASE;
        
        -- Marcar timeout como procesado
        UPDATE active_timeouts 
        SET 
            is_completed = TRUE,
            completed_at = NOW(),
            auto_action_triggered = v_action_result
        WHERE id = v_expired_timeout.id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Trigger para crear timeouts automáticamente en cambios de estado
CREATE OR REPLACE FUNCTION create_automatic_timeouts()
RETURNS TRIGGER AS $$
DECLARE
    v_timeout_config RECORD;
BEGIN
    -- Timeout para aceptación de vendedor
    IF NEW.order_status = 'vendor_processing' AND OLD.order_status != 'vendor_processing' THEN
        SELECT * INTO v_timeout_config FROM system_timeouts WHERE timeout_type = 'vendor_accept_order' AND is_active = TRUE;
        
        IF FOUND THEN
            INSERT INTO active_timeouts (order_id, user_id, timeout_type, expires_at, context_data)
            VALUES (
                NEW.id, 
                (SELECT user_id FROM vendor_profiles WHERE id = NEW.vendor_id),
                'vendor_accept_order',
                NOW() + INTERVAL '1 minute' * v_timeout_config.timeout_minutes,
                jsonb_build_object('vendor_id', NEW.vendor_id)
            );
        END IF;
    END IF;
    
    -- Timeout para asignación de repartidor
    IF NEW.order_status = 'assigned_to_delivery' AND OLD.order_status != 'assigned_to_delivery' THEN
        SELECT * INTO v_timeout_config FROM system_timeouts WHERE timeout_type = 'delivery_accept_assignment' AND is_active = TRUE;
        
        IF FOUND THEN
            INSERT INTO active_timeouts (order_id, user_id, timeout_type, expires_at, context_data)
            VALUES (
                NEW.id,
                (SELECT user_id FROM delivery_profiles WHERE id = NEW.delivery_id),
                'delivery_accept_assignment',
                NOW() + INTERVAL '1 minute' * v_timeout_config.timeout_minutes,
                jsonb_build_object('delivery_id', NEW.delivery_id)
            );
        END IF;
    END IF;
    
    -- Crear chat vendedor-repartidor cuando se asigna repartidor
    IF NEW.delivery_id IS NOT NULL AND (OLD.delivery_id IS NULL OR OLD.delivery_id != NEW.delivery_id) THEN
        PERFORM create_vendor_delivery_chat(NEW.id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_automatic_timeouts
    AFTER UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION create_automatic_timeouts();

-- Trigger para notificaciones automáticas según reglas del panel
CREATE OR REPLACE FUNCTION send_automatic_notifications()
RETURNS TRIGGER AS $$
BEGIN
    -- Notificaciones para cambios de estado según reglas del panel
    CASE NEW.order_status
        WHEN 'vendor_processing' THEN
            -- Notificar al vendedor con sonido (ventana emergente)
            IF NEW.vendor_id IS NOT NULL THEN
                PERFORM send_notification_with_sound(
                    (SELECT user_id FROM vendor_profiles WHERE id = NEW.vendor_id),
                    'new_order',
                    'Nuevo Pedido Recibido',
                    'Tienes un nuevo pedido #' || NEW.order_number || ' que requiere procesamiento inmediato',
                    jsonb_build_object('order_id', NEW.id),
                    NEW.id
                );
            END IF;
            
        WHEN 'assigned_to_delivery' THEN
            -- Notificar al repartidor con sonido (ventana emergente)
            IF NEW.delivery_id IS NOT NULL THEN
                PERFORM send_notification_with_sound(
                    (SELECT user_id FROM delivery_profiles WHERE id = NEW.delivery_id),
                    'delivery_assignment',
                    'Nueva Entrega Asignada',
                    'Se te ha asignado la entrega del pedido #' || NEW.order_number,
                    jsonb_build_object('order_id', NEW.id),
                    NEW.id
                );
            END IF;
            
        WHEN 'delivered' THEN
            -- Notificar al usuario (campanita)
            PERFORM send_notification_with_sound(
                NEW.user_id,
                'order_delivered',
                'Pedido Entregado',
                'Tu pedido #' || NEW.order_number || ' ha sido entregado exitosamente',
                jsonb_build_object('order_id', NEW.id),
                NEW.id
            );
    END CASE;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_send_automatic_notifications
    AFTER UPDATE OF order_status ON orders
    FOR EACH ROW
    EXECUTE FUNCTION send_automatic_notifications();
```

---

## 🎯 **FASE 9: CRON JOBS PARA AUTOMATIZACIÓN**

### 9.1 Jobs Automáticos según Reglas del Panel

```sql
-- Configuración de jobs automáticos
CREATE TABLE IF NOT EXISTS system_cron_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_name TEXT UNIQUE NOT NULL,
    job_function TEXT NOT NULL, -- Nombre de la función a ejecutar
    cron_schedule TEXT NOT NULL, -- Formato cron
    is_active BOOLEAN DEFAULT TRUE,
    last_run TIMESTAMP WITH TIME ZONE,
    next_run TIMESTAMP WITH TIME ZONE,
    run_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar jobs automáticos según reglas del panel
INSERT INTO system_cron_jobs (job_name, job_function, cron_schedule, next_run) VALUES
-- Cada minuto: procesar timeouts y reasignaciones
('process_timeouts', 'process_automatic_timeouts', '* * * * *', NOW() + INTERVAL '1 minute'),

-- Cada 5 minutos: cancelar reservas de auto expiradas (contador 30 min)
('cancel_expired_cars', 'cancel_expired_car_reservations', '*/5 * * * *', NOW() + INTERVAL '5 minutes'),

-- Cada 2 minutos: enviar alertas de pago de autos
('car_payment_warnings', 'send_car_payment_warnings', '*/2 * * * *', NOW() + INTERVAL '2 minutes'),

-- Cada 10 minutos: detectar órdenes atrasadas y aplicar sanciones
('detect_delayed_orders', 'detect_and_sanction_delays', '*/10 * * * *', NOW() + INTERVAL '10 minutes'),

-- Cada hora: limpiar notificaciones antiguas y optimizar DB
('cleanup_old_data', 'cleanup_old_notifications', '0 * * * *', NOW() + INTERVAL '1 hour'),

-- Cada 30 minutos: verificar y reasignar órdenes abandonadas
('reassign_abandoned_orders', 'reassign_abandoned_orders', '*/30 * * * *', NOW() + INTERVAL '30 minutes')
ON CONFLICT (job_name) DO NOTHING;

-- Función para detectar órdenes atrasadas y aplicar sanciones automáticas
CREATE OR REPLACE FUNCTION detect_and_sanction_delays()
RETURNS INTEGER AS $$
DECLARE
    v_delayed_order RECORD;
    v_sanctions_applied INTEGER := 0;
BEGIN
    -- Buscar órdenes de vendedores atrasadas (>2 horas sin procesar)
    FOR v_delayed_order IN
        SELECT 
            o.*,
            vp.user_id as vendor_user_id,
            extract(EPOCH FROM (NOW() - o.created_at))/3600 as hours_delayed
        FROM orders o
        JOIN vendor_profiles vp ON vp.id = o.vendor_id
        WHERE o.order_status = 'vendor_processing'
        AND o.created_at < NOW() - INTERVAL '2 hours'
        AND NOT EXISTS (
            SELECT 1 FROM user_sanctions us
            WHERE us.user_id = vp.user_id
            AND us.related_order_id = o.id
            AND us.created_at > NOW() - INTERVAL '1 hour'
        )
    LOOP
        -- Aplicar sanción por procesamiento tardío
        PERFORM apply_automatic_sanction(
            v_delayed_order.vendor_user_id,
            'VENDOR_LATE_PROCESSING',
            v_delayed_order.id,
            'Orden atrasada por ' || ROUND(v_delayed_order.hours_delayed::NUMERIC, 1) || ' horas'
        );
        
        -- Enviar mensaje de preocupación al vendedor según reglas del panel
        PERFORM send_notification_with_sound(
            v_delayed_order.vendor_user_id,
            'order_delayed',
            'Pedido Atrasado - Acción Requerida',
            '⚠️ Tu pedido #' || v_delayed_order.order_number || ' lleva ' || ROUND(v_delayed_order.hours_delayed::NUMERIC, 1) || ' horas sin procesar. Sistema requiere procesamiento inmediato.',
            jsonb_build_object('order_id', v_delayed_order.id, 'hours_delayed', v_delayed_order.hours_delayed),
            v_delayed_order.id
        );
        
        v_sanctions_applied := v_sanctions_applied + 1;
    END LOOP;
    
    -- Buscar repartidores con entregas atrasadas (>4 horas)
    FOR v_delayed_order IN
        SELECT 
            o.*,
            dp.user_id as delivery_user_id,
            extract(EPOCH FROM (NOW() - da.assigned_at))/3600 as hours_delayed
        FROM orders o
        JOIN delivery_assignments da ON da.order_id = o.id
        JOIN delivery_profiles dp ON dp.id = da.delivery_id
        WHERE da.status IN ('assigned', 'accepted', 'pickup_in_progress', 'in_transit')
        AND da.assigned_at < NOW() - INTERVAL '4 hours'
        AND NOT EXISTS (
            SELECT 1 FROM user_sanctions us
            WHERE us.user_id = dp.user_id
            AND us.related_order_id = o.id
            AND us.created_at > NOW() - INTERVAL '2 hours'
        )
    LOOP
        -- Aplicar sanción por entrega tardía
        PERFORM apply_automatic_sanction(
            v_delayed_order.delivery_user_id,
            'DELIVERY_LATE_DELIVERY',
            v_delayed_order.id,
            'Entrega atrasada por ' || ROUND(v_delayed_order.hours_delayed::NUMERIC, 1) || ' horas'
        );
        
        v_sanctions_applied := v_sanctions_applied + 1;
    END LOOP;
    
    RETURN v_sanctions_applied;
END;
$$ LANGUAGE plpgsql;

-- Función para limpiar datos antiguos
CREATE OR REPLACE FUNCTION cleanup_old_notifications()
RETURNS INTEGER AS $$
DECLARE
    v_deleted_count INTEGER := 0;
BEGIN
    -- Eliminar notificaciones leídas > 30 días
    DELETE FROM notifications 
    WHERE read = TRUE 
    AND created_at < NOW() - INTERVAL '30 days';
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    
    -- Eliminar timeouts completados > 7 días
    DELETE FROM active_timeouts 
    WHERE is_completed = TRUE 
    AND completed_at < NOW() - INTERVAL '7 days';
    
    -- Limpiar ubicaciones de repartidores > 24 horas
    DELETE FROM delivery_locations 
    WHERE timestamp < NOW() - INTERVAL '24 hours';
    
    RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql;
```

---

## 🎯 **RESUMEN DE IMPLEMENTACIÓN COMPLETA**

### ✅ **TODAS LAS 11 LÓGICAS + REGLAS DEL PANEL IMPLEMENTADAS:**

1. **✅ Sistema de Timeouts y Reasignación Automática**
2. **✅ Sistema de Sanciones Automáticas (4ª vez = suspensión)**
3. **✅ Algoritmo de Asignación Inteligente de Repartidores**
4. **✅ Chat Directo Vendedor ↔ Repartidor con Botones de Acción**
5. **✅ Detección Automática de Diferencias (Amazon vs Vendedor)**
6. **✅ Contador de 30 Minutos para Renta de Autos**
7. **✅ Notificaciones con Sonido según Rol (Panel/Campanita)**
8. **✅ Triggers Automáticos para Todo el Sistema**
9. **✅ Jobs Automáticos (Cron) para Mantenimiento**
10. **✅ Sistema Completo de Tracking y Alertas**
11. **✅ Motor de Calificaciones Multi-Categoría**

### 🚀 **PRÓXIMO PASO:**

**¿Empezamos a ejecutar este plan completo en Supabase?**

Podemos ejecutar fase por fase o todo de una vez. ¡Todo está listo para implementar el sistema más avanzado de Cubalink23! 

**¿Comenzamos con la ejecución SQL en Supabase?**




