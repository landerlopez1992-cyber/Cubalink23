-- ========================== VERIFICAR TARJETAS DEL USUARIO ==========================
-- Script para verificar qué tarjetas existen y cuál es el user_id correcto

-- ==================== PASO 1: VERIFICAR USUARIO ====================
-- Buscar el usuario landerlopez1992@gmail.com
SELECT 
    id,
    email,
    name,
    balance,
    created_at
FROM users 
WHERE email = 'landerlopez1992@gmail.com';

-- ==================== PASO 2: VERIFICAR TARJETAS ====================
-- Ver todas las tarjetas existentes
SELECT 
    pc.id,
    pc.user_id,
    pc.card_number,
    pc.card_type,
    pc.holder_name,
    pc.is_default,
    pc.created_at,
    u.email as user_email,
    u.name as user_name
FROM payment_cards pc
LEFT JOIN users u ON pc.user_id = u.id
ORDER BY pc.created_at DESC;

-- ==================== PASO 3: VERIFICAR TARJETAS ESPECÍFICAS ====================
-- Ver solo las tarjetas del usuario landerlopez1992@gmail.com
SELECT 
    pc.id,
    pc.user_id,
    pc.card_number,
    pc.card_type,
    pc.holder_name,
    pc.is_default,
    pc.created_at,
    u.email as user_email,
    u.name as user_name
FROM payment_cards pc
JOIN users u ON pc.user_id = u.id
WHERE u.email = 'landerlopez1992@gmail.com';

-- ==================== PASO 4: CONTAR TARJETAS ====================
-- Contar cuántas tarjetas tiene cada usuario
SELECT 
    u.email,
    u.name,
    COUNT(pc.id) as total_cards
FROM users u
LEFT JOIN payment_cards pc ON u.id = pc.user_id
GROUP BY u.id, u.email, u.name
ORDER BY total_cards DESC;


