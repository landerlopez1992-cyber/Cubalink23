-- Verificar si la tabla notifications ya existe en Supabase
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'notifications' 
ORDER BY ordinal_position;

-- Si la tabla existe, mostrar su estructura
-- Si no existe, mostrar mensaje
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'notifications'
        ) 
        THEN '✅ La tabla "notifications" YA EXISTE'
        ELSE '❌ La tabla "notifications" NO EXISTE - Necesitas crearla'
    END as status;