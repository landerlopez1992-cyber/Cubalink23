-- ========================== AGREGAR ZIP CODE A PAYMENT_CARDS ==========================
-- URGENTE: Para producción Square requiere ZIP code real

-- ==================== AGREGAR COLUMNA ZIP_CODE ====================
ALTER TABLE payment_cards 
ADD COLUMN IF NOT EXISTS zip_code TEXT;

-- ==================== ACTUALIZAR TARJETAS EXISTENTES ====================
-- Poner ZIP code por defecto para tarjetas existentes
UPDATE payment_cards 
SET zip_code = '12345' 
WHERE zip_code IS NULL;

-- ==================== VERIFICAR CAMBIOS ====================
-- Ver la estructura actualizada
SELECT 
    column_name, 
    data_type, 
    is_nullable 
FROM information_schema.columns 
WHERE table_name = 'payment_cards' 
ORDER BY ordinal_position;

-- ==================== VER TARJETAS CON ZIP CODE ====================
-- Verificar que todas las tarjetas tengan ZIP code
SELECT 
    id,
    user_id,
    card_type,
    holder_name,
    zip_code,
    created_at
FROM payment_cards 
ORDER BY created_at DESC;
