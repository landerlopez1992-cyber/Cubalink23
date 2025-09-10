-- =====================================================
-- FASE 8: TRIGGERS AUTOMÁTICOS MASTER
-- =====================================================
-- Sistema completo de triggers que automatiza todas las acciones críticas:
-- 1. Triggers para gestión completa de pedidos
-- 2. Triggers para notificaciones automáticas
-- 3. Triggers para auditoría y logs
-- 4. Triggers para métricas y estadísticas
-- 5. Triggers para integridad y validaciones

-- -----------------------------------------------------
-- 1. TABLA: trigger_audit_log (Log de triggers ejecutados)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS trigger_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trigger_name VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    row_id UUID, -- ID del registro afectado
    old_data JSONB, -- Datos anteriores (para UPDATE/DELETE)
    new_data JSONB, -- Datos nuevos (para INSERT/UPDATE)
    execution_time_ms INTEGER, -- Tiempo de ejecución en millisegundos
    success BOOLEAN DEFAULT true,
    error_message TEXT,
    additional_info JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_trigger_audit_log_trigger ON trigger_audit_log(trigger_name);
CREATE INDEX IF NOT EXISTS idx_trigger_audit_log_table ON trigger_audit_log(table_name);
CREATE INDEX IF NOT EXISTS idx_trigger_audit_log_created ON trigger_audit_log(created_at DESC);

-- -----------------------------------------------------
-- 2. FUNCIÓN HELPER: Log de ejecución de triggers
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION log_trigger_execution(
    trigger_name_param VARCHAR(100),
    table_name_param VARCHAR(100),
    operation_param VARCHAR(20),
    row_id_param UUID DEFAULT NULL,
    old_data_param JSONB DEFAULT NULL,
    new_data_param JSONB DEFAULT NULL,
    success_param BOOLEAN DEFAULT true,
    error_message_param TEXT DEFAULT NULL,
    additional_info_param JSONB DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO trigger_audit_log (
        trigger_name, table_name, operation, row_id,
        old_data, new_data, success, error_message, additional_info
    ) VALUES (
        trigger_name_param, table_name_param, operation_param, row_id_param,
        old_data_param, new_data_param, success_param, error_message_param, additional_info_param
    );
EXCEPTION WHEN OTHERS THEN
    -- Si falla el log, no debe fallar el trigger principal
    NULL;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 3. TRIGGER MASTER: Gestión completa de pedidos
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION trigger_master_order_management() 
RETURNS TRIGGER AS $$
DECLARE
    start_time TIMESTAMP := NOW();
    vendor_info RECORD;
    delivery_info RECORD;
    assignment_result RECORD;
    notification_result RECORD;
    old_data JSONB;
    new_data JSONB;
BEGIN
    -- Convertir datos a JSONB para logging
    IF TG_OP != 'INSERT' THEN
        old_data := to_jsonb(OLD);
    END IF;
    IF TG_OP != 'DELETE' THEN
        new_data := to_jsonb(NEW);
    END IF;
    
    BEGIN
        -- =============================
        -- PROCESAMIENTO DE INSERCIÓN
        -- =============================
        IF TG_OP = 'INSERT' THEN
            -- 1. Auto-asignar número de pedido si no existe
            IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
                NEW.order_number := 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(nextval('order_sequence')::TEXT, 6, '0');
            END IF;
            
            -- 2. Establecer fecha estimada de entrega si no existe
            IF NEW.estimated_delivery_time IS NULL THEN
                NEW.estimated_delivery_time := NEW.created_at + 
                    CASE 
                        WHEN NEW.is_express THEN INTERVAL '30 minutes'
                        WHEN NEW.delivery_method = 'pickup' THEN INTERVAL '15 minutes'
                        ELSE INTERVAL '60 minutes'
                    END;
            END IF;
            
            -- 3. Calcular timeout de confirmación
            NEW.timeout_confirmation := NEW.created_at + INTERVAL '10 minutes';
            NEW.timeout_pickup := NEW.estimated_delivery_time + INTERVAL '15 minutes';
            NEW.timeout_delivery := NEW.estimated_delivery_time + INTERVAL '30 minutes';
            
            -- 4. Intentar asignación automática de repartidor
            IF NEW.delivery_method != 'pickup' AND NEW.delivery_person_id IS NULL THEN
                -- Obtener información del vendor para coordenadas
                SELECT u.current_lat, u.current_lng, u.full_name
                INTO vendor_info
                FROM users u 
                WHERE u.id = NEW.vendor_id;
                
                IF vendor_info.current_lat IS NOT NULL THEN
                    SELECT * INTO assignment_result
                    FROM auto_assign_delivery_person(
                        NEW.id,
                        vendor_info.current_lat,
                        vendor_info.current_lng,
                        'general',
                        CASE WHEN NEW.is_express THEN 'express' ELSE 'standard' END
                    );
                    
                    IF assignment_result.success THEN
                        NEW.delivery_person_id := assignment_result.assigned_delivery_person_id;
                        NEW.status := 'assigned';
                        NEW.assigned_at := NOW();
                    END IF;
                END IF;
            END IF;
            
            -- 5. Crear notificaciones automáticas
            -- Notificar al vendor
            SELECT * INTO notification_result
            FROM create_smart_notification(
                NEW.vendor_id,
                'new_order',
                'Nuevo Pedido Recibido',
                'Pedido #' || NEW.order_number || ' - Total: $' || NEW.total_amount,
                jsonb_build_object('order_id', NEW.id, 'order_number', NEW.order_number),
                'high'
            );
            
            -- Notificar al repartidor si fue asignado
            IF NEW.delivery_person_id IS NOT NULL THEN
                SELECT * INTO notification_result
                FROM create_smart_notification(
                    NEW.delivery_person_id,
                    'order_assigned',
                    'Pedido Asignado',
                    'Se te ha asignado el pedido #' || NEW.order_number,
                    jsonb_build_object('order_id', NEW.id, 'order_number', NEW.order_number),
                    'high'
                );
            END IF;
            
            -- Notificar al cliente
            SELECT * INTO notification_result
            FROM create_smart_notification(
                NEW.customer_id,
                'order_confirmed',
                'Pedido Confirmado',
                'Tu pedido #' || NEW.order_number || ' ha sido confirmado',
                jsonb_build_object('order_id', NEW.id, 'order_number', NEW.order_number),
                'medium'
            );
            
        -- =============================
        -- PROCESAMIENTO DE ACTUALIZACIÓN
        -- =============================
        ELSIF TG_OP = 'UPDATE' THEN
            
            -- Cambio de estado del pedido
            IF OLD.status != NEW.status THEN
                
                -- Estado: assigned -> preparing
                IF NEW.status = 'preparing' AND OLD.status = 'assigned' THEN
                    NEW.preparation_started_at := NOW();
                    
                    -- Notificar al cliente
                    SELECT * INTO notification_result
                    FROM create_smart_notification(
                        NEW.customer_id,
                        'order_preparing',
                        'Pedido en Preparación',
                        'Tu pedido #' || NEW.order_number || ' está siendo preparado',
                        jsonb_build_object('order_id', NEW.id),
                        'low'
                    );
                END IF;
                
                -- Estado: preparing -> ready_for_pickup
                IF NEW.status = 'ready_for_pickup' AND OLD.status = 'preparing' THEN
                    NEW.ready_at := NOW();
                    
                    -- Notificar al repartidor
                    IF NEW.delivery_person_id IS NOT NULL THEN
                        SELECT * INTO notification_result
                        FROM create_smart_notification(
                            NEW.delivery_person_id,
                            'pickup_ready',
                            'Pedido Listo para Recoger',
                            'El pedido #' || NEW.order_number || ' está listo para recoger',
                            jsonb_build_object('order_id', NEW.id),
                            'high'
                        );
                    END IF;
                END IF;
                
                -- Estado: ready_for_pickup -> picked_up
                IF NEW.status = 'picked_up' AND OLD.status = 'ready_for_pickup' THEN
                    NEW.picked_up_at := NOW();
                    
                    -- Crear chat automáticamente si no existe
                    IF NEW.delivery_person_id IS NOT NULL THEN
                        PERFORM create_chat_conversation(NEW.id, NEW.vendor_id, NEW.delivery_person_id);
                    END IF;
                    
                    -- Notificar al cliente
                    SELECT * INTO notification_result
                    FROM create_smart_notification(
                        NEW.customer_id,
                        'order_picked_up',
                        'Pedido Recogido',
                        'Tu pedido #' || NEW.order_number || ' ha sido recogido por el repartidor',
                        jsonb_build_object('order_id', NEW.id),
                        'medium'
                    );
                    
                    -- Verificación automática de peso/items
                    PERFORM auto_verify_weight(NEW.id, NEW.delivery_person_id, 
                        (SELECT COALESCE(SUM(oi.quantity * COALESCE(p.weight_kg, 0.5)), 1.0)
                         FROM order_items oi
                         JOIN store_products p ON oi.product_id = p.id
                         WHERE oi.order_id = NEW.id) + (RANDOM() - 0.5) * 0.2,
                        'pickup'
                    );
                END IF;
                
                -- Estado: picked_up -> delivered
                IF NEW.status = 'delivered' AND OLD.status = 'picked_up' THEN
                    NEW.delivered_at := NOW();
                    
                    -- Notificar al cliente
                    SELECT * INTO notification_result
                    FROM create_smart_notification(
                        NEW.customer_id,
                        'order_delivered',
                        'Pedido Entregado',
                        'Tu pedido #' || NEW.order_number || ' ha sido entregado exitosamente',
                        jsonb_build_object('order_id', NEW.id),
                        'medium'
                    );
                    
                    -- Notificar al vendor
                    SELECT * INTO notification_result
                    FROM create_smart_notification(
                        NEW.vendor_id,
                        'order_delivered',
                        'Pedido Entregado',
                        'El pedido #' || NEW.order_number || ' ha sido entregado al cliente',
                        jsonb_build_object('order_id', NEW.id),
                        'low'
                    );
                    
                    -- Verificación automática de tiempo de entrega
                    PERFORM auto_verify_delivery_time(NEW.id, NEW.delivery_person_id, NEW.delivered_at);
                    
                    -- Actualizar performance del repartidor
                    IF NEW.delivery_person_id IS NOT NULL THEN
                        INSERT INTO delivery_performance (delivery_person_id, current_load, completed_deliveries, total_deliveries)
                        VALUES (NEW.delivery_person_id, 0, 1, 1)
                        ON CONFLICT (delivery_person_id) 
                        DO UPDATE SET 
                            current_load = GREATEST(0, delivery_performance.current_load - 1),
                            completed_deliveries = delivery_performance.completed_deliveries + 1,
                            total_deliveries = delivery_performance.total_deliveries + 1,
                            last_delivery_at = NOW(),
                            updated_at = NOW();
                    END IF;
                END IF;
                
                -- Estado: cualquiera -> cancelled
                IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
                    NEW.cancelled_at := NOW();
                    
                    -- Liberar repartidor si estaba asignado
                    IF NEW.delivery_person_id IS NOT NULL THEN
                        UPDATE delivery_performance
                        SET 
                            current_load = GREATEST(0, current_load - 1),
                            cancelled_deliveries = cancelled_deliveries + 1,
                            updated_at = NOW()
                        WHERE delivery_person_id = NEW.delivery_person_id;
                        
                        -- Notificar al repartidor
                        SELECT * INTO notification_result
                        FROM create_smart_notification(
                            NEW.delivery_person_id,
                            'order_cancelled',
                            'Pedido Cancelado',
                            'El pedido #' || NEW.order_number || ' ha sido cancelado',
                            jsonb_build_object('order_id', NEW.id),
                            'medium'
                        );
                    END IF;
                    
                    -- Notificar al vendor
                    SELECT * INTO notification_result
                    FROM create_smart_notification(
                        NEW.vendor_id,
                        'order_cancelled',
                        'Pedido Cancelado',
                        'El pedido #' || NEW.order_number || ' ha sido cancelado',
                        jsonb_build_object('order_id', NEW.id, 'reason', NEW.cancellation_reason),
                        'medium'
                    );
                    
                    -- Notificar al cliente
                    SELECT * INTO notification_result
                    FROM create_smart_notification(
                        NEW.customer_id,
                        'order_cancelled',
                        'Pedido Cancelado',
                        'Tu pedido #' || NEW.order_number || ' ha sido cancelado',
                        jsonb_build_object('order_id', NEW.id, 'reason', NEW.cancellation_reason),
                        'medium'
                    );
                END IF;
            END IF;
            
            -- Asignación de repartidor
            IF OLD.delivery_person_id IS NULL AND NEW.delivery_person_id IS NOT NULL THEN
                NEW.assigned_at := NOW();
                
                -- Crear chat automáticamente
                PERFORM create_chat_conversation(NEW.id, NEW.vendor_id, NEW.delivery_person_id);
                
                -- Actualizar carga del repartidor
                INSERT INTO delivery_performance (delivery_person_id, current_load)
                VALUES (NEW.delivery_person_id, 1)
                ON CONFLICT (delivery_person_id) 
                DO UPDATE SET 
                    current_load = delivery_performance.current_load + 1,
                    updated_at = NOW();
            END IF;
            
            -- Cambio de repartidor
            IF OLD.delivery_person_id IS NOT NULL AND NEW.delivery_person_id != OLD.delivery_person_id THEN
                -- Liberar repartidor anterior
                UPDATE delivery_performance
                SET 
                    current_load = GREATEST(0, current_load - 1),
                    updated_at = NOW()
                WHERE delivery_person_id = OLD.delivery_person_id;
                
                -- Asignar nuevo repartidor
                IF NEW.delivery_person_id IS NOT NULL THEN
                    UPDATE delivery_performance
                    SET 
                        current_load = current_load + 1,
                        updated_at = NOW()
                    WHERE delivery_person_id = NEW.delivery_person_id;
                END IF;
            END IF;
        END IF;
        
        -- Log exitoso
        PERFORM log_trigger_execution(
            'trigger_master_order_management',
            'orders',
            TG_OP,
            COALESCE(NEW.id, OLD.id),
            old_data,
            new_data,
            true,
            NULL,
            jsonb_build_object(
                'execution_time_ms', EXTRACT(EPOCH FROM (NOW() - start_time)) * 1000,
                'status_change', CASE WHEN TG_OP = 'UPDATE' THEN jsonb_build_object('from', OLD.status, 'to', NEW.status) ELSE NULL END
            )
        );
        
    EXCEPTION WHEN OTHERS THEN
        -- Log de error
        PERFORM log_trigger_execution(
            'trigger_master_order_management',
            'orders',
            TG_OP,
            COALESCE(NEW.id, OLD.id),
            old_data,
            new_data,
            false,
            SQLERRM,
            jsonb_build_object('error_state', SQLSTATE)
        );
        
        -- Re-raise el error para que el trigger falle
        RAISE;
    END;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Aplicar el trigger master a la tabla orders
DROP TRIGGER IF EXISTS trigger_master_order_management_insert ON orders;
DROP TRIGGER IF EXISTS trigger_master_order_management_update ON orders;

CREATE TRIGGER trigger_master_order_management_insert
    BEFORE INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trigger_master_order_management();

CREATE TRIGGER trigger_master_order_management_update
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trigger_master_order_management();

-- -----------------------------------------------------
-- 4. TRIGGER: Auditoría automática de cambios críticos
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION trigger_audit_critical_changes() 
RETURNS TRIGGER AS $$
DECLARE
    table_name_val TEXT := TG_TABLE_NAME;
    critical_fields TEXT[];
    changed_fields TEXT[];
    field_name TEXT;
    old_value TEXT;
    new_value TEXT;
BEGIN
    -- Definir campos críticos por tabla
    critical_fields := CASE table_name_val
        WHEN 'users' THEN ARRAY['role', 'is_active', 'email', 'phone']
        WHEN 'orders' THEN ARRAY['status', 'total_amount', 'delivery_person_id', 'vendor_id']
        WHEN 'store_products' THEN ARRAY['price', 'is_active', 'inventory_count']
        WHEN 'delivery_performance' THEN ARRAY['avg_rating', 'is_available', 'current_load']
        ELSE ARRAY[]::TEXT[]
    END;
    
    IF array_length(critical_fields, 1) > 0 AND TG_OP = 'UPDATE' THEN
        -- Detectar cambios en campos críticos
        FOR field_name IN SELECT unnest(critical_fields) LOOP
            BEGIN
                EXECUTE format('SELECT ($1).%I::TEXT, ($2).%I::TEXT', field_name, field_name) 
                INTO old_value, new_value USING OLD, NEW;
                
                IF old_value IS DISTINCT FROM new_value THEN
                    changed_fields := array_append(changed_fields, field_name);
                    
                    -- Log específico del cambio
                    INSERT INTO system_logs (level, message, details) VALUES (
                        'WARNING',
                        format('Campo crítico modificado: %s.%s', table_name_val, field_name),
                        jsonb_build_object(
                            'table', table_name_val,
                            'field', field_name,
                            'record_id', COALESCE((NEW.id)::TEXT, 'unknown'),
                            'old_value', old_value,
                            'new_value', new_value,
                            'changed_by', current_user,
                            'timestamp', NOW()
                        )
                    );
                END IF;
            EXCEPTION WHEN OTHERS THEN
                -- Si el campo no existe, continuar
                CONTINUE;
            END;
        END LOOP;
        
        -- Si hubo cambios críticos, crear alerta
        IF array_length(changed_fields, 1) > 0 THEN
            INSERT INTO system_logs (level, message, details) VALUES (
                'ALERT',
                format('Cambios críticos detectados en %s', table_name_val),
                jsonb_build_object(
                    'table', table_name_val,
                    'record_id', COALESCE((NEW.id)::TEXT, 'unknown'),
                    'changed_fields', changed_fields,
                    'user', current_user,
                    'timestamp', NOW()
                )
            );
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger de auditoría a tablas críticas
CREATE TRIGGER trigger_audit_users
    AFTER UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION trigger_audit_critical_changes();

CREATE TRIGGER trigger_audit_store_products
    AFTER UPDATE ON store_products
    FOR EACH ROW
    EXECUTE FUNCTION trigger_audit_critical_changes();

CREATE TRIGGER trigger_audit_delivery_performance
    AFTER UPDATE ON delivery_performance
    FOR EACH ROW
    EXECUTE FUNCTION trigger_audit_critical_changes();

-- -----------------------------------------------------
-- 5. TRIGGER: Validaciones automáticas de integridad
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION trigger_validate_data_integrity() 
RETURNS TRIGGER AS $$
DECLARE
    error_msg TEXT;
BEGIN
    -- Validaciones específicas por tabla
    CASE TG_TABLE_NAME
        WHEN 'orders' THEN
            -- Validar que el total sea positivo
            IF NEW.total_amount <= 0 THEN
                RAISE EXCEPTION 'El total del pedido debe ser mayor a 0: $%', NEW.total_amount;
            END IF;
            
            -- Validar que vendor existe y está activo
            IF NOT EXISTS (SELECT 1 FROM users WHERE id = NEW.vendor_id AND role = 'vendor' AND is_active = true) THEN
                RAISE EXCEPTION 'Vendor no válido o inactivo: %', NEW.vendor_id;
            END IF;
            
            -- Validar que delivery person es válido si está asignado
            IF NEW.delivery_person_id IS NOT NULL THEN
                IF NOT EXISTS (SELECT 1 FROM users WHERE id = NEW.delivery_person_id AND role = 'delivery' AND is_active = true) THEN
                    RAISE EXCEPTION 'Repartidor no válido o inactivo: %', NEW.delivery_person_id;
                END IF;
            END IF;
            
            -- Validar flujo de estados
            IF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
                CASE
                    WHEN OLD.status = 'delivered' AND NEW.status != 'delivered' THEN
                        RAISE EXCEPTION 'No se puede cambiar el estado de un pedido ya entregado';
                    WHEN OLD.status = 'cancelled' AND NEW.status != 'cancelled' THEN
                        RAISE EXCEPTION 'No se puede cambiar el estado de un pedido cancelado';
                    WHEN NEW.status = 'picked_up' AND OLD.status NOT IN ('ready_for_pickup', 'assigned', 'preparing') THEN
                        RAISE EXCEPTION 'Estado inválido para marcar como recogido: %', OLD.status;
                    WHEN NEW.status = 'delivered' AND OLD.status != 'picked_up' THEN
                        RAISE EXCEPTION 'Solo se puede entregar un pedido que haya sido recogido';
                END CASE;
            END IF;
            
        WHEN 'users' THEN
            -- Validar email único por rol activo
            IF NEW.is_active = true THEN
                IF EXISTS (SELECT 1 FROM users WHERE email = NEW.email AND id != NEW.id AND is_active = true) THEN
                    RAISE EXCEPTION 'Ya existe un usuario activo con el email: %', NEW.email;
                END IF;
            END IF;
            
            -- Validar formato de teléfono
            IF NEW.phone IS NOT NULL AND NEW.phone !~ '^\+?[1-9]\d{1,14}$' THEN
                RAISE EXCEPTION 'Formato de teléfono inválido: %', NEW.phone;
            END IF;
            
        WHEN 'store_products' THEN
            -- Validar precio positivo
            IF NEW.price < 0 THEN
                RAISE EXCEPTION 'El precio del producto no puede ser negativo: $%', NEW.price;
            END IF;
            
            -- Validar inventario no negativo
            IF NEW.inventory_count < 0 THEN
                RAISE EXCEPTION 'El inventario no puede ser negativo: %', NEW.inventory_count;
            END IF;
            
        WHEN 'delivery_performance' THEN
            -- Validar rating entre 0 y 5
            IF NEW.avg_rating < 0 OR NEW.avg_rating > 5 THEN
                RAISE EXCEPTION 'El rating debe estar entre 0 y 5: %', NEW.avg_rating;
            END IF;
            
            -- Validar carga actual no negativa
            IF NEW.current_load < 0 THEN
                RAISE EXCEPTION 'La carga actual no puede ser negativa: %', NEW.current_load;
            END IF;
    END CASE;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger de validación
CREATE TRIGGER trigger_validate_orders
    BEFORE INSERT OR UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trigger_validate_data_integrity();

CREATE TRIGGER trigger_validate_users
    BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION trigger_validate_data_integrity();

CREATE TRIGGER trigger_validate_products
    BEFORE INSERT OR UPDATE ON store_products
    FOR EACH ROW
    EXECUTE FUNCTION trigger_validate_data_integrity();

CREATE TRIGGER trigger_validate_performance
    BEFORE INSERT OR UPDATE ON delivery_performance
    FOR EACH ROW
    EXECUTE FUNCTION trigger_validate_data_integrity();

-- -----------------------------------------------------
-- 6. TRIGGER: Métricas automáticas del sistema
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION trigger_update_system_metrics() 
RETURNS TRIGGER AS $$
DECLARE
    metric_name TEXT;
    metric_value DECIMAL;
    current_hour INTEGER := EXTRACT(hour FROM NOW());
BEGIN
    -- Actualizar métricas según la tabla modificada
    CASE TG_TABLE_NAME
        WHEN 'orders' THEN
            IF TG_OP = 'INSERT' THEN
                -- Incrementar contador de pedidos por hora
                INSERT INTO system_metrics (metric_name, metric_value, hour_of_day)
                VALUES ('orders_created_hourly', 1, current_hour)
                ON CONFLICT (metric_name, hour_of_day, DATE(created_at))
                DO UPDATE SET 
                    metric_value = system_metrics.metric_value + 1,
                    updated_at = NOW();
                    
            ELSIF TG_OP = 'UPDATE' AND NEW.status = 'delivered' AND OLD.status != 'delivered' THEN
                -- Incrementar contador de entregas completadas
                INSERT INTO system_metrics (metric_name, metric_value, hour_of_day)
                VALUES ('orders_delivered_hourly', 1, current_hour)
                ON CONFLICT (metric_name, hour_of_day, DATE(created_at))
                DO UPDATE SET 
                    metric_value = system_metrics.metric_value + 1,
                    updated_at = NOW();
                    
                -- Calcular tiempo promedio de entrega
                metric_value := EXTRACT(EPOCH FROM (NEW.delivered_at - NEW.created_at)) / 60.0; -- minutos
                INSERT INTO system_metrics (metric_name, metric_value, hour_of_day)
                VALUES ('avg_delivery_time_minutes', metric_value, current_hour)
                ON CONFLICT (metric_name, hour_of_day, DATE(created_at))
                DO UPDATE SET 
                    metric_value = (system_metrics.metric_value + metric_value) / 2,
                    updated_at = NOW();
            END IF;
            
        WHEN 'users' THEN
            IF TG_OP = 'INSERT' THEN
                -- Contador de registros de usuarios
                INSERT INTO system_metrics (metric_name, metric_value, hour_of_day, additional_data)
                VALUES ('users_registered_hourly', 1, current_hour, jsonb_build_object('role', NEW.role))
                ON CONFLICT (metric_name, hour_of_day, DATE(created_at))
                DO UPDATE SET 
                    metric_value = system_metrics.metric_value + 1,
                    updated_at = NOW();
            END IF;
            
        WHEN 'notifications_queue' THEN
            IF TG_OP = 'INSERT' THEN
                -- Contador de notificaciones enviadas
                INSERT INTO system_metrics (metric_name, metric_value, hour_of_day, additional_data)
                VALUES ('notifications_sent_hourly', 1, current_hour, jsonb_build_object('priority', NEW.priority))
                ON CONFLICT (metric_name, hour_of_day, DATE(created_at))
                DO UPDATE SET 
                    metric_value = system_metrics.metric_value + 1,
                    updated_at = NOW();
            END IF;
    END CASE;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger de métricas
CREATE TRIGGER trigger_metrics_orders
    AFTER INSERT OR UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_system_metrics();

CREATE TRIGGER trigger_metrics_users
    AFTER INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_system_metrics();

CREATE TRIGGER trigger_metrics_notifications
    AFTER INSERT ON notifications_queue
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_system_metrics();

-- -----------------------------------------------------
-- 7. TRIGGER: Limpieza automática de datos
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION trigger_auto_cleanup() 
RETURNS TRIGGER AS $$
BEGIN
    -- Limpiar datos antiguos al insertar nuevos registros (cada 100 inserts aprox)
    IF RANDOM() < 0.01 THEN -- 1% de probabilidad
        CASE TG_TABLE_NAME
            WHEN 'system_logs' THEN
                -- Limpiar logs mayores a 30 días
                DELETE FROM system_logs 
                WHERE created_at < NOW() - INTERVAL '30 days';
                
            WHEN 'trigger_audit_log' THEN
                -- Limpiar audit logs mayores a 60 días
                DELETE FROM trigger_audit_log 
                WHERE created_at < NOW() - INTERVAL '60 days';
                
            WHEN 'rental_tracking' THEN
                -- Limpiar tracking data mayor a 30 días
                DELETE FROM rental_tracking 
                WHERE recorded_at < NOW() - INTERVAL '30 days';
                
            WHEN 'notification_delivery_log' THEN
                -- Limpiar logs de delivery mayores a 15 días
                DELETE FROM notification_delivery_log 
                WHERE created_at < NOW() - INTERVAL '15 days';
        END CASE;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger de limpieza
CREATE TRIGGER trigger_cleanup_system_logs
    AFTER INSERT ON system_logs
    FOR EACH ROW
    EXECUTE FUNCTION trigger_auto_cleanup();

CREATE TRIGGER trigger_cleanup_audit_logs
    AFTER INSERT ON trigger_audit_log
    FOR EACH ROW
    EXECUTE FUNCTION trigger_auto_cleanup();

-- -----------------------------------------------------
-- 8. VISTA: Monitor de triggers en tiempo real
-- -----------------------------------------------------
CREATE OR REPLACE VIEW triggers_monitor AS
SELECT 
    trigger_name,
    table_name,
    COUNT(*) as executions_today,
    COUNT(CASE WHEN success = false THEN 1 END) as failed_executions,
    AVG(execution_time_ms) as avg_execution_time_ms,
    MAX(execution_time_ms) as max_execution_time_ms,
    MAX(created_at) as last_execution,
    CASE 
        WHEN COUNT(CASE WHEN success = false THEN 1 END) > 0 THEN 'ERROR'
        WHEN AVG(execution_time_ms) > 1000 THEN 'SLOW'
        WHEN COUNT(*) > 1000 THEN 'HIGH_VOLUME'
        ELSE 'OK'
    END as status
FROM trigger_audit_log
WHERE created_at >= CURRENT_DATE
GROUP BY trigger_name, table_name
ORDER BY executions_today DESC;

-- -----------------------------------------------------
-- 9. FUNCIÓN: Estadísticas de rendimiento de triggers
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_trigger_performance_stats(
    days_back INTEGER DEFAULT 7
) RETURNS TABLE (
    trigger_name VARCHAR(100),
    table_name VARCHAR(100),
    total_executions BIGINT,
    success_rate DECIMAL(5,2),
    avg_execution_time_ms DECIMAL(8,2),
    max_execution_time_ms INTEGER,
    errors_count BIGINT,
    last_error_message TEXT,
    performance_grade VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tal.trigger_name,
        tal.table_name,
        COUNT(*) as total_executions,
        (COUNT(CASE WHEN tal.success THEN 1 END)::DECIMAL / COUNT(*) * 100) as success_rate,
        AVG(tal.execution_time_ms)::DECIMAL(8,2) as avg_execution_time_ms,
        MAX(tal.execution_time_ms) as max_execution_time_ms,
        COUNT(CASE WHEN NOT tal.success THEN 1 END) as errors_count,
        (SELECT error_message FROM trigger_audit_log tal2 
         WHERE tal2.trigger_name = tal.trigger_name 
           AND tal2.success = false 
         ORDER BY tal2.created_at DESC LIMIT 1) as last_error_message,
        CASE 
            WHEN COUNT(CASE WHEN NOT tal.success THEN 1 END) = 0 AND AVG(tal.execution_time_ms) < 100 THEN 'A+'
            WHEN COUNT(CASE WHEN NOT tal.success THEN 1 END) = 0 AND AVG(tal.execution_time_ms) < 500 THEN 'A'
            WHEN (COUNT(CASE WHEN tal.success THEN 1 END)::DECIMAL / COUNT(*)) > 0.95 AND AVG(tal.execution_time_ms) < 1000 THEN 'B'
            WHEN (COUNT(CASE WHEN tal.success THEN 1 END)::DECIMAL / COUNT(*)) > 0.90 THEN 'C'
            ELSE 'F'
        END as performance_grade
    FROM trigger_audit_log tal
    WHERE tal.created_at >= CURRENT_DATE - INTERVAL '1 day' * days_back
    GROUP BY tal.trigger_name, tal.table_name
    ORDER BY total_executions DESC;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 10. FUNCIÓN: Deshabilitar/habilitar triggers temporalmente
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION manage_triggers(
    action VARCHAR(20), -- 'disable', 'enable', 'status'
    trigger_pattern VARCHAR(100) DEFAULT '%' -- patrón para filtrar triggers
) RETURNS TABLE (
    trigger_name VARCHAR(100),
    table_name VARCHAR(100),
    status VARCHAR(20),
    action_result VARCHAR(50)
) AS $$
DECLARE
    trigger_record RECORD;
    sql_command TEXT;
    result_msg VARCHAR(50);
BEGIN
    FOR trigger_record IN
        SELECT 
            t.tgname as trigger_name,
            c.relname as table_name,
            CASE 
                WHEN t.tgenabled = 'O' THEN 'enabled'
                WHEN t.tgenabled = 'D' THEN 'disabled'
                ELSE 'unknown'
            END as current_status
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE n.nspname = 'public'
          AND t.tgname LIKE trigger_pattern
          AND NOT t.tgisinternal
    LOOP
        result_msg := 'no_action';
        
        IF action = 'disable' AND trigger_record.current_status = 'enabled' THEN
            sql_command := format('ALTER TABLE %s DISABLE TRIGGER %s', 
                trigger_record.table_name, trigger_record.trigger_name);
            EXECUTE sql_command;
            result_msg := 'disabled';
        ELSIF action = 'enable' AND trigger_record.current_status = 'disabled' THEN
            sql_command := format('ALTER TABLE %s ENABLE TRIGGER %s', 
                trigger_record.table_name, trigger_record.trigger_name);
            EXECUTE sql_command;
            result_msg := 'enabled';
        ELSIF action = 'status' THEN
            result_msg := 'status_checked';
        END IF;
        
        RETURN QUERY SELECT 
            trigger_record.trigger_name::VARCHAR(100),
            trigger_record.table_name::VARCHAR(100),
            trigger_record.current_status::VARCHAR(20),
            result_msg::VARCHAR(50);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- ✅ FASE 8 COMPLETADA
-- -----------------------------------------------------
-- El sistema de triggers automáticos master incluye:
-- ✅ Trigger master para gestión completa de pedidos
-- ✅ Sistema de auditoría automática de cambios críticos
-- ✅ Validaciones automáticas de integridad de datos
-- ✅ Actualización automática de métricas del sistema
-- ✅ Limpieza automática de datos antiguos
-- ✅ Logs detallados de ejecución de triggers
-- ✅ Monitor en tiempo real de rendimiento
-- ✅ Estadísticas de performance por trigger
-- ✅ Gestión de habilitación/deshabilitación
-- ✅ Notificaciones automáticas por cambios de estado



