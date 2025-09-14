#!/usr/bin/env python3
"""
Script para arreglar específicamente el archivo products.html
"""

def fix_products_html():
    """Arreglar el archivo products.html"""
    file_path = 'templates/admin/products.html'
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Buscar y eliminar todo el CSS inline
        import re
        
        # Patrón para encontrar desde "body {" hasta "</style>"
        pattern = r'        body \{[^}]*\}.*?</style>'
        new_content = re.sub(pattern, '', content, flags=re.DOTALL)
        
        # Si no se encontró, intentar otro patrón
        if new_content == content:
            # Buscar cualquier bloque de CSS
            pattern2 = r'        body.*?</style>'
            new_content = re.sub(pattern2, '', content, flags=re.DOTALL)
        
        # Escribir el archivo actualizado
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"✅ Archivo products.html actualizado correctamente")
        return True
        
    except Exception as e:
        print(f"❌ Error procesando products.html: {e}")
        return False

if __name__ == "__main__":
    fix_products_html()
