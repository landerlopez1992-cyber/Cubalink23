import 'package:flutter/material.dart';
import 'package:cubalink23/services/store_service.dart';
import 'package:cubalink23/models/product_category.dart';
import 'package:cubalink23/models/store_product.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Commented out for compilation
import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Commented out for compilation
import 'dart:io';
// Removed unused import: dart:typed_data
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  _StoreSettingsScreenState createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final StoreService _storeService = StoreService();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<ProductCategory> _categories = [];
  List<StoreProduct> _products = [];
  List<StoreProduct> _filteredProducts = [];
  List<StoreProduct> _recentProducts = [];
  List<Map<String, dynamic>> _subcategories = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryFilter;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  
  // Lista de todas las provincias cubanas
  static const List<String> cubanProvinces = [
    'Pinar del Río', 'Artemisa', 'La Habana', 'Mayabeque',
    'Matanzas', 'Varadero', 'Cienfuegos', 'Villa Clara',
    'Sancti Spíritus', 'Ciego de Ávila', 'Camagüey', 'Las Tunas',
    'Holguín', 'Granma', 'Santiago de Cuba', 'Guantánamo',
    'Isla de la Juventud'
  ];
  
  // Lista de opciones predeterminadas para productos
  static const List<String> productSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const List<String> productColors = [
    'Rojo', 'Azul', 'Verde', 'Amarillo', 'Negro', 'Blanco',
    'Rosa', 'Morado', 'Naranja', 'Gris', 'Marrón'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      print('🔄 Cargando datos de la tienda...');
      
      await _storeService.initializeDefaultCategories();
      print('✅ Categorías por defecto inicializadas');
      
      final categories = await _storeService.getCategories();
      print('📦 Categorías cargadas: ${categories.length}');
      
      final products = await _storeService.getAllProducts();
      print('🛍️ Productos cargados: ${products.length}');
      
      final subcategories = await _loadSubcategories();
      print('🔖 Subcategorías cargadas: ${subcategories.length}');
      
      final recentProducts = await _loadRecentProducts();
      print('🆕 Productos recientes cargados: ${recentProducts.length}');
      
      setState(() {
        _categories = categories;
        _products = products;
        _filteredProducts = products;
        _subcategories = subcategories;
        _recentProducts = recentProducts;
        _isLoading = false;
      });
      
      print('✅ Datos cargados exitosamente');
    } catch (e) {
      print('❌ Error loading store data: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando datos: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
  
  Future<List<Map<String, dynamic>>> _loadSubcategories() async {
    try {
      return await _storeService.getSubcategories();
    } catch (e) {
      print('Error loading subcategories: $e');
      return [];
    }
  }
  
  Future<List<StoreProduct>> _loadRecentProducts() async {
    try {
      final products = await _storeService.getAllProducts();
      // Get the most recent 10 products
      products.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return products.take(10).toList();
    } catch (e) {
      print('Error loading recent products: $e');
      return [];
    }
  }

  Future<void> _pickAndUploadImage(Function(String) onImageUploaded) async {
    try {
      setState(() => _isUploadingImage = true);
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (pickedFile == null) {
        setState(() => _isUploadingImage = false);
        return;
      }

      print('📸 Imagen seleccionada: ${pickedFile.name}');
      
      // Crear URL local para previsualización inmediata
      String imageUrl;
      
      if (kIsWeb) {
        // Para web, usar bytes directamente
        final bytes = await pickedFile.readAsBytes();
        imageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else {
        // Para móvil, usar file path
        imageUrl = pickedFile.path;
      }
      
      // Upload image to Supabase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'product_${timestamp}_${pickedFile.name}';
      
      String? uploadedUrl;
      
      if (kIsWeb) {
        // For web, use bytes
        final bytes = await pickedFile.readAsBytes();
        uploadedUrl = await _storeService.uploadImageFromBytes(
          bytes: bytes,
          fileName: fileName,
        );
      } else {
        // For mobile, use file path
        uploadedUrl = await _storeService.uploadImage(
          filePath: pickedFile.path,
          fileName: fileName,
        );
      }
      
      // Use uploaded URL if available, otherwise use local preview
      final finalUrl = uploadedUrl ?? imageUrl;
      onImageUploaded(finalUrl);
      
      print('✅ Imagen cargada para previsualización');
      
    } catch (e) {
      print('❌ Error cargando imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  // Removed unused method: _addToRecentProducts

  void _filterProducts(String query) {
    setState(() {
      var filtered = _products;
      
      if (query.isNotEmpty) {
        filtered = filtered.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
                 product.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      
      if (_selectedCategoryFilter != null) {
        filtered = filtered.where((product) => 
          product.categoryId == _selectedCategoryFilter).toList();
      }
      
      _filteredProducts = filtered;
    });
  }

  void _filterByCategory(String? categoryId) {
    setState(() {
      _selectedCategoryFilter = categoryId;
    });
    _filterProducts(_searchController.text);
  }

  Future<void> _addCategory() async {
    await _showCategoryDialog();
  }

  Future<void> _editCategory(ProductCategory category) async {
    await _showCategoryDialog(category: category);
  }

  Future<void> _showCategoryDialog({ProductCategory? category}) async {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');
    final iconNameController = TextEditingController(text: category?.iconName ?? 'store');
    bool isActive = category?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Categoría' : 'Nueva Categoría'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la Categoría',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: iconNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Ícono',
                    border: OutlineInputBorder(),
                    hintText: 'restaurant, devices, build, etc.',
                  ),
                ),
                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('Categoría Activa'),
                  value: isActive,
                  onChanged: (value) {
                    setDialogState(() => isActive = value ?? false);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    bool success = false;
                    
                    if (isEditing) {
                      success = await _storeService.updateCategory(
                        categoryId: category.id,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        iconName: iconNameController.text.trim().isNotEmpty 
                            ? iconNameController.text.trim() 
                            : 'store',
                        color: category.color, // Keep existing color
                        isActive: isActive,
                      );
                      print('Updating category: ${category.id}');
                    } else {
                      final result = await _storeService.createCategory(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        iconName: iconNameController.text.trim().isNotEmpty 
                            ? iconNameController.text.trim() 
                            : 'store',
                        color: 0xFF42A5F5, // Default blue color
                        isActive: isActive,
                      );
                      success = result != null;
                      print('Creating category: ${nameController.text}');
                    }
                    
                    Navigator.pop(context);
                    
                    if (success) {
                      await _loadData();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing ? 'Categoría actualizada' : 'Categoría creada'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error ${isEditing ? 'actualizando' : 'creando'} categoría'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Actualizar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSubcategoryDialog({Map<String, dynamic>? subcategory}) async {
    final isEditing = subcategory != null;
    final nameController = TextEditingController(text: subcategory?['name'] ?? '');
    final descriptionController = TextEditingController(text: subcategory?['description'] ?? '');
    String selectedCategory = subcategory?['categoryId'] ?? (_categories.isNotEmpty ? _categories.first.id : '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Subcategoría' : 'Nueva Subcategoría'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory.isNotEmpty ? selectedCategory : null,
                  decoration: InputDecoration(
                    labelText: 'Categoría Principal',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((cat) => DropdownMenuItem(
                    value: cat.id, 
                    child: Text(cat.name)
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedCategory = value!);
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la Subcategoría',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && selectedCategory.isNotEmpty) {
                  try {
                    bool success = false;
                    
                    if (isEditing) {
                      // Note: Update subcategory functionality would need to be added to StoreService
                      print('Updating subcategory: ${subcategory['id']} (not implemented yet)');
                      success = false; // Placeholder for now
                    } else {
                      success = await _storeService.createSubcategory(
                        name: nameController.text.trim(),
                        categoryId: selectedCategory,
                        description: descriptionController.text.trim(),
                      );
                      print('Creating subcategory: ${nameController.text}');
                    }
                    
                    Navigator.pop(context);
                    
                    if (success) {
                      await _loadData();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing ? 'Subcategoría actualizada' : 'Subcategoría creada'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error ${isEditing ? 'actualizando' : 'creando'} subcategoría'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Actualizar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(ProductCategory category) async {
    final productsInCategory = await _storeService.getProductsByCategory(category.id);
    
    if (productsInCategory.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se puede eliminar. Hay ${productsInCategory.length} productos en esta categoría.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Categoría'),
        content: Text('¿Estás seguro de eliminar "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _storeService.deleteCategory(category.id);
        print('Deleting category: ${category.id}');
        
        if (success) {
          await _loadData();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Categoría "${category.name}" eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar la categoría'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error eliminando categoría: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addProduct() async {
    await _showProductDialog();
  }

  Future<void> _editProduct(StoreProduct product) async {
    await _showProductDialog(product: product);
  }

  Future<void> _showProductDialog({StoreProduct? product}) async {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final imageController = TextEditingController(text: product?.imageUrl ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final weightController = TextEditingController(text: product?.weight.toString() ?? '');
    final unitController = TextEditingController(text: product?.unit ?? 'unidad');
    final deliveryCostController = TextEditingController(text: product?.additionalData['deliveryCost']?.toString() ?? '0');
    
    String selectedCategory = product?.categoryId ?? (_categories.isNotEmpty ? _categories.first.id : '');
    String selectedSubcategory = product?.additionalData['subcategoryId']?.toString() ?? '';
    bool isAvailable = product?.isAvailable ?? true;
    String deliveryMethod = product?.deliveryMethod ?? 'express';
    List<String> selectedProvinces = List.from(product?.availableProvinces ?? StoreService.expressProvinces);
    List<String> selectedSizes = List.from(product?.additionalData['sizes'] ?? []);
    List<String> selectedColors = List.from(product?.additionalData['colors'] ?? []);
    String? uploadedImageUrl;
    bool hasImageFile = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 700,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Producto',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Precio (\$)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: unitController,
                          decoration: InputDecoration(
                            labelText: 'Unidad',
                            border: OutlineInputBorder(),
                            hintText: 'lb, kg, unidad, etc.',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Stock',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Peso (kg)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory.isNotEmpty ? selectedCategory : null,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((cat) => DropdownMenuItem(
                      value: cat.id, 
                      child: Text(cat.name)
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value!;
                        selectedSubcategory = '';
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // Selección de subcategoría
                  DropdownButtonFormField<String>(
                    initialValue: selectedSubcategory.isNotEmpty ? selectedSubcategory : null,
                    decoration: InputDecoration(
                      labelText: 'Subcategoría',
                      border: OutlineInputBorder(),
                    ),
                    items: _subcategories
                        .where((sub) => sub['categoryId'] == selectedCategory)
                        .map((sub) => DropdownMenuItem<String>(
                      value: sub['id'], 
                      child: Text(sub['name'])
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedSubcategory = value ?? '');
                    },
                  ),
                  SizedBox(height: 16),
                  // Carga de imagen desde archivo
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Imagen del Producto', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          if (uploadedImageUrl != null || imageController.text.isNotEmpty)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300, width: 2),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade50,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _buildImagePreview(uploadedImageUrl ?? imageController.text),
                              ),
                            )
                          else
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300, width: 2),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade100,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
                                  SizedBox(height: 8),
                                  Text(
                                    'Sin imagen seleccionada',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Haz clic en "Subir Imagen" o pega una URL',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isUploadingImage ? null : () async {
                                  try {
                                    await _pickAndUploadImage((url) {
                                      setDialogState(() {
                                        uploadedImageUrl = url;
                                        hasImageFile = true;
                                        imageController.clear(); // Limpiar URL manual al subir archivo
                                      });
                                    });
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error al subir imagen: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: _isUploadingImage ? 
                                    SizedBox(
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ) :
                                    Icon(Icons.upload_file),
                                label: Text(_isUploadingImage ? 'Subiendo...' : 'Subir Imagen'),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: imageController,
                                  decoration: InputDecoration(
                                    labelText: 'O pegar URL',
                                    border: OutlineInputBorder(),
                                    hintText: 'https://...',
                                  ),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      hasImageFile = false;
                                      if (value.trim().isNotEmpty) {
                                        uploadedImageUrl = null; // Limpiar URL subida al escribir manualmente
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Costo de entrega
                  TextField(
                    controller: deliveryCostController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Costo de Entrega (\$)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: deliveryMethod,
                    decoration: InputDecoration(
                      labelText: 'Método de Entrega',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'express', child: Text('Express (Provincias Limitadas)')),
                      DropdownMenuItem(value: 'barco', child: Text('Barco (Todas las Provincias)')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        deliveryMethod = value!;
                        if (deliveryMethod == 'express') {
                          selectedProvinces = List.from(StoreService.expressProvinces);
                        } else {
                          selectedProvinces = List.from(cubanProvinces);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  CheckboxListTile(
                    title: Text('Producto Disponible'),
                    value: isAvailable,
                    onChanged: (value) {
                      setDialogState(() => isAvailable = value!);
                    },
                  ),
                  SizedBox(height: 8),
                  // Opciones de tallas
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tallas Disponibles', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: productSizes.map((size) => FilterChip(
                              label: Text(size),
                              selected: selectedSizes.contains(size),
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    if (!selectedSizes.contains(size)) {
                                      selectedSizes.add(size);
                                    }
                                  } else {
                                    selectedSizes.remove(size);
                                  }
                                });
                                print('Tallas seleccionadas: $selectedSizes');
                              },
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Opciones de colores
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Colores Disponibles', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: productColors.map((color) => FilterChip(
                              label: Text(color),
                              selected: selectedColors.contains(color),
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    if (!selectedColors.contains(color)) {
                                      selectedColors.add(color);
                                    }
                                  } else {
                                    selectedColors.remove(color);
                                  }
                                });
                                print('Colores seleccionados: $selectedColors');
                              },
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Selección manual de provincias
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Provincias Disponibles', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(
                            deliveryMethod == 'express' 
                              ? 'Express: Selecciona provincias específicas'
                              : 'Barco: Todas las provincias seleccionadas',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 4,
                                children: (deliveryMethod == 'express' ? StoreService.expressProvinces : cubanProvinces)
                                    .map((province) => FilterChip(
                                  label: Text(province, style: TextStyle(fontSize: 10)),
                                  selected: selectedProvinces.contains(province),
                                  onSelected: deliveryMethod == 'express' ? (bool selected) {
                                    setDialogState(() {
                                      if (selected) {
                                        selectedProvinces.add(province);
                                      } else {
                                        selectedProvinces.remove(province);
                                      }
                                    });
                                  } : null,
                                )).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validación mejorada
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('El nombre del producto es obligatorio'), backgroundColor: Colors.red),
                  );
                  return;
                }
                
                if (priceController.text.trim().isEmpty || double.tryParse(priceController.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ingrese un precio válido'), backgroundColor: Colors.red),
                  );
                  return;
                }
                
                if (selectedCategory.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Seleccione una categoría'), backgroundColor: Colors.red),
                  );
                  return;
                }
                
                // Mostrar indicador de carga
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Guardando producto...'),
                      ],
                    ),
                  ),
                );
                
                try {
                  print('🔄 Iniciando proceso de guardado de producto...');
                  print('📝 Nombre: ${nameController.text}');
                  print('💰 Precio: ${priceController.text}');
                  print('🏷️ Categoría: $selectedCategory');
                  
                  final finalImageUrl = uploadedImageUrl ?? (imageController.text.isNotEmpty 
                      ? imageController.text 
                      : 'https://via.placeholder.com/300x300?text=${Uri.encodeComponent(nameController.text)}');
                  
                  print('🖼️ URL Final de imagen: $finalImageUrl');
                  
                  // Crear objeto StoreProduct
                  final productToSave = StoreProduct(
                    id: isEditing ? product!.id : '', // Supabase generará el ID para productos nuevos
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    price: double.tryParse(priceController.text) ?? 0.0,
                    imageUrl: finalImageUrl,
                    weight: double.tryParse(weightController.text) ?? 0.0,
                    unit: unitController.text.trim().isNotEmpty ? unitController.text.trim() : 'unidad',
                    categoryId: selectedCategory,
                    subCategoryId: selectedSubcategory.isNotEmpty ? selectedSubcategory : null,
                    isAvailable: isAvailable,
                    stock: int.tryParse(stockController.text) ?? 0,
                    availableProvinces: selectedProvinces,
                    deliveryMethod: deliveryMethod,
                    additionalData: {
                      'subcategoryId': selectedSubcategory,
                      'sizes': selectedSizes,
                      'colors': selectedColors,
                      'deliveryCost': double.tryParse(deliveryCostController.text) ?? 0.0,
                    },
                  );
                  
                  bool success = false;
                  String? errorMessage;
                  
                  if (isEditing) {
                    print('✏️ Actualizando producto existente: ${product!.id}');
                    try {
                      success = await _storeService.updateProduct(productToSave);
                    } catch (updateError) {
                      errorMessage = updateError.toString();
                      success = false;
                    }
                  } else {
                    print('➕ Creando nuevo producto...');
                    try {
                      success = await _storeService.createProduct(productToSave);
                    } catch (createError) {
                      errorMessage = createError.toString();
                      success = false;
                    }
                  }
                  
                  if (!success) {
                    throw Exception(errorMessage ?? 'Error desconocido guardando el producto');
                  }
                  
                  Navigator.pop(context); // Cerrar dialog de carga
                  Navigator.pop(context); // Cerrar dialog de producto
                  
                  await _loadData(); // Recargar datos
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? '✅ Producto actualizado exitosamente' : '✅ Producto creado exitosamente'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context); // Cerrar dialog de carga si hay error
                  print('Error creating/updating product: $e');
                  
                  String userFriendlyError = e.toString().replaceAll('Exception: ', '');
                  
                  // Show specific error dialog if it's about missing tables
                  if (userFriendlyError.contains('Las tablas de Supabase no están configuradas')) {
                    _showSupabaseSetupDialog(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $userFriendlyError'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                        action: SnackBarAction(
                          label: 'Ver Solución',
                          textColor: Colors.white,
                          onPressed: () => _showSupabaseSetupDialog(context),
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Actualizar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProduct(StoreProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Producto'),
        content: Text('¿Estás seguro de eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Replace with Supabase implementation
        await Future.delayed(Duration(milliseconds: 500));
        print('Deleting product: ${product.id}');
        
        await _loadData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto eliminado (simulado)'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error eliminando producto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant': return Icons.restaurant;
      case 'devices': return Icons.devices;
      case 'spa': return Icons.spa;
      case 'local_drink': return Icons.local_drink;
      case 'hardware': return Icons.hardware;
      case 'build': return Icons.build;
      case 'construction': return Icons.construction;
      case 'local_pharmacy': return Icons.local_pharmacy;
      default: return Icons.store;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          'Gestión de Tienda',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity( 0.7),
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          isScrollable: true,
          tabs: [
            Tab(text: 'Categorías'),
            Tab(text: 'Subcategorías'),
            Tab(text: 'Productos'),
            Tab(text: 'Recién Llegados'),
            Tab(text: 'Entrega'),
            Tab(text: 'Configuración'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriesTab(isDesktop),
                _buildSubcategoriesTab(isDesktop),
                _buildProductsTab(isDesktop),
                _buildRecentProductsTab(isDesktop),
                _buildDeliveryTab(isDesktop),
                _buildSettingsTab(isDesktop),
              ],
            ),
    );
  }

  Widget _buildCategoriesTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Categorías de Productos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: _addCategory,
                icon: Icon(Icons.add),
                label: Text('Nueva Categoría'),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          if (_categories.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No hay categorías creadas'),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          _getCategoryIcon(category.iconName),
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 12),
                        Text(
                          category.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          category.description,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, size: 20),
                              onPressed: () => _editCategory(category),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _deleteCategory(category),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubcategoriesTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Subcategorías',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showSubcategoryDialog(),
                icon: Icon(Icons.add),
                label: Text('Nueva Subcategoría'),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          if (_subcategories.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No hay subcategorías creadas'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _subcategories.length,
              itemBuilder: (context, index) {
                final subcategory = _subcategories[index];
                final parentCategory = _categories.firstWhere(
                  (cat) => cat.id == subcategory['categoryId'],
                  orElse: () => ProductCategory(
                    id: 'unknown',
                    name: 'Desconocida',
                    description: '',
                    iconName: 'store',
                  ),
                );
                
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      _getCategoryIcon(parentCategory.iconName),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(subcategory['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Categoría: ${parentCategory.name}'),
                        if (subcategory['description'].isNotEmpty)
                          Text(subcategory['description']),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showSubcategoryDialog(subcategory: subcategory),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Eliminar Subcategoría'),
                                content: Text('¿Estás seguro de eliminar "${subcategory['name']}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirmed == true) {
                              try {
                                // TODO: Replace with Supabase implementation
                                await Future.delayed(Duration(milliseconds: 500));
                                print('Deleting subcategory: ${subcategory['id']}');
                                await _loadData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Subcategoría eliminada (simulado)'), backgroundColor: Colors.green),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar productos...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: _filterProducts,
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _addProduct,
                        icon: Icon(Icons.add),
                        label: Text('Nuevo Producto'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Botón de prueba para verificar conexión
                          try {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Probando conexión simulada...'), backgroundColor: Colors.blue),
                            );
                            
                            await Future.delayed(Duration(seconds: 1));
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('✅ Conexión simulada exitosa'), backgroundColor: Colors.green),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('❌ Error de conexión: $e'), backgroundColor: Colors.red),
                            );
                          }
                        },
                        icon: Icon(Icons.wifi),
                        label: Text('Probar Conexión'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Filtrar por categoría: '),
                      SizedBox(width: 16),
                      DropdownButton<String?>(
                        value: _selectedCategoryFilter,
                        hint: Text('Todas las categorías'),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Todas las categorías'),
                          ),
                          ..._categories.map((category) =>
                            DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          ),
                        ],
                        onChanged: _filterByCategory,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          
          if (_filteredProducts.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No se encontraron productos'),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final category = _categories.firstWhere(
                  (c) => c.id == product.categoryId,
                  orElse: () => ProductCategory(
                    id: 'unknown',
                    name: 'Sin categoría',
                    description: '',
                    iconName: 'store',
                  ),
                );

                return Card(
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.image, size: 50, color: Colors.grey[400]),
                                )
                              : Icon(Icons.image, size: 50, color: Colors.grey[400]),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                category.name,
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '\$${product.price.toStringAsFixed(2)} / ${product.unit}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Stock: ${product.stock}',
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                              if (!product.isAvailable)
                                Chip(
                                  label: Text('INACTIVO'),
                                  backgroundColor: Colors.red[100],
                                  labelStyle: TextStyle(fontSize: 9, color: Colors.red),
                                ),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 18),
                                    onPressed: () => _editProduct(product),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, size: 18, color: Colors.red),
                                    onPressed: () => _deleteProduct(product),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentProductsTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Productos Recién Llegados',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                'Últimos 20 productos agregados',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          if (_recentProducts.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text('No hay productos recientes'),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 5 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: _recentProducts.length,
              itemBuilder: (context, index) {
                final product = _recentProducts[index];
                final category = _categories.firstWhere(
                  (c) => c.id == product.categoryId,
                  orElse: () => ProductCategory(
                    id: 'unknown',
                    name: 'Sin categoría',
                    description: '',
                    iconName: 'store',
                  ),
                );

                return Card(
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge de "NUEVO"
                      Stack(
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: product.imageUrl.isNotEmpty
                                ? Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.image, size: 40, color: Colors.grey[400]),
                                  )
                                : Icon(Icons.image, size: 40, color: Colors.grey[400]),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NUEVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              category.name,
                              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Métodos de Entrega',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  
                  // Express delivery
                  ListTile(
                    leading: Icon(Icons.flash_on, color: Colors.orange),
                    title: Text('Entrega Express'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Disponible para ${StoreService.expressProvinces.length} provincias'),
                        SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: StoreService.expressProvinces.take(5).map((province) =>
                            Chip(
                              label: Text(province, style: TextStyle(fontSize: 10)),
                              backgroundColor: Colors.orange.withOpacity( 0.1),
                            ),
                          ).toList(),
                        ),
                        if (StoreService.expressProvinces.length > 5)
                          Text('+ ${StoreService.expressProvinces.length - 5} más',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                  Divider(),
                  
                  // Ship delivery
                  ListTile(
                    leading: Icon(Icons.directions_boat, color: Colors.blue),
                    title: Text('Entrega por Barco'),
                    subtitle: Text('Disponible para todas las ${cubanProvinces.length} provincias de Cuba'),
                  ),
                  
                  SizedBox(height: 24),
                  
                  Text(
                    'Configuración de Costos de Entrega',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💡 Información importante:'),
                          SizedBox(height: 8),
                          Text('• Los costos de entrega se configuran individualmente para cada producto'),
                          Text('• Los productos Express tienen costos de envío más altos'),
                          Text('• Los productos por Barco tienen costos más económicos pero mayor tiempo de entrega'),
                          Text('• Puedes asignar provincias específicas para cada producto'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estadísticas de la Tienda',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  
                  ListTile(
                    leading: Icon(Icons.category, color: Colors.blue),
                    title: Text('Total de Categorías'),
                    trailing: Chip(
                      label: Text('${_categories.length}'),
                      backgroundColor: Colors.blue.withOpacity( 0.1),
                    ),
                  ),
                  
                  ListTile(
                    leading: Icon(Icons.subdirectory_arrow_right, color: Colors.purple),
                    title: Text('Total de Subcategorías'),
                    trailing: Chip(
                      label: Text('${_subcategories.length}'),
                      backgroundColor: Colors.purple.withOpacity( 0.1),
                    ),
                  ),
                  
                  ListTile(
                    leading: Icon(Icons.inventory, color: Colors.green),
                    title: Text('Total de Productos'),
                    trailing: Chip(
                      label: Text('${_products.length}'),
                      backgroundColor: Colors.green.withOpacity( 0.1),
                    ),
                  ),
                  
                  ListTile(
                    leading: Icon(Icons.new_releases, color: Colors.orange),
                    title: Text('Productos Recientes'),
                    trailing: Chip(
                      label: Text('${_recentProducts.length}'),
                      backgroundColor: Colors.orange.withOpacity( 0.1),
                    ),
                  ),
                  
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Productos Disponibles'),
                    trailing: Chip(
                      label: Text('${_products.where((p) => p.isAvailable).length}'),
                      backgroundColor: Colors.green.withOpacity( 0.2),
                    ),
                  ),
                  
                  ListTile(
                    leading: Icon(Icons.cancel, color: Colors.red),
                    title: Text('Productos Inactivos'),
                    trailing: Chip(
                      label: Text('${_products.where((p) => !p.isAvailable).length}'),
                      backgroundColor: Colors.red.withOpacity( 0.1),
                    ),
                  ),
                  
                  Divider(),
                  
                  ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Recargar Datos'),
                    subtitle: Text('Actualizar todas las estadísticas'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: _loadData,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración Avanzada',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  
                  ListTile(
                    leading: Icon(Icons.storage, color: Colors.indigo),
                    title: Text('Gestión de Imágenes'),
                    subtitle: Text('Las imágenes se almacenan en Firebase Storage'),
                    trailing: Icon(Icons.info_outline),
                  ),
                  
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.red),
                    title: Text('Cobertura Geográfica'),
                    subtitle: Text('${cubanProvinces.length} provincias de Cuba'),
                    trailing: Icon(Icons.info_outline),
                  ),
                  
                  ListTile(
                    leading: Icon(Icons.palette, color: Colors.pink),
                    title: Text('Opciones de Personalización'),
                    subtitle: Text('${productSizes.length} tallas, ${productColors.length} colores'),
                    trailing: Icon(Icons.info_outline),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build image preview widget that handles different image sources
  Widget _buildImagePreview(String imageSource) {
    if (imageSource.startsWith('data:image')) {
      // Base64 encoded image (web)
      try {
        final bytes = base64Decode(imageSource.split(',')[1]);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (e) {
        print('Error decodificando imagen base64: $e');
        return _buildErrorPlaceholder();
      }
    } else if (imageSource.startsWith('/') && !kIsWeb) {
      // Local file path (mobile)
      return Image.file(
        File(imageSource),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    } else if (imageSource.startsWith('http')) {
      // Network URL
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    } else {
      return _buildErrorPlaceholder();
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey.shade400),
          SizedBox(height: 8),
          Text(
            'Error cargando imagen',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Show Supabase setup dialog with SQL instructions
  void _showSupabaseSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Configuración de Supabase Requerida'),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Las tablas de la tienda no están configuradas en Supabase. Sigue estos pasos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text('1. Ve a tu Dashboard de Supabase'),
                Text('2. Abre el "SQL Editor"'),
                Text('3. Copia y ejecuta el siguiente SQL:'),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    StoreService.getSetupSQL(),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                    maxLines: 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 12),
                Text('4. Reinicia la aplicación'),
                Text('5. Intenta crear el producto nuevamente'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Copy SQL to clipboard (web only)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('SQL copiado al portapapeles (en aplicaciones que lo soporten)'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: Text('Copiar SQL'),
          ),
        ],
      ),
    );
  }
}