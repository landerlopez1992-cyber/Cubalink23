-- ========================== ACTUALIZAR SALDO DE LANDER ==========================
-- Script para verificar y actualizar el saldo del usuario Lander

-- ==================== PASO 1: VERIFICAR SALDO ACTUAL ====================
SELECT 
    id,
    email,
    name,
    balance,
    created_at,
    updated_at
FROM users 
WHERE email = 'landerlopez1992@gmail.com';

-- ==================== PASO 2: ACTUALIZAR SALDO A $50 ====================
UPDATE users 
SET balance = 50.0, updated_at = NOW()
WHERE email = 'landerlopez1992@gmail.com';

-- ==================== PASO 3: VERIFICAR SALDO ACTUALIZADO ====================
SELECT 
    id,
    email,
    name,
    balance,
    created_at,
    updated_at
FROM users 
WHERE email = 'landerlopez1992@gmail.com';


