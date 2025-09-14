#!/usr/bin/env python3
"""
Sistema mejorado de upload de imágenes para productos
Se integra automáticamente con Supabase Storage
"""

import os
import requests
import base64
import uuid
import json
from datetime import datetime

class ImprovedImageUploader:
    """Clase para manejar upload de imágenes con retry automático"""
    
    def __init__(self):
        self.supabase_url = os.getenv('SUPABASE_URL', 'https://zgqrhzuhrwudckwesybg.supabase.co')
        self.supabase_key = os.getenv('SUPABASE_SERVICE_KEY', 
            os.getenv('SUPABASE_ANON_KEY', 
                'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
            )
        )
        self.bucket_name = 'product-images'
        
    def upload_image_to_supabase(self, image_base64, product_name):
        """
        Subir imagen a Supabase Storage con sistema mejorado
        """
        try:
            print(f"📸 Iniciando upload de imagen para producto: {product_name}")
            
            # 1. Validar datos de entrada
            if not image_base64 or not product_name:
                print("❌ Datos inválidos para upload")
                return self._get_placeholder_url(product_name)
            
            # 2. Procesar imagen base64
            image_data, file_extension, mime_type = self._process_base64_image(image_base64)
            if not image_data:
                print("❌ Error procesando imagen base64")
                return self._get_placeholder_url(product_name)
            
            # 3. Generar nombre único
            filename = self._generate_unique_filename(product_name, file_extension)
            
            # 4. Intentar upload con retry
            upload_url = self._upload_with_retry(image_data, filename, mime_type)
            
            if upload_url:
                print(f"✅ Imagen subida exitosamente: {upload_url}")
                return upload_url
            else:
                print("❌ Falló upload después de todos los intentos")
                return self._get_placeholder_url(product_name)
                
        except Exception as e:
            print(f"❌ Error en upload_image_to_supabase: {e}")
            return self._get_placeholder_url(product_name)
    
    def _process_base64_image(self, image_base64):
        """Procesar y validar imagen base64"""
        try:
            # Separar header y datos
            if ',' in image_base64:
                header, data = image_base64.split(',', 1)
            else:
                # Asumir que es solo datos sin header
                header = 'data:image/jpeg;base64'
                data = image_base64
            
            # Determinar tipo de archivo
            if 'image/png' in header:
                file_extension = 'png'
                mime_type = 'image/png'
            elif 'image/gif' in header:
                file_extension = 'gif'
                mime_type = 'image/gif'
            elif 'image/webp' in header:
                file_extension = 'webp'
                mime_type = 'image/webp'
            else:
                file_extension = 'jpg'
                mime_type = 'image/jpeg'
            
            # Decodificar datos
            image_data = base64.b64decode(data)
            
            # Validar tamaño
            if len(image_data) > 50 * 1024 * 1024:  # 50MB
                print("⚠️ Imagen muy grande, puede fallar el upload")
            
            print(f"📊 Imagen procesada: {len(image_data)} bytes, tipo: {mime_type}")
            return image_data, file_extension, mime_type
            
        except Exception as e:
            print(f"❌ Error procesando imagen base64: {e}")
            return None, None, None
    
    def _generate_unique_filename(self, product_name, file_extension):
        """Generar nombre único para el archivo"""
        # Limpiar nombre del producto
        clean_name = "".join(c for c in product_name if c.isalnum() or c in (' ', '-', '_')).strip()
        clean_name = clean_name.replace(' ', '_')[:30]  # Limitar longitud
        
        # Agregar timestamp e ID único
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        unique_id = str(uuid.uuid4())[:8]
        
        filename = f"{clean_name}_{timestamp}_{unique_id}.{file_extension}"
        return filename
    
    def _upload_with_retry(self, image_data, filename, mime_type, max_retries=3):
        """Intentar upload con sistema de retry"""
        
        for attempt in range(max_retries):
            print(f"🔄 Intento {attempt + 1}/{max_retries} de upload...")
            
            try:
                # Headers para upload
                headers = {
                    'apikey': self.supabase_key,
                    'Authorization': f'Bearer {self.supabase_key}',
                    'Content-Type': mime_type,
                    'x-upsert': 'true'  # Permitir sobrescribir si existe
                }
                
                # URL de upload
                upload_url = f"{self.supabase_url}/storage/v1/object/{self.bucket_name}/{filename}"
                
                # Realizar upload
                response = requests.post(upload_url, headers=headers, data=image_data, timeout=30)
                
                if response.status_code in [200, 201]:
                    # Upload exitoso, generar URL pública
                    public_url = f"{self.supabase_url}/storage/v1/object/public/{self.bucket_name}/{filename}"
                    
                    # Verificar que la URL funciona
                    if self._verify_image_url(public_url):
                        return public_url
                    else:
                        print("⚠️ URL generada no es accesible")
                        
                elif response.status_code == 409:
                    # Archivo ya existe, generar nuevo nombre
                    print("⚠️ Archivo ya existe, generando nuevo nombre...")
                    filename = self._generate_unique_filename(f"retry_{attempt}", filename.split('.')[-1])
                    continue
                    
                else:
                    print(f"❌ Error en upload: {response.status_code}")
                    print(f"Respuesta: {response.text[:200]}")
                    
            except requests.exceptions.Timeout:
                print("⏱️ Timeout en upload, reintentando...")
            except Exception as e:
                print(f"❌ Error en intento {attempt + 1}: {e}")
            
            # Esperar antes del siguiente intento
            if attempt < max_retries - 1:
                import time
                time.sleep(2 ** attempt)  # Backoff exponencial
        
        return None
    
    def _verify_image_url(self, url):
        """Verificar que la URL de imagen es accesible"""
        try:
            response = requests.head(url, timeout=10)
            return response.status_code == 200
        except:
            return False
    
    def _get_placeholder_url(self, product_name):
        """Generar URL de placeholder cuando falla el upload"""
        clean_name = product_name.replace(' ', '%20')
        return f'https://via.placeholder.com/400x300/007bff/ffffff?text={clean_name}'

# Función global para compatibilidad con código existente
def upload_image_to_supabase(image_base64, product_name):
    """Función wrapper para compatibilidad"""
    uploader = ImprovedImageUploader()
    return uploader.upload_image_to_supabase(image_base64, product_name)

# Función para probar el sistema
def test_image_upload():
    """Función de prueba para el sistema de upload"""
    print("🧪 Probando sistema de upload de imágenes...")
    
    # Crear imagen de prueba simple
    test_image_b64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="
    full_b64 = f"data:image/png;base64,{test_image_b64}"
    
    uploader = ImprovedImageUploader()
    result = uploader.upload_image_to_supabase(full_b64, "Producto de Prueba")
    
    if result and 'placeholder' not in result:
        print(f"✅ Prueba exitosa: {result}")
        return True
    else:
        print(f"⚠️ Prueba falló: {result}")
        return False

if __name__ == "__main__":
    test_image_upload()
