import 'package:flutter/material.dart';
import 'package:cubalink23/models/product_category.dart';
import 'package:cubalink23/models/store_product.dart';
import 'package:cubalink23/services/store_service.dart';
import 'package:cubalink23/services/cart_service.dart';
import 'package:cubalink23/services/firebase_repository.dart';
import 'package:cubalink23/screens/shopping/store_category_screen.dart';
import 'package:cubalink23/screens/shopping/product_details_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final StoreService _storeService = StoreService();
  final CartService _cartService = CartService();
  final FirebaseRepository _firebaseRepository = FirebaseRepository.instance;
  
  List<ProductCategory> _realCategories = [];
  List<StoreProduct> _realProducts = [];
  bool _isLoading = true;
  String? _selectedMainCategory;

  @override
  void initState() {
    super.initState();
    _initializeStore();
  }

  Future<void> _initializeStore() async {
    try {
      // Initialize store service with default categories
      await _storeService.initializeDefaultCategories();
      
      // Load real categories and products from Firebase
      final categories = await _storeService.getCategories();
      final products = await _storeService.getAllProducts();
      
      if (mounted) {
        setState(() {
          _realCategories = categories;
          _realProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error inicializando tienda: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addToCart(StoreProduct product) {
    final cartItem = {
      'id': 'store_${product.id}',
      'name': product.name,
      'price': product.price,
      'image': product.imageUrl,
      'type': 'store_product',
      'unit': product.unit,
      'quantity': 1,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          'Tienda',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16, // Reducido de 18 a 16
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 20), // Reducido tamaño
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart, color: Colors.white, size: 22), // Reducido de 26 a 22
                if (_cartService.itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(3), // Reducido de 4 a 3
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: BoxConstraints(minWidth: 14, minHeight: 14), // Reducido de 16 a 14
                      child: Text(
                        _cartService.itemCount > 9 ? '9+' : _cartService.itemCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9, // Reducido de 10 a 9
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner informativo
                    _buildInfoBanner(),
                    
                    // Categorías
                    _buildCategoriesSection(),
                    
                    // Productos destacados
                    if (_realProducts.isNotEmpty) _buildFeaturedProductsSection(),
                    
                    SizedBox(height: 40), // Aumentado de 20 a 40 para bottom navigation
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: EdgeInsets.all(12), // Reducido de 16 a 12
      padding: EdgeInsets.all(12), // Reducido de 16 a 12
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade600,
            Colors.green.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(10), // Reducido de 12 a 10
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 6, // Reducido de 8 a 6
            offset: Offset(0, 3), // Reducido de 4 a 3
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.white, size: 20), // Reducido de 24 a 20
              SizedBox(width: 6), // Reducido de 8 a 6
              Text(
                'Entrega Rápida',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Reducido de 18 a 16
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6), // Reducido de 8 a 6
          Text(
            '📦 Entrega Express: Pinar del Río hasta Camagüey\\n🚢 Entrega por Barco: Todas las provincias',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12, // Reducido de 14 a 12
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12), // Reducido de 16 a 12
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category, color: Theme.of(context).colorScheme.primary, size: 20), // Reducido de 24 a 20
              SizedBox(width: 6), // Reducido de 8 a 6
              Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 18, // Reducido de 20 a 18
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12), // Reducido de 16 a 12
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1, // Reducido de 1.2 a 1.1 para más compacto
              mainAxisSpacing: 10, // Reducido de 12 a 10
              crossAxisSpacing: 10, // Reducido de 12 a 10
            ),
            itemCount: _realCategories.length,
            itemBuilder: (context, index) {
              final category = _realCategories[index];
              return _buildCategoryCard(category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ProductCategory category) {
    final iconData = _getCategoryIcon(category.iconName);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreCategoryScreen(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Reducido de 16 a 12
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6, // Reducido de 8 a 6
              offset: Offset(0, 2), // Reducido de 3 a 2
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12), // Reducido de 16 a 12
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 28, // Reducido de 32 a 28
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 8), // Reducido de 12 a 8
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13, // Reducido de 14 a 13
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2), // Reducido de 4 a 2
            Text(
              category.description,
              style: TextStyle(
                fontSize: 10, // Reducido de 11 a 10
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProductsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12), // Reducido de 16 a 12
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20), // Reducido de 24 a 20
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange, size: 20), // Reducido de 24 a 20
              SizedBox(width: 6), // Reducido de 8 a 6
              Text(
                'Productos Destacados',
                style: TextStyle(
                  fontSize: 18, // Reducido de 20 a 18
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12), // Reducido de 16 a 12
          SizedBox(
            height: 200, // Reducido de 220 a 200
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _realProducts.take(10).length,
              itemBuilder: (context, index) {
                final product = _realProducts[index];
                return _buildRealProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRealProductCard(StoreProduct product) {
    return GestureDetector(
      onTap: () {
        // Convert StoreProduct to Map for compatibility with ProductDetailsScreen
        final productMap = {
          'id': product.id,
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'image': product.imageUrl,
          'unit': product.unit,
          'stock': product.stock,
          'isAvailable': product.isAvailable,
          'categoryId': product.categoryId,
          'deliveryMethod': product.deliveryMethod,
          'availableProvinces': product.availableProvinces,
          'weight': product.weight,
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: productMap),
          ),
        );
      },
      child: Container(
        width: 150, // Reducido de 160 a 150
        margin: EdgeInsets.only(right: 10), // Reducido de 12 a 10
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // Reducido de 12 a 10
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6, // Reducido de 8 a 6
              offset: Offset(0, 2), // Reducido de 3 a 2
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)), // Reducido de 12 a 10
                  child: SizedBox(
                    height: 90, // Reducido de 100 a 90
                    width: double.infinity,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 35, // Reducido de 40 a 35
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!product.isAvailable)
                  Positioned(
                    top: 6, // Reducido de 8 a 6
                    left: 6, // Reducido de 8 a 6
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2), // Reducido padding
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6), // Reducido de 8 a 6
                      ),
                      child: Text(
                        'AGOTADO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9, // Reducido de 10 a 9
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10), // Reducido de 12 a 10
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 13, // Reducido de 14 a 13
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15, // Reducido de 16 a 15
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              'por ${product.unit}',
                              style: TextStyle(
                                fontSize: 9, // Reducido de 10 a 9
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        if (product.isAvailable)
                          Container(
                            width: 28, // Reducido de 32 a 28
                            height: 28, // Reducido de 32 a 28
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _addToCart(product),
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16, // Reducido de 18 a 16
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}