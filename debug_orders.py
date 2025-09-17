#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🔍 SCRIPT DE DIAGNÓSTICO - ÓRDENES CUBALINK23
Verificar por qué no aparecen las órdenes después del pago
"""

import os
import sys
import json
from datetime import datetime, timedelta
from supabase import create_client, Client

# Configuración de Supabase (usar las mismas credenciales del proyecto)
SUPABASE_URL = "https://zgqrhzuhrwudckwesybg.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY2NjQ4MjksImV4cCI6MjA0MjI0MDgyOX0.6l_-LL4WrYPFM7n3jFJYE9E-C-gHV_8Jdm4W-7qs8nQ"

def main():
    print("🔍 ===== DIAGNÓSTICO DE ÓRDENES CUBALINK23 =====")
    print(f"🕐 Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    try:
        # Conectar a Supabase
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Conectado a Supabase exitosamente")
        print()
        
        # 1. Verificar estructura de tabla orders
        print("📋 1. VERIFICANDO ESTRUCTURA DE TABLA ORDERS...")
        try:
            # Obtener todas las órdenes (límite 5 para ver estructura)
            response = supabase.table('orders').select('*').limit(5).execute()
            
            if response.data:
                print(f"✅ Tabla 'orders' existe - {len(response.data)} órdenes encontradas")
                
                # Mostrar estructura de primera orden
                if response.data:
                    first_order = response.data[0]
                    print("📝 Campos disponibles:")
                    for key in sorted(first_order.keys()):
                        print(f"   - {key}: {type(first_order[key]).__name__}")
                    print()
            else:
                print("⚠️ Tabla 'orders' existe pero está vacía")
                print()
                
        except Exception as e:
            print(f"❌ Error accediendo tabla orders: {e}")
            print()
        
        # 2. Verificar tabla order_items
        print("📦 2. VERIFICANDO TABLA ORDER_ITEMS...")
        try:
            response = supabase.table('order_items').select('*').limit(3).execute()
            
            if response.data:
                print(f"✅ Tabla 'order_items' existe - {len(response.data)} items encontrados")
            else:
                print("⚠️ Tabla 'order_items' existe pero está vacía")
            print()
                
        except Exception as e:
            print(f"❌ Error accediendo tabla order_items: {e}")
            print("💡 Posible solución: Ejecutar SQL_FIX_ORDERS_SYSTEM_COMPLETE.sql")
            print()
        
        # 3. Buscar órdenes recientes (últimas 24 horas)
        print("🕐 3. BUSCANDO ÓRDENES RECIENTES (ÚLTIMAS 24 HORAS)...")
        try:
            yesterday = (datetime.now() - timedelta(days=1)).isoformat()
            
            response = supabase.table('orders').select('*').gte('created_at', yesterday).order('created_at', desc=True).execute()
            
            if response.data:
                print(f"📦 {len(response.data)} órdenes encontradas en las últimas 24 horas:")
                print()
                
                for i, order in enumerate(response.data[:5], 1):  # Mostrar máximo 5
                    print(f"   {i}. Orden #{order.get('order_number', 'N/A')}")
                    print(f"      💰 Total: ${order.get('total', 0)}")
                    print(f"      👤 Usuario: {order.get('user_id', 'N/A')[:8]}...")
                    print(f"      💳 Pago: {order.get('payment_method', 'N/A')} - {order.get('payment_status', 'N/A')}")
                    print(f"      📊 Estado: {order.get('order_status', 'N/A')}")
                    print(f"      📅 Creada: {order.get('created_at', 'N/A')}")
                    print()
            else:
                print("❌ NO se encontraron órdenes recientes")
                print("💡 Esto indica que las órdenes no se están creando correctamente")
                print()
                
        except Exception as e:
            print(f"❌ Error buscando órdenes recientes: {e}")
            print()
        
        # 4. Verificar usuarios activos
        print("👥 4. VERIFICANDO USUARIOS ACTIVOS...")
        try:
            response = supabase.table('users').select('id, email, balance, created_at').limit(3).execute()
            
            if response.data:
                print(f"✅ {len(response.data)} usuarios encontrados:")
                for user in response.data[:3]:
                    print(f"   - {user.get('email', 'N/A')} (Saldo: ${user.get('balance', 0)})")
            else:
                print("❌ No se encontraron usuarios")
            print()
                
        except Exception as e:
            print(f"❌ Error verificando usuarios: {e}")
            print()
        
        # 5. Verificar actividades recientes
        print("📊 5. VERIFICANDO ACTIVIDADES RECIENTES...")
        try:
            response = supabase.table('activities').select('*').gte('timestamp', yesterday).order('timestamp', desc=True).limit(10).execute()
            
            if response.data:
                print(f"📈 {len(response.data)} actividades encontradas:")
                for activity in response.data[:5]:
                    print(f"   - {activity.get('type', 'N/A')}: {activity.get('description', 'N/A')}")
                    print(f"     💰 ${activity.get('amount', 0)} - {activity.get('timestamp', 'N/A')}")
            else:
                print("❌ No se encontraron actividades recientes")
            print()
                
        except Exception as e:
            print(f"❌ Error verificando actividades: {e}")
            print()
        
        # 6. Recomendaciones
        print("💡 6. DIAGNÓSTICO Y RECOMENDACIONES:")
        print()
        
        # Verificar si las órdenes se están creando
        recent_orders_response = supabase.table('orders').select('*').gte('created_at', yesterday).execute()
        recent_orders_count = len(recent_orders_response.data) if recent_orders_response.data else 0
        
        if recent_orders_count == 0:
            print("🚨 PROBLEMA IDENTIFICADO: Las órdenes NO se están creando")
            print("   Posibles causas:")
            print("   1. Error en el método createOrder() del repositorio")
            print("   2. Error en la estructura de datos enviada")
            print("   3. Error de permisos en Supabase")
            print("   4. Error en la tabla orders (campos faltantes)")
            print()
            print("🔧 SOLUCIONES RECOMENDADAS:")
            print("   1. Verificar logs de Flutter durante el pago")
            print("   2. Ejecutar SQL_FIX_ORDERS_SYSTEM_COMPLETE.sql")
            print("   3. Verificar permisos RLS en Supabase")
            print("   4. Probar creación manual de orden")
        else:
            print(f"✅ Las órdenes se están creando ({recent_orders_count} recientes)")
            print("   El problema puede estar en:")
            print("   1. La pantalla de rastreo no carga correctamente")
            print("   2. Filtro por usuario incorrecto")
            print("   3. Error en getUserOrdersRaw()")
        
        print()
        print("🎯 PRÓXIMO PASO RECOMENDADO:")
        print("   Revisar logs de Flutter durante el proceso de pago")
        print("   Comando: flutter logs (mientras haces una compra)")
        
    except Exception as e:
        print(f"💥 Error general en diagnóstico: {e}")
        print("Verifica las credenciales de Supabase")
    
    print()
    print("🏁 ===== DIAGNÓSTICO COMPLETADO =====")

if __name__ == "__main__":
    # Instalar supabase si no está disponible
    try:
        import supabase
    except ImportError:
        print("📦 Instalando supabase-py...")
        os.system("pip install supabase")
        import supabase
    
    main()
