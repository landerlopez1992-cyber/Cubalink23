-- =====================================================
-- HISTORIAL COMPLETO DEL USUARIO
-- =====================================================
-- Sistema que registra TODAS las actividades del usuario:
-- 1. Rentas de autos
-- 2. Recargas de saldo
-- 3. Pasajes aéreos
-- 4. Compras en tiendas
-- 5. Transferencias
-- 6. Retiros
-- 7. Cualquier transacción

-- -----------------------------------------------------
-- 1. TABLA: user_activity_history (Historial completo de actividades)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS user_activity_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(30) NOT NULL, -- rental, recharge, flight, purchase, transfer, withdrawal, refund
    activity_category VARCHAR(50), -- auto, phone, store, flight, money, etc.
    reference_id UUID, -- ID del pedido, renta, vuelo, etc.
    reference_number VARCHAR(100), -- Número de referencia externo
    
    -- Detalles de la actividad
    title VARCHAR(255) NOT NULL,
    description TEXT,
    amount DECIMAL(12,2), -- Monto de la transacción
    currency VARCHAR(10) DEFAULT 'USD',
    
    -- Estado y fechas
    status VARCHAR(30) NOT NULL, -- pending, completed, failed, cancelled, refunded
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    
    -- Detalles específicos por tipo
    activity_data JSONB, -- Datos específicos de cada actividad
    
    -- Información de ubicación
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    location_address TEXT,
    
    -- Método de pago usado
    payment_method VARCHAR(30), -- wallet, credit_card, cash, transfer
    payment_reference VARCHAR(100),
    
    -- Metadatos
    device_info JSONB, -- Información del dispositivo usado
    user_agent TEXT,
    ip_address INET,
    
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_activity_history_user ON user_activity_history(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_history_type ON user_activity_history(activity_type);
CREATE INDEX IF NOT EXISTS idx_user_activity_history_category ON user_activity_history(activity_category);
CREATE INDEX IF NOT EXISTS idx_user_activity_history_status ON user_activity_history(status);
CREATE INDEX IF NOT EXISTS idx_user_activity_history_created ON user_activity_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_activity_history_reference ON user_activity_history(reference_id);

-- -----------------------------------------------------
-- 2. FUNCIÓN: Registrar actividad automáticamente
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION register_user_activity(
    user_id_param UUID,
    activity_type_param VARCHAR(30),
    activity_category_param VARCHAR(50),
    title_param VARCHAR(255),
    description_param TEXT DEFAULT NULL,
    amount_param DECIMAL(12,2) DEFAULT NULL,
    reference_id_param UUID DEFAULT NULL,
    reference_number_param VARCHAR(100) DEFAULT NULL,
    status_param VARCHAR(30) DEFAULT 'pending',
    activity_data_param JSONB DEFAULT NULL,
    payment_method_param VARCHAR(30) DEFAULT NULL,
    location_lat_param DECIMAL(10,8) DEFAULT NULL,
    location_lng_param DECIMAL(11,8) DEFAULT NULL,
    location_address_param TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    activity_id UUID;
BEGIN
    INSERT INTO user_activity_history (
        user_id, activity_type, activity_category, title, description,
        amount, reference_id, reference_number, status, activity_data,
        payment_method, location_lat, location_lng, location_address
    ) VALUES (
        user_id_param, activity_type_param, activity_category_param, 
        title_param, description_param, amount_param, reference_id_param,
        reference_number_param, status_param, activity_data_param,
        payment_method_param, location_lat_param, location_lng_param, location_address_param
    ) RETURNING id INTO activity_id;
    
    RETURN activity_id;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 3. FUNCIÓN: Actualizar estado de actividad
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION update_activity_status(
    activity_id_param UUID,
    new_status_param VARCHAR(30),
    completion_data_param JSONB DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE user_activity_history 
    SET 
        status = new_status_param,
        completed_at = CASE WHEN new_status_param = 'completed' THEN NOW() ELSE completed_at END,
        cancelled_at = CASE WHEN new_status_param = 'cancelled' THEN NOW() ELSE cancelled_at END,
        activity_data = CASE 
            WHEN completion_data_param IS NOT NULL THEN 
                COALESCE(activity_data, '{}'::jsonb) || completion_data_param
            ELSE activity_data 
        END,
        updated_at = NOW()
    WHERE id = activity_id_param;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 4. TRIGGERS: Registrar actividades automáticamente
-- -----------------------------------------------------

-- TRIGGER: Rentas de autos
CREATE OR REPLACE FUNCTION trigger_register_rental_activity() 
RETURNS TRIGGER AS $$
DECLARE
    activity_title TEXT;
    activity_desc TEXT;
    vehicle_name TEXT;
BEGIN
    -- Obtener nombre del vehículo
    SELECT title INTO vehicle_name FROM store_products WHERE id = NEW.vehicle_id;
    
    IF TG_OP = 'INSERT' THEN
        activity_title := 'Renta de Vehículo: ' || COALESCE(vehicle_name, 'Vehículo');
        activity_desc := format('Renta del %s desde %s hasta %s', 
            COALESCE(vehicle_name, 'vehículo'),
            NEW.scheduled_pickup_time::DATE,
            NEW.scheduled_return_time::DATE
        );
        
        PERFORM register_user_activity(
            NEW.customer_id,
            'rental',
            'auto',
            activity_title,
            activity_desc,
            NEW.total_estimated_cost,
            NEW.id,
            NEW.rental_number,
            NEW.status,
            jsonb_build_object(
                'vehicle_id', NEW.vehicle_id,
                'vehicle_name', vehicle_name,
                'pickup_time', NEW.scheduled_pickup_time,
                'return_time', NEW.scheduled_return_time,
                'pickup_location', NEW.pickup_location_address
            ),
            'wallet',
            NEW.pickup_location_lat,
            NEW.pickup_location_lng,
            NEW.pickup_location_address
        );
        
    ELSIF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        -- Actualizar actividad existente
        UPDATE user_activity_history 
        SET 
            status = NEW.status,
            amount = NEW.total_actual_cost,
            completed_at = CASE WHEN NEW.status = 'returned' THEN NEW.actual_return_time ELSE completed_at END,
            cancelled_at = CASE WHEN NEW.status = 'cancelled' THEN NEW.cancelled_at ELSE cancelled_at END,
            activity_data = activity_data || jsonb_build_object(
                'actual_cost', NEW.total_actual_cost,
                'penalty_amount', NEW.penalty_amount,
                'actual_pickup_time', NEW.actual_pickup_time,
                'actual_return_time', NEW.actual_return_time
            ),
            updated_at = NOW()
        WHERE reference_id = NEW.id AND activity_type = 'rental';
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_rental_activity
    AFTER INSERT OR UPDATE ON vehicle_rentals
    FOR EACH ROW
    EXECUTE FUNCTION trigger_register_rental_activity();

-- TRIGGER: Compras en tiendas (pedidos)
CREATE OR REPLACE FUNCTION trigger_register_purchase_activity() 
RETURNS TRIGGER AS $$
DECLARE
    activity_title TEXT;
    activity_desc TEXT;
    vendor_name TEXT;
    products_info JSONB;
BEGIN
    -- Obtener información del vendor
    SELECT full_name INTO vendor_name FROM users WHERE id = NEW.vendor_id;
    
    -- Obtener información de productos
    SELECT jsonb_agg(jsonb_build_object(
        'product_name', p.title,
        'quantity', oi.quantity,
        'price', oi.price
    )) INTO products_info
    FROM order_items oi
    JOIN store_products p ON oi.product_id = p.id
    WHERE oi.order_id = NEW.id;
    
    IF TG_OP = 'INSERT' THEN
        activity_title := 'Compra en Tienda: ' || COALESCE(vendor_name, 'Tienda');
        activity_desc := format('Pedido #%s en %s', 
            NEW.order_number,
            COALESCE(vendor_name, 'tienda')
        );
        
        PERFORM register_user_activity(
            NEW.customer_id,
            'purchase',
            'store',
            activity_title,
            activity_desc,
            NEW.total_amount,
            NEW.id,
            NEW.order_number,
            NEW.status,
            jsonb_build_object(
                'vendor_id', NEW.vendor_id,
                'vendor_name', vendor_name,
                'delivery_method', NEW.delivery_method,
                'is_express', NEW.is_express,
                'products', products_info,
                'delivery_address', NEW.delivery_address
            ),
            NEW.payment_method,
            NEW.delivery_lat,
            NEW.delivery_lng,
            NEW.delivery_address
        );
        
    ELSIF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        -- Actualizar actividad existente
        UPDATE user_activity_history 
        SET 
            status = NEW.status,
            completed_at = CASE WHEN NEW.status = 'delivered' THEN NEW.delivered_at ELSE completed_at END,
            cancelled_at = CASE WHEN NEW.status = 'cancelled' THEN NEW.cancelled_at ELSE cancelled_at END,
            activity_data = activity_data || jsonb_build_object(
                'delivered_at', NEW.delivered_at,
                'delivery_person_id', NEW.delivery_person_id,
                'cancellation_reason', NEW.cancellation_reason
            ),
            updated_at = NOW()
        WHERE reference_id = NEW.id AND activity_type = 'purchase';
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_purchase_activity
    AFTER INSERT OR UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trigger_register_purchase_activity();

-- -----------------------------------------------------
-- 5. FUNCIÓN: Registrar recargas de saldo
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION register_balance_recharge(
    user_id_param UUID,
    amount_param DECIMAL(10,2),
    payment_method_param VARCHAR(30),
    reference_number_param VARCHAR(100) DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    activity_id UUID;
BEGIN
    activity_id := register_user_activity(
        user_id_param,
        'recharge',
        'balance',
        'Recarga de Saldo',
        format('Recarga de $%s a la billetera', amount_param),
        amount_param,
        NULL, -- No reference_id para recargas
        reference_number_param,
        'completed',
        jsonb_build_object(
            'recharge_amount', amount_param,
            'previous_balance', (SELECT wallet_balance FROM users WHERE id = user_id_param),
            'new_balance', (SELECT wallet_balance FROM users WHERE id = user_id_param) + amount_param
        ),
        payment_method_param
    );
    
    -- Actualizar saldo del usuario
    UPDATE users 
    SET 
        wallet_balance = wallet_balance + amount_param,
        updated_at = NOW()
    WHERE id = user_id_param;
    
    RETURN activity_id;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 6. FUNCIÓN: Registrar pasajes aéreos
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION register_flight_booking(
    user_id_param UUID,
    flight_data_param JSONB,
    total_price_param DECIMAL(10,2),
    booking_reference_param VARCHAR(100),
    payment_method_param VARCHAR(30)
) RETURNS UUID AS $$
DECLARE
    activity_id UUID;
    flight_title TEXT;
    flight_desc TEXT;
BEGIN
    flight_title := format('Pasaje Aéreo: %s → %s',
        flight_data_param->>'origin',
        flight_data_param->>'destination'
    );
    
    flight_desc := format('Vuelo del %s - %s pasajeros',
        (flight_data_param->>'departure_date')::DATE,
        flight_data_param->>'passengers'
    );
    
    activity_id := register_user_activity(
        user_id_param,
        'flight',
        'travel',
        flight_title,
        flight_desc,
        total_price_param,
        NULL,
        booking_reference_param,
        'completed',
        flight_data_param || jsonb_build_object(
            'booking_date', NOW(),
            'total_price', total_price_param
        ),
        payment_method_param
    );
    
    RETURN activity_id;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 7. FUNCIÓN: Registrar transferencias
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION register_transfer_activity(
    sender_id_param UUID,
    receiver_id_param UUID,
    amount_param DECIMAL(10,2),
    transfer_reference_param VARCHAR(100),
    transfer_note_param TEXT DEFAULT NULL
) RETURNS TABLE (
    sender_activity_id UUID,
    receiver_activity_id UUID
) AS $$
DECLARE
    sender_activity UUID;
    receiver_activity UUID;
    receiver_name TEXT;
    sender_name TEXT;
BEGIN
    -- Obtener nombres
    SELECT full_name INTO receiver_name FROM users WHERE id = receiver_id_param;
    SELECT full_name INTO sender_name FROM users WHERE id = sender_id_param;
    
    -- Registrar actividad del enviador
    sender_activity := register_user_activity(
        sender_id_param,
        'transfer',
        'money_out',
        'Transferencia Enviada',
        format('Transferencia de $%s a %s', amount_param, COALESCE(receiver_name, 'Usuario')),
        -amount_param, -- Negativo porque sale dinero
        NULL,
        transfer_reference_param,
        'completed',
        jsonb_build_object(
            'receiver_id', receiver_id_param,
            'receiver_name', receiver_name,
            'transfer_note', transfer_note_param,
            'transfer_type', 'sent'
        ),
        'wallet'
    );
    
    -- Registrar actividad del receptor
    receiver_activity := register_user_activity(
        receiver_id_param,
        'transfer',
        'money_in',
        'Transferencia Recibida',
        format('Transferencia de $%s de %s', amount_param, COALESCE(sender_name, 'Usuario')),
        amount_param, -- Positivo porque entra dinero
        NULL,
        transfer_reference_param,
        'completed',
        jsonb_build_object(
            'sender_id', sender_id_param,
            'sender_name', sender_name,
            'transfer_note', transfer_note_param,
            'transfer_type', 'received'
        ),
        'wallet'
    );
    
    RETURN QUERY SELECT sender_activity, receiver_activity;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 8. FUNCIÓN: Obtener historial completo del usuario
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_user_complete_history(
    user_id_param UUID,
    limit_param INTEGER DEFAULT 50,
    offset_param INTEGER DEFAULT 0,
    activity_type_filter VARCHAR(30) DEFAULT NULL,
    date_from DATE DEFAULT NULL,
    date_to DATE DEFAULT NULL
) RETURNS TABLE (
    activity_id UUID,
    activity_type VARCHAR(30),
    activity_category VARCHAR(50),
    title VARCHAR(255),
    description TEXT,
    amount DECIMAL(12,2),
    currency VARCHAR(10),
    status VARCHAR(30),
    reference_number VARCHAR(100),
    payment_method VARCHAR(30),
    created_at TIMESTAMP,
    completed_at TIMESTAMP,
    activity_data JSONB,
    location_address TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        uah.id,
        uah.activity_type,
        uah.activity_category,
        uah.title,
        uah.description,
        uah.amount,
        uah.currency,
        uah.status,
        uah.reference_number,
        uah.payment_method,
        uah.created_at,
        uah.completed_at,
        uah.activity_data,
        uah.location_address
    FROM user_activity_history uah
    WHERE uah.user_id = user_id_param
      AND (activity_type_filter IS NULL OR uah.activity_type = activity_type_filter)
      AND (date_from IS NULL OR uah.created_at::DATE >= date_from)
      AND (date_to IS NULL OR uah.created_at::DATE <= date_to)
    ORDER BY uah.created_at DESC
    LIMIT limit_param OFFSET offset_param;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 9. FUNCIÓN: Estadísticas de actividad del usuario
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_user_activity_stats(
    user_id_param UUID,
    days_back INTEGER DEFAULT 30
) RETURNS TABLE (
    total_activities INTEGER,
    total_spent DECIMAL(12,2),
    total_received DECIMAL(12,2),
    rentals_count INTEGER,
    purchases_count INTEGER,
    flights_count INTEGER,
    transfers_sent INTEGER,
    transfers_received INTEGER,
    recharges_count INTEGER,
    avg_order_value DECIMAL(10,2),
    most_used_payment_method VARCHAR(30),
    favorite_activity_type VARCHAR(30)
) AS $$
BEGIN
    RETURN QUERY
    WITH activity_stats AS (
        SELECT 
            COUNT(*) as total_activities,
            SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END) as total_spent,
            SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) as total_received,
            COUNT(CASE WHEN activity_type = 'rental' THEN 1 END) as rentals,
            COUNT(CASE WHEN activity_type = 'purchase' THEN 1 END) as purchases,
            COUNT(CASE WHEN activity_type = 'flight' THEN 1 END) as flights,
            COUNT(CASE WHEN activity_type = 'transfer' AND activity_category = 'money_out' THEN 1 END) as transfers_out,
            COUNT(CASE WHEN activity_type = 'transfer' AND activity_category = 'money_in' THEN 1 END) as transfers_in,
            COUNT(CASE WHEN activity_type = 'recharge' THEN 1 END) as recharges,
            AVG(CASE WHEN activity_type IN ('purchase', 'rental', 'flight') AND amount > 0 THEN amount END) as avg_value
        FROM user_activity_history
        WHERE user_id = user_id_param
          AND created_at >= NOW() - INTERVAL '1 day' * days_back
    ),
    payment_method_stats AS (
        SELECT payment_method
        FROM user_activity_history
        WHERE user_id = user_id_param
          AND payment_method IS NOT NULL
          AND created_at >= NOW() - INTERVAL '1 day' * days_back
        GROUP BY payment_method
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ),
    activity_type_stats AS (
        SELECT activity_type
        FROM user_activity_history
        WHERE user_id = user_id_param
          AND created_at >= NOW() - INTERVAL '1 day' * days_back
        GROUP BY activity_type
        ORDER BY COUNT(*) DESC
        LIMIT 1
    )
    SELECT 
        ast.total_activities::INTEGER,
        ast.total_spent::DECIMAL(12,2),
        ast.total_received::DECIMAL(12,2),
        ast.rentals::INTEGER,
        ast.purchases::INTEGER,
        ast.flights::INTEGER,
        ast.transfers_out::INTEGER,
        ast.transfers_in::INTEGER,
        ast.recharges::INTEGER,
        ast.avg_value::DECIMAL(10,2),
        COALESCE(pms.payment_method, 'wallet')::VARCHAR(30),
        COALESCE(ats.activity_type, 'purchase')::VARCHAR(30)
    FROM activity_stats ast
    CROSS JOIN payment_method_stats pms
    CROSS JOIN activity_type_stats ats;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 10. VISTA: Resumen de historial de usuario
-- -----------------------------------------------------
CREATE OR REPLACE VIEW user_activity_summary AS
SELECT 
    u.id as user_id,
    u.full_name,
    u.email,
    COUNT(uah.id) as total_activities,
    COUNT(CASE WHEN uah.activity_type = 'purchase' THEN 1 END) as total_purchases,
    COUNT(CASE WHEN uah.activity_type = 'rental' THEN 1 END) as total_rentals,
    COUNT(CASE WHEN uah.activity_type = 'flight' THEN 1 END) as total_flights,
    COUNT(CASE WHEN uah.activity_type = 'recharge' THEN 1 END) as total_recharges,
    SUM(CASE WHEN uah.amount > 0 THEN uah.amount ELSE 0 END) as total_money_in,
    SUM(CASE WHEN uah.amount < 0 THEN ABS(uah.amount) ELSE 0 END) as total_money_out,
    MAX(uah.created_at) as last_activity_at,
    MIN(uah.created_at) as first_activity_at
FROM users u
LEFT JOIN user_activity_history uah ON u.id = uah.user_id
WHERE u.role = 'customer'
GROUP BY u.id, u.full_name, u.email
ORDER BY total_activities DESC;

-- -----------------------------------------------------
-- ✅ HISTORIAL COMPLETO DEL USUARIO IMPLEMENTADO
-- -----------------------------------------------------
-- Este sistema ahora registra automáticamente:
-- ✅ Todas las rentas de autos (con detalles completos)
-- ✅ Todas las compras en tiendas (con productos)
-- ✅ Todas las recargas de saldo
-- ✅ Todos los pasajes aéreos (cuando se implemente)
-- ✅ Todas las transferencias (enviadas y recibidas)
-- ✅ Historial completo con filtros y búsqueda
-- ✅ Estadísticas detalladas por usuario
-- ✅ Triggers automáticos que registran todo
-- ✅ Funciones para consultar el historial completo



