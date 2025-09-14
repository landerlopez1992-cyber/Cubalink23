#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import requests
import json

def create_user_likes_table():
    """Crear la tabla user_likes en Supabase usando SQL directo"""
    
    # Variables de entorno
    supabase_url = os.getenv('SUPABASE_URL')
    supabase_key = os.getenv('SUPABASE_ANON_KEY')
    
    if not supabase_url or not supabase_key:
        print("❌ Error: SUPABASE_URL o SUPABASE_ANON_KEY no configurados")
        return False
    
    try:
        print("🔗 Conectando a Supabase...")
        
        # Headers para la petición
        headers = {
            'apikey': supabase_key,
            'Authorization': f'Bearer {supabase_key}',
            'Content-Type': 'application/json'
        }
        
        # SQL para crear la tabla
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
        
        # URL para ejecutar SQL
        url = f"{supabase_url}/rest/v1/rpc/exec_sql"
        
        # Datos para la petición
        data = {
            'sql': sql_script
        }
        
        print("📝 Ejecutando script SQL para crear tabla user_likes...")
        response = requests.post(url, headers=headers, json=data)
        
        if response.status_code == 200:
            print("✅ Tabla user_likes creada exitosamente")
            
            # Verificar que la tabla existe
            print("🔍 Verificando que la tabla existe...")
            verify_url = f"{supabase_url}/rest/v1/user_likes"
            verify_response = requests.get(verify_url, headers=headers)
            
            if verify_response.status_code == 200:
                print("✅ Tabla user_likes verificada y funcionando")
                return True
            else:
                print(f"❌ Error verificando tabla: {verify_response.status_code}")
                return False
                
        else:
            print(f"❌ Error creando tabla: {response.status_code}")
            print(f"Response: {response.text}")
            return False
        
    except Exception as e:
        print(f"❌ Error general: {e}")
        return False

if __name__ == "__main__":
    success = create_user_likes_table()
    if success:
        print("\n🎉 ¡Tabla user_likes creada exitosamente!")
        print("Ahora puedes probar la funcionalidad de Me gusta en la app.")
    else:
        print("\n💥 Error creando la tabla user_likes")
        exit(1)






