-- =====================================================
-- FIX: Corregir tabla vendor_profiles
-- =====================================================
-- Error: column "verification_status" does not exist
-- Solución: Ajustar la tabla para que coincida con la estructura existente

-- Primero verificar estructura actual de vendor_profiles
DO $$
BEGIN
    -- Si la tabla no tiene verification_status, agregarla
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'verification_status'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN verification_status VARCHAR(30) DEFAULT 'pending' 
        CHECK (verification_status IN ('pending', 'verified', 'rejected', 'suspended'));
    END IF;
    
    -- Agregar otras columnas faltantes si no existen
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'business_name'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN business_name VARCHAR(200) NOT NULL DEFAULT 'Negocio Sin Nombre';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'business_type'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN business_type VARCHAR(50) NOT NULL DEFAULT 'store';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'business_description'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN business_description TEXT;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'business_address'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN business_address JSONB NOT NULL DEFAULT '{}';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'business_phone'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN business_phone VARCHAR(20);
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'commission_rate'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN commission_rate DECIMAL(5,2) DEFAULT 10.00;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'total_orders'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN total_orders INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'total_sales'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN total_sales DECIMAL(12,2) DEFAULT 0.00;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'average_rating'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN average_rating DECIMAL(3,2) DEFAULT 0.00;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'total_reviews'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN total_reviews INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'verified_at'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN verified_at TIMESTAMP;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendor_profiles' 
        AND column_name = 'verified_by'
    ) THEN
        ALTER TABLE vendor_profiles ADD COLUMN verified_by UUID REFERENCES users(id);
    END IF;
END $$;

-- Ahora crear las otras tablas que pueden estar faltando
CREATE TABLE IF NOT EXISTS product_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id UUID REFERENCES product_categories(id),
    icon VARCHAR(50),
    color VARCHAR(7),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insertar categorías si no existen
INSERT INTO product_categories (name, description, icon, color, sort_order) VALUES
('Comida Rápida', 'Hamburguesas, pizzas, tacos, etc.', 'fastfood', '#FF6B35', 1),
('Restaurantes', 'Comida tradicional y gourmet', 'restaurant', '#4ECDC4', 2),
('Supermercado', 'Productos de abarrotes y hogar', 'shopping_cart', '#45B7D1', 3),
('Farmacia', 'Medicamentos y productos de salud', 'local_pharmacy', '#96CEB4', 4),
('Bebidas', 'Bebidas alcohólicas y no alcohólicas', 'local_drink', '#FFEAA7', 5),
('Postres', 'Helados, pasteles, dulces', 'cake', '#DDA0DD', 6),
('Frutas y Verduras', 'Productos frescos', 'eco', '#98D8C8', 7),
('Carnes', 'Carnes frescas y procesadas', 'restaurant_menu', '#F7DC6F', 8),
('Panadería', 'Pan, pasteles, repostería', 'bakery_dining', '#BB8FCE', 9),
('Servicios', 'Servicios varios', 'build', '#85C1E9', 10)
ON CONFLICT (name) DO NOTHING;

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
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendor_commissions_vendor ON vendor_commissions(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_commissions_order ON vendor_commissions(order_id);

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
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendor_reviews_vendor ON vendor_reviews(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_reviews_customer ON vendor_reviews(customer_id);

-- Crear vista simplificada sin campos problemáticos
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
    vp.created_at as registration_date,
    (SELECT COUNT(*) FROM vendor_products WHERE vendor_id = vp.id) as total_products,
    (SELECT COUNT(*) FROM vendor_products WHERE vendor_id = vp.id AND is_available = true) as active_products
FROM vendor_profiles vp
JOIN users u ON vp.user_id = u.id
ORDER BY vp.total_sales DESC, vp.average_rating DESC;

-- ✅ FIX COMPLETADO
SELECT 'Tabla vendor_profiles corregida exitosamente' as message;