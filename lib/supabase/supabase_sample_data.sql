-- Helper function to insert users into auth.users
CREATE OR REPLACE FUNCTION insert_user_to_auth(email TEXT, password TEXT)
RETURNS TEXT AS $$
DECLARE
    user_id TEXT;
BEGIN
    INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
    VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        email,
        crypt(password, gen_salt('bf')),
        NOW(),
        NOW(),
        NOW()
    )
    RETURNING id::text INTO user_id;
    RETURN user_id;
END;
$$ LANGUAGE plpgsql;

-- Insert sample users into auth.users first
SELECT insert_user_to_auth('john.doe@example.com', 'password123');
SELECT insert_user_to_auth('jane.smith@example.com', 'securepass');
SELECT insert_user_to_auth('alice.jones@example.com', 'mypassword');

-- Insert sample data into orders
INSERT INTO orders (firebase_id, user_id, order_number, items, shipping_address, shipping_method, subtotal, shipping_cost, total, payment_method, payment_status, order_status, estimated_delivery, zelle_payment_proof, metadata)
SELECT
    'firebase_order_001',
    (SELECT id::text FROM auth.users WHERE email = 'john.doe@example.com'),
    'TR-ORD-001',
    '[{"product_id": "prod_001", "name": "Smartphone", "quantity": 1, "price": 500.00}, {"product_id": "prod_002", "name": "Headphones", "quantity": 2, "price": 50.00}]'::jsonb,
    '{"street": "123 Main St", "city": "Anytown", "state": "CA", "zip": "90210", "country": "USA"}'::jsonb,
    'express',
    600.00,
    25.00,
    625.00,
    'credit_card',
    'completed',
    'delivered',
    '2024-07-10',
    NULL,
    '{"notes": "Customer requested gift wrapping"}'::jsonb
UNION ALL
SELECT
    'firebase_order_002',
    (SELECT id::text FROM auth.users WHERE email = 'jane.smith@example.com'),
    'TR-ORD-002',
    '[{"product_id": "prod_003", "name": "Laptop", "quantity": 1, "price": 1200.00}]'::jsonb,
    '{"street": "456 Oak Ave", "city": "Otherville", "state": "NY", "zip": "10001", "country": "USA"}'::jsonb,
    'maritime',
    1200.00,
    50.00,
    1250.00,
    'zelle',
    'pending',
    'payment_pending',
    '2024-08-01',
    'zelle_proof_001.jpg',
    '{}'::jsonb
UNION ALL
SELECT
    'firebase_order_003',
    (SELECT id::text FROM auth.users WHERE email = 'john.doe@example.com'),
    'TR-ORD-003',
    '[{"product_id": "prod_004", "name": "Smartwatch", "quantity": 1, "price": 250.00}]'::jsonb,
    '{"street": "123 Main St", "city": "Anytown", "state": "CA", "zip": "90210", "country": "USA"}'::jsonb,
    'express',
    250.00,
    15.00,
    265.00,
    'credit_card',
    'completed',
    'processing',
    '2024-07-15',
    NULL,
    '{}'::jsonb
UNION ALL
SELECT
    'firebase_order_004',
    (SELECT id::text FROM auth.users WHERE email = 'alice.jones@example.com'),
    'TR-ORD-004',
    '[{"product_id": "prod_005", "name": "Tablet", "quantity": 1, "price": 400.00}, {"product_id": "prod_006", "name": "Keyboard", "quantity": 1, "price": 75.00}]'::jsonb,
    '{"street": "789 Pine Ln", "city": "Villagetown", "state": "TX", "zip": "75001", "country": "USA"}'::jsonb,
    'maritime',
    475.00,
    30.00,
    505.00,
    'zelle',
    'completed',
    'shipped',
    '2024-08-10',
    'zelle_proof_002.png',
    '{"tracking_number": "SHIP12345"}'::jsonb;

-- Insert sample data into activities
INSERT INTO activities (firebase_id, user_id, type, description, amount, metadata)
SELECT
    'firebase_activity_001',
    (SELECT id::text FROM auth.users WHERE email = 'john.doe@example.com'),
    'order_placed',
    'Order TR-ORD-001 placed successfully',
    625.00,
    '{"order_number": "TR-ORD-001"}'::jsonb
UNION ALL
SELECT
    'firebase_activity_002',
    (SELECT id::text FROM auth.users WHERE email = 'jane.smith@example.com'),
    'payment_pending',
    'Payment pending for order TR-ORD-002',
    1250.00,
    '{"order_number": "TR-ORD-002"}'::jsonb
UNION ALL
SELECT
    'firebase_activity_003',
    (SELECT id::text FROM auth.users WHERE email = 'john.doe@example.com'),
    'order_shipped',
    'Order TR-ORD-001 has been shipped',
    NULL,
    '{"order_number": "TR-ORD-001", "tracking_id": "XYZ789"}'::jsonb
UNION ALL
SELECT
    'firebase_activity_004',
    (SELECT id::text FROM auth.users WHERE email = 'alice.jones@example.com'),
    'order_placed',
    'Order TR-ORD-004 placed successfully',
    505.00,
    '{"order_number": "TR-ORD-004"}'::jsonb
UNION ALL
SELECT
    'firebase_activity_005',
    (SELECT id::text FROM auth.users WHERE email = 'jane.smith@example.com'),
    'payment_received',
    'Zelle payment received for order TR-ORD-002',
    1250.00,
    '{"order_number": "TR-ORD-002"}'::jsonb;

-- Insert sample data into profile_photos
INSERT INTO profile_photos (user_id, firebase_url, supabase_url, filename, file_size)
SELECT
    (SELECT id::text FROM auth.users WHERE email = 'john.doe@example.com'),
    'https://firebase.com/john_profile.jpg',
    'https://supabase.com/storage/v1/object/public/profiles/john_profile.jpg',
    'john_profile.jpg',
    150000
UNION ALL
SELECT
    (SELECT id::text FROM auth.users WHERE email = 'jane.smith@example.com'),
    'https://firebase.com/jane_profile.png',
    'https://supabase.com/storage/v1/object/public/profiles/jane_profile.png',
    'jane_profile.png',
    200000;

-- Insert sample data into zelle_proofs
INSERT INTO zelle_proofs (order_id, firebase_url, supabase_url, filename, file_size)
SELECT
    (SELECT id::text FROM orders WHERE order_number = 'TR-ORD-002'),
    'https://firebase.com/zelle_proofs/proof_001.jpg',
    'https://supabase.com/storage/v1/object/public/zelle_proofs/proof_001.jpg',
    'proof_001.jpg',
    300000
UNION ALL
SELECT
    (SELECT id::text FROM orders WHERE order_number = 'TR-ORD-004'),
    'https://firebase.com/zelle_proofs/proof_002.png',
    'https://supabase.com/storage/v1/object/public/zelle_proofs/proof_proof_002.png',
    'proof_002.png',
    450000;

-- Clean up the helper function
DROP FUNCTION insert_user_to_auth;