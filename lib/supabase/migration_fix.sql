-- ========================== MIGRATION FIX FOR EXISTING TABLES ==========================
-- This migration file safely handles existing tables and adds missing ones
-- Use this instead of the problematic supabase_tables.sql

-- First, let's check if core tables exist and create missing ones only

-- ==================== MISSING PRODUCT CATEGORIES TABLE ====================
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

-- ==================== ENSURE USER ADDRESSES TABLE EXISTS ====================
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

-- ==================== ADD MISSING COLUMNS TO EXISTING TABLES ====================
-- Add missing columns to users table (safely)
DO $$
BEGIN
    -- Add referral_code if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='referral_code') THEN
        ALTER TABLE users ADD COLUMN referral_code TEXT UNIQUE;
    END IF;
    
    -- Add referred_by if it doesn't exist  
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='referred_by') THEN
        ALTER TABLE users ADD COLUMN referred_by UUID REFERENCES users(id);
    END IF;
    
    -- Add has_used_service if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='has_used_service') THEN
        ALTER TABLE users ADD COLUMN has_used_service BOOLEAN DEFAULT FALSE;
    END IF;
    
    -- Add referred_users if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='referred_users') THEN
        ALTER TABLE users ADD COLUMN referred_users TEXT[] DEFAULT '{}';
    END IF;
    
    -- Add reward_date if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='reward_date') THEN
        ALTER TABLE users ADD COLUMN reward_date TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- ==================== ADD MISSING COLUMNS TO PAYMENT CARDS ====================
DO $$
BEGIN
    -- Add last_4 if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='payment_cards' AND column_name='last_4') THEN
        ALTER TABLE payment_cards ADD COLUMN last_4 TEXT;
    END IF;
    
    -- Add square_card_id if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='payment_cards' AND column_name='square_card_id') THEN
        ALTER TABLE payment_cards ADD COLUMN square_card_id TEXT;
    END IF;
    
    -- Add is_verified if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='payment_cards' AND column_name='is_verified') THEN
        ALTER TABLE payment_cards ADD COLUMN is_verified BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- ==================== ADD MISSING COLUMNS TO CART ITEMS ====================
DO $$
BEGIN
    -- Add weight if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='cart_items' AND column_name='weight') THEN
        ALTER TABLE cart_items ADD COLUMN weight DECIMAL(8,3);
    END IF;
    
    -- Add shipping_cost if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='cart_items' AND column_name='shipping_cost') THEN
        ALTER TABLE cart_items ADD COLUMN shipping_cost DECIMAL(10,2) DEFAULT 0.00;
    END IF;
    
    -- Add product_image_url if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='cart_items' AND column_name='product_image_url') THEN
        ALTER TABLE cart_items ADD COLUMN product_image_url TEXT;
    END IF;
END $$;

-- ==================== ENSURE TRIGGERS EXIST ====================
-- Create update function if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Safely create triggers for product_categories
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.triggers 
                   WHERE event_object_table = 'product_categories' 
                   AND trigger_name = 'update_product_categories_updated_at') THEN
        CREATE TRIGGER update_product_categories_updated_at 
        BEFORE UPDATE ON product_categories 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- Safely create triggers for user_addresses
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.triggers 
                   WHERE event_object_table = 'user_addresses' 
                   AND trigger_name = 'update_user_addresses_updated_at') THEN
        CREATE TRIGGER update_user_addresses_updated_at 
        BEFORE UPDATE ON user_addresses 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- ==================== ENABLE ROW LEVEL SECURITY ====================
-- Enable RLS for new tables (safely)
DO $$
BEGIN
    -- Enable RLS for product_categories
    ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
    
    -- Enable RLS for user_addresses
    ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;
EXCEPTION
    WHEN OTHERS THEN
        -- Ignore errors if RLS is already enabled
        NULL;
END $$;

-- ==================== CREATE MISSING POLICIES ====================
-- Policies for product_categories (public read, admin write)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'product_categories' AND policyname = 'Anyone can view active product categories') THEN
        CREATE POLICY "Anyone can view active product categories" ON product_categories
            FOR SELECT USING (is_active = true);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'product_categories' AND policyname = 'Admins can manage product categories') THEN
        CREATE POLICY "Admins can manage product categories" ON product_categories
            FOR ALL USING (
                EXISTS (
                    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
                )
            ) WITH CHECK (
                EXISTS (
                    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'Admin'
                )
            );
    END IF;
END $$;

-- Policies for user_addresses
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_addresses' AND policyname = 'Users can manage their own addresses') THEN
        CREATE POLICY "Users can manage their own addresses" ON user_addresses
            FOR ALL USING (auth.uid() = user_id) 
            WITH CHECK (auth.uid() = user_id);
    END IF;
END $$;

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

-- ==================== CREATE MISSING INDEXES ====================
-- Indexes for new tables
CREATE INDEX IF NOT EXISTS idx_product_categories_active ON product_categories(is_active);
CREATE INDEX IF NOT EXISTS idx_product_categories_sort_order ON product_categories(sort_order);
CREATE INDEX IF NOT EXISTS idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_user_addresses_is_default ON user_addresses(is_default);

-- ==================== SUCCESS MESSAGE ====================
DO $$
BEGIN
    RAISE NOTICE '✅ MIGRATION FIX COMPLETED SUCCESSFULLY';
    RAISE NOTICE '🔧 Fixed Issues:';
    RAISE NOTICE '   - Used CREATE TABLE IF NOT EXISTS to avoid conflicts';
    RAISE NOTICE '   - Added missing product_categories table';  
    RAISE NOTICE '   - Added missing user_addresses table';
    RAISE NOTICE '   - Added missing columns to existing tables';
    RAISE NOTICE '   - Created necessary triggers and policies';
    RAISE NOTICE '   - Inserted default product categories';
    RAISE NOTICE '🎉 MIGRATION IS NOW SAFE TO APPLY!';
END $$;