#!/usr/bin/env python3

# Leer el archivo
with open('supabase_service.py', 'r') as f:
    content = f.read()

# Reemplazar f-strings simples
content = content.replace("f'{self.supabase_url}/rest/v1/users?id=eq.{user_id}'", "self.supabase_url + '/rest/v1/users?id=eq.' + user_id")
content = content.replace("f'{self.supabase_url}/rest/v1/products?select=*'", "self.supabase_url + '/rest/v1/products?select=*'")
content = content.replace("f'{self.supabase_url}/rest/v1/products'", "self.supabase_url + '/rest/v1/products'")
content = content.replace("f'{self.supabase_url}/rest/v1/products?id=eq.{product_id}'", "self.supabase_url + '/rest/v1/products?id=eq.' + product_id")
content = content.replace("f'{self.supabase_url}/rest/v1/banners?select=*'", "self.supabase_url + '/rest/v1/banners?select=*'")
content = content.replace("f'{self.supabase_url}/rest/v1/banners'", "self.supabase_url + '/rest/v1/banners'")
content = content.replace("f'{self.supabase_url}/rest/v1/banners?id=eq.{banner_id}'", "self.supabase_url + '/rest/v1/banners?id=eq.' + banner_id")
content = content.replace("f'{self.supabase_url}/rest/v1/orders'", "self.supabase_url + '/rest/v1/orders'")
content = content.replace("f'{self.supabase_url}/rest/v1/orders?id=eq.{order_id}'", "self.supabase_url + '/rest/v1/orders?id=eq.' + order_id")
content = content.replace("f'{self.supabase_url}/rest/v1/recharge_history'", "self.supabase_url + '/rest/v1/recharge_history'")
content = content.replace("f'{self.supabase_url}/rest/v1/transfers'", "self.supabase_url + '/rest/v1/transfers'")
content = content.replace("f'{self.supabase_url}/rest/v1/store_categories'", "self.supabase_url + '/rest/v1/store_categories'")
content = content.replace("f'{self.supabase_url}/rest/v1/activities'", "self.supabase_url + '/rest/v1/activities'")
content = content.replace("f'{self.supabase_url}/rest/v1/notifications'", "self.supabase_url + '/rest/v1/notifications'")
content = content.replace("f'{self.supabase_url}/rest/v1/app_config'", "self.supabase_url + '/rest/v1/app_config'")
content = content.replace("f'{self.supabase_url}/rest/v1/app_config?id=eq.1'", "self.supabase_url + '/rest/v1/app_config?id=eq.1'")
content = content.replace("f'{self.supabase_url}/rest/v1/users?select=count'", "self.supabase_url + '/rest/v1/users?select=count'")
content = content.replace("f'{self.supabase_url}/rest/v1/products?select=count'", "self.supabase_url + '/rest/v1/products?select=count'")
content = content.replace("f'{self.supabase_url}/rest/v1/orders?select=count'", "self.supabase_url + '/rest/v1/orders?select=count'")
content = content.replace("f'{self.supabase_url}/rest/v1/vehicles'", "self.supabase_url + '/rest/v1/vehicles'")
content = content.replace("f'{self.supabase_url}/rest/v1/vehicles?order=created_at.desc'", "self.supabase_url + '/rest/v1/vehicles?order=created_at.desc'")
content = content.replace("f'{self.supabase_url}/rest/v1/vehicles?id=eq.{vehicle_id}'", "self.supabase_url + '/rest/v1/vehicles?id=eq.' + vehicle_id")
content = content.replace("f'{self.supabase_url}/rest/v1/phone_bookings'", "self.supabase_url + '/rest/v1/phone_bookings'")
content = content.replace("f'{self.supabase_url}/rest/v1/phone_bookings?order=booking_date.desc'", "self.supabase_url + '/rest/v1/phone_bookings?order=booking_date.desc'")
content = content.replace("f'{self.supabase_url}/rest/v1/phone_bookings?id=eq.{booking_id}'", "self.supabase_url + '/rest/v1/phone_bookings?id=eq.' + booking_id")

# Reemplazar f-strings de error
content = content.replace("f'Error getting products: {e}'", "'Error getting products: ' + str(e)")
content = content.replace("f'Error adding product: {e}'", "'Error adding product: ' + str(e)")
content = content.replace("f'Error updating product: {e}'", "'Error updating product: ' + str(e)")
content = content.replace("f'Error deleting product: {e}'", "'Error deleting product: ' + str(e)")
content = content.replace("f'Error getting banners: {e}'", "'Error getting banners: ' + str(e)")
content = content.replace("f'Error adding banner: {e}'", "'Error adding banner: ' + str(e)")
content = content.replace("f'Error updating banner: {e}'", "'Error updating banner: ' + str(e)")
content = content.replace("f'Error deleting banner: {e}'", "'Error deleting banner: ' + str(e)")
content = content.replace("f'Error getting orders: {e}'", "'Error getting orders: ' + str(e)")
content = content.replace("f'Error getting order: {e}'", "'Error getting order: ' + str(e)")
content = content.replace("f'Error getting recharge history: {e}'", "'Error getting recharge history: ' + str(e)")
content = content.replace("f'Error getting transfers: {e}'", "'Error getting transfers: ' + str(e)")
content = content.replace("f'Error getting categories: {e}'", "'Error getting categories: ' + str(e)")
content = content.replace("f'Error adding category: {e}'", "'Error adding category: ' + str(e)")
content = content.replace("f'Error getting activities: {e}'", "'Error getting activities: ' + str(e)")
content = content.replace("f'Error getting notifications: {e}'", "'Error getting notifications: ' + str(e)")
content = content.replace("f'Error adding notification: {e}'", "'Error adding notification: ' + str(e)")
content = content.replace("f'Error getting config: {e}'", "'Error getting config: ' + str(e)")
content = content.replace("f'Error updating config: {e}'", "'Error updating config: ' + str(e)")
content = content.replace("f'Error getting vehicles: {e}'", "'Error getting vehicles: ' + str(e)")
content = content.replace("f'Error adding vehicle: {e}'", "'Error adding vehicle: ' + str(e)")
content = content.replace("f'Error updating vehicle: {e}'", "'Error updating vehicle: ' + str(e)")
content = content.replace("f'Error deleting vehicle: {e}'", "'Error deleting vehicle: ' + str(e)")
content = content.replace("f'Error getting phone bookings: {e}'", "'Error getting phone bookings: ' + str(e)")
content = content.replace("f'Error adding phone booking: {e}'", "'Error adding phone booking: ' + str(e)")
content = content.replace("f'Error getting phone booking: {e}'", "'Error getting phone booking: ' + str(e)")

# Escribir el archivo corregido
with open('supabase_service.py', 'w') as f:
    f.write(content)

print("Remaining f-strings fixed successfully!")

