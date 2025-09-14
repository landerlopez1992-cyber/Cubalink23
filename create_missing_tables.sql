-- ========================== CREAR TABLAS FALTANTES EN SUPABASE ==========================
-- Script para crear las tablas necesarias para almacenar tarjetas, direcciones y saldos

-- ==================== VERIFICAR Y CREAR PAYMENT_CARDS ====================
CREATE TABLE IF NOT EXISTS payment_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    card_number TEXT NOT NULL, -- Últimos 4 dígitos
    card_type TEXT NOT NULL, -- Visa, Mastercard, etc.
    expiry_month TEXT NOT NULL,
    expiry_year TEXT NOT NULL,
    holder_name TEXT NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== VERIFICAR Y CREAR USER_ADDRESSES ====================
CREATE TABLE IF NOT EXISTS user_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    address_line_1 TEXT NOT NULL,
    address_line_2 TEXT,
    city TEXT NOT NULL,
    province TEXT NOT NULL,
    postal_code TEXT,
    country TEXT DEFAULT 'Cuba',
    phone TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== VERIFICAR Y CREAR TRANSFERS ====================
CREATE TABLE IF NOT EXISTS transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    to_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('send', 'request')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== VERIFICAR Y CREAR ACTIVITIES ====================
CREATE TABLE IF NOT EXISTS activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    amount DECIMAL(10,2),
    status TEXT DEFAULT 'completed',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== VERIFICAR Y CREAR NOTIFICATIONS ====================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'general',
    is_read BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== HABILITAR ROW LEVEL SECURITY ====================
ALTER TABLE payment_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ==================== CREAR POLÍTICAS DE SEGURIDAD ====================
-- Políticas para payment_cards
CREATE POLICY IF NOT EXISTS "Users can manage their own payment cards" ON payment_cards
    FOR ALL USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);

-- Políticas para user_addresses
CREATE POLICY IF NOT EXISTS "Users can manage their own addresses" ON user_addresses
    FOR ALL USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);

-- Políticas para transfers
CREATE POLICY IF NOT EXISTS "Users can view their transfers" ON transfers
    FOR SELECT USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);

CREATE POLICY IF NOT EXISTS "Users can create transfers" ON transfers
    FOR INSERT WITH CHECK (auth.uid() = from_user_id);

CREATE POLICY IF NOT EXISTS "Users can update their transfers" ON transfers
    FOR UPDATE USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);

-- Políticas para activities
CREATE POLICY IF NOT EXISTS "Users can view their activities" ON activities
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can create activities" ON activities
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para notifications
CREATE POLICY IF NOT EXISTS "Users can view their notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can update their notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- ==================== CREAR ÍNDICES ====================
CREATE INDEX IF NOT EXISTS idx_payment_cards_user_id ON payment_cards(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_cards_is_default ON payment_cards(is_default);

CREATE INDEX IF NOT EXISTS idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_user_addresses_is_default ON user_addresses(is_default);

CREATE INDEX IF NOT EXISTS idx_transfers_from_user_id ON transfers(from_user_id);
CREATE INDEX IF NOT EXISTS idx_transfers_to_user_id ON transfers(to_user_id);
CREATE INDEX IF NOT EXISTS idx_transfers_status ON transfers(status);

CREATE INDEX IF NOT EXISTS idx_activities_user_id ON activities(user_id);
CREATE INDEX IF NOT EXISTS idx_activities_type ON activities(type);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- ==================== MENSAJE DE ÉXITO ====================
DO $$
BEGIN
    RAISE NOTICE '✅ TABLAS CREADAS EXITOSAMENTE';
    RAISE NOTICE '🔧 Tablas verificadas/creadas:';
    RAISE NOTICE '   - payment_cards (tarjetas de pago)';
    RAISE NOTICE '   - user_addresses (direcciones de usuarios)';
    RAISE NOTICE '   - transfers (transferencias entre usuarios)';
    RAISE NOTICE '   - activities (historial de actividades)';
    RAISE NOTICE '   - notifications (notificaciones del sistema)';
    RAISE NOTICE '🔒 RLS habilitado y políticas creadas';
    RAISE NOTICE '📊 Índices creados para optimizar consultas';
    RAISE NOTICE '🎉 SISTEMA LISTO PARA ALMACENAR DATOS DE USUARIOS!';
END $$;


