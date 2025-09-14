#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import requests
import json

def create_user_likes_table_direct():
    """Crear la tabla user_likes usando el método directo de Supabase"""
    
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
        
        # Intentar crear la tabla usando el endpoint de migración
        url = f"{supabase_url}/rest/v1/migrations"
        
        # Datos para crear la tabla
        migration_data = {
            'name': 'create_user_likes_table',
            'sql': '''
            CREATE TABLE IF NOT EXISTS user_likes (
                id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
                user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
                product_id TEXT NOT NULL,
                product_name TEXT NOT NULL,
                product_image_url TEXT,
                product_price DECIMAL(10,2) DEFAULT 0.00,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                UNIQUE(user_id, product_id)
            );
            
            CREATE INDEX IF NOT EXISTS idx_user_likes_user_id ON user_likes(user_id);
            CREATE INDEX IF NOT EXISTS idx_user_likes_product_id ON user_likes(product_id);
            CREATE INDEX IF NOT EXISTS idx_user_likes_created_at ON user_likes(created_at DESC);
            
            ALTER TABLE user_likes ENABLE ROW LEVEL SECURITY;
            
            CREATE POLICY "Users can view their own likes" ON user_likes
                FOR SELECT USING (auth.uid() = user_id);
            
            CREATE POLICY "Users can insert their own likes" ON user_likes
                FOR INSERT WITH CHECK (auth.uid() = user_id);
            
            CREATE POLICY "Users can update their own likes" ON user_likes
                FOR UPDATE USING (auth.uid() = user_id);
            
            CREATE POLICY "Users can delete their own likes" ON user_likes
                FOR DELETE USING (auth.uid() = user_id);
            '''
        }
        
        print("📝 Intentando crear tabla user_likes...")
        response = requests.post(url, headers=headers, json=migration_data)
        
        if response.status_code in [200, 201]:
            print("✅ Tabla user_likes creada exitosamente")
        else:
            print(f"⚠️ Respuesta inesperada: {response.status_code}")
            print(f"Response: {response.text}")
        
        # Verificar que la tabla existe
        print("🔍 Verificando que la tabla existe...")
        verify_url = f"{supabase_url}/rest/v1/user_likes"
        verify_response = requests.get(verify_url, headers=headers)
        
        if verify_response.status_code == 200:
            print("✅ Tabla user_likes verificada y funcionando")
            data = verify_response.json()
            print(f"📊 Registros encontrados: {len(data)}")
            return True
        else:
            print(f"❌ Error verificando tabla: {verify_response.status_code}")
            print(f"Response: {verify_response.text}")
            return False
        
    except Exception as e:
        print(f"❌ Error general: {e}")
        return False

if __name__ == "__main__":
    success = create_user_likes_table_direct()
    if success:
        print("\n🎉 ¡Tabla user_likes creada exitosamente!")
        print("Ahora puedes probar la funcionalidad de Me gusta en la app.")
    else:
        print("\n💥 Error creando la tabla user_likes")
        print("Necesitarás crear la tabla manualmente en el panel de Supabase.")
        exit(1)






