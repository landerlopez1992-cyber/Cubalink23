-- ========================== SUPABASE ROW LEVEL SECURITY POLICIES ==========================
-- Complete RLS policies for Tu Recarga app migrating from Firebase

-- ==================== ENABLE ROW LEVEL SECURITY ====================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE recharge_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_subcategories ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE profile_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE zelle_proofs ENABLE ROW LEVEL SECURITY;

-- ==================== USERS TABLE POLICIES ====================
-- Special policy for users table with WITH CHECK (true) for signup compatibility
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (true); -- Allow signup

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id)
    WITH CHECK (true); -- Allow user updates

-- Admins can see and manage all users
CREATE POLICY "Admins can manage all users" ON users
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== PAYMENT CARDS POLICIES ====================
CREATE POLICY "Users can manage their own payment cards" ON payment_cards
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ==================== CONTACTS POLICIES ====================
CREATE POLICY "Users can manage their own contacts" ON contacts
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ==================== RECHARGE HISTORY POLICIES ====================
CREATE POLICY "Users can manage their own recharge history" ON recharge_history
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Admins can see all recharge history
CREATE POLICY "Admins can manage all recharge history" ON recharge_history
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== TRANSFERS POLICIES ====================
CREATE POLICY "Users can manage their own transfers" ON transfers
    FOR ALL USING (auth.uid() = from_user_id OR auth.uid() = to_user_id)
    WITH CHECK (auth.uid() = from_user_id OR auth.uid() = to_user_id);

-- ==================== NOTIFICATIONS POLICIES ====================
CREATE POLICY "Users can manage their own notifications" ON notifications
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ==================== SUPPORT CHAT POLICIES ====================
CREATE POLICY "Users can manage their own support conversations" ON support_conversations
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Admins can see all support conversations
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
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM support_conversations 
            WHERE id = conversation_id AND user_id = auth.uid()
        )
    );

-- Admins can manage all support messages
CREATE POLICY "Admins can manage all support messages" ON support_messages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== STORE SYSTEM POLICIES ====================
-- Categories are public for browsing but only admins can manage
CREATE POLICY "Anyone can view active store categories" ON store_categories
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage store categories" ON store_categories
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    )
    WITH CHECK (
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
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Admins can manage all orders
CREATE POLICY "Admins can manage all orders" ON orders
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== CART ITEMS POLICIES ====================
CREATE POLICY "Users can manage their own cart items" ON cart_items
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ==================== ACTIVITIES POLICIES ====================
CREATE POLICY "Users can view their own activities" ON activities
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can insert activities" ON activities
    FOR INSERT WITH CHECK (true); -- Allow system to log activities

-- Admins can view all activities
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
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- ==================== USER PRESENCE POLICIES ====================
CREATE POLICY "Users can manage their own presence" ON user_presence
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

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
    FOR ALL USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Anyone can view product images" ON product_images
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage product images" ON product_images
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );

-- Users who own orders can manage their zelle proofs
CREATE POLICY "Users can manage zelle proofs for their orders" ON zelle_proofs
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM orders WHERE id = order_id AND user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM orders WHERE id = order_id AND user_id = auth.uid()
        )
    );

-- Admins can manage all zelle proofs
CREATE POLICY "Admins can manage all zelle proofs" ON zelle_proofs
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
        )
    );