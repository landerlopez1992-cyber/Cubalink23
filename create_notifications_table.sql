-- Crear tabla de notificaciones para el sistema de historial
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    user_id TEXT NOT NULL DEFAULT 'admin',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    created_at_iso TEXT GENERATED ALWAYS AS (created_at::text) STORED
);

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_expires_at ON notifications(expires_at);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);

-- Habilitar RLS (Row Level Security)
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Política para permitir lectura a todos (para la app móvil)
CREATE POLICY "Allow read access to notifications" ON notifications
    FOR SELECT USING (true);

-- Política para permitir inserción (para el backend)
CREATE POLICY "Allow insert access to notifications" ON notifications
    FOR INSERT WITH CHECK (true);

-- Política para permitir actualización (para marcar como leídas)
CREATE POLICY "Allow update access to notifications" ON notifications
    FOR UPDATE USING (true);

-- Política para permitir eliminación (para limpieza)
CREATE POLICY "Allow delete access to notifications" ON notifications
    FOR DELETE USING (true);

-- Comentarios para documentación
COMMENT ON TABLE notifications IS 'Tabla para almacenar el historial de notificaciones push';
COMMENT ON COLUMN notifications.id IS 'ID único de la notificación';
COMMENT ON COLUMN notifications.title IS 'Título de la notificación';
COMMENT ON COLUMN notifications.message IS 'Mensaje de la notificación';
COMMENT ON COLUMN notifications.user_id IS 'ID del usuario destinatario (admin para todos)';
COMMENT ON COLUMN notifications.created_at IS 'Fecha y hora de creación';
COMMENT ON COLUMN notifications.expires_at IS 'Fecha y hora de expiración (1 mes después)';
COMMENT ON COLUMN notifications.read IS 'Indica si la notificación fue leída';
COMMENT ON COLUMN notifications.created_at_iso IS 'Fecha en formato ISO para compatibilidad con Flutter';