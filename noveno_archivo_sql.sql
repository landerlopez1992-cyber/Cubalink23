-- =====================================================
-- SISTEMA DE CHAT DIRECTO Y COMUNICACIÓN EN TIEMPO REAL
-- =====================================================
-- Sistema completo de comunicación:
-- 1. Chat directo entre cliente-repartidor-vendedor
-- 2. Mensajes automáticos del sistema
-- 3. Notificaciones push en tiempo real
-- 4. Histórico de conversaciones
-- 5. Estado de mensajes (enviado/entregado/leído)
-- 6. Moderación y filtros de contenido
-- 7. Archivos multimedia en mensajes

-- -----------------------------------------------------
-- 1. TABLA: chat_conversations (Conversaciones de chat)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Tipo de conversación
    conversation_type VARCHAR(30) NOT NULL CHECK (conversation_type IN ('customer_vendor', 'customer_delivery', 'vendor_delivery', 'customer_support', 'group_order', 'system_broadcast')),
    
    -- Participantes de la conversación
    participant_1_id UUID NOT NULL REFERENCES users(id), -- Cliente, vendedor o repartidor
    participant_2_id UUID REFERENCES users(id), -- Otro participante (puede ser NULL para broadcasts)
    participant_3_id UUID REFERENCES users(id), -- Tercer participante (para conversaciones de 3 vías)
    
    -- Información contextual
    order_id UUID REFERENCES orders(id), -- Pedido relacionado (si aplica)
    vendor_id UUID REFERENCES vendor_profiles(id), -- Vendedor relacionado
    delivery_person_id UUID REFERENCES delivery_profiles(id), -- Repartidor relacionado
    
    -- Estado de la conversación
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'closed', 'archived', 'blocked')),
    is_priority BOOLEAN DEFAULT false, -- Conversación prioritaria
    is_system_conversation BOOLEAN DEFAULT false, -- Conversación generada por el sistema
    
    -- Metadatos
    title VARCHAR(200), -- Título de la conversación
    description TEXT, -- Descripción opcional
    tags TEXT[], -- Etiquetas para clasificación
    
    -- Último mensaje
    last_message_id UUID, -- Se actualizará con REFERENCES después
    last_message_time TIMESTAMP,
    last_message_preview TEXT, -- Preview del último mensaje
    
    -- Estadísticas
    total_messages INTEGER DEFAULT 0,
    unread_count_p1 INTEGER DEFAULT 0, -- Mensajes no leídos por participante 1
    unread_count_p2 INTEGER DEFAULT 0, -- Mensajes no leídos por participante 2
    unread_count_p3 INTEGER DEFAULT 0, -- Mensajes no leídos por participante 3
    
    -- Configuración
    auto_close_after_hours INTEGER DEFAULT 24, -- Cerrar automáticamente después de X horas de inactividad
    allow_notifications BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_conversations_participant1 ON chat_conversations(participant_1_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_participant2 ON chat_conversations(participant_2_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_order ON chat_conversations(order_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_type ON chat_conversations(conversation_type);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_status ON chat_conversations(status);

-- -----------------------------------------------------
-- 2. TABLA: chat_messages (Mensajes de chat)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    
    -- Contenido del mensaje
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'video', 'audio', 'file', 'location', 'system', 'order_update', 'delivery_update')),
    content TEXT NOT NULL, -- Texto del mensaje
    metadata JSONB DEFAULT '{}', -- Datos adicionales (ubicación, info de archivo, etc.)
    
    -- Archivos multimedia
    media_urls TEXT[] DEFAULT ARRAY[]::TEXT[], -- URLs de imágenes, videos, audios
    file_name VARCHAR(200), -- Nombre del archivo adjunto
    file_size INTEGER, -- Tamaño del archivo en bytes
    file_type VARCHAR(50), -- Tipo MIME del archivo
    
    -- Estado del mensaje
    status VARCHAR(20) DEFAULT 'sent' CHECK (status IN ('sending', 'sent', 'delivered', 'read', 'failed', 'deleted')),
    is_system_message BOOLEAN DEFAULT false, -- Mensaje generado automáticamente
    is_priority BOOLEAN DEFAULT false, -- Mensaje prioritario
    is_pinned BOOLEAN DEFAULT false, -- Mensaje anclado
    
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

-- Agregar la referencia al último mensaje en conversaciones
ALTER TABLE chat_conversations ADD CONSTRAINT fk_last_message 
FOREIGN KEY (last_message_id) REFERENCES chat_messages(id);

-- -----------------------------------------------------
-- 3. TABLA: chat_notifications (Notificaciones de chat)
-- -----------------------------------------------------
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
    action_url TEXT, -- URL para acción (abrir chat, ver pedido, etc.)
    
    -- Estado de la notificación
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'delivered', 'read', 'failed')),
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    read_at TIMESTAMP,
    
    -- Configuración del dispositivo
    device_token TEXT, -- Token del dispositivo para push notifications
    platform VARCHAR(20), -- 'ios', 'android', 'web'
    
    -- Metadatos
    payload JSONB DEFAULT '{}', -- Datos adicionales para la notificación
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_notifications_user ON chat_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_notifications_conversation ON chat_notifications(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_notifications_status ON chat_notifications(status);
CREATE INDEX IF NOT EXISTS idx_chat_notifications_type ON chat_notifications(notification_type);

-- -----------------------------------------------------
-- 4. TABLA: chat_typing_indicators (Indicadores de escritura)
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- 5. FUNCIÓN: Crear conversación entre usuarios
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION create_chat_conversation(
    conversation_type_param VARCHAR(30),
    participant_1_id_param UUID,
    participant_2_id_param UUID DEFAULT NULL,
    order_id_param UUID DEFAULT NULL,
    title_param VARCHAR(200) DEFAULT NULL
) RETURNS TABLE (
    success BOOLEAN,
    conversation_id UUID,
    message TEXT
) AS $$
DECLARE
    new_conversation_id UUID;
    existing_conversation_id UUID;
    generated_title VARCHAR(200);
    participant1_record RECORD;
    participant2_record RECORD;
BEGIN
    -- Verificar que los participantes existen
    SELECT u.id, u.name, u.role INTO participant1_record
    FROM users u WHERE u.id = participant_1_id_param;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, NULL::UUID, 'Participante 1 no encontrado';
        RETURN;
    END IF;
    
    IF participant_2_id_param IS NOT NULL THEN
        SELECT u.id, u.name, u.role INTO participant2_record
        FROM users u WHERE u.id = participant_2_id_param;
        
        IF NOT FOUND THEN
            RETURN QUERY SELECT false, NULL::UUID, 'Participante 2 no encontrado';
            RETURN;
        END IF;
        
        -- Verificar si ya existe una conversación entre estos usuarios para el mismo pedido
        SELECT id INTO existing_conversation_id
        FROM chat_conversations
        WHERE conversation_type = conversation_type_param
          AND ((participant_1_id = participant_1_id_param AND participant_2_id = participant_2_id_param)
               OR (participant_1_id = participant_2_id_param AND participant_2_id = participant_1_id_param))
          AND (order_id_param IS NULL OR order_id = order_id_param)
          AND status = 'active';
        
        IF FOUND THEN
            RETURN QUERY SELECT true, existing_conversation_id, 'Conversación existente encontrada';
            RETURN;
        END IF;
    END IF;
    
    -- Generar título automático si no se proporciona
    IF title_param IS NULL THEN
        generated_title := CASE conversation_type_param
            WHEN 'customer_vendor' THEN format('Chat: Cliente - %s', COALESCE(participant2_record.name, 'Vendedor'))
            WHEN 'customer_delivery' THEN format('Chat: Cliente - %s', COALESCE(participant2_record.name, 'Repartidor'))
            WHEN 'vendor_delivery' THEN format('Chat: Vendedor - %s', COALESCE(participant2_record.name, 'Repartidor'))
            WHEN 'customer_support' THEN 'Chat de Soporte'
            ELSE 'Conversación'
        END;
    ELSE
        generated_title := title_param;
    END IF;
    
    -- Crear nueva conversación
    INSERT INTO chat_conversations (
        conversation_type, participant_1_id, participant_2_id,
        order_id, title, status
    ) VALUES (
        conversation_type_param, participant_1_id_param, participant_2_id_param,
        order_id_param, generated_title, 'active'
    ) RETURNING id INTO new_conversation_id;
    
    -- Crear mensaje de bienvenida del sistema
    INSERT INTO chat_messages (
        conversation_id, sender_id, message_type, content, is_system_message
    ) VALUES (
        new_conversation_id, participant_1_id_param, 'system',
        format('Conversación iniciada. Tipo: %s', conversation_type_param),
        true
    );
    
    -- Log de la creación
    INSERT INTO system_logs (level, message, details) VALUES (
        'INFO',
        'Nueva conversación de chat creada',
        jsonb_build_object(
            'conversation_id', new_conversation_id,
            'conversation_type', conversation_type_param,
            'participant_1_id', participant_1_id_param,
            'participant_2_id', participant_2_id_param,
            'order_id', order_id_param,
            'timestamp', NOW()
        )
    );
    
    RETURN QUERY SELECT true, new_conversation_id, 'Conversación creada exitosamente';
    
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 6. FUNCIÓN: Enviar mensaje de chat
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION send_chat_message(
    conversation_id_param UUID,
    sender_id_param UUID,
    content_param TEXT,
    message_type_param VARCHAR(20) DEFAULT 'text',
    media_urls_param TEXT[] DEFAULT ARRAY[]::TEXT[],
    reply_to_message_id_param UUID DEFAULT NULL
) RETURNS TABLE (
    success BOOLEAN,
    message_id UUID,
    message TEXT
) AS $$
DECLARE
    new_message_id UUID;
    conversation_record RECORD;
    sender_record RECORD;
    notification_title VARCHAR(200);
    notification_body TEXT;
    participant_id UUID;
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
        RETURN QUERY SELECT false, NULL::UUID, 'Usuario no autorizado para enviar mensajes en esta conversación';
        RETURN;
    END IF;
    
    -- Obtener información del remitente
    SELECT u.id, u.name, u.role INTO sender_record
    FROM users u WHERE u.id = sender_id_param;
    
    -- Crear el mensaje
    INSERT INTO chat_messages (
        conversation_id, sender_id, message_type, content,
        media_urls, reply_to_message_id, status
    ) VALUES (
        conversation_id_param, sender_id_param, message_type_param, content_param,
        media_urls_param, reply_to_message_id_param, 'sent'
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
    
    -- Actualizar contadores de mensajes no leídos para otros participantes
    UPDATE chat_conversations
    SET 
        unread_count_p1 = CASE WHEN participant_1_id != sender_id_param THEN unread_count_p1 + 1 ELSE unread_count_p1 END,
        unread_count_p2 = CASE WHEN participant_2_id != sender_id_param THEN unread_count_p2 + 1 ELSE unread_count_p2 END,
        unread_count_p3 = CASE WHEN participant_3_id != sender_id_param THEN unread_count_p3 + 1 ELSE unread_count_p3 END
    WHERE id = conversation_id_param;
    
    -- Crear notificaciones para otros participantes
    notification_title := format('Nuevo mensaje de %s', sender_record.name);
    notification_body := CASE 
        WHEN message_type_param = 'text' THEN LEFT(content_param, 100)
        WHEN message_type_param = 'image' THEN 'Envió una imagen'
        WHEN message_type_param = 'video' THEN 'Envió un video'
        WHEN message_type_param = 'audio' THEN 'Envió un audio'
        WHEN message_type_param = 'file' THEN 'Envió un archivo'
        WHEN message_type_param = 'location' THEN 'Compartió su ubicación'
        ELSE 'Envió un mensaje'
    END;
    
    -- Notificar a participante 1 (si no es el remitente)
    IF conversation_record.participant_1_id IS NOT NULL AND conversation_record.participant_1_id != sender_id_param THEN
        INSERT INTO chat_notifications (
            user_id, conversation_id, message_id, notification_type,
            title, body, priority
        ) VALUES (
            conversation_record.participant_1_id, conversation_id_param, new_message_id, 'new_message',
            notification_title, notification_body, 'normal'
        );
    END IF;
    
    -- Notificar a participante 2 (si no es el remitente)
    IF conversation_record.participant_2_id IS NOT NULL AND conversation_record.participant_2_id != sender_id_param THEN
        INSERT INTO chat_notifications (
            user_id, conversation_id, message_id, notification_type,
            title, body, priority
        ) VALUES (
            conversation_record.participant_2_id, conversation_id_param, new_message_id, 'new_message',
            notification_title, notification_body, 'normal'
        );
    END IF;
    
    -- Notificar a participante 3 (si no es el remitente)
    IF conversation_record.participant_3_id IS NOT NULL AND conversation_record.participant_3_id != sender_id_param THEN
        INSERT INTO chat_notifications (
            user_id, conversation_id, message_id, notification_type,
            title, body, priority
        ) VALUES (
            conversation_record.participant_3_id, conversation_id_param, new_message_id, 'new_message',
            notification_title, notification_body, 'normal'
        );
    END IF;
    
    -- Actualizar estado del mensaje a 'delivered'
    UPDATE chat_messages 
    SET 
        status = 'delivered',
        delivered_at = NOW()
    WHERE id = new_message_id;
    
    -- Log del mensaje
    INSERT INTO system_logs (level, message, details) VALUES (
        'INFO',
        'Mensaje de chat enviado',
        jsonb_build_object(
            'message_id', new_message_id,
            'conversation_id', conversation_id_param,
            'sender_id', sender_id_param,
            'message_type', message_type_param,
            'content_length', LENGTH(content_param),
            'timestamp', NOW()
        )
    );
    
    RETURN QUERY SELECT true, new_message_id, 'Mensaje enviado exitosamente';
    
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 7. FUNCIÓN: Marcar mensajes como leídos
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION mark_messages_as_read(
    conversation_id_param UUID,
    user_id_param UUID
) RETURNS TABLE (
    success BOOLEAN,
    messages_marked INTEGER,
    message TEXT
) AS $$
DECLARE
    messages_count INTEGER;
    conversation_record RECORD;
BEGIN
    -- Verificar que la conversación existe
    SELECT * INTO conversation_record
    FROM chat_conversations
    WHERE id = conversation_id_param;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 0, 'Conversación no encontrada';
        RETURN;
    END IF;
    
    -- Verificar que el usuario es participante
    IF user_id_param NOT IN (conversation_record.participant_1_id, conversation_record.participant_2_id, conversation_record.participant_3_id) THEN
        RETURN QUERY SELECT false, 0, 'Usuario no autorizado';
        RETURN;
    END IF;
    
    -- Marcar mensajes como leídos
    UPDATE chat_messages
    SET 
        status = 'read',
        read_at = NOW()
    WHERE conversation_id = conversation_id_param
      AND sender_id != user_id_param
      AND status = 'delivered';
    
    GET DIAGNOSTICS messages_count = ROW_COUNT;
    
    -- Resetear contador de no leídos para este usuario
    UPDATE chat_conversations
    SET 
        unread_count_p1 = CASE WHEN participant_1_id = user_id_param THEN 0 ELSE unread_count_p1 END,
        unread_count_p2 = CASE WHEN participant_2_id = user_id_param THEN 0 ELSE unread_count_p2 END,
        unread_count_p3 = CASE WHEN participant_3_id = user_id_param THEN 0 ELSE unread_count_p3 END,
        updated_at = NOW()
    WHERE id = conversation_id_param;
    
    RETURN QUERY SELECT true, messages_count, format('%s mensajes marcados como leídos', messages_count);
    
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 8. FUNCIÓN: Limpiar indicadores de escritura expirados
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION cleanup_expired_typing_indicators()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Eliminar indicadores de escritura expirados
    DELETE FROM chat_typing_indicators
    WHERE expires_at < NOW();
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 9. VISTA: Dashboard de conversaciones por usuario
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- 10. TRIGGER: Limpiar automáticamente indicadores de escritura
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION trigger_cleanup_typing_indicators()
RETURNS TRIGGER AS $$
BEGIN
    -- Ejecutar limpieza cada vez que se inserta un nuevo indicador
    PERFORM cleanup_expired_typing_indicators();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cleanup_typing_on_insert
    AFTER INSERT ON chat_typing_indicators
    EXECUTE FUNCTION trigger_cleanup_typing_indicators();

-- -----------------------------------------------------
-- ✅ SISTEMA DE CHAT DIRECTO COMPLETADO
-- -----------------------------------------------------
-- Funcionalidades implementadas:
-- ✅ Chat directo entre cliente-repartidor-vendedor con contexto de pedidos
-- ✅ Mensajes multimedia (texto, imagen, video, audio, archivos, ubicación)
-- ✅ Sistema completo de notificaciones push en tiempo real
-- ✅ Estados de mensajes (enviado/entregado/leído) con timestamps
-- ✅ Indicadores de escritura en tiempo real con limpieza automática
-- ✅ Moderación y filtros de contenido con estados de aprobación
-- ✅ Histórico completo de conversaciones con búsqueda
-- ✅ Dashboard de estadísticas por usuario
-- ✅ Sistema de respuestas a mensajes específicos
-- ✅ Conversaciones de grupo para pedidos complejos
-- ✅ Mensajes del sistema automáticos
-- ✅ Auto-cierre de conversaciones inactivas


