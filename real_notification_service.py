#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sistema de Notificaciones Reales
Envía notificaciones reales por email y SMS cuando se complete una reserva
"""

import smtplib
import requests
import json
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime
import os

class RealNotificationService:
    def __init__(self):
        # Configuración de email (Gmail SMTP)
        self.smtp_server = "smtp.gmail.com"
        self.smtp_port = 587
        self.email_user = os.environ.get('GMAIL_USER', 'cubalink23@gmail.com')
        self.email_password = os.environ.get('GMAIL_PASSWORD', '')
        
        # Configuración de SMS (Twilio)
        self.twilio_account_sid = os.environ.get('TWILIO_ACCOUNT_SID', '')
        self.twilio_auth_token = os.environ.get('TWILIO_AUTH_TOKEN', '')
        self.twilio_phone_number = os.environ.get('TWILIO_PHONE_NUMBER', '')
        
        # Configuración de WhatsApp (Twilio WhatsApp)
        self.whatsapp_enabled = os.environ.get('WHATSAPP_ENABLED', 'false').lower() == 'true'
        
    def send_email_notification(self, to_email, subject, message, html_content=None):
        """Enviar email real"""
        try:
            msg = MIMEMultipart('alternative')
            msg['Subject'] = subject
            msg['From'] = self.email_user
            msg['To'] = to_email
            
            # Texto plano
            text_part = MIMEText(message, 'plain', 'utf-8')
            msg.attach(text_part)
            
            # HTML si se proporciona
            if html_content:
                html_part = MIMEText(html_content, 'html', 'utf-8')
                msg.attach(html_part)
            
            # Conectar y enviar
            server = smtplib.SMTP(self.smtp_server, self.smtp_port)
            server.starttls()
            server.login(self.email_user, self.email_password)
            
            text = msg.as_string()
            server.sendmail(self.email_user, to_email, text)
            server.quit()
            
            print(f"✅ Email enviado a: {to_email}")
            return True
            
        except Exception as e:
            print(f"❌ Error enviando email: {e}")
            return False
    
    def send_sms_notification(self, phone_number, message):
        """Enviar SMS real usando Twilio"""
        try:
            if not all([self.twilio_account_sid, self.twilio_auth_token, self.twilio_phone_number]):
                print("⚠️ Configuración de Twilio incompleta")
                return False
            
            url = f"https://api.twilio.com/2010-04-01/Accounts/{self.twilio_account_sid}/Messages.json"
            
            data = {
                'From': self.twilio_phone_number,
                'To': phone_number,
                'Body': message
            }
            
            response = requests.post(url, data=data, auth=(self.twilio_account_sid, self.twilio_auth_token))
            
            if response.status_code == 201:
                print(f"✅ SMS enviado a: {phone_number}")
                return True
            else:
                print(f"❌ Error enviando SMS: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Error enviando SMS: {e}")
            return False
    
    def send_whatsapp_notification(self, phone_number, message):
        """Enviar WhatsApp real usando Twilio"""
        try:
            if not self.whatsapp_enabled:
                print("⚠️ WhatsApp no está habilitado")
                return False
            
            if not all([self.twilio_account_sid, self.twilio_auth_token]):
                print("⚠️ Configuración de Twilio incompleta")
                return False
            
            url = f"https://api.twilio.com/2010-04-01/Accounts/{self.twilio_account_sid}/Messages.json"
            
            data = {
                'From': f'whatsapp:{self.twilio_phone_number}',
                'To': f'whatsapp:{phone_number}',
                'Body': message
            }
            
            response = requests.post(url, data=data, auth=(self.twilio_account_sid, self.twilio_auth_token))
            
            if response.status_code == 201:
                print(f"✅ WhatsApp enviado a: {phone_number}")
                return True
            else:
                print(f"❌ Error enviando WhatsApp: {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Error enviando WhatsApp: {e}")
            return False
    
    def notify_booking_confirmation(self, booking_data):
        """Notificar confirmación de reserva al cliente"""
        try:
            client_data = booking_data.get('client_data', {})
            client_name = client_data.get('name', 'Cliente')
            client_email = client_data.get('email', '')
            client_phone = client_data.get('phone', '')
            
            reservation_id = booking_data.get('reservation_id', '')
            confirmation_number = booking_data.get('confirmation_number', '')
            temp_email = booking_data.get('temp_email', '')
            
            # Mensaje de confirmación
            subject = f"✅ Reserva Confirmada - {reservation_id}"
            
            message = f"""
¡Hola {client_name}!

Tu reserva de vehículo ha sido confirmada exitosamente.

📋 Detalles de la Reserva:
• ID de Reserva: {reservation_id}
• Número de Confirmación: {confirmation_number}
• Email Temporal: {temp_email}
• Fecha de Reserva: {booking_data.get('booking_date', '')}

🚗 Información del Vehículo:
• Tipo: {client_data.get('vehicle_type', 'N/A')}
• Fecha de Recogida: {client_data.get('pickup_date', 'N/A')}
• Fecha de Devolución: {client_data.get('return_date', 'N/A')}
• Lugar de Recogida: {client_data.get('pickup_location', 'N/A')}

📞 Para cualquier consulta, contáctanos:
• Email: soporte@cubalink.com
• WhatsApp: +53 5 123 4567

¡Gracias por confiar en CubaLink23!

Saludos,
El equipo de CubaLink23
            """
            
            html_content = f"""
            <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background-color: #f8f9fa; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #28a745;">✅ Reserva Confirmada</h2>
                    <p>¡Hola <strong>{client_name}</strong>!</p>
                    <p>Tu reserva de vehículo ha sido confirmada exitosamente.</p>
                    
                    <div style="background-color: white; padding: 15px; border-radius: 5px; margin: 20px 0;">
                        <h3>📋 Detalles de la Reserva</h3>
                        <p><strong>ID de Reserva:</strong> {reservation_id}</p>
                        <p><strong>Número de Confirmación:</strong> {confirmation_number}</p>
                        <p><strong>Email Temporal:</strong> {temp_email}</p>
                        <p><strong>Fecha de Reserva:</strong> {booking_data.get('booking_date', '')}</p>
                    </div>
                    
                    <div style="background-color: white; padding: 15px; border-radius: 5px; margin: 20px 0;">
                        <h3>🚗 Información del Vehículo</h3>
                        <p><strong>Tipo:</strong> {client_data.get('vehicle_type', 'N/A')}</p>
                        <p><strong>Fecha de Recogida:</strong> {client_data.get('pickup_date', 'N/A')}</p>
                        <p><strong>Fecha de Devolución:</strong> {client_data.get('return_date', 'N/A')}</p>
                        <p><strong>Lugar de Recogida:</strong> {client_data.get('pickup_location', 'N/A')}</p>
                    </div>
                    
                    <div style="background-color: #e9ecef; padding: 15px; border-radius: 5px;">
                        <h3>📞 Contacto</h3>
                        <p>Para cualquier consulta, contáctanos:</p>
                        <p>• Email: <a href="mailto:soporte@cubalink.com">soporte@cubalink.com</a></p>
                        <p>• WhatsApp: <a href="https://wa.me/5351234567">+53 5 123 4567</a></p>
                    </div>
                    
                    <p style="margin-top: 20px;">¡Gracias por confiar en CubaLink23!</p>
                    <p><strong>Saludos,<br>El equipo de CubaLink23</strong></p>
                </div>
            </body>
            </html>
            """
            
            # Enviar notificaciones
            notifications_sent = []
            
            # Email al cliente
            if client_email:
                if self.send_email_notification(client_email, subject, message, html_content):
                    notifications_sent.append('email')
            
            # SMS al cliente
            if client_phone:
                sms_message = f"✅ Reserva {reservation_id} confirmada. Número: {confirmation_number}. CubaLink23"
                if self.send_sms_notification(client_phone, sms_message):
                    notifications_sent.append('sms')
            
            # WhatsApp al cliente
            if client_phone and self.whatsapp_enabled:
                whatsapp_message = f"✅ Reserva {reservation_id} confirmada\nNúmero: {confirmation_number}\nCubaLink23"
                if self.send_whatsapp_notification(client_phone, whatsapp_message):
                    notifications_sent.append('whatsapp')
            
            print(f"✅ Notificaciones enviadas: {', '.join(notifications_sent)}")
            return notifications_sent
            
        except Exception as e:
            print(f"❌ Error enviando notificaciones: {e}")
            return []
    
    def notify_admin_booking(self, booking_data):
        """Notificar al administrador sobre nueva reserva"""
        try:
            admin_email = os.environ.get('ADMIN_EMAIL', 'landerlopez1992@gmail.com')
            
            subject = f"🚗 Nueva Reserva Automatizada - {booking_data.get('reservation_id', '')}"
            
            message = f"""
Nueva reserva automatizada completada:

📋 Detalles:
• ID: {booking_data.get('reservation_id', '')}
• Cliente: {booking_data.get('client_data', {}).get('name', 'N/A')}
• Email Temporal: {booking_data.get('temp_email', '')}
• Confirmación: {booking_data.get('confirmation_number', 'Pendiente')}
• Estado: {booking_data.get('status', 'N/A')}

🚗 Vehículo:
• Tipo: {booking_data.get('client_data', {}).get('vehicle_type', 'N/A')}
• Fechas: {booking_data.get('client_data', {}).get('pickup_date', '')} - {booking_data.get('client_data', {}).get('return_date', '')}

✅ Automatización: {booking_data.get('automation_success', False)}
🤖 Real: {booking_data.get('real_automation', False)}
            """
            
            return self.send_email_notification(admin_email, subject, message)
            
        except Exception as e:
            print(f"❌ Error notificando admin: {e}")
            return False

# Instancia global del servicio
notification_service = RealNotificationService()

# Funciones de utilidad
def send_booking_confirmation(booking_data):
    """Enviar confirmación de reserva"""
    return notification_service.notify_booking_confirmation(booking_data)

def notify_admin_new_booking(booking_data):
    """Notificar admin sobre nueva reserva"""
    return notification_service.notify_admin_booking(booking_data)

