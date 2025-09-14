-- =====================================================
-- FASE 4: CHAT DIRECTO VENDEDOR ↔ REPARTIDOR
-- =====================================================
-- Sistema de chat en tiempo real entre vendedores y repartidores
-- Permite comunicación directa durante el proceso de entrega
-- Incluye mensajes, archivos, ubicación y notificaciones

-- -----------------------------------------------------
-- 1. TABLA: chat_conversations (Conversaciones)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES users(id),
    delivery_person_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'active', -- active, closed, archived
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
    UNIQUE(order_id) -- Una conversación por pedido
);

CREATE INDEX IF NOT EXISTS idx_chat_conversations_order ON chat_conversations(order_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_vendor ON chat_conversations(vendor_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_delivery ON chat_conversations(delivery_person_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_status ON chat_conversations(status);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_updated ON chat_conversations(updated_at DESC);

-- -----------------------------------------------------
-- 2. TABLA: chat_messages (Mensajes del chat)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    sender_role VARCHAR(20) NOT NULL, -- vendor, delivery
    message_type VARCHAR(20) DEFAULT 'text', -- text, image, file, location, system
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

CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created ON chat_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_unread ON chat_messages(is_read) WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_chat_messages_type ON chat_messages(message_type);

-- -----------------------------------------------------
-- 3. TABLA: chat_notifications (Notificaciones de chat)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES users(id),
    message_id UUID NOT NULL REFERENCES chat_messages(id) ON DELETE CASCADE,
    notification_type VARCHAR(30) DEFAULT 'new_message', -- new_message, typing, location_shared
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    is_sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_notifications_recipient ON chat_notifications(recipient_id);
CREATE INDEX IF NOT EXISTS idx_chat_notifications_conversation ON chat_notifications(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_notifications_unread ON chat_notifications(is_read) WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_chat_notifications_unsent ON chat_notifications(is_sent) WHERE is_sent = false;

-- -----------------------------------------------------
-- 4. TABLA: quick_responses (Respuestas rápidas)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS quick_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role VARCHAR(20) NOT NULL, -- vendor, delivery, both
    category VARCHAR(50) NOT NULL, -- pickup, delivery, problem, general
    message_text TEXT NOT NULL,
    order_index INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_quick_responses_role ON quick_responses(role);
CREATE INDEX IF NOT EXISTS idx_quick_responses_category ON quick_responses(category);
CREATE INDEX IF NOT EXISTS idx_quick_responses_active ON quick_responses(is_active);

-- Insertar respuestas rápidas por defecto
INSERT INTO quick_responses (role, category, message_text, order_index) VALUES
-- Para vendedores
('vendor', 'pickup', 'El pedido está listo para recoger', 1),
('vendor', 'pickup', 'El pedido estará listo en 5 minutos', 2),
('vendor', 'pickup', 'Por favor llama cuando llegues', 3),
('vendor', 'pickup', 'Estoy en el local, puedes venir', 4),
('vendor', 'problem', 'Producto agotado, ¿hay sustituto?', 5),
('vendor', 'problem', 'Necesito 10 minutos más de preparación', 6),
('vendor', 'general', 'Gracias por la entrega', 7),
('vendor', 'general', 'Perfecto, todo en orden', 8),

-- Para repartidores
('delivery', 'pickup', 'Estoy llegando al local', 1),
('delivery', 'pickup', 'He llegado, ¿dónde recojo?', 2),
('delivery', 'pickup', 'Pedido recogido, en camino', 3),
('delivery', 'delivery', 'Llegando a destino en 5 min', 4),
('delivery', 'delivery', 'He llegado a la dirección', 5),
('delivery', 'delivery', 'Pedido entregado exitosamente', 6),
('delivery', 'problem', 'No encuentro la dirección', 7),
('delivery', 'problem', 'Cliente no contesta', 8),
('delivery', 'problem', 'Problema con el vehículo', 9),
('delivery', 'general', 'Entendido', 10),
('delivery', 'general', 'De acuerdo', 11),

-- Para ambos roles
('both', 'general', 'OK', 1),
('both', 'general', 'Perfecto', 2),
('both', 'general', 'Entendido', 3),
('both', 'general', 'Gracias', 4);

-- -----------------------------------------------------
-- 5. FUNCIÓN: Crear conversación automáticamente
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION create_chat_conversation(
    order_id_param UUID,
    vendor_id_param UUID,
    delivery_person_id_param UUID
) RETURNS UUID AS $$
DECLARE
    conversation_id_result UUID;
BEGIN
    -- Verificar si ya existe una conversación para este pedido
    SELECT id INTO conversation_id_result
    FROM chat_conversations
    WHERE order_id = order_id_param;
    
    -- Si no existe, crear nueva conversación
    IF conversation_id_result IS NULL THEN
        INSERT INTO chat_conversations (order_id, vendor_id, delivery_person_id)
        VALUES (order_id_param, vendor_id_param, delivery_person_id_param)
        RETURNING id INTO conversation_id_result;
        
        -- Mensaje de sistema inicial
        INSERT INTO chat_messages (
            conversation_id,
            sender_id,
            sender_role,
            message_type,
            content
        ) VALUES (
            conversation_id_result,
            vendor_id_param,
            'system',
            'system',
            'Chat iniciado. Vendedor y repartidor pueden comunicarse aquí.'
        );
    END IF;
    
    RETURN conversation_id_result;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 6. FUNCIÓN: Enviar mensaje
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION send_chat_message(
    conversation_id_param UUID,
    sender_id_param UUID,
    message_type_param VARCHAR(20) DEFAULT 'text',
    content_param TEXT DEFAULT NULL,
    file_url_param TEXT DEFAULT NULL,
    file_name_param VARCHAR(255) DEFAULT NULL,
    file_size_param INTEGER DEFAULT NULL,
    file_type_param VARCHAR(50) DEFAULT NULL,
    location_lat_param DECIMAL(10,8) DEFAULT NULL,
    location_lng_param DECIMAL(11,8) DEFAULT NULL,
    location_address_param TEXT DEFAULT NULL,
    reply_to_message_id_param UUID DEFAULT NULL
) RETURNS TABLE (
    message_id UUID,
    success BOOLEAN,
    error_message TEXT
) AS $$
DECLARE
    sender_role_val VARCHAR(20);
    recipient_id_val UUID;
    recipient_role_val VARCHAR(20);
    conversation_record RECORD;
    message_id_result UUID;
    notification_title VARCHAR(255);
    notification_body TEXT;
BEGIN
    -- Obtener información de la conversación
    SELECT 
        c.*,
        CASE WHEN c.vendor_id = sender_id_param THEN 'vendor' ELSE 'delivery' END as sender_role,
        CASE WHEN c.vendor_id = sender_id_param THEN c.delivery_person_id ELSE c.vendor_id END as recipient_id,
        CASE WHEN c.vendor_id = sender_id_param THEN 'delivery' ELSE 'vendor' END as recipient_role
    INTO conversation_record
    FROM chat_conversations c
    WHERE c.id = conversation_id_param;
    
    -- Verificar que la conversación existe y el sender es válido
    IF conversation_record IS NULL THEN
        RETURN QUERY SELECT NULL::UUID, false, 'Conversación no encontrada';
        RETURN;
    END IF;
    
    IF sender_id_param NOT IN (conversation_record.vendor_id, conversation_record.delivery_person_id) THEN
        RETURN QUERY SELECT NULL::UUID, false, 'Usuario no autorizado para esta conversación';
        RETURN;
    END IF;
    
    sender_role_val := conversation_record.sender_role;
    recipient_id_val := conversation_record.recipient_id;
    recipient_role_val := conversation_record.recipient_role;
    
    -- Insertar el mensaje
    INSERT INTO chat_messages (
        conversation_id,
        sender_id,
        sender_role,
        message_type,
        content,
        file_url,
        file_name,
        file_size,
        file_type,
        location_lat,
        location_lng,
        location_address,
        reply_to_message_id
    ) VALUES (
        conversation_id_param,
        sender_id_param,
        sender_role_val,
        message_type_param,
        content_param,
        file_url_param,
        file_name_param,
        file_size_param,
        file_type_param,
        location_lat_param,
        location_lng_param,
        location_address_param,
        reply_to_message_id_param
    ) RETURNING id INTO message_id_result;
    
    -- Actualizar conversación
    UPDATE chat_conversations
    SET 
        updated_at = NOW(),
        last_message_at = NOW(),
        last_message_preview = CASE 
            WHEN message_type_param = 'text' THEN LEFT(content_param, 100)
            WHEN message_type_param = 'image' THEN '📷 Imagen'
            WHEN message_type_param = 'file' THEN '📎 ' || COALESCE(file_name_param, 'Archivo')
            WHEN message_type_param = 'location' THEN '📍 Ubicación compartida'
            ELSE 'Mensaje'
        END,
        vendor_unread_count = CASE 
            WHEN sender_role_val = 'delivery' THEN vendor_unread_count + 1 
            ELSE vendor_unread_count 
        END,
        delivery_unread_count = CASE 
            WHEN sender_role_val = 'vendor' THEN delivery_unread_count + 1 
            ELSE delivery_unread_count 
        END
    WHERE id = conversation_id_param;
    
    -- Preparar notificación
    SELECT 
        CASE sender_role_val
            WHEN 'vendor' THEN 'Vendedor'
            WHEN 'delivery' THEN 'Repartidor'
            ELSE 'Usuario'
        END || ' - Pedido #' || SUBSTRING(o.id::TEXT, 1, 8)
    INTO notification_title
    FROM orders o
    WHERE o.id = conversation_record.order_id;
    
    notification_body := CASE 
        WHEN message_type_param = 'text' THEN LEFT(content_param, 150)
        WHEN message_type_param = 'image' THEN 'Te ha enviado una imagen'
        WHEN message_type_param = 'file' THEN 'Te ha enviado un archivo'
        WHEN message_type_param = 'location' THEN 'Ha compartido su ubicación'
        ELSE 'Te ha enviado un mensaje'
    END;
    
    -- Crear notificación
    INSERT INTO chat_notifications (
        conversation_id,
        recipient_id,
        message_id,
        notification_type,
        title,
        body
    ) VALUES (
        conversation_id_param,
        recipient_id_val,
        message_id_result,
        'new_message',
        notification_title,
        notification_body
    );
    
    RETURN QUERY SELECT message_id_result, true, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 7. FUNCIÓN: Marcar mensajes como leídos
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION mark_messages_as_read(
    conversation_id_param UUID,
    user_id_param UUID
) RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
    user_role_val VARCHAR(20);
BEGIN
    -- Determinar el rol del usuario
    SELECT 
        CASE WHEN vendor_id = user_id_param THEN 'vendor' ELSE 'delivery' END
    INTO user_role_val
    FROM chat_conversations
    WHERE id = conversation_id_param;
    
    -- Marcar mensajes como leídos
    UPDATE chat_messages
    SET 
        is_read = true,
        read_at = NOW()
    WHERE conversation_id = conversation_id_param
      AND sender_id != user_id_param
      AND is_read = false;
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    
    -- Resetear contador de no leídos
    UPDATE chat_conversations
    SET 
        vendor_unread_count = CASE WHEN user_role_val = 'vendor' THEN 0 ELSE vendor_unread_count END,
        delivery_unread_count = CASE WHEN user_role_val = 'delivery' THEN 0 ELSE delivery_unread_count END,
        vendor_last_seen = CASE WHEN user_role_val = 'vendor' THEN NOW() ELSE vendor_last_seen END,
        delivery_last_seen = CASE WHEN user_role_val = 'delivery' THEN NOW() ELSE delivery_last_seen END
    WHERE id = conversation_id_param;
    
    -- Marcar notificaciones como leídas
    UPDATE chat_notifications
    SET is_read = true
    WHERE conversation_id = conversation_id_param
      AND recipient_id = user_id_param
      AND is_read = false;
    
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 8. FUNCIÓN: Obtener conversaciones de un usuario
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_user_conversations(
    user_id_param UUID,
    limit_param INTEGER DEFAULT 20,
    offset_param INTEGER DEFAULT 0
) RETURNS TABLE (
    conversation_id UUID,
    order_id UUID,
    order_number VARCHAR(50),
    other_user_id UUID,
    other_user_name VARCHAR(255),
    other_user_role VARCHAR(20),
    last_message_preview TEXT,
    last_message_at TIMESTAMP,
    unread_count INTEGER,
    status VARCHAR(20),
    is_other_typing BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id as conversation_id,
        c.order_id,
        o.order_number,
        CASE WHEN c.vendor_id = user_id_param THEN c.delivery_person_id ELSE c.vendor_id END as other_user_id,
        CASE WHEN c.vendor_id = user_id_param THEN d.full_name ELSE v.full_name END as other_user_name,
        CASE WHEN c.vendor_id = user_id_param THEN 'delivery' ELSE 'vendor' END as other_user_role,
        c.last_message_preview,
        c.last_message_at,
        CASE WHEN c.vendor_id = user_id_param THEN c.vendor_unread_count ELSE c.delivery_unread_count END as unread_count,
        c.status,
        CASE WHEN c.vendor_id = user_id_param THEN c.is_delivery_typing ELSE c.is_vendor_typing END as is_other_typing
    FROM chat_conversations c
    JOIN orders o ON c.order_id = o.id
    LEFT JOIN users v ON c.vendor_id = v.id
    LEFT JOIN users d ON c.delivery_person_id = d.id
    WHERE c.vendor_id = user_id_param OR c.delivery_person_id = user_id_param
    ORDER BY c.last_message_at DESC
    LIMIT limit_param OFFSET offset_param;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 9. FUNCIÓN: Obtener mensajes de una conversación
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION get_conversation_messages(
    conversation_id_param UUID,
    limit_param INTEGER DEFAULT 50,
    offset_param INTEGER DEFAULT 0
) RETURNS TABLE (
    message_id UUID,
    sender_id UUID,
    sender_name VARCHAR(255),
    sender_role VARCHAR(20),
    message_type VARCHAR(20),
    content TEXT,
    file_url TEXT,
    file_name VARCHAR(255),
    file_size INTEGER,
    file_type VARCHAR(50),
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    location_address TEXT,
    is_read BOOLEAN,
    read_at TIMESTAMP,
    is_edited BOOLEAN,
    edited_at TIMESTAMP,
    reply_to_message_id UUID,
    reply_to_content TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id as message_id,
        m.sender_id,
        u.full_name as sender_name,
        m.sender_role,
        m.message_type,
        m.content,
        m.file_url,
        m.file_name,
        m.file_size,
        m.file_type,
        m.location_lat,
        m.location_lng,
        m.location_address,
        m.is_read,
        m.read_at,
        m.is_edited,
        m.edited_at,
        m.reply_to_message_id,
        rm.content as reply_to_content,
        m.created_at
    FROM chat_messages m
    LEFT JOIN users u ON m.sender_id = u.id
    LEFT JOIN chat_messages rm ON m.reply_to_message_id = rm.id
    WHERE m.conversation_id = conversation_id_param
    ORDER BY m.created_at DESC
    LIMIT limit_param OFFSET offset_param;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 10. FUNCIÓN: Actualizar estado de escritura
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION update_typing_status(
    conversation_id_param UUID,
    user_id_param UUID,
    is_typing_param BOOLEAN
) RETURNS BOOLEAN AS $$
DECLARE
    user_role_val VARCHAR(20);
BEGIN
    -- Determinar el rol del usuario
    SELECT 
        CASE WHEN vendor_id = user_id_param THEN 'vendor' ELSE 'delivery' END
    INTO user_role_val
    FROM chat_conversations
    WHERE id = conversation_id_param;
    
    IF user_role_val IS NULL THEN
        RETURN false;
    END IF;
    
    -- Actualizar estado de escritura
    UPDATE chat_conversations
    SET 
        is_vendor_typing = CASE WHEN user_role_val = 'vendor' THEN is_typing_param ELSE is_vendor_typing END,
        is_delivery_typing = CASE WHEN user_role_val = 'delivery' THEN is_typing_param ELSE is_delivery_typing END,
        updated_at = NOW()
    WHERE id = conversation_id_param;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 11. TRIGGER: Crear chat automáticamente al asignar repartidor
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION trigger_create_chat_on_assignment() 
RETURNS TRIGGER AS $$
BEGIN
    -- Crear chat cuando se asigna un repartidor
    IF NEW.delivery_person_id IS NOT NULL AND OLD.delivery_person_id IS NULL THEN
        PERFORM create_chat_conversation(NEW.id, NEW.vendor_id, NEW.delivery_person_id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger
DROP TRIGGER IF EXISTS trigger_create_chat_on_order_assignment ON orders;
CREATE TRIGGER trigger_create_chat_on_order_assignment
    AFTER UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trigger_create_chat_on_assignment();

-- -----------------------------------------------------
-- 12. FUNCIÓN: Cerrar conversación automáticamente
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION close_conversation_on_delivery() 
RETURNS TRIGGER AS $$
BEGIN
    -- Cerrar chat cuando el pedido se marca como entregado
    IF NEW.status = 'delivered' AND OLD.status != 'delivered' THEN
        UPDATE chat_conversations
        SET 
            status = 'closed',
            updated_at = NOW()
        WHERE order_id = NEW.id;
        
        -- Mensaje de sistema final
        INSERT INTO chat_messages (
            conversation_id,
            sender_id,
            sender_role,
            message_type,
            content
        )
        SELECT 
            c.id,
            NEW.vendor_id,
            'system',
            'system',
            'Pedido entregado. Chat cerrado automáticamente.'
        FROM chat_conversations c
        WHERE c.order_id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para cerrar chat
DROP TRIGGER IF EXISTS trigger_close_chat_on_delivery ON orders;
CREATE TRIGGER trigger_close_chat_on_delivery
    AFTER UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION close_conversation_on_delivery();

-- -----------------------------------------------------
-- 13. FUNCIÓN: Limpiar chats antiguos
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION cleanup_old_chats(
    days_old INTEGER DEFAULT 30
) RETURNS INTEGER AS $$
DECLARE
    archived_count INTEGER;
BEGIN
    -- Archivar conversaciones antiguas cerradas
    UPDATE chat_conversations
    SET status = 'archived'
    WHERE status = 'closed'
      AND updated_at < NOW() - INTERVAL '1 day' * days_old;
    
    GET DIAGNOSTICS archived_count = ROW_COUNT;
    
    -- Eliminar notificaciones leídas antiguas
    DELETE FROM chat_notifications
    WHERE is_read = true
      AND created_at < NOW() - INTERVAL '1 day' * (days_old / 2);
    
    RETURN archived_count;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- 14. VISTA: Estadísticas de chat
-- -----------------------------------------------------
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

-- -----------------------------------------------------
-- ✅ FASE 4 COMPLETADA
-- -----------------------------------------------------
-- El sistema de chat directo ahora incluye:
-- ✅ Conversaciones automáticas por pedido
-- ✅ Mensajes de texto, imágenes, archivos y ubicación
-- ✅ Notificaciones en tiempo real
-- ✅ Respuestas rápidas predefinidas
-- ✅ Estado de escritura (typing indicators)
-- ✅ Marcado de mensajes como leídos
-- ✅ Contadores de mensajes no leídos
-- ✅ Cierre automático al entregar pedido
-- ✅ Limpieza automática de chats antiguos
-- ✅ Estadísticas y monitoreo completo



