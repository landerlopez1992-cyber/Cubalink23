-- 🚀 SISTEMA COMPLETO DE PEDIDOS - CUBALINK23
-- Actualizar tabla orders y crear order_items para sistema completo

-- ==================== EXTENDER TABLA ORDERS ====================
-- Agregar campos faltantes a la tabla orders existente
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS vendor_id UUID REFERENCES vendor_profiles(id);

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS delivery_id UUID REFERENCES delivery_profiles(id);

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS source_type TEXT DEFAULT 'store' CHECK (source_type IN ('store', 'amazon', 'vendor'));

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS total_weight DECIMAL(8,3) DEFAULT 0.0;

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS total_volume DECIMAL(10,3) DEFAULT 0.0;

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS customer_name TEXT;

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS customer_email TEXT;

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS customer_phone TEXT;

-- Extender direcciones de envío con campos individuales para mejor acceso
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS shipping_recipient TEXT;

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS shipping_phone TEXT;

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS shipping_street TEXT;

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS shipping_city TEXT;

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS shipping_province TEXT;

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS shipping_postal_code TEXT;

-- Estados más específicos para el sistema de delivery
ALTER TABLE orders 
DROP CONSTRAINT IF EXISTS orders_order_status_check;

ALTER TABLE orders 
ADD CONSTRAINT orders_order_status_check CHECK (order_status IN (
    'created',              -- Orden creada inicialmente
    'payment_pending',      -- Esperando pago
    'payment_confirmed',    -- Pago confirmado
    'processing',           -- Procesando orden
    'vendor_processing',    -- Vendedor procesando (si aplica)
    'ready_for_pickup',     -- Listo para recoger
    'assigned_to_delivery', -- Asignado a repartidor
    'pickup_in_progress',   -- Repartidor recogiendo
    'in_transit',           -- En tránsito
    'out_for_delivery',     -- Salió para entrega
    'delivered',            -- Entregado
    'cancelled',            -- Cancelado
    'refunded'              -- Reembolsado
));

-- ==================== CREAR TABLA ORDER_ITEMS ====================
-- Tabla dedicada para items de cada pedido (mejor que JSON)
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    
    -- Información del producto
    product_type TEXT NOT NULL CHECK (product_type IN ('store', 'amazon', 'vendor')),
    product_id UUID, -- ID genérico del producto
    store_product_id UUID REFERENCES store_products(id),
    vendor_product_id UUID, -- Para futuro sistema de vendedores
    
    -- Detalles del producto (guardados para historial)
    name TEXT NOT NULL,
    description TEXT,
    sku TEXT,
    asin TEXT, -- Para productos de Amazon
    
    -- Precios y cantidades
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    total_price DECIMAL(10,2) NOT NULL,
    
    -- Información física para envío
    unit_weight_lb DECIMAL(8,3) DEFAULT 0.0, -- Peso en libras
    total_weight_lb DECIMAL(8,3) DEFAULT 0.0,
    unit_dimensions JSONB DEFAULT '{}', -- {length, width, height}
    
    -- Personalización del producto
    selected_size TEXT,
    selected_color TEXT,
    custom_options JSONB DEFAULT '{}',
    
    -- Estado individual del ítem
    item_status TEXT DEFAULT 'pending' CHECK (item_status IN (
        'pending', 'processing', 'ready', 'shipped', 'delivered', 'cancelled'
    )),
    
    -- Vendedor asignado (si aplica)
    assigned_vendor_id UUID,
    
    -- Información de Amazon (si aplica)
    amazon_data JSONB DEFAULT '{}',
    
    -- Metadatos adicionales
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== ÍNDICES PARA OPTIMIZACIÓN ====================
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_vendor_id ON orders(vendor_id);
CREATE INDEX IF NOT EXISTS idx_orders_delivery_id ON orders(delivery_id);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_type ON order_items(product_type);
CREATE INDEX IF NOT EXISTS idx_order_items_store_product_id ON order_items(store_product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_status ON order_items(item_status);

-- ==================== FUNCIONES PARA AUTOMATIZACIÓN ====================

-- Función para generar número de orden único
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
BEGIN
    RETURN 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD((EXTRACT(EPOCH FROM NOW()) * 1000)::TEXT, 10, '0');
END;
$$ LANGUAGE plpgsql;

-- Función para calcular totales automáticamente
CREATE OR REPLACE FUNCTION calculate_order_totals(p_order_id UUID)
RETURNS VOID AS $$
DECLARE
    v_subtotal DECIMAL(10,2);
    v_total_weight DECIMAL(8,3);
BEGIN
    -- Calcular subtotal y peso total desde order_items
    SELECT 
        COALESCE(SUM(total_price), 0),
        COALESCE(SUM(total_weight_lb), 0)
    INTO v_subtotal, v_total_weight
    FROM order_items 
    WHERE order_id = p_order_id;
    
    -- Actualizar orden con totales calculados
    UPDATE orders 
    SET 
        subtotal = v_subtotal,
        total_weight = v_total_weight,
        updated_at = NOW()
    WHERE id = p_order_id;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar totales automáticamente
CREATE OR REPLACE FUNCTION trigger_update_order_totals()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar totales cuando se modifica un item
    PERFORM calculate_order_totals(COALESCE(NEW.order_id, OLD.order_id));
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_order_items_update_totals
    AFTER INSERT OR UPDATE OR DELETE ON order_items
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_order_totals();

-- ==================== DATOS DE PRUEBA (OPCIONAL) ====================
-- Insertar algunos datos de ejemplo para testing
/*
INSERT INTO orders (
    user_id, order_number, customer_name, customer_email, 
    shipping_recipient, shipping_phone, shipping_street, shipping_city, shipping_province,
    shipping_method, payment_method, payment_status, order_status,
    subtotal, shipping_cost, total
) VALUES (
    (SELECT id FROM users LIMIT 1), -- Primer usuario disponible
    generate_order_number(),
    'Juan Pérez',
    'juan@ejemplo.com',
    'Juan Pérez',
    '+1234567890',
    '123 Calle Principal',
    'Havana',
    'La Habana',
    'express',
    'card',
    'completed',
    'payment_confirmed',
    25.99,
    5.00,
    30.99
);
*/

-- ==================== POLÍTICA DE SEGURIDAD ====================
-- Asegurar que los usuarios solo vean sus propias órdenes
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own orders" ON orders
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own orders" ON orders
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

-- Política para order_items
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own order items" ON order_items
    FOR SELECT USING (
        order_id IN (SELECT id FROM orders WHERE user_id = auth.uid()::text)
    );

CREATE POLICY "Users can insert own order items" ON order_items
    FOR INSERT WITH CHECK (
        order_id IN (SELECT id FROM orders WHERE user_id = auth.uid()::text)
    );

-- ==================== COMENTARIOS Y DOCUMENTACIÓN ====================
COMMENT ON TABLE orders IS 'Tabla principal de pedidos/órdenes del sistema';
COMMENT ON TABLE order_items IS 'Detalles de productos por cada pedido';
COMMENT ON FUNCTION generate_order_number() IS 'Genera números únicos de orden con formato ORD-YYYYMMDD-timestamp';
COMMENT ON FUNCTION calculate_order_totals(UUID) IS 'Calcula subtotal y peso total automáticamente desde order_items';

-- ==================== VERIFICACIÓN FINAL ====================
-- Mostrar estructura actualizada
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('orders', 'order_items')
ORDER BY table_name, ordinal_position;

COMMIT;
