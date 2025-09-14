-- ========================== PENDING MIGRATIONS FOR TU RECARGA ==========================
-- Migraciones adicionales para completar la funcionalidad de Tu Recarga
-- Ejecuta este SQL después de aplicar supabase_tables.sql y supabase_policies.sql

-- ==================== PAYMENT CARDS UPDATES ====================
-- Add missing fields for payment cards
ALTER TABLE payment_cards 
ADD COLUMN IF NOT EXISTS last_4 TEXT,
ADD COLUMN IF NOT EXISTS square_card_id TEXT,
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE;

-- Update existing records to use last_4 instead of card_number for security
UPDATE payment_cards SET last_4 = RIGHT(card_number, 4) WHERE last_4 IS NULL;

-- ==================== REFERRAL SYSTEM ENHANCEMENT ====================
-- Add referral tracking table
CREATE TABLE IF NOT EXISTS referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    referred_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    referral_code TEXT NOT NULL,
    reward_amount DECIMAL(10,2) DEFAULT 0.00,
    reward_status TEXT DEFAULT 'pending' CHECK (reward_status IN ('pending', 'paid', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    rewarded_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for referral system
CREATE INDEX IF NOT EXISTS idx_referrals_referrer_id ON referrals(referrer_id);
CREATE INDEX IF NOT EXISTS idx_referrals_referred_id ON referrals(referred_id);
CREATE INDEX IF NOT EXISTS idx_referrals_code ON referrals(referral_code);

-- ==================== IMPROVED STORE SYSTEM ====================
-- Add product ratings and reviews
CREATE TABLE IF NOT EXISTS product_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES store_products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Product wishlist
CREATE TABLE IF NOT EXISTS wishlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES store_products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- Indexes for product system
CREATE INDEX IF NOT EXISTS idx_product_reviews_product_id ON product_reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_user_id ON product_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_wishlists_user_id ON wishlists(user_id);

-- ==================== ENHANCED CART SYSTEM ====================
-- Add weight and shipping data to cart items
ALTER TABLE cart_items 
ADD COLUMN IF NOT EXISTS weight DECIMAL(8,3),
ADD COLUMN IF NOT EXISTS shipping_cost DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN IF NOT EXISTS product_image_url TEXT;

-- ==================== SHIPPING AND DELIVERY ====================
-- Shipping addresses table
CREATE TABLE IF NOT EXISTS shipping_addresses (
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

-- Delivery tracking
CREATE TABLE IF NOT EXISTS delivery_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status TEXT NOT NULL,
    location TEXT,
    notes TEXT,
    estimated_delivery TIMESTAMP WITH TIME ZONE,
    actual_delivery TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for shipping
CREATE INDEX IF NOT EXISTS idx_shipping_addresses_user_id ON shipping_addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_delivery_tracking_order_id ON delivery_tracking(order_id);

-- ==================== RECHARGE SYSTEM ENHANCEMENTS ====================
-- Operators and countries table for better data management
CREATE TABLE IF NOT EXISTS recharge_operators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    country TEXT NOT NULL,
    logo_url TEXT,
    supported_amounts DECIMAL(10,2)[] DEFAULT '{}',
    fees JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recharge packages for special offers
CREATE TABLE IF NOT EXISTS recharge_packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operator_id UUID NOT NULL REFERENCES recharge_operators(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL,
    bonus_data TEXT,
    bonus_minutes TEXT,
    validity_days INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for recharge system
CREATE INDEX IF NOT EXISTS idx_recharge_operators_country ON recharge_operators(country);
CREATE INDEX IF NOT EXISTS idx_recharge_packages_operator_id ON recharge_packages(operator_id);

-- ==================== COMMUNICATION SYSTEM ====================
-- Chat conversations (for support and user communication)
CREATE TABLE IF NOT EXISTS chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    admin_id UUID REFERENCES users(id),
    type TEXT DEFAULT 'support' CHECK (type IN ('support', 'user_chat')),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'closed', 'waiting')),
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat messages
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'system')),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for chat system
CREATE INDEX IF NOT EXISTS idx_chat_conversations_user_id ON chat_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation_id ON chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at DESC);

-- ==================== LOYALTY AND REWARDS ====================
-- User rewards and points system
CREATE TABLE IF NOT EXISTS user_rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    points INTEGER DEFAULT 0,
    level TEXT DEFAULT 'Bronze' CHECK (level IN ('Bronze', 'Silver', 'Gold', 'Platinum')),
    total_spent DECIMAL(12,2) DEFAULT 0.00,
    total_recharges INTEGER DEFAULT 0,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reward history
CREATE TABLE IF NOT EXISTS reward_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- 'earned', 'redeemed', 'expired'
    points INTEGER NOT NULL,
    reason TEXT NOT NULL,
    reference_id UUID, -- Can reference order_id, recharge_id, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for rewards system
CREATE INDEX IF NOT EXISTS idx_user_rewards_user_id ON user_rewards(user_id);
CREATE INDEX IF NOT EXISTS idx_reward_history_user_id ON reward_history(user_id);

-- ==================== APP CONFIG ENHANCEMENTS ====================
-- Insert default app configuration
INSERT INTO app_config (key, value, description) VALUES 
('maintenance_mode', 'false', 'Enable/disable maintenance mode')
ON CONFLICT (key) DO NOTHING;

INSERT INTO app_config (key, value, description) VALUES 
('force_update', '{"active": false, "version": "1.0.0", "message": "Please update the app"}', 'Force app update configuration')
ON CONFLICT (key) DO NOTHING;

INSERT INTO app_config (key, value, description) VALUES 
('banner_urls', '[]', 'Array of banner image URLs for home screen')
ON CONFLICT (key) DO NOTHING;

INSERT INTO app_config (key, value, description) VALUES 
('shipping_rates', '{"express": 5.50, "maritime": 3.25, "base_fee": 10.00}', 'Shipping cost calculation rates')
ON CONFLICT (key) DO NOTHING;

INSERT INTO app_config (key, value, description) VALUES 
('recharge_fees', '{"percentage": 0.05, "minimum": 0.99, "maximum": 5.00}', 'Recharge transaction fees')
ON CONFLICT (key) DO NOTHING;

-- ==================== AUDIT LOG ====================
-- Audit trail for important actions
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action TEXT NOT NULL,
    table_name TEXT,
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for audit logs
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC);

-- ==================== UPDATED_AT TRIGGERS FOR NEW TABLES ====================
CREATE TRIGGER update_referrals_updated_at BEFORE UPDATE ON referrals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_product_reviews_updated_at BEFORE UPDATE ON product_reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_shipping_addresses_updated_at BEFORE UPDATE ON shipping_addresses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_recharge_operators_updated_at BEFORE UPDATE ON recharge_operators FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_recharge_packages_updated_at BEFORE UPDATE ON recharge_packages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_chat_conversations_updated_at BEFORE UPDATE ON chat_conversations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_rewards_updated_at BEFORE UPDATE ON user_rewards FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==================== ROW LEVEL SECURITY FOR NEW TABLES ====================
-- Enable RLS for all new tables
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE shipping_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE recharge_operators ENABLE ROW LEVEL SECURITY;
ALTER TABLE recharge_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- ==================== POLICIES FOR NEW TABLES ====================
-- Referrals policies
CREATE POLICY "Users can view their referrals" ON referrals
    FOR SELECT USING (auth.uid() = referrer_id OR auth.uid() = referred_id);

CREATE POLICY "System can manage referrals" ON referrals
    FOR ALL USING (true) WITH CHECK (true);

-- Product reviews policies
CREATE POLICY "Anyone can view product reviews" ON product_reviews
    FOR SELECT USING (true);

CREATE POLICY "Users can manage their own reviews" ON product_reviews
    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Wishlists policies
CREATE POLICY "Users can manage their own wishlists" ON wishlists
    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Shipping addresses policies
CREATE POLICY "Users can manage their own shipping addresses" ON shipping_addresses
    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Delivery tracking policies
CREATE POLICY "Users can view delivery tracking for their orders" ON delivery_tracking
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders WHERE id = order_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all delivery tracking" ON delivery_tracking
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- Recharge operators policies (public read, admin write)
CREATE POLICY "Anyone can view active recharge operators" ON recharge_operators
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage recharge operators" ON recharge_operators
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- Recharge packages policies (public read, admin write)
CREATE POLICY "Anyone can view active recharge packages" ON recharge_packages
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage recharge packages" ON recharge_packages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- Chat conversations policies
CREATE POLICY "Users can manage their own chat conversations" ON chat_conversations
    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can manage all chat conversations" ON chat_conversations
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- Chat messages policies
CREATE POLICY "Users can manage messages in their conversations" ON chat_messages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM chat_conversations 
            WHERE id = conversation_id AND (user_id = auth.uid() OR admin_id = auth.uid())
        )
    ) WITH CHECK (
        EXISTS (
            SELECT 1 FROM chat_conversations 
            WHERE id = conversation_id AND (user_id = auth.uid() OR admin_id = auth.uid())
        )
    );

-- User rewards policies
CREATE POLICY "Users can view their own rewards" ON user_rewards
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can manage user rewards" ON user_rewards
    FOR ALL USING (true) WITH CHECK (true);

-- Reward history policies
CREATE POLICY "Users can view their own reward history" ON reward_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can insert reward history" ON reward_history
    FOR INSERT WITH CHECK (true);

-- Audit logs policies (admin only)
CREATE POLICY "Admins can view all audit logs" ON audit_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

CREATE POLICY "System can insert audit logs" ON audit_logs
    FOR INSERT WITH CHECK (true);

-- ==================== SUCCESS MESSAGE ====================
-- This will appear in the console when migrations are complete
DO $$
BEGIN
    RAISE NOTICE '✅ PENDING MIGRATIONS COMPLETED SUCCESSFULLY';
    RAISE NOTICE '📊 New tables created:';
    RAISE NOTICE '   - referrals (referral tracking)';
    RAISE NOTICE '   - product_reviews (product ratings)';
    RAISE NOTICE '   - wishlists (user favorites)';
    RAISE NOTICE '   - shipping_addresses (delivery addresses)';
    RAISE NOTICE '   - delivery_tracking (order tracking)';
    RAISE NOTICE '   - recharge_operators (telecom providers)';
    RAISE NOTICE '   - recharge_packages (special offers)';
    RAISE NOTICE '   - chat_conversations (communication)';
    RAISE NOTICE '   - chat_messages (chat history)';
    RAISE NOTICE '   - user_rewards (loyalty system)';
    RAISE NOTICE '   - reward_history (points tracking)';
    RAISE NOTICE '   - audit_logs (system audit trail)';
    RAISE NOTICE '🔒 RLS policies configured for all tables';
    RAISE NOTICE '🎉 TU RECARGA DATABASE IS READY!';
END $$;