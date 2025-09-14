#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re

def fix_fstrings_in_file(filename):
    """Arreglar todos los f-strings en un archivo"""
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Patrón para encontrar f-strings
    pattern = r"f'([^']*\{[^}]*\}[^']*)'"
    
    def replace_fstring(match):
        fstring_content = match.group(1)
        # Reemplazar {variable} con {}.format(variable)
        formatted_content = re.sub(r'\{([^}]+)\}', r'{}', fstring_content)
        variables = re.findall(r'\{([^}]+)\}', fstring_content)
        
        if variables:
            format_args = ', '.join(variables)
            return "'{}'.format({})".format(formatted_content, format_args)
        else:
            return "'{}'".format(formatted_content)
    
    # Reemplazar todos los f-strings
    new_content = re.sub(pattern, replace_fstring, content)
    
    # También arreglar f"..." strings
    pattern_double = r'f"([^"]*\{[^}]*\}[^"]*)"'
    new_content = re.sub(pattern_double, replace_fstring, new_content)
    
    # Escribir el archivo corregido
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"✅ F-strings arreglados en {filename}")

if __name__ == "__main__":
    fix_fstrings_in_file("admin_routes.py")





