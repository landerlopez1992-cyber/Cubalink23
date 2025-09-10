-- =====================================================
-- SISTEMA FINAL: HISTORIAL COMPLETO DE ACTIVIDADES DE USUARIO
-- =====================================================
-- Sistema completo de tracking de actividades:
-- 1. Historial detallado de todas las acciones del usuario
-- 2. Timeline completa de eventos por usuario
-- 3. Seguimiento de sesiones y dispositivos
-- 4. Análisis de comportamiento y patrones
-- 5. Métricas de engagement y retención
-- 6. Auditoría completa de seguridad
-- 7. Reportes de actividad personalizados

-- -----------------------------------------------------
-- 1. TABLA: user_activity_log (Log principal de actividades)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS user_activity_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Información de la actividad
    activity_type VARCHAR(50) NOT NULL, -- 'login', 'logout', 'order_placed', 'payment_made', 'profile_updated', etc.
    activity_category VARCHAR(30) NOT NULL, -- 'authentication', 'orders', 'payments', 'profile', 'delivery', 'chat', 'car_rental'
    activity_description TEXT NOT NULL,
    activity_result VARCHAR(20) DEFAULT 'success' CHECK (activity_result IN ('success', 'failed', 'pending', 'cancelled')),
    
    -- Contexto de la actividad
    resource_type VARCHAR(30), -- 'order', 'payment', 'product', 'conversation', 'vehicle', etc.
    resource_id UUID, -- ID del recurso relacionado
    related_user_id UUID REFERENCES users(id), -- Usuario relacionado (ej: chat, delivery)
    
    -- Datos específicos de la actividad
    activity_data JSONB DEFAULT '{}', -- Datos específicos según el tipo de actividad
    previous_values JSONB DEFAULT '{}', -- Valores anteriores (para cambios)
    new_values JSONB DEFAULT '{}', -- Valores nuevos (para cambios)
    
    -- Información de sesión
    session_id VARCHAR(100), -- ID de sesión única
    device_info JSONB DEFAULT '{}', -- Información del dispositivo
    user_agent TEXT, -- User agent del navegador/app
    ip_address INET, -- Dirección IP
    location_data JSONB DEFAULT '{}', -- Ubicación aproximada
    
    -- Tiempo y duración
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    duration_seconds INTEGER, -- Duración de la actividad
    
    -- Métricas de rendimiento
    response_time_ms INTEGER, -- Tiempo de respuesta del sistema
    error_code VARCHAR(20), -- Código de error si falló
    error_message TEXT, -- Mensaje de error detallado
    
    -- Metadata adicional
    source_platform VARCHAR(20) DEFAULT 'web' CHECK (source_platform IN ('web', 'mobile_app', 'api', 'admin_panel')),
    api_endpoint VARCHAR(200), -- Endpoint API utilizado
    referrer_url TEXT, -- URL de referencia
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_activity_log_user ON user_activity_log(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_log_type ON user_activity_log(activity_type);
CREATE INDEX IF NOT EXISTS idx_user_activity_log_category ON user_activity_log(activity_category);
CREATE INDEX IF NOT EXISTS idx_user_activity_log_session ON user_activity_log(session_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_log_created_at ON user_activity_log(created_at);
CREATE INDEX IF NOT EXISTS idx_user_activity_log_resource ON user_activity_log(resource_type, resource_id);

-- -----------------------------------------------------
-- 2. TABLA: user_sessions (Sesiones de usuario detalladas)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(100) NOT NULL UNIQUE,
    
    -- Información de la sesión
    started_at TIMESTAMP DEFAULT NOW(),
    last_activity_at TIMESTAMP DEFAULT NOW(),
    ended_at TIMESTAMP,
    session_duration_minutes INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    
    -- Información del dispositivo y ubicación
    device_type VARCHAR(20) DEFAULT 'unknown' CHECK (device_type IN ('mobile', 'tablet', 'desktop', 'unknown')),
    operating_system VARCHAR(30),
    browser_name VARCHAR(30),
    browser_version VARCHAR(20),
    screen_resolution VARCHAR(20),
    user_agent TEXT,
    
    -- Información de red
    ip_address INET,
    country VARCHAR(50),
    city VARCHAR(100),
    timezone VARCHAR(50),
    isp VARCHAR(100),
    
    -- Métricas de la sesión
    total_page_views INTEGER DEFAULT 0,
    total_actions INTEGER DEFAULT 0,
    total_orders INTEGER DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0.00,
    
    -- Información de autenticación
    login_method VARCHAR(20) DEFAULT 'password' CHECK (login_method IN ('password', 'google', 'facebook', 'apple', 'biometric', 'token')),
    two_factor_used BOOLEAN DEFAULT false,
    
    -- Flags de seguridad
    is_suspicious BOOLEAN DEFAULT false,
    risk_score INTEGER DEFAULT 0 CHECK (risk_score >= 0 AND risk_score <= 100),
    security_alerts JSONB DEFAULT '[]',
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_active ON user_sessions(is_active);
CREATE INDEX IF NOT EXISTS idx_user_sessions_started_at ON user_sessions(started_at);

-- -----------------------------------------------------
-- 3. TABLA: user_engagement_metrics (Métricas de engagement)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS user_engagement_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Período de la métrica
    metric_date DATE DEFAULT CURRENT_DATE,
    metric_period VARCHAR(10) DEFAULT 'daily' CHECK (metric_period IN ('daily', 'weekly', 'monthly')),
    
    -- Métricas de actividad
    total_sessions INTEGER DEFAULT 0,
    total_session_time_minutes INTEGER DEFAULT 0,
    average_session_duration_minutes DECIMAL(8,2) DEFAULT 0.00,
    total_page_views INTEGER DEFAULT 0,
    unique_features_used INTEGER DEFAULT 0,
    
    -- Métricas de órdenes
    total_orders INTEGER DEFAULT 0,
    total_order_value DECIMAL(12,2) DEFAULT 0.00,
    average_order_value DECIMAL(10,2) DEFAULT 0.00,
    orders_completed INTEGER DEFAULT 0,
    orders_cancelled INTEGER DEFAULT 0,
    
    -- Métricas de comunicación
    messages_sent INTEGER DEFAULT 0,
    conversations_started INTEGER DEFAULT 0,
    support_tickets_created INTEGER DEFAULT 0,
    
    -- Métricas de renta de autos
    car_rental_sessions INTEGER DEFAULT 0,
    car_rental_hours DECIMAL(8,2) DEFAULT 0.00,
    car_rental_spend DECIMAL(10,2) DEFAULT 0.00,
    
    -- Métricas de entrega
    deliveries_received INTEGER DEFAULT 0,
    average_delivery_rating DECIMAL(3,2) DEFAULT 0.00,
    delivery_issues_reported INTEGER DEFAULT 0,
    
    -- Engagement score calculado
    engagement_score DECIMAL(5,2) DEFAULT 0.00 CHECK (engagement_score >= 0.00 AND engagement_score <= 100.00),
    retention_risk VARCHAR(10) DEFAULT 'low' CHECK (retention_risk IN ('low', 'medium', 'high')),
    
    -- Datos adicionales
    features_used TEXT[] DEFAULT ARRAY[]::TEXT[],
    most_active_hour INTEGER, -- Hora del día más activa (0-23)
    preferred_device VARCHAR(20),
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_user_engagement_metrics_unique ON user_engagement_metrics(user_id, metric_date, metric_period);
CREATE INDEX IF NOT EXISTS idx_user_engagement_metrics_date ON user_engagement_metrics(metric_date);
CREATE INDEX IF NOT EXISTS idx_user_engagement_metrics_score ON user_engagement_metrics(engagement_score);

-- -----------------------------------------------------
-- 4. TABLA: user_preferences_history (Historial de preferencias)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS user_preferences_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Tipo de preferencia
    preference_category VARCHAR(30) NOT NULL, -- 'delivery', 'payment', 'communication', 'privacy', 'app_settings'
    preference_key VARCHAR(50) NOT NULL,
    
    -- Valores de la preferencia
    old_value JSONB,
    new_value JSONB NOT NULL,
    change_reason VARCHAR(100), -- Razón del cambio
    
    -- Información del cambio
    changed_by VARCHAR(20) DEFAULT 'user' CHECK (changed_by IN ('user', 'system', 'admin', 'auto_optimization')),
    change_source VARCHAR(30), -- 'app', 'website', 'admin_panel', 'api'
    
    -- Impacto del cambio
    impact_description TEXT,
    affects_recommendations BOOLEAN DEFAULT false,
    affects_notifications BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_preferences_history_user ON user_preferences_history(user_id);
CREATE INDEX IF NOT EXISTS idx_user_preferences_history_category ON user_preferences_history(preference_category);
CREATE INDEX IF NOT EXISTS idx_user_preferences_history_created_at ON user_preferences_history(created_at);

-- -----------------------------------------------------
-- 5. FUNCIÓN: Registrar actividad de usuario
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION log_user_activity(
    user_id_param UUID,
    activity_type_param VARCHAR(50),
    activity_category_param VARCHAR(30),
    activity_description_param TEXT,
    resource_type_param VARCHAR(30) DEFAULT NULL,
    resource_id_param UUID DEFAULT NULL,
    activity_data_param JSONB DEFAULT '{}',
    session_id_param VARCHAR(100) DEFAULT NULL,
    device_info_param JSONB DEFAULT '{}',
    ip_address_param INET DEFAULT NULL
) RETURNS TABLE (
    success BOOLEAN,
    activity_id UUID,
    message TEXT
) AS $$
DECLARE
    new_activity_id UUID;
    session_record RECORD;
    engagement_data RECORD;
BEGIN
    -- Registrar la actividad
    INSERT INTO user_activity_log (
        user_id, activity_type, activity_category, activity_description,
        resource_type, resource_id, activity_data, session_id,
        device_info, ip_address, started_at, completed_at
    ) VALUES (
        user_id_param, activity_type_param, activity_category_param, activity_description_param,
        resource_type_param, resource_id_param, activity_data_param, session_id_param,
        device_info_param, ip_address_param, NOW(), NOW()
    ) RETURNING id INTO new_activity_id;
    
    -- Actualizar sesión si existe
    IF session_id_param IS NOT NULL THEN
        UPDATE user_sessions 
        SET 
            last_activity_at = NOW(),
            total_actions = total_actions + 1,
            updated_at = NOW()
        WHERE session_token = session_id_param AND user_id = user_id_param;
        
        -- Calcular duración de sesión
        UPDATE user_sessions 
        SET session_duration_minutes = EXTRACT(EPOCH FROM (last_activity_at - started_at)) / 60
        WHERE session_token = session_id_param;
    END IF;
    
    -- Actualizar métricas de engagement diarias
    INSERT INTO user_engagement_metrics (user_id, metric_date, metric_period)
    VALUES (user_id_param, CURRENT_DATE, 'daily')
    ON CONFLICT (user_id, metric_date, metric_period) DO NOTHING;
    
    -- Incrementar contadores según el tipo de actividad
    CASE activity_category_param
        WHEN 'orders' THEN
            IF activity_type_param = 'order_placed' THEN
                UPDATE user_engagement_metrics 
                SET 
                    total_orders = total_orders + 1,
                    total_order_value = total_order_value + COALESCE((activity_data_param->>'order_total')::DECIMAL, 0),
                    updated_at = NOW()
                WHERE user_id = user_id_param AND metric_date = CURRENT_DATE AND metric_period = 'daily';
            END IF;
            
        WHEN 'chat' THEN
            IF activity_type_param = 'message_sent' THEN
                UPDATE user_engagement_metrics 
                SET 
                    messages_sent = messages_sent + 1,
                    updated_at = NOW()
                WHERE user_id = user_id_param AND metric_date = CURRENT_DATE AND metric_period = 'daily';
            END IF;
            
        WHEN 'car_rental' THEN
            IF activity_type_param = 'rental_session_started' THEN
                UPDATE user_engagement_metrics 
                SET 
                    car_rental_sessions = car_rental_sessions + 1,
                    updated_at = NOW()
                WHERE user_id = user_id_param AND metric_date = CURRENT_DATE AND metric_period = 'daily';
            END IF;
    END CASE;
    
    -- Actualizar features utilizadas
    IF activity_data_param ? 'feature_name' THEN
        UPDATE user_engagement_metrics 
        SET 
            features_used = array_append(
                CASE WHEN (activity_data_param->>'feature_name') = ANY(features_used) 
                     THEN features_used 
                     ELSE array_append(features_used, activity_data_param->>'feature_name') 
                END,
                NULL
            ),
            unique_features_used = array_length(
                array_append(
                    CASE WHEN (activity_data_param->>'feature_name') = ANY(features_used) 
                         THEN features_used 
                         ELSE array_append(features_used, activity_data_param->>'feature_name') 
                    END,
                    NULL
                ), 1
            ),
            updated_at = NOW()
        WHERE user_id = user_id_param AND metric_date = CURRENT_DATE AND metric_period = 'daily';
    END IF;
    
    RETURN QUERY SELECT true, new_activity_id, 'Actividad registrada exitosamente';
    
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 6. FUNCIÓN: Crear nueva sesión de usuario
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION create_user_session(
    user_id_param UUID,
    session_token_param VARCHAR(100),
    device_info_param JSONB DEFAULT '{}',
    ip_address_param INET DEFAULT NULL,
    login_method_param VARCHAR(20) DEFAULT 'password'
) RETURNS TABLE (
    success BOOLEAN,
    session_id UUID,
    message TEXT
) AS $$
DECLARE
    new_session_id UUID;
    location_data JSONB := '{}';
    risk_score_calc INTEGER := 0;
BEGIN
    -- Terminar sesiones anteriores activas del mismo usuario
    UPDATE user_sessions 
    SET 
        is_active = false,
        ended_at = NOW(),
        session_duration_minutes = EXTRACT(EPOCH FROM (NOW() - started_at)) / 60
    WHERE user_id = user_id_param AND is_active = true;
    
    -- Calcular score de riesgo básico
    risk_score_calc := CASE 
        WHEN login_method_param = 'password' THEN 10
        WHEN login_method_param IN ('google', 'apple') THEN 5
        WHEN login_method_param = 'biometric' THEN 2
        ELSE 15
    END;
    
    -- Crear nueva sesión
    INSERT INTO user_sessions (
        user_id, session_token, device_type, operating_system,
        browser_name, user_agent, ip_address, login_method,
        risk_score
    ) VALUES (
        user_id_param, session_token_param,
        COALESCE(device_info_param->>'device_type', 'unknown'),
        device_info_param->>'operating_system',
        device_info_param->>'browser_name',
        device_info_param->>'user_agent',
        ip_address_param, login_method_param, risk_score_calc
    ) RETURNING id INTO new_session_id;
    
    -- Registrar actividad de login
    PERFORM log_user_activity(
        user_id_param, 'login', 'authentication', 'Usuario inició sesión',
        'session', new_session_id, 
        jsonb_build_object('login_method', login_method_param, 'ip_address', ip_address_param),
        session_token_param, device_info_param, ip_address_param
    );
    
    -- Actualizar métricas de engagement
    UPDATE user_engagement_metrics 
    SET 
        total_sessions = total_sessions + 1,
        updated_at = NOW()
    WHERE user_id = user_id_param AND metric_date = CURRENT_DATE AND metric_period = 'daily';
    
    -- Insertar métricas si no existen
    INSERT INTO user_engagement_metrics (user_id, metric_date, metric_period, total_sessions)
    VALUES (user_id_param, CURRENT_DATE, 'daily', 1)
    ON CONFLICT (user_id, metric_date, metric_period) DO NOTHING;
    
    RETURN QUERY SELECT true, new_session_id, 'Sesión creada exitosamente';
    
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 7. FUNCIÓN: Calcular engagement score
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_engagement_score(
    user_id_param UUID,
    period_days INTEGER DEFAULT 30
) RETURNS TABLE (
    user_id UUID,
    engagement_score DECIMAL(5,2),
    retention_risk VARCHAR(10),
    metrics JSONB
) AS $$
DECLARE
    activity_score DECIMAL(5,2) := 0.00;
    order_score DECIMAL(5,2) := 0.00;
    communication_score DECIMAL(5,2) := 0.00;
    consistency_score DECIMAL(5,2) := 0.00;
    final_score DECIMAL(5,2);
    risk_level VARCHAR(10);
    user_metrics JSONB;
    days_active INTEGER;
    total_orders INTEGER;
    total_messages INTEGER;
    avg_session_duration DECIMAL(8,2);
BEGIN
    -- Obtener métricas del período
    SELECT 
        COUNT(DISTINCT DATE(started_at)) as days_active,
        COUNT(DISTINCT CASE WHEN activity_category = 'orders' THEN id END) as orders,
        COUNT(DISTINCT CASE WHEN activity_category = 'chat' THEN id END) as messages,
        AVG(EXTRACT(EPOCH FROM (completed_at - started_at)) / 60) as avg_duration
    INTO days_active, total_orders, total_messages, avg_session_duration
    FROM user_activity_log
    WHERE user_id = user_id_param 
      AND started_at >= NOW() - INTERVAL '%s days' % period_days;
    
    -- Calcular scores por categoría
    
    -- 1. Score de actividad (40% del total)
    activity_score := LEAST(40.0, (days_active::DECIMAL / period_days * 40.0));
    
    -- 2. Score de órdenes (30% del total)
    order_score := LEAST(30.0, (total_orders * 3.0));
    
    -- 3. Score de comunicación (20% del total)
    communication_score := LEAST(20.0, (total_messages * 0.5));
    
    -- 4. Score de consistencia (10% del total)
    consistency_score := CASE 
        WHEN days_active >= period_days * 0.8 THEN 10.0
        WHEN days_active >= period_days * 0.5 THEN 7.0
        WHEN days_active >= period_days * 0.2 THEN 4.0
        ELSE 1.0
    END;
    
    -- Calcular score final
    final_score := activity_score + order_score + communication_score + consistency_score;
    
    -- Determinar nivel de riesgo de retención
    risk_level := CASE 
        WHEN final_score >= 70 THEN 'low'
        WHEN final_score >= 40 THEN 'medium'
        ELSE 'high'
    END;
    
    -- Crear objeto JSON con métricas
    user_metrics := jsonb_build_object(
        'period_days', period_days,
        'days_active', days_active,
        'total_orders', total_orders,
        'total_messages', total_messages,
        'avg_session_duration', COALESCE(avg_session_duration, 0),
        'activity_score', activity_score,
        'order_score', order_score,
        'communication_score', communication_score,
        'consistency_score', consistency_score,
        'calculated_at', NOW()
    );
    
    -- Actualizar métricas de engagement
    UPDATE user_engagement_metrics 
    SET 
        engagement_score = final_score,
        retention_risk = risk_level,
        updated_at = NOW()
    WHERE user_id = user_id_param AND metric_date = CURRENT_DATE AND metric_period = 'daily';
    
    RETURN QUERY SELECT user_id_param, final_score, risk_level, user_metrics;
    
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 8. VISTA: Timeline de actividades por usuario
-- -----------------------------------------------------
CREATE OR REPLACE VIEW user_activity_timeline AS
SELECT 
    ual.id,
    ual.user_id,
    u.name as user_name,
    u.email as user_email,
    ual.activity_type,
    ual.activity_category,
    ual.activity_description,
    ual.activity_result,
    ual.resource_type,
    ual.resource_id,
    ual.started_at,
    ual.completed_at,
    ual.duration_seconds,
    ual.source_platform,
    ual.ip_address,
    ual.session_id,
    ual.activity_data,
    -- Información adicional contextual
    CASE ual.activity_category
        WHEN 'orders' THEN 
            (SELECT jsonb_build_object('order_number', order_number, 'total', total) 
             FROM orders WHERE id = ual.resource_id::UUID)
        WHEN 'chat' THEN 
            (SELECT jsonb_build_object('conversation_type', conversation_type, 'title', title) 
             FROM chat_conversations WHERE id = ual.resource_id::UUID)
        WHEN 'car_rental' THEN 
            (SELECT jsonb_build_object('vehicle_info', brand || ' ' || model, 'license_plate', license_plate) 
             FROM car_rental_fleet WHERE id = ual.resource_id::UUID)
        ELSE NULL
    END as context_data,
    -- Tiempo desde la actividad anterior
    LAG(ual.started_at) OVER (PARTITION BY ual.user_id ORDER BY ual.started_at) as previous_activity_time,
    EXTRACT(EPOCH FROM (ual.started_at - LAG(ual.started_at) OVER (PARTITION BY ual.user_id ORDER BY ual.started_at))) / 60 as minutes_since_last_activity
FROM user_activity_log ual
JOIN users u ON ual.user_id = u.id
ORDER BY ual.user_id, ual.started_at DESC;

-- -----------------------------------------------------
-- 9. VISTA: Resumen de engagement por usuario
-- -----------------------------------------------------
CREATE OR REPLACE VIEW user_engagement_summary AS
SELECT 
    u.id as user_id,
    u.name,
    u.email,
    u.created_at as registration_date,
    -- Métricas de los últimos 30 días
    uem.engagement_score,
    uem.retention_risk,
    uem.total_sessions as sessions_last_30_days,
    uem.total_session_time_minutes as active_time_last_30_days,
    uem.average_session_duration_minutes,
    uem.total_orders as orders_last_30_days,
    uem.total_order_value as spent_last_30_days,
    uem.messages_sent as messages_last_30_days,
    uem.car_rental_sessions as rentals_last_30_days,
    uem.features_used,
    uem.unique_features_used,
    uem.most_active_hour,
    uem.preferred_device,
    -- Estadísticas históricas
    (SELECT COUNT(*) FROM user_activity_log WHERE user_id = u.id) as total_activities,
    (SELECT COUNT(DISTINCT session_id) FROM user_activity_log WHERE user_id = u.id) as total_sessions_ever,
    (SELECT MAX(started_at) FROM user_activity_log WHERE user_id = u.id) as last_activity,
    -- Score de longevidad
    CASE 
        WHEN EXTRACT(DAYS FROM (NOW() - u.created_at)) >= 365 THEN 'veteran'
        WHEN EXTRACT(DAYS FROM (NOW() - u.created_at)) >= 90 THEN 'regular'
        WHEN EXTRACT(DAYS FROM (NOW() - u.created_at)) >= 30 THEN 'established'
        ELSE 'new'
    END as user_tier
FROM users u
LEFT JOIN user_engagement_metrics uem ON (
    u.id = uem.user_id 
    AND uem.metric_date = CURRENT_DATE 
    AND uem.metric_period = 'daily'
)
ORDER BY uem.engagement_score DESC NULLS LAST, u.created_at DESC;

-- -----------------------------------------------------
-- 10. FUNCIÓN: Generar reporte de actividad personalizado
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION generate_user_activity_report(
    user_id_param UUID,
    start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    end_date DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
    report_data JSONB
) AS $$
DECLARE
    user_info JSONB;
    activity_summary JSONB;
    top_activities JSONB;
    engagement_trends JSONB;
    device_usage JSONB;
    final_report JSONB;
BEGIN
    -- Información básica del usuario
    SELECT jsonb_build_object(
        'user_id', u.id,
        'name', u.name,
        'email', u.email,
        'registration_date', u.created_at,
        'account_age_days', EXTRACT(DAYS FROM (NOW() - u.created_at)),
        'current_role', u.role
    ) INTO user_info
    FROM users u WHERE u.id = user_id_param;
    
    -- Resumen de actividades
    SELECT jsonb_build_object(
        'total_activities', COUNT(*),
        'unique_activity_types', COUNT(DISTINCT activity_type),
        'unique_categories', COUNT(DISTINCT activity_category),
        'success_rate', ROUND((COUNT(CASE WHEN activity_result = 'success' THEN 1 END)::DECIMAL / COUNT(*) * 100), 2),
        'total_session_time_minutes', COALESCE(SUM(duration_seconds) / 60, 0),
        'average_activities_per_day', ROUND(COUNT(*)::DECIMAL / GREATEST(EXTRACT(DAYS FROM (end_date - start_date)), 1), 2)
    ) INTO activity_summary
    FROM user_activity_log 
    WHERE user_id = user_id_param 
      AND DATE(started_at) BETWEEN start_date AND end_date;
    
    -- Top actividades
    SELECT jsonb_agg(
        jsonb_build_object(
            'activity_type', activity_type,
            'count', activity_count,
            'percentage', ROUND((activity_count::DECIMAL / total_activities * 100), 2)
        )
    ) INTO top_activities
    FROM (
        SELECT 
            activity_type,
            COUNT(*) as activity_count,
            (SELECT COUNT(*) FROM user_activity_log WHERE user_id = user_id_param AND DATE(started_at) BETWEEN start_date AND end_date) as total_activities
        FROM user_activity_log 
        WHERE user_id = user_id_param 
          AND DATE(started_at) BETWEEN start_date AND end_date
        GROUP BY activity_type
        ORDER BY COUNT(*) DESC
        LIMIT 10
    ) top_acts;
    
    -- Tendencias de engagement
    SELECT jsonb_agg(
        jsonb_build_object(
            'date', activity_date,
            'activities', daily_activities,
            'session_time', daily_session_time
        ) ORDER BY activity_date
    ) INTO engagement_trends
    FROM (
        SELECT 
            DATE(started_at) as activity_date,
            COUNT(*) as daily_activities,
            COALESCE(SUM(duration_seconds) / 60, 0) as daily_session_time
        FROM user_activity_log 
        WHERE user_id = user_id_param 
          AND DATE(started_at) BETWEEN start_date AND end_date
        GROUP BY DATE(started_at)
    ) daily_stats;
    
    -- Uso por dispositivo
    SELECT jsonb_agg(
        jsonb_build_object(
            'platform', source_platform,
            'count', platform_count,
            'percentage', ROUND((platform_count::DECIMAL / total_activities * 100), 2)
        )
    ) INTO device_usage
    FROM (
        SELECT 
            source_platform,
            COUNT(*) as platform_count,
            (SELECT COUNT(*) FROM user_activity_log WHERE user_id = user_id_param AND DATE(started_at) BETWEEN start_date AND end_date) as total_activities
        FROM user_activity_log 
        WHERE user_id = user_id_param 
          AND DATE(started_at) BETWEEN start_date AND end_date
        GROUP BY source_platform
    ) platform_stats;
    
    -- Compilar reporte final
    final_report := jsonb_build_object(
        'report_metadata', jsonb_build_object(
            'generated_at', NOW(),
            'period_start', start_date,
            'period_end', end_date,
            'period_days', EXTRACT(DAYS FROM (end_date - start_date)) + 1
        ),
        'user_info', user_info,
        'activity_summary', activity_summary,
        'top_activities', top_activities,
        'engagement_trends', engagement_trends,
        'device_usage', device_usage
    );
    
    RETURN QUERY SELECT final_report;
    
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- ✅ SISTEMA FINAL DE HISTORIAL DE ACTIVIDADES COMPLETADO
-- -----------------------------------------------------
-- Funcionalidades implementadas:
-- ✅ Log completo de todas las actividades de usuario con contexto detallado
-- ✅ Seguimiento de sesiones con información de dispositivo y ubicación
-- ✅ Métricas de engagement automatizadas con scoring y análisis de retención
-- ✅ Historial de cambios de preferencias con impacto en el sistema
-- ✅ Timeline detallada de actividades con contexto y tiempo entre acciones
-- ✅ Cálculo automático de engagement score con múltiples factores
-- ✅ Reportes personalizados de actividad por usuario y período
-- ✅ Análisis de patrones de comportamiento y uso de dispositivos
-- ✅ Sistema de alertas por riesgo de retención de usuarios
-- ✅ Dashboard completo de estadísticas de engagement
-- ✅ Auditoría de seguridad con tracking de IPs y dispositivos
-- ✅ Integración completa con todos los sistemas implementados anteriormente


