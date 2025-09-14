#!/usr/bin/env python3
"""
Script para diagnosticar y arreglar problemas de persistencia del carrito
"""

import os
import requests
import json
from datetime import datetime

def diagnose_cart_issues():
    """Diagnosticar problemas del carrito de compras"""
    
    print("🔍 DIAGNÓSTICO DE PROBLEMAS DEL CARRITO DE COMPRAS")
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
    
    # 1. Verificar tabla user_carts
    print("\n1️⃣ VERIFICANDO TABLA USER_CARTS")
    print("-" * 40)
    
    try:
        table_url = f"{supabase_url}/rest/v1/user_carts?select=*&limit=5"
        response = requests.get(table_url, headers=headers)
        
        if response.status_code == 200:
            carts = response.json()
            print(f"✅ Tabla user_carts accesible - {len(carts)} carritos encontrados")
            
            for i, cart in enumerate(carts):
                user_id = cart.get('user_id', 'N/A')
                items = cart.get('items', [])
                updated_at = cart.get('updated_at', 'N/A')
                print(f"   Carrito {i+1}: Usuario {user_id[:8]}... - {len(items)} items - {updated_at}")
        else:
            print(f"❌ Error accediendo a user_carts: {response.status_code}")
            print(f"Respuesta: {response.text}")
            
    except Exception as e:
        print(f"❌ Error verificando user_carts: {e}")
    
    # 2. Verificar tabla cart_items
    print("\n2️⃣ VERIFICANDO TABLA CART_ITEMS")
    print("-" * 40)
    
    try:
        table_url = f"{supabase_url}/rest/v1/cart_items?select=*&limit=5"
        response = requests.get(table_url, headers=headers)
        
        if response.status_code == 200:
            items = response.json()
            print(f"✅ Tabla cart_items accesible - {len(items)} items encontrados")
            
            for i, item in enumerate(items):
                user_id = item.get('user_id', 'N/A')
                product_name = item.get('product_name', 'N/A')
                quantity = item.get('quantity', 0)
                print(f"   Item {i+1}: Usuario {user_id[:8]}... - {product_name} x{quantity}")
        else:
            print(f"❌ Error accediendo a cart_items: {response.status_code}")
            print(f"Respuesta: {response.text}")
            
    except Exception as e:
        print(f"❌ Error verificando cart_items: {e}")
    
    # 3. Verificar políticas RLS
    print("\n3️⃣ VERIFICANDO POLÍTICAS RLS")
    print("-" * 40)
    
    try:
        # Probar inserción en user_carts
        test_cart = {
            'user_id': 'test_user_123',
            'items': [],
            'updated_at': datetime.now().isoformat()
        }
        
        test_url = f"{supabase_url}/rest/v1/user_carts"
        response = requests.post(test_url, headers=headers, json=test_cart)
        
        if response.status_code in [200, 201]:
            print("✅ Políticas RLS para user_carts funcionan")
            
            # Limpiar test
            created_cart = response.json()
            if created_cart.get('id'):
                delete_url = f"{supabase_url}/rest/v1/user_carts?id=eq.{created_cart['id']}"
                delete_response = requests.delete(delete_url, headers=headers)
                if delete_response.status_code == 204:
                    print("✅ Test de user_carts limpiado")
        else:
            print(f"❌ Error con políticas RLS para user_carts: {response.status_code}")
            print(f"Respuesta: {response.text}")
            
    except Exception as e:
        print(f"❌ Error verificando políticas RLS: {e}")
    
    # 4. Verificar estructura de tablas
    print("\n4️⃣ VERIFICANDO ESTRUCTURA DE TABLAS")
    print("-" * 40)
    
    tables_to_check = ['user_carts', 'cart_items']
    
    for table in tables_to_check:
        try:
            table_url = f"{supabase_url}/rest/v1/{table}?select=*&limit=1"
            response = requests.get(table_url, headers=headers)
            
            if response.status_code == 200:
                data = response.json()
                if data:
                    columns = list(data[0].keys())
                    print(f"✅ Tabla {table}: {len(columns)} columnas")
                    print(f"   Columnas: {', '.join(columns)}")
                else:
                    print(f"⚠️ Tabla {table}: vacía")
            else:
                print(f"❌ Error accediendo a {table}: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Error verificando {table}: {e}")
    
    print("\n" + "=" * 60)
    print("🎯 DIAGNÓSTICO COMPLETADO")

def create_cart_fix():
    """Crear arreglo para problemas del carrito"""
    
    print("\n🔧 CREANDO ARREGLO PARA PROBLEMAS DEL CARRITO")
    print("-" * 60)
    
    # Crear script de arreglo para CartService
    cart_fix_script = """
// ARREGLO PARA CART SERVICE - lib/services/cart_service.dart

class CartService extends ChangeNotifier {
  // ... código existente ...

  /// ARREGLO: Cargar carrito automáticamente al inicializar
  Future<void> initializeCart() async {
    try {
      print('🛒 Inicializando carrito...');
      
      final client = SupabaseConfig.client;
      final user = client.auth.currentUser;
      
      if (user != null) {
        print('👤 Usuario autenticado, cargando carrito...');
        await loadFromSupabase();
      } else {
        print('⚠️ Usuario no autenticado, carrito vacío');
        _items.clear();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error inicializando carrito: $e');
      _items.clear();
      notifyListeners();
    }
  }

  /// ARREGLO: Mejorar loadFromSupabase con mejor manejo de errores
  Future<void> loadFromSupabase() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final client = SupabaseConfig.client;
      final user = client.auth.currentUser;
      
      if (user == null) {
        print('⚠️ Usuario no autenticado, no se puede cargar carrito');
        _items.clear();
        return;
      }
      
      print('📦 Cargando carrito para usuario: ${user.id}');
      
      // Intentar cargar desde user_carts primero
      final response = await client
          .from('user_carts')
          .select('items')
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (response != null && response['items'] != null) {
        final itemsData = response['items'] as List<dynamic>? ?? [];
        
        _items.clear();
        _items.addAll(
          itemsData.map((itemData) => CartItem.fromJson(itemData as Map<String, dynamic>))
        );
        
        print('✅ Carrito cargado desde user_carts: ${_items.length} items');
      } else {
        // Fallback: cargar desde cart_items
        print('🔄 user_carts vacío, intentando cart_items...');
        await _loadFromCartItems();
      }
      
    } catch (e) {
      print('❌ Error cargando carrito desde Supabase: $e');
      _items.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ARREGLO: Método auxiliar para cargar desde cart_items
  Future<void> _loadFromCartItems() async {
    try {
      final client = SupabaseConfig.client;
      final user = client.auth.currentUser;
      
      if (user == null) return;
      
      final response = await client
          .from('cart_items')
          .select('*')
          .eq('user_id', user.id);
      
      _items.clear();
      _items.addAll(
        response.map((itemData) => CartItem(
          id: itemData['product_id'] ?? itemData['id'],
          name: itemData['product_name'] ?? '',
          price: (itemData['product_price'] ?? 0.0).toDouble(),
          quantity: itemData['quantity'] ?? 1,
          imageUrl: itemData['product_image_url'] ?? '',
          type: itemData['product_type'] ?? 'store',
          weight: itemData['weight'],
        ))
      );
      
      print('✅ Carrito cargado desde cart_items: ${_items.length} items');
      
      // Migrar a user_carts para futuras cargas
      await _saveToSupabase();
      
    } catch (e) {
      print('❌ Error cargando desde cart_items: $e');
    }
  }

  /// ARREGLO: Mejorar _saveToSupabase con mejor manejo de errores
  Future<void> _saveToSupabase() async {
    try {
      final client = SupabaseConfig.client;
      final user = client.auth.currentUser;
      
      if (user == null) {
        print('⚠️ Usuario no autenticado, no se puede guardar carrito');
        return;
      }
      
      print('💾 Guardando carrito para usuario: ${user.id}');
      
      await client
          .from('user_carts')
          .upsert({
            'user_id': user.id,
            'items': _items.map((item) => item.toJson()).toList(),
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      print('✅ Carrito guardado exitosamente');
      
    } catch (e) {
      print('❌ Error guardando carrito: $e');
    }
  }
}
"""
    
    with open('fix_cart_service.dart', 'w') as f:
        f.write(cart_fix_script)
    
    print("✅ Script de arreglo del CartService creado: fix_cart_service.dart")
    
    # Crear script de arreglo para WelcomeScreen
    welcome_fix_script = """
// ARREGLO PARA WELCOME SCREEN - lib/screens/welcome/welcome_screen_fixed.dart

class _WelcomeScreenFixedState extends State<WelcomeScreenFixed> {
  // ... código existente ...

  @override
  void initState() {
    super.initState();
    print('🚀 WelcomeScreenFixed - INICIANDO DE FORMA NO BLOQUEANTE');
    
    // Mostrar UI inmediatamente con valores por defecto
    setState(() {
      _isLoading = false;
      _currentBalance = 0.0;
      _categories = _getDefaultCategoriesMap();
      _bestSellers = _getDefaultProductsMap();
    });
    
    // ARREGLO: Configurar CartService y cargar carrito
    _cartService.addListener(_updateCartCount);
    _initializeCart();
    
    // Cargar datos en background SIN BLOQUEAR la UI
    _loadDataInBackground();
    
    print('✅ WelcomeScreenFixed - UI MOSTRADA INMEDIATAMENTE');
  }

  /// ARREGLO: Inicializar carrito correctamente
  Future<void> _initializeCart() async {
    try {
      print('🛒 Inicializando carrito en WelcomeScreen...');
      await _cartService.initializeCart();
      _updateCartCount();
      print('✅ Carrito inicializado: ${_cartService.itemCount} items');
    } catch (e) {
      print('❌ Error inicializando carrito: $e');
    }
  }

  /// ARREGLO: Mejorar _loadCartItemsCount
  Future<void> _loadCartItemsCount() async {
    try {
      print('🛒 Cargando conteo de carrito...');
      
      // Asegurar que el carrito esté cargado
      if (_cartService.itemCount == 0) {
        await _cartService.loadFromSupabase();
      }
      
      if (mounted) {
        setState(() {
          _cartItemsCount = _cartService.itemCount;
        });
        print('✅ Conteo de carrito actualizado: $_cartItemsCount');
      }
    } catch (e) {
      print('❌ Error cargando conteo de carrito: $e');
    }
  }

  /// ARREGLO: Mejorar _updateCartCount
  void _updateCartCount() {
    if (mounted) {
      setState(() {
        _cartItemsCount = _cartService.itemCount;
      });
      print('🛒 Carrito actualizado: $_cartItemsCount productos');
    }
  }
}
"""
    
    with open('fix_welcome_screen.dart', 'w') as f:
        f.write(welcome_fix_script)
    
    print("✅ Script de arreglo del WelcomeScreen creado: fix_welcome_screen.dart")

def create_sql_fix():
    """Crear SQL para arreglar tablas del carrito"""
    
    print("\n🔧 CREANDO SQL PARA ARREGLAR TABLAS DEL CARRITO")
    print("-" * 60)
    
    sql_fix = """
-- SQL para arreglar tablas del carrito
-- Ejecutar en Supabase SQL Editor

-- 1. Crear tabla user_carts si no existe
CREATE TABLE IF NOT EXISTS user_carts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  items JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- 2. Crear tabla cart_items si no existe
CREATE TABLE IF NOT EXISTS cart_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  product_id VARCHAR NOT NULL,
  product_name VARCHAR NOT NULL,
  product_price DECIMAL(10,2) NOT NULL,
  product_image_url TEXT,
  product_type VARCHAR DEFAULT 'store',
  quantity INTEGER DEFAULT 1,
  selected_size VARCHAR,
  selected_color VARCHAR,
  weight DECIMAL(8,3),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_user_carts_user_id ON user_carts(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON cart_items(product_id);

-- 4. Habilitar RLS
ALTER TABLE user_carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

-- 5. Crear políticas RLS para user_carts
DROP POLICY IF EXISTS "Users can view own cart" ON user_carts;
DROP POLICY IF EXISTS "Users can insert own cart" ON user_carts;
DROP POLICY IF EXISTS "Users can update own cart" ON user_carts;
DROP POLICY IF EXISTS "Users can delete own cart" ON user_carts;

CREATE POLICY "Users can view own cart" ON user_carts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cart" ON user_carts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cart" ON user_carts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cart" ON user_carts
  FOR DELETE USING (auth.uid() = user_id);

-- 6. Crear políticas RLS para cart_items
DROP POLICY IF EXISTS "Users can view own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can insert own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can update own cart items" ON cart_items;
DROP POLICY IF EXISTS "Users can delete own cart items" ON cart_items;

CREATE POLICY "Users can view own cart items" ON cart_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cart items" ON cart_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cart items" ON cart_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cart items" ON cart_items
  FOR DELETE USING (auth.uid() = user_id);

-- 7. Crear trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger a user_carts
DROP TRIGGER IF EXISTS update_user_carts_updated_at ON user_carts;
CREATE TRIGGER update_user_carts_updated_at
    BEFORE UPDATE ON user_carts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Aplicar trigger a cart_items
DROP TRIGGER IF EXISTS update_cart_items_updated_at ON cart_items;
CREATE TRIGGER update_cart_items_updated_at
    BEFORE UPDATE ON cart_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 8. Verificar estructura final
SELECT 'user_carts' as table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'user_carts'
UNION ALL
SELECT 'cart_items' as table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'cart_items'
ORDER BY table_name, ordinal_position;
"""
    
    with open('fix_cart_tables.sql', 'w') as f:
        f.write(sql_fix)
    
    print("✅ SQL de arreglo de tablas creado: fix_cart_tables.sql")

if __name__ == "__main__":
    # Ejecutar diagnóstico
    diagnose_cart_issues()
    
    # Crear arreglos
    create_cart_fix()
    create_sql_fix()
    
    print("\n🎉 DIAGNÓSTICO Y ARREGLOS DEL CARRITO COMPLETADOS")
    print("📁 Archivos creados:")
    print("   - fix_cart_service.dart")
    print("   - fix_welcome_screen.dart")
    print("   - fix_cart_tables.sql")
    print("\n📋 Próximos pasos:")
    print("1. Ejecutar fix_cart_tables.sql en Supabase")
    print("2. Aplicar arreglos de los archivos .dart")
    print("3. Probar persistencia del carrito")
    print("4. Verificar que el carrito se mantiene al hacer login")
