-- Crear tabla para almacenar los "Me gusta" de los usuarios
CREATE TABLE IF NOT EXISTS user_likes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id TEXT NOT NULL,
    product_name TEXT NOT NULL,
    product_image_url TEXT,
    product_price DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Evitar duplicados: un usuario solo puede dar like una vez al mismo producto
    UNIQUE(user_id, product_id)
);

-- Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_user_likes_user_id ON user_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_user_likes_product_id ON user_likes(product_id);
CREATE INDEX IF NOT EXISTS idx_user_likes_created_at ON user_likes(created_at DESC);

-- Habilitar Row Level Security (RLS)
ALTER TABLE user_likes ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios solo pueden ver sus propios likes
CREATE POLICY "Users can view their own likes" ON user_likes
    FOR SELECT USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden insertar sus propios likes
CREATE POLICY "Users can insert their own likes" ON user_likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios solo pueden actualizar sus propios likes
CREATE POLICY "Users can update their own likes" ON user_likes
    FOR UPDATE USING (auth.uid() = user_id);

-- Política: Los usuarios solo pueden eliminar sus propios likes
CREATE POLICY "Users can delete their own likes" ON user_likes
    FOR DELETE USING (auth.uid() = user_id);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_user_likes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar updated_at
CREATE TRIGGER trigger_update_user_likes_updated_at
    BEFORE UPDATE ON user_likes
    FOR EACH ROW
    EXECUTE FUNCTION update_user_likes_updated_at();

-- Comentarios para documentación
COMMENT ON TABLE user_likes IS 'Tabla para almacenar los productos favoritos de los usuarios';
COMMENT ON COLUMN user_likes.user_id IS 'ID del usuario que dio like';
COMMENT ON COLUMN user_likes.product_id IS 'ID único del producto';
COMMENT ON COLUMN user_likes.product_name IS 'Nombre del producto al momento del like';
COMMENT ON COLUMN user_likes.product_image_url IS 'URL de la imagen del producto al momento del like';
COMMENT ON COLUMN user_likes.product_price IS 'Precio del producto al momento del like';
