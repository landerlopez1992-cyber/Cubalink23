#!/usr/bin/env python3
"""
🔄 ROLLBACK AUTOMÁTICO PARA DUFFEL
Este script restaura automáticamente el backend de Duffel
cuando se detecta que ha sido dañado.
"""

import os
import shutil
import glob
from datetime import datetime

class DuffelAutoRollback:
    def __init__(self):
        self.backup_dir = "BACKUPS_DUFFEL_FUNCIONANDO"
        self.critical_files = ['app.py', 'duffel_service.py']
        
    def find_latest_backup(self, file_name):
        """Encontrar el backup más reciente de un archivo"""
        pattern = os.path.join(self.backup_dir, f"{file_name}_FUNCIONANDO_*.py")
        backups = glob.glob(pattern)
        
        if not backups:
            return None
            
        # Ordenar por fecha (el más reciente al final)
        backups.sort()
        return backups[-1]
        
    def is_file_damaged(self, file_name):
        """Detectar si un archivo ha sido dañado"""
        if not os.path.exists(file_name):
            return True, "Archivo no existe"
            
        with open(file_name, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Verificar patrones que indican daño
        damage_indicators = [
            "/places?query=",  # Endpoint incorrecto
            "'name': query,",  # Parámetro incorrecto
            "endpoint incorrecto",  # Comentario de error
        ]
        
        for indicator in damage_indicators:
            if indicator in content:
                return True, f"Contiene patrón dañado: {indicator}"
                
        # Verificar que tenga los patrones correctos
        correct_patterns = [
            "/air/airports?search=",  # Endpoint correcto
            "'search': query,",  # Parámetro correcto
        ]
        
        for pattern in correct_patterns:
            if pattern not in content:
                return True, f"Falta patrón correcto: {pattern}"
                
        return False, "Archivo en buen estado"
        
    def rollback_file(self, file_name):
        """Hacer rollback de un archivo específico"""
        print(f"🔄 Verificando {file_name}...")
        
        is_damaged, reason = self.is_file_damaged(file_name)
        
        if not is_damaged:
            print(f"   ✅ {file_name} está en buen estado")
            return True
            
        print(f"   ❌ {file_name} está dañado: {reason}")
        
        # Buscar backup
        latest_backup = self.find_latest_backup(file_name)
        
        if not latest_backup:
            print(f"   💥 No hay backup disponible para {file_name}")
            return False
            
        # Hacer rollback
        try:
            shutil.copy2(latest_backup, file_name)
            print(f"   ✅ {file_name} restaurado desde {os.path.basename(latest_backup)}")
            return True
        except Exception as e:
            print(f"   💥 Error restaurando {file_name}: {str(e)}")
            return False
            
    def run_rollback(self):
        """Ejecutar rollback completo"""
        print("🔄 ROLLBACK AUTOMÁTICO DUFFEL")
        print("=" * 40)
        
        if not os.path.exists(self.backup_dir):
            print(f"❌ Directorio de backups no existe: {self.backup_dir}")
            print("💡 Ejecutar PROTECCION_BACKEND_DUFFEL.py primero")
            return False
            
        all_success = True
        
        for file_name in self.critical_files:
            success = self.rollback_file(file_name)
            if not success:
                all_success = False
                
        print("=" * 40)
        
        if all_success:
            print("🎉 ROLLBACK COMPLETADO EXITOSAMENTE")
            print("✅ Backend Duffel restaurado")
        else:
            print("❌ ROLLBACK PARCIAL - REVISAR MANUALMENTE")
            
        return all_success

if __name__ == "__main__":
    rollback = DuffelAutoRollback()
    rollback.run_rollback()
