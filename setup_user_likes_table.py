#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
from supabase import create_client, Client

def setup_user_likes_table():
    """Configurar la tabla user_likes en Supabase"""
    
    # Cargar variables de entorno
    supabase_url = os.getenv('SUPABASE_URL')
    supabase_key = os.getenv('SUPABASE_ANON_KEY')
    
    if not supabase_url or not supabase_key:
        print("❌ Error: SUPABASE_URL o SUPABASE_ANON_KEY no configurados")
        return False
    
    try:
        # Crear cliente de Supabase
        supabase: Client = create_client(supabase_url, supabase_key)
        
        print("🔗 Conectando a Supabase...")
        
        # SQL para crear la tabla user_likes
        sql_script = """
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
        DROP TRIGGER IF EXISTS trigger_update_user_likes_updated_at ON user_likes;
        CREATE TRIGGER trigger_update_user_likes_updated_at
            BEFORE UPDATE ON user_likes
            FOR EACH ROW
            EXECUTE FUNCTION update_user_likes_updated_at();
        """
        
        # Ejecutar el script SQL
        print("📝 Ejecutando script SQL para crear tabla user_likes...")
        result = supabase.rpc('exec_sql', {'sql': sql_script}).execute()
        
        print("✅ Tabla user_likes creada exitosamente")
        
        # Verificar que la tabla existe
        print("🔍 Verificando que la tabla existe...")
        tables = supabase.table('user_likes').select('*').limit(1).execute()
        print("✅ Tabla user_likes verificada")
        
        return True
        
    except Exception as e:
        print(f"❌ Error configurando tabla user_likes: {e}")
        return False

if __name__ == "__main__":
    success = setup_user_likes_table()
    if success:
        print("\n🎉 ¡Configuración completada exitosamente!")
        print("La tabla user_likes está lista para usar.")
    else:
        print("\n💥 Error en la configuración")
        sys.exit(1)






