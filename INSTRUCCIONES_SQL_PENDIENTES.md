# 📋 INSTRUCCIONES SQL PENDIENTES

## 🚨 IMPORTANTE: Ejecutar en Supabase SQL Editor

Las siguientes instrucciones SQL deben ejecutarse manualmente en el **SQL Editor de Supabase** para completar la implementación:

---

## 1. 🛒 SISTEMA DE APROBACIÓN DE PRODUCTOS

```sql
-- Agregar columnas de aprobación a store_products
ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approval_status VARCHAR(20) DEFAULT 'approved';

ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;

ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES users(id);

ALTER TABLE store_products 
ADD COLUMN IF NOT EXISTS approval_notes TEXT;

-- Crear índices para mejorar performance
CREATE INDEX IF NOT EXISTS idx_store_products_approval_status ON store_products(approval_status);
CREATE INDEX IF NOT EXISTS idx_store_products_vendor_approval ON store_products(vendor_id, approval_status);

-- Actualizar productos existentes para que estén aprobados
UPDATE store_products 
SET approval_status = 'approved'
WHERE approval_status IS NULL;
```

---

## 2. 🏪 PERFILES DE VENDEDOR

```sql
-- Tabla de perfiles de vendedor con fotos separadas
CREATE TABLE IF NOT EXISTS vendor_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    company_name VARCHAR NOT NULL,
    company_description TEXT,
    company_logo_url TEXT,
    store_cover_url TEXT,
    business_address TEXT,
    business_phone VARCHAR,
    business_email VARCHAR,
    categories JSONB DEFAULT '[]',
    is_verified BOOLEAN DEFAULT false,
    rating_average DECIMAL(3,2) DEFAULT 0.0,
    total_ratings INTEGER DEFAULT 0,
    total_sales INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para vendor_profiles
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_user_id ON vendor_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_verified ON vendor_profiles(is_verified);
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_rating ON vendor_profiles(rating_average);
```

---

## 3. 🚚 PERFILES DE REPARTIDOR

```sql
-- Tabla de perfiles de repartidor con foto profesional
CREATE TABLE IF NOT EXISTS delivery_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    professional_photo_url TEXT,
    vehicle_type VARCHAR,
    license_plate VARCHAR,
    phone VARCHAR,
    areas_served JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    rating_average DECIMAL(3,2) DEFAULT 0.0,
    total_ratings INTEGER DEFAULT 0,
    total_deliveries INTEGER DEFAULT 0,
    balance DECIMAL(10,2) DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para delivery_profiles
CREATE INDEX IF NOT EXISTS idx_delivery_profiles_user_id ON delivery_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_delivery_profiles_active ON delivery_profiles(is_active);
CREATE INDEX IF NOT EXISTS idx_delivery_profiles_rating ON delivery_profiles(rating_average);
```

---

## 4. ⭐ SISTEMA DE CALIFICACIONES Y REPORTES

```sql
-- Tabla de calificaciones de vendedores
CREATE TABLE IF NOT EXISTS vendor_ratings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    vendor_id UUID REFERENCES vendor_profiles(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(vendor_id, user_id)
);

-- Tabla de reportes de vendedores
CREATE TABLE IF NOT EXISTS vendor_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    vendor_id UUID REFERENCES vendor_profiles(id) ON DELETE CASCADE,
    reporter_id UUID REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID REFERENCES store_products(id) ON DELETE SET NULL,
    report_type VARCHAR NOT NULL, -- 'vendor', 'product', 'service'
    reason VARCHAR NOT NULL,
    description TEXT,
    status VARCHAR DEFAULT 'pending', -- 'pending', 'reviewed', 'resolved'
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para ratings y reports
CREATE INDEX IF NOT EXISTS idx_vendor_ratings_vendor_id ON vendor_ratings(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_ratings_user_id ON vendor_ratings(user_id);
CREATE INDEX IF NOT EXISTS idx_vendor_reports_vendor_id ON vendor_reports(vendor_id);
CREATE INDEX IF NOT EXISTS idx_vendor_reports_status ON vendor_reports(status);
```

---

## 5. 🛒 VERIFICAR/REPARAR TABLA CART_ITEMS

```sql
-- Verificar si la tabla cart_items existe y tiene las columnas correctas
-- Si falta alguna columna, agregarla:

-- Verificar estructura actual
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'cart_items';

-- Si la tabla no existe, crearla:
CREATE TABLE IF NOT EXISTS cart_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    product_id VARCHAR NOT NULL,
    product_name VARCHAR NOT NULL,
    product_price DECIMAL(10,2) NOT NULL,
    product_image_url TEXT,
    product_type VARCHAR DEFAULT 'store',
    quantity INTEGER DEFAULT 1,
    weight DECIMAL(8,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para cart_items
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON cart_items(product_id);
```

---

## 📝 NOTAS IMPORTANTES:

1. **Ejecutar en orden**: Los scripts deben ejecutarse en el orden listado
2. **Verificar errores**: Si algún comando falla, investigar la causa antes de continuar
3. **Backup**: Considera hacer un backup antes de ejecutar cambios importantes
4. **RLS (Row Level Security)**: Los permisos de RLS pueden necesitar configuración adicional

---

## ✅ VERIFICACIÓN POST-EJECUCIÓN:

Después de ejecutar el SQL, verificar que:

- [ ] La tabla `store_products` tiene las columnas de aprobación
- [ ] Las tablas `vendor_profiles` y `delivery_profiles` existen
- [ ] Las tablas `vendor_ratings` y `vendor_reports` existen
- [ ] La tabla `cart_items` tiene la estructura correcta
- [ ] Los índices se crearon correctamente

---

## 🔧 EN CASO DE PROBLEMAS:

Si hay errores al ejecutar el SQL:

1. Verificar que las tablas referenciadas (`users`, `store_products`) existen
2. Verificar permisos de la base de datos
3. Ejecutar comando por comando en lugar de todo junto
4. Revisar logs de error en Supabase Dashboard
