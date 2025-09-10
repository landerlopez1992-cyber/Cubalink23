-- =====================================================
-- SISTEMA DE MANTENIMIENTO TOTAL - DETENER TODO
-- =====================================================
-- Cuando se activa el modo mantenimiento desde el panel admin:
-- 1. BLOQUEAR todos los vendedores (no pueden recibir pedidos)
-- 2. PAUSAR todos los repartidores (no pueden ser asignados)
-- 3. BLOQUEAR usuarios (no pueden hacer pedidos)
-- 4. DETENER todos los jobs automáticos
-- 5. PAUSAR notificaciones no críticas
-- 6. LOGS detallados del proceso

-- -----------------------------------------------------
-- 1. TABLA: system_maintenance_status (Estado de mantenimiento)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS system_maintenance_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    is_maintenance_active BOOLEAN DEFAULT false,
    activated_by UUID REFERENCES users(id),
    activated_at TIMESTAMP,
    deactivated_by UUID REFERENCES users(id),
    deactivated_at TIMESTAMP,
    maintenance_reason TEXT,
    estimated_duration_minutes INTEGER,
    affected_services TEXT[], -- services paused during maintenance
    maintenance_message TEXT DEFAULT 'Sistema en mantenimiento. Disculpe las molestias.',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Solo debe haber un registro de estado de mantenimiento
CREATE UNIQUE INDEX IF NOT EXISTS idx_system_maintenance_single ON system_maintenance_status((true));

-- Insertar estado inicial (inactivo)
INSERT INTO system_maintenance_status (is_maintenance_active, maintenance_message) 
VALUES (false, 'Sistema operativo normalmente')
ON CONFLICT ((true)) DO NOTHING;

-- -----------------------------------------------------
-- 2. TABLA: maintenance_affected_entities (Entidades afectadas)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS maintenance_affected_entities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    maintenance_session_id UUID NOT NULL,
    entity_type VARCHAR(30) NOT NULL, -- user, vendor, delivery, order, notification, job
    entity_id UUID,
    entity_identifier VARCHAR(255), -- Para jobs y otros sin UUID
    original_status VARCHAR(30), -- Estado original antes del mantenimiento
    maintenance_status VARCHAR(30), -- Estado durante mantenimiento
    blocked_at TIMESTAMP DEFAULT NOW(),
    restored_at TIMESTAMP,
    is_restored BOOLEAN DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_maintenance_entities_session ON maintenance_affected_entities(maintenance_session_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_entities_type ON maintenance_affected_entities(entity_type);
CREATE INDEX IF NOT EXISTS idx_maintenance_entities_restored ON maintenance_affected_entities(is_restored);

-- -----------------------------------------------------
-- 3. FUNCIÓN: Activar modo mantenimiento total
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION activate_total_maintenance_mode(
    activated_by_param UUID,
    reason_param TEXT DEFAULT 'Mantenimiento programado del sistema',
    estimated_duration_param INTEGER DEFAULT 60,
    maintenance_message_param TEXT DEFAULT NULL
) RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    maintenance_session_id UUID,
    vendors_blocked INTEGER,
    delivery_blocked INTEGER,
    users_blocked INTEGER,
    jobs_paused INTEGER,
    notifications_paused INTEGER
) AS $$
DECLARE
    maintenance_session_id_val UUID := gen_random_uuid();
    vendors_count INTEGER := 0;
    delivery_count INTEGER := 0;
    users_count INTEGER := 0;
    jobs_count INTEGER := 0;
    notifications_count INTEGER := 0;
    vendor_record RECORD;
    delivery_record RECORD;
    user_record RECORD;
    final_message TEXT;
BEGIN
    -- Verificar si ya está en mantenimiento
    IF EXISTS (SELECT 1 FROM system_maintenance_status WHERE is_maintenance_active = true) THEN
        RETURN QUERY SELECT 
            false, 
            'El sistema ya está en modo mantenimiento'::TEXT,
            NULL::UUID, 0, 0, 0, 0, 0;
        RETURN;
    END IF;
    
    -- Activar modo mantenimiento
    UPDATE system_maintenance_status 
    SET 
        is_maintenance_active = true,
        activated_by = activated_by_param,
        activated_at = NOW(),
        maintenance_reason = reason_param,
        estimated_duration_minutes = estimated_duration_param,
        maintenance_message = COALESCE(maintenance_message_param, maintenance_message),
        affected_services = ARRAY['vendors', 'delivery', 'users', 'orders', 'notifications', 'jobs'],
        updated_at = NOW();
    
    BEGIN
        -- ==================================
        -- 1. BLOQUEAR TODOS LOS VENDEDORES
        -- ==================================
        FOR vendor_record IN
            SELECT id, is_active, availability_status 
            FROM users 
            WHERE role = 'vendor' AND is_active = true
        LOOP
            -- Guardar estado original
            INSERT INTO maintenance_affected_entities (
                maintenance_session_id, entity_type, entity_id, 
                original_status, maintenance_status
            ) VALUES (
                maintenance_session_id_val, 'vendor', vendor_record.id,
                'active', 'maintenance_blocked'
            );
            
            -- Bloquear vendedor (marcar como inactivo temporalmente)
            UPDATE users 
            SET 
                is_active = false,
                updated_at = NOW()
            WHERE id = vendor_record.id;
            
            vendors_count := vendors_count + 1;
        END LOOP;
        
        -- ==================================
        -- 2. PAUSAR TODOS LOS REPARTIDORES
        -- ==================================
        FOR delivery_record IN
            SELECT dp.delivery_person_id, dp.is_available, dp.availability_status
            FROM delivery_performance dp
            JOIN users u ON dp.delivery_person_id = u.id
            WHERE u.role = 'delivery' AND u.is_active = true
        LOOP
            -- Guardar estado original
            INSERT INTO maintenance_affected_entities (
                maintenance_session_id, entity_type, entity_id,
                original_status, maintenance_status
            ) VALUES (
                maintenance_session_id_val, 'delivery', delivery_record.delivery_person_id,
                delivery_record.availability_status, 'maintenance_paused'
            );
            
            -- Pausar repartidor
            UPDATE delivery_performance 
            SET 
                is_available = false,
                availability_status = 'maintenance',
                updated_at = NOW()
            WHERE delivery_person_id = delivery_record.delivery_person_id;
            
            delivery_count := delivery_count + 1;
        END LOOP;
        
        -- ==================================
        -- 3. BLOQUEAR USUARIOS REGULARES
        -- ==================================
        FOR user_record IN
            SELECT id, is_active 
            FROM users 
            WHERE role = 'customer' AND is_active = true
        LOOP
            -- Guardar estado original
            INSERT INTO maintenance_affected_entities (
                maintenance_session_id, entity_type, entity_id,
                original_status, maintenance_status
            ) VALUES (
                maintenance_session_id_val, 'user', user_record.id,
                'active', 'maintenance_blocked'
            );
            
            -- Bloquear usuario temporalmente
            UPDATE users 
            SET 
                is_active = false,
                updated_at = NOW()
            WHERE id = user_record.id;
            
            users_count := users_count + 1;
        END LOOP;
        
        -- ==================================
        -- 4. PAUSAR NOTIFICACIONES NO CRÍTICAS
        -- ==================================
        UPDATE notifications_queue 
        SET 
            status = 'maintenance_paused',
            updated_at = NOW()
        WHERE status = 'pending' 
          AND priority NOT IN ('critical', 'urgent');
        
        GET DIAGNOSTICS notifications_count = ROW_COUNT;
        
        -- Registrar notificaciones pausadas
        INSERT INTO maintenance_affected_entities (
            maintenance_session_id, entity_type, entity_identifier,
            original_status, maintenance_status
        ) VALUES (
            maintenance_session_id_val, 'notification', 'non_critical_notifications',
            'pending', 'maintenance_paused'
        );
        
        -- ==================================
        -- 5. DESHABILITAR TRIGGERS AUTOMÁTICOS
        -- ==================================
        -- Deshabilitar triggers no críticos durante mantenimiento
        PERFORM manage_triggers('disable', 'trigger_auto_assign%');
        PERFORM manage_triggers('disable', 'trigger_metrics%');
        PERFORM manage_triggers('disable', 'trigger_cleanup%');
        
        jobs_count := 3; -- Aproximado de jobs pausados
        
        -- Registrar jobs pausados
        INSERT INTO maintenance_affected_entities (
            maintenance_session_id, entity_type, entity_identifier,
            original_status, maintenance_status
        ) VALUES 
        (maintenance_session_id_val, 'job', 'auto_assignment_triggers', 'enabled', 'disabled'),
        (maintenance_session_id_val, 'job', 'metrics_triggers', 'enabled', 'disabled'),
        (maintenance_session_id_val, 'job', 'cleanup_triggers', 'enabled', 'disabled');
        
        -- ==================================
        -- 6. LOG CRÍTICO DEL MANTENIMIENTO
        -- ==================================
        INSERT INTO system_logs (level, message, details) VALUES (
            'CRITICAL',
            'MODO MANTENIMIENTO ACTIVADO - SISTEMA COMPLETAMENTE PAUSADO',
            jsonb_build_object(
                'maintenance_session_id', maintenance_session_id_val,
                'activated_by', activated_by_param,
                'reason', reason_param,
                'estimated_duration_minutes', estimated_duration_param,
                'vendors_blocked', vendors_count,
                'delivery_paused', delivery_count,
                'users_blocked', users_count,
                'notifications_paused', notifications_count,
                'jobs_paused', jobs_count,
                'timestamp', NOW()
            )
        );
        
        final_message := format(
            'MANTENIMIENTO ACTIVADO: %s vendedores, %s repartidores, %s usuarios bloqueados. %s notificaciones y %s jobs pausados.',
            vendors_count, delivery_count, users_count, notifications_count, jobs_count
        );
        
        RETURN QUERY SELECT 
            true, 
            final_message,
            maintenance_session_id_val,
            vendors_count,
            delivery_count,
            users_count,
            jobs_count,
            notifications_count;
            
    EXCEPTION WHEN OTHERS THEN
        -- Rollback en caso de error
        UPDATE system_maintenance_status 
        SET is_maintenance_active = false;
        
        INSERT INTO system_logs (level, message, details) VALUES (
            'ERROR',
            'FALLO AL ACTIVAR MANTENIMIENTO',
            jsonb_build_object(
                'error', SQLERRM,
                'sqlstate', SQLSTATE,
                'attempted_by', activated_by_param
            )
        );
        
        RETURN QUERY SELECT 
            false, 
            'Error al activar mantenimiento: ' || SQLERRM,
            NULL::UUID, 0, 0, 0, 0, 0;
    END;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 4. FUNCIÓN: Desactivar modo mantenimiento y restaurar todo
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION deactivate_total_maintenance_mode(
    deactivated_by_param UUID
) RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    vendors_restored INTEGER,
    delivery_restored INTEGER,
    users_restored INTEGER,
    jobs_restored INTEGER,
    notifications_restored INTEGER
) AS $$
DECLARE
    maintenance_session_id_val UUID;
    vendors_count INTEGER := 0;
    delivery_count INTEGER := 0;
    users_count INTEGER := 0;
    jobs_count INTEGER := 0;
    notifications_count INTEGER := 0;
    entity_record RECORD;
    final_message TEXT;
BEGIN
    -- Verificar si está en mantenimiento
    SELECT activated_at::TEXT INTO maintenance_session_id_val::TEXT
    FROM system_maintenance_status 
    WHERE is_maintenance_active = true;
    
    IF maintenance_session_id_val IS NULL THEN
        RETURN QUERY SELECT 
            false, 
            'El sistema no está en modo mantenimiento'::TEXT,
            0, 0, 0, 0, 0;
        RETURN;
    END IF;
    
    BEGIN
        -- ==================================
        -- 1. RESTAURAR TODOS LOS VENDEDORES
        -- ==================================
        FOR entity_record IN
            SELECT entity_id
            FROM maintenance_affected_entities 
            WHERE entity_type = 'vendor' AND is_restored = false
        LOOP
            UPDATE users 
            SET 
                is_active = true,
                updated_at = NOW()
            WHERE id = entity_record.entity_id;
            
            UPDATE maintenance_affected_entities
            SET 
                is_restored = true,
                restored_at = NOW()
            WHERE entity_id = entity_record.entity_id AND entity_type = 'vendor';
            
            vendors_count := vendors_count + 1;
        END LOOP;
        
        -- ==================================
        -- 2. RESTAURAR TODOS LOS REPARTIDORES
        -- ==================================
        FOR entity_record IN
            SELECT entity_id, original_status
            FROM maintenance_affected_entities 
            WHERE entity_type = 'delivery' AND is_restored = false
        LOOP
            UPDATE delivery_performance 
            SET 
                is_available = true,
                availability_status = COALESCE(entity_record.original_status, 'available'),
                updated_at = NOW()
            WHERE delivery_person_id = entity_record.entity_id;
            
            UPDATE maintenance_affected_entities
            SET 
                is_restored = true,
                restored_at = NOW()
            WHERE entity_id = entity_record.entity_id AND entity_type = 'delivery';
            
            delivery_count := delivery_count + 1;
        END LOOP;
        
        -- ==================================
        -- 3. RESTAURAR USUARIOS REGULARES
        -- ==================================
        FOR entity_record IN
            SELECT entity_id
            FROM maintenance_affected_entities 
            WHERE entity_type = 'user' AND is_restored = false
        LOOP
            UPDATE users 
            SET 
                is_active = true,
                updated_at = NOW()
            WHERE id = entity_record.entity_id;
            
            UPDATE maintenance_affected_entities
            SET 
                is_restored = true,
                restored_at = NOW()
            WHERE entity_id = entity_record.entity_id AND entity_type = 'user';
            
            users_count := users_count + 1;
        END LOOP;
        
        -- ==================================
        -- 4. RESTAURAR NOTIFICACIONES
        -- ==================================
        UPDATE notifications_queue 
        SET 
            status = 'pending',
            updated_at = NOW()
        WHERE status = 'maintenance_paused';
        
        GET DIAGNOSTICS notifications_count = ROW_COUNT;
        
        -- ==================================
        -- 5. REACTIVAR TRIGGERS Y JOBS
        -- ==================================
        PERFORM manage_triggers('enable', 'trigger_auto_assign%');
        PERFORM manage_triggers('enable', 'trigger_metrics%');
        PERFORM manage_triggers('enable', 'trigger_cleanup%');
        
        jobs_count := 3;
        
        -- Marcar jobs como restaurados
        UPDATE maintenance_affected_entities
        SET 
            is_restored = true,
            restored_at = NOW()
        WHERE entity_type = 'job' AND is_restored = false;
        
        -- ==================================
        -- 6. DESACTIVAR MODO MANTENIMIENTO
        -- ==================================
        UPDATE system_maintenance_status 
        SET 
            is_maintenance_active = false,
            deactivated_by = deactivated_by_param,
            deactivated_at = NOW(),
            updated_at = NOW();
        
        -- ==================================
        -- 7. LOG CRÍTICO DE RESTAURACIÓN
        -- ==================================
        INSERT INTO system_logs (level, message, details) VALUES (
            'CRITICAL',
            'MODO MANTENIMIENTO DESACTIVADO - SISTEMA COMPLETAMENTE RESTAURADO',
            jsonb_build_object(
                'deactivated_by', deactivated_by_param,
                'vendors_restored', vendors_count,
                'delivery_restored', delivery_count,
                'users_restored', users_count,
                'notifications_restored', notifications_count,
                'jobs_restored', jobs_count,
                'timestamp', NOW()
            )
        );
        
        final_message := format(
            'MANTENIMIENTO DESACTIVADO: %s vendedores, %s repartidores, %s usuarios restaurados. %s notificaciones y %s jobs reactivados.',
            vendors_count, delivery_count, users_count, notifications_count, jobs_count
        );
        
        RETURN QUERY SELECT 
            true, 
            final_message,
            vendors_count,
            delivery_count,
            users_count,
            jobs_count,
            notifications_count;
            
    EXCEPTION WHEN OTHERS THEN
        INSERT INTO system_logs (level, message, details) VALUES (
            'ERROR',
            'FALLO AL DESACTIVAR MANTENIMIENTO',
            jsonb_build_object(
                'error', SQLERRM,
                'sqlstate', SQLSTATE,
                'attempted_by', deactivated_by_param
            )
        );
        
        RETURN QUERY SELECT 
            false, 
            'Error al desactivar mantenimiento: ' || SQLERRM,
            0, 0, 0, 0, 0;
    END;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 5. FUNCIÓN: Verificar estado de mantenimiento
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_maintenance_status() 
RETURNS TABLE (
    is_active BOOLEAN,
    activated_by VARCHAR(255),
    activated_at TIMESTAMP,
    maintenance_reason TEXT,
    estimated_duration_minutes INTEGER,
    maintenance_message TEXT,
    affected_services TEXT[],
    entities_blocked INTEGER,
    time_since_activation INTERVAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sms.is_maintenance_active,
        u.full_name as activated_by,
        sms.activated_at,
        sms.maintenance_reason,
        sms.estimated_duration_minutes,
        sms.maintenance_message,
        sms.affected_services,
        (SELECT COUNT(*)::INTEGER FROM maintenance_affected_entities WHERE is_restored = false) as entities_blocked,
        CASE 
            WHEN sms.is_maintenance_active THEN NOW() - sms.activated_at
            ELSE NULL
        END as time_since_activation
    FROM system_maintenance_status sms
    LEFT JOIN users u ON sms.activated_by = u.id
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 6. TRIGGER: Bloquear acciones durante mantenimiento
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION trigger_block_during_maintenance() 
RETURNS TRIGGER AS $$
DECLARE
    is_maintenance_active_val BOOLEAN;
    maintenance_msg TEXT;
BEGIN
    -- Verificar si está en mantenimiento
    SELECT is_maintenance_active, maintenance_message 
    INTO is_maintenance_active_val, maintenance_msg
    FROM system_maintenance_status;
    
    -- Si está en mantenimiento, bloquear operaciones críticas
    IF is_maintenance_active_val = true THEN
        CASE TG_TABLE_NAME
            WHEN 'orders' THEN
                IF TG_OP = 'INSERT' THEN
                    RAISE EXCEPTION 'SISTEMA EN MANTENIMIENTO: No se pueden crear nuevos pedidos. %', maintenance_msg;
                END IF;
            WHEN 'users' THEN
                IF TG_OP = 'INSERT' THEN
                    RAISE EXCEPTION 'SISTEMA EN MANTENIMIENTO: No se pueden registrar nuevos usuarios. %', maintenance_msg;
                END IF;
            WHEN 'store_products' THEN
                IF TG_OP IN ('INSERT', 'UPDATE') THEN
                    RAISE EXCEPTION 'SISTEMA EN MANTENIMIENTO: No se pueden modificar productos. %', maintenance_msg;
                END IF;
        END CASE;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger de bloqueo
CREATE TRIGGER trigger_maintenance_block_orders
    BEFORE INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trigger_block_during_maintenance();

CREATE TRIGGER trigger_maintenance_block_users
    BEFORE INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION trigger_block_during_maintenance();

CREATE TRIGGER trigger_maintenance_block_products
    BEFORE INSERT OR UPDATE ON store_products
    FOR EACH ROW
    EXECUTE FUNCTION trigger_block_during_maintenance();

-- -----------------------------------------------------
-- 7. VISTA: Dashboard de mantenimiento
-- -----------------------------------------------------
CREATE OR REPLACE VIEW maintenance_dashboard AS
SELECT 
    sms.is_maintenance_active,
    sms.activated_at,
    sms.maintenance_reason,
    sms.estimated_duration_minutes,
    EXTRACT(EPOCH FROM (NOW() - sms.activated_at)) / 60 as minutes_since_activation,
    u.full_name as activated_by_name,
    COUNT(DISTINCT CASE WHEN mae.entity_type = 'vendor' AND mae.is_restored = false THEN mae.entity_id END) as vendors_blocked,
    COUNT(DISTINCT CASE WHEN mae.entity_type = 'delivery' AND mae.is_restored = false THEN mae.entity_id END) as delivery_blocked,
    COUNT(DISTINCT CASE WHEN mae.entity_type = 'user' AND mae.is_restored = false THEN mae.entity_id END) as users_blocked,
    COUNT(DISTINCT CASE WHEN mae.entity_type = 'notification' AND mae.is_restored = false THEN mae.id END) as notifications_paused,
    COUNT(DISTINCT CASE WHEN mae.entity_type = 'job' AND mae.is_restored = false THEN mae.id END) as jobs_paused
FROM system_maintenance_status sms
LEFT JOIN users u ON sms.activated_by = u.id
LEFT JOIN maintenance_affected_entities mae ON true
GROUP BY sms.id, sms.is_maintenance_active, sms.activated_at, sms.maintenance_reason, 
         sms.estimated_duration_minutes, u.full_name;

-- -----------------------------------------------------
-- ✅ SISTEMA DE MANTENIMIENTO TOTAL COMPLETADO
-- -----------------------------------------------------
-- Funcionalidades implementadas:
-- ✅ Activación total de mantenimiento desde panel admin
-- ✅ Bloqueo automático de TODOS los vendedores
-- ✅ Pausa automática de TODOS los repartidores  
-- ✅ Bloqueo automático de TODOS los usuarios
-- ✅ Pausa de notificaciones no críticas
-- ✅ Deshabilitación de triggers automáticos
-- ✅ Restauración completa al desactivar
-- ✅ Triggers que bloquean acciones durante mantenimiento
-- ✅ Logs detallados de todo el proceso
-- ✅ Dashboard de monitoreo en tiempo real



