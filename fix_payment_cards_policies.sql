-- ========================== ARREGLAR POLÍTICAS DE PAYMENT_CARDS ==========================
-- Script para asegurar que los usuarios puedan insertar y leer sus propias tarjetas

-- ==================== VERIFICAR RLS ESTÁ HABILITADO ====================
ALTER TABLE payment_cards ENABLE ROW LEVEL SECURITY;

-- ==================== ELIMINAR POLÍTICAS EXISTENTES ====================
DROP POLICY IF EXISTS "Users can manage their own payment cards" ON payment_cards;
DROP POLICY IF EXISTS "Users can view their own payment cards" ON payment_cards;
DROP POLICY IF EXISTS "Users can insert their own payment cards" ON payment_cards;
DROP POLICY IF EXISTS "Users can update their own payment cards" ON payment_cards;
DROP POLICY IF EXISTS "Users can delete their own payment cards" ON payment_cards;

-- ==================== CREAR NUEVAS POLÍTICAS ====================

-- Política para SELECT (leer tarjetas)
CREATE POLICY "Users can view their own payment cards" ON payment_cards
    FOR SELECT USING (auth.uid() = user_id);

-- Política para INSERT (crear tarjetas)
CREATE POLICY "Users can insert their own payment cards" ON payment_cards
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para UPDATE (actualizar tarjetas)
CREATE POLICY "Users can update their own payment cards" ON payment_cards
    FOR UPDATE USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);

-- Política para DELETE (eliminar tarjetas)
CREATE POLICY "Users can delete their own payment cards" ON payment_cards
    FOR DELETE USING (auth.uid() = user_id);

-- ==================== VERIFICAR QUE LAS POLÍTICAS ESTÁN ACTIVAS ====================
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'payment_cards';

-- ==================== MENSAJE DE ÉXITO ====================
DO $$
BEGIN
    RAISE NOTICE '✅ POLÍTICAS DE PAYMENT_CARDS ARREGLADAS';
    RAISE NOTICE '🔧 Políticas creadas:';
    RAISE NOTICE '   - SELECT: Usuarios pueden ver sus propias tarjetas';
    RAISE NOTICE '   - INSERT: Usuarios pueden agregar sus propias tarjetas';
    RAISE NOTICE '   - UPDATE: Usuarios pueden actualizar sus propias tarjetas';
    RAISE NOTICE '   - DELETE: Usuarios pueden eliminar sus propias tarjetas';
    RAISE NOTICE '🔒 RLS habilitado correctamente';
    RAISE NOTICE '🎉 AHORA DEBERÍAS PODER GUARDAR TARJETAS!';
END $$;


