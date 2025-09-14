#!/usr/bin/env python3
"""
Script para estandarizar los estilos de todos los archivos HTML del admin
"""

import os
import re

# Lista de archivos HTML del admin
admin_files = [
    'templates/admin/dashboard.html',
    'templates/admin/orders.html',
    'templates/admin/banners.html',
    'templates/admin/vendors.html',
    'templates/admin/drivers.html',
    'templates/admin/vehicles.html',
    'templates/admin/support_chat.html',
    'templates/admin/alerts.html',
    'templates/admin/wallet.html',
    'templates/admin/payment_methods.html',
    'templates/admin/payroll.html',
    'templates/admin/system_rules.html',
    'templates/admin/users.html',
    'templates/admin/flights.html'
]

# CSS común que reemplazará todos los estilos
common_css_links = '''    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="{{ url_for('static', filename='css/admin-common.css') }}" rel="stylesheet">'''

def fix_html_file(file_path):
    """Arreglar un archivo HTML específico"""
    if not os.path.exists(file_path):
        print(f"❌ Archivo no encontrado: {file_path}")
        return False
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Buscar y reemplazar la sección de estilos
        # Patrón para encontrar desde <link href="https://cdn.jsdelivr.net..." hasta </style>
        pattern = r'(<link href="https://cdn\.jsdelivr\.net/npm/bootstrap@5\.1\.3/dist/css/bootstrap\.min\.css" rel="stylesheet">.*?</style>)'
        
        # Reemplazar con los links comunes
        new_content = re.sub(pattern, common_css_links, content, flags=re.DOTALL)
        
        # Si no se encontró el patrón, intentar otro patrón más simple
        if new_content == content:
            # Buscar desde el primer link de bootstrap hasta </style>
            pattern2 = r'(<link href="https://cdn\.jsdelivr\.net.*?</style>)'
            new_content = re.sub(pattern2, common_css_links, content, flags=re.DOTALL)
        
        # Si aún no se encontró, buscar cualquier <style>...</style>
        if new_content == content:
            pattern3 = r'(<style>.*?</style>)'
            new_content = re.sub(pattern3, '', content, flags=re.DOTALL)
            # Agregar los links después del viewport
            new_content = new_content.replace(
                '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
                '<meta name="viewport" content="width=device-width, initial-scale=1.0">\n' + common_css_links
            )
        
        # Escribir el archivo actualizado
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"✅ Archivo actualizado: {file_path}")
        return True
        
    except Exception as e:
        print(f"❌ Error procesando {file_path}: {e}")
        return False

def main():
    """Función principal"""
    print("🔧 Iniciando estandarización de estilos del admin...")
    
    success_count = 0
    total_count = len(admin_files)
    
    for file_path in admin_files:
        if fix_html_file(file_path):
            success_count += 1
    
    print(f"\n📊 Resumen:")
    print(f"✅ Archivos actualizados: {success_count}/{total_count}")
    print(f"❌ Archivos con errores: {total_count - success_count}")
    
    if success_count == total_count:
        print("\n🎉 ¡Todos los archivos han sido actualizados correctamente!")
    else:
        print(f"\n⚠️ {total_count - success_count} archivos necesitan revisión manual")

if __name__ == "__main__":
    main()
