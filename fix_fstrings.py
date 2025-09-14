#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re

# Leer el archivo
with open('supabase_service.py', 'r') as f:
    content = f.read()

# Reemplazar f-strings con concatenación de strings
replacements = [
    (r"f'\{self\.supabase_url\}/rest/v1/users'", "self.supabase_url + '/rest/v1/users'"),
    (r"f'\{self\.supabase_url\}/rest/v1/users\?id=eq\.\{user_id\}'", "self.supabase_url + '/rest/v1/users?id=eq.' + user_id"),
    (r"f'\{self\.supabase_url\}/rest/v1/products\?select=\*'", "self.supabase_url + '/rest/v1/products?select=*'"),
    (r"f'\{self\.supabase_url\}/rest/v1/products'", "self.supabase_url + '/rest/v1/products'"),
    (r"f'\{self\.supabase_url\}/rest/v1/products\?id=eq\.\{product_id\}'", "self.supabase_url + '/rest/v1/products?id=eq.' + product_id"),
    (r"f'\{self\.supabase_url\}/rest/v1/banners\?select=\*'", "self.supabase_url + '/rest/v1/banners?select=*'"),
    (r"f'\{self\.supabase_url\}/rest/v1/banners'", "self.supabase_url + '/rest/v1/banners'"),
    (r"f'\{self\.supabase_url\}/rest/v1/banners\?id=eq\.\{banner_id\}'", "self.supabase_url + '/rest/v1/banners?id=eq.' + banner_id"),
    (r"f'\{self\.supabase_url\}/rest/v1/orders'", "self.supabase_url + '/rest/v1/orders'"),
    (r"f'\{self\.supabase_url\}/rest/v1/orders\?id=eq\.\{order_id\}'", "self.supabase_url + '/rest/v1/orders?id=eq.' + order_id"),
    (r"f'\{self\.supabase_url\}/rest/v1/recharge_history'", "self.supabase_url + '/rest/v1/recharge_history'"),
    (r"f'\{self\.supabase_url\}/rest/v1/transfers'", "self.supabase_url + '/rest/v1/transfers'"),
    (r"f'\{self\.supabase_url\}/rest/v1/store_categories'", "self.supabase_url + '/rest/v1/store_categories'"),
    (r"f'\{self\.supabase_url\}/rest/v1/activities'", "self.supabase_url + '/rest/v1/activities'"),
    (r"f'\{self\.supabase_url\}/rest/v1/notifications'", "self.supabase_url + '/rest/v1/notifications'"),
    (r"f'\{self\.supabase_url\}/rest/v1/app_config'", "self.supabase_url + '/rest/v1/app_config'"),
    (r"f'\{self\.supabase_url\}/rest/v1/app_config\?id=eq\.1'", "self.supabase_url + '/rest/v1/app_config?id=eq.1'"),
    (r"f'\{self\.supabase_url\}/rest/v1/users\?select=count'", "self.supabase_url + '/rest/v1/users?select=count'"),
    (r"f'\{self\.supabase_url\}/rest/v1/products\?select=count'", "self.supabase_url + '/rest/v1/products?select=count'"),
    (r"f'\{self\.supabase_url\}/rest/v1/orders\?select=count'", "self.supabase_url + '/rest/v1/orders?select=count'"),
    (r"f'\{self\.supabase_url\}/rest/v1/vehicles'", "self.supabase_url + '/rest/v1/vehicles'"),
    (r"f'\{self\.supabase_url\}/rest/v1/vehicles\?order=created_at\.desc'", "self.supabase_url + '/rest/v1/vehicles?order=created_at.desc'"),
    (r"f'\{self\.supabase_url\}/rest/v1/vehicles\?id=eq\.\{vehicle_id\}'", "self.supabase_url + '/rest/v1/vehicles?id=eq.' + vehicle_id"),
    (r"f'\{self\.supabase_url\}/rest/v1/phone_bookings'", "self.supabase_url + '/rest/v1/phone_bookings'"),
    (r"f'\{self\.supabase_url\}/rest/v1/phone_bookings\?order=booking_date\.desc'", "self.supabase_url + '/rest/v1/phone_bookings?order=booking_date.desc'"),
    (r"f'\{self\.supabase_url\}/rest/v1/phone_bookings\?id=eq\.\{booking_id\}'", "self.supabase_url + '/rest/v1/phone_bookings?id=eq.' + booking_id"),
]

# Aplicar reemplazos
for pattern, replacement in replacements:
    content = re.sub(pattern, replacement, content)

# Reemplazar f-strings de error
content = re.sub(r"f'Error getting users: \{e\}'", "'Error getting users: ' + str(e)", content)
content = re.sub(r"f'Error getting user: \{e\}'", "'Error getting user: ' + str(e)", content)
content = re.sub(r"f'Error updating user status: \{e\}'", "'Error updating user status: ' + str(e)", content)
content = re.sub(r"f'Error adding user: \{response\.text\}'", "'Error adding user: ' + response.text", content)
content = re.sub(r"f'Error adding user: \{e\}'", "'Error adding user: ' + str(e)", content)
content = re.sub(r"f'Error updating user: \{response\.text\}'", "'Error updating user: ' + response.text", content)
content = re.sub(r"f'Error updating user: \{e\}'", "'Error updating user: ' + str(e)", content)
content = re.sub(r"f'Error deleting user: \{e\}'", "'Error deleting user: ' + str(e)", content)

# Escribir el archivo corregido
with open('supabase_service.py', 'w') as f:
    f.write(content)

print("F-strings fixed successfully!")
