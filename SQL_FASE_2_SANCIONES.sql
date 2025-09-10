-- ====================================
-- FASE 2: SISTEMA DE SANCIONES AUTOMÁTICAS
-- Implementación según regla "4ª vez = VENDEDOR SUSPENDIDO automáticamente"
-- ====================================

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
    v_user_record RECORD;
BEGIN
    -- Obtener configuración de la sanción
    SELECT * INTO v_sanction_type 
    FROM sanction_types 
    WHERE sanction_code = p_sanction_code AND is_active = TRUE;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Obtener datos del usuario
    SELECT * INTO v_user_record FROM users WHERE id = p_user_id;
    
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
            'Tu cuenta ha sido suspendida por ' || v_sanction_type.suspension_hours || ' horas debido a ' || v_sanction_type.sanction_name || '. Esta es tu violación #' || (v_violation_count + 1) || '.',
            'urgent', TRUE
        );
        
        -- Notificar a administradores sobre suspensión automática
        INSERT INTO notifications (user_id, type, title, message, priority, data)
        SELECT 
            u.id, 'auto_suspension_alert', 'Suspensión Automática Aplicada',
            'Usuario ' || v_user_record.email || ' (' || v_user_record.role || ') suspendido automáticamente por ' || v_sanction_type.sanction_name,
            'high',
            jsonb_build_object(
                'suspended_user_id', p_user_id,
                'suspended_user_email', v_user_record.email,
                'sanction_code', p_sanction_code,
                'violation_number', v_violation_count + 1,
                'suspension_hours', v_sanction_type.suspension_hours
            )
        FROM users u
        WHERE u.role = 'admin' AND u.is_blocked = FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Función para levantar suspensiones automáticamente cuando expire el tiempo
CREATE OR REPLACE FUNCTION lift_expired_suspensions()
RETURNS INTEGER AS $$
DECLARE
    v_lifted_count INTEGER := 0;
    v_suspended_user RECORD;
BEGIN
    -- Buscar suspensiones que ya expiraron
    FOR v_suspended_user IN
        SELECT DISTINCT us.user_id, u.email
        FROM user_sanctions us
        JOIN users u ON u.id = us.user_id
        WHERE us.ends_at IS NOT NULL
        AND us.ends_at <= NOW()
        AND us.is_active = TRUE
        AND u.is_blocked = TRUE
    LOOP
        -- Levantar suspensión
        UPDATE users 
        SET 
            is_blocked = FALSE,
            status = 'Aprobado',
            updated_at = NOW()
        WHERE id = v_suspended_user.user_id;
        
        -- Marcar sanciones como completadas
        UPDATE user_sanctions 
        SET is_active = FALSE 
        WHERE user_id = v_suspended_user.user_id 
        AND ends_at <= NOW() 
        AND is_active = TRUE;
        
        -- Notificar al usuario que su suspensión fue levantada
        INSERT INTO notifications (user_id, type, title, message, priority)
        VALUES (
            v_suspended_user.user_id, 'suspension_lifted', 'Suspensión Levantada',
            'Tu cuenta ha sido reactivada automáticamente. Puedes continuar usando la aplicación normalmente.',
            'normal'
        );
        
        v_lifted_count := v_lifted_count + 1;
    END LOOP;
    
    RETURN v_lifted_count;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- FASE 2 COMPLETADA ✅
-- - Sistema completo de sanciones automáticas
-- - Regla "4ª vez = suspensión" implementada
-- - Notificaciones automáticas a usuarios y admin
-- - Función para levantar suspensiones expiradas
-- ====================================




