-- Agregar columna profile_image_url faltante en tabla users
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_image_url TEXT;

-- Comentario para documentar la columna
COMMENT ON COLUMN users.profile_image_url IS 'URL de la imagen de perfil del usuario';


