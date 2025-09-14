-- =====================================================
-- FIX SIMPLE: Eliminar vista problemática y crear tablas básicas
-- =====================================================

-- PASO 1: Eliminar vista problemática
DROP VIEW IF EXISTS user_chat_dashboard;

-- PASO 2: Crear tabla básica de conversaciones
CREATE TABLE IF NOT EXISTS chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_type VARCHAR(30) NOT NULL DEFAULT 'customer_support',
    participant_1_id UUID NOT NULL REFERENCES users(id),
    participant_2_id UUID REFERENCES users(id),
    order_id UUID REFERENCES orders(id),
    title VARCHAR(200) DEFAULT 'Conversación',
    status VARCHAR(20) DEFAULT 'active',
    total_messages INTEGER DEFAULT 0,
    unread_count_p1 INTEGER DEFAULT 0,
    unread_count_p2 INTEGER DEFAULT 0,
    last_message_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- PASO 3: Crear tabla básica de mensajes
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text',
    status VARCHAR(20) DEFAULT 'sent',
    sent_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- PASO 4: Función simple para crear conversación
CREATE OR REPLACE FUNCTION create_simple_conversation(
    user1_id UUID,
    user2_id UUID,
    order_id_param UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    conversation_id UUID;
BEGIN
    INSERT INTO chat_conversations (participant_1_id, participant_2_id, order_id)
    VALUES (user1_id, user2_id, order_id_param)
    RETURNING id INTO conversation_id;
    
    RETURN conversation_id;
END;
$$ LANGUAGE plpgsql;

-- PASO 5: Función simple para enviar mensaje
CREATE OR REPLACE FUNCTION send_simple_message(
    conversation_id UUID,
    sender_id UUID,
    message_content TEXT
) RETURNS UUID AS $$
DECLARE
    message_id UUID;
BEGIN
    INSERT INTO chat_messages (conversation_id, sender_id, content)
    VALUES (conversation_id, sender_id, message_content)
    RETURNING id INTO message_id;
    
    -- Actualizar conversación
    UPDATE chat_conversations 
    SET 
        total_messages = total_messages + 1,
        last_message_time = NOW(),
        updated_at = NOW()
    WHERE id = conversation_id;
    
    RETURN message_id;
END;
$$ LANGUAGE plpgsql;

-- PASO 6: Vista simple sin problemas
CREATE OR REPLACE VIEW simple_chat_stats AS
SELECT 
    u.id as user_id,
    u.name as user_name,
    COUNT(DISTINCT cc.id) as total_conversations,
    COUNT(DISTINCT cm.id) as total_messages
FROM users u
LEFT JOIN chat_conversations cc ON (u.id = cc.participant_1_id OR u.id = cc.participant_2_id)
LEFT JOIN chat_messages cm ON (cm.sender_id = u.id)
GROUP BY u.id, u.name;

-- ✅ FIX SIMPLE COMPLETADO
SELECT 'Sistema de chat básico creado exitosamente' as message;


