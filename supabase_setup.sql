-- Configuración de tablas para Tu Recarga Store
-- Ejecuta este SQL en tu Dashboard de Supabase (SQL Editor)

-- Tabla de categorías de productos
CREATE TABLE IF NOT EXISTS product_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL UNIQUE,
  description TEXT,
  icon_name VARCHAR DEFAULT 'store',
  color VARCHAR DEFAULT '0xFF42A5F5',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de productos de la tienda
CREATE TABLE IF NOT EXISTS store_products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.0,
  image_url TEXT,
  category_id UUID REFERENCES product_categories(id),
  sub_category_id VARCHAR,
  unit VARCHAR DEFAULT 'unidad',
  weight DECIMAL(8,3) DEFAULT 0.0,
  is_available BOOLEAN DEFAULT true,
  is_active BOOLEAN DEFAULT true,
  stock INTEGER DEFAULT 0,
  available_provinces JSONB DEFAULT '[]',
  delivery_method VARCHAR DEFAULT 'express',
  additional_data JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_store_products_category_id ON store_products(category_id);
CREATE INDEX IF NOT EXISTS idx_store_products_is_active ON store_products(is_active);
CREATE INDEX IF NOT EXISTS idx_store_products_is_available ON store_products(is_available);
CREATE INDEX IF NOT EXISTS idx_product_categories_is_active ON product_categories(is_active);

-- Row Level Security (RLS) - Opcional pero recomendado
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_products ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad (permite lectura pública, escritura solo para usuarios autenticados)
CREATE POLICY "Allow public read access to categories" ON product_categories
  FOR SELECT USING (true);

CREATE POLICY "Allow public read access to products" ON store_products
  FOR SELECT USING (is_active = true);

CREATE POLICY "Allow authenticated users to manage categories" ON product_categories
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to manage products" ON store_products
  FOR ALL USING (auth.role() = 'authenticated');

-- Insertar categorías por defecto
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