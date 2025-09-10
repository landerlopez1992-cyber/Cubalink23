-- 🔒 POLÍTICAS DE SEGURIDAD PARA BUCKET 'user-profiles'
-- Configuración de Row Level Security para fotos de perfil

-- ==================== POLÍTICAS PARA STORAGE.OBJECTS ====================

-- 1. Lectura pública para todas las fotos de perfil
CREATE POLICY "Profile images are publicly accessible" ON storage.objects
FOR SELECT USING (bucket_id = 'user-profiles');

-- 2. Solo usuarios autenticados pueden subir sus propias fotos
CREATE POLICY "Users can upload their own profile images" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'user-profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 3. Solo usuarios pueden actualizar sus propias fotos
CREATE POLICY "Users can update their own profile images" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'user-profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 4. Solo usuarios pueden eliminar sus propias fotos  
CREATE POLICY "Users can delete their own profile images" ON storage.objects
FOR DELETE USING (
    bucket_id = 'user-profiles' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ==================== FUNCIÓN AUXILIAR PARA RUTAS ====================

-- Función para extraer el user_id de la ruta del archivo
-- Ejemplo: profiles/uuid/avatar.jpg -> uuid
CREATE OR REPLACE FUNCTION extract_user_id_from_path(file_path text)
RETURNS uuid
LANGUAGE plpgsql
AS $$
BEGIN
    -- Extraer UUID de la ruta profiles/uuid/filename
    RETURN (regexp_split_to_array(file_path, '/'))[2]::uuid;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$;

-- ==================== POLÍTICA MEJORADA USANDO LA FUNCIÓN ====================

-- Reemplazar políticas existentes con función personalizada (opcional)
/*
DROP POLICY IF EXISTS "Users can upload their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile images" ON storage.objects;

CREATE POLICY "Users can upload their own profile images v2" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'user-profiles' 
    AND auth.uid() = extract_user_id_from_path(name)
);

CREATE POLICY "Users can update their own profile images v2" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'user-profiles' 
    AND auth.uid() = extract_user_id_from_path(name)
);

CREATE POLICY "Users can delete their own profile images v2" ON storage.objects
FOR DELETE USING (
    bucket_id = 'user-profiles' 
    AND auth.uid() = extract_user_id_from_path(name)
);
*/

-- ==================== VERIFICACIÓN DE CONFIGURACIÓN ====================

-- Ver todas las políticas del bucket user-profiles
-- SELECT policyname, roles, cmd, qual FROM pg_policies 
-- WHERE schemaname = 'storage' AND tablename = 'objects' 
-- AND qual LIKE '%user-profiles%';

-- ==================== NOTAS IMPORTANTES ====================

/*
🔐 ESTRUCTURA DE ARCHIVOS ESPERADA:
   - Bucket: user-profiles
   - Ruta: profiles/{user_id}/avatar_{timestamp}.jpg
   - Ejemplo: profiles/550e8400-e29b-41d4-a716-446655440000/avatar_1234567890.jpg

🛡️ SEGURIDAD:
   - Solo lectura pública para mostrar fotos
   - Solo el dueño puede subir/modificar/eliminar su foto
   - La validación se hace por UUID en la ruta del archivo

📱 USO EN LA APP:
   - ProfileImageService maneja automáticamente las rutas
   - Las políticas RLS se aplican automáticamente
   - No se requiere validación adicional en el código
*/



