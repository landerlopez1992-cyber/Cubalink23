# 🔧 INSTRUCCIONES PARA CONFIGURAR BUCKET DE SUPABASE STORAGE

## 🎯 PROBLEMA ACTUAL
Las imágenes de productos no se están guardando en Supabase Storage porque el bucket `product-images` no existe o no está configurado correctamente.

## 📋 PASOS PARA SOLUCIONAR

### PASO 1: Acceder a Supabase Dashboard
1. Ve a [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Inicia sesión con tu cuenta
3. Selecciona tu proyecto: `zgqrhzuhrwudckwesybg`

### PASO 2: Crear el Bucket
1. En el menú lateral, haz clic en **"Storage"**
2. Haz clic en **"New bucket"**
3. Configura el bucket:
   - **Name**: `product-images`
   - **Public bucket**: ✅ **ACTIVAR** (muy importante)
   - **File size limit**: `50 MB`
   - **Allowed MIME types**: 
     - `image/jpeg`
     - `image/png`
     - `image/gif`
     - `image/webp`
4. Haz clic en **"Create bucket"**

### PASO 3: Configurar Políticas RLS (Row Level Security)
1. En la página del bucket `product-images`, ve a la pestaña **"Policies"**
2. Haz clic en **"New Policy"**

#### Política 1: Lectura Pública
- **Policy name**: `Public read access`
- **Policy type**: `SELECT`
- **Target roles**: `public`
- **Policy definition**:
```sql
bucket_id = 'product-images'
```
- Haz clic en **"Save"**

#### Política 2: Escritura para Usuarios Autenticados
- **Policy name**: `Authenticated users can upload`
- **Policy type**: `INSERT`
- **Target roles**: `authenticated`
- **Policy definition**:
```sql
bucket_id = 'product-images'
```
- Haz clic en **"Save"**

#### Política 3: Actualización para Usuarios Autenticados
- **Policy name**: `Authenticated users can update`
- **Policy type**: `UPDATE`
- **Target roles**: `authenticated`
- **Policy definition**:
```sql
bucket_id = 'product-images'
```
- Haz clic en **"Save"**

### PASO 4: Verificar Configuración
1. Ve a la pestaña **"Settings"** del bucket
2. Verifica que:
   - ✅ **Public bucket**: Activado
   - ✅ **File size limit**: 50 MB
   - ✅ **Allowed MIME types**: image/jpeg, image/png, image/gif, image/webp

## 🧪 PROBAR LA CONFIGURACIÓN

Después de completar los pasos anteriores, ejecuta este comando para probar:

```bash
python3 test_image_upload.py
```

Deberías ver:
- ✅ Base de datos: OK
- ✅ Bucket storage: OK  
- ✅ Subida imagen: OK

## 🔍 VERIFICAR EN EL PANEL ADMIN

1. Ve a [https://cubalink23-backend.onrender.com/admin/products](https://cubalink23-backend.onrender.com/admin/products)
2. Haz clic en **"Agregar Producto"**
3. Llena los campos básicos
4. Selecciona una imagen
5. Haz clic en **"Agregar Producto"**
6. Verifica que la imagen aparezca en la tabla

## 🚨 SOLUCIÓN ALTERNATIVA

Si no puedes crear el bucket `product-images`, el sistema automáticamente intentará usar estos buckets en orden:
1. `product-images` (preferido)
2. `images` (alternativo)
3. `public` (fallback)

Si ninguno funciona, usará un placeholder de imagen.

## 📞 SOPORTE

Si tienes problemas:
1. Verifica que el bucket sea **público**
2. Verifica que las políticas RLS estén configuradas
3. Revisa los logs del backend en Render.com
4. Ejecuta el script de prueba para diagnosticar

---

**Una vez completado, las imágenes se guardarán correctamente en Supabase Storage y se mostrarán en el panel admin y la app móvil.**