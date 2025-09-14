-- Script para agregar sistema de aprobación de productos de vendedores
-- Ejecutar en Supabase SQL Editor

-- Agregar campo de estado de aprobación a store_products
ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approval_status VARCHAR(20) DEFAULT 'approved';

-- Agregar campo de fecha de aprobación
ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;

-- Agregar campo de aprobado por (admin que aprobó)
ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES users(id);

-- Agregar campo de comentarios de aprobación
ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approval_notes TEXT;

-- Crear índice para mejorar consultas por estado de aprobación
CREATE INDEX IF NOT EXISTS idx_store_products_approval_status ON store_products(approval_status);

-- Crear índice para productos por vendedor y estado
CREATE INDEX IF NOT EXISTS idx_store_products_vendor_approval ON store_products(vendor_id, approval_status);

-- Actualizar productos existentes para que estén aprobados por defecto
UPDATE store_products 
SET approval_status = 'approved', 
    approved_at = created_at,
    approved_by = (SELECT id FROM users WHERE role = 'admin' LIMIT 1)
WHERE approval_status IS NULL;

-- Crear función para aprobar producto
CREATE OR REPLACE FUNCTION approve_product(
    product_id UUID,
    admin_id UUID,
    notes TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE store_products 
    SET approval_status = 'approved',
        approved_at = NOW(),
        approved_by = admin_id,
        approval_notes = notes,
        updated_at = NOW()
    WHERE id = product_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Crear función para rechazar producto
CREATE OR REPLACE FUNCTION reject_product(
    product_id UUID,
    admin_id UUID,
    notes TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE store_products 
    SET approval_status = 'rejected',
        approved_at = NOW(),
        approved_by = admin_id,
        approval_notes = notes,
        updated_at = NOW()
    WHERE id = product_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Crear vista para productos pendientes de aprobación
CREATE OR REPLACE VIEW pending_products AS
SELECT 
    sp.*,
    u.name as vendor_name,
    u.email as vendor_email,
    admin.name as approved_by_name
FROM store_products sp
LEFT JOIN users u ON sp.vendor_id = u.id
LEFT JOIN users admin ON sp.approved_by = admin.id
WHERE sp.approval_status = 'pending'
ORDER BY sp.created_at DESC;

-- Crear vista para productos aprobados (para mostrar en la app)
CREATE OR REPLACE VIEW approved_products AS
SELECT 
    sp.*,
    u.name as vendor_name,
    u.email as vendor_email
FROM store_products sp
LEFT JOIN users u ON sp.vendor_id = u.id
WHERE sp.approval_status = 'approved' 
  AND sp.is_active = true 
  AND sp.is_available = true
ORDER BY sp.created_at DESC;

-- Comentarios para documentar el sistema
COMMENT ON COLUMN store_products.approval_status IS 'Estado de aprobación: pending, approved, rejected';
COMMENT ON COLUMN store_products.approved_at IS 'Fecha y hora de aprobación';
COMMENT ON COLUMN store_products.approved_by IS 'ID del admin que aprobó el producto';
COMMENT ON COLUMN store_products.approval_notes IS 'Comentarios del admin sobre la aprobación';

-- RLS (Row Level Security) para el sistema de aprobación
-- Los vendedores solo pueden ver sus propios productos
CREATE POLICY "Vendors can view their own products" ON store_products
    FOR SELECT USING (
        vendor_id = auth.uid() OR 
        approval_status = 'approved'
    );

-- Los vendedores solo pueden insertar productos con estado pending
CREATE POLICY "Vendors can create pending products" ON store_products
    FOR INSERT WITH CHECK (
        vendor_id = auth.uid() AND 
        approval_status = 'pending'
    );

-- Los vendedores solo pueden actualizar sus productos si están pending
CREATE POLICY "Vendors can update pending products" ON store_products
    FOR UPDATE USING (
        vendor_id = auth.uid() AND 
        approval_status = 'pending'
    );

-- Los admins pueden hacer todo
CREATE POLICY "Admins can manage all products" ON store_products
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role = 'admin'
        )
    );
