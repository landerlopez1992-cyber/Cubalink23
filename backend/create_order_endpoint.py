#!/usr/bin/env python3
"""
🎯 ENDPOINT PARA CREAR ÓRDENES SERVER-TO-SERVER
Solución definitiva al problema de campos faltantes en Flutter
"""

import os
import json
import uuid
from datetime import datetime
from flask import Flask, request, jsonify
from supabase import create_client, Client

# Configuración de Supabase con SERVICE_ROLE (bypassa RLS)
SUPABASE_URL = "https://zgqrhzuhrwudckwesybg.supabase.co"
SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNjY2NDgyOSwiZXhwIjoyMDQyMjQwODI5fQ.nMhOYDNNfq8NMqXvJKJT8SjLFjZJmVP9gDGGfcE8xhQ"

app = Flask(__name__)

# Cliente Supabase con permisos completos
supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

@app.route('/api/orders/from-wallet', methods=['POST'])
def create_order_from_wallet():
    """
    🎯 Crear orden después de pago exitoso con billetera
    """
    try:
        data = request.get_json()
        print(f"📋 Datos recibidos: {list(data.keys())}")
        
        # Generar order_number único
        order_number = f"ORD-{datetime.now().strftime('%Y%m%d-%H%M%S')}-{str(uuid.uuid4())[:8]}"
        
        # Preparar datos de la orden (SOLO campos que EXISTEN en Supabase)
        order_data = {
            'user_id': data.get('user_id'),
            'order_number': order_number,
            'items': data.get('items', []),
            'shipping_address': data.get('shipping_address', {}),
            'shipping_method': data.get('shipping_method', 'express'),
            'subtotal': float(data.get('subtotal', 0)),
            'shipping_cost': float(data.get('shipping_cost', 0)),
            'total': float(data.get('total', 0)),
            'payment_method': 'wallet',
            'payment_status': 'completed',
            'order_status': 'payment_confirmed',
            'estimated_delivery': data.get('estimated_delivery'),
            'metadata': data.get('metadata', {}),
        }
        
        print(f"💾 Insertando orden: {order_number}")
        
        # Insertar orden en Supabase (con service_role, bypassa RLS)
        result = supabase.table('orders').insert(order_data).execute()
        
        if result.data:
            order_id = result.data[0]['id']
            print(f"✅ Orden creada: {order_id}")
            
            # Crear order_items si hay items en el carrito
            cart_items = data.get('cart_items', [])
            if cart_items:
                print(f"📦 Creando {len(cart_items)} order_items...")
                
                for item in cart_items:
                    order_item = {
                        'order_id': order_id,
                        'product_type': item.get('product_type', 'store'),
                        'name': item.get('product_name', item.get('name', 'Producto')),
                        'unit_price': float(item.get('product_price', item.get('price', 0))),
                        'quantity': int(item.get('quantity', 1)),
                        'total_price': float(item.get('product_price', item.get('price', 0))) * int(item.get('quantity', 1)),
                        'unit_weight_lb': float(item.get('weight_lb', 0.5)),
                        'total_weight_lb': float(item.get('weight_lb', 0.5)) * int(item.get('quantity', 1)),
                        'selected_size': item.get('selected_size'),
                        'selected_color': item.get('selected_color'),
                        'asin': item.get('amazon_asin'),
                        'amazon_data': item.get('amazon_data'),
                        'metadata': {
                            'product_id': item.get('product_id'),
                            'cart_item_id': item.get('id')
                        }
                    }
                    
                    supabase.table('order_items').insert(order_item).execute()
                    print(f"   ✅ Item creado: {order_item['name']}")
            
            # Registrar actividad
            try:
                activity_data = {
                    'user_id': data.get('user_id'),
                    'type': 'order_created',
                    'description': f'Orden #{order_number} creada y pagada con billetera',
                    'amount': float(data.get('total', 0)),
                    'metadata': {'order_id': order_id, 'order_number': order_number}
                }
                supabase.table('activities').insert(activity_data).execute()
                print("✅ Actividad registrada")
            except Exception as e:
                print(f"⚠️ Error registrando actividad: {e}")
            
            return jsonify({
                'success': True,
                'order_id': order_id,
                'order_number': order_number,
                'message': 'Orden creada exitosamente server-to-server'
            }), 201
            
        else:
            print("❌ No se pudo insertar la orden")
            return jsonify({
                'success': False,
                'error': 'Failed to create order'
            }), 500
            
    except Exception as e:
        print(f"💥 Error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check"""
    return jsonify({
        'status': 'ok',
        'service': 'order-creation-server',
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    print("🚀 Order Creation Server iniciando...")
    print(f"🗄️ Supabase URL: {SUPABASE_URL}")
    print("🔑 Service Role Key configurada")
    app.run(debug=True, port=5001)
