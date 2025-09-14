#!/usr/bin/env python3
"""
Script para arreglar la indentación en todos los archivos HTML del admin
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
    'templates/admin/flights.html',
    'templates/admin/products.html',
    'templates/admin/system.html'
]

def fix_html_indentation(file_path):
    """Arreglar la indentación de un archivo HTML"""
    if not os.path.exists(file_path):
        print(f"❌ Archivo no encontrado: {file_path}")
        return False
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Arreglar indentación incorrecta en los links
        # Buscar líneas que empiecen con espacios extra
        lines = content.split('\n')
        fixed_lines = []
        
        for line in lines:
            # Si la línea tiene indentación incorrecta en los links
            if re.match(r'^\s{8,}<link', line):
                # Corregir a 4 espacios
                fixed_line = re.sub(r'^\s+', '    ', line)
                fixed_lines.append(fixed_line)
            else:
                fixed_lines.append(line)
        
        # Unir las líneas
        new_content = '\n'.join(fixed_lines)
        
        # Escribir el archivo actualizado
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"✅ Indentación arreglada: {file_path}")
        return True
        
    except Exception as e:
        print(f"❌ Error procesando {file_path}: {e}")
        return False

def main():
    """Función principal"""
    print("🔧 Arreglando indentación en archivos HTML...")
    
    success_count = 0
    total_count = len(admin_files)
    
    for file_path in admin_files:
        if fix_html_indentation(file_path):
            success_count += 1
    
    print(f"\n📊 Resumen:")
    print(f"✅ Archivos arreglados: {success_count}/{total_count}")
    print(f"❌ Archivos con errores: {total_count - success_count}")
    
    if success_count == total_count:
        print("\n🎉 ¡Todos los archivos han sido arreglados!")
    else:
        print(f"\n⚠️ {total_count - success_count} archivos necesitan revisión manual")

if __name__ == "__main__":
    main()
