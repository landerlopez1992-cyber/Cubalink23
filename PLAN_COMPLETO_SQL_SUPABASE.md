# 📋 PLAN COMPLETO DE IMPLEMENTACIÓN SQL EN SUPABASE

## 🎯 **FASE 1: SISTEMA DE USUARIOS EXTENDIDO**

### 1.1 Extender tabla `users` para roles de vendedor/repartidor

```sql
-- Actualizar tabla users con nuevos roles y campos
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'usuario' CHECK (role IN ('usuario', 'admin', 'vendor', 'delivery'));

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS vendor_id UUID REFERENCES vendor_profiles(id);

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS delivery_id UUID REFERENCES delivery_profiles(id);

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS wallet_balance DECIMAL(12,2) DEFAULT 0.00;

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS commission_balance DECIMAL(12,2) DEFAULT 0.00;

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS rating_average DECIMAL(3,2) DEFAULT 0.0;

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS total_ratings INTEGER DEFAULT 0;

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS is_approved BOOLEAN DEFAULT FALSE;

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS approval_date TIMESTAMP WITH TIME ZONE;

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS documents_verified BOOLEAN DEFAULT FALSE;
```

### 1.2 Tarjetas guardadas extendidas

```sql
-- Extender payment_cards para retiros y métodos adicionales
ALTER TABLE payment_cards 
ADD COLUMN IF NOT EXISTS nickname TEXT;

ALTER TABLE payment_cards 
ADD COLUMN IF NOT EXISTS last_used TIMESTAMP WITH TIME ZONE DEFAULT NOW();

ALTER TABLE payment_cards 
ADD COLUMN IF NOT EXISTS is_for_withdrawals BOOLEAN DEFAULT TRUE;

-- Tabla para direcciones guardadas
CREATE TABLE IF NOT EXISTS user_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    full_address TEXT NOT NULL,
    address_line_1 TEXT NOT NULL,
    address_line_2 TEXT,
    city TEXT NOT NULL,
    province TEXT NOT NULL,
    postal_code TEXT,
    country TEXT DEFAULT 'Cuba',
    phone TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🎯 **FASE 2: SISTEMA COMPLETO DE VENDEDORES**

### 2.1 Perfiles de vendedores

```sql
-- Tabla principal de perfiles de vendedor
CREATE TABLE IF NOT EXISTS vendor_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    company_name TEXT NOT NULL,
    company_description TEXT,
    company_logo_url TEXT,
    store_cover_url TEXT,
    business_address TEXT NOT NULL,
    business_phone TEXT,
    business_email TEXT,
    tax_id TEXT,
    categories TEXT[] DEFAULT '{}',
    delivery_methods TEXT[] DEFAULT '{}', -- ['self_delivery', 'app_delivery', 'maritime']
    service_areas TEXT[] DEFAULT '{}', -- Provincias donde opera
    
    -- Configuración de entrega
    can_self_deliver BOOLEAN DEFAULT TRUE,
    can_use_app_delivery BOOLEAN DEFAULT FALSE,
    can_use_maritime BOOLEAN DEFAULT FALSE,
    
    -- Estado y verificación
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    verification_date TIMESTAMP WITH TIME ZONE,
    documents_status TEXT DEFAULT 'pending' CHECK (documents_status IN ('pending', 'approved', 'rejected')),
    
    -- Estadísticas
    rating_average DECIMAL(3,2) DEFAULT 0.0,
    total_ratings INTEGER DEFAULT 0,
    total_sales INTEGER DEFAULT 0,
    total_products INTEGER DEFAULT 0,
    
    -- Configuración de comisiones
    commission_percentage DECIMAL(5,2) DEFAULT 10.00,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de productos del vendedor
CREATE TABLE IF NOT EXISTS vendor_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID NOT NULL REFERENCES vendor_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    category_id UUID REFERENCES store_categories(id),
    subcategory_id UUID REFERENCES store_subcategories(id),
    price DECIMAL(10,2) NOT NULL,
    weight DECIMAL(8,3) DEFAULT 0.0, -- En kilogramos
    dimensions_length DECIMAL(8,2), -- En centímetros
    dimensions_width DECIMAL(8,2),
    dimensions_height DECIMAL(8,2),
    stock INTEGER DEFAULT 0,
    unit TEXT DEFAULT 'unidad',
    
    -- Configuración de entrega por producto
    self_delivery_enabled BOOLEAN DEFAULT TRUE,
    app_delivery_enabled BOOLEAN DEFAULT FALSE,
    maritime_delivery_enabled BOOLEAN DEFAULT FALSE,
    
    -- Precios de envío por método
    self_delivery_cost DECIMAL(8,2) DEFAULT 0.00,
    app_delivery_cost DECIMAL(8,2) DEFAULT NULL, -- NULL = calculado por sistema
    maritime_delivery_cost DECIMAL(8,2) DEFAULT NULL,
    
    -- Tiempos de entrega estimados (en días)
    self_delivery_days INTEGER DEFAULT 1,
    app_delivery_days INTEGER DEFAULT 1,
    maritime_delivery_days INTEGER DEFAULT 30,
    
    -- Estado y aprobación
    approval_status TEXT DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected')),
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    approval_notes TEXT,
    
    images TEXT[] DEFAULT '{}',
    available_provinces TEXT[] DEFAULT '{}',
    available_sizes TEXT[] DEFAULT '{}',
    available_colors TEXT[] DEFAULT '{}',
    
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de configuración de entrega por vendedor
CREATE TABLE IF NOT EXISTS vendor_delivery_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID UNIQUE NOT NULL REFERENCES vendor_profiles(id) ON DELETE CASCADE,
    
    -- Configuración global del vendedor
    default_delivery_method TEXT DEFAULT 'self_delivery' CHECK (default_delivery_method IN ('self_delivery', 'app_delivery', 'maritime')),
    
    -- Límites de peso y dimensiones para cada método
    self_delivery_max_weight DECIMAL(8,3) DEFAULT 50.0,
    app_delivery_max_weight DECIMAL(8,3) DEFAULT 20.0,
    maritime_delivery_max_weight DECIMAL(8,3) DEFAULT 1000.0,
    
    -- Costos base por método
    self_delivery_base_cost DECIMAL(8,2) DEFAULT 5.00,
    app_delivery_markup_percentage DECIMAL(5,2) DEFAULT 0.00, -- Sobrecosto sobre tarifa del sistema
    maritime_delivery_base_cost DECIMAL(8,2) DEFAULT 15.00,
    
    -- Zonas de entrega
    self_delivery_zones TEXT[] DEFAULT '{}',
    app_delivery_zones TEXT[] DEFAULT '{}',
    maritime_delivery_zones TEXT[] DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🎯 **FASE 3: SISTEMA COMPLETO DE REPARTIDORES**

### 3.1 Perfiles de repartidores

```sql
-- Tabla principal de perfiles de repartidor
CREATE TABLE IF NOT EXISTS delivery_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Información personal
    full_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    address TEXT NOT NULL,
    identity_document TEXT NOT NULL,
    
    -- Información del vehículo
    vehicle_type TEXT NOT NULL CHECK (vehicle_type IN ('motorcycle', 'bicycle', 'car', 'van')),
    vehicle_brand TEXT,
    vehicle_model TEXT,
    vehicle_year INTEGER,
    vehicle_plate TEXT,
    vehicle_color TEXT,
    vehicle_photos TEXT[] DEFAULT '{}',
    
    -- Documentos y verificación
    driver_license_url TEXT,
    vehicle_registration_url TEXT,
    insurance_url TEXT,
    background_check_url TEXT,
    profile_photo_url TEXT,
    documents_status TEXT DEFAULT 'pending' CHECK (documents_status IN ('pending', 'approved', 'rejected')),
    
    -- Configuración de trabajo
    service_zones TEXT[] DEFAULT '{}', -- Provincias donde trabaja
    max_delivery_weight DECIMAL(8,3) DEFAULT 20.0,
    max_delivery_distance INTEGER DEFAULT 50, -- En kilómetros
    available_schedule JSONB DEFAULT '{}', -- Horarios disponibles
    
    -- Estado y estadísticas
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_available BOOLEAN DEFAULT TRUE,
    verification_date TIMESTAMP WITH TIME ZONE,
    rating_average DECIMAL(3,2) DEFAULT 0.0,
    total_ratings INTEGER DEFAULT 0,
    total_deliveries INTEGER DEFAULT 0,
    successful_deliveries INTEGER DEFAULT 0,
    
    -- Configuración de comisiones
    commission_per_delivery DECIMAL(8,2) DEFAULT 5.00,
    commission_percentage DECIMAL(5,2) DEFAULT 15.00,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de asignaciones de entrega
CREATE TABLE IF NOT EXISTS delivery_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    delivery_id UUID NOT NULL REFERENCES delivery_profiles(id),
    vendor_id UUID REFERENCES vendor_profiles(id),
    
    -- Información de la entrega
    pickup_address JSONB NOT NULL,
    delivery_address JSONB NOT NULL,
    estimated_distance DECIMAL(8,2), -- En kilómetros
    estimated_duration INTEGER, -- En minutos
    
    -- Estados de la entrega
    status TEXT DEFAULT 'assigned' CHECK (status IN ('assigned', 'accepted', 'pickup_in_progress', 'picked_up', 'in_transit', 'delivered', 'cancelled')),
    
    -- Tiempos importantes
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,
    pickup_started_at TIMESTAMP WITH TIME ZONE,
    picked_up_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    
    -- Información de entrega
    delivery_photo_url TEXT,
    delivery_notes TEXT,
    recipient_name TEXT,
    recipient_phone TEXT,
    
    -- Comisiones
    delivery_fee DECIMAL(8,2) NOT NULL,
    delivery_commission DECIMAL(8,2) NOT NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de ubicaciones en tiempo real
CREATE TABLE IF NOT EXISTS delivery_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_id UUID NOT NULL REFERENCES delivery_profiles(id),
    assignment_id UUID REFERENCES delivery_assignments(id),
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    accuracy DECIMAL(8,2),
    speed DECIMAL(8,2),
    heading DECIMAL(6,2),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🎯 **FASE 4: SISTEMA DE AMAZON COMPLETO**

### 4.1 Productos y gestión de Amazon

```sql
-- Tabla de productos de Amazon
CREATE TABLE IF NOT EXISTS amazon_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asin TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2),
    currency TEXT DEFAULT 'USD',
    
    -- Información física del producto
    weight DECIMAL(8,3), -- En kilogramos
    dimensions_length DECIMAL(8,2), -- En centímetros
    dimensions_width DECIMAL(8,2),
    dimensions_height DECIMAL(8,2),
    package_weight DECIMAL(8,3),
    
    -- Categorización
    category TEXT,
    subcategory TEXT,
    brand TEXT,
    model TEXT,
    
    -- Imágenes y medios
    main_image_url TEXT,
    additional_images TEXT[] DEFAULT '{}',
    
    -- Disponibilidad y stock
    availability TEXT,
    is_prime BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    
    -- Calificaciones y reseñas
    rating DECIMAL(3,2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    
    -- Configuración de envío
    amazon_shipping_cost DECIMAL(8,2) DEFAULT 0.00,
    estimated_delivery_days INTEGER DEFAULT 21,
    
    -- Metadatos
    features TEXT[] DEFAULT '{}',
    variants JSONB DEFAULT '{}',
    raw_data JSONB DEFAULT '{}',
    
    -- Control de estado
    is_active BOOLEAN DEFAULT TRUE,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de configuración de Amazon
CREATE TABLE IF NOT EXISTS amazon_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Márgenes y comisiones
    markup_percentage DECIMAL(5,2) DEFAULT 25.00,
    commission_percentage DECIMAL(5,2) DEFAULT 20.00,
    
    -- Configuración de envío
    base_shipping_cost DECIMAL(8,2) DEFAULT 15.00,
    weight_multiplier DECIMAL(8,3) DEFAULT 2.50, -- Costo por kg adicional
    
    -- Límites de peso y dimensiones
    max_weight DECIMAL(8,3) DEFAULT 30.0,
    max_dimension DECIMAL(8,2) DEFAULT 100.0,
    
    -- Restricciones
    restricted_categories TEXT[] DEFAULT '{}',
    blocked_keywords TEXT[] DEFAULT '{}',
    
    -- Configuración de API
    api_rate_limit INTEGER DEFAULT 100,
    cache_duration INTEGER DEFAULT 3600, -- En segundos
    
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de historial de precios de Amazon
CREATE TABLE IF NOT EXISTS amazon_price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES amazon_products(id) ON DELETE CASCADE,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2),
    availability TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🎯 **FASE 5: SISTEMA DE PESOS Y CÁLCULOS DE ENVÍO**

### 5.1 Configuración de pesos y dimensiones

```sql
-- Tabla de configuración de envío por peso
CREATE TABLE IF NOT EXISTS shipping_weight_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Rangos de peso (en kilogramos)
    weight_from DECIMAL(8,3) NOT NULL,
    weight_to DECIMAL(8,3) NOT NULL,
    
    -- Costos por método de envío
    express_cost DECIMAL(8,2) NOT NULL,
    maritime_cost DECIMAL(8,2) NOT NULL,
    
    -- Tiempos de entrega (en días)
    express_days INTEGER DEFAULT 3,
    maritime_days INTEGER DEFAULT 30,
    
    -- Restricciones
    is_active BOOLEAN DEFAULT TRUE,
    applies_to_zones TEXT[] DEFAULT '{}', -- Provincias donde aplica
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de configuración de envío por dimensiones
CREATE TABLE IF NOT EXISTS shipping_dimension_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Límites de dimensiones (en centímetros)
    max_length DECIMAL(8,2) NOT NULL,
    max_width DECIMAL(8,2) NOT NULL,
    max_height DECIMAL(8,2) NOT NULL,
    
    -- Factor volumétrico
    volumetric_factor DECIMAL(8,3) DEFAULT 5000.0,
    
    -- Costos adicionales por volumen
    volume_surcharge DECIMAL(8,2) DEFAULT 0.00,
    
    -- Método de envío aplicable
    shipping_method TEXT NOT NULL CHECK (shipping_method IN ('express', 'maritime', 'self_delivery')),
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de zonas de envío y sus configuraciones
CREATE TABLE IF NOT EXISTS shipping_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_name TEXT UNIQUE NOT NULL,
    provinces TEXT[] NOT NULL DEFAULT '{}',
    
    -- Multiplicadores de costo por zona
    express_multiplier DECIMAL(5,3) DEFAULT 1.0,
    maritime_multiplier DECIMAL(5,3) DEFAULT 1.0,
    self_delivery_multiplier DECIMAL(5,3) DEFAULT 1.0,
    
    -- Límites especiales por zona
    max_weight_express DECIMAL(8,3) DEFAULT 20.0,
    max_weight_maritime DECIMAL(8,3) DEFAULT 1000.0,
    
    -- Tiempos adicionales por zona
    express_additional_days INTEGER DEFAULT 0,
    maritime_additional_days INTEGER DEFAULT 0,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🎯 **FASE 6: TIPOS Y MÉTODOS DE ENVÍO CON REGLAS**

### 6.1 Sistema completo de métodos de envío

```sql
-- Tabla principal de métodos de envío
CREATE TABLE IF NOT EXISTS shipping_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL, -- 'express_system', 'express_vendor', 'maritime', 'self_delivery'
    name TEXT NOT NULL,
    description TEXT,
    
    -- Configuración base
    base_cost DECIMAL(8,2) DEFAULT 0.00,
    cost_per_kg DECIMAL(8,2) DEFAULT 0.00,
    cost_per_km DECIMAL(8,2) DEFAULT 0.00,
    
    -- Límites físicos
    max_weight DECIMAL(8,3) DEFAULT 1000.0,
    max_length DECIMAL(8,2) DEFAULT 200.0,
    max_width DECIMAL(8,2) DEFAULT 200.0,
    max_height DECIMAL(8,2) DEFAULT 200.0,
    
    -- Tiempos de entrega
    min_delivery_days INTEGER DEFAULT 1,
    max_delivery_days INTEGER DEFAULT 30,
    
    -- Disponibilidad
    available_zones TEXT[] DEFAULT '{}',
    restricted_categories TEXT[] DEFAULT '{}',
    
    -- Configuración especial
    requires_vendor_approval BOOLEAN DEFAULT FALSE,
    requires_delivery_assignment BOOLEAN DEFAULT FALSE,
    allows_tracking BOOLEAN DEFAULT TRUE,
    requires_photo_proof BOOLEAN DEFAULT FALSE,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de reglas de envío
CREATE TABLE IF NOT EXISTS shipping_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name TEXT NOT NULL,
    rule_type TEXT NOT NULL CHECK (rule_type IN ('weight', 'dimension', 'zone', 'category', 'vendor', 'product')),
    
    -- Condiciones
    condition_field TEXT NOT NULL, -- 'weight', 'total_volume', 'province', 'category_id', etc.
    condition_operator TEXT NOT NULL CHECK (condition_operator IN ('eq', 'ne', 'gt', 'lt', 'gte', 'lte', 'in', 'not_in')),
    condition_value TEXT NOT NULL, -- Valor a comparar (JSON para arrays)
    
    -- Acciones
    action_type TEXT NOT NULL CHECK (action_type IN ('restrict_method', 'add_surcharge', 'set_cost', 'set_days', 'require_approval')),
    action_value DECIMAL(10,2), -- Valor numérico para costos/días
    action_methods TEXT[] DEFAULT '{}', -- Métodos afectados
    
    -- Prioridad y estado
    priority INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de cálculos de envío por orden
CREATE TABLE IF NOT EXISTS order_shipping_calculations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    
    -- Información calculada
    total_weight DECIMAL(8,3) NOT NULL,
    total_volume DECIMAL(10,3) NOT NULL,
    volumetric_weight DECIMAL(8,3) NOT NULL,
    billable_weight DECIMAL(8,3) NOT NULL, -- Mayor entre peso real y volumétrico
    
    -- Métodos disponibles calculados
    available_methods JSONB NOT NULL DEFAULT '[]',
    selected_method TEXT,
    
    -- Costos desglosados
    base_shipping_cost DECIMAL(8,2) DEFAULT 0.00,
    weight_surcharge DECIMAL(8,2) DEFAULT 0.00,
    zone_surcharge DECIMAL(8,2) DEFAULT 0.00,
    dimension_surcharge DECIMAL(8,2) DEFAULT 0.00,
    vendor_surcharge DECIMAL(8,2) DEFAULT 0.00,
    total_shipping_cost DECIMAL(8,2) NOT NULL,
    
    -- Metadatos del cálculo
    calculation_rules JSONB DEFAULT '{}',
    calculation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🎯 **FASE 7: SISTEMA DE ÓRDENES EXTENDIDO**

### 7.1 Actualizar tabla de órdenes con toda la lógica

```sql
-- Extender tabla orders existente
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
ADD COLUMN IF NOT EXISTS shipping_calculation_id UUID REFERENCES order_shipping_calculations(id);

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS delivery_assignment_id UUID REFERENCES delivery_assignments(id);

-- Estados más específicos
ALTER TABLE orders 
DROP CONSTRAINT IF EXISTS orders_order_status_check;

ALTER TABLE orders 
ADD CONSTRAINT orders_order_status_check CHECK (order_status IN (
    'created', 'payment_pending', 'payment_confirmed', 'processing', 
    'vendor_processing', 'ready_for_pickup', 'assigned_to_delivery', 
    'pickup_in_progress', 'in_transit', 'out_for_delivery', 'delivered', 
    'cancelled', 'refunded'
));

-- Tabla de ítems de orden extendida
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    
    -- Información del producto
    product_type TEXT NOT NULL CHECK (product_type IN ('store', 'amazon', 'vendor')),
    product_id UUID, -- Referencias a store_products, amazon_products, vendor_products
    vendor_product_id UUID REFERENCES vendor_products(id),
    amazon_product_id UUID REFERENCES amazon_products(id),
    
    -- Detalles del ítem
    name TEXT NOT NULL,
    description TEXT,
    sku TEXT,
    asin TEXT, -- Para productos de Amazon
    
    -- Precios y cantidades
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    total_price DECIMAL(10,2) NOT NULL,
    
    -- Información física
    unit_weight DECIMAL(8,3) DEFAULT 0.0,
    unit_dimensions JSONB DEFAULT '{}',
    total_weight DECIMAL(8,3) DEFAULT 0.0,
    total_volume DECIMAL(10,3) DEFAULT 0.0,
    
    -- Personalización
    selected_size TEXT,
    selected_color TEXT,
    custom_options JSONB DEFAULT '{}',
    
    -- Estado individual del ítem
    item_status TEXT DEFAULT 'pending' CHECK (item_status IN ('pending', 'processing', 'ready', 'shipped', 'delivered', 'cancelled')),
    
    -- Vendedor asignado (si aplica)
    assigned_vendor_id UUID REFERENCES vendor_profiles(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🎯 **FASE 8: SISTEMA DE NOTIFICACIONES Y COMUNICACIÓN EXTENDIDO**

### 8.1 Notificaciones específicas por rol

```sql
-- Extender tabla notifications
ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS recipient_role TEXT CHECK (recipient_role IN ('usuario', 'vendor', 'delivery', 'admin'));

ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent'));

ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS requires_sound BOOLEAN DEFAULT FALSE;

ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS action_required BOOLEAN DEFAULT FALSE;

ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS related_order_id UUID REFERENCES orders(id);

ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE;

-- Tabla de configuración de notificaciones por rol
CREATE TABLE IF NOT EXISTS notification_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_role TEXT NOT NULL CHECK (user_role IN ('usuario', 'vendor', 'delivery', 'admin')),
    notification_type TEXT NOT NULL,
    
    -- Configuración de entrega
    push_enabled BOOLEAN DEFAULT TRUE,
    sound_enabled BOOLEAN DEFAULT TRUE,
    popup_enabled BOOLEAN DEFAULT FALSE, -- Para vendedores/repartidores
    email_enabled BOOLEAN DEFAULT FALSE,
    
    -- Configuración de sonido
    sound_priority TEXT DEFAULT 'normal' CHECK (sound_priority IN ('low', 'normal', 'high', 'urgent')),
    can_override_silent BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_role, notification_type)
);
```

## 🎯 **FASE 9: SISTEMA DE CALIFICACIONES Y RESEÑAS**

### 9.1 Calificaciones completas

```sql
-- Tabla de calificaciones
CREATE TABLE IF NOT EXISTS ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Entidad calificada
    rated_type TEXT NOT NULL CHECK (rated_type IN ('vendor', 'delivery')),
    rated_vendor_id UUID REFERENCES vendor_profiles(id),
    rated_delivery_id UUID REFERENCES delivery_profiles(id),
    
    -- Calificaciones por categoría
    overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),
    quality_rating INTEGER CHECK (quality_rating >= 1 AND quality_rating <= 5),
    service_rating INTEGER CHECK (service_rating >= 1 AND service_rating <= 5),
    communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
    
    -- Comentarios
    comment TEXT,
    anonymous BOOLEAN DEFAULT FALSE,
    
    -- Estado
    is_verified BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Un usuario solo puede calificar una vez por orden
    UNIQUE(order_id, user_id, rated_type)
);

-- Tabla de respuestas a calificaciones
CREATE TABLE IF NOT EXISTS rating_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rating_id UUID NOT NULL REFERENCES ratings(id) ON DELETE CASCADE,
    responder_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    response_text TEXT NOT NULL,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Solo una respuesta por calificación
    UNIQUE(rating_id)
);
```

## 🎯 **FASE 10: TRIGGERS Y FUNCIONES AUTOMÁTICAS**

### 10.1 Triggers para automatización

```sql
-- Función para actualizar promedios de calificación
CREATE OR REPLACE FUNCTION update_rating_averages()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar promedio de vendedor
    IF NEW.rated_vendor_id IS NOT NULL THEN
        UPDATE vendor_profiles 
        SET 
            rating_average = (
                SELECT AVG(overall_rating::DECIMAL) 
                FROM ratings 
                WHERE rated_vendor_id = NEW.rated_vendor_id
            ),
            total_ratings = (
                SELECT COUNT(*) 
                FROM ratings 
                WHERE rated_vendor_id = NEW.rated_vendor_id
            )
        WHERE id = NEW.rated_vendor_id;
        
        -- También actualizar en la tabla users
        UPDATE users 
        SET 
            rating_average = (
                SELECT rating_average 
                FROM vendor_profiles 
                WHERE id = NEW.rated_vendor_id
            ),
            total_ratings = (
                SELECT total_ratings 
                FROM vendor_profiles 
                WHERE id = NEW.rated_vendor_id
            )
        WHERE vendor_id = NEW.rated_vendor_id;
    END IF;
    
    -- Actualizar promedio de repartidor
    IF NEW.rated_delivery_id IS NOT NULL THEN
        UPDATE delivery_profiles 
        SET 
            rating_average = (
                SELECT AVG(overall_rating::DECIMAL) 
                FROM ratings 
                WHERE rated_delivery_id = NEW.rated_delivery_id
            ),
            total_ratings = (
                SELECT COUNT(*) 
                FROM ratings 
                WHERE rated_delivery_id = NEW.rated_delivery_id
            )
        WHERE id = NEW.rated_delivery_id;
        
        -- También actualizar en la tabla users
        UPDATE users 
        SET 
            rating_average = (
                SELECT rating_average 
                FROM delivery_profiles 
                WHERE id = NEW.rated_delivery_id
            ),
            total_ratings = (
                SELECT total_ratings 
                FROM delivery_profiles 
                WHERE id = NEW.rated_delivery_id
            )
        WHERE delivery_id = NEW.rated_delivery_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar calificaciones
CREATE TRIGGER trigger_update_rating_averages
    AFTER INSERT ON ratings
    FOR EACH ROW
    EXECUTE FUNCTION update_rating_averages();

-- Función para calcular pesos y volúmenes automáticamente
CREATE OR REPLACE FUNCTION calculate_order_dimensions()
RETURNS TRIGGER AS $$
DECLARE
    calc_weight DECIMAL(8,3) := 0;
    calc_volume DECIMAL(10,3) := 0;
BEGIN
    -- Calcular peso y volumen total de la orden
    SELECT 
        COALESCE(SUM(total_weight), 0),
        COALESCE(SUM(total_volume), 0)
    INTO calc_weight, calc_volume
    FROM order_items 
    WHERE order_id = NEW.order_id;
    
    -- Actualizar la orden
    UPDATE orders 
    SET 
        total_weight = calc_weight,
        total_volume = calc_volume,
        updated_at = NOW()
    WHERE id = NEW.order_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para recalcular dimensiones
CREATE TRIGGER trigger_calculate_order_dimensions
    AFTER INSERT OR UPDATE OR DELETE ON order_items
    FOR EACH ROW
    EXECUTE FUNCTION calculate_order_dimensions();

-- Función para crear notificaciones automáticas
CREATE OR REPLACE FUNCTION create_order_notifications()
RETURNS TRIGGER AS $$
BEGIN
    -- Notificación al usuario cuando cambia el estado
    INSERT INTO notifications (user_id, type, title, message, related_order_id, recipient_role)
    VALUES (
        NEW.user_id,
        'order_status_change',
        'Estado de pedido actualizado',
        'Tu pedido #' || NEW.order_number || ' ha cambiado a: ' || NEW.order_status,
        NEW.id,
        'usuario'
    );
    
    -- Notificaciones específicas por estado
    CASE NEW.order_status
        WHEN 'vendor_processing' THEN
            -- Notificar al vendedor
            IF NEW.vendor_id IS NOT NULL THEN
                INSERT INTO notifications (user_id, type, title, message, related_order_id, recipient_role, requires_sound, priority)
                SELECT 
                    vp.user_id,
                    'new_order',
                    'Nuevo pedido recibido',
                    'Tienes un nuevo pedido #' || NEW.order_number || ' que requiere procesamiento',
                    NEW.id,
                    'vendor',
                    true,
                    'high'
                FROM vendor_profiles vp 
                WHERE vp.id = NEW.vendor_id;
            END IF;
            
        WHEN 'assigned_to_delivery' THEN
            -- Notificar al repartidor
            IF NEW.delivery_id IS NOT NULL THEN
                INSERT INTO notifications (user_id, type, title, message, related_order_id, recipient_role, requires_sound, priority)
                SELECT 
                    dp.user_id,
                    'delivery_assignment',
                    'Nueva entrega asignada',
                    'Se te ha asignado la entrega del pedido #' || NEW.order_number,
                    NEW.id,
                    'delivery',
                    true,
                    'high'
                FROM delivery_profiles dp 
                WHERE dp.id = NEW.delivery_id;
            END IF;
    END CASE;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para notificaciones automáticas
CREATE TRIGGER trigger_create_order_notifications
    AFTER UPDATE OF order_status ON orders
    FOR EACH ROW
    EXECUTE FUNCTION create_order_notifications();
```

## 🎯 **FASE 11: ÍNDICES PARA OPTIMIZACIÓN**

### 11.1 Índices críticos para rendimiento

```sql
-- Índices para tablas de vendedores
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_user_id ON vendor_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_verified ON vendor_profiles(is_verified);
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_active ON vendor_profiles(is_active);
CREATE INDEX IF NOT EXISTS idx_vendor_products_vendor_id ON vendor_products(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_products_category_id ON vendor_products(category_id);
CREATE INDEX IF NOT EXISTS idx_vendor_products_approval_status ON vendor_products(approval_status);
CREATE INDEX IF NOT EXISTS idx_vendor_products_active ON vendor_products(is_active);

-- Índices para tablas de repartidores
CREATE INDEX IF NOT EXISTS idx_delivery_profiles_user_id ON delivery_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_delivery_profiles_verified ON delivery_profiles(is_verified);
CREATE INDEX IF NOT EXISTS idx_delivery_profiles_available ON delivery_profiles(is_available);
CREATE INDEX IF NOT EXISTS idx_delivery_assignments_order_id ON delivery_assignments(order_id);
CREATE INDEX IF NOT EXISTS idx_delivery_assignments_delivery_id ON delivery_assignments(delivery_id);
CREATE INDEX IF NOT EXISTS idx_delivery_assignments_status ON delivery_assignments(status);

-- Índices para Amazon
CREATE INDEX IF NOT EXISTS idx_amazon_products_asin ON amazon_products(asin);
CREATE INDEX IF NOT EXISTS idx_amazon_products_category ON amazon_products(category);
CREATE INDEX IF NOT EXISTS idx_amazon_products_active ON amazon_products(is_available);
CREATE INDEX IF NOT EXISTS idx_amazon_products_weight ON amazon_products(weight);

-- Índices para órdenes
CREATE INDEX IF NOT EXISTS idx_orders_vendor_id ON orders(vendor_id);
CREATE INDEX IF NOT EXISTS idx_orders_delivery_id ON orders(delivery_id);
CREATE INDEX IF NOT EXISTS idx_orders_source_type ON orders(source_type);
CREATE INDEX IF NOT EXISTS idx_orders_status_created ON orders(order_status, created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_type ON order_items(product_type);

-- Índices para notificaciones
CREATE INDEX IF NOT EXISTS idx_notifications_user_role ON notifications(user_id, recipient_role);
CREATE INDEX IF NOT EXISTS idx_notifications_read_created ON notifications(read, created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_type_priority ON notifications(type, priority);

-- Índices para calificaciones
CREATE INDEX IF NOT EXISTS idx_ratings_order_id ON ratings(order_id);
CREATE INDEX IF NOT EXISTS idx_ratings_vendor_id ON ratings(rated_vendor_id);
CREATE INDEX IF NOT EXISTS idx_ratings_delivery_id ON ratings(rated_delivery_id);
CREATE INDEX IF NOT EXISTS idx_ratings_created ON ratings(created_at);

-- Índices para envío
CREATE INDEX IF NOT EXISTS idx_shipping_weight_config_range ON shipping_weight_config(weight_from, weight_to);
CREATE INDEX IF NOT EXISTS idx_shipping_zones_provinces ON shipping_zones USING GIN(provinces);
CREATE INDEX IF NOT EXISTS idx_order_shipping_calculations_order ON order_shipping_calculations(order_id);
```

## 🎯 **FASE 12: DATOS INICIALES Y CONFIGURACIÓN**

### 12.1 Insertar datos de configuración inicial

```sql
-- Insertar métodos de envío por defecto
INSERT INTO shipping_methods (code, name, description, base_cost, cost_per_kg, max_weight, min_delivery_days, max_delivery_days, requires_delivery_assignment) VALUES
('express_system', 'Envío Express (Sistema)', 'Entrega rápida gestionada por el sistema con repartidores de la app', 5.00, 2.50, 20.0, 1, 3, true),
('express_vendor', 'Envío Express (Vendedor)', 'Entrega rápida donde el vendedor usa repartidores de la app', 3.00, 2.00, 20.0, 1, 3, true),
('maritime', 'Envío Marítimo', 'Envío económico por barco para productos pesados', 15.00, 1.50, 1000.0, 21, 35, false),
('self_delivery', 'Entrega por Vendedor', 'El vendedor entrega personalmente el producto', 0.00, 0.00, 50.0, 1, 2, false)
ON CONFLICT (code) DO NOTHING;

-- Insertar rangos de peso por defecto
INSERT INTO shipping_weight_config (weight_from, weight_to, express_cost, maritime_cost, express_days, maritime_days) VALUES
(0.0, 1.0, 5.00, 15.00, 2, 25),
(1.1, 5.0, 8.00, 18.00, 2, 25),
(5.1, 10.0, 12.00, 22.00, 3, 28),
(10.1, 20.0, 18.00, 28.00, 3, 30),
(20.1, 50.0, 25.00, 35.00, 4, 32),
(50.1, 1000.0, 40.00, 50.00, 5, 35)
ON CONFLICT DO NOTHING;

-- Insertar zonas de envío de Cuba
INSERT INTO shipping_zones (zone_name, provinces, express_multiplier, maritime_multiplier) VALUES
('La Habana', ARRAY['La Habana'], 1.0, 1.0),
('Occidente', ARRAY['Pinar del Río', 'Artemisa', 'Mayabeque'], 1.2, 1.1),
('Centro', ARRAY['Matanzas', 'Villa Clara', 'Cienfuegos', 'Sancti Spíritus'], 1.3, 1.1),
('Centro-Este', ARRAY['Ciego de Ávila', 'Camagüey'], 1.4, 1.2),
('Oriente', ARRAY['Las Tunas', 'Granma', 'Holguín', 'Santiago de Cuba', 'Guantánamo'], 1.5, 1.2),
('Isla de la Juventud', ARRAY['Isla de la Juventud'], 2.0, 1.5)
ON CONFLICT (zone_name) DO NOTHING;

-- Insertar configuración de notificaciones por defecto
INSERT INTO notification_config (user_role, notification_type, push_enabled, sound_enabled, popup_enabled, can_override_silent) VALUES
-- Usuarios normales
('usuario', 'order_status_change', true, false, false, false),
('usuario', 'payment_confirmation', true, true, false, false),
('usuario', 'delivery_update', true, true, false, false),

-- Vendedores
('vendor', 'new_order', true, true, true, true),
('vendor', 'order_delayed', true, true, true, true),
('vendor', 'payment_received', true, true, false, false),
('vendor', 'system_alert', true, true, true, true),

-- Repartidores
('delivery', 'delivery_assignment', true, true, true, true),
('delivery', 'pickup_ready', true, true, true, true),
('delivery', 'route_update', true, true, false, false),
('delivery', 'system_alert', true, true, true, true),

-- Administradores
('admin', 'system_error', true, true, true, true),
('admin', 'payment_issue', true, true, true, true),
('admin', 'user_report', true, false, false, false)
ON CONFLICT (user_role, notification_type) DO NOTHING;

-- Insertar configuración de Amazon por defecto
INSERT INTO amazon_config (markup_percentage, commission_percentage, base_shipping_cost, weight_multiplier, max_weight) VALUES
(25.00, 20.00, 15.00, 2.50, 30.0)
ON CONFLICT DO NOTHING;
```

---

## 📝 **RESUMEN DE IMPLEMENTACIÓN**

### ✅ **ORDEN DE EJECUCIÓN:**
1. **FASE 1-2**: Usuarios y Vendedores
2. **FASE 3**: Repartidores  
3. **FASE 4**: Amazon
4. **FASE 5-6**: Pesos y Envíos
5. **FASE 7**: Órdenes extendidas
6. **FASE 8-9**: Notificaciones y Calificaciones
7. **FASE 10**: Triggers automáticos
8. **FASE 11-12**: Optimización y datos iniciales

### 🎯 **FUNCIONALIDADES CUBIERTAS:**
- ✅ Sistema completo de vendedores con productos y configuración
- ✅ Sistema completo de repartidores con asignaciones y tracking
- ✅ Integración total de Amazon con cálculos automáticos
- ✅ Sistema de pesos y dimensiones con reglas automáticas
- ✅ Métodos de envío con todas las reglas de negocio
- ✅ Calificaciones y reseñas por categorías
- ✅ Notificaciones específicas por rol con sonidos
- ✅ Triggers automáticos para cálculos y notificaciones
- ✅ Optimización completa con índices

**¿Comenzamos con la implementación fase por fase?**




