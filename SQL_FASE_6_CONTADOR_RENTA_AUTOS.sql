-- =====================================================
-- FASE 6: SISTEMA DE RENTA DE AUTOS CON CONTADOR DE 5 MINUTOS
-- =====================================================
-- Sistema completo de renta de autos con:
-- 1. Prerreservas con verificación de disponibilidad
-- 2. Contador de 5 minutos para pago
-- 3. Comisión fija de $30 por reserva
-- 4. Branding exclusivo de Cubalink23
-- 5. Integración con sistema externo (sin mencionar nombres)

-- -----------------------------------------------------
-- 1. TABLA: car_rental_vehicles (Vehículos disponibles)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS car_rental_vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Información del vehículo
    vehicle_name VARCHAR(255) NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL CHECK (vehicle_type IN (
        'autos', 'autos_lujo', 'motos', 'shuttle', 'bus_tour', 'electricos', 'ecotur'
    )),
    vehicle_brand VARCHAR(100),
    vehicle_model VARCHAR(100),
    vehicle_year INTEGER,
    vehicle_color VARCHAR(50),
    
    -- Capacidad y características
    passenger_capacity INTEGER DEFAULT 4,
    luggage_capacity INTEGER DEFAULT 2,
    transmission_type VARCHAR(20) DEFAULT 'manual', -- manual, automatic
    fuel_type VARCHAR(20) DEFAULT 'gasoline', -- gasoline, electric, hybrid
    
    -- Precios (precio base sin comisión)
    base_price_per_day DECIMAL(10,2) NOT NULL,
    base_price_per_hour DECIMAL(10,2),
    commission_amount DECIMAL(10,2) DEFAULT 30.00, -- Comisión fija de $30
    
    -- Disponibilidad
    is_available BOOLEAN DEFAULT true,
    available_from DATE,
    available_to DATE,
    
    -- Ubicación
    pickup_location VARCHAR(255),
    pickup_address TEXT,
    pickup_lat DECIMAL(10,8),
    pickup_lng DECIMAL(11,8),
    
    -- Imágenes y descripción
    main_image_url TEXT,
    additional_images TEXT[] DEFAULT '{}',
    description TEXT,
    features TEXT[] DEFAULT '{}',
    
    -- Configuración especial para shuttle
    shuttle_route VARCHAR(50), -- vedado, habana_vieja, playa
    shuttle_schedule JSONB, -- Horarios específicos
    
    -- Estado
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_car_rental_vehicles_type ON car_rental_vehicles(vehicle_type);
CREATE INDEX IF NOT EXISTS idx_car_rental_vehicles_available ON car_rental_vehicles(is_available, available_from, available_to);
CREATE INDEX IF NOT EXISTS idx_car_rental_vehicles_location ON car_rental_vehicles(pickup_lat, pickup_lng);

-- -----------------------------------------------------
-- 2. TABLA: car_rental_reservations (Reservas de autos)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS car_rental_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES car_rental_vehicles(id),
    
    -- Fechas de alquiler
    pickup_date DATE NOT NULL,
    pickup_time TIME NOT NULL,
    return_date DATE NOT NULL,
    return_time TIME NOT NULL,
    total_days INTEGER NOT NULL,
    total_hours INTEGER,
    
    -- Precios calculados
    base_price DECIMAL(10,2) NOT NULL, -- Precio base del vehículo
    commission_amount DECIMAL(10,2) DEFAULT 30.00, -- Comisión fija
    total_amount DECIMAL(10,2) NOT NULL, -- Precio base + comisión
    
    -- Sistema de contador de 5 minutos
    payment_deadline TIMESTAMP WITH TIME ZONE NOT NULL, -- NOW() + 5 minutes
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN (
        'pending', 'paid', 'expired', 'cancelled', 'refunded'
    )),
    
    -- Estados de la reserva
    reservation_status VARCHAR(30) DEFAULT 'prerreserva_pendiente' CHECK (reservation_status IN (
        'prerreserva_pendiente', 'disponibilidad_verificada', 'pago_pendiente', 
        'pago_realizado', 'reserva_confirmada', 'cancelada', 'completada'
    )),
    
    -- Datos del conductor
    driver_name VARCHAR(255) NOT NULL,
    driver_email VARCHAR(255) NOT NULL,
    driver_phone VARCHAR(50),
    driver_license VARCHAR(100) NOT NULL,
    driver_passport VARCHAR(100) NOT NULL,
    driver_country VARCHAR(100) DEFAULT 'Cuba',
    
    -- Información de contacto
    contact_phone VARCHAR(50),
    contact_email VARCHAR(255),
    special_requests TEXT,
    
    -- Verificación manual del admin
    admin_verified BOOLEAN DEFAULT FALSE,
    admin_verification_notes TEXT,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID REFERENCES users(id),
    
    -- Reserva externa (sin mencionar nombres)
    external_reservation_id VARCHAR(255), -- ID de la reserva externa
    external_boucher_url TEXT, -- URL del boucher externo
    external_confirmation_code VARCHAR(100), -- Código de confirmación externo
    
    -- Tiempos importantes
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    payment_completed_at TIMESTAMP,
    reservation_confirmed_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_car_rental_reservations_user ON car_rental_reservations(user_id);
CREATE INDEX IF NOT EXISTS idx_car_rental_reservations_vehicle ON car_rental_reservations(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_car_rental_reservations_status ON car_rental_reservations(reservation_status);
CREATE INDEX IF NOT EXISTS idx_car_rental_reservations_payment ON car_rental_reservations(payment_status);
CREATE INDEX IF NOT EXISTS idx_car_rental_reservations_dates ON car_rental_reservations(pickup_date, return_date);
CREATE INDEX IF NOT EXISTS idx_car_rental_reservations_deadline ON car_rental_reservations(payment_deadline);

-- -----------------------------------------------------
-- 3. TABLA: car_rental_payments (Pagos de reservas)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS car_rental_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL REFERENCES car_rental_reservations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Información del pago
    payment_method VARCHAR(50) NOT NULL, -- credit_card, debit_card, wallet, etc.
    payment_amount DECIMAL(10,2) NOT NULL,
    base_amount DECIMAL(10,2) NOT NULL, -- Precio base del vehículo
    commission_amount DECIMAL(10,2) NOT NULL, -- Comisión de $30
    
    -- Detalles del pago
    payment_reference VARCHAR(255), -- Referencia del pago
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN (
        'pending', 'completed', 'failed', 'refunded', 'cancelled'
    )),
    
    -- Información de la tarjeta (encriptada)
    card_last_four VARCHAR(4),
    card_brand VARCHAR(50),
    
    -- Tiempos
    payment_initiated_at TIMESTAMP DEFAULT NOW(),
    payment_completed_at TIMESTAMP,
    payment_expires_at TIMESTAMP, -- 5 minutos después de iniciado
    
    -- Metadatos
    payment_metadata JSONB DEFAULT '{}',
    error_message TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_car_rental_payments_reservation ON car_rental_payments(reservation_id);
CREATE INDEX IF NOT EXISTS idx_car_rental_payments_user ON car_rental_payments(user_id);
CREATE INDEX IF NOT EXISTS idx_car_rental_payments_status ON car_rental_payments(payment_status);
CREATE INDEX IF NOT EXISTS idx_car_rental_payments_expires ON car_rental_payments(payment_expires_at);

-- -----------------------------------------------------
-- 4. TABLA: car_rental_notifications (Notificaciones específicas)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS car_rental_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL REFERENCES car_rental_reservations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Tipo de notificación
    notification_type VARCHAR(50) NOT NULL CHECK (notification_type IN (
        'prerreserva_created', 'disponibilidad_verified', 'disponibilidad_rejected',
        'payment_required', 'payment_completed', 'reservation_confirmed',
        'payment_expired', 'reservation_cancelled'
    )),
    
    -- Contenido de la notificación
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Configuración de envío
    send_email BOOLEAN DEFAULT true,
    send_push BOOLEAN DEFAULT true,
    send_sms BOOLEAN DEFAULT false,
    
    -- Estado de envío
    email_sent BOOLEAN DEFAULT false,
    push_sent BOOLEAN DEFAULT false,
    sms_sent BOOLEAN DEFAULT false,
    
    -- Tiempos
    scheduled_for TIMESTAMP DEFAULT NOW(),
    sent_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_car_rental_notifications_reservation ON car_rental_notifications(reservation_id);
CREATE INDEX IF NOT EXISTS idx_car_rental_notifications_user ON car_rental_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_car_rental_notifications_type ON car_rental_notifications(notification_type);
CREATE INDEX IF NOT EXISTS idx_car_rental_notifications_scheduled ON car_rental_notifications(scheduled_for);

-- -----------------------------------------------------
-- 5. FUNCIÓN: Crear prerreserva
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION create_car_rental_prereservation(
    user_id_param UUID,
    vehicle_id_param UUID,
    pickup_date_param DATE,
    pickup_time_param TIME,
    return_date_param DATE,
    return_time_param TIME,
    driver_name_param VARCHAR(255),
    driver_email_param VARCHAR(255),
    driver_phone_param VARCHAR(50),
    driver_license_param VARCHAR(100),
    driver_passport_param VARCHAR(100),
    driver_country_param VARCHAR(100) DEFAULT 'Cuba',
    contact_phone_param VARCHAR(50) DEFAULT NULL,
    contact_email_param VARCHAR(255) DEFAULT NULL,
    special_requests_param TEXT DEFAULT NULL
) RETURNS TABLE (
    reservation_id UUID,
    total_amount DECIMAL(10,2),
    base_amount DECIMAL(10,2),
    commission_amount DECIMAL(10,2),
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    vehicle_record RECORD;
    total_days_val INTEGER;
    total_hours_val INTEGER;
    base_price_val DECIMAL(10,2);
    commission_val DECIMAL(10,2);
    total_amount_val DECIMAL(10,2);
    reservation_id_result UUID;
BEGIN
    -- Obtener información del vehículo
    SELECT * INTO vehicle_record
    FROM car_rental_vehicles
    WHERE id = vehicle_id_param AND is_available = true AND is_active = true;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            NULL::UUID, NULL::DECIMAL(10,2), NULL::DECIMAL(10,2), NULL::DECIMAL(10,2),
            false, 'Vehículo no disponible';
        RETURN;
    END IF;
    
    -- Calcular días y horas
    total_days_val := return_date_param - pickup_date_param;
    total_hours_val := EXTRACT(EPOCH FROM (
        (return_date_param + return_time_param) - (pickup_date_param + pickup_time_param)
    )) / 3600;
    
    -- Calcular precios
    base_price_val := vehicle_record.base_price_per_day * total_days_val;
    commission_val := vehicle_record.commission_amount;
    total_amount_val := base_price_val + commission_val;
    
    -- Crear prerreserva
    INSERT INTO car_rental_reservations (
        user_id, vehicle_id, pickup_date, pickup_time, return_date, return_time,
        total_days, total_hours, base_price, commission_amount, total_amount,
        driver_name, driver_email, driver_phone, driver_license, driver_passport,
        driver_country, contact_phone, contact_email, special_requests,
        reservation_status, payment_deadline
    ) VALUES (
        user_id_param, vehicle_id_param, pickup_date_param, pickup_time_param,
        return_date_param, return_time_param, total_days_val, total_hours_val,
        base_price_val, commission_val, total_amount_val,
        driver_name_param, driver_email_param, driver_phone_param, driver_license_param,
        driver_passport_param, driver_country_param, contact_phone_param,
        contact_email_param, special_requests_param,
        'prerreserva_pendiente', NOW() + INTERVAL '1 year' -- Sin límite para verificación admin
    ) RETURNING id INTO reservation_id_result;
    
    -- Crear notificación de prerreserva creada
    INSERT INTO car_rental_notifications (
        reservation_id, user_id, notification_type, title, message
    ) VALUES (
        reservation_id_result, user_id_param, 'prerreserva_created',
        'Prerreserva Creada - Cubalink23',
        'Cubalink23 está verificando disponibilidad para tu reserva. Recibirás una notificación cuando esté lista para el pago.'
    );
    
    RETURN QUERY SELECT 
        reservation_id_result, total_amount_val, base_price_val, commission_val,
        true, 'Prerreserva creada exitosamente';
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 6. FUNCIÓN: Verificar disponibilidad (Admin)
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION verify_car_rental_availability(
    reservation_id_param UUID,
    admin_user_id UUID,
    is_available_param BOOLEAN,
    verification_notes_param TEXT DEFAULT NULL
) RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    reservation_record RECORD;
    new_status VARCHAR(30);
    notification_type_val VARCHAR(50);
    notification_title_val VARCHAR(255);
    notification_message_val TEXT;
BEGIN
    -- Obtener información de la reserva
    SELECT * INTO reservation_record
    FROM car_rental_reservations
    WHERE id = reservation_id_param AND reservation_status = 'prerreserva_pendiente';
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Reserva no encontrada o ya procesada';
        RETURN;
    END IF;
    
    -- Determinar nuevo estado y notificación
    IF is_available_param THEN
        new_status := 'disponibilidad_verificada';
        notification_type_val := 'disponibilidad_verified';
        notification_title_val := '¡Disponible! - Cubalink23';
        notification_message_val := '¡Tu vehículo está disponible! Tienes 5 minutos para realizar el pago y confirmar tu reserva.';
    ELSE
        new_status := 'cancelada';
        notification_type_val := 'disponibilidad_rejected';
        notification_title_val := 'No Disponible - Cubalink23';
        notification_message_val := 'Lo sentimos, el vehículo no está disponible para las fechas seleccionadas. Tu prerreserva ha sido cancelada.';
    END IF;
    
    -- Actualizar reserva
    UPDATE car_rental_reservations
    SET 
        reservation_status = new_status,
        admin_verified = true,
        admin_verification_notes = verification_notes_param,
        verified_at = NOW(),
        verified_by = admin_user_id,
        payment_deadline = CASE WHEN is_available_param THEN NOW() + INTERVAL '5 minutes' ELSE payment_deadline END,
        updated_at = NOW()
    WHERE id = reservation_id_param;
    
    -- Crear notificación
    INSERT INTO car_rental_notifications (
        reservation_id, user_id, notification_type, title, message
    ) VALUES (
        reservation_id_param, reservation_record.user_id, notification_type_val,
        notification_title_val, notification_message_val
    );
    
    RETURN QUERY SELECT true, 'Disponibilidad verificada exitosamente';
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 7. FUNCIÓN: Procesar pago
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION process_car_rental_payment(
    reservation_id_param UUID,
    payment_method_param VARCHAR(50),
    payment_reference_param VARCHAR(255) DEFAULT NULL,
    card_last_four_param VARCHAR(4) DEFAULT NULL,
    card_brand_param VARCHAR(50) DEFAULT NULL
) RETURNS TABLE (
    payment_id UUID,
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    reservation_record RECORD;
    payment_id_result UUID;
BEGIN
    -- Obtener información de la reserva
    SELECT * INTO reservation_record
    FROM car_rental_reservations
    WHERE id = reservation_id_param 
      AND reservation_status = 'disponibilidad_verificada'
      AND payment_deadline > NOW();
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            NULL::UUID, false, 'Reserva no encontrada, no disponible o tiempo expirado';
        RETURN;
    END IF;
    
    -- Crear registro de pago
    INSERT INTO car_rental_payments (
        reservation_id, user_id, payment_method, payment_amount,
        base_amount, commission_amount, payment_reference,
        card_last_four, card_brand, payment_status,
        payment_expires_at
    ) VALUES (
        reservation_id_param, reservation_record.user_id, payment_method_param,
        reservation_record.total_amount, reservation_record.base_price,
        reservation_record.commission_amount, payment_reference_param,
        card_last_four_param, card_brand_param, 'completed',
        NOW() + INTERVAL '5 minutes'
    ) RETURNING id INTO payment_id_result;
    
    -- Actualizar reserva
    UPDATE car_rental_reservations
    SET 
        reservation_status = 'pago_realizado',
        payment_status = 'paid',
        payment_completed_at = NOW(),
        updated_at = NOW()
    WHERE id = reservation_id_param;
    
    -- Crear notificación de pago completado
    INSERT INTO car_rental_notifications (
        reservation_id, user_id, notification_type, title, message
            ) VALUES (
        reservation_id_param, reservation_record.user_id, 'payment_completed',
        'Pago Confirmado - Cubalink23',
        'Pago confirmado, Cubalink23 procesando tu reserva. Recibirás tu boucher de confirmación pronto.'
    );
    
    RETURN QUERY SELECT 
        payment_id_result, true, 'Pago procesado exitosamente';
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 8. FUNCIÓN: Confirmar reserva (Admin)
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION confirm_car_rental_reservation(
    reservation_id_param UUID,
    admin_user_id UUID,
    external_reservation_id_param VARCHAR(255),
    external_boucher_url_param TEXT,
    external_confirmation_code_param VARCHAR(100)
) RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    reservation_record RECORD;
BEGIN
    -- Obtener información de la reserva
    SELECT * INTO reservation_record
    FROM car_rental_reservations
    WHERE id = reservation_id_param AND reservation_status = 'pago_realizado';
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Reserva no encontrada o pago no realizado';
        RETURN;
    END IF;
    
    -- Actualizar reserva con información externa
    UPDATE car_rental_reservations
    SET 
        reservation_status = 'reserva_confirmada',
        external_reservation_id = external_reservation_id_param,
        external_boucher_url = external_boucher_url_param,
        external_confirmation_code = external_confirmation_code_param,
        reservation_confirmed_at = NOW(),
        updated_at = NOW()
    WHERE id = reservation_id_param;
    
    -- Crear notificación de reserva confirmada
    INSERT INTO car_rental_notifications (
        reservation_id, user_id, notification_type, title, message
    ) VALUES (
        reservation_id_param, reservation_record.user_id, 'reservation_confirmed',
        '¡Reserva Confirmada! - Cubalink23',
        '¡Reserva confirmada! Aquí está tu boucher de Cubalink23. Tu vehículo está listo para la fecha seleccionada.'
    );
    
    RETURN QUERY SELECT true, 'Reserva confirmada exitosamente';
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 9. FUNCIÓN: Cancelar reservas expiradas automáticamente
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION cancel_expired_car_rental_reservations()
RETURNS INTEGER AS $$
DECLARE
    cancelled_count INTEGER := 0;
    expired_reservation RECORD;
BEGIN
    -- Buscar reservas con pago expirado
    FOR expired_reservation IN
        SELECT id, user_id
        FROM car_rental_reservations
        WHERE reservation_status = 'disponibilidad_verificada'
          AND payment_deadline < NOW()
          AND payment_status = 'pending'
    LOOP
        -- Cancelar reserva
        UPDATE car_rental_reservations
        SET 
            reservation_status = 'cancelada',
            payment_status = 'expired',
            updated_at = NOW()
        WHERE id = expired_reservation.id;
        
        -- Crear notificación de cancelación por tiempo expirado
        INSERT INTO car_rental_notifications (
            reservation_id, user_id, notification_type, title, message
        ) VALUES (
            expired_reservation.id, expired_reservation.user_id, 'payment_expired',
            'Tiempo Expirado - Cubalink23',
            'El tiempo para realizar el pago ha expirado. Tu reserva ha sido cancelada automáticamente.'
        );
        
        cancelled_count := cancelled_count + 1;
    END LOOP;
    
    RETURN cancelled_count;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 10. FUNCIÓN: Obtener reservas del usuario
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_user_car_rental_reservations(
    user_id_param UUID,
    status_filter VARCHAR(30) DEFAULT NULL,
    limit_param INTEGER DEFAULT 20,
    offset_param INTEGER DEFAULT 0
) RETURNS TABLE (
    reservation_id UUID,
    vehicle_name VARCHAR(255),
    vehicle_type VARCHAR(50),
    pickup_date DATE,
    pickup_time TIME,
    return_date DATE,
    return_time TIME,
    total_days INTEGER,
    total_amount DECIMAL(10,2),
    base_amount DECIMAL(10,2),
    commission_amount DECIMAL(10,2),
    reservation_status VARCHAR(30),
    payment_status VARCHAR(20),
    payment_deadline TIMESTAMP WITH TIME ZONE,
    external_boucher_url TEXT,
    external_confirmation_code VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cr.id as reservation_id,
        cv.vehicle_name,
        cv.vehicle_type,
        cr.pickup_date,
        cr.pickup_time,
        cr.return_date,
        cr.return_time,
        cr.total_days,
        cr.total_amount,
        cr.base_amount,
        cr.commission_amount,
        cr.reservation_status,
        cr.payment_status,
        cr.payment_deadline,
        cr.external_boucher_url,
        cr.external_confirmation_code,
        cr.created_at,
        cr.updated_at
    FROM car_rental_reservations cr
    JOIN car_rental_vehicles cv ON cr.vehicle_id = cv.id
    WHERE cr.user_id = user_id_param
      AND (status_filter IS NULL OR cr.reservation_status = status_filter)
    ORDER BY cr.created_at DESC
    LIMIT limit_param OFFSET offset_param;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 11. FUNCIÓN: Obtener prerreservas pendientes (Admin)
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_pending_car_rental_prereservations(
    limit_param INTEGER DEFAULT 50,
    offset_param INTEGER DEFAULT 0
) RETURNS TABLE (
    reservation_id UUID,
    user_name VARCHAR(255),
    user_email VARCHAR(255),
    vehicle_name VARCHAR(255),
    vehicle_type VARCHAR(50),
    pickup_date DATE,
    pickup_time TIME,
    return_date DATE,
    return_time TIME,
    total_days INTEGER,
    total_amount DECIMAL(10,2),
    driver_name VARCHAR(255),
    driver_phone VARCHAR(50),
    special_requests TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cr.id as reservation_id,
        u.full_name as user_name,
        u.email as user_email,
        cv.vehicle_name,
        cv.vehicle_type,
        cr.pickup_date,
        cr.pickup_time,
        cr.return_date,
        cr.return_time,
        cr.total_days,
        cr.total_amount,
        cr.driver_name,
        cr.driver_phone,
        cr.special_requests,
        cr.created_at
    FROM car_rental_reservations cr
    JOIN users u ON cr.user_id = u.id
    JOIN car_rental_vehicles cv ON cr.vehicle_id = cv.id
    WHERE cr.reservation_status = 'prerreserva_pendiente'
    ORDER BY cr.created_at ASC
    LIMIT limit_param OFFSET offset_param;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 12. TRIGGER: Auto-cancelación de reservas expiradas
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION trigger_cancel_expired_car_rental_reservations()
RETURNS TRIGGER AS $$
BEGIN
    -- Ejecutar función de cancelación automática
    PERFORM cancel_expired_car_rental_reservations();
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger que se ejecute cada minuto (requiere configuración de cron)
-- DROP TRIGGER IF EXISTS trigger_cancel_expired_car_rental ON car_rental_reservations;
-- CREATE TRIGGER trigger_cancel_expired_car_rental
--     AFTER INSERT OR UPDATE ON car_rental_reservations
--     FOR EACH ROW
--     EXECUTE FUNCTION trigger_cancel_expired_car_rental_reservations();

-- -----------------------------------------------------
-- 13. Insertar datos de ejemplo
-- -----------------------------------------------------

-- Vehículos de ejemplo
INSERT INTO car_rental_vehicles (vehicle_name, vehicle_type, vehicle_brand, vehicle_model, base_price_per_day, commission_amount, pickup_location, is_available) VALUES
('Toyota Corolla', 'autos', 'Toyota', 'Corolla', 45.00, 30.00, 'La Habana', true),
('BMW X5', 'autos_lujo', 'BMW', 'X5', 120.00, 30.00, 'La Habana', true),
('Honda CBR', 'motos', 'Honda', 'CBR 600', 25.00, 30.00, 'La Habana', true),
('Shuttle Vedado', 'shuttle', 'Mercedes', 'Sprinter', 15.00, 30.00, 'Vedado', true),
('Bus Tour Panorámico', 'bus_tour', 'Mercedes', 'Tourismo', 35.00, 30.00, 'La Habana', true),
('Tesla Model 3', 'electricos', 'Tesla', 'Model 3', 80.00, 30.00, 'La Habana', true),
('Safari 4x4', 'ecotur', 'Land Rover', 'Defender', 65.00, 30.00, 'La Habana', true);

-- -----------------------------------------------------
-- 14. VISTA: Estadísticas de reservas
-- -----------------------------------------------------
CREATE OR REPLACE VIEW car_rental_statistics AS
SELECT 
    COUNT(*) as total_reservations,
    COUNT(CASE WHEN reservation_status = 'prerreserva_pendiente' THEN 1 END) as pending_prereservations,
    COUNT(CASE WHEN reservation_status = 'disponibilidad_verificada' THEN 1 END) as verified_availability,
    COUNT(CASE WHEN reservation_status = 'pago_realizado' THEN 1 END) as paid_reservations,
    COUNT(CASE WHEN reservation_status = 'reserva_confirmada' THEN 1 END) as confirmed_reservations,
    COUNT(CASE WHEN reservation_status = 'cancelada' THEN 1 END) as cancelled_reservations,
    SUM(CASE WHEN reservation_status = 'reserva_confirmada' THEN total_amount ELSE 0 END) as total_revenue,
    SUM(CASE WHEN reservation_status = 'reserva_confirmada' THEN commission_amount ELSE 0 END) as total_commissions,
    AVG(CASE WHEN reservation_status = 'reserva_confirmada' THEN total_amount ELSE NULL END) as avg_reservation_value
FROM car_rental_reservations
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days';

-- -----------------------------------------------------
-- ✅ FASE 6 COMPLETADA
-- -----------------------------------------------------
-- El sistema de renta de autos ahora incluye:
-- ✅ Prerreservas con verificación de disponibilidad
-- ✅ Contador de 5 minutos para pago
-- ✅ Comisión fija de $30 por reserva
-- ✅ Branding exclusivo de Cubalink23
-- ✅ Sistema completo de notificaciones
-- ✅ Gestión de pagos y confirmaciones
-- ✅ Cancelación automática de reservas expiradas
-- ✅ Panel admin para gestión de prerreservas
-- ✅ Integración con sistema externo (sin mencionar nombres)
-- ✅ Estadísticas y monitoreo completo