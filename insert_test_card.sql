-- ========================== INSERTAR TARJETA DE PRUEBA ==========================
-- Script para insertar una tarjeta de prueba directamente en Supabase

-- ==================== PASO 1: ENCONTRAR EL USER_ID ====================
-- Buscar el user_id de landerlopez1992@gmail.com
SELECT 
    id,
    email,
    name,
    balance
FROM users 
WHERE email = 'landerlopez1992@gmail.com';

-- ==================== PASO 2: INSERTAR TARJETA DE PRUEBA ====================
-- NOTA: Reemplaza 'TU_USER_ID_AQUI' con el ID que obtengas del SELECT anterior
INSERT INTO payment_cards (
    user_id,
    card_number,
    card_type,
    expiry_month,
    expiry_year,
    holder_name,
    is_default,
    created_at,
    updated_at
) VALUES (
    (SELECT id FROM users WHERE email = 'landerlopez1992@gmail.com'),
    '1111', -- Últimos 4 dígitos de 4111 1111 1111 1111
    'Visa',
    '12',
    '2025',
    'Test User',
    true, -- Marcar como tarjeta por defecto
    NOW(),
    NOW()
);

-- ==================== PASO 3: VERIFICAR QUE SE INSERTÓ ====================
-- Verificar que la tarjeta se insertó correctamente
SELECT 
    pc.id,
    pc.card_number,
    pc.card_type,
    pc.expiry_month,
    pc.expiry_year,
    pc.holder_name,
    pc.is_default,
    u.email,
    u.name
FROM payment_cards pc
JOIN users u ON pc.user_id = u.id
WHERE u.email = 'landerlopez1992@gmail.com';

-- ==================== MENSAJE DE ÉXITO ====================
DO $$
BEGIN
    RAISE NOTICE '✅ TARJETA DE PRUEBA INSERTADA';
    RAISE NOTICE '🔧 Datos insertados:';
    RAISE NOTICE '   - Usuario: landerlopez1992@gmail.com';
    RAISE NOTICE '   - Tarjeta: Visa •••• 1111';
    RAISE NOTICE '   - Vencimiento: 12/2025';
    RAISE NOTICE '   - Titular: Test User';
    RAISE NOTICE '   - Por defecto: Sí';
    RAISE NOTICE '🎉 AHORA DEBERÍAS VER LA TARJETA EN LA APP!';
END $$;


