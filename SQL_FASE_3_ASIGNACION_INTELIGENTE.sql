-- =====================================================
-- FASE 3: ALGORITMO DE ASIGNACIÓN INTELIGENTE
-- =====================================================
-- Sistema que asigna automáticamente repartidores basado en:
-- 1. Proximidad geográfica
-- 2. Disponibilidad y carga actual
-- 3. Rating y experiencia
-- 4. Tipo de producto/servicio
-- 5. Historial de performance

-- -----------------------------------------------------
-- 1. TABLA: delivery_zones (Zonas de reparto)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS delivery_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    center_lat DECIMAL(10,8) NOT NULL,
    center_lng DECIMAL(11,8) NOT NULL,
    radius_km DECIMAL(5,2) NOT NULL DEFAULT 5.0,
    is_active BOOLEAN DEFAULT true,
    priority_level INTEGER DEFAULT 1, -- 1=alta, 2=media, 3=baja
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para búsquedas geográficas
CREATE INDEX IF NOT EXISTS idx_delivery_zones_location ON delivery_zones(center_lat, center_lng);
CREATE INDEX IF NOT EXISTS idx_delivery_zones_active ON delivery_zones(is_active);

-- -----------------------------------------------------
-- 2. TABLA: delivery_person_zones (Repartidores por zona)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS delivery_person_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_person_id UUID NOT NULL REFERENCES users(id),
    zone_id UUID NOT NULL REFERENCES delivery_zones(id),
    is_preferred BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(delivery_person_id, zone_id)
);

CREATE INDEX IF NOT EXISTS idx_delivery_zones_person ON delivery_person_zones(delivery_person_id);
CREATE INDEX IF NOT EXISTS idx_delivery_zones_zone ON delivery_person_zones(zone_id);

-- -----------------------------------------------------
-- 3. TABLA: delivery_performance (Performance de repartidores)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS delivery_performance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_person_id UUID NOT NULL REFERENCES users(id),
    total_deliveries INTEGER DEFAULT 0,
    completed_deliveries INTEGER DEFAULT 0,
    cancelled_deliveries INTEGER DEFAULT 0,
    avg_delivery_time_minutes DECIMAL(5,2) DEFAULT 0,
    avg_rating DECIMAL(3,2) DEFAULT 0,
    total_earnings DECIMAL(10,2) DEFAULT 0,
    current_load INTEGER DEFAULT 0, -- Pedidos activos actuales
    max_load INTEGER DEFAULT 3, -- Máximo pedidos simultáneos
    last_delivery_at TIMESTAMP,
    is_available BOOLEAN DEFAULT true,
    availability_status VARCHAR(20) DEFAULT 'available', -- available, busy, offline
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(delivery_person_id)
);

CREATE INDEX IF NOT EXISTS idx_delivery_performance_person ON delivery_performance(delivery_person_id);
CREATE INDEX IF NOT EXISTS idx_delivery_performance_available ON delivery_performance(is_available, availability_status);
CREATE INDEX IF NOT EXISTS idx_delivery_performance_rating ON delivery_performance(avg_rating DESC);

-- -----------------------------------------------------
-- 4. TABLA: assignment_rules (Reglas de asignación)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS assignment_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name VARCHAR(100) NOT NULL,
    product_category VARCHAR(50), -- null = aplica a todos
    service_type VARCHAR(50), -- delivery, pickup, express, etc.
    max_distance_km DECIMAL(5,2) DEFAULT 10.0,
    min_rating DECIMAL(3,2) DEFAULT 0.0,
    max_current_load INTEGER DEFAULT 3,
    priority_weight_distance DECIMAL(3,2) DEFAULT 0.4, -- 40% peso distancia
    priority_weight_rating DECIMAL(3,2) DEFAULT 0.3, -- 30% peso rating
    priority_weight_load DECIMAL(3,2) DEFAULT 0.2, -- 20% peso carga actual
    priority_weight_experience DECIMAL(3,2) DEFAULT 0.1, -- 10% peso experiencia
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_assignment_rules_category ON assignment_rules(product_category);
CREATE INDEX IF NOT EXISTS idx_assignment_rules_service ON assignment_rules(service_type);
CREATE INDEX IF NOT EXISTS idx_assignment_rules_active ON assignment_rules(is_active);

-- Insertar reglas por defecto
INSERT INTO assignment_rules (rule_name, product_category, service_type, max_distance_km, min_rating, max_current_load) VALUES
('Regla General', NULL, NULL, 15.0, 0.0, 3),
('Comida Rápida', 'food', 'express', 8.0, 4.0, 2),
('Productos Frágiles', 'fragile', 'careful', 12.0, 4.5, 1),
('Medicamentos', 'pharmacy', 'priority', 20.0, 4.8, 2),
('Documentos Urgentes', 'documents', 'express', 25.0, 4.0, 3);

-- -----------------------------------------------------
-- 5. FUNCIÓN: Calcular distancia entre dos puntos (Haversine)
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_distance_km(
    lat1 DECIMAL(10,8),
    lng1 DECIMAL(11,8),
    lat2 DECIMAL(10,8),
    lng2 DECIMAL(11,8)
) RETURNS DECIMAL(8,3) AS $$
DECLARE
    earth_radius DECIMAL := 6371; -- Radio de la Tierra en km
    dlat DECIMAL;
    dlng DECIMAL;
    a DECIMAL;
    c DECIMAL;
BEGIN
    dlat := RADIANS(lat2 - lat1);
    dlng := RADIANS(lng2 - lng1);
    
    a := SIN(dlat/2) * SIN(dlat/2) + 
         COS(RADIANS(lat1)) * COS(RADIANS(lat2)) * 
         SIN(dlng/2) * SIN(dlng/2);
    
    c := 2 * ATAN2(SQRT(a), SQRT(1-a));
    
    RETURN earth_radius * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- -----------------------------------------------------
-- 6. FUNCIÓN: Obtener repartidores disponibles con puntuación
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_available_delivery_persons(
    pickup_lat DECIMAL(10,8),
    pickup_lng DECIMAL(11,8),
    product_category VARCHAR(50) DEFAULT NULL,
    service_type VARCHAR(50) DEFAULT NULL
) RETURNS TABLE (
    delivery_person_id UUID,
    user_name VARCHAR(255),
    user_email VARCHAR(255),
    distance_km DECIMAL(8,3),
    avg_rating DECIMAL(3,2),
    current_load INTEGER,
    total_deliveries INTEGER,
    final_score DECIMAL(8,4),
    rank_position INTEGER
) AS $$
DECLARE
    rule_record RECORD;
BEGIN
    -- Obtener regla aplicable
    SELECT * INTO rule_record
    FROM assignment_rules 
    WHERE is_active = true
      AND (product_category IS NULL OR assignment_rules.product_category = get_available_delivery_persons.product_category)
      AND (service_type IS NULL OR assignment_rules.service_type = get_available_delivery_persons.service_type)
    ORDER BY 
        CASE WHEN assignment_rules.product_category IS NOT NULL THEN 1 ELSE 2 END,
        CASE WHEN assignment_rules.service_type IS NOT NULL THEN 1 ELSE 2 END
    LIMIT 1;
    
    -- Si no hay regla específica, usar regla general
    IF rule_record IS NULL THEN
        SELECT * INTO rule_record
        FROM assignment_rules 
        WHERE rule_name = 'Regla General' AND is_active = true;
    END IF;
    
    -- Retornar repartidores ordenados por puntuación
    RETURN QUERY
    WITH delivery_candidates AS (
        SELECT 
            u.id as delivery_person_id,
            u.full_name as user_name,
            u.email as user_email,
            calculate_distance_km(pickup_lat, pickup_lng, u.current_lat, u.current_lng) as distance_km,
            COALESCE(dp.avg_rating, 0) as avg_rating,
            COALESCE(dp.current_load, 0) as current_load,
            COALESCE(dp.total_deliveries, 0) as total_deliveries,
            dp.is_available,
            dp.availability_status
        FROM users u
        LEFT JOIN delivery_performance dp ON u.id = dp.delivery_person_id
        WHERE u.role = 'delivery'
          AND COALESCE(dp.is_available, true) = true
          AND COALESCE(dp.availability_status, 'available') = 'available'
          AND COALESCE(dp.current_load, 0) < rule_record.max_current_load
          AND COALESCE(dp.avg_rating, 0) >= rule_record.min_rating
          AND u.current_lat IS NOT NULL 
          AND u.current_lng IS NOT NULL
    ),
    scored_candidates AS (
        SELECT 
            dc.*,
            -- Normalizar y calcular puntuación final
            (
                -- Componente distancia (invertido: menor distancia = mayor puntuación)
                (rule_record.priority_weight_distance * 
                 GREATEST(0, (rule_record.max_distance_km - dc.distance_km) / rule_record.max_distance_km)) +
                
                -- Componente rating
                (rule_record.priority_weight_rating * (dc.avg_rating / 5.0)) +
                
                -- Componente carga (invertido: menor carga = mayor puntuación)
                (rule_record.priority_weight_load * 
                 (1.0 - (dc.current_load::DECIMAL / rule_record.max_current_load))) +
                
                -- Componente experiencia
                (rule_record.priority_weight_experience * 
                 LEAST(1.0, dc.total_deliveries::DECIMAL / 100.0))
            ) as final_score
        FROM delivery_candidates dc
        WHERE dc.distance_km <= rule_record.max_distance_km
    )
    SELECT 
        sc.delivery_person_id,
        sc.user_name,
        sc.user_email,
        sc.distance_km,
        sc.avg_rating,
        sc.current_load,
        sc.total_deliveries,
        sc.final_score,
        ROW_NUMBER() OVER (ORDER BY sc.final_score DESC)::INTEGER as rank_position
    FROM scored_candidates sc
    ORDER BY sc.final_score DESC;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 7. FUNCIÓN: Asignar automáticamente repartidor
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION auto_assign_delivery_person(
    order_id_param UUID,
    pickup_lat DECIMAL(10,8),
    pickup_lng DECIMAL(11,8),
    product_category VARCHAR(50) DEFAULT NULL,
    service_type VARCHAR(50) DEFAULT NULL
) RETURNS TABLE (
    success BOOLEAN,
    assigned_delivery_person_id UUID,
    delivery_person_name VARCHAR(255),
    distance_km DECIMAL(8,3),
    final_score DECIMAL(8,4),
    message TEXT
) AS $$
DECLARE
    best_delivery RECORD;
    update_count INTEGER;
BEGIN
    -- Buscar el mejor repartidor disponible
    SELECT * INTO best_delivery
    FROM get_available_delivery_persons(pickup_lat, pickup_lng, product_category, service_type)
    LIMIT 1;
    
    -- Si no hay repartidores disponibles
    IF best_delivery IS NULL THEN
        RETURN QUERY SELECT 
            false as success,
            NULL::UUID as assigned_delivery_person_id,
            NULL::VARCHAR(255) as delivery_person_name,
            NULL::DECIMAL(8,3) as distance_km,
            NULL::DECIMAL(8,4) as final_score,
            'No hay repartidores disponibles en este momento' as message;
        RETURN;
    END IF;
    
    -- Asignar el pedido al repartidor
    UPDATE orders 
    SET 
        delivery_person_id = best_delivery.delivery_person_id,
        status = 'assigned',
        assigned_at = NOW(),
        updated_at = NOW()
    WHERE id = order_id_param 
      AND delivery_person_id IS NULL; -- Solo si no está ya asignado
    
    GET DIAGNOSTICS update_count = ROW_COUNT;
    
    -- Si la asignación fue exitosa, actualizar carga del repartidor
    IF update_count > 0 THEN
        -- Insertar/actualizar performance del repartidor
        INSERT INTO delivery_performance (delivery_person_id, current_load)
        VALUES (best_delivery.delivery_person_id, 1)
        ON CONFLICT (delivery_person_id) 
        DO UPDATE SET 
            current_load = delivery_performance.current_load + 1,
            updated_at = NOW();
        
        -- Retornar éxito
        RETURN QUERY SELECT 
            true as success,
            best_delivery.delivery_person_id,
            best_delivery.user_name,
            best_delivery.distance_km,
            best_delivery.final_score,
            'Repartidor asignado exitosamente' as message;
    ELSE
        -- El pedido ya estaba asignado o no existe
        RETURN QUERY SELECT 
            false as success,
            NULL::UUID as assigned_delivery_person_id,
            NULL::VARCHAR(255) as delivery_person_name,
            NULL::DECIMAL(8,3) as distance_km,
            NULL::DECIMAL(8,4) as final_score,
            'El pedido ya está asignado o no existe' as message;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 8. FUNCIÓN: Actualizar ubicación de repartidor
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION update_delivery_person_location(
    delivery_person_id_param UUID,
    new_lat DECIMAL(10,8),
    new_lng DECIMAL(11,8)
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE users 
    SET 
        current_lat = new_lat,
        current_lng = new_lng,
        last_location_update = NOW()
    WHERE id = delivery_person_id_param 
      AND role = 'delivery';
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 9. FUNCIÓN: Cambiar disponibilidad de repartidor
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION set_delivery_person_availability(
    delivery_person_id_param UUID,
    is_available_param BOOLEAN,
    status_param VARCHAR(20) DEFAULT 'available'
) RETURNS BOOLEAN AS $$
BEGIN
    INSERT INTO delivery_performance (delivery_person_id, is_available, availability_status)
    VALUES (delivery_person_id_param, is_available_param, status_param)
    ON CONFLICT (delivery_person_id) 
    DO UPDATE SET 
        is_available = is_available_param,
        availability_status = status_param,
        updated_at = NOW();
    
    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 10. TRIGGER: Auto-asignación cuando se crea un pedido
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION trigger_auto_assign_delivery() 
RETURNS TRIGGER AS $$
DECLARE
    pickup_lat_val DECIMAL(10,8);
    pickup_lng_val DECIMAL(11,8);
    product_cat VARCHAR(50);
    service_typ VARCHAR(50);
    assignment_result RECORD;
BEGIN
    -- Solo auto-asignar si es un nuevo pedido sin repartidor
    IF TG_OP = 'INSERT' AND NEW.delivery_person_id IS NULL AND NEW.status = 'pending' THEN
        
        -- Obtener coordenadas de pickup (desde dirección o vendor)
        SELECT 
            COALESCE(NEW.pickup_lat, v.lat, 25.7617) as lat,
            COALESCE(NEW.pickup_lng, v.lng, -80.1918) as lng
        INTO pickup_lat_val, pickup_lng_val
        FROM users v 
        WHERE v.id = NEW.vendor_id;
        
        -- Determinar categoría de producto y tipo de servicio
        SELECT 
            COALESCE(p.category, 'general') as category,
            CASE 
                WHEN NEW.is_express = true THEN 'express'
                WHEN p.category = 'food' THEN 'express'
                WHEN p.category = 'pharmacy' THEN 'priority'
                ELSE 'standard'
            END as service_type
        INTO product_cat, service_typ
        FROM order_items oi
        JOIN store_products p ON oi.product_id = p.id
        WHERE oi.order_id = NEW.id
        LIMIT 1;
        
        -- Intentar asignación automática
        SELECT * INTO assignment_result
        FROM auto_assign_delivery_person(
            NEW.id, 
            pickup_lat_val, 
            pickup_lng_val, 
            product_cat, 
            service_typ
        );
        
        -- Si la asignación fue exitosa, actualizar el NEW record
        IF assignment_result.success THEN
            NEW.delivery_person_id := assignment_result.assigned_delivery_person_id;
            NEW.status := 'assigned';
            NEW.assigned_at := NOW();
            
            -- Log de asignación
            INSERT INTO system_logs (level, message, details)
            VALUES (
                'INFO',
                'Auto-asignación exitosa',
                jsonb_build_object(
                    'order_id', NEW.id,
                    'delivery_person_id', assignment_result.assigned_delivery_person_id,
                    'delivery_person_name', assignment_result.delivery_person_name,
                    'distance_km', assignment_result.distance_km,
                    'score', assignment_result.final_score
                )
            );
        ELSE
            -- Log de fallo en asignación
            INSERT INTO system_logs (level, message, details)
            VALUES (
                'WARNING',
                'Fallo en auto-asignación',
                jsonb_build_object(
                    'order_id', NEW.id,
                    'reason', assignment_result.message,
                    'pickup_location', jsonb_build_object('lat', pickup_lat_val, 'lng', pickup_lng_val)
                )
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger
DROP TRIGGER IF EXISTS trigger_auto_assign_on_order_create ON orders;
CREATE TRIGGER trigger_auto_assign_on_order_create
    BEFORE INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trigger_auto_assign_delivery();

-- -----------------------------------------------------
-- 11. FUNCIÓN: Estadísticas de asignación
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_assignment_statistics(
    start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    end_date DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
    total_orders INTEGER,
    auto_assigned INTEGER,
    manual_assigned INTEGER,
    unassigned INTEGER,
    avg_assignment_time_minutes DECIMAL(8,2),
    top_delivery_person_name VARCHAR(255),
    top_delivery_person_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    WITH assignment_stats AS (
        SELECT 
            COUNT(*) as total_orders,
            COUNT(CASE WHEN assigned_at IS NOT NULL AND assigned_at = created_at THEN 1 END) as auto_assigned,
            COUNT(CASE WHEN assigned_at IS NOT NULL AND assigned_at > created_at THEN 1 END) as manual_assigned,
            COUNT(CASE WHEN delivery_person_id IS NULL THEN 1 END) as unassigned,
            AVG(EXTRACT(EPOCH FROM (assigned_at - created_at))/60) as avg_assignment_time_minutes
        FROM orders
        WHERE created_at::DATE BETWEEN start_date AND end_date
    ),
    top_delivery AS (
        SELECT 
            u.full_name,
            COUNT(o.id) as delivery_count
        FROM orders o
        JOIN users u ON o.delivery_person_id = u.id
        WHERE o.created_at::DATE BETWEEN start_date AND end_date
        GROUP BY u.id, u.full_name
        ORDER BY delivery_count DESC
        LIMIT 1
    )
    SELECT 
        ast.total_orders::INTEGER,
        ast.auto_assigned::INTEGER,
        ast.manual_assigned::INTEGER,
        ast.unassigned::INTEGER,
        ast.avg_assignment_time_minutes::DECIMAL(8,2),
        COALESCE(td.full_name, 'N/A')::VARCHAR(255),
        COALESCE(td.delivery_count, 0)::INTEGER
    FROM assignment_stats ast
    CROSS JOIN top_delivery td;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 12. Insertar datos de ejemplo
-- -----------------------------------------------------

-- Zonas de reparto de ejemplo
INSERT INTO delivery_zones (name, center_lat, center_lng, radius_km, priority_level) VALUES
('Centro Miami', 25.7617, -80.1918, 8.0, 1),
('Miami Beach', 25.7907, -80.1300, 6.0, 1),
('Coral Gables', 25.7214, -80.2683, 7.0, 2),
('Aventura', 25.9564, -80.1386, 5.0, 2),
('Hialeah', 25.8576, -80.2781, 9.0, 3);

-- Actualizar usuarios delivery con ubicaciones de ejemplo
UPDATE users 
SET 
    current_lat = 25.7617 + (RANDOM() - 0.5) * 0.1,
    current_lng = -80.1918 + (RANDOM() - 0.5) * 0.1,
    last_location_update = NOW()
WHERE role = 'delivery';

-- Inicializar performance para repartidores existentes
INSERT INTO delivery_performance (delivery_person_id, total_deliveries, completed_deliveries, avg_rating, is_available)
SELECT 
    u.id,
    FLOOR(RANDOM() * 50 + 10)::INTEGER as total_deliveries,
    FLOOR(RANDOM() * 45 + 8)::INTEGER as completed_deliveries,
    (RANDOM() * 2 + 3)::DECIMAL(3,2) as avg_rating, -- Entre 3.0 y 5.0
    true
FROM users u 
WHERE u.role = 'delivery'
ON CONFLICT (delivery_person_id) DO NOTHING;

-- -----------------------------------------------------
-- ✅ FASE 3 COMPLETADA
-- -----------------------------------------------------
-- El sistema de asignación inteligente ahora incluye:
-- ✅ Cálculo de distancias geográficas
-- ✅ Puntuación basada en múltiples factores
-- ✅ Reglas configurables por categoría/servicio
-- ✅ Asignación automática via triggers
-- ✅ Gestión de disponibilidad y carga
-- ✅ Estadísticas y monitoreo
-- ✅ Zonas de reparto optimizadas



