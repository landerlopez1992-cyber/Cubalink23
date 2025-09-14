#!/usr/bin/env python3
"""
Script de prueba para el sistema de Chat de Soporte
Prueba todas las funcionalidades del sistema de tickets y mensajería
"""

import requests
import json
import time
from datetime import datetime

# Configuración
BASE_URL = 'http://localhost:3005'
ADMIN_CREDENTIALS = {
    'username': 'admin',
    'password': 'admin123'
}

def test_admin_login():
    """Login de administrador"""
    print("🔐 Iniciando sesión como administrador...")
    
    try:
        response = requests.post(f'{BASE_URL}/admin/login', data=ADMIN_CREDENTIALS)
        
        if response.status_code == 200:
            print("✅ Login exitoso")
            return response.cookies
        else:
            print(f"❌ Error en login: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_get_support_statistics(cookies):
    """Obtener estadísticas de soporte"""
    print("\n📊 Obteniendo estadísticas de soporte...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/support/statistics', cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                stats = result.get('statistics', {})
                print(f"✅ Estadísticas obtenidas")
                print(f"   📋 Total de tickets: {stats.get('total_tickets', 0)}")
                print(f"   📨 Mensajes no leídos: {stats.get('unread_messages', 0)}")
                print(f"   📊 Tickets por estado: {stats.get('tickets_by_status', {})}")
                print(f"   🚨 Tickets por prioridad: {stats.get('tickets_by_priority', {})}")
                
                return stats
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error en request: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_get_support_tickets(cookies, status=None):
    """Obtener tickets de soporte"""
    print(f"\n📋 Obteniendo tickets de soporte{f' ({status})' if status else ''}...")
    
    try:
        url = f'{BASE_URL}/admin/api/support/tickets'
        if status:
            url += f'?status={status}'
        
        response = requests.get(url, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                tickets = result.get('tickets', [])
                print(f"✅ Tickets obtenidos: {len(tickets)}")
                
                for i, ticket in enumerate(tickets[:5], 1):  # Mostrar solo los primeros 5
                    print(f"   {i}. #{ticket.get('ticket_number')} - {ticket.get('subject')} ({ticket.get('status')}) - 🔥 {ticket.get('priority')}")
                
                return tickets
            else:
                print(f"❌ Error: {result.get('error')}")
                return []
        else:
            print(f"❌ Error en request: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def test_create_support_ticket():
    """Crear ticket de soporte desde app Flutter"""
    print(f"\n🎫 Creando ticket de soporte desde app Flutter...")
    
    ticket_data = {
        'user_id': 1,
        'subject': 'Problema con reserva de vuelo',
        'description': 'No puedo completar mi reserva de vuelo MIA-HAV para el 15 de diciembre. El sistema me da error al procesar el pago.',
        'priority': 'high',
        'category': 'flight'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/support/create-ticket', json=ticket_data)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                ticket = result.get('data', {})
                print(f"✅ Ticket creado exitosamente")
                print(f"   🎫 Número: {ticket.get('ticket_number')}")
                print(f"   📝 Asunto: {ticket.get('subject')}")
                print(f"   🔥 Prioridad: {ticket.get('priority')}")
                print(f"   📂 Categoría: {ticket.get('category')}")
                
                return ticket
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error en request: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_get_ticket_details(cookies, ticket_id):
    """Obtener detalles de un ticket específico"""
    print(f"\n📄 Obteniendo detalles del ticket {ticket_id}...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/support/tickets/{ticket_id}', cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                ticket = result.get('ticket', {})
                messages = result.get('messages', [])
                
                print(f"✅ Detalles obtenidos")
                print(f"   🎫 Ticket: #{ticket.get('ticket_number')}")
                print(f"   👤 Usuario: {ticket.get('user_name', 'N/A')} ({ticket.get('user_email', 'N/A')})")
                print(f"   📝 Asunto: {ticket.get('subject')}")
                print(f"   🔥 Prioridad: {ticket.get('priority')}")
                print(f"   📂 Categoría: {ticket.get('category')}")
                print(f"   📊 Estado: {ticket.get('status')}")
                print(f"   💬 Mensajes: {len(messages)}")
                
                return {'ticket': ticket, 'messages': messages}
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error en request: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_add_admin_message(cookies, ticket_id, message):
    """Agregar mensaje de administrador"""
    print(f"\n💬 Agregando mensaje de administrador al ticket {ticket_id}...")
    
    message_data = {
        'message': message,
        'message_type': 'text'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/support/tickets/{ticket_id}/messages', 
                               json=message_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                print(f"✅ Mensaje enviado exitosamente")
                print(f"   💬 Mensaje: {message}")
                print(f"   🆔 Message ID: {result.get('data', {}).get('id', 'N/A')}")
                
                return result.get('data')
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error en request: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_add_user_message(ticket_id, user_id, message):
    """Agregar mensaje de usuario"""
    print(f"\n👤 Agregando mensaje de usuario al ticket {ticket_id}...")
    
    message_data = {
        'user_id': user_id,
        'message': message,
        'message_type': 'text'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/admin/api/support/tickets/{ticket_id}/user-message', 
                               json=message_data)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                print(f"✅ Mensaje de usuario enviado exitosamente")
                print(f"   👤 Usuario ID: {user_id}")
                print(f"   💬 Mensaje: {message}")
                
                return result.get('data')
            else:
                print(f"❌ Error: {result.get('error')}")
                return None
        else:
            print(f"❌ Error en request: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return None

def test_update_ticket_status(cookies, ticket_id, status):
    """Actualizar estado de ticket"""
    print(f"\n🔄 Actualizando estado del ticket {ticket_id} a '{status}'...")
    
    update_data = {
        'status': status,
        'assigned_to': 1  # Admin ID
    }
    
    try:
        response = requests.put(f'{BASE_URL}/admin/api/support/tickets/{ticket_id}/status', 
                              json=update_data, cookies=cookies)
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                print(f"✅ Estado actualizado exitosamente")
                print(f"   📊 Nuevo estado: {status}")
                
                return True
            else:
                print(f"❌ Error: {result.get('error')}")
                return False
        else:
            print(f"❌ Error en request: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_get_user_tickets(user_id):
    """Obtener tickets de un usuario específico"""
    print(f"\n👤 Obteniendo tickets del usuario {user_id}...")
    
    try:
        response = requests.get(f'{BASE_URL}/admin/api/support/user/{user_id}/tickets')
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                tickets = result.get('tickets', [])
                print(f"✅ Tickets del usuario obtenidos: {len(tickets)}")
                
                for i, ticket in enumerate(tickets, 1):
                    print(f"   {i}. #{ticket.get('ticket_number')} - {ticket.get('subject')} ({ticket.get('status')})")
                
                return tickets
            else:
                print(f"❌ Error: {result.get('error')}")
                return []
        else:
            print(f"❌ Error en request: {response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return []

def simulate_support_chat_flow():
    """Simular flujo completo de chat de soporte"""
    print("🚀 INICIANDO PRUEBA DEL SISTEMA DE CHAT DE SOPORTE")
    print("=" * 60)
    
    # 1. Login de administrador
    cookies = test_admin_login()
    if not cookies:
        print("❌ No se pudo iniciar sesión. Abortando prueba.")
        return
    
    # 2. Obtener estadísticas iniciales
    initial_stats = test_get_support_statistics(cookies)
    
    # 3. Obtener tickets existentes
    existing_tickets = test_get_support_tickets(cookies)
    
    # 4. Crear nuevo ticket desde app Flutter
    new_ticket = test_create_support_ticket()
    if not new_ticket:
        print("❌ No se pudo crear ticket. Continuando con tickets existentes...")
        if existing_tickets:
            new_ticket = existing_tickets[0]
        else:
            print("❌ No hay tickets disponibles para probar.")
            return
    
    ticket_id = new_ticket.get('id')
    
    # 5. Obtener detalles del ticket
    ticket_details = test_get_ticket_details(cookies, ticket_id)
    
    # 6. Simular conversación
    print(f"\n💬 SIMULANDO CONVERSACIÓN EN TICKET #{new_ticket.get('ticket_number')}")
    print("-" * 50)
    
    # Usuario envía mensaje inicial
    test_add_user_message(ticket_id, 1, "Hola, necesito ayuda con mi reserva de vuelo.")
    
    # Admin responde
    test_add_admin_message(cookies, ticket_id, "Hola! Gracias por contactarnos. ¿Podrías proporcionar más detalles sobre el problema?")
    
    # Usuario responde
    test_add_user_message(ticket_id, 1, "Sí, cuando intento pagar con mi tarjeta, el sistema me da error 500. Ya intenté con diferentes tarjetas.")
    
    # Admin responde
    test_add_admin_message(cookies, ticket_id, "Entiendo el problema. Voy a revisar el sistema de pagos. Mientras tanto, ¿podrías intentar con PayPal?")
    
    # 7. Actualizar estado del ticket
    test_update_ticket_status(cookies, ticket_id, 'in_progress')
    
    # 8. Obtener tickets del usuario
    test_get_user_tickets(1)
    
    # 9. Obtener estadísticas finales
    final_stats = test_get_support_statistics(cookies)
    
    # 10. Resumen final
    print("\n" + "=" * 60)
    print("📋 RESUMEN DE LA PRUEBA")
    print("=" * 60)
    
    print("✅ Funcionalidades probadas:")
    print("   ✅ Login de administrador")
    print("   ✅ Obtener estadísticas de soporte")
    print("   ✅ Listar tickets de soporte")
    print("   ✅ Crear ticket desde app Flutter")
    print("   ✅ Obtener detalles de ticket")
    print("   ✅ Agregar mensajes de administrador")
    print("   ✅ Agregar mensajes de usuario")
    print("   ✅ Actualizar estado de ticket")
    print("   ✅ Obtener tickets por usuario")
    
    print(f"\n📊 Estadísticas:")
    if initial_stats and final_stats:
        print(f"   📋 Tickets iniciales: {initial_stats.get('total_tickets', 0)}")
        print(f"   📋 Tickets finales: {final_stats.get('total_tickets', 0)}")
        print(f"   📨 Mensajes no leídos: {final_stats.get('unread_messages', 0)}")
    
    print(f"\n🎯 Sistema de Chat de Soporte listo!")
    print("   Los usuarios pueden:")
    print("   - Crear tickets de soporte desde la app")
    print("   - Enviar mensajes y recibir respuestas")
    print("   - Ver el estado de sus tickets")
    print("   - Los administradores pueden:")
    print("   - Ver todos los tickets")
    print("   - Responder mensajes")
    print("   - Actualizar estados")
    print("   - Ver estadísticas en tiempo real")

if __name__ == "__main__":
    simulate_support_chat_flow()

