-- ========================== VERIFICAR SALDO DE LANDER ==========================
-- Script para verificar el saldo actual del usuario Lander

-- ==================== PASO 1: VERIFICAR USUARIO LANDER ====================
SELECT 
    id,
    email,
    name,
    balance,
    created_at,
    updated_at
FROM users 
WHERE email = 'landerlopez1992@gmail.com';

-- ==================== PASO 2: VERIFICAR HISTORIAL DE RECARGAS ====================
-- Ver todas las recargas de Lander (si existe la tabla)
SELECT 
    rh.id,
    rh.user_id,
    rh.amount,
    rh.fee,
    rh.total,
    rh.payment_method,
    rh.transaction_id,
    rh.status,
    rh.created_at,
    u.email as user_email
FROM recharge_history rh
JOIN users u ON rh.user_id = u.id
WHERE u.email = 'landerlopez1992@gmail.com'
ORDER BY rh.created_at DESC;

-- ==================== PASO 3: VERIFICAR ACTIVIDADES ====================
-- Ver el historial de actividades de Lander
SELECT 
    a.id,
    a.user_id,
    a.activity_type,
    a.description,
    a.amount,
    a.created_at,
    u.email as user_email
FROM activities a
JOIN users u ON a.user_id = u.id
WHERE u.email = 'landerlopez1992@gmail.com'
ORDER BY a.created_at DESC
LIMIT 10;

-- ==================== PASO 4: ACTUALIZAR SALDO MANUALMENTE (SI ES NECESARIO) ====================
-- Descomentar la siguiente línea si necesitas agregar saldo manualmente
-- UPDATE users SET balance = balance + 50.0 WHERE email = 'landerlopez1992@gmail.com';


