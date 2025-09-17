-- 🚨 ARREGLO FINAL DEFINITIVO - ÓRDENES
-- Ejecutar en Supabase SQL Editor AHORA MISMO

-- 1. Deshabilitar RLS completamente
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;

-- 2. Crear tabla order_items si no existe
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    total_price DECIMAL(10,2) NOT NULL,
    product_type TEXT DEFAULT 'store',
    unit_weight_lb DECIMAL(8,3) DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Deshabilitar RLS en order_items
ALTER TABLE order_items DISABLE ROW LEVEL SECURITY;

-- 4. Crear orden de prueba DIRECTA
INSERT INTO orders (
    user_id, order_number, shipping_method, subtotal, shipping_cost, total,
    payment_method, payment_status, order_status, shipping_address, items
) VALUES (
    '0b802a1e-8651-4fcf-b2d7-0442db89f4d7',
    'MANUAL-TEST-001',
    'express',
    15.99,
    3.00,
    18.99,
    'wallet',
    'completed',
    'payment_confirmed',
    '{"recipient": "Lander Lopez", "address": "Test Address"}',
    '[]'
) RETURNING id, order_number, total, created_at;

-- 5. Verificar que se creó
SELECT 
    order_number, 
    total, 
    order_status, 
    payment_status,
    created_at 
FROM orders 
WHERE user_id = '0b802a1e-8651-4fcf-b2d7-0442db89f4d7'
ORDER BY created_at DESC;
