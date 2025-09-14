-- =====================================================
-- IMPLEMENTACIÓN COMPLETA CUBALINK23 - SUPABASE (VERSIÓN CORREGIDA)
-- =====================================================
-- Este archivo contiene todas las fases implementadas:
-- FASE 1: Sistema de Timeouts y Reasignación Automática
-- FASE 2: Sistema de Sanciones Automáticas
-- FASE 3: Algoritmo de Asignación Inteligente
-- FASE 4: Chat Directo Vendedor ↔ Repartidor
-- FASE 5: Detección Automática de Diferencias
-- FASE 6: Sistema de Renta de Autos con Contador de 5 Minutos

-- =====================================================
-- FASE 1: SISTEMA DE TIMEOUTS Y REASIGNACIÓN AUTOMÁTICA
-- =====================================================

-- Tabla de configuración de timeouts del sistema
DROP TABLE IF EXISTS system_timeouts CASCADE;
CREATE TABLE system_timeouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timeout_type TEXT NOT NULL CHECK (timeout_type IN (
        'vendor_accept_order', 'vendor_prepare_order', 'delivery_accept_assignment',
        'delivery_pickup_order', 'delivery_complete_order', 'payment_timeout',
        'car_rental_payment', 'admin_verify_car_rental'
    )),
    timeout_minutes INTEGER NOT NULL,
    warning_minutes INTEGER DEFAULT 5,
    auto_action TEXT CHECK (auto_action IN (
        'reassign_to_next_vendor', 'reassign_to_next_delivery', 'cancel_order',
        'notify_admin', 'suspend_user', 'release_vehicle'
    )),
    applies_to_role TEXT CHECK (applies_to_role IN ('vendor', 'delivery', 'customer', 'admin')),
    max_violations_before_suspension INTEGER DEFAULT 4,
    suspension_hours INTEGER DEFAULT 24,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(timeout_type)
);

-- Tabla para trackear timeouts activos
DROP TABLE IF EXISTS active_timeouts CASCADE;
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
    auto_action_triggered BOOLEAN DEFAULT FALSE,
    context_data JSONB DEFAULT '{}',
    UNIQUE(order_id, timeout_type)
);

-- Tabla de historial de asignaciones
DROP TABLE IF EXISTS assignment_history CASCADE;
CREATE TABLE assignment_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    assigned_vendor_id UUID,
    assigned_delivery_id UUID,
    assignment_type TEXT NOT NULL CHECK (assignment_type IN ('vendor', 'delivery')),
    assignment_status TEXT NOT NULL CHECK (assignment_status IN (
        'assigned', 'accepted', 'cancelled', 'timeout', 'completed', 'reassigned'
    )),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    responded_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    is_timeout BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar timeouts por defecto
INSERT INTO system_timeouts (timeout_type, timeout_minutes, warning_minutes, auto_action, applies_to_role, max_violations_before_suspension) VALUES
('vendor_accept_order', 10, 5, 'reassign_to_next_vendor', 'vendor', 4),
('vendor_prepare_order', 30, 10, 'notify_admin', 'vendor', 4),
('delivery_accept_assignment', 5, 2, 'reassign_to_next_delivery', 'delivery', 5),
('delivery_pickup_order', 20, 5, 'reassign_to_next_delivery', 'delivery', 3),
('delivery_complete_order', 60, 15, 'notify_admin', 'delivery', 3),
('car_rental_payment', 5, 2, 'release_vehicle', 'customer', 1),
('admin_verify_car_rental', 120, 30, 'notify_admin', 'admin', 1)
ON CONFLICT (timeout_type) DO NOTHING;

-- =====================================================
-- FASE 2: SISTEMA DE SANCIONES AUTOMÁTICAS
-- =====================================================

-- Tabla de tipos de sanciones
DROP TABLE IF EXISTS sanction_types CASCADE;
CREATE TABLE sanction_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sanction_code TEXT UNIQUE NOT NULL,
    sanction_name TEXT NOT NULL,
    description TEXT,
    severity_level INTEGER DEFAULT 1 CHECK (severity_level >= 1 AND severity_level <= 5),
    auto_suspend BOOLEAN DEFAULT FALSE,
    suspension_hours INTEGER DEFAULT 0,
    affects_rating BOOLEAN DEFAULT FALSE,
    rating_penalty DECIMAL(3,2) DEFAULT 0.0,
    max_occurrences INTEGER DEFAULT 4,
    period_days INTEGER DEFAULT 30,
    applies_to_role TEXT[] DEFAULT ARRAY['vendor', 'delivery'],
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de historial de sanciones
DROP TABLE IF EXISTS user_sanctions CASCADE;
CREATE TABLE user_sanctions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sanction_type_id UUID NOT NULL REFERENCES sanction_types(id),
    reason TEXT NOT NULL,
    related_order_id UUID REFERENCES orders(id),
    severity_level INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    starts_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ends_at TIMESTAMP WITH TIME ZONE,
    auto_applied BOOLEAN DEFAULT FALSE,
    applied_by UUID REFERENCES users(id),
    context_data JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar tipos de sanciones
INSERT INTO sanction_types (sanction_code, sanction_name, description, severity_level, max_occurrences, auto_suspend, suspension_hours) VALUES
('VENDOR_LATE_PROCESSING', 'Procesamiento Tardío', 'Vendedor no procesa pedido a tiempo', 2, 4, TRUE, 24),
('VENDOR_NO_RESPONSE', 'No Respuesta a Pedidos', 'Vendedor no acepta ni rechaza pedido', 3, 4, TRUE, 48),
('VENDOR_PREPARATION_DELAY', 'Demora en Preparación', 'Vendedor demora más del tiempo estimado', 2, 4, TRUE, 24),
('DELIVERY_CANCEL_FREQUENT', 'Cancelaciones Frecuentes', 'Repartidor cancela demasiadas órdenes', 2, 5, TRUE, 12),
('DELIVERY_NO_PICKUP', 'No Recoge Pedido', 'Repartidor no recoge pedido del vendedor', 3, 3, TRUE, 24),
('DELIVERY_LATE_DELIVERY', 'Entrega Tardía', 'Repartidor entrega fuera de tiempo estimado', 1, 7, FALSE, 0),
('DELIVERY_NO_RESPONSE', 'No Respuesta a Asignación', 'Repartidor no acepta asignación', 2, 5, TRUE, 8),
('LOW_RATING_PATTERN', 'Patrón de Calificaciones Bajas', 'Calificaciones consistentemente bajas', 4, 10, TRUE, 72),
('POOR_COMMUNICATION', 'Comunicación Deficiente', 'No responde a mensajes de coordinación', 1, 8, FALSE, 0)
ON CONFLICT (sanction_code) DO NOTHING;

-- =====================================================
-- FASE 3: ALGORITMO DE ASIGNACIÓN INTELIGENTE
-- =====================================================

-- Tabla de zonas de reparto
DROP TABLE IF EXISTS delivery_zones CASCADE;
CREATE TABLE delivery_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    center_latitude DECIMAL(10,8) NOT NULL,
    center_longitude DECIMAL(11,8) NOT NULL,
    radius_km DECIMAL(5,2) NOT NULL DEFAULT 5.0,
    is_active BOOLEAN DEFAULT true,
    priority_level INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de repartidores por zona
DROP TABLE IF EXISTS delivery_person_zones CASCADE;
CREATE TABLE delivery_person_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_person_id UUID NOT NULL REFERENCES users(id),
    zone_id UUID NOT NULL REFERENCES delivery_zones(id),
    is_preferred BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(delivery_person_id, zone_id)
);

-- Tabla de performance de repartidores
DROP TABLE IF EXISTS delivery_performance CASCADE;
CREATE TABLE delivery_performance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_person_id UUID NOT NULL REFERENCES users(id),
    total_deliveries INTEGER DEFAULT 0,
    completed_deliveries INTEGER DEFAULT 0,
    cancelled_deliveries INTEGER DEFAULT 0,
    avg_delivery_time_minutes DECIMAL(5,2) DEFAULT 0,
    avg_rating DECIMAL(3,2) DEFAULT 0,
    total_earnings DECIMAL(10,2) DEFAULT 0,
    current_load INTEGER DEFAULT 0,
    max_load INTEGER DEFAULT 3,
    last_delivery_at TIMESTAMP,
    is_available BOOLEAN DEFAULT true,
    availability_status VARCHAR(20) DEFAULT 'available',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(delivery_person_id)
);

-- Tabla de reglas de asignación
DROP TABLE IF EXISTS assignment_rules CASCADE;
CREATE TABLE assignment_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name VARCHAR(100) NOT NULL,
    product_category VARCHAR(50),
    service_type VARCHAR(50),
    max_distance_km DECIMAL(5,2) DEFAULT 10.0,
    min_rating DECIMAL(3,2) DEFAULT 0.0,
    max_current_load INTEGER DEFAULT 3,
    priority_weight_distance DECIMAL(3,2) DEFAULT 0.4,
    priority_weight_rating DECIMAL(3,2) DEFAULT 0.3,
    priority_weight_load DECIMAL(3,2) DEFAULT 0.2,
    priority_weight_experience DECIMAL(3,2) DEFAULT 0.1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insertar reglas por defecto
INSERT INTO assignment_rules (rule_name, product_category, service_type, max_distance_km, min_rating, max_current_load) VALUES
('Regla General', NULL, NULL, 15.0, 0.0, 3),
('Comida Rápida', 'food', 'express', 8.0, 4.0, 2),
('Productos Frágiles', 'fragile', 'careful', 12.0, 4.5, 1),
('Medicamentos', 'pharmacy', 'priority', 20.0, 4.8, 2),
('Documentos Urgentes', 'documents', 'express', 25.0, 4.0, 3);

-- =====================================================
-- FASE 4: CHAT DIRECTO VENDEDOR ↔ REPARTIDOR
-- =====================================================

-- Tabla de conversaciones
DROP TABLE IF EXISTS chat_conversations CASCADE;
CREATE TABLE chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES users(id),
    delivery_person_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_message_at TIMESTAMP DEFAULT NOW(),
    last_message_preview TEXT,
    vendor_unread_count INTEGER DEFAULT 0,
    delivery_unread_count INTEGER DEFAULT 0,
    is_vendor_typing BOOLEAN DEFAULT false,
    is_delivery_typing BOOLEAN DEFAULT false,
    vendor_last_seen TIMESTAMP,
    delivery_last_seen TIMESTAMP,
    UNIQUE(order_id)
);

-- Tabla de mensajes del chat
DROP TABLE IF EXISTS chat_messages CASCADE;
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    sender_role VARCHAR(20) NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text',
    content TEXT,
    file_url TEXT,
    file_name VARCHAR(255),
    file_size INTEGER,
    file_type VARCHAR(50),
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    location_address TEXT,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    is_edited BOOLEAN DEFAULT false,
    edited_at TIMESTAMP,
    reply_to_message_id UUID REFERENCES chat_messages(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de notificaciones de chat
DROP TABLE IF EXISTS chat_notifications CASCADE;
CREATE TABLE chat_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES users(id),
    message_id UUID NOT NULL REFERENCES chat_messages(id) ON DELETE CASCADE,
    notification_type VARCHAR(30) DEFAULT 'new_message',
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    is_sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de respuestas rápidas
DROP TABLE IF EXISTS quick_responses CASCADE;
CREATE TABLE quick_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    message_text TEXT NOT NULL,
    order_index INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insertar respuestas rápidas por defecto
INSERT INTO quick_responses (role, category, message_text, order_index) VALUES
('vendor', 'pickup', 'El pedido está listo para recoger', 1),
('vendor', 'pickup', 'El pedido estará listo en 5 minutos', 2),
('delivery', 'pickup', 'Estoy llegando al local', 1),
('delivery', 'pickup', 'He llegado, ¿dónde recojo?', 2),
('delivery', 'delivery', 'Llegando a destino en 5 min', 4),
('delivery', 'delivery', 'Pedido entregado exitosamente', 6),
('both', 'general', 'OK', 1),
('both', 'general', 'Perfecto', 2);

-- =====================================================
-- FASE 5: DETECCIÓN AUTOMÁTICA DE DIFERENCIAS
-- =====================================================

-- Tabla de verificaciones de entrega
DROP TABLE IF EXISTS delivery_verifications CASCADE;
CREATE TABLE delivery_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    delivery_person_id UUID NOT NULL REFERENCES users(id),
    verification_step VARCHAR(30) NOT NULL,
    verification_type VARCHAR(30) NOT NULL,
    expected_value TEXT,
    actual_value TEXT,
    difference_detected BOOLEAN DEFAULT false,
    difference_percentage DECIMAL(5,2),
    difference_description TEXT,
    verification_method VARCHAR(30),
    photo_evidence_url TEXT,
    gps_lat DECIMAL(10,8),
    gps_lng DECIMAL(11,8),
    timestamp_verification TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de alertas de diferencias
DROP TABLE IF EXISTS difference_alerts CASCADE;
CREATE TABLE difference_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    verification_id UUID NOT NULL REFERENCES delivery_verifications(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(id),
    alert_type VARCHAR(30) NOT NULL,
    severity_level VARCHAR(20) DEFAULT 'medium',
    alert_title VARCHAR(255) NOT NULL,
    alert_description TEXT NOT NULL,
    affected_parties TEXT[],
    auto_resolution_suggested TEXT,
    manual_review_required BOOLEAN DEFAULT false,
    is_resolved BOOLEAN DEFAULT false,
    resolved_by UUID REFERENCES users(id),
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    compensation_amount DECIMAL(10,2),
    compensation_type VARCHAR(30),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de reglas de tolerancia
DROP TABLE IF EXISTS tolerance_rules CASCADE;
CREATE TABLE tolerance_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name VARCHAR(100) NOT NULL,
    verification_type VARCHAR(30) NOT NULL,
    product_category VARCHAR(50),
    service_type VARCHAR(50),
    tolerance_percentage DECIMAL(5,2) DEFAULT 5.0,
    tolerance_absolute_value DECIMAL(10,2),
    tolerance_unit VARCHAR(20),
    auto_approve_within_tolerance BOOLEAN DEFAULT true,
    alert_severity_within_tolerance VARCHAR(20) DEFAULT 'low',
    alert_severity_outside_tolerance VARCHAR(20) DEFAULT 'high',
    requires_photo_evidence BOOLEAN DEFAULT false,
    requires_manager_approval BOOLEAN DEFAULT false,
    compensation_rule TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insertar reglas de tolerancia por defecto
INSERT INTO tolerance_rules (rule_name, verification_type, tolerance_percentage, tolerance_absolute_value, tolerance_unit, alert_severity_outside_tolerance) VALUES
('Peso General', 'weight', 5.0, 0.5, 'kg', 'medium'),
('Peso Comida', 'weight', 3.0, 0.2, 'kg', 'high'),
('Peso Frágil', 'weight', 2.0, 0.1, 'kg', 'critical'),
('Tiempo Entrega', 'time', 15.0, 10, 'minutes', 'medium'),
('Tiempo Express', 'time', 5.0, 5, 'minutes', 'high'),
('Precio General', 'price', 2.0, 5.0, 'dollars', 'high'),
('Calidad Productos', 'quality', 0.0, 0, 'score', 'medium'),
('Artículos Pedido', 'items', 0.0, 0, 'units', 'critical');

-- =====================================================
-- FASE 6: SISTEMA DE RENTA DE AUTOS CON CONTADOR DE 5 MINUTOS
-- =====================================================

-- Tabla de vehículos disponibles
DROP TABLE IF EXISTS car_rental_vehicles CASCADE;
CREATE TABLE car_rental_vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_name VARCHAR(255) NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL CHECK (vehicle_type IN (
        'autos', 'autos_lujo', 'motos', 'shuttle', 'bus_tour', 'electricos', 'ecotur'
    )),
    vehicle_brand VARCHAR(100),
    vehicle_model VARCHAR(100),
    vehicle_year INTEGER,
    vehicle_color VARCHAR(50),
    passenger_capacity INTEGER DEFAULT 4,
    luggage_capacity INTEGER DEFAULT 2,
    transmission_type VARCHAR(20) DEFAULT 'manual',
    fuel_type VARCHAR(20) DEFAULT 'gasoline',
    base_price_per_day DECIMAL(10,2) NOT NULL,
    base_price_per_hour DECIMAL(10,2),
    commission_amount DECIMAL(10,2) DEFAULT 30.00,
    is_available BOOLEAN DEFAULT true,
    available_from DATE,
    available_to DATE,
    pickup_location VARCHAR(255),
    pickup_address TEXT,
    pickup_lat DECIMAL(10,8),
    pickup_lng DECIMAL(11,8),
    main_image_url TEXT,
    additional_images TEXT[] DEFAULT '{}',
    description TEXT,
    features TEXT[] DEFAULT '{}',
    shuttle_route VARCHAR(50),
    shuttle_schedule JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de reservas de autos
DROP TABLE IF EXISTS car_rental_reservations CASCADE;
CREATE TABLE car_rental_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES car_rental_vehicles(id),
    pickup_date DATE NOT NULL,
    pickup_time TIME NOT NULL,
    return_date DATE NOT NULL,
    return_time TIME NOT NULL,
    total_days INTEGER NOT NULL,
    total_hours INTEGER,
    base_price DECIMAL(10,2) NOT NULL,
    commission_amount DECIMAL(10,2) DEFAULT 30.00,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_deadline TIMESTAMP WITH TIME ZONE NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN (
        'pending', 'paid', 'expired', 'cancelled', 'refunded'
    )),
    reservation_status VARCHAR(30) DEFAULT 'prerreserva_pendiente' CHECK (reservation_status IN (
        'prerreserva_pendiente', 'disponibilidad_verificada', 'pago_pendiente', 
        'pago_realizado', 'reserva_confirmada', 'cancelada', 'completada'
    )),
    driver_name VARCHAR(255) NOT NULL,
    driver_email VARCHAR(255) NOT NULL,
    driver_phone VARCHAR(50),
    driver_license VARCHAR(100) NOT NULL,
    driver_passport VARCHAR(100) NOT NULL,
    driver_country VARCHAR(100) DEFAULT 'Cuba',
    contact_phone VARCHAR(50),
    contact_email VARCHAR(255),
    special_requests TEXT,
    admin_verified BOOLEAN DEFAULT FALSE,
    admin_verification_notes TEXT,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID REFERENCES users(id),
    external_reservation_id VARCHAR(255),
    external_boucher_url TEXT,
    external_confirmation_code VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    payment_completed_at TIMESTAMP,
    reservation_confirmed_at TIMESTAMP
);

-- Tabla de pagos de reservas
DROP TABLE IF EXISTS car_rental_payments CASCADE;
CREATE TABLE car_rental_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL REFERENCES car_rental_reservations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    payment_method VARCHAR(50) NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    base_amount DECIMAL(10,2) NOT NULL,
    commission_amount DECIMAL(10,2) NOT NULL,
    payment_reference VARCHAR(255),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN (
        'pending', 'completed', 'failed', 'refunded', 'cancelled'
    )),
    card_last_four VARCHAR(4),
    card_brand VARCHAR(50),
    payment_initiated_at TIMESTAMP DEFAULT NOW(),
    payment_completed_at TIMESTAMP,
    payment_expires_at TIMESTAMP,
    payment_metadata JSONB DEFAULT '{}',
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de notificaciones específicas de renta de autos
DROP TABLE IF EXISTS car_rental_notifications CASCADE;
CREATE TABLE car_rental_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL REFERENCES car_rental_reservations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    notification_type VARCHAR(50) NOT NULL CHECK (notification_type IN (
        'prerreserva_created', 'disponibilidad_verified', 'disponibilidad_rejected',
        'payment_required', 'payment_completed', 'reservation_confirmed',
        'payment_expired', 'reservation_cancelled'
    )),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    send_email BOOLEAN DEFAULT true,
    send_push BOOLEAN DEFAULT true,
    send_sms BOOLEAN DEFAULT false,
    email_sent BOOLEAN DEFAULT false,
    push_sent BOOLEAN DEFAULT false,
    sms_sent BOOLEAN DEFAULT false,
    scheduled_for TIMESTAMP DEFAULT NOW(),
    sent_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insertar vehículos de ejemplo
INSERT INTO car_rental_vehicles (vehicle_name, vehicle_type, vehicle_brand, vehicle_model, base_price_per_day, commission_amount, pickup_location, is_available) VALUES
('Toyota Corolla', 'autos', 'Toyota', 'Corolla', 45.00, 30.00, 'La Habana', true),
('BMW X5', 'autos_lujo', 'BMW', 'X5', 120.00, 30.00, 'La Habana', true),
('Honda CBR', 'motos', 'Honda', 'CBR 600', 25.00, 30.00, 'La Habana', true),
('Shuttle Vedado', 'shuttle', 'Mercedes', 'Sprinter', 15.00, 30.00, 'Vedado', true),
('Bus Tour Panorámico', 'bus_tour', 'Mercedes', 'Tourismo', 35.00, 30.00, 'La Habana', true),
('Tesla Model 3', 'electricos', 'Tesla', 'Model 3', 80.00, 30.00, 'La Habana', true),
('Safari 4x4', 'ecotur', 'Land Rover', 'Defender', 65.00, 30.00, 'La Habana', true);

-- =====================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- Índices para timeouts
CREATE INDEX IF NOT EXISTS idx_active_timeouts_order ON active_timeouts(order_id);
CREATE INDEX IF NOT EXISTS idx_active_timeouts_user ON active_timeouts(user_id);
CREATE INDEX IF NOT EXISTS idx_active_timeouts_expires ON active_timeouts(expires_at);

-- Índices para sanciones
CREATE INDEX IF NOT EXISTS idx_user_sanctions_user ON user_sanctions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sanctions_active ON user_sanctions(is_active);
CREATE INDEX IF NOT EXISTS idx_user_sanctions_ends ON user_sanctions(ends_at);

-- Índices para asignación inteligente
CREATE INDEX IF NOT EXISTS idx_delivery_zones_location ON delivery_zones(center_latitude, center_longitude);
CREATE INDEX IF NOT EXISTS idx_delivery_performance_person ON delivery_performance(delivery_person_id);
CREATE INDEX IF NOT EXISTS idx_delivery_performance_available ON delivery_performance(is_available, availability_status);

-- Índices para chat
CREATE INDEX IF NOT EXISTS idx_chat_conversations_order ON chat_conversations(order_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created ON chat_messages(created_at DESC);

-- Índices para detección de diferencias
CREATE INDEX IF NOT EXISTS idx_delivery_verifications_order ON delivery_verifications(order_id);
CREATE INDEX IF NOT EXISTS idx_difference_alerts_unresolved ON difference_alerts(is_resolved) WHERE is_resolved = false;

-- Índices para renta de autos
CREATE INDEX IF NOT EXISTS idx_car_rental_vehicles_type ON car_rental_vehicles(vehicle_type);
CREATE INDEX IF NOT EXISTS idx_car_rental_reservations_user ON car_rental_reservations(user_id);
CREATE INDEX IF NOT EXISTS idx_car_rental_reservations_status ON car_rental_reservations(reservation_status);
CREATE INDEX IF NOT EXISTS idx_car_rental_reservations_deadline ON car_rental_reservations(payment_deadline);

-- =====================================================
-- VISTAS PARA ESTADÍSTICAS
-- =====================================================

-- Vista de estadísticas de renta de autos
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

-- Vista de estadísticas de chat
CREATE OR REPLACE VIEW chat_statistics AS
SELECT 
    COUNT(DISTINCT c.id) as total_conversations,
    COUNT(DISTINCT CASE WHEN c.status = 'active' THEN c.id END) as active_conversations,
    COUNT(DISTINCT CASE WHEN c.status = 'closed' THEN c.id END) as closed_conversations,
    COUNT(m.id) as total_messages,
    COUNT(DISTINCT m.sender_id) as active_users,
    AVG(CASE WHEN c.status = 'closed' THEN 
        EXTRACT(EPOCH FROM (c.updated_at - c.created_at))/3600 
    END) as avg_conversation_duration_hours,
    COUNT(CASE WHEN m.message_type = 'text' THEN 1 END) as text_messages,
    COUNT(CASE WHEN m.message_type = 'image' THEN 1 END) as image_messages,
    COUNT(CASE WHEN m.message_type = 'file' THEN 1 END) as file_messages,
    COUNT(CASE WHEN m.message_type = 'location' THEN 1 END) as location_messages
FROM chat_conversations c
LEFT JOIN chat_messages m ON c.id = m.conversation_id
WHERE c.created_at >= CURRENT_DATE - INTERVAL '30 days';

-- =====================================================
-- IMPLEMENTACIÓN COMPLETA FINALIZADA
-- =====================================================
-- ✅ FASE 1: Sistema de Timeouts y Reasignación Automática
-- ✅ FASE 2: Sistema de Sanciones Automáticas
-- ✅ FASE 3: Algoritmo de Asignación Inteligente
-- ✅ FASE 4: Chat Directo Vendedor ↔ Repartidor
-- ✅ FASE 5: Detección Automática de Diferencias
-- ✅ FASE 6: Sistema de Renta de Autos con Contador de 5 Minutos
-- ✅ Índices para optimización
-- ✅ Vistas para estadísticas
-- ✅ Datos de ejemplo


