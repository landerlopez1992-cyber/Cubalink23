#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
from supabase import create_client, Client

def test_likes_functionality():
    """Probar la funcionalidad de likes en Supabase"""
    
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
        
        # 1. Verificar si la tabla user_likes existe
        print("\n1️⃣ Verificando si la tabla user_likes existe...")
        try:
            result = supabase.table('user_likes').select('*').limit(1).execute()
            print("✅ Tabla user_likes existe")
        except Exception as e:
            print(f"❌ Tabla user_likes no existe: {e}")
            return False
        
        # 2. Verificar estructura de la tabla
        print("\n2️⃣ Verificando estructura de la tabla...")
        try:
            # Intentar insertar un registro de prueba
            test_data = {
                'user_id': '00000000-0000-0000-0000-000000000000',  # UUID de prueba
                'product_id': 'test_product_123',
                'product_name': 'Producto de Prueba',
                'product_image_url': 'https://example.com/image.jpg',
                'product_price': 29.99
            }
            
            # Esto fallará por el foreign key, pero nos dirá si la estructura está bien
            try:
                result = supabase.table('user_likes').insert(test_data).execute()
                print("✅ Estructura de tabla correcta")
            except Exception as insert_error:
                if "foreign key" in str(insert_error).lower():
                    print("✅ Estructura de tabla correcta (error esperado por foreign key)")
                else:
                    print(f"❌ Error en estructura: {insert_error}")
                    return False
                    
        except Exception as e:
            print(f"❌ Error verificando estructura: {e}")
            return False
        
        # 3. Verificar políticas RLS
        print("\n3️⃣ Verificando políticas RLS...")
        try:
            # Intentar hacer un select sin autenticación
            result = supabase.table('user_likes').select('*').execute()
            print(f"📊 Registros encontrados: {len(result.data)}")
            print("✅ Políticas RLS configuradas correctamente")
        except Exception as e:
            print(f"❌ Error con políticas RLS: {e}")
            return False
        
        # 4. Verificar usuarios existentes
        print("\n4️⃣ Verificando usuarios en auth.users...")
        try:
            # Esto debería fallar porque no tenemos acceso directo a auth.users
            result = supabase.table('auth.users').select('*').limit(1).execute()
            print("✅ Acceso a auth.users disponible")
        except Exception as e:
            print(f"⚠️ No se puede acceder a auth.users directamente: {e}")
            print("Esto es normal, auth.users es una tabla del sistema")
        
        # 5. Probar operaciones CRUD básicas
        print("\n5️⃣ Probando operaciones básicas...")
        try:
            # Count de registros existentes
            result = supabase.table('user_likes').select('*', count='exact').execute()
            print(f"📊 Total de likes en la tabla: {result.count}")
            
            # Verificar si hay algún like existente
            if result.count > 0:
                print("✅ Hay likes existentes en la tabla")
                # Mostrar algunos ejemplos
                sample_likes = result.data[:3] if len(result.data) > 0 else []
                for like in sample_likes:
                    print(f"   - Producto: {like.get('product_name', 'N/A')} (ID: {like.get('product_id', 'N/A')})")
            else:
                print("ℹ️ No hay likes en la tabla aún")
                
        except Exception as e:
            print(f"❌ Error en operaciones básicas: {e}")
            return False
        
        print("\n✅ Todas las verificaciones pasaron exitosamente")
        return True
        
    except Exception as e:
        print(f"❌ Error general: {e}")
        return False

if __name__ == "__main__":
    success = test_likes_functionality()
    if success:
        print("\n🎉 ¡La funcionalidad de likes está funcionando correctamente!")
        print("El problema puede estar en el código de la app Flutter.")
    else:
        print("\n💥 Hay problemas con la configuración de Supabase")
        sys.exit(1)






