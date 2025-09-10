-- =====================================================
-- FASE 6: CONTADOR 30 MINUTOS RENTA AUTOS
-- =====================================================
-- Sistema especializado para servicios de renta de autos con:
-- 1. Contador de 30 minutos para confirmar recogida
-- 2. Penalizaciones automáticas por no confirmar
-- 3. Sistema de reservas y disponibilidad
-- 4. Tracking en tiempo real de vehículos
-- 5. Gestión de tarifas por tiempo

-- -----------------------------------------------------
-- 1. TABLA: vehicle_rentals (Rentas de vehículos)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS vehicle_rentals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rental_number VARCHAR(50) UNIQUE NOT NULL DEFAULT 'R-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(nextval('rental_sequence')::TEXT, 4, '0'),
    customer_id UUID NOT NULL REFERENCES users(id),
    vehicle_id UUID NOT NULL REFERENCES store_products(id), -- Vehículo como producto
    vendor_id UUID NOT NULL REFERENCES users(id), -- Propietario del vehículo
    rental_type VARCHAR(30) DEFAULT 'hourly', -- hourly, daily, weekly
    
    -- Fechas y tiempos
    reservation_time TIMESTAMP DEFAULT NOW(),
    scheduled_pickup_time TIMESTAMP NOT NULL,
    actual_pickup_time TIMESTAMP,
    scheduled_return_time TIMESTAMP NOT NULL,
    actual_return_time TIMESTAMP,
    
    -- Estado de la renta
    status VARCHAR(30) DEFAULT 'reserved', -- reserved, confirmed, picked_up, in_use, returned, cancelled, expired
    confirmation_deadline TIMESTAMP, -- 30 minutos después de scheduled_pickup_time
    pickup_confirmed_at TIMESTAMP,
    pickup_confirmed_by UUID REFERENCES users(id),
    
    -- Ubicación y tracking
    pickup_location_lat DECIMAL(10,8),
    pickup_location_lng DECIMAL(11,8),
    pickup_location_address TEXT,
    return_location_lat DECIMAL(10,8),
    return_location_lng DECIMAL(11,8),
    return_location_address TEXT,
    current_location_lat DECIMAL(10,8),
    current_location_lng DECIMAL(11,8),
    last_location_update TIMESTAMP,
    
    -- Costos y pagos
    base_rate_per_hour DECIMAL(8,2) NOT NULL,
    total_estimated_cost DECIMAL(10,2),
    total_actual_cost DECIMAL(10,2),
    deposit_amount DECIMAL(10,2) DEFAULT 0,
    penalty_amount DECIMAL(10,2) DEFAULT 0,
    
    -- Condiciones del vehículo
    fuel_level_pickup INTEGER, -- Porcentaje 0-100
    fuel_level_return INTEGER,
    mileage_pickup INTEGER,
    mileage_return INTEGER,
    damage_notes_pickup TEXT,
    damage_notes_return TEXT,
    
    -- Fotos de evidencia
    pickup_photos TEXT[], -- URLs de fotos al recoger
    return_photos TEXT[], -- URLs de fotos al devolver
    
    -- Metadatos
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    cancelled_reason TEXT,
    penalty_reason TEXT
);

-- Secuencia para números de renta
CREATE SEQUENCE IF NOT EXISTS rental_sequence START 1;

CREATE INDEX IF NOT EXISTS idx_vehicle_rentals_customer ON vehicle_rentals(customer_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_rentals_vehicle ON vehicle_rentals(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_rentals_vendor ON vehicle_rentals(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_rentals_status ON vehicle_rentals(status);
CREATE INDEX IF NOT EXISTS idx_vehicle_rentals_pickup_time ON vehicle_rentals(scheduled_pickup_time);
CREATE INDEX IF NOT EXISTS idx_vehicle_rentals_deadline ON vehicle_rentals(confirmation_deadline);

-- -----------------------------------------------------
-- 2. TABLA: vehicle_availability (Disponibilidad de vehículos)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS vehicle_availability (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES store_products(id),
    vendor_id UUID NOT NULL REFERENCES users(id),
    available_from TIMESTAMP NOT NULL,
    available_until TIMESTAMP NOT NULL,
    is_available BOOLEAN DEFAULT true,
    blocked_reason VARCHAR(100), -- maintenance, rented, damaged, etc.
    base_rate_per_hour DECIMAL(8,2) NOT NULL,
    minimum_rental_hours INTEGER DEFAULT 1,
    maximum_rental_hours INTEGER DEFAULT 168, -- 7 días
    requires_deposit BOOLEAN DEFAULT true,
    deposit_percentage DECIMAL(5,2) DEFAULT 20.0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vehicle_availability_vehicle ON vehicle_availability(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_availability_vendor ON vehicle_availability(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_availability_time ON vehicle_availability(available_from, available_until);
CREATE INDEX IF NOT EXISTS idx_vehicle_availability_status ON vehicle_availability(is_available);

-- -----------------------------------------------------
-- 3. TABLA: rental_penalties (Penalizaciones por renta)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS rental_penalties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rental_id UUID NOT NULL REFERENCES vehicle_rentals(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES users(id),
    penalty_type VARCHAR(30) NOT NULL, -- no_confirmation, late_pickup, late_return, damage, fuel_shortage
    penalty_amount DECIMAL(10,2) NOT NULL,
    penalty_description TEXT NOT NULL,
    applied_at TIMESTAMP DEFAULT NOW(),
    is_paid BOOLEAN DEFAULT false,
    paid_at TIMESTAMP,
    payment_method VARCHAR(30), -- credit_card, wallet, cash
    waived_by UUID REFERENCES users(id), -- Admin que puede cancelar penalización
    waived_at TIMESTAMP,
    waived_reason TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rental_penalties_rental ON rental_penalties(rental_id);
CREATE INDEX IF NOT EXISTS idx_rental_penalties_customer ON rental_penalties(customer_id);
CREATE INDEX IF NOT EXISTS idx_rental_penalties_type ON rental_penalties(penalty_type);
CREATE INDEX IF NOT EXISTS idx_rental_penalties_unpaid ON rental_penalties(is_paid) WHERE is_paid = false;

-- -----------------------------------------------------
-- 4. TABLA: rental_tracking (Tracking en tiempo real)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS rental_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rental_id UUID NOT NULL REFERENCES vehicle_rentals(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES users(id),
    current_lat DECIMAL(10,8) NOT NULL,
    current_lng DECIMAL(11,8) NOT NULL,
    speed_kmh DECIMAL(5,2), -- Velocidad en km/h
    direction_degrees INTEGER, -- Dirección 0-360 grados
    battery_level INTEGER, -- Para vehículos eléctricos
    fuel_level INTEGER, -- Para vehículos de combustión
    engine_status VARCHAR(20) DEFAULT 'unknown', -- on, off, idle, unknown
    location_method VARCHAR(20) DEFAULT 'gps', -- gps, network, manual
    accuracy_meters INTEGER,
    recorded_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rental_tracking_rental ON rental_tracking(rental_id);
CREATE INDEX IF NOT EXISTS idx_rental_tracking_customer ON rental_tracking(customer_id);
CREATE INDEX IF NOT EXISTS idx_rental_tracking_time ON rental_tracking(recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_rental_tracking_location ON rental_tracking(current_lat, current_lng);

-- -----------------------------------------------------
-- 5. FUNCIÓN: Crear reserva de vehículo
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION create_vehicle_rental(
    customer_id_param UUID,
    vehicle_id_param UUID,
    scheduled_pickup_time_param TIMESTAMP,
    rental_hours INTEGER,
    pickup_lat DECIMAL(10,8) DEFAULT NULL,
    pickup_lng DECIMAL(11,8) DEFAULT NULL,
    pickup_address TEXT DEFAULT NULL
) RETURNS TABLE (
    rental_id UUID,
    rental_number VARCHAR(50),
    confirmation_deadline TIMESTAMP,
    total_estimated_cost DECIMAL(10,2),
    deposit_required DECIMAL(10,2),
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    rental_id_result UUID;
    rental_number_result VARCHAR(50);
    vendor_info RECORD;
    availability_info RECORD;
    rate_per_hour DECIMAL(8,2);
    estimated_cost DECIMAL(10,2);
    deposit_amount DECIMAL(10,2);
    deadline_time TIMESTAMP;
    return_time TIMESTAMP;
BEGIN
    -- Obtener información del vehículo y vendor
    SELECT 
        sp.vendor_id,
        sp.title as vehicle_name,
        sp.price as base_price,
        u.full_name as vendor_name
    INTO vendor_info
    FROM store_products sp
    JOIN users u ON sp.vendor_id = u.id
    WHERE sp.id = vehicle_id_param
      AND sp.category = 'vehicle';
    
    IF vendor_info IS NULL THEN
        RETURN QUERY SELECT 
            NULL::UUID, NULL::VARCHAR(50), NULL::TIMESTAMP, 
            NULL::DECIMAL(10,2), NULL::DECIMAL(10,2),
            false, 'Vehículo no encontrado o no disponible'::TEXT;
        RETURN;
    END IF;
    
    -- Verificar disponibilidad del vehículo
    SELECT * INTO availability_info
    FROM vehicle_availability va
    WHERE va.vehicle_id = vehicle_id_param
      AND va.is_available = true
      AND scheduled_pickup_time_param >= va.available_from
      AND scheduled_pickup_time_param + INTERVAL '1 hour' * rental_hours <= va.available_until
      AND NOT EXISTS (
          SELECT 1 FROM vehicle_rentals vr
          WHERE vr.vehicle_id = vehicle_id_param
            AND vr.status NOT IN ('cancelled', 'returned', 'expired')
            AND (
                (scheduled_pickup_time_param, scheduled_pickup_time_param + INTERVAL '1 hour' * rental_hours) 
                OVERLAPS 
                (vr.scheduled_pickup_time, vr.scheduled_return_time)
            )
      );
    
    IF availability_info IS NULL THEN
        RETURN QUERY SELECT 
            NULL::UUID, NULL::VARCHAR(50), NULL::TIMESTAMP,
            NULL::DECIMAL(10,2), NULL::DECIMAL(10,2),
            false, 'Vehículo no disponible en el horario solicitado'::TEXT;
        RETURN;
    END IF;
    
    -- Calcular costos
    rate_per_hour := availability_info.base_rate_per_hour;
    estimated_cost := rate_per_hour * rental_hours;
    deposit_amount := CASE 
        WHEN availability_info.requires_deposit THEN 
            estimated_cost * (availability_info.deposit_percentage / 100.0)
        ELSE 0
    END;
    
    -- Calcular tiempo límite para confirmación (30 minutos)
    deadline_time := scheduled_pickup_time_param + INTERVAL '30 minutes';
    return_time := scheduled_pickup_time_param + INTERVAL '1 hour' * rental_hours;
    
    -- Crear la reserva
    INSERT INTO vehicle_rentals (
        customer_id, vehicle_id, vendor_id,
        scheduled_pickup_time, scheduled_return_time,
        confirmation_deadline, base_rate_per_hour,
        total_estimated_cost, deposit_amount,
        pickup_location_lat, pickup_location_lng, pickup_location_address
    ) VALUES (
        customer_id_param, vehicle_id_param, vendor_info.vendor_id,
        scheduled_pickup_time_param, return_time,
        deadline_time, rate_per_hour,
        estimated_cost, deposit_amount,
        pickup_lat, pickup_lng, pickup_address
    ) RETURNING id, rental_number INTO rental_id_result, rental_number_result;
    
    -- Marcar vehículo como temporalmente no disponible
    UPDATE vehicle_availability
    SET 
        is_available = false,
        blocked_reason = 'reserved',
        updated_at = NOW()
    WHERE vehicle_id = vehicle_id_param;
    
    RETURN QUERY SELECT 
        rental_id_result,
        rental_number_result,
        deadline_time,
        estimated_cost,
        deposit_amount,
        true,
        'Reserva creada exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 6. FUNCIÓN: Confirmar recogida de vehículo (dentro de 30 min)
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION confirm_vehicle_pickup(
    rental_id_param UUID,
    confirmed_by_param UUID,
    actual_pickup_time_param TIMESTAMP DEFAULT NOW(),
    fuel_level_param INTEGER DEFAULT NULL,
    mileage_param INTEGER DEFAULT NULL,
    pickup_photos_param TEXT[] DEFAULT NULL,
    damage_notes_param TEXT DEFAULT NULL
) RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    penalty_applied BOOLEAN,
    penalty_amount DECIMAL(10,2)
) AS $$
DECLARE
    rental_record RECORD;
    is_within_deadline BOOLEAN;
    penalty_applied_val BOOLEAN := false;
    penalty_amount_val DECIMAL(10,2) := 0;
BEGIN
    -- Obtener información de la reserva
    SELECT * INTO rental_record
    FROM vehicle_rentals
    WHERE id = rental_id_param
      AND status = 'reserved';
    
    IF rental_record IS NULL THEN
        RETURN QUERY SELECT false, 'Reserva no encontrada o no está en estado reservado'::TEXT, false, 0::DECIMAL(10,2);
        RETURN;
    END IF;
    
    -- Verificar si está dentro del plazo de 30 minutos
    is_within_deadline := (actual_pickup_time_param <= rental_record.confirmation_deadline);
    
    -- Si está fuera del plazo, aplicar penalización
    IF NOT is_within_deadline THEN
        penalty_amount_val := rental_record.base_rate_per_hour * 0.5; -- 50% de 1 hora como penalización
        penalty_applied_val := true;
        
        -- Insertar penalización
        INSERT INTO rental_penalties (
            rental_id, customer_id, penalty_type, penalty_amount, penalty_description
        ) VALUES (
            rental_id_param, rental_record.customer_id, 'late_confirmation',
            penalty_amount_val, 
            format('Confirmación tardía. Límite era %s, confirmó a las %s', 
                rental_record.confirmation_deadline, actual_pickup_time_param)
        );
        
        -- Actualizar costo total
        UPDATE vehicle_rentals
        SET penalty_amount = penalty_amount + penalty_amount_val
        WHERE id = rental_id_param;
    END IF;
    
    -- Confirmar la recogida
    UPDATE vehicle_rentals
    SET 
        status = 'picked_up',
        actual_pickup_time = actual_pickup_time_param,
        pickup_confirmed_at = NOW(),
        pickup_confirmed_by = confirmed_by_param,
        fuel_level_pickup = fuel_level_param,
        mileage_pickup = mileage_param,
        pickup_photos = pickup_photos_param,
        damage_notes_pickup = damage_notes_param,
        updated_at = NOW()
    WHERE id = rental_id_param;
    
    -- Crear primer registro de tracking
    INSERT INTO rental_tracking (
        rental_id, customer_id, current_lat, current_lng, fuel_level, recorded_at
    ) VALUES (
        rental_id_param, rental_record.customer_id,
        rental_record.pickup_location_lat, rental_record.pickup_location_lng,
        fuel_level_param, actual_pickup_time_param
    );
    
    RETURN QUERY SELECT 
        true,
        CASE 
            WHEN penalty_applied_val THEN 'Recogida confirmada con penalización por retraso'
            ELSE 'Recogida confirmada exitosamente'
        END::TEXT,
        penalty_applied_val,
        penalty_amount_val;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 7. FUNCIÓN: Actualizar ubicación en tiempo real
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION update_rental_location(
    rental_id_param UUID,
    current_lat_param DECIMAL(10,8),
    current_lng_param DECIMAL(11,8),
    speed_param DECIMAL(5,2) DEFAULT NULL,
    direction_param INTEGER DEFAULT NULL,
    fuel_level_param INTEGER DEFAULT NULL,
    battery_level_param INTEGER DEFAULT NULL,
    engine_status_param VARCHAR(20) DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    customer_id_val UUID;
BEGIN
    -- Obtener customer_id de la renta
    SELECT customer_id INTO customer_id_val
    FROM vehicle_rentals
    WHERE id = rental_id_param
      AND status IN ('picked_up', 'in_use');
    
    IF customer_id_val IS NULL THEN
        RETURN false;
    END IF;
    
    -- Insertar nuevo punto de tracking
    INSERT INTO rental_tracking (
        rental_id, customer_id, current_lat, current_lng,
        speed_kmh, direction_degrees, fuel_level, battery_level, engine_status
    ) VALUES (
        rental_id_param, customer_id_val, current_lat_param, current_lng_param,
        speed_param, direction_param, fuel_level_param, battery_level_param, engine_status_param
    );
    
    -- Actualizar ubicación actual en la tabla principal
    UPDATE vehicle_rentals
    SET 
        current_location_lat = current_lat_param,
        current_location_lng = current_lng_param,
        last_location_update = NOW(),
        updated_at = NOW()
    WHERE id = rental_id_param;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 8. FUNCIÓN: Procesar rentas expiradas (no confirmadas)
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION process_expired_rentals() 
RETURNS TABLE (
    processed_count INTEGER,
    penalties_applied INTEGER,
    total_penalty_amount DECIMAL(10,2)
) AS $$
DECLARE
    expired_rental RECORD;
    penalties_count INTEGER := 0;
    total_penalties DECIMAL(10,2) := 0;
    processed_count_val INTEGER := 0;
BEGIN
    -- Buscar reservas expiradas (pasaron 30 minutos sin confirmar)
    FOR expired_rental IN
        SELECT *
        FROM vehicle_rentals
        WHERE status = 'reserved'
          AND confirmation_deadline < NOW()
    LOOP
        -- Marcar como expirada
        UPDATE vehicle_rentals
        SET 
            status = 'expired',
            cancelled_reason = 'No confirmó recogida dentro de 30 minutos',
            updated_at = NOW()
        WHERE id = expired_rental.id;
        
        -- Aplicar penalización del 25% del depósito
        IF expired_rental.deposit_amount > 0 THEN
            INSERT INTO rental_penalties (
                rental_id, customer_id, penalty_type, penalty_amount, penalty_description
            ) VALUES (
                expired_rental.id, expired_rental.customer_id, 'no_confirmation',
                expired_rental.deposit_amount * 0.25,
                'No confirmó recogida del vehículo dentro del plazo de 30 minutos'
            );
            
            penalties_count := penalties_count + 1;
            total_penalties := total_penalties + (expired_rental.deposit_amount * 0.25);
        END IF;
        
        -- Liberar vehículo para nuevas reservas
        UPDATE vehicle_availability
        SET 
            is_available = true,
            blocked_reason = NULL,
            updated_at = NOW()
        WHERE vehicle_id = expired_rental.vehicle_id;
        
        processed_count_val := processed_count_val + 1;
    END LOOP;
    
    RETURN QUERY SELECT processed_count_val, penalties_count, total_penalties;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 9. FUNCIÓN: Finalizar renta y calcular costo final
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION finalize_vehicle_rental(
    rental_id_param UUID,
    actual_return_time_param TIMESTAMP DEFAULT NOW(),
    fuel_level_return_param INTEGER DEFAULT NULL,
    mileage_return_param INTEGER DEFAULT NULL,
    return_photos_param TEXT[] DEFAULT NULL,
    damage_notes_return_param TEXT DEFAULT NULL
) RETURNS TABLE (
    final_cost DECIMAL(10,2),
    overtime_charges DECIMAL(10,2),
    fuel_penalty DECIMAL(10,2),
    damage_penalty DECIMAL(10,2),
    total_penalties DECIMAL(10,2),
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    rental_record RECORD;
    actual_hours DECIMAL(10,2);
    expected_hours DECIMAL(10,2);
    overtime_hours DECIMAL(10,2) := 0;
    base_cost DECIMAL(10,2);
    overtime_cost DECIMAL(10,2) := 0;
    fuel_penalty_val DECIMAL(10,2) := 0;
    damage_penalty_val DECIMAL(10,2) := 0;
    final_cost_val DECIMAL(10,2);
    total_penalties_val DECIMAL(10,2);
BEGIN
    -- Obtener información de la renta
    SELECT * INTO rental_record
    FROM vehicle_rentals
    WHERE id = rental_id_param
      AND status IN ('picked_up', 'in_use');
    
    IF rental_record IS NULL THEN
        RETURN QUERY SELECT 
            0::DECIMAL(10,2), 0::DECIMAL(10,2), 0::DECIMAL(10,2), 
            0::DECIMAL(10,2), 0::DECIMAL(10,2),
            false, 'Renta no encontrada o no está activa'::TEXT;
        RETURN;
    END IF;
    
    -- Calcular horas reales y esperadas
    actual_hours := EXTRACT(EPOCH FROM (actual_return_time_param - rental_record.actual_pickup_time)) / 3600.0;
    expected_hours := EXTRACT(EPOCH FROM (rental_record.scheduled_return_time - rental_record.actual_pickup_time)) / 3600.0;
    
    -- Calcular costo base
    base_cost := expected_hours * rental_record.base_rate_per_hour;
    
    -- Calcular overtime si aplica
    IF actual_hours > expected_hours THEN
        overtime_hours := actual_hours - expected_hours;
        overtime_cost := overtime_hours * rental_record.base_rate_per_hour * 1.5; -- 150% del rate normal
        
        -- Insertar penalización por overtime
        INSERT INTO rental_penalties (
            rental_id, customer_id, penalty_type, penalty_amount, penalty_description
        ) VALUES (
            rental_id_param, rental_record.customer_id, 'late_return',
            overtime_cost, 
            format('Retorno tardío: %s horas extra a $%s/hora', overtime_hours, rental_record.base_rate_per_hour * 1.5)
        );
    END IF;
    
    -- Penalización por combustible si aplica
    IF fuel_level_return_param IS NOT NULL AND rental_record.fuel_level_pickup IS NOT NULL THEN
        IF fuel_level_return_param < rental_record.fuel_level_pickup THEN
            fuel_penalty_val := (rental_record.fuel_level_pickup - fuel_level_return_param) * 2.0; -- $2 por % de combustible
            
            INSERT INTO rental_penalties (
                rental_id, customer_id, penalty_type, penalty_amount, penalty_description
            ) VALUES (
                rental_id_param, rental_record.customer_id, 'fuel_shortage',
                fuel_penalty_val,
                format('Combustible faltante: %s%% (de %s%% a %s%%)', 
                    rental_record.fuel_level_pickup - fuel_level_return_param,
                    rental_record.fuel_level_pickup, fuel_level_return_param)
            );
        END IF;
    END IF;
    
    -- Penalización por daños (requiere revisión manual)
    IF damage_notes_return_param IS NOT NULL AND damage_notes_return_param != '' THEN
        damage_penalty_val := 50.0; -- Penalización base por daños (a revisar manualmente)
        
        INSERT INTO rental_penalties (
            rental_id, customer_id, penalty_type, penalty_amount, penalty_description
        ) VALUES (
            rental_id_param, rental_record.customer_id, 'damage',
            damage_penalty_val,
            'Daños reportados: ' || damage_notes_return_param
        );
    END IF;
    
    -- Calcular totales
    total_penalties_val := COALESCE(rental_record.penalty_amount, 0) + overtime_cost + fuel_penalty_val + damage_penalty_val;
    final_cost_val := base_cost + total_penalties_val;
    
    -- Finalizar la renta
    UPDATE vehicle_rentals
    SET 
        status = 'returned',
        actual_return_time = actual_return_time_param,
        fuel_level_return = fuel_level_return_param,
        mileage_return = mileage_return_param,
        return_photos = return_photos_param,
        damage_notes_return = damage_notes_return_param,
        total_actual_cost = final_cost_val,
        penalty_amount = total_penalties_val,
        updated_at = NOW()
    WHERE id = rental_id_param;
    
    -- Liberar vehículo
    UPDATE vehicle_availability
    SET 
        is_available = true,
        blocked_reason = NULL,
        updated_at = NOW()
    WHERE vehicle_id = rental_record.vehicle_id;
    
    RETURN QUERY SELECT 
        final_cost_val,
        overtime_cost,
        fuel_penalty_val,
        damage_penalty_val,
        total_penalties_val,
        true,
        'Renta finalizada exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 10. VISTA: Dashboard de rentas activas
-- -----------------------------------------------------
CREATE OR REPLACE VIEW active_rentals_dashboard AS
SELECT 
    vr.id as rental_id,
    vr.rental_number,
    vr.status,
    c.full_name as customer_name,
    c.email as customer_email,
    v.full_name as vendor_name,
    sp.title as vehicle_name,
    vr.scheduled_pickup_time,
    vr.confirmation_deadline,
    vr.actual_pickup_time,
    vr.scheduled_return_time,
    CASE 
        WHEN vr.status = 'reserved' AND NOW() > vr.confirmation_deadline THEN 'EXPIRED'
        WHEN vr.status = 'picked_up' AND NOW() > vr.scheduled_return_time THEN 'OVERDUE'
        WHEN vr.status = 'reserved' THEN 
            EXTRACT(EPOCH FROM (vr.confirmation_deadline - NOW())) / 60
        ELSE NULL
    END as minutes_until_deadline,
    vr.total_estimated_cost,
    vr.penalty_amount,
    vr.current_location_lat,
    vr.current_location_lng,
    vr.last_location_update,
    EXTRACT(EPOCH FROM (NOW() - COALESCE(vr.actual_pickup_time, vr.scheduled_pickup_time))) / 3600.0 as hours_since_pickup
FROM vehicle_rentals vr
JOIN users c ON vr.customer_id = c.id
JOIN users v ON vr.vendor_id = v.id
JOIN store_products sp ON vr.vehicle_id = sp.id
WHERE vr.status IN ('reserved', 'confirmed', 'picked_up', 'in_use')
ORDER BY 
    CASE vr.status
        WHEN 'reserved' THEN 1
        WHEN 'picked_up' THEN 2
        WHEN 'in_use' THEN 3
        WHEN 'confirmed' THEN 4
    END,
    vr.confirmation_deadline ASC;

-- -----------------------------------------------------
-- 11. JOB AUTOMÁTICO: Procesar rentas expiradas cada 5 minutos
-- -----------------------------------------------------
-- Esta función debe ser llamada cada 5 minutos por un cron job
CREATE OR REPLACE FUNCTION rental_maintenance_job() 
RETURNS TEXT AS $$
DECLARE
    expired_result RECORD;
    result_message TEXT;
BEGIN
    -- Procesar rentas expiradas
    SELECT * INTO expired_result FROM process_expired_rentals();
    
    -- Limpiar tracking data antiguo (> 30 días)
    DELETE FROM rental_tracking 
    WHERE recorded_at < NOW() - INTERVAL '30 days';
    
    result_message := format(
        'Mantenimiento completado: %s rentas expiradas procesadas, %s penalizaciones aplicadas por $%s total',
        expired_result.processed_count,
        expired_result.penalties_applied,
        expired_result.total_penalty_amount
    );
    
    -- Log del mantenimiento
    INSERT INTO system_logs (level, message, details)
    VALUES (
        'INFO',
        'Mantenimiento automático de rentas',
        jsonb_build_object(
            'expired_rentals', expired_result.processed_count,
            'penalties_applied', expired_result.penalties_applied,
            'total_penalties', expired_result.total_penalty_amount
        )
    );
    
    RETURN result_message;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 12. FUNCIÓN: Estadísticas de renta de autos
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_rental_statistics(
    start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    end_date DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
    total_rentals INTEGER,
    completed_rentals INTEGER,
    expired_rentals INTEGER,
    cancelled_rentals INTEGER,
    total_revenue DECIMAL(12,2),
    total_penalties DECIMAL(12,2),
    avg_rental_duration_hours DECIMAL(8,2),
    on_time_confirmation_rate DECIMAL(5,2),
    avg_confirmation_time_minutes DECIMAL(8,2),
    most_popular_vehicle VARCHAR(255),
    top_customer VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    WITH rental_stats AS (
        SELECT 
            COUNT(*) as total_rentals,
            COUNT(CASE WHEN status = 'returned' THEN 1 END) as completed_rentals,
            COUNT(CASE WHEN status = 'expired' THEN 1 END) as expired_rentals,
            COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_rentals,
            SUM(COALESCE(total_actual_cost, total_estimated_cost)) as total_revenue,
            SUM(COALESCE(penalty_amount, 0)) as total_penalties,
            AVG(EXTRACT(EPOCH FROM (actual_return_time - actual_pickup_time)) / 3600.0) as avg_duration,
            AVG(CASE 
                WHEN pickup_confirmed_at <= confirmation_deadline THEN 100.0 
                ELSE 0.0 
            END) as on_time_rate,
            AVG(EXTRACT(EPOCH FROM (pickup_confirmed_at - scheduled_pickup_time)) / 60.0) as avg_confirm_time
        FROM vehicle_rentals
        WHERE created_at::DATE BETWEEN start_date AND end_date
    ),
    popular_vehicle AS (
        SELECT sp.title
        FROM vehicle_rentals vr
        JOIN store_products sp ON vr.vehicle_id = sp.id
        WHERE vr.created_at::DATE BETWEEN start_date AND end_date
        GROUP BY sp.id, sp.title
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ),
    top_customer AS (
        SELECT u.full_name
        FROM vehicle_rentals vr
        JOIN users u ON vr.customer_id = u.id
        WHERE vr.created_at::DATE BETWEEN start_date AND end_date
        GROUP BY u.id, u.full_name
        ORDER BY COUNT(*) DESC
        LIMIT 1
    )
    SELECT 
        rs.total_rentals::INTEGER,
        rs.completed_rentals::INTEGER,
        rs.expired_rentals::INTEGER,
        rs.cancelled_rentals::INTEGER,
        rs.total_revenue::DECIMAL(12,2),
        rs.total_penalties::DECIMAL(12,2),
        rs.avg_duration::DECIMAL(8,2),
        rs.on_time_rate::DECIMAL(5,2),
        rs.avg_confirm_time::DECIMAL(8,2),
        COALESCE(pv.title, 'N/A')::VARCHAR(255),
        COALESCE(tc.full_name, 'N/A')::VARCHAR(255)
    FROM rental_stats rs
    CROSS JOIN popular_vehicle pv
    CROSS JOIN top_customer tc;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- ✅ FASE 6 COMPLETADA
-- -----------------------------------------------------
-- El sistema de contador 30 minutos para renta autos incluye:
-- ✅ Reservas con límite de 30 minutos para confirmar
-- ✅ Penalizaciones automáticas por no confirmar a tiempo
-- ✅ Tracking en tiempo real de ubicación del vehículo
-- ✅ Gestión completa de costos y penalizaciones
-- ✅ Cálculo automático de overtime y combustible
-- ✅ Dashboard de rentas activas en tiempo real
-- ✅ Jobs automáticos para procesar expirados
-- ✅ Estadísticas detalladas del servicio
-- ✅ Sistema de disponibilidad de vehículos
-- ✅ Evidencia fotográfica y daños



