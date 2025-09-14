-- Script SQL para agregar las columnas faltantes a la tabla store_products
-- Ejecutar este script en el SQL Editor de Supabase

-- Agregar columna subcategory
ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS subcategory TEXT;

-- Agregar columna weight (peso en kg)
ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS weight DECIMAL(10,2);

-- Agregar columna shipping_cost (costo de envío adicional)
ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS shipping_cost DECIMAL(10,2) DEFAULT 0;

-- Agregar columna shipping_methods (métodos de envío como JSON)
ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS shipping_methods JSONB DEFAULT '[]'::jsonb;

-- Agregar columna tags (etiquetas como JSON)
ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS tags JSONB DEFAULT '[]'::jsonb;

-- Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_store_products_subcategory ON store_products(subcategory);
CREATE INDEX IF NOT EXISTS idx_store_products_weight ON store_products(weight);
CREATE INDEX IF NOT EXISTS idx_store_products_shipping_cost ON store_products(shipping_cost);
CREATE INDEX IF NOT EXISTS idx_store_products_tags ON store_products USING GIN(tags);

-- Comentarios para documentar las columnas
COMMENT ON COLUMN store_products.subcategory IS 'Subcategoría del producto (ej: Motos Eléctricas, Smartphones)';
COMMENT ON COLUMN store_products.weight IS 'Peso del producto en kilogramos';
COMMENT ON COLUMN store_products.shipping_cost IS 'Costo adicional de envío por preparación y manejo';
COMMENT ON COLUMN store_products.shipping_methods IS 'Métodos de envío disponibles como array JSON';
COMMENT ON COLUMN store_products.tags IS 'Etiquetas del producto como array JSON (ej: NUEVO, 12% OFF)';
