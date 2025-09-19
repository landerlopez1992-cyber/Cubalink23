-- ========================== AGREGAR DIRECCIÓN DE EJEMPLO ==========================
-- Para probar que las direcciones se muestran en la app

-- PASO 1: Buscar el user_id de Lander Lopez
SELECT id, name, email FROM users WHERE name ILIKE '%lander%' OR email ILIKE '%lander%';

-- PASO 2: Agregar dirección de ejemplo (reemplaza USER_ID_AQUI con el ID real)
INSERT INTO user_addresses (
  user_id,
  full_name,
  street,
  city,
  province,
  country,
  phone,
  is_default
) VALUES (
  'USER_ID_AQUI', -- ⚠️ REEMPLAZAR CON ID REAL DE LANDER
  'Lander Lopez',
  'Calle 23 #456 entre 5ta y 7ma',
  'La Habana',
  'La Habana',
  'Cuba',
  '+5312345678',
  true
);

-- PASO 3: Verificar que se guardó
SELECT * FROM user_addresses WHERE full_name ILIKE '%lander%';
