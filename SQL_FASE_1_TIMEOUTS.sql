-- ====================================
-- FASE 1: SISTEMA DE TIMEOUTS Y REASIGNACIÓN AUTOMÁTICA
-- Implementación completa según reglas del panel de administración
-- ====================================

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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(timeout_type)
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

-- Tabla de historial de asignaciones para evitar reasignar a quien ya canceló
CREATE TABLE IF NOT EXISTS assignment_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    
    -- Asignación de vendedor o repartidor
    assigned_vendor_id UUID, -- REFERENCES vendor_profiles(id) - comentado por si no existe aún
    assigned_delivery_id UUID, -- REFERENCES delivery_profiles(id) - comentado por si no existe aún
    
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
        -- Nota: ajustaremos las referencias cuando las tablas de perfiles existan
        SELECT id INTO v_next_vendor_id
        FROM users
        WHERE role = 'vendor'
        AND status = 'Aprobado'
        AND is_blocked = FALSE
        AND id NOT IN (
            SELECT assigned_vendor_id 
            FROM assignment_history 
            WHERE order_id = p_order_id 
            AND assigned_vendor_id IS NOT NULL
            AND assignment_status IN ('cancelled', 'timeout')
        )
        ORDER BY created_at DESC -- Temporalmente por fecha, luego por rating
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
        SELECT id INTO v_next_delivery_id
        FROM users
        WHERE role = 'delivery'
        AND status = 'Aprobado'
        AND is_blocked = FALSE
        AND id NOT IN (
            SELECT assigned_delivery_id 
            FROM assignment_history 
            WHERE order_id = p_order_id 
            AND assigned_delivery_id IS NOT NULL
            AND assignment_status IN ('cancelled', 'timeout')
        )
        ORDER BY created_at DESC -- Temporalmente por fecha, luego por proximidad
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

-- ====================================
-- FASE 1 COMPLETADA ✅
-- - Tablas de timeouts configurables
-- - Historial de asignaciones para evitar loops
-- - Función de reasignación automática
-- - Configuración inicial según reglas del panel
-- ====================================




