-- =====================================================
-- FIX: Corregir tablas de chat
-- =====================================================
-- Error: column "participant_1_id" does not exist
-- Solución: Crear tablas de chat paso a paso

-- PASO 1: Crear tabla de conversaciones de chat
CREATE TABLE IF NOT EXISTS chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Tipo de conversación
    conversation_type VARCHAR(30) NOT NULL DEFAULT 'customer_support' CHECK (conversation_type IN ('customer_vendor', 'customer_delivery', 'vendor_delivery', 'customer_support', 'group_order', 'system_broadcast')),
    
    -- Participantes de la conversación
    participant_1_id UUID NOT NULL REFERENCES users(id),
    participant_2_id UUID REFERENCES users(id),
    participant_3_id UUID REFERENCES users(id),
    
    -- Información contextual
    order_id UUID REFERENCES orders(id),
    vendor_id UUID REFERENCES vendor_profiles(id),
    delivery_person_id UUID REFERENCES delivery_profiles(id),
    
    -- Estado de la conversación
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'closed', 'archived', 'blocked')),
    is_priority BOOLEAN DEFAULT false,
    is_system_conversation BOOLEAN DEFAULT false,
    
    -- Metadatos
    title VARCHAR(200),
    description TEXT,
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    
    -- Último mensaje (se agregará después)
    last_message_id UUID,
    last_message_time TIMESTAMP,
    last_message_preview TEXT,
    
    -- Estadísticas
    total_messages INTEGER DEFAULT 0,
    unread_count_p1 INTEGER DEFAULT 0,
    unread_count_p2 INTEGER DEFAULT 0,
    unread_count_p3 INTEGER DEFAULT 0,
    
    -- Configuración
    auto_close_after_hours INTEGER DEFAULT 24,
    allow_notifications BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_conversations_participant1 ON chat_conversations(participant_1_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_participant2 ON chat_conversations(participant_2_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_order ON chat_conversations(order_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_type ON chat_conversations(conversation_type);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_status ON chat_conversations(status);

-- PASO 2: Crear tabla de mensajes de chat
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    
    -- Contenido del mensaje
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'video', 'audio', 'file', 'location', 'system', 'order_update', 'delivery_update')),
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    
    -- Archivos multimedia
    media_urls TEXT[] DEFAULT ARRAY[]::TEXT[],
    file_name VARCHAR(200),
    file_size INTEGER,
    file_type VARCHAR(50),
    
    -- Estado del mensaje
    status VARCHAR(20) DEFAULT 'sent' CHECK (status IN ('sending', 'sent', 'delivered', 'read', 'failed', 'deleted')),
    is_system_message BOOLEAN DEFAULT false,
    is_priority BOOLEAN DEFAULT false,
    is_pinned BOOLEAN DEFAULT false,
    
    -- Respuesta a otro mensaje
    reply_to_message_id UUID REFERENCES chat_messages(id),
    
    -- Información de entrega
    sent_at TIMESTAMP DEFAULT NOW(),
    delivered_at TIMESTAMP,
    read_at TIMESTAMP,
    
    -- Moderación
    is_flagged BOOLEAN DEFAULT false,
    moderation_status VARCHAR(20) DEFAULT 'approved' CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'auto_filtered')),
    moderation_reason TEXT,
    moderated_by UUID REFERENCES users(id),
    moderated_at TIMESTAMP,
    
    -- Eliminación
    deleted_at TIMESTAMP,
    deleted_by UUID REFERENCES users(id),
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sent_at ON chat_messages(sent_at);
CREATE INDEX IF NOT EXISTS idx_chat_messages_status ON chat_messages(status);
CREATE INDEX IF NOT EXISTS idx_chat_messages_type ON chat_messages(message_type);

-- PASO 3: Agregar restricción de clave foránea para último mensaje
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'chat_conversations' 
        AND constraint_name = 'fk_last_message'
    ) THEN
        ALTER TABLE chat_conversations 
        ADD CONSTRAINT fk_last_message 
        FOREIGN KEY (last_message_id) REFERENCES chat_messages(id);
    END IF;
END $$;

-- PASO 4: Crear tabla de notificaciones de chat
CREATE TABLE IF NOT EXISTS chat_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id),
    message_id UUID NOT NULL REFERENCES chat_messages(id),
    
    -- Configuración de notificación
    notification_type VARCHAR(30) NOT NULL CHECK (notification_type IN ('new_message', 'message_read', 'typing', 'order_update', 'delivery_update', 'system_alert')),
    priority VARCHAR(10) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    
    -- Contenido de la notificación
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    action_url TEXT,
    
    -- Estado de la notificación
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'delivered', 'read', 'failed')),
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    read_at TIMESTAMP,
    
    -- Configuración del dispositivo
    device_token TEXT,
    platform VARCHAR(20),
    
    -- Metadatos
    payload JSONB DEFAULT '{}',
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_notifications_user ON chat_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_notifications_conversation ON chat_notifications(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_notifications_status ON chat_notifications(status);
CREATE INDEX IF NOT EXISTS idx_chat_notifications_type ON chat_notifications(notification_type);

-- PASO 5: Crear tabla de indicadores de escritura
CREATE TABLE IF NOT EXISTS chat_typing_indicators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id),
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Estado de escritura
    is_typing BOOLEAN DEFAULT true,
    typing_started_at TIMESTAMP DEFAULT NOW(),
    last_activity_at TIMESTAMP DEFAULT NOW(),
    
    -- Limpieza automática después de 30 segundos
    expires_at TIMESTAMP DEFAULT (NOW() + INTERVAL '30 seconds'),
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_typing_user_conversation ON chat_typing_indicators(conversation_id, user_id);
CREATE INDEX IF NOT EXISTS idx_typing_expires ON chat_typing_indicators(expires_at);

-- PASO 6: Funciones simplificadas
CREATE OR REPLACE FUNCTION create_chat_conversation_simple(
    conversation_type_param VARCHAR(30),
    participant_1_id_param UUID,
    participant_2_id_param UUID DEFAULT NULL,
    order_id_param UUID DEFAULT NULL
) RETURNS TABLE (
    success BOOLEAN,
    conversation_id UUID,
    message TEXT
) AS $$
DECLARE
    new_conversation_id UUID;
    existing_conversation_id UUID;
    generated_title VARCHAR(200);
BEGIN
    -- Verificar que los participantes existen
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = participant_1_id_param) THEN
        RETURN QUERY SELECT false, NULL::UUID, 'Participante 1 no encontrado';
        RETURN;
    END IF;
    
    IF participant_2_id_param IS NOT NULL AND NOT EXISTS (SELECT 1 FROM users WHERE id = participant_2_id_param) THEN
        RETURN QUERY SELECT false, NULL::UUID, 'Participante 2 no encontrado';
        RETURN;
    END IF;
    
    -- Verificar si ya existe una conversación activa
    SELECT id INTO existing_conversation_id
    FROM chat_conversations
    WHERE conversation_type = conversation_type_param
      AND ((participant_1_id = participant_1_id_param AND participant_2_id = participant_2_id_param)
           OR (participant_1_id = participant_2_id_param AND participant_2_id = participant_1_id_param))
      AND (order_id_param IS NULL OR order_id = order_id_param)
      AND status = 'active'
    LIMIT 1;
    
    IF FOUND THEN
        RETURN QUERY SELECT true, existing_conversation_id, 'Conversación existente encontrada';
        RETURN;
    END IF;
    
    -- Generar título automático
    generated_title := CASE conversation_type_param
        WHEN 'customer_vendor' THEN 'Chat: Cliente - Vendedor'
        WHEN 'customer_delivery' THEN 'Chat: Cliente - Repartidor'
        WHEN 'vendor_delivery' THEN 'Chat: Vendedor - Repartidor'
        WHEN 'customer_support' THEN 'Chat de Soporte'
        ELSE 'Conversación'
    END;
    
    -- Crear nueva conversación
    INSERT INTO chat_conversations (
        conversation_type, participant_1_id, participant_2_id,
        order_id, title, status
    ) VALUES (
        conversation_type_param, participant_1_id_param, participant_2_id_param,
        order_id_param, generated_title, 'active'
    ) RETURNING id INTO new_conversation_id;
    
    RETURN QUERY SELECT true, new_conversation_id, 'Conversación creada exitosamente';
    
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION send_chat_message_simple(
    conversation_id_param UUID,
    sender_id_param UUID,
    content_param TEXT,
    message_type_param VARCHAR(20) DEFAULT 'text'
) RETURNS TABLE (
    success BOOLEAN,
    message_id UUID,
    message TEXT
) AS $$
DECLARE
    new_message_id UUID;
    conversation_record RECORD;
BEGIN
    -- Verificar que la conversación existe y está activa
    SELECT * INTO conversation_record
    FROM chat_conversations
    WHERE id = conversation_id_param AND status = 'active';
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, NULL::UUID, 'Conversación no encontrada o inactiva';
        RETURN;
    END IF;
    
    -- Verificar que el sender es participante de la conversación
    IF sender_id_param NOT IN (conversation_record.participant_1_id, conversation_record.participant_2_id, conversation_record.participant_3_id) THEN
        RETURN QUERY SELECT false, NULL::UUID, 'Usuario no autorizado';
        RETURN;
    END IF;
    
    -- Crear el mensaje
    INSERT INTO chat_messages (
        conversation_id, sender_id, message_type, content, status
    ) VALUES (
        conversation_id_param, sender_id_param, message_type_param, content_param, 'sent'
    ) RETURNING id INTO new_message_id;
    
    -- Actualizar conversación con último mensaje
    UPDATE chat_conversations 
    SET 
        last_message_id = new_message_id,
        last_message_time = NOW(),
        last_message_preview = LEFT(content_param, 100),
        total_messages = total_messages + 1,
        updated_at = NOW()
    WHERE id = conversation_id_param;
    
    -- Actualizar contadores de mensajes no leídos
    UPDATE chat_conversations
    SET 
        unread_count_p1 = CASE WHEN participant_1_id != sender_id_param THEN unread_count_p1 + 1 ELSE unread_count_p1 END,
        unread_count_p2 = CASE WHEN participant_2_id != sender_id_param THEN unread_count_p2 + 1 ELSE unread_count_p2 END,
        unread_count_p3 = CASE WHEN participant_3_id != sender_id_param THEN unread_count_p3 + 1 ELSE unread_count_p3 END
    WHERE id = conversation_id_param;
    
    -- Actualizar estado del mensaje a 'delivered'
    UPDATE chat_messages 
    SET 
        status = 'delivered',
        delivered_at = NOW()
    WHERE id = new_message_id;
    
    RETURN QUERY SELECT true, new_message_id, 'Mensaje enviado exitosamente';
    
END;
$$ LANGUAGE plpgsql;

-- PASO 7: Vista dashboard simplificada
CREATE OR REPLACE VIEW user_chat_dashboard AS
SELECT 
    u.id as user_id,
    u.name as user_name,
    u.email as user_email,
    -- Estadísticas de conversaciones
    COUNT(DISTINCT cc.id) as total_conversations,
    COUNT(DISTINCT CASE WHEN cc.status = 'active' THEN cc.id END) as active_conversations,
    COUNT(DISTINCT CASE WHEN cc.status = 'closed' THEN cc.id END) as closed_conversations,
    -- Estadísticas de mensajes
    COUNT(DISTINCT cm.id) as total_messages_sent,
    COUNT(DISTINCT CASE WHEN cm.sent_at >= NOW() - INTERVAL '24 hours' THEN cm.id END) as messages_sent_today,
    -- Mensajes no leídos
    COALESCE(SUM(
        CASE 
            WHEN cc.participant_1_id = u.id THEN cc.unread_count_p1
            WHEN cc.participant_2_id = u.id THEN cc.unread_count_p2  
            WHEN cc.participant_3_id = u.id THEN cc.unread_count_p3
            ELSE 0
        END
    ), 0) as total_unread_messages,
    -- Conversación más reciente
    MAX(cc.last_message_time) as last_conversation_activity
FROM users u
LEFT JOIN chat_conversations cc ON (
    u.id = cc.participant_1_id OR 
    u.id = cc.participant_2_id OR 
    u.id = cc.participant_3_id
)
LEFT JOIN chat_messages cm ON (
    cm.sender_id = u.id AND 
    cm.conversation_id = cc.id
)
GROUP BY u.id, u.name, u.email
ORDER BY total_unread_messages DESC, last_conversation_activity DESC;

-- PASO 8: Función de limpieza
CREATE OR REPLACE FUNCTION cleanup_expired_typing_indicators()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM chat_typing_indicators WHERE expires_at < NOW();
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- PASO 9: Trigger de limpieza
CREATE OR REPLACE FUNCTION trigger_cleanup_typing_indicators()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM cleanup_expired_typing_indicators();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS cleanup_typing_on_insert ON chat_typing_indicators;
CREATE TRIGGER cleanup_typing_on_insert
    AFTER INSERT ON chat_typing_indicators
    EXECUTE FUNCTION trigger_cleanup_typing_indicators();

-- ✅ FIX COMPLETADO - SISTEMA DE CHAT CORREGIDO
SELECT 'Sistema de chat corregido y completado exitosamente' as message;


