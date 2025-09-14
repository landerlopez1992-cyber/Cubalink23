import 'package:flutter/material.dart';
import 'package:cubalink23/models/product_category.dart';
import 'package:cubalink23/models/store_product.dart';
import 'package:cubalink23/services/store_service.dart';
import 'package:cubalink23/services/cart_service.dart';

class StoreCategoryScreen extends StatefulWidget {
  final ProductCategory? category;
  final String? categoryName;

  const StoreCategoryScreen({super.key, this.category, this.categoryName});

  @override
  _StoreCategoryScreenState createState() => _StoreCategoryScreenState();
}

class _StoreCategoryScreenState extends State<StoreCategoryScreen> {
  final StoreService _storeService = StoreService();
  final CartService _cartService = CartService();
  
  List<StoreProduct> _products = [];
  List<Map<String, dynamic>> _subcategories = [];
  bool _isLoading = true;
  String _selectedProvince = 'La Habana';
  final bool _showingSubcategories = true;
  String _currentCategoryName = '';

  @override
  void initState() {
    super.initState();
    _currentCategoryName = widget.categoryName ?? widget.category?.name ?? '';
    _loadSubcategoriesAndProducts();
  }

  Future<void> _loadSubcategoriesAndProducts() async {
    try {
      // Cargar subcategorías basadas en el nombre de la categoría
      await _loadSubcategories(_currentCategoryName);
      
      // Cargar algunos productos destacados de la categoría general
      await _loadFeaturedProducts(_currentCategoryName);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando datos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSubcategories(String categoryName) async {
    // Definir subcategorías basadas en la categoría principal
    switch (categoryName.toLowerCase()) {
      case 'alimentos':
        _subcategories = [
          {'name': 'Carnes', 'icon': Icons.restaurant, 'color': 0xFFE57373},
          {'name': 'Lácteos', 'icon': Icons.local_drink, 'color': 0xFF64B5F6},
          {'name': 'Frutas & Verduras', 'icon': Icons.eco, 'color': 0xFF81C784},
          {'name': 'Panadería', 'icon': Icons.bakery_dining, 'color': 0xFFFFB74D},
          {'name': 'Mariscos', 'icon': Icons.set_meal, 'color': 0xFF4DB6AC},
          {'name': 'Congelados', 'icon': Icons.ac_unit, 'color': 0xFFBA68C8},
        ];
        break;
      case 'materiales':
        _subcategories = [
          {'name': 'Construcción', 'icon': Icons.construction, 'color': 0xFFFF8A65},
          {'name': 'Pintura', 'icon': Icons.brush, 'color': 0xFF9575CD},
          {'name': 'Madera', 'icon': Icons.park, 'color': 0xFF8D6E63},
          {'name': 'Metal', 'icon': Icons.build_circle, 'color': 0xFF90A4AE},
        ];
        break;
      case 'ferretería':
        _subcategories = [
          {'name': 'Herramientas', 'icon': Icons.build, 'color': 0xFFFF8F00},
          {'name': 'Tornillos', 'icon': Icons.settings, 'color': 0xFF5E35B1},
          {'name': 'Clavos', 'icon': Icons.push_pin, 'color': 0xFF1E88E5},
          {'name': 'Candados', 'icon': Icons.lock, 'color': 0xFF43A047},
        ];
        break;
      case 'farmacia':
        _subcategories = [
          {'name': 'Medicamentos', 'icon': Icons.medication, 'color': 0xFF26A69A},
          {'name': 'Vitaminas', 'icon': Icons.healing, 'color': 0xFFAB47BC},
          {'name': 'Primeros Auxilios', 'icon': Icons.local_hospital, 'color': 0xFFEF5350},
          {'name': 'Cuidado Personal', 'icon': Icons.face, 'color': 0xFF66BB6A},
        ];
        break;
      case 'electrónicos':
        _subcategories = [
          {'name': 'Teléfonos', 'icon': Icons.phone_android, 'color': 0xFF42A5F5},
          {'name': 'Computadoras', 'icon': Icons.computer, 'color': 0xFF5C6BC0},
          {'name': 'Accesorios', 'icon': Icons.headphones, 'color': 0xFFFF7043},
          {'name': 'Electrodomésticos', 'icon': Icons.kitchen, 'color': 0xFF26C6DA},
        ];
        break;
      case 'cosmética':
        _subcategories = [
          {'name': 'Maquillaje', 'icon': Icons.face_retouching_natural, 'color': 0xFFEC407A},
          {'name': 'Perfumes', 'icon': Icons.local_florist, 'color': 0xFF9C27B0},
          {'name': 'Cuidado de Piel', 'icon': Icons.spa, 'color': 0xFF66BB6A},
          {'name': 'Cabello', 'icon': Icons.content_cut, 'color': 0xFFFF9800},
        ];
        break;
      default:
        _subcategories = [];
    }
  }

  Future<void> _loadFeaturedProducts(String categoryName) async {
    // Productos demo para cada categoría
    switch (categoryName.toLowerCase()) {
      case 'alimentos':
        _products = [
          StoreProduct(
            id: 'food_001',
            name: 'Carne de Res Premium',
            description: 'Carne de res fresca, ideal para asados',
            price: 12.99,
            unit: 'lb',
            imageUrl: 'https://pixabay.com/get/g75264e69a9c06c727929a3f013ea13786e405699770a052e82d89b921c61324320d89878b3c3f5c3072f9be949e3d288684f52daaac3e17a79660bfbdf3cd1e3_1280.jpg',
            categoryId: 'alimentos',
            weight: 1.0,
            deliveryMethod: 'express',
          ),
          StoreProduct(
            id: 'food_002',
            name: 'Leche Entera 1L',
            description: 'Leche fresca entera, rica en calcio',
            price: 3.50,
            unit: 'litro',
            imageUrl: 'https://pixabay.com/get/g86d8165e47b58c742f869324506cb752ac86970ac76e9f736e7c4aa6265f28eaec336395b136daa56370b388f5a8e1c383a00a7c67b51a070576e2671ad801a2_1280.jpg',
            categoryId: 'alimentos',
            weight: 1.0,
            deliveryMethod: 'ship',
          ),
        ];
        break;
      default:
        _products = [];
    }
  }

  void _addToCart(StoreProduct product) {
    // Verificar si se puede entregar en la provincia seleccionada
    if (!_storeService.canDeliverTo(_selectedProvince, product.deliveryMethod)) {
      _showDeliveryAlert(product);
      return;
    }

    final cartItem = {
      'id': 'store_${product.id}',
      'name': product.name,
      'price': product.price,
      'image': product.imageUrl,
      'type': 'store_product',
      'unit': product.unit,
      'quantity': 1,
      'weight': product.weight,
      'categoryId': product.categoryId,
      'deliveryProvince': _selectedProvince,
    };

    _cartService.addFoodProduct(cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido al carrito'),
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: 'Ver Carrito',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  void _addDemoProductToCart(Map<String, dynamic> productData) {
    final cartItem = {
      'id': 'demo_${productData['name'].replaceAll(' ', '_').toLowerCase()}',
      'name': productData['name'],
      'price': productData['price'],
      'image': productData['image'],
      'type': 'store_product',
      'unit': productData['unit'],
      'quantity': 1,
    };

    _cartService.addFoodProduct(cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${productData['name']} añadido al carrito'),
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: 'Ver Carrito',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  void _showDeliveryAlert(StoreProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('Entrega No Disponible'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Este producto no se puede entregar en $_selectedProvince con el método de entrega ${product.deliveryMethod}.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            if (product.deliveryMethod == 'express') ...[
              Text(
                'Entrega Express disponible en:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              ...StoreService.expressProvinces.map((province) => 
                Text('• $province', style: TextStyle(fontSize: 14))),
            ] else ...[
              Text(
                'Entrega por Barco disponible en todas las provincias.',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
          if (product.deliveryMethod == 'express')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showProvinceSelector();
              },
              child: Text('Cambiar Provincia'),
            ),
        ],
      ),
    );
  }

  void _showProvinceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar Provincia de Entrega',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: StoreService.allProvinces.length,
                itemBuilder: (context, index) {
                  final province = StoreService.allProvinces[index];
                  final isSelected = province == _selectedProvince;
                  final isExpressAvailable = StoreService.expressProvinces.contains(province);
                  
                  return ListTile(
                    title: Text(province),
                    subtitle: Text(
                      isExpressAvailable ? 'Express + Barco' : 'Solo Barco',
                      style: TextStyle(
                        color: isExpressAvailable ? Colors.green : Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected 
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedProvince = province;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          _currentCategoryName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart, color: Colors.white, size: 26),
                if (_cartService.itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        _cartService.itemCount > 9 ? '9+' : _cartService.itemCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de provincia
          _buildProvinceSelector(),
          
          // Contenido principal
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _showingSubcategories
                    ? _buildSubcategoriesAndProducts()
                    : _buildProductsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProvinceSelector() {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 8),
          Text(
            'Entregar en: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showProvinceSelector,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedProvince,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No hay productos disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'en esta categoría por el momento.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoriesAndProducts() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subcategorías
          if (_subcategories.isNotEmpty) ...[
            Text(
              'Subcategorías',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _subcategories.length,
              itemBuilder: (context, index) {
                final subcategory = _subcategories[index];
                return _buildSubcategoryCard(subcategory);
              },
            ),
            SizedBox(height: 24),
          ],
          
          // Productos destacados
          if (_products.isNotEmpty) ...[
            Text(
              'Productos Destacados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),
            ..._products.map((product) => _buildProductCard(product)),
          ],
        ],
      ),
    );
  }

  Widget _buildSubcategoryCard(Map<String, dynamic> subcategory) {
    return GestureDetector(
      onTap: () {
        // Aquí podrías navegar a una pantalla de productos específicos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cargando productos de ${subcategory['name']}...'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity( 0.1),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(subcategory['color']).withOpacity( 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                subcategory['icon'],
                size: 32,
                color: Color(subcategory['color']),
              ),
            ),
            SizedBox(height: 12),
            Text(
              subcategory['name'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(StoreProduct product) {
    final canDeliver = _storeService.canDeliverTo(_selectedProvince, product.deliveryMethod);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity( 0.1),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 32,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        ' por ${product.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Spacer(),
                      if (!canDeliver)
                        Icon(
                          Icons.local_shipping_outlined,
                          color: Colors.orange,
                          size: 16,
                        ),
                    ],
                  ),
                  if (!canDeliver)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'No disponible en $_selectedProvince',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Botón agregar al carrito
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: canDeliver
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: canDeliver ? () => _addToCart(product) : null,
                icon: Icon(
                  Icons.add,
                  color: canDeliver ? Colors.white : Colors.grey.shade500,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        final canDeliver = _storeService.canDeliverTo(_selectedProvince, product.deliveryMethod);
        
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity( 0.1),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Imagen del producto
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                
                // Información del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            ' por ${product.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Spacer(),
                          if (!canDeliver)
                            Icon(
                              Icons.local_shipping_outlined,
                              color: Colors.orange,
                              size: 16,
                            ),
                        ],
                      ),
                      if (!canDeliver)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'No disponible en $_selectedProvince',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Botón agregar al carrito
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: canDeliver
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: canDeliver ? () => _addToCart(product) : null,
                    icon: Icon(
                      Icons.add,
                      color: canDeliver ? Colors.white : Colors.grey.shade500,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}