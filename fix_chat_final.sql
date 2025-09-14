-- =====================================================
-- FIX FINAL: Sistema de chat ultra simple que funciona
-- =====================================================

-- PASO 1: Eliminar todo lo que pueda causar problemas
DROP VIEW IF EXISTS simple_chat_stats CASCADE;
DROP VIEW IF EXISTS user_chat_dashboard CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS chat_conversations CASCADE;
DROP TABLE IF EXISTS chat_notifications CASCADE;
DROP TABLE IF EXISTS chat_typing_indicators CASCADE;

-- PASO 2: Crear tabla de conversaciones ultra simple
CREATE TABLE chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    participant_1_id UUID NOT NULL REFERENCES users(id),
    participant_2_id UUID REFERENCES users(id),
    order_id UUID REFERENCES orders(id),
    title VARCHAR(200) DEFAULT 'Chat',
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

-- PASO 3: Crear tabla de mensajes ultra simple
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT NOW()
);

-- PASO 4: Función ultra simple para crear chat
CREATE OR REPLACE FUNCTION create_chat(user1_id UUID, user2_id UUID)
RETURNS UUID AS $$
DECLARE
    chat_id UUID;
BEGIN
    INSERT INTO chat_conversations (participant_1_id, participant_2_id)
    VALUES (user1_id, user2_id)
    RETURNING id INTO chat_id;
    
    RETURN chat_id;
END;
$$ LANGUAGE plpgsql;

-- PASO 5: Función ultra simple para enviar mensaje
CREATE OR REPLACE FUNCTION send_message(chat_id UUID, sender_id UUID, message TEXT)
RETURNS UUID AS $$
DECLARE
    msg_id UUID;
BEGIN
    INSERT INTO chat_messages (conversation_id, sender_id, content)
    VALUES (chat_id, sender_id, message)
    RETURNING id INTO msg_id;
    
    RETURN msg_id;
END;
$$ LANGUAGE plpgsql;

-- PASO 6: Vista ultra simple sin problemas
CREATE VIEW chat_stats AS
SELECT 
    u.id,
    u.name,
    COUNT(cc.id) as chats,
    COUNT(cm.id) as messages
FROM users u
LEFT JOIN chat_conversations cc ON u.id = cc.participant_1_id OR u.id = cc.participant_2_id
LEFT JOIN chat_messages cm ON cm.sender_id = u.id
GROUP BY u.id, u.name;

-- ✅ SISTEMA DE CHAT ULTRA SIMPLE COMPLETADO
SELECT 'Sistema de chat ultra simple creado exitosamente' as message;


