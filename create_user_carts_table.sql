-- Crear tabla user_carts para persistir carritos por usuario
CREATE TABLE IF NOT EXISTS public.user_carts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    items JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id)
);

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_user_carts_user_id ON public.user_carts(user_id);
CREATE INDEX IF NOT EXISTS idx_user_carts_updated_at ON public.user_carts(updated_at);

-- Habilitar Row Level Security (RLS)
ALTER TABLE public.user_carts ENABLE ROW LEVEL SECURITY;

-- Política RLS: Los usuarios solo pueden ver/editar su propio carrito
CREATE POLICY "Users can manage their own cart" ON public.user_carts
    FOR ALL USING (auth.uid() = user_id);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar updated_at automáticamente
CREATE TRIGGER update_user_carts_updated_at 
    BEFORE UPDATE ON public.user_carts 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();