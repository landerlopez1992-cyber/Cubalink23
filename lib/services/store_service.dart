import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cubalink23/models/product_category.dart';
import 'package:cubalink23/models/store_product.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreService {
  static final StoreService _instance = StoreService._internal();
  factory StoreService() => _instance;
  StoreService._internal();

  SupabaseClient? get _client => SupabaseConfig.safeClient;

  // Provincias donde se permite entrega express
  static const List<String> expressProvinces = [
    'Pinar del Río',
    'Artemisa',
    'La Habana',
    'Mayabeque', 
    'Matanzas',
    'Cienfuegos',
    'Villa Clara',
    'Sancti Spíritus',
    'Ciego de Ávila',
    'Camagüey',
  ];

  // Todas las provincias de Cuba (para envío por barco)
  static const List<String> allProvinces = [
    'Pinar del Río',
    'Artemisa',
    'La Habana',
    'Mayabeque',
    'Matanzas',
    'Cienfuegos',
    'Villa Clara',
    'Sancti Spíritus',
    'Ciego de Ávila',
    'Camagüey',
    'Las Tunas',
    'Granma',
    'Holguín',
    'Santiago de Cuba',
    'Guantánamo',
    'Isla de la Juventud',
  ];

  /// Initialize default categories in Supabase
  Future<void> initializeDefaultCategories() async {
    try {
      print('🏪 Inicializando sistema de tienda...');
      
      // Check if Supabase is ready
      if (_client == null) {
        print('⚠️ Supabase no disponible, usando categorías locales');
        return;
      }
      
      final defaultCategories = [
        {'name': 'Alimentos', 'description': 'Comida y productos básicos', 'icon_name': 'restaurant', 'color': '0xFFE57373', 'is_active': true},
        {'name': 'Materiales', 'description': 'Materiales de construcción', 'icon_name': 'construction', 'color': '0xFFFF8A65', 'is_active': true},
        {'name': 'Ferretería', 'description': 'Herramientas y accesorios', 'icon_name': 'build', 'color': '0xFFFF8F00', 'is_active': true},
        {'name': 'Farmacia', 'description': 'Medicinas y productos de salud', 'icon_name': 'healing', 'color': '0xFF26A69A', 'is_active': true},
        {'name': 'Electrónicos', 'description': 'Dispositivos y accesorios', 'icon_name': 'phone_android', 'color': '0xFF42A5F5', 'is_active': true},
        {'name': 'Ropa', 'description': 'Vestimenta y accesorios', 'icon_name': 'shopping_bag', 'color': '0xFFAB47BC', 'is_active': true},
        {'name': 'Hogar', 'description': 'Productos para el hogar', 'icon_name': 'home', 'color': '0xFF66BB6A', 'is_active': true},
        {'name': 'Deportes', 'description': 'Artículos deportivos', 'icon_name': 'fitness_center', 'color': '0xFFFF7043', 'is_active': true},
      ];

      // Try to check if categories exist, if table doesn't exist, show setup message
      try {
        final existingCategories = await _client!
          .from('product_categories')
          .select('name')
          .limit(1);

        if (existingCategories.isEmpty) {
          // Insert default categories
          await _client!
            .from('product_categories')
            .insert(defaultCategories);
          
          print('✅ Categorías por defecto creadas exitosamente');
        } else {
          print('ℹ️ Las categorías ya existen');
        }
      } catch (tableError) {
        print('⚠️ Las tablas de Supabase no están configuradas. Usando categorías locales.');
        print('📋 Para configurar Supabase correctamente, sigue estos pasos:');
        print('   1. Ve al Dashboard de Supabase');
        print('   2. Ejecuta el SQL para crear las tablas (ver documentación)');
        print('   3. Reinicia la aplicación');
        // Continue with hardcoded categories as fallback
      }
    } catch (e) {
      print('❌ Error inicializando categorías: $e');
      print('📋 Usando categorías por defecto como fallback');
    }
  }

  /// Get SQL scripts needed to set up Supabase tables
  static String getSetupSQL() {
    return '''
-- Configuración de tablas para Tu Recarga Store
-- Ejecuta este SQL en tu Dashboard de Supabase (SQL Editor)

-- Tabla de categorías de productos
CREATE TABLE IF NOT EXISTS product_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL UNIQUE,
  description TEXT,
  icon_name VARCHAR DEFAULT 'store',
  color VARCHAR DEFAULT '0xFF42A5F5',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de subcategorías de productos
CREATE TABLE IF NOT EXISTS product_subcategories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  description TEXT,
  category_id UUID REFERENCES product_categories(id) ON DELETE CASCADE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de productos de la tienda
CREATE TABLE IF NOT EXISTS store_products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.0,
  image_url TEXT,
  category_id UUID REFERENCES product_categories(id),
  sub_category_id UUID REFERENCES product_subcategories(id),
  unit VARCHAR DEFAULT 'unidad',
  weight DECIMAL(8,3) DEFAULT 0.0,
  is_available BOOLEAN DEFAULT true,
  is_active BOOLEAN DEFAULT true,
  stock INTEGER DEFAULT 0,
  available_provinces JSONB DEFAULT '[]',
  delivery_method VARCHAR DEFAULT 'express',
  additional_data JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_store_products_category_id ON store_products(category_id);
CREATE INDEX IF NOT EXISTS idx_store_products_subcategory_id ON store_products(sub_category_id);
CREATE INDEX IF NOT EXISTS idx_store_products_is_active ON store_products(is_active);
CREATE INDEX IF NOT EXISTS idx_store_products_is_available ON store_products(is_available);
CREATE INDEX IF NOT EXISTS idx_product_categories_is_active ON product_categories(is_active);
CREATE INDEX IF NOT EXISTS idx_product_subcategories_category_id ON product_subcategories(category_id);
CREATE INDEX IF NOT EXISTS idx_product_subcategories_is_active ON product_subcategories(is_active);

-- Row Level Security (RLS) - Opcional pero recomendado
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_subcategories ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_products ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad (permite lectura pública, escritura solo para usuarios autenticados)
CREATE POLICY "Allow public read access to categories" ON product_categories
  FOR SELECT USING (true);

CREATE POLICY "Allow public read access to subcategories" ON product_subcategories
  FOR SELECT USING (is_active = true);

CREATE POLICY "Allow public read access to products" ON store_products
  FOR SELECT USING (is_active = true);

CREATE POLICY "Allow authenticated users to manage categories" ON product_categories
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to manage subcategories" ON product_subcategories
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to manage products" ON store_products
  FOR ALL USING (auth.role() = 'authenticated');
''';
  }

  /// Get all categories from Supabase
  Future<List<ProductCategory>> getCategories() async {
    try {
      print('📋 Obteniendo categorías de Supabase...');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible, retornando categorías por defecto');
        return _getDefaultCategories();
      }
      
      final response = await _client!
        .from('product_categories')
        .select('*')
        .eq('is_active', true)
        .order('name');

      final categories = <ProductCategory>[];
      for (final item in response) {
        try {
          categories.add(ProductCategory.fromMap(item));
        } catch (e) {
          print('⚠️ Error parsing category: $e');
        }
      }

      print('✅ ${categories.length} categorías obtenidas');
      return categories;
    } catch (e) {
      print('❌ Error obteniendo categorías: $e');
      return _getDefaultCategories(); // Return hardcoded categories as fallback
    }
  }

  /// Get default categories as fallback
  List<ProductCategory> _getDefaultCategories() {
    return [
      ProductCategory(
        id: 'alimentos',
        name: 'Alimentos',
        description: 'Comida y productos básicos',
        iconName: 'restaurant',
        color: 0xFFE57373,
        isActive: true,
      ),
      ProductCategory(
        id: 'materiales',
        name: 'Materiales', 
        description: 'Materiales de construcción',
        iconName: 'construction',
        color: 0xFFFF8A65,
        isActive: true,
      ),
      ProductCategory(
        id: 'ferreteria',
        name: 'Ferretería',
        description: 'Herramientas y accesorios',
        iconName: 'build',
        color: 0xFFFF8F00,
        isActive: true,
      ),
      ProductCategory(
        id: 'farmacia',
        name: 'Farmacia',
        description: 'Medicinas y productos de salud',
        iconName: 'healing',
        color: 0xFF26A69A,
        isActive: true,
      ),
      ProductCategory(
        id: 'electronicos',
        name: 'Electrónicos',
        description: 'Dispositivos y accesorios',
        iconName: 'phone_android',
        color: 0xFF42A5F5,
        isActive: true,
      ),
      ProductCategory(
        id: 'ropa',
        name: 'Ropa',
        description: 'Vestimenta y accesorios',
        iconName: 'shopping_bag',
        color: 0xFFAB47BC,
        isActive: true,
      ),
    ];
  }

  /// Upload image to Supabase Storage and return the public URL
  Future<String?> uploadImage({
    required String filePath,
    required String fileName,
    String bucket = 'products',
  }) async {
    try {
      print('📸 Subiendo imagen a Supabase Storage...');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible para subir imagen');
        return null;
      }

      // Upload the file to Supabase Storage
      final response = await _client!.storage
          .from(bucket)
          .upload(fileName, File(filePath));

      if (response.isNotEmpty) {
        print('❌ Error subiendo imagen: $response');
        return null;
      }

      // Get the public URL
      final publicUrl = _client!.storage
          .from(bucket)
          .getPublicUrl(fileName);

      print('✅ Imagen subida exitosamente: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error subiendo imagen: $e');
      return null;
    }
  }

  /// Upload image from bytes (for web)
  Future<String?> uploadImageFromBytes({
    required Uint8List bytes,
    required String fileName,
    String bucket = 'products',
  }) async {
    try {
      print('📸 Subiendo imagen desde bytes a Supabase Storage...');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible para subir imagen');
        return null;
      }

      // Upload the file to Supabase Storage
      final response = await _client!.storage
          .from(bucket)
          .uploadBinary(fileName, bytes);

      if (response.isNotEmpty) {
        print('❌ Error subiendo imagen: $response');
        return null;
      }

      // Get the public URL
      final publicUrl = _client!.storage
          .from(bucket)
          .getPublicUrl(fileName);

      print('✅ Imagen subida exitosamente: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error subiendo imagen: $e');
      return null;
    }
  }

  /// Delete image from Supabase Storage
  Future<bool> deleteImage(String fileName, {String bucket = 'products'}) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible para eliminar imagen');
        return false;
      }

      final response = await _client!.storage
          .from(bucket)
          .remove([fileName]);

      print('✅ Imagen eliminada: $fileName');
      return true;
    } catch (e) {
      print('❌ Error eliminando imagen: $e');
      return false;
    }
  }

  /// Create a new category
  Future<ProductCategory?> createCategory({
    required String name,
    required String description,
    required String iconName,
    required int color,
    bool isActive = true,
  }) async {
    try {
      print('📁 Creando nueva categoría: $name');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return null;
      }

      final categoryData = {
        'name': name,
        'description': description,
        'icon_name': iconName,
        'color': color,
        'is_active': isActive,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client!
          .from('product_categories')
          .insert(categoryData)
          .select()
          .single();

      print('✅ Categoría creada exitosamente');
      return ProductCategory.fromMap(response);
    } catch (e) {
      print('❌ Error creando categoría: $e');
      return null;
    }
  }

  /// Update a category
  Future<bool> updateCategory({
    required String categoryId,
    required String name,
    required String description,
    required String iconName,
    required int color,
    bool? isActive,
  }) async {
    try {
      print('✏️ Actualizando categoría: $categoryId');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      final updateData = {
        'name': name,
        'description': description,
        'icon_name': iconName,
        'color': color,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (isActive != null) {
        updateData['is_active'] = isActive;
      }

      await _client!
          .from('product_categories')
          .update(updateData)
          .eq('id', categoryId);

      print('✅ Categoría actualizada exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando categoría: $e');
      return false;
    }
  }

  /// Delete a category (soft delete)
  Future<bool> deleteCategory(String categoryId) async {
    try {
      print('🗑️ Eliminando categoría: $categoryId');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      await _client!
          .from('product_categories')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', categoryId);

      print('✅ Categoría eliminada exitosamente');
      return true;
    } catch (e) {
      print('❌ Error eliminando categoría: $e');
      return false;
    }
  }

  /// Get subcategories for a category
  Future<List<Map<String, dynamic>>> getSubcategories([String? categoryId]) async {
    try {
      print('📂 Obteniendo subcategorías...');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible, usando subcategorías por defecto');
        return _getDefaultSubcategories();
      }

      var query = _client!
          .from('product_subcategories')
          .select('*')
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query.order('name');
      
      print('✅ Subcategorías obtenidas: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error obteniendo subcategorías: $e');
      return _getDefaultSubcategories();
    }
  }

  /// Get default subcategories as fallback
  List<Map<String, dynamic>> _getDefaultSubcategories() {
    return [
      {'id': '1', 'name': 'Arroz y Granos', 'category_id': '1'},
      {'id': '2', 'name': 'Carnes y Embutidos', 'category_id': '1'},
      {'id': '3', 'name': 'Lácteos', 'category_id': '1'},
      {'id': '4', 'name': 'Cemento', 'category_id': '2'},
      {'id': '5', 'name': 'Ladrillos', 'category_id': '2'},
      {'id': '6', 'name': 'Herramientas Manuales', 'category_id': '3'},
      {'id': '7', 'name': 'Tornillos y Clavos', 'category_id': '3'},
      {'id': '8', 'name': 'Medicamentos', 'category_id': '4'},
      {'id': '9', 'name': 'Vitaminas', 'category_id': '4'},
    ];
  }

  /// Create a new subcategory
  Future<bool> createSubcategory({
    required String name,
    required String categoryId,
    String? description,
    bool isActive = true,
  }) async {
    try {
      print('📂 Creando nueva subcategoría: $name');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      final subcategoryData = {
        'name': name,
        'category_id': categoryId,
        'description': description,
        'is_active': isActive,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _client!
          .from('product_subcategories')
          .insert(subcategoryData);

      print('✅ Subcategoría creada exitosamente');
      return true;
    } catch (e) {
      print('❌ Error creando subcategoría: $e');
      return false;
    }
  }
  
  /// Get products by category from Supabase
  Future<List<StoreProduct>> getProductsByCategory(String categoryId) async {
    try {
      print('🔍 Buscando productos de categoría: $categoryId');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible, retornando productos por defecto');
        return _getDefaultProductsByCategory(categoryId);
      }
      
      final response = await _client!
        .from('store_products')
        .select('*')
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

      final products = <StoreProduct>[];
      for (final item in response) {
        try {
          products.add(StoreProduct.fromMap(item));
        } catch (e) {
          print('⚠️ Error parsing product: $e');
        }
      }

      print('✅ ${products.length} productos encontrados');
      return products;
    } catch (e) {
      print('❌ Error obteniendo productos: $e');
      return [];
    }
  }
  
  /// Get product by ID from Supabase
  Future<StoreProduct?> getProductById(String productId) async {
    try {
      print('🔍 Buscando producto: $productId');
      
      if (_client == null) {
        throw Exception('Supabase no disponible');
      }
      
      final response = await _client!
        .from('store_products')
        .select('*')
        .eq('id', productId)
        .single();

      return StoreProduct.fromMap(response);
    } catch (e) {
      print('❌ Error obteniendo producto: $e');
      return null;
    }
  }
  
  /// Get recent products from Supabase
  Future<List<StoreProduct>> getRecentProducts() async {
    try {
      print('🕐 Obteniendo productos recientes...');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible, retornando productos por defecto');
        return _getDefaultRecentProducts();
      }
      
      final response = await _client!
        .from('store_products')
        .select('*')
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(10);

      final products = <StoreProduct>[];
      for (final item in response) {
        try {
          products.add(StoreProduct.fromMap(item));
        } catch (e) {
          print('⚠️ Error parsing recent product: $e');
        }
      }

      print('✅ ${products.length} productos recientes obtenidos');
      return products;
    } catch (e) {
      print('❌ Error obteniendo productos recientes: $e');
      return [];
    }
  }
  
  /// Get all products from Supabase
  Future<List<StoreProduct>> getAllProducts() async {
    try {
      print('📦 Obteniendo todos los productos...');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible, retornando productos por defecto');
        return _getAllDefaultProducts();
      }
      
      final response = await _client!
        .from('store_products')
        .select('*')
        .eq('is_active', true)
        .order('name');

      final products = <StoreProduct>[];
      for (final item in response) {
        try {
          products.add(StoreProduct.fromMap(item));
        } catch (e) {
          print('⚠️ Error parsing product: $e');
        }
      }

      print('✅ ${products.length} productos obtenidos');
      return products;
    } catch (e) {
      print('❌ Error obteniendo productos: $e');
      return [];
    }
  }

  /// Get vendor products by vendor ID
  Future<List<StoreProduct>> getVendorProducts(String vendorId) async {
    try {
      print('📦 Obteniendo productos del vendedor: $vendorId');
      
      if (_client == null) {
        print('⚠️ Supabase no disponible, retornando productos por defecto');
        return _getAllDefaultProducts();
      }
      
      final response = await _client!
        .from('store_products')
        .select('*')
        .eq('vendor_id', vendorId)
        .eq('is_active', true)
        .order('name');

      final products = <StoreProduct>[];
      for (final item in response) {
        try {
          products.add(StoreProduct.fromMap(item));
        } catch (e) {
          print('⚠️ Error parsing vendor product: $e');
        }
      }

      print('✅ ${products.length} productos del vendedor obtenidos');
      return products;
    } catch (e) {
      print('❌ Error obteniendo productos del vendedor: $e');
      return [];
    }
  }

  /// Create a new product in Supabase
  Future<bool> createProduct(StoreProduct product) async {
    try {
      print('➕ Creando nuevo producto: ${product.name}');
      
      // Validar que la categoría existe
      if (product.categoryId.isEmpty) {
        throw Exception('Category ID es obligatorio');
      }
      
      // Crear datos para insertar usando solo columnas snake_case para Supabase
      final productData = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'images': product.imageUrl.isNotEmpty ? [product.imageUrl] : [],  // Array de imágenes
        'category_id': product.categoryId,
        'subcategory_id': product.subCategoryId?.isNotEmpty == true ? product.subCategoryId : null,  // Corregido snake_case
        'unit': product.unit,
        'weight': product.weight,
        'is_active': product.isAvailable,  // Corregido nombre de columna
        'stock': product.stock,
        'available_provinces': product.availableProvinces,
        'available_sizes': product.additionalData?['sizes'] ?? [],
        'available_colors': product.additionalData?['colors'] ?? [],
        'delivery_cost': product.additionalData?['deliveryCost'] ?? 0.0,
        'metadata': {
          'delivery_method': product.deliveryMethod,
          ...?product.additionalData,
        },
      };
      
      print('📊 Datos del producto a insertar: $productData');
      
      if (_client == null) {
        throw Exception('Supabase no disponible para crear producto');
      }
      
      final response = await _client!
        .from('store_products')
        .insert(productData)
        .select();

      if (response.isNotEmpty) {
        print('✅ Producto creado exitosamente: ${response.first['id']}');
        return true;
      } else {
        throw Exception('No se pudo crear el producto - respuesta vacía');
      }
    } catch (e) {
      print('❌ Error creando producto: $e');
      
      // Provide more specific error messages
      String errorMessage = e.toString();
      if (errorMessage.contains('relation "store_products" does not exist')) {
        errorMessage = 'Las tablas de Supabase no están configuradas. Ejecuta el SQL de configuración primero.';
      } else if (errorMessage.contains('violates foreign key constraint')) {
        errorMessage = 'La categoría seleccionada no existe. Selecciona una categoría válida.';
      } else if (errorMessage.contains('column') && errorMessage.contains('does not exist')) {
        errorMessage = 'Estructura de tabla incorrecta. Verifica que las tablas estén actualizadas.';
      }
      
      print('❌ Error específico: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  /// Update an existing product in Supabase
  Future<bool> updateProduct(StoreProduct product) async {
    try {
      print('✏️ Actualizando producto: ${product.name} (ID: ${product.id})');
      
      // Validar que tenemos un ID válido
      if (product.id.isEmpty) {
        throw Exception('Product ID es obligatorio para actualizar');
      }
      
      // Crear datos para actualizar usando solo columnas snake_case para Supabase
      final productData = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'images': product.imageUrl.isNotEmpty ? [product.imageUrl] : [],  // Array de imágenes
        'category_id': product.categoryId,
        'subcategory_id': product.subCategoryId?.isNotEmpty == true ? product.subCategoryId : null,  // Corregido snake_case
        'unit': product.unit,
        'weight': product.weight,
        'is_active': product.isAvailable,  // Corregido nombre de columna
        'stock': product.stock,
        'available_provinces': product.availableProvinces,
        'available_sizes': product.additionalData?['sizes'] ?? [],
        'available_colors': product.additionalData?['colors'] ?? [],
        'delivery_cost': product.additionalData?['deliveryCost'] ?? 0.0,
        'metadata': {
          'delivery_method': product.deliveryMethod,
          ...?product.additionalData,
        },
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      print('📊 Datos del producto a actualizar: $productData');
      
      if (_client == null) {
        throw Exception('Supabase no disponible para actualizar producto');
      }
      
      final response = await _client!
        .from('store_products')
        .update(productData)
        .eq('id', product.id)
        .select();

      if (response.isNotEmpty) {
        print('✅ Producto actualizado exitosamente: ${response.first['id']}');
        return true;
      } else {
        throw Exception('No se pudo actualizar el producto - producto no encontrado');
      }
    } catch (e) {
      print('❌ Error actualizando producto: $e');
      
      // Provide more specific error messages
      String errorMessage = e.toString();
      if (errorMessage.contains('relation "store_products" does not exist')) {
        errorMessage = 'Las tablas de Supabase no están configuradas.';
      } else if (errorMessage.contains('violates foreign key constraint')) {
        errorMessage = 'La categoría seleccionada no existe.';
      }
      
      print('❌ Error específico: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  /// Delete a product from Supabase (soft delete)
  Future<bool> deleteProduct(String productId) async {
    try {
      print('🗑️ Eliminando producto: $productId');
      
      if (_client == null) {
        throw Exception('Supabase no disponible para eliminar producto');
      }
      
      await _client!
        .from('store_products')
        .update({
          'is_active': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', productId);

      print('✅ Producto eliminado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error eliminando producto: $e');
      return false;
    }
  }
  
  bool canDeliverTo(String province, String deliveryMethod) {
    // Check if delivery is available to this province
    if (deliveryMethod == 'express') {
      return expressProvinces.contains(province);
    } else {
      return allProvinces.contains(province);
    }
  }


  /// Fallback products by category when Supabase is not available
  List<StoreProduct> _getDefaultProductsByCategory(String categoryId) {
    return [
      StoreProduct(
        id: 'default_1',
        name: 'Producto de Ejemplo',
        description: 'Producto de demostración (Supabase no disponible)',
        categoryId: categoryId,
        price: 10.0,
        imageUrl: 'https://via.placeholder.com/300x200',
        unit: 'unidad',
        weight: 1.0,
        isAvailable: true,
        stock: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Fallback recent products when Supabase is not available
  List<StoreProduct> _getDefaultRecentProducts() {
    return [
      StoreProduct(
        id: 'recent_1',
        name: 'Producto Reciente',
        description: 'Producto de demostración reciente',
        categoryId: '1',
        price: 15.0,
        imageUrl: 'https://via.placeholder.com/300x200',
        unit: 'unidad',
        weight: 1.0,
        isAvailable: true,
        stock: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Fallback all products when Supabase is not available
  List<StoreProduct> _getAllDefaultProducts() {
    return [
      StoreProduct(
        id: 'all_1',
        name: 'Producto General',
        description: 'Producto de demostración general',
        categoryId: '1',
        price: 12.0,
        imageUrl: 'https://via.placeholder.com/300x200',
        unit: 'unidad',
        weight: 1.0,
        isAvailable: true,
        stock: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}