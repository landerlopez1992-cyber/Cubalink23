# 🔧 CONFIGURACIÓN MANUAL DE SUPABASE STORAGE

## 📋 PASOS PARA CONFIGURAR EL BUCKET `product-images`

### 1. Ir al Dashboard de Supabase
- Ve a: https://supabase.com/dashboard/project/zgqrhzuhrwudckwesybg/storage/buckets

### 2. Verificar/Crear el Bucket
- Si no existe, haz clic en **"Create bucket"**
- Nombre: `product-images`
- ✅ Marcar **"Public bucket"**
- Tamaño máximo: `50 MB`

### 3. Configurar Políticas de Acceso
Ve a la pestaña **"Policies"** del bucket y agrega estas políticas:

#### Política de Lectura Pública:
```sql
CREATE POLICY "Public read access" ON storage.objects 
FOR SELECT USING (bucket_id = 'product-images');
```

#### Política de Escritura para Usuarios Autenticados:
```sql
CREATE POLICY "Authenticated users can upload" ON storage.objects 
FOR INSERT WITH CHECK (bucket_id = 'product-images');
```

#### Política de Actualización:
```sql
CREATE POLICY "Authenticated users can update" ON storage.objects 
FOR UPDATE USING (bucket_id = 'product-images');
```

#### Política de Eliminación:
```sql
CREATE POLICY "Authenticated users can delete" ON storage.objects 
FOR DELETE USING (bucket_id = 'product-images');
```

### 4. Verificar Configuración
- Ve a: https://supabase.com/dashboard/project/zgqrhzuhrwudckwesybg/storage/buckets/product-images
- Verifica que aparezcan las políticas en la pestaña "Policies"
- Asegúrate de que el bucket esté marcado como "Public"

## 🧪 PROBAR CONFIGURACIÓN

Una vez configurado, puedes probar:

1. **Agregar un producto con imagen** desde el panel admin
2. **Verificar que la imagen se sube** al bucket
3. **Comprobar que la URL pública funciona** en la app Flutter

## 📱 URLs DE EJEMPLO

- **Bucket:** https://zgqrhzuhrwudckwesybg.supabase.co/storage/v1/object/list/product-images
- **Imagen pública:** https://zgqrhzuhrwudckwesybg.supabase.co/storage/v1/object/public/product-images/filename.jpg

## ⚠️ NOTAS IMPORTANTES

- El backend ya está configurado para usar Supabase Storage
- Las imágenes se subirán automáticamente cuando agregues productos
- Las URLs generadas serán accesibles desde la app Flutter
- Si hay problemas, revisa los logs del backend en Render.com
