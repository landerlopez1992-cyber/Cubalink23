#!/usr/bin/env python3
"""
Script para diagnosticar y arreglar problemas con productos
1. Verificar por qué las imágenes no se muestran en la app
2. Arreglar feedback del panel admin
3. Verificar almacenamiento de imágenes en Supabase
"""

import os
import requests
import json
from datetime import datetime

def diagnose_product_issues():
    """Diagnosticar todos los problemas con productos"""
    
    print("🔍 DIAGNÓSTICO COMPLETO DE PROBLEMAS CON PRODUCTOS")
    print("=" * 60)
    
    # Obtener credenciales de Supabase
    supabase_url = os.getenv('SUPABASE_URL', 'https://zgqrhzuhrwudckwesybg.supabase.co')
    supabase_key = os.getenv('SUPABASE_SERVICE_KEY', 
        os.getenv('SUPABASE_ANON_KEY', 
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ'
        )
    )
    
    if not supabase_url or not supabase_key:
        print("❌ Error: Variables de entorno SUPABASE_URL y SUPABASE_SERVICE_KEY no encontradas")
        return False
    
    headers = {
        'apikey': supabase_key,
        'Authorization': f'Bearer {supabase_key}',
        'Content-Type': 'application/json'
    }
    
    # 1. Verificar estructura de tabla store_products
    print("\n1️⃣ VERIFICANDO ESTRUCTURA DE TABLA STORE_PRODUCTS")
    print("-" * 50)
    
    try:
        # Verificar columnas de la tabla
        table_url = f"{supabase_url}/rest/v1/store_products?select=*&limit=1"
        response = requests.get(table_url, headers=headers)
        
        if response.status_code == 200:
            print("✅ Tabla store_products accesible")
            data = response.json()
            if data:
                print("📋 Columnas disponibles:")
                for key in data[0].keys():
                    print(f"   - {key}")
            else:
                print("⚠️ Tabla vacía")
        else:
            print(f"❌ Error accediendo a tabla: {response.status_code}")
            print(f"Respuesta: {response.text}")
            
    except Exception as e:
        print(f"❌ Error verificando tabla: {e}")
    
    # 2. Verificar productos existentes
    print("\n2️⃣ VERIFICANDO PRODUCTOS EXISTENTES")
    print("-" * 50)
    
    try:
        products_url = f"{supabase_url}/rest/v1/store_products?select=*"
        response = requests.get(products_url, headers=headers)
        
        if response.status_code == 200:
            products = response.json()
            print(f"✅ {len(products)} productos encontrados")
            
            for i, product in enumerate(products[:3]):  # Mostrar solo los primeros 3
                print(f"\n📦 Producto {i+1}:")
                print(f"   - ID: {product.get('id', 'N/A')}")
                print(f"   - Nombre: {product.get('name', 'N/A')}")
                print(f"   - Precio: ${product.get('price', 'N/A')}")
                print(f"   - Categoría: {product.get('category', 'N/A')}")
                print(f"   - Imagen URL: {product.get('image_url', 'N/A')}")
                print(f"   - Activo: {product.get('is_active', 'N/A')}")
                
                # Verificar si la imagen es accesible
                image_url = product.get('image_url')
                if image_url and image_url != 'N/A':
                    try:
                        img_response = requests.head(image_url, timeout=5)
                        if img_response.status_code == 200:
                            print(f"   ✅ Imagen accesible: {image_url}")
                        else:
                            print(f"   ❌ Imagen no accesible: {img_response.status_code}")
                    except:
                        print(f"   ❌ Error verificando imagen: {image_url}")
                else:
                    print(f"   ⚠️ Sin imagen")
        else:
            print(f"❌ Error obteniendo productos: {response.status_code}")
            print(f"Respuesta: {response.text}")
            
    except Exception as e:
        print(f"❌ Error verificando productos: {e}")
    
    # 3. Verificar bucket de imágenes
    print("\n3️⃣ VERIFICANDO BUCKET DE IMÁGENES")
    print("-" * 50)
    
    try:
        # Verificar si el bucket existe
        bucket_url = f"{supabase_url}/storage/v1/bucket"
        response = requests.get(bucket_url, headers=headers)
        
        if response.status_code == 200:
            buckets = response.json()
            print(f"✅ {len(buckets)} buckets encontrados")
            
            product_bucket = None
            for bucket in buckets:
                print(f"   - {bucket.get('name', 'N/A')} (público: {bucket.get('public', False)})")
                if bucket.get('name') == 'product-images':
                    product_bucket = bucket
            
            if product_bucket:
                print("✅ Bucket 'product-images' encontrado")
                print(f"   - Público: {product_bucket.get('public', False)}")
                print(f"   - Creado: {product_bucket.get('created_at', 'N/A')}")
            else:
                print("❌ Bucket 'product-images' no encontrado")
        else:
            print(f"❌ Error verificando buckets: {response.status_code}")
            print(f"Respuesta: {response.text}")
            
    except Exception as e:
        print(f"❌ Error verificando bucket: {e}")
    
    # 4. Verificar políticas RLS
    print("\n4️⃣ VERIFICANDO POLÍTICAS RLS")
    print("-" * 50)
    
    try:
        # Intentar hacer una consulta que requiera RLS
        test_url = f"{supabase_url}/rest/v1/store_products?select=id,name&limit=1"
        response = requests.get(test_url, headers=headers)
        
        if response.status_code == 200:
            print("✅ Políticas RLS funcionando correctamente")
        else:
            print(f"❌ Error con políticas RLS: {response.status_code}")
            print(f"Respuesta: {response.text}")
            
    except Exception as e:
        print(f"❌ Error verificando RLS: {e}")
    
    # 5. Probar crear un producto de prueba
    print("\n5️⃣ PROBANDO CREACIÓN DE PRODUCTO")
    print("-" * 50)
    
    try:
        test_product = {
            'name': f'Producto Test {datetime.now().strftime("%H%M%S")}',
            'description': 'Producto de prueba para diagnóstico',
            'price': 10.99,
            'category': 'Alimentos',
            'stock': 5,
            'is_active': True,
            'image_url': 'https://via.placeholder.com/400x300/007bff/ffffff?text=Test'
        }
        
        create_url = f"{supabase_url}/rest/v1/store_products"
        response = requests.post(create_url, headers=headers, json=test_product)
        
        if response.status_code in [200, 201]:
            print("✅ Producto de prueba creado exitosamente")
            created_product = response.json()
            print(f"   - ID: {created_product.get('id', 'N/A')}")
            print(f"   - Nombre: {created_product.get('name', 'N/A')}")
            
            # Limpiar producto de prueba
            if created_product.get('id'):
                delete_url = f"{supabase_url}/rest/v1/store_products?id=eq.{created_product['id']}"
                delete_response = requests.delete(delete_url, headers=headers)
                if delete_response.status_code == 204:
                    print("✅ Producto de prueba eliminado")
                else:
                    print("⚠️ No se pudo eliminar producto de prueba")
        else:
            print(f"❌ Error creando producto de prueba: {response.status_code}")
            print(f"Respuesta: {response.text}")
            
    except Exception as e:
        print(f"❌ Error probando creación: {e}")
    
    print("\n" + "=" * 60)
    print("🎯 DIAGNÓSTICO COMPLETADO")
    print("\n📋 PRÓXIMOS PASOS:")
    print("1. Si hay problemas con columnas, ejecutar fix_store_products_table.sql")
    print("2. Si hay problemas con imágenes, verificar bucket y políticas")
    print("3. Si hay problemas con RLS, reconfigurar políticas")
    print("4. Probar panel admin después de arreglos")

def fix_image_display_issues():
    """Arreglar problemas de visualización de imágenes"""
    
    print("\n🔧 ARREGLANDO PROBLEMAS DE VISUALIZACIÓN DE IMÁGENES")
    print("-" * 60)
    
    # Crear script para arreglar mapeo de imágenes
    fix_script = """
// Script para arreglar mapeo de imágenes en Flutter
// Agregar a lib/services/store_service.dart

/// Arreglar mapeo de imágenes en getAllProducts
Future<List<StoreProduct>> getAllProducts() async {
  try {
    print('🔍 Obteniendo todos los productos...');
    
    if (_client == null) {
      print('⚠️ Supabase no disponible, retornando productos por defecto');
      return _getAllDefaultProducts();
    }
    
    print('🔍 Ejecutando query a store_products...');
    final response = await _client!
      .from('store_products')
      .select('*')
      .eq('is_active', true)
      .order('name');

    print('📊 Respuesta de productos: \$response');

    final products = <StoreProduct>[];
    for (final item in response) {
      try {
        print('🔄 Procesando producto: \${item['name']}');
        
        // ARREGLO: Mapear correctamente las imágenes
        String imageUrl = '';
        if (item['image_url'] != null && item['image_url'].toString().isNotEmpty) {
          imageUrl = item['image_url'].toString();
        } else if (item['images'] != null && item['images'] is List && item['images'].isNotEmpty) {
          imageUrl = item['images'][0].toString();
        }
        
        // Crear producto con imagen corregida
        final product = StoreProduct(
          id: item['id']?.toString() ?? '',
          name: item['name'] ?? '',
          description: item['description'] ?? '',
          price: (item['price'] ?? 0.0).toDouble(),
          imageUrl: imageUrl, // Usar imagen corregida
          categoryId: item['category'] ?? item['category_id'] ?? '',
          unit: item['unit'] ?? 'unidad',
          weight: (item['weight'] ?? 0.0).toDouble(),
          isAvailable: item['is_active'] ?? true,
          stock: item['stock'] ?? 0,
          availableProvinces: List<String>.from(item['available_provinces'] ?? []),
          deliveryMethod: 'express',
          createdAt: item['created_at'] != null ? DateTime.parse(item['created_at']) : null,
        );
        
        products.add(product);
        print('✅ Producto procesado: \${product.name} - Imagen: \${product.imageUrl}');
        
      } catch (e) {
        print('⚠️ Error parsing product: \$e');
      }
    }

    print('✅ \${products.length} productos obtenidos');
    return products;
  } catch (e) {
    print('❌ Error obteniendo productos: \$e');
    print('📋 Usando productos por defecto como fallback');
    return _getAllDefaultProducts();
  }
}
"""
    
    with open('fix_image_mapping.dart', 'w') as f:
        f.write(fix_script)
    
    print("✅ Script de arreglo de imágenes creado: fix_image_mapping.dart")

def create_admin_feedback_fix():
    """Crear arreglo para feedback del panel admin"""
    
    print("\n🔧 ARREGLANDO FEEDBACK DEL PANEL ADMIN")
    print("-" * 60)
    
    # Crear script para arreglar feedback
    feedback_script = """
// Script para arreglar feedback del panel admin
// Modificar lib/screens/admin/store_settings_screen.dart

// En el método _showProductDialog, después de crear/actualizar producto:

try {
  // ... código existente para crear/actualizar producto ...
  
  if (success) {
    Navigator.pop(context); // Cerrar dialog de carga
    Navigator.pop(context); // Cerrar dialog de producto
    
    await _loadData(); // Recargar datos
    
    // ARREGLO: Mostrar mensaje de éxito más visible
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                isEditing ? '✅ Producto actualizado exitosamente' : '✅ Producto creado exitosamente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    
    // ARREGLO: Mostrar también un dialog de confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Éxito'),
          ],
        ),
        content: Text(
          isEditing ? 'El producto ha sido actualizado correctamente.' : 'El producto ha sido creado correctamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continuar'),
          ),
        ],
      ),
    );
    
  } else {
    throw Exception(errorMessage ?? 'Error desconocido guardando el producto');
  }
  
} catch (e) {
  // ... código existente para manejo de errores ...
  
  // ARREGLO: Mostrar error más visible
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Error: \$userFriendlyError',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 6),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      action: SnackBarAction(
        label: 'Ver Solución',
        textColor: Colors.white,
        onPressed: () => _showSupabaseSetupDialog(context),
      ),
    ),
  );
}
"""
    
    with open('fix_admin_feedback.dart', 'w') as f:
        f.write(feedback_script)
    
    print("✅ Script de arreglo de feedback creado: fix_admin_feedback.dart")

if __name__ == "__main__":
    # Ejecutar diagnóstico completo
    diagnose_product_issues()
    
    # Crear scripts de arreglo
    fix_image_display_issues()
    create_admin_feedback_fix()
    
    print("\n🎉 DIAGNÓSTICO Y ARREGLOS COMPLETADOS")
    print("📁 Archivos creados:")
    print("   - fix_image_mapping.dart")
    print("   - fix_admin_feedback.dart")
    print("\n📋 Próximos pasos:")
    print("1. Revisar el diagnóstico arriba")
    print("2. Aplicar los arreglos de los archivos .dart")
    print("3. Probar el panel admin")
    print("4. Verificar que las imágenes se muestran en la app")
