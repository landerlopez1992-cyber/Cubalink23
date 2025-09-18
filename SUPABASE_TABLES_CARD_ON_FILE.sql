-- ========================== TABLAS PARA CARD-ON-FILE SEGÚN AMIGO ==========================
-- Plan híbrido: Square guarda tarjetas, Supabase guarda metadata

-- ==================== TABLA: USER_SQUARE ====================
-- Vincula usuarios de Supabase con customers de Square
CREATE TABLE IF NOT EXISTS user_square (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  square_customer_id text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- RLS para user_square
ALTER TABLE user_square ENABLE ROW LEVEL SECURITY;

-- Solo el usuario puede ver/modificar su propio customer_id
CREATE POLICY "Users can view own square customer" ON user_square
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own square customer" ON user_square
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own square customer" ON user_square
  FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- ==================== ACTUALIZAR TABLA: PAYMENT_CARDS ====================
-- Agregar campos necesarios para Card-on-File

-- Agregar square_card_id (el ccof:... real de Square)
ALTER TABLE payment_cards 
ADD COLUMN IF NOT EXISTS square_card_id text;

-- Agregar square_customer_id para referencia
ALTER TABLE payment_cards 
ADD COLUMN IF NOT EXISTS square_customer_id text;

-- Agregar is_default para tarjeta principal
ALTER TABLE payment_cards 
ADD COLUMN IF NOT EXISTS is_default boolean DEFAULT false;

-- Asegurar que zip_code existe (ya debería estar)
ALTER TABLE payment_cards 
ADD COLUMN IF NOT EXISTS zip_code text DEFAULT '12345';

-- ==================== ÍNDICES PARA PERFORMANCE ====================
CREATE INDEX IF NOT EXISTS idx_user_square_customer_id ON user_square(square_customer_id);
CREATE INDEX IF NOT EXISTS idx_payment_cards_square_card_id ON payment_cards(square_card_id);
CREATE INDEX IF NOT EXISTS idx_payment_cards_user_default ON payment_cards(user_id, is_default);

-- ==================== VERIFICAR ESTRUCTURA FINAL ====================
-- Ver estructura de user_square
SELECT 
    column_name, 
    data_type, 
    is_nullable 
FROM information_schema.columns 
WHERE table_name = 'user_square' 
ORDER BY ordinal_position;

-- Ver estructura actualizada de payment_cards
SELECT 
    column_name, 
    data_type, 
    is_nullable 
FROM information_schema.columns 
WHERE table_name = 'payment_cards' 
ORDER BY ordinal_position;

-- ==================== DATOS DE PRUEBA (OPCIONAL) ====================
-- Comentar estas líneas si no quieres datos de prueba

-- Insertar customer de prueba (cambiar UUID por uno real)
-- INSERT INTO user_square (user_id, square_customer_id) 
-- VALUES ('00000000-0000-0000-0000-000000000000', 'CUST_TEST_123') 
-- ON CONFLICT (user_id) DO NOTHING;

-- ==================== NOTAS IMPORTANTES ====================
/*
1. square_card_id debe ser formato ccof:... (viene de Square CreateCard API)
2. square_customer_id debe coincidir entre user_square y payment_cards
3. is_default = true solo para UNA tarjeta por usuario
4. zip_code es obligatorio para Square AVS
5. NUNCA guardar PAN, CVV, o datos sensibles - solo metadata
*/
