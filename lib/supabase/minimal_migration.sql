-- ========================== MINIMAL MIGRATION FOR TU RECARGA ==========================
-- This is a minimal, conflict-free migration that creates only essential structure
-- Use this if all other migrations fail

-- ==================== CREATE ESSENTIAL TABLES ====================
-- Only create tables that don't exist yet
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
    user_id UUID NOT NULL,
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

-- Add foreign key constraint if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'user_addresses_user_id_fkey'
    ) THEN
        ALTER TABLE user_addresses 
        ADD CONSTRAINT user_addresses_user_id_fkey 
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
    END IF;
END $$;

-- ==================== ADD MISSING COLUMNS TO EXISTING TABLES ====================
-- Add columns safely without conflicts
DO $$
BEGIN
    -- Add columns to payment_cards if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='payment_cards' AND column_name='last_4') THEN
        ALTER TABLE payment_cards ADD COLUMN last_4 TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='payment_cards' AND column_name='square_card_id') THEN
        ALTER TABLE payment_cards ADD COLUMN square_card_id TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='payment_cards' AND column_name='is_verified') THEN
        ALTER TABLE payment_cards ADD COLUMN is_verified BOOLEAN DEFAULT FALSE;
    END IF;
    
    -- Add columns to cart_items if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='cart_items' AND column_name='weight') THEN
        ALTER TABLE cart_items ADD COLUMN weight DECIMAL(8,3);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='cart_items' AND column_name='shipping_cost') THEN
        ALTER TABLE cart_items ADD COLUMN shipping_cost DECIMAL(10,2) DEFAULT 0.00;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='cart_items' AND column_name='product_image_url') THEN
        ALTER TABLE cart_items ADD COLUMN product_image_url TEXT;
    END IF;
    
    -- Add referral columns to users if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='referral_code') THEN
        ALTER TABLE users ADD COLUMN referral_code TEXT UNIQUE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='referred_by') THEN
        ALTER TABLE users ADD COLUMN referred_by UUID;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='has_used_service') THEN
        ALTER TABLE users ADD COLUMN has_used_service BOOLEAN DEFAULT FALSE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='referred_users') THEN
        ALTER TABLE users ADD COLUMN referred_users TEXT[] DEFAULT '{}';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='reward_date') THEN
        ALTER TABLE users ADD COLUMN reward_date TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- ==================== CREATE ESSENTIAL INDEXES ====================
-- Create indexes only if they don't exist
CREATE INDEX IF NOT EXISTS idx_product_categories_active ON product_categories(is_active);
CREATE INDEX IF NOT EXISTS idx_product_categories_sort_order ON product_categories(sort_order);
CREATE INDEX IF NOT EXISTS idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_user_addresses_is_default ON user_addresses(is_default);

-- ==================== INSERT DEFAULT DATA ====================
-- Insert default product categories (safely)
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

-- ==================== ENABLE RLS FOR NEW TABLES (SAFELY) ====================
-- Enable RLS only for tables we just created
DO $$
BEGIN
    ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
    ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;
EXCEPTION
    WHEN OTHERS THEN
        -- Ignore errors if RLS is already enabled
        NULL;
END $$;

-- ==================== CREATE MINIMAL POLICIES (SAFELY) ====================
-- Create basic policies only for new tables, avoid existing policies
DO $$
BEGIN
    -- Only create policy if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'product_categories' 
        AND policyname = 'Public can view active categories'
    ) THEN
        CREATE POLICY "Public can view active categories" ON product_categories
            FOR SELECT USING (is_active = true);
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'user_addresses' 
        AND policyname = 'Users own addresses'
    ) THEN
        CREATE POLICY "Users own addresses" ON user_addresses
            FOR ALL USING (auth.uid() = user_id);
    END IF;
END $$;

-- ==================== SUCCESS MESSAGE ====================
DO $$
BEGIN
    RAISE NOTICE '✅ MINIMAL MIGRATION COMPLETED SUCCESSFULLY';
    RAISE NOTICE '🔧 Changes Applied:';
    RAISE NOTICE '   - Created product_categories table if missing';
    RAISE NOTICE '   - Created user_addresses table if missing';
    RAISE NOTICE '   - Added missing columns to existing tables';
    RAISE NOTICE '   - Created essential indexes';
    RAISE NOTICE '   - Inserted default product categories';
    RAISE NOTICE '   - Applied minimal RLS policies';
    RAISE NOTICE '🎉 MIGRATION SAFE TO APPLY WITHOUT CONFLICTS!';
END $$;