#!/usr/bin/env python3
"""
🛡️ SISTEMA DE PROTECCIÓN PARA BACKEND DUFFEL
Este script protege los archivos críticos del backend de Duffel
y previene que agentes dañen funcionalidades que ya están trabajando.
"""

import os
import shutil
import hashlib
import json
from datetime import datetime

class DuffelBackendProtector:
    def __init__(self):
        self.critical_files = {
            'app.py': {
                'critical_lines': [
                    "url = f'https://api.duffel.com/air/airports?search={query}&limit=20'",
                    "if place.get('type') == 'airport':",
                    "airport_data = {"
                ],
                'forbidden_patterns': [
                    "/places?query=",
                    "url = f'https://api.duffel.com/places",
                    "endpoint incorrecto"
                ]
            },
            'duffel_service.py': {
                'critical_lines': [
                    "'search': query,",
                    "'limit': 20"
                ],
                'forbidden_patterns': [
                    "'name': query,",
                    "/places"
                ]
            }
        }
        
        self.backup_dir = "BACKUPS_DUFFEL_FUNCIONANDO"
        self.protection_log = "PROTECCION_DUFFEL_LOG.txt"
        
    def create_backup(self):
        """Crear backup de archivos críticos"""
        if not os.path.exists(self.backup_dir):
            os.makedirs(self.backup_dir)
            
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        for file_name in self.critical_files.keys():
            if os.path.exists(file_name):
                backup_name = f"{file_name}_FUNCIONANDO_{timestamp}.py"
                backup_path = os.path.join(self.backup_dir, backup_name)
                shutil.copy2(file_name, backup_path)
                print(f"✅ Backup creado: {backup_path}")
                
    def validate_file(self, file_name):
        """Validar que el archivo no haya sido dañado"""
        if not os.path.exists(file_name):
            return False, f"Archivo {file_name} no existe"
            
        with open(file_name, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Verificar líneas críticas
        for critical_line in self.critical_files[file_name]['critical_lines']:
            if critical_line not in content:
                return False, f"Línea crítica faltante: {critical_line}"
                
        # Verificar patrones prohibidos
        for forbidden_pattern in self.critical_files[file_name]['forbidden_patterns']:
            if forbidden_pattern in content:
                return False, f"Patrón prohibido encontrado: {forbidden_pattern}"
                
        return True, "Archivo válido"
        
    def restore_backup(self, file_name):
        """Restaurar desde el backup más reciente"""
        if not os.path.exists(self.backup_dir):
            print(f"❌ No hay backups disponibles para {file_name}")
            return False
            
        # Buscar el backup más reciente
        backups = [f for f in os.listdir(self.backup_dir) if f.startswith(f"{file_name}_FUNCIONANDO_")]
        if not backups:
            print(f"❌ No hay backups de {file_name}")
            return False
            
        latest_backup = sorted(backups)[-1]
        backup_path = os.path.join(self.backup_dir, latest_backup)
        
        shutil.copy2(backup_path, file_name)
        print(f"✅ Restaurado desde backup: {latest_backup}")
        return True
        
    def log_protection_event(self, event_type, file_name, message):
        """Registrar eventos de protección"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] {event_type}: {file_name} - {message}\n"
        
        with open(self.protection_log, 'a', encoding='utf-8') as f:
            f.write(log_entry)
            
    def run_protection(self):
        """Ejecutar sistema de protección"""
        print("🛡️ INICIANDO SISTEMA DE PROTECCIÓN DUFFEL")
        print("=" * 50)
        
        # Crear backup inicial
        self.create_backup()
        
        # Validar archivos críticos
        for file_name in self.critical_files.keys():
            is_valid, message = self.validate_file(file_name)
            
            if is_valid:
                print(f"✅ {file_name}: {message}")
            else:
                print(f"❌ {file_name}: {message}")
                print(f"🔄 Restaurando desde backup...")
                
                if self.restore_backup(file_name):
                    self.log_protection_event("RESTAURADO", file_name, message)
                    print(f"✅ {file_name} restaurado exitosamente")
                else:
                    self.log_protection_event("ERROR", file_name, f"No se pudo restaurar: {message}")
                    print(f"❌ No se pudo restaurar {file_name}")
                    
        print("=" * 50)
        print("🛡️ PROTECCIÓN COMPLETADA")

if __name__ == "__main__":
    protector = DuffelBackendProtector()
    protector.run_protection()
