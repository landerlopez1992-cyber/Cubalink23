-- Script para agregar columnas faltantes a la tabla store_products
-- Ejecutar en Supabase SQL Editor

-- Agregar columnas faltantes si no existen
DO $$ 
BEGIN
    -- Agregar columna shipping_cost si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'store_products' AND column_name = 'shipping_cost') THEN
        ALTER TABLE store_products ADD COLUMN shipping_cost DECIMAL(10,2) DEFAULT 0;
        RAISE NOTICE 'Columna shipping_cost agregada';
    ELSE
        RAISE NOTICE 'Columna shipping_cost ya existe';
    END IF;

    -- Agregar columna weight si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'store_products' AND column_name = 'weight') THEN
        ALTER TABLE store_products ADD COLUMN weight VARCHAR(50);
        RAISE NOTICE 'Columna weight agregada';
    ELSE
        RAISE NOTICE 'Columna weight ya existe';
    END IF;

    -- Agregar columna shipping_methods si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'store_products' AND column_name = 'shipping_methods') THEN
        ALTER TABLE store_products ADD COLUMN shipping_methods JSONB DEFAULT '[]'::jsonb;
        RAISE NOTICE 'Columna shipping_methods agregada';
    ELSE
        RAISE NOTICE 'Columna shipping_methods ya existe';
    END IF;

    -- Agregar columna tags si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'store_products' AND column_name = 'tags') THEN
        ALTER TABLE store_products ADD COLUMN tags JSONB DEFAULT '[]'::jsonb;
        RAISE NOTICE 'Columna tags agregada';
    ELSE
        RAISE NOTICE 'Columna tags ya existe';
    END IF;

    -- Agregar columna subcategory si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'store_products' AND column_name = 'subcategory') THEN
        ALTER TABLE store_products ADD COLUMN subcategory VARCHAR(100);
        RAISE NOTICE 'Columna subcategory agregada';
    ELSE
        RAISE NOTICE 'Columna subcategory ya existe';
    END IF;

    -- Agregar columna vendor_id si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'store_products' AND column_name = 'vendor_id') THEN
        ALTER TABLE store_products ADD COLUMN vendor_id VARCHAR(50) DEFAULT 'admin';
        RAISE NOTICE 'Columna vendor_id agregada';
    ELSE
        RAISE NOTICE 'Columna vendor_id ya existe';
    END IF;

    -- Agregar columna is_active si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'store_products' AND column_name = 'is_active') THEN
        ALTER TABLE store_products ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE 'Columna is_active agregada';
    ELSE
        RAISE NOTICE 'Columna is_active ya existe';
    END IF;

    -- Agregar columna created_at si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'store_products' AND column_name = 'created_at') THEN
        ALTER TABLE store_products ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Columna created_at agregada';
    ELSE
        RAISE NOTICE 'Columna created_at ya existe';
    END IF;

    -- Agregar columna updated_at si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'store_products' AND column_name = 'updated_at') THEN
        ALTER TABLE store_products ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Columna updated_at agregada';
    ELSE
        RAISE NOTICE 'Columna updated_at ya existe';
    END IF;

END $$;

-- Configurar políticas RLS para store_products
ALTER TABLE store_products ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si existen
DROP POLICY IF EXISTS "Enable all operations for authenticated users" ON store_products;
DROP POLICY IF EXISTS "Enable read access for all users" ON store_products;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON store_products;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON store_products;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON store_products;

-- Crear nuevas políticas RLS
CREATE POLICY "Enable read access for all users" ON store_products
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON store_products
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON store_products
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for authenticated users" ON store_products
    FOR DELETE USING (true);

-- Crear trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger a store_products
DROP TRIGGER IF EXISTS update_store_products_updated_at ON store_products;
CREATE TRIGGER update_store_products_updated_at
    BEFORE UPDATE ON store_products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Verificar estructura final de la tabla
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'store_products'
ORDER BY ordinal_position;
