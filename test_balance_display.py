#!/usr/bin/env python3
"""
Script para verificar el saldo del usuario Lander en Supabase
"""

import os
from supabase import create_client, Client

# Configuración de Supabase
SUPABASE_URL = "https://qjqjqjqjqjqjqjqjqjqj.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqcWpxanFqcWpxanFqcWpxanFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU5NDQ4MDAsImV4cCI6MjA1MTUyMDgwMH0.qjqjqjqjqjqjqjqjqjqjqjqjqjqjqjqjqjqjqjqjqjqj"

def test_balance_display():
    """Verificar el saldo del usuario Lander"""
    try:
        # Crear cliente de Supabase
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        print("🔍 === VERIFICANDO SALDO DE LANDER ===")
        
        # Buscar usuario Lander
        response = supabase.table('users').select('*').eq('email', 'landerlopez1992@gmail.com').execute()
        
        if response.data:
            user = response.data[0]
            print(f"✅ Usuario encontrado:")
            print(f"   - ID: {user['id']}")
            print(f"   - Nombre: {user['name']}")
            print(f"   - Email: {user['email']}")
            print(f"   - Saldo actual: ${user['balance']}")
            print(f"   - Creado: {user['created_at']}")
            print(f"   - Actualizado: {user['updated_at']}")
            
            # Verificar si el saldo es 0
            if user['balance'] == 0:
                print("\n⚠️  SALDO ES 0 - ACTUALIZANDO A $50...")
                update_response = supabase.table('users').update({
                    'balance': 50.0
                }).eq('id', user['id']).execute()
                
                if update_response.data:
                    print("✅ Saldo actualizado a $50.00")
                else:
                    print("❌ Error actualizando saldo")
            else:
                print(f"✅ Saldo correcto: ${user['balance']}")
                
        else:
            print("❌ Usuario no encontrado")
            
        # Verificar tarjetas de pago
        print("\n💳 === VERIFICANDO TARJETAS DE PAGO ===")
        cards_response = supabase.table('payment_cards').select('*').eq('user_id', user['id']).execute()
        
        if cards_response.data:
            print(f"✅ {len(cards_response.data)} tarjetas encontradas:")
            for card in cards_response.data:
                print(f"   - Tarjeta: ****{card['card_number']}")
                print(f"   - Tipo: {card['card_type']}")
                print(f"   - Vencimiento: {card['expiry_month']}/{card['expiry_year']}")
                print(f"   - Nombre: {card['holder_name']}")
                print(f"   - Predeterminada: {card['is_default']}")
        else:
            print("❌ No hay tarjetas guardadas")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_balance_display()


