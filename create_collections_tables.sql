-- Script SQL para crear las tablas de colecciones en Supabase
-- Ejecutar este script en el SQL Editor de Supabase

-- Crear tabla de colecciones
CREATE TABLE IF NOT EXISTS collections (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order VARCHAR(20) DEFAULT 'newest',
    show_in_menu BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    featured BOOLEAN DEFAULT false,
    meta_title VARCHAR(200),
    meta_description TEXT,
    image_url TEXT,
    product_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de relación colección-producto
CREATE TABLE IF NOT EXISTS collection_products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    collection_id UUID REFERENCES collections(id) ON DELETE CASCADE,
    product_id UUID REFERENCES store_products(id) ON DELETE CASCADE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(collection_id, product_id)
);

-- Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_collections_title ON collections(title);
CREATE INDEX IF NOT EXISTS idx_collections_active ON collections(is_active);
CREATE INDEX IF NOT EXISTS idx_collections_menu ON collections(show_in_menu);
CREATE INDEX IF NOT EXISTS idx_collections_featured ON collections(featured);
CREATE INDEX IF NOT EXISTS idx_collection_products_collection ON collection_products(collection_id);
CREATE INDEX IF NOT EXISTS idx_collection_products_product ON collection_products(product_id);
CREATE INDEX IF NOT EXISTS idx_collection_products_sort ON collection_products(sort_order);

-- Crear función para actualizar product_count automáticamente
CREATE OR REPLACE FUNCTION update_collection_product_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE collections 
        SET product_count = product_count + 1 
        WHERE id = NEW.collection_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE collections 
        SET product_count = product_count - 1 
        WHERE id = OLD.collection_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para actualizar product_count
DROP TRIGGER IF EXISTS trigger_update_collection_product_count ON collection_products;
CREATE TRIGGER trigger_update_collection_product_count
    AFTER INSERT OR DELETE ON collection_products
    FOR EACH ROW EXECUTE FUNCTION update_collection_product_count();

-- Crear función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para actualizar updated_at en collections
DROP TRIGGER IF EXISTS trigger_update_collections_updated_at ON collections;
CREATE TRIGGER trigger_update_collections_updated_at
    BEFORE UPDATE ON collections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insertar algunas colecciones de ejemplo
INSERT INTO collections (title, description, show_in_menu, is_active, featured) VALUES
('Lo más vendido', 'Productos más populares y mejor valorados', true, true, true),
('Envío de remesa', 'Servicios de envío de dinero y remesas', true, true, false),
('Tu Carnicero', 'Productos frescos de carnicería', true, true, false),
('Electrónicos', 'Dispositivos electrónicos y accesorios', true, true, false),
('Motos', 'Motocicletas y accesorios', true, true, false)
ON CONFLICT DO NOTHING;

-- Comentarios para documentar las tablas
COMMENT ON TABLE collections IS 'Tabla de colecciones/categorías de productos';
COMMENT ON TABLE collection_products IS 'Tabla de relación entre colecciones y productos';
COMMENT ON COLUMN collections.title IS 'Título de la colección';
COMMENT ON COLUMN collections.description IS 'Descripción de la colección';
COMMENT ON COLUMN collections.sort_order IS 'Orden de productos: newest, oldest, price_low, price_high, name_asc, name_desc, manual';
COMMENT ON COLUMN collections.show_in_menu IS 'Si la colección se muestra en el menú principal';
COMMENT ON COLUMN collections.is_active IS 'Si la colección está activa';
COMMENT ON COLUMN collections.featured IS 'Si la colección es destacada';
COMMENT ON COLUMN collections.meta_title IS 'Título para SEO';
COMMENT ON COLUMN collections.meta_description IS 'Descripción para SEO';
COMMENT ON COLUMN collections.image_url IS 'URL de la imagen de la colección';
COMMENT ON COLUMN collections.product_count IS 'Número de productos en la colección (actualizado automáticamente)';
