# 🔧 INSTRUCCIONES PARA AGREGAR COLUMNAS FALTANTES EN SUPABASE

## 🎯 PROBLEMA IDENTIFICADO
Los nuevos campos (peso, envío, etiquetas) no se pueden guardar porque las columnas no existen en la tabla `store_products` de Supabase.

## 📋 PASOS PARA SOLUCIONAR

### PASO 1: Acceder al SQL Editor de Supabase
1. Ve a [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Inicia sesión con tu cuenta
3. Selecciona tu proyecto: `zgqrhzuhrwudckwesybg`
4. En el menú lateral, haz clic en **"SQL Editor"**

### PASO 2: Ejecutar el Script SQL
Copia y pega este código SQL en el editor:

```sql
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
```

### PASO 3: Ejecutar el Script
1. Haz clic en **"Run"** o presiona `Ctrl+Enter`
2. Deberías ver mensajes de éxito para cada comando
3. Si hay errores, cópialos y envíalos

### PASO 4: Verificar las Columnas
Después de ejecutar el script, verifica que las columnas se agregaron:

1. Ve a **"Table Editor"** en el menú lateral
2. Selecciona la tabla **"store_products"**
3. Verifica que aparezcan estas columnas:
   - ✅ `subcategory` (TEXT)
   - ✅ `weight` (DECIMAL)
   - ✅ `shipping_cost` (DECIMAL)
   - ✅ `shipping_methods` (JSONB)
   - ✅ `tags` (JSONB)

## 🧪 PROBAR DESPUÉS DE AGREGAR COLUMNAS

Una vez agregadas las columnas, ejecuta este comando para probar:

```bash
python3 test_new_fields.py
```

Deberías ver:
- ✅ Lectura de campos: OK
- ✅ Creación con nuevos campos: OK
- ✅ Actualización con nuevos campos: OK

## 🔍 VERIFICAR EN EL PANEL ADMIN

1. Ve a [https://cubalink23-backend.onrender.com/admin/products](https://cubalink23-backend.onrender.com/admin/products)
2. Haz clic en **"Agregar Producto"**
3. Llena todos los campos incluyendo:
   - Peso (ej: 25.5)
   - Precio de envío adicional (ej: 15.00)
   - Etiquetas (selecciona algunas)
4. Haz clic en **"Agregar Producto"**
5. Verifica que el producto aparezca en la tabla con todos los campos

## 🚨 SOLUCIÓN ALTERNATIVA

Si no puedes ejecutar el SQL, puedes agregar las columnas una por una:

1. Ve a **"Table Editor"** > **"store_products"**
2. Haz clic en **"Add Column"**
3. Agrega cada columna con estos datos:

### Columna 1: subcategory
- **Name**: `subcategory`
- **Type**: `text`
- **Default value**: (dejar vacío)

### Columna 2: weight
- **Name**: `weight`
- **Type**: `numeric`
- **Default value**: (dejar vacío)

### Columna 3: shipping_cost
- **Name**: `shipping_cost`
- **Type**: `numeric`
- **Default value**: `0`

### Columna 4: shipping_methods
- **Name**: `shipping_methods`
- **Type**: `jsonb`
- **Default value**: `[]`

### Columna 5: tags
- **Name**: `tags`
- **Type**: `jsonb`
- **Default value**: `[]`

## 📞 SOPORTE

Si tienes problemas:
1. Verifica que tengas permisos de administrador en Supabase
2. Asegúrate de que la tabla se llame exactamente `store_products`
3. Revisa que no haya errores de sintaxis en el SQL
4. Ejecuta el script de prueba para verificar

---

**Una vez completado, el panel admin podrá guardar y mostrar peso, envío y etiquetas correctamente.**
