-- Function to get orders for a specific user with their items
CREATE OR REPLACE FUNCTION get_user_orders_with_items(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', o.id,
            'order_number', o.order_number,
            'user_id', o.user_id,
            'subtotal', o.subtotal,
            'shipping_cost', o.shipping_cost,
            'total', o.total,
            'order_status', o.order_status,
            'payment_status', o.payment_status,
            'payment_method', o.payment_method,
            'shipping_method', o.shipping_method,
            'shipping_address', o.shipping_address,
            'created_at', o.created_at,
            'updated_at', o.updated_at,
            'estimated_delivery', o.estimated_delivery,
            'metadata', o.metadata,
            'items', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', oi.id,
                        'product_id', oi.metadata->>'original_product_id',
                        'name', oi.name,
                        'imageUrl', p.image_url, -- Join with products table to get image
                        'price', oi.unit_price,
                        'quantity', oi.quantity,
                        'category', p.category_id,
                        'type', oi.product_type
                    )
                )
                FROM order_items oi
                LEFT JOIN store_products p ON (oi.metadata->>'original_product_id')::uuid = p.id
                WHERE oi.order_id = o.id
            )
        )
    )
    INTO result
    FROM orders o
    WHERE o.user_id = p_user_id
    ORDER BY o.created_at DESC;

    RETURN COALESCE(result, '[]'::jsonb);
END;
$$ LANGUAGE plpgsql;
