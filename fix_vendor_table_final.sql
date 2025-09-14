-- =====================================================
-- FIX FINAL: Corregir todas las tablas de vendedores
-- =====================================================
-- Error: column "icon" of relation "product_categories" does not exist
-- Solución: Agregar columnas faltantes a tablas existentes

-- PASO 1: Agregar columnas faltantes a vendor_profiles
DO $$
BEGIN
    -- Verificar y agregar columnas a vendor_profiles
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'verification_status') THEN
        ALTER TABLE vendor_profiles ADD COLUMN verification_status VARCHAR(30) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected', 'suspended'));
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'business_name') THEN
        ALTER TABLE vendor_profiles ADD COLUMN business_name VARCHAR(200) NOT NULL DEFAULT 'Negocio Sin Nombre';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'business_type') THEN
        ALTER TABLE vendor_profiles ADD COLUMN business_type VARCHAR(50) NOT NULL DEFAULT 'store';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'business_description') THEN
        ALTER TABLE vendor_profiles ADD COLUMN business_description TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'business_address') THEN
        ALTER TABLE vendor_profiles ADD COLUMN business_address JSONB NOT NULL DEFAULT '{}';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'business_phone') THEN
        ALTER TABLE vendor_profiles ADD COLUMN business_phone VARCHAR(20);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'commission_rate') THEN
        ALTER TABLE vendor_profiles ADD COLUMN commission_rate DECIMAL(5,2) DEFAULT 10.00;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'total_orders') THEN
        ALTER TABLE vendor_profiles ADD COLUMN total_orders INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'total_sales') THEN
        ALTER TABLE vendor_profiles ADD COLUMN total_sales DECIMAL(12,2) DEFAULT 0.00;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'average_rating') THEN
        ALTER TABLE vendor_profiles ADD COLUMN average_rating DECIMAL(3,2) DEFAULT 0.00;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'total_reviews') THEN
        ALTER TABLE vendor_profiles ADD COLUMN total_reviews INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'verified_at') THEN
        ALTER TABLE vendor_profiles ADD COLUMN verified_at TIMESTAMP;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_profiles' AND column_name = 'verified_by') THEN
        ALTER TABLE vendor_profiles ADD COLUMN verified_by UUID REFERENCES users(id);
    END IF;
END $$;

-- PASO 2: Agregar columnas faltantes a product_categories (SI YA EXISTE)
DO $$
BEGIN
    -- Agregar columnas faltantes a product_categories existente
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_categories' AND column_name = 'icon') THEN
        ALTER TABLE product_categories ADD COLUMN icon VARCHAR(50);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_categories' AND column_name = 'color') THEN
        ALTER TABLE product_categories ADD COLUMN color VARCHAR(7);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_categories' AND column_name = 'sort_order') THEN
        ALTER TABLE product_categories ADD COLUMN sort_order INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_categories' AND column_name = 'is_active') THEN
        ALTER TABLE product_categories ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'product_categories' AND column_name = 'parent_category_id') THEN
        ALTER TABLE product_categories ADD COLUMN parent_category_id UUID REFERENCES product_categories(id);
    END IF;
END $$;

-- PASO 3: Actualizar las categorías existentes con los nuevos campos
UPDATE product_categories SET 
    icon = CASE name
        WHEN 'Comida Rápida' THEN 'fastfood'
        WHEN 'Restaurantes' THEN 'restaurant'
        WHEN 'Supermercado' THEN 'shopping_cart'
        WHEN 'Farmacia' THEN 'local_pharmacy'
        WHEN 'Bebidas' THEN 'local_drink'
        WHEN 'Postres' THEN 'cake'
        WHEN 'Frutas y Verduras' THEN 'eco'
        WHEN 'Carnes' THEN 'restaurant_menu'
        WHEN 'Panadería' THEN 'bakery_dining'
        WHEN 'Servicios' THEN 'build'
        ELSE 'category'
    END,
    color = CASE name
        WHEN 'Comida Rápida' THEN '#FF6B35'
        WHEN 'Restaurantes' THEN '#4ECDC4'
        WHEN 'Supermercado' THEN '#45B7D1'
        WHEN 'Farmacia' THEN '#96CEB4'
        WHEN 'Bebidas' THEN '#FFEAA7'
        WHEN 'Postres' THEN '#DDA0DD'
        WHEN 'Frutas y Verduras' THEN '#98D8C8'
        WHEN 'Carnes' THEN '#F7DC6F'
        WHEN 'Panadería' THEN '#BB8FCE'
        WHEN 'Servicios' THEN '#85C1E9'
        ELSE '#CCCCCC'
    END,
    sort_order = CASE name
        WHEN 'Comida Rápida' THEN 1
        WHEN 'Restaurantes' THEN 2
        WHEN 'Supermercado' THEN 3
        WHEN 'Farmacia' THEN 4
        WHEN 'Bebidas' THEN 5
        WHEN 'Postres' THEN 6
        WHEN 'Frutas y Verduras' THEN 7
        WHEN 'Carnes' THEN 8
        WHEN 'Panadería' THEN 9
        WHEN 'Servicios' THEN 10
        ELSE 99
    END,
    is_active = true
WHERE icon IS NULL OR color IS NULL;

-- PASO 4: Insertar categorías nuevas si no existen
INSERT INTO product_categories (name, description, icon, color, sort_order, is_active) VALUES
('Comida Rápida', 'Hamburguesas, pizzas, tacos, etc.', 'fastfood', '#FF6B35', 1, true),
('Restaurantes', 'Comida tradicional y gourmet', 'restaurant', '#4ECDC4', 2, true),
('Supermercado', 'Productos de abarrotes y hogar', 'shopping_cart', '#45B7D1', 3, true),
('Farmacia', 'Medicamentos y productos de salud', 'local_pharmacy', '#96CEB4', 4, true),
('Bebidas', 'Bebidas alcohólicas y no alcohólicas', 'local_drink', '#FFEAA7', 5, true),
('Postres', 'Helados, pasteles, dulces', 'cake', '#DDA0DD', 6, true),
('Frutas y Verduras', 'Productos frescos', 'eco', '#98D8C8', 7, true),
('Carnes', 'Carnes frescas y procesadas', 'restaurant_menu', '#F7DC6F', 8, true),
('Panadería', 'Pan, pasteles, repostería', 'bakery_dining', '#BB8FCE', 9, true),
('Servicios', 'Servicios varios', 'build', '#85C1E9', 10, true)
ON CONFLICT (name) DO NOTHING;

-- PASO 5: Crear tablas de productos de vendedores
CREATE TABLE IF NOT EXISTS vendor_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendor_profiles(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES product_categories(id),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    is_available BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    images TEXT[] DEFAULT ARRAY[]::TEXT[],
    thumbnail_url TEXT,
    total_orders INTEGER DEFAULT 0,
    total_sales DECIMAL(12,2) DEFAULT 0.00,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendor_products_vendor ON vendor_products(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_products_category ON vendor_products(category_id);
CREATE INDEX IF NOT EXISTS idx_vendor_products_available ON vendor_products(is_available);

-- PASO 6: Crear tabla de comisiones
CREATE TABLE IF NOT EXISTS vendor_commissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendor_profiles(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(id),
    product_id UUID REFERENCES vendor_products(id),
    order_total DECIMAL(10,2) NOT NULL,
    commission_rate DECIMAL(5,2) NOT NULL,
    commission_amount DECIMAL(10,2) NOT NULL,
    platform_fee DECIMAL(10,2) DEFAULT 0.00,
    net_amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(30) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'cancelled', 'disputed')),
    payment_date TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendor_commissions_vendor ON vendor_commissions(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_commissions_order ON vendor_commissions(order_id);
CREATE INDEX IF NOT EXISTS idx_vendor_commissions_status ON vendor_commissions(payment_status);

-- PASO 7: Crear tabla de reseñas
CREATE TABLE IF NOT EXISTS vendor_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendor_profiles(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES users(id),
    order_id UUID NOT NULL REFERENCES orders(id),
    overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    title VARCHAR(200),
    comment TEXT,
    is_verified BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT true,
    vendor_response TEXT,
    vendor_response_date TIMESTAMP,
    moderation_status VARCHAR(30) DEFAULT 'approved' CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'hidden')),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendor_reviews_vendor ON vendor_reviews(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_reviews_customer ON vendor_reviews(customer_id);
CREATE INDEX IF NOT EXISTS idx_vendor_reviews_order ON vendor_reviews(order_id);
CREATE INDEX IF NOT EXISTS idx_vendor_reviews_rating ON vendor_reviews(overall_rating);

-- PASO 8: Crear vista dashboard final
CREATE OR REPLACE VIEW vendor_dashboard AS
SELECT 
    vp.id as vendor_id,
    COALESCE(vp.business_name, 'Sin Nombre') as business_name,
    COALESCE(vp.business_type, 'store') as business_type,
    COALESCE(vp.verification_status, 'pending') as verification_status,
    COALESCE(vp.commission_rate, 10.00) as commission_rate,
    COALESCE(vp.total_orders, 0) as total_orders,
    COALESCE(vp.total_sales, 0.00) as total_sales,
    COALESCE(vp.average_rating, 0.00) as average_rating,
    COALESCE(vp.total_reviews, 0) as total_reviews,
    u.name as owner_name,
    u.email as owner_email,
    u.phone as owner_phone,
    vp.created_at as registration_date,
    vp.verified_at,
    (SELECT COUNT(*) FROM vendor_products WHERE vendor_id = vp.id) as total_products,
    (SELECT COUNT(*) FROM vendor_products WHERE vendor_id = vp.id AND is_available = true) as active_products,
    (SELECT COALESCE(SUM(commission_amount), 0) FROM vendor_commissions WHERE vendor_id = vp.id) as total_commissions_earned,
    (SELECT COALESCE(SUM(net_amount), 0) FROM vendor_commissions WHERE vendor_id = vp.id AND payment_status = 'paid') as total_paid_out,
    (SELECT COALESCE(SUM(net_amount), 0) FROM vendor_commissions WHERE vendor_id = vp.id AND payment_status = 'pending') as pending_payments
FROM vendor_profiles vp
JOIN users u ON vp.user_id = u.id
ORDER BY vp.total_sales DESC, vp.average_rating DESC;

-- ✅ FIX COMPLETADO - TODAS LAS TABLAS DE VENDEDORES LISTAS
SELECT 'Sistema de vendedores corregido y completado exitosamente' as message;


