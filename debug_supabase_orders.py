#!/usr/bin/env python3

import os
from supabase import create_client, Client
from datetime import datetime

# Configuración de Supabase
SUPABASE_URL = "https://zgqrhzuhrwudckwesybg.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY2NjQ4MjksImV4cCI6MjA0MjI0MDgyOX0.ZHCjAeJnWMfYRWKnxjIhQG_5x8wJjm8nHlPfqXhT4-c"

def main():
    print("🔍 DEBUGGING SUPABASE ORDERS - INVESTIGACIÓN COMPLETA")
    print("=" * 60)
    
    # Crear cliente de Supabase
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    try:
        print("\n📋 1. VERIFICANDO TODAS LAS ÓRDENES EN SUPABASE:")
        print("-" * 50)
        
        # Obtener todas las órdenes
        orders_response = supabase.table('orders').select('*').order('created_at', desc=True).execute()
        orders = orders_response.data
        
        print(f"✅ Total de órdenes encontradas: {len(orders)}")
        
        if orders:
            print("\n📦 DETALLES DE CADA ORDEN:")
            for i, order in enumerate(orders, 1):
                print(f"\n--- ORDEN {i} ---")
                print(f"🆔 ID: {order.get('id', 'N/A')}")
                print(f"📄 Número: {order.get('order_number', 'N/A')}")
                print(f"👤 User ID: {order.get('user_id', 'N/A')}")
                print(f"💰 Total: ${order.get('total', 0)}")
                print(f"💳 Pago: {order.get('payment_method', 'N/A')}")
                print(f"📊 Estado: {order.get('order_status', 'N/A')}")
                print(f"🕒 Creado: {order.get('created_at', 'N/A')}")
                
                # Verificar si es del usuario Lander
                if order.get('user_id') == '0b802a1e-8651-4fcf-b2d7-0442db89f4d7':
                    print("👤 ✅ ESTA ES UNA ORDEN DE LANDER LOPEZ")
                else:
                    print(f"👤 ❌ Esta orden es de otro usuario")
        else:
            print("❌ No se encontraron órdenes en la base de datos")
        
        print("\n" + "=" * 60)
        print("\n🔍 2. VERIFICANDO ÓRDENES ESPECÍFICAS DE LANDER:")
        print("-" * 50)
        
        # Obtener órdenes específicas del usuario Lander
        lander_orders = supabase.table('orders').select('*').eq('user_id', '0b802a1e-8651-4fcf-b2d7-0442db89f4d7').order('created_at', desc=True).execute()
        
        print(f"✅ Órdenes de Lander encontradas: {len(lander_orders.data)}")
        
        if lander_orders.data:
            print("\n📋 ÓRDENES DE LANDER (más recientes primero):")
            for i, order in enumerate(lander_orders.data, 1):
                created_time = order.get('created_at', '')
                if created_time:
                    try:
                        dt = datetime.fromisoformat(created_time.replace('Z', '+00:00'))
                        time_str = dt.strftime('%d/%m/%Y %H:%M:%S')
                    except:
                        time_str = created_time
                else:
                    time_str = 'N/A'
                
                print(f"\n{i}. Orden #{order.get('order_number', 'N/A')}")
                print(f"   💰 Total: ${order.get('total', 0)}")
                print(f"   💳 Método: {order.get('payment_method', 'N/A')}")
                print(f"   📊 Estado: {order.get('order_status', 'N/A')}")
                print(f"   🕒 Fecha: {time_str}")
                
                # Verificar si es de hoy
                if created_time:
                    try:
                        dt = datetime.fromisoformat(created_time.replace('Z', '+00:00'))
                        if dt.date() == datetime.now().date():
                            print("   🆕 ✅ ORDEN CREADA HOY")
                        else:
                            print(f"   📅 Orden antigua ({dt.date()})")
                    except:
                        print("   ❓ Fecha no válida")
        
        print("\n" + "=" * 60)
        print("\n🔍 3. VERIFICANDO TABLA ORDER_ITEMS:")
        print("-" * 50)
        
        # Verificar si existe la tabla order_items
        try:
            items_response = supabase.table('order_items').select('*').limit(5).execute()
            print(f"✅ Tabla order_items existe - {len(items_response.data)} items encontrados")
            
            if items_response.data:
                print("\n📦 PRIMEROS 5 ORDER_ITEMS:")
                for item in items_response.data[:5]:
                    print(f"   🆔 Order ID: {item.get('order_id', 'N/A')}")
                    print(f"   📦 Producto: {item.get('name', 'N/A')}")
                    print(f"   💰 Precio: ${item.get('unit_price', 0)}")
                    print("   ---")
            
        except Exception as e:
            print(f"❌ Error accediendo a order_items: {e}")
        
        print("\n" + "=" * 60)
        print("\n🔍 4. VERIFICANDO USUARIOS REGISTRADOS:")
        print("-" * 50)
        
        # Verificar usuarios
        try:
            users_response = supabase.table('users').select('id, email, full_name, created_at').limit(10).execute()
            print(f"✅ Usuarios encontrados: {len(users_response.data)}")
            
            lander_found = False
            for user in users_response.data:
                if user.get('id') == '0b802a1e-8651-4fcf-b2d7-0442db89f4d7':
                    print(f"\n👤 ✅ LANDER LOPEZ ENCONTRADO:")
                    print(f"   📧 Email: {user.get('email', 'N/A')}")
                    print(f"   👤 Nombre: {user.get('full_name', 'N/A')}")
                    print(f"   🕒 Registrado: {user.get('created_at', 'N/A')}")
                    lander_found = True
                    break
            
            if not lander_found:
                print("❌ Usuario Lander Lopez NO encontrado en la tabla users")
                
        except Exception as e:
            print(f"❌ Error accediendo a users: {e}")
        
        print("\n" + "=" * 60)
        print("🎯 RESUMEN DE LA INVESTIGACIÓN:")
        print("-" * 50)
        print(f"📊 Total órdenes en sistema: {len(orders)}")
        print(f"👤 Órdenes de Lander: {len(lander_orders.data)}")
        
        # Contar órdenes de hoy
        today_orders = 0
        if lander_orders.data:
            for order in lander_orders.data:
                created_time = order.get('created_at', '')
                if created_time:
                    try:
                        dt = datetime.fromisoformat(created_time.replace('Z', '+00:00'))
                        if dt.date() == datetime.now().date():
                            today_orders += 1
                    except:
                        pass
        
        print(f"🆕 Órdenes de hoy: {today_orders}")
        
        if today_orders == 0:
            print("\n❌ PROBLEMA IDENTIFICADO: No hay órdenes nuevas guardándose en Supabase")
            print("🔧 POSIBLES CAUSAS:")
            print("   1. Error en el código de creación de órdenes")
            print("   2. Problema con las credenciales de Supabase")
            print("   3. Error en el backend sistema")
            print("   4. RLS bloqueando las inserciones")
        else:
            print(f"\n✅ Se están creando órdenes, pero puede haber problema en la app")
        
    except Exception as e:
        print(f"❌ Error general: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
