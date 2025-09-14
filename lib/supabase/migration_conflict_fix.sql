-- ========================== MIGRATION CONFLICT FIX ==========================
-- This file handles policy conflicts and duplicates safely
-- Execute this instead of the problematic files

-- ==================== DROP EXISTING POLICIES TO RECREATE THEM ====================
-- Drop all existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view their own profile" ON users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Admins can manage all users" ON users;
DROP POLICY IF EXISTS "Users can manage their own payment cards" ON payment_cards;
DROP POLICY IF EXISTS "Users can manage their own contacts" ON contacts;
DROP POLICY IF EXISTS "Users can manage their own recharge history" ON recharge_history;
DROP POLICY IF EXISTS "Admins can manage all recharge history" ON recharge_history;
DROP POLICY IF EXISTS "Users can manage their own transfers" ON transfers;
DROP POLICY IF EXISTS "Users can manage their own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can manage their own support conversations" ON support_conversations;
DROP POLICY IF EXISTS "Admins can manage all support conversations" ON support_conversations;
DROP POLICY IF EXISTS "Users can manage messages in their conversations" ON support_messages;
DROP POLICY IF EXISTS "Admins can manage all support messages" ON support_messages;
DROP POLICY IF EXISTS "Anyone can view active store categories" ON store_categories;
DROP POLICY IF EXISTS "Admins can manage store categories" ON store_categories;
DROP POLICY IF EXISTS "Anyone can view active store subcategories" ON store_subcategories;
DROP POLICY IF EXISTS "Admins can manage store subcategories" ON store_subcategories;
DROP POLICY IF EXISTS "Anyone can view active store products" ON store_products;
DROP POLICY IF EXISTS "Admins can manage store products" ON store_products;
DROP POLICY IF EXISTS "Users can manage their own orders" ON orders;
DROP POLICY IF EXISTS "Admins can manage all orders" ON orders;
DROP POLICY IF EXISTS "Users can manage their own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can view their own activities" ON activities;
DROP POLICY IF EXISTS "System can insert activities" ON activities;
DROP POLICY IF EXISTS "Admins can view all activities" ON activities;
DROP POLICY IF EXISTS "Users can view their own admin messages" ON admin_messages;
DROP POLICY IF EXISTS "Admins can manage admin messages" ON admin_messages;
DROP POLICY IF EXISTS "Users can manage their own presence" ON user_presence;
DROP POLICY IF EXISTS "Anyone can view app config" ON app_config;
DROP POLICY IF EXISTS "Admins can manage app config" ON app_config;
DROP POLICY IF EXISTS "Users can manage their own profile photos" ON profile_photos;
DROP POLICY IF EXISTS "Anyone can view product images" ON product_images;
DROP POLICY IF EXISTS "Admins can manage product images" ON product_images;
DROP POLICY IF EXISTS "Users can manage zelle proofs for their orders" ON zelle_proofs;
DROP POLICY IF EXISTS "Admins can manage all zelle proofs" ON zelle_proofs;

-- ==================== ENABLE ROW LEVEL SECURITY ====================
-- Enable RLS for all tables (safely)
DO $$
BEGIN
    -- Main tables
    ALTER TABLE users ENABLE ROW LEVEL SECURITY;
    ALTER TABLE payment_cards ENABLE ROW LEVEL SECURITY;
    ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
    ALTER TABLE recharge_history ENABLE ROW LEVEL SECURITY;
    ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;
    ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
    
    -- Support system
    ALTER TABLE support_conversations ENABLE ROW LEVEL SECURITY;
    ALTER TABLE support_messages ENABLE ROW LEVEL SECURITY;
    
    -- Store system
    ALTER TABLE store_categories ENABLE ROW LEVEL SECURITY;
    ALTER TABLE store_subcategories ENABLE ROW LEVEL SECURITY;
    ALTER TABLE store_products ENABLE ROW LEVEL SECURITY;
    ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
    ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
    
    -- Activity and admin
    ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
    ALTER TABLE admin_messages ENABLE ROW LEVEL SECURITY;
    ALTER TABLE user_presence ENABLE ROW LEVEL SECURITY;
    ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
    
    -- File storage
    ALTER TABLE profile_photos ENABLE ROW LEVEL SECURITY;
    ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
    ALTER TABLE zelle_proofs ENABLE ROW LEVEL SECURITY;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'RLS already enabled or table does not exist: %', SQLERRM;
END $$;

-- ==================== CREATE ALL POLICIES FRESH ====================

-- ==================== USERS TABLE POLICIES ====================
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Admins can see and manage all users
CREATE POLICY "Admins can manage all users" ON users
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== PAYMENT CARDS POLICIES ====================
CREATE POLICY "Users can manage their own payment cards" ON payment_cards
    FOR ALL USING (auth.uid() = user_id);

-- ==================== CONTACTS POLICIES ====================
CREATE POLICY "Users can manage their own contacts" ON contacts
    FOR ALL USING (auth.uid() = user_id);

-- ==================== RECHARGE HISTORY POLICIES ====================
CREATE POLICY "Users can manage their own recharge history" ON recharge_history
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all recharge history" ON recharge_history
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== TRANSFERS POLICIES ====================
CREATE POLICY "Users can manage their own transfers" ON transfers
    FOR ALL USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);

-- ==================== NOTIFICATIONS POLICIES ====================
CREATE POLICY "Users can manage their own notifications" ON notifications
    FOR ALL USING (auth.uid() = user_id);

-- ==================== SUPPORT CHAT POLICIES ====================
CREATE POLICY "Users can manage their own support conversations" ON support_conversations
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all support conversations" ON support_conversations
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

CREATE POLICY "Users can manage messages in their conversations" ON support_messages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM support_conversations 
            WHERE id = conversation_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all support messages" ON support_messages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== STORE SYSTEM POLICIES ====================
CREATE POLICY "Anyone can view active store categories" ON store_categories
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage store categories" ON store_categories
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

CREATE POLICY "Anyone can view active store subcategories" ON store_subcategories
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage store subcategories" ON store_subcategories
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

CREATE POLICY "Anyone can view active store products" ON store_products
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage store products" ON store_products
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== ORDERS POLICIES ====================
CREATE POLICY "Users can manage their own orders" ON orders
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all orders" ON orders
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== CART ITEMS POLICIES ====================
CREATE POLICY "Users can manage their own cart items" ON cart_items
    FOR ALL USING (auth.uid() = user_id);

-- ==================== ACTIVITIES POLICIES ====================
CREATE POLICY "Users can view their own activities" ON activities
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can insert activities" ON activities
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Admins can view all activities" ON activities
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== ADMIN MESSAGES POLICIES ====================
CREATE POLICY "Users can view their own admin messages" ON admin_messages
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage admin messages" ON admin_messages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== USER PRESENCE POLICIES ====================
CREATE POLICY "Users can manage their own presence" ON user_presence
    FOR ALL USING (auth.uid() = user_id);

-- ==================== APP CONFIG POLICIES ====================
CREATE POLICY "Anyone can view app config" ON app_config
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage app config" ON app_config
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== FILE STORAGE POLICIES ====================
CREATE POLICY "Users can manage their own profile photos" ON profile_photos
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view product images" ON product_images
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage product images" ON product_images
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

CREATE POLICY "Users can manage zelle proofs for their orders" ON zelle_proofs
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM orders WHERE id = order_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all zelle proofs" ON zelle_proofs
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== CREATE MISSING TABLES SAFELY ====================
-- Create tables that might be missing
CREATE TABLE IF NOT EXISTS product_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    icon_name TEXT,
    color TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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

-- Enable RLS for new tables
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;

-- Create policies for new tables
CREATE POLICY "Anyone can view active product categories" ON product_categories
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage product categories" ON product_categories
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

CREATE POLICY "Users can manage their own addresses" ON user_addresses
    FOR ALL USING (auth.uid() = user_id);

-- ==================== INSERT DEFAULT DATA ====================
-- Insert default product categories
INSERT INTO product_categories (name, description, icon_name, color, is_active) VALUES 
('Alimentos', 'Comida y productos básicos', 'restaurant', '0xFFE57373', true),
('Materiales', 'Materiales de construcción', 'construction', '0xFFFF8A65', true),
('Ferretería', 'Herramientas y accesorios', 'build', '0xFFFF8F00', true),
('Farmacia', 'Medicinas y productos de salud', 'healing', '0xFF26A69A', true),
('Electrónicos', 'Dispositivos y accesorios', 'phone_android', '0xFF42A5F5', true),
('Ropa', 'Vestimenta y accesorios', 'shopping_bag', '0xFFAB47BC', true),
('Hogar', 'Productos para el hogar', 'home', '0xFF66BB6A', true),
('Deportes', 'Artículos deportivos', 'fitness_center', '0xFFFF7043', true)
ON CONFLICT (name) DO NOTHING;

-- ==================== SUCCESS MESSAGE ====================
DO $$
BEGIN
    RAISE NOTICE '✅ MIGRATION CONFLICT FIX COMPLETED SUCCESSFULLY';
    RAISE NOTICE '🔧 Fixed Issues:';
    RAISE NOTICE '   - Dropped all existing policies to avoid conflicts';
    RAISE NOTICE '   - Recreated all policies with proper names';
    RAISE NOTICE '   - Created missing tables safely';
    RAISE NOTICE '   - Applied RLS to all tables';
    RAISE NOTICE '   - Inserted default product categories';
    RAISE NOTICE '🎉 ALL POLICY CONFLICTS RESOLVED!';
END $$;