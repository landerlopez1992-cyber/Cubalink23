-- =====================================================
-- FIX: Corregir tabla delivery_profiles
-- =====================================================
-- Error: column "verification_status" does not exist
-- Solución: Agregar columnas faltantes a tabla existente

-- PASO 1: Agregar columnas faltantes a delivery_profiles
DO $$
BEGIN
    -- Verificar y agregar columnas a delivery_profiles
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'verification_status') THEN
        ALTER TABLE delivery_profiles ADD COLUMN verification_status VARCHAR(30) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected', 'suspended'));
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'full_name') THEN
        ALTER TABLE delivery_profiles ADD COLUMN full_name VARCHAR(200) NOT NULL DEFAULT 'Repartidor Sin Nombre';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'phone_number') THEN
        ALTER TABLE delivery_profiles ADD COLUMN phone_number VARCHAR(20) NOT NULL DEFAULT '0000000000';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'vehicle_type') THEN
        ALTER TABLE delivery_profiles ADD COLUMN vehicle_type VARCHAR(30) NOT NULL DEFAULT 'motorcycle' CHECK (vehicle_type IN ('bicycle', 'motorcycle', 'car', 'truck', 'walking'));
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'total_deliveries') THEN
        ALTER TABLE delivery_profiles ADD COLUMN total_deliveries INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'successful_deliveries') THEN
        ALTER TABLE delivery_profiles ADD COLUMN successful_deliveries INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'cancelled_deliveries') THEN
        ALTER TABLE delivery_profiles ADD COLUMN cancelled_deliveries INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'total_earnings') THEN
        ALTER TABLE delivery_profiles ADD COLUMN total_earnings DECIMAL(12,2) DEFAULT 0.00;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'average_rating') THEN
        ALTER TABLE delivery_profiles ADD COLUMN average_rating DECIMAL(3,2) DEFAULT 0.00;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'total_reviews') THEN
        ALTER TABLE delivery_profiles ADD COLUMN total_reviews INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'average_delivery_time_minutes') THEN
        ALTER TABLE delivery_profiles ADD COLUMN average_delivery_time_minutes INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'is_active') THEN
        ALTER TABLE delivery_profiles ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'is_available') THEN
        ALTER TABLE delivery_profiles ADD COLUMN is_available BOOLEAN DEFAULT false;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'current_location') THEN
        ALTER TABLE delivery_profiles ADD COLUMN current_location JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'auto_accept_orders') THEN
        ALTER TABLE delivery_profiles ADD COLUMN auto_accept_orders BOOLEAN DEFAULT false;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'max_concurrent_orders') THEN
        ALTER TABLE delivery_profiles ADD COLUMN max_concurrent_orders INTEGER DEFAULT 3;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'verified_at') THEN
        ALTER TABLE delivery_profiles ADD COLUMN verified_at TIMESTAMP;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'delivery_profiles' AND column_name = 'verified_by') THEN
        ALTER TABLE delivery_profiles ADD COLUMN verified_by UUID REFERENCES users(id);
    END IF;
END $$;

-- PASO 2: Crear tabla de asignaciones de entrega
CREATE TABLE IF NOT EXISTS delivery_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id),
    delivery_person_id UUID NOT NULL REFERENCES delivery_profiles(id),
    assigned_by UUID REFERENCES users(id),
    
    -- Estado de la asignación
    status VARCHAR(30) DEFAULT 'assigned' CHECK (status IN ('assigned', 'accepted', 'picked_up', 'in_transit', 'delivered', 'cancelled', 'failed')),
    assignment_type VARCHAR(20) DEFAULT 'automatic' CHECK (assignment_type IN ('automatic', 'manual', 'self_assigned')),
    
    -- Tiempos de la entrega
    assigned_at TIMESTAMP DEFAULT NOW(),
    accepted_at TIMESTAMP,
    pickup_at TIMESTAMP,
    delivered_at TIMESTAMP,
    estimated_delivery_time TIMESTAMP,
    actual_delivery_time TIMESTAMP,
    
    -- Ubicaciones
    pickup_location JSONB NOT NULL DEFAULT '{}',
    delivery_location JSONB NOT NULL DEFAULT '{}',
    current_location JSONB,
    
    -- Detalles de la entrega
    delivery_instructions TEXT,
    customer_notes TEXT,
    delivery_photo_url TEXT,
    customer_signature_url TEXT,
    delivery_code VARCHAR(10),
    
    -- Distancias y tiempos
    estimated_distance_km DECIMAL(8,2),
    actual_distance_km DECIMAL(8,2),
    estimated_duration_minutes INTEGER,
    actual_duration_minutes INTEGER,
    
    -- Earnings para el repartidor
    base_fee DECIMAL(8,2) NOT NULL DEFAULT 5.00,
    distance_fee DECIMAL(8,2) DEFAULT 0.00,
    time_bonus DECIMAL(8,2) DEFAULT 0.00,
    tip_amount DECIMAL(8,2) DEFAULT 0.00,
    total_earnings DECIMAL(10,2) NOT NULL DEFAULT 5.00,
    
    -- Seguimiento de problemas
    issues_reported JSONB DEFAULT '[]',
    resolution_notes TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_delivery_assignments_order ON delivery_assignments(order_id);
CREATE INDEX IF NOT EXISTS idx_delivery_assignments_delivery_person ON delivery_assignments(delivery_person_id);
CREATE INDEX IF NOT EXISTS idx_delivery_assignments_status ON delivery_assignments(status);

-- PASO 3: Crear tabla de ganancias de repartidores
CREATE TABLE IF NOT EXISTS delivery_earnings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_person_id UUID NOT NULL REFERENCES delivery_profiles(id) ON DELETE CASCADE,
    assignment_id UUID NOT NULL REFERENCES delivery_assignments(id),
    order_id UUID NOT NULL REFERENCES orders(id),
    
    -- Cálculo detallado de ganancias
    base_amount DECIMAL(8,2) NOT NULL,
    distance_amount DECIMAL(8,2) DEFAULT 0.00,
    time_bonus DECIMAL(8,2) DEFAULT 0.00,
    customer_tip DECIMAL(8,2) DEFAULT 0.00,
    platform_bonus DECIMAL(8,2) DEFAULT 0.00,
    gross_amount DECIMAL(10,2) NOT NULL,
    
    -- Deducciones
    platform_commission DECIMAL(8,2) DEFAULT 0.00,
    fuel_allowance DECIMAL(6,2) DEFAULT 0.00,
    insurance_deduction DECIMAL(6,2) DEFAULT 0.00,
    other_deductions DECIMAL(8,2) DEFAULT 0.00,
    net_amount DECIMAL(10,2) NOT NULL,
    
    -- Estado del pago
    payment_status VARCHAR(30) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'cancelled', 'disputed')),
    payment_date TIMESTAMP,
    payment_method VARCHAR(50),
    payment_reference VARCHAR(100),
    
    -- Información adicional
    earning_date DATE DEFAULT CURRENT_DATE,
    week_number INTEGER DEFAULT EXTRACT(WEEK FROM NOW()),
    month_number INTEGER DEFAULT EXTRACT(MONTH FROM NOW()),
    year_number INTEGER DEFAULT EXTRACT(YEAR FROM NOW()),
    
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_delivery_earnings_delivery_person ON delivery_earnings(delivery_person_id);
CREATE INDEX IF NOT EXISTS idx_delivery_earnings_assignment ON delivery_earnings(assignment_id);
CREATE INDEX IF NOT EXISTS idx_delivery_earnings_date ON delivery_earnings(earning_date);
CREATE INDEX IF NOT EXISTS idx_delivery_earnings_status ON delivery_earnings(payment_status);

-- PASO 4: Crear tabla de reseñas de repartidores
CREATE TABLE IF NOT EXISTS delivery_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_person_id UUID NOT NULL REFERENCES delivery_profiles(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES users(id),
    order_id UUID NOT NULL REFERENCES orders(id),
    assignment_id UUID NOT NULL REFERENCES delivery_assignments(id),
    
    -- Calificaciones específicas
    overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),
    politeness_rating INTEGER CHECK (politeness_rating >= 1 AND politeness_rating <= 5),
    product_handling_rating INTEGER CHECK (product_handling_rating >= 1 AND product_handling_rating <= 5),
    communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
    
    -- Comentarios
    title VARCHAR(200),
    comment TEXT,
    
    -- Imágenes de la reseña
    review_images TEXT[] DEFAULT ARRAY[]::TEXT[],
    
    -- Estado
    is_verified BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    
    -- Respuesta del repartidor
    delivery_person_response TEXT,
    delivery_person_response_date TIMESTAMP,
    
    -- Moderación
    moderation_status VARCHAR(30) DEFAULT 'approved' CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'hidden')),
    moderated_by UUID REFERENCES users(id),
    moderated_at TIMESTAMP,
    moderation_notes TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_delivery_reviews_delivery_person ON delivery_reviews(delivery_person_id);
CREATE INDEX IF NOT EXISTS idx_delivery_reviews_customer ON delivery_reviews(customer_id);
CREATE INDEX IF NOT EXISTS idx_delivery_reviews_order ON delivery_reviews(order_id);
CREATE INDEX IF NOT EXISTS idx_delivery_reviews_rating ON delivery_reviews(overall_rating);

-- PASO 5: Crear funciones simplificadas

-- Función de registro de repartidor (simplificada)
CREATE OR REPLACE FUNCTION register_delivery_person_simple(
    user_id_param UUID,
    full_name_param VARCHAR(200),
    phone_number_param VARCHAR(20),
    vehicle_type_param VARCHAR(30) DEFAULT 'motorcycle'
) RETURNS TABLE (
    success BOOLEAN,
    delivery_person_id UUID,
    message TEXT
) AS $$
DECLARE
    new_delivery_id UUID;
BEGIN
    -- Verificar que el usuario existe
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = user_id_param) THEN
        RETURN QUERY SELECT false, NULL::UUID, 'Usuario no encontrado';
        RETURN;
    END IF;
    
    -- Verificar que no es repartidor
    IF EXISTS (SELECT 1 FROM delivery_profiles WHERE user_id = user_id_param) THEN
        RETURN QUERY SELECT false, NULL::UUID, 'El usuario ya es repartidor';
        RETURN;
    END IF;
    
    -- Crear perfil de repartidor
    INSERT INTO delivery_profiles (
        user_id, full_name, phone_number, vehicle_type
    ) VALUES (
        user_id_param, full_name_param, phone_number_param, vehicle_type_param
    ) RETURNING id INTO new_delivery_id;
    
    -- Actualizar rol del usuario
    UPDATE users 
    SET 
        role = 'delivery',
        updated_at = NOW()
    WHERE id = user_id_param;
    
    RETURN QUERY SELECT true, new_delivery_id, 'Repartidor registrado exitosamente';
    
END;
$$ LANGUAGE plpgsql;

-- Función de asignación automática (simplificada)
CREATE OR REPLACE FUNCTION auto_assign_delivery_simple(
    order_id_param UUID
) RETURNS TABLE (
    success BOOLEAN,
    assignment_id UUID,
    delivery_person_id UUID,
    message TEXT
) AS $$
DECLARE
    order_record RECORD;
    best_delivery_person RECORD;
    new_assignment_id UUID;
BEGIN
    -- Obtener datos del pedido
    SELECT o.id, o.user_id, o.total
    INTO order_record
    FROM orders o
    WHERE o.id = order_id_param;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, NULL::UUID, NULL::UUID, 'Pedido no encontrado';
        RETURN;
    END IF;
    
    -- Verificar que no hay asignación previa
    IF EXISTS (SELECT 1 FROM delivery_assignments WHERE order_id = order_id_param) THEN
        RETURN QUERY SELECT false, NULL::UUID, NULL::UUID, 'El pedido ya tiene un repartidor asignado';
        RETURN;
    END IF;
    
    -- Buscar repartidor disponible
    SELECT dp.id, dp.user_id, dp.full_name
    INTO best_delivery_person
    FROM delivery_profiles dp
    WHERE dp.verification_status = 'verified'
      AND dp.is_active = true
      AND dp.is_available = true
    ORDER BY dp.total_deliveries DESC, dp.average_rating DESC
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, NULL::UUID, NULL::UUID, 'No hay repartidores disponibles';
        RETURN;
    END IF;
    
    -- Crear asignación básica
    INSERT INTO delivery_assignments (
        order_id, delivery_person_id, assignment_type,
        pickup_location, delivery_location,
        estimated_delivery_time, base_fee, total_earnings
    ) VALUES (
        order_id_param, best_delivery_person.id, 'automatic',
        '{"lat": -23.5505, "lng": -46.6333}', '{"lat": -23.5505, "lng": -46.6333}',
        NOW() + INTERVAL '30 minutes', 5.00, 7.50
    ) RETURNING id INTO new_assignment_id;
    
    -- Actualizar estado del pedido
    UPDATE orders 
    SET 
        status = 'assigned_for_delivery',
        updated_at = NOW()
    WHERE id = order_id_param;
    
    RETURN QUERY SELECT true, new_assignment_id, best_delivery_person.id, 
                 format('Pedido asignado a %s', best_delivery_person.full_name);
    
END;
$$ LANGUAGE plpgsql;

-- PASO 6: Crear vista dashboard simplificada
CREATE OR REPLACE VIEW delivery_dashboard AS
SELECT 
    dp.id as delivery_person_id,
    COALESCE(dp.full_name, 'Sin Nombre') as full_name,
    COALESCE(dp.vehicle_type, 'motorcycle') as vehicle_type,
    COALESCE(dp.verification_status, 'pending') as verification_status,
    COALESCE(dp.is_active, true) as is_active,
    COALESCE(dp.is_available, false) as is_available,
    COALESCE(dp.total_deliveries, 0) as total_deliveries,
    COALESCE(dp.successful_deliveries, 0) as successful_deliveries,
    COALESCE(dp.cancelled_deliveries, 0) as cancelled_deliveries,
    COALESCE(dp.total_earnings, 0.00) as total_earnings,
    COALESCE(dp.average_rating, 0.00) as average_rating,
    COALESCE(dp.total_reviews, 0) as total_reviews,
    COALESCE(dp.average_delivery_time_minutes, 0) as average_delivery_time_minutes,
    u.name as user_name,
    u.email as user_email,
    u.phone as user_phone,
    dp.created_at as registration_date,
    dp.verified_at,
    CASE 
        WHEN dp.total_deliveries > 0 THEN 
            ROUND((dp.successful_deliveries::DECIMAL / dp.total_deliveries * 100), 2)
        ELSE 0 
    END as success_rate_percentage,
    (SELECT COUNT(*) FROM delivery_assignments WHERE delivery_person_id = dp.id AND status IN ('assigned', 'accepted', 'picked_up', 'in_transit')) as current_active_deliveries,
    (SELECT COALESCE(SUM(net_amount), 0) FROM delivery_earnings WHERE delivery_person_id = dp.id AND payment_status = 'pending') as pending_payments
FROM delivery_profiles dp
JOIN users u ON dp.user_id = u.id
ORDER BY dp.total_earnings DESC, dp.average_rating DESC;

-- ✅ FIX COMPLETADO - SISTEMA DE REPARTIDORES CORREGIDO
SELECT 'Sistema de repartidores corregido y completado exitosamente' as message;


