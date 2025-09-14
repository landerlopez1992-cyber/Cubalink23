import 'package:flutter/material.dart';
import 'package:cubalink23/models/walmart_product.dart';
import 'package:cubalink23/services/walmart_api_service.dart';
import 'package:cubalink23/services/cart_service.dart';
import 'package:cubalink23/screens/shopping/cart_screen.dart';
import 'package:cubalink23/services/auth_guard_service.dart';
import 'package:cubalink23/screens/shopping/product_details_screen.dart';

class WalmartShoppingScreen extends StatefulWidget {
  const WalmartShoppingScreen({super.key});

  @override
  _WalmartShoppingScreenState createState() => _WalmartShoppingScreenState();
}

class _WalmartShoppingScreenState extends State<WalmartShoppingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WalmartApiService _apiService = WalmartApiService();
  final CartService _cartService = CartService();
  List<WalmartProduct> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _selectedCategory = 'Todos';

  // Colores de Walmart
  static const Color walmartBlue = Color(0xFF004C91);
  static const Color walmartYellow = Color(0xFFFFC220);
  static const Color walmartGrey = Color(0xFF5A5A5A);
  static const Color walmartBackground = Color(0xFFF8F8F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: walmartBackground,
      appBar: AppBar(
        backgroundColor: walmartBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar en Walmart',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: _performSearch,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CartScreen(),
                    ),
                  );
                },
              ),
              if (_cartService.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: walmartYellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartService.itemCount}',
                      style: TextStyle(
                        color: walmartBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de categorías estilo Walmart
          Container(
            height: 50,
            color: walmartGrey,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('Todos'),
                _buildCategoryChip('Supermercado'),
                _buildCategoryChip('Electrónicos'),
                _buildCategoryChip('Ropa'),
                _buildCategoryChip('Hogar'),
                _buildCategoryChip('Farmacia'),
                _buildCategoryChip('Juguetes'),
              ],
            ),
          ),

          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String title) {
    bool isSelected = _selectedCategory == title;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        label: Text(
          title,
          style: TextStyle(
            color: isSelected ? walmartBlue : Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        backgroundColor: isSelected ? Colors.white : walmartGrey,
        selectedColor: Colors.white,
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = title;
          });
          if (_hasSearched && _searchController.text.isNotEmpty) {
            _performSearch(_searchController.text);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(walmartBlue),
            ),
            SizedBox(height: 16),
            Text(
              'Buscando productos...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return _buildWalmartWelcome();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return _buildProductGrid();
  }

  Widget _buildWalmartWelcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: walmartBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: walmartBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.store,
              size: 60,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Text(
            '¡Ahorra Más en Walmart!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: walmartBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Encuentra todo lo que necesitas\na los mejores precios',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: walmartYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: walmartBlue, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, color: walmartBlue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Busca algo para empezar',
                  style: TextStyle(
                    color: walmartBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: walmartGrey,
          ),
          SizedBox(height: 16),
          Text(
            'Sin productos disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: walmartBlue,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'La API de Walmart no está disponible\no no hay productos para esta búsqueda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: walmartYellow.withOpacity( 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: walmartYellow),
            ),
            child: Text(
              '✅ SIN DATOS DEMO - Solo productos reales',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: walmartBlue,
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _performSearch(_searchController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: walmartBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('🔄 Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(WalmartProduct product) {
    final discountPercentage = product.getDiscountPercentage();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to product details
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                productId: product.id,
                productTitle: product.title,
                productPrice: product.price,
                productImage: product.imageUrl ?? '',
                productDescription: product.description,
                productRating: product.rating,
                productReviews: product.reviewsCount,
                productBrand: product.brand,
                isFromWalmart: true,
                walmartProduct: product,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[100],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.imageUrl ?? '',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.store,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                    // Discount badge
                    if (discountPercentage != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '-${discountPercentage.toInt()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Weight indicator
                    if (product.weight != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity( 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.weight!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Brand and rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        if (product.rating > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber,
                              ),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.originalPrice != null && product.originalPrice! > product.price)
                              Text(
                                product.getFormattedOriginalPrice()!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              product.getFormattedPrice(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: walmartBlue,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _addToCart(product),
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: walmartBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
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

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    // Check authentication first
    if (!AuthGuardService.instance.checkServiceAccess(context)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      print('🔍 Buscando productos en Walmart: "$query" (categoría: $_selectedCategory)');
      
      final products = await _apiService.searchProducts(
        query: query,
        category: _selectedCategory != 'Todos' ? _selectedCategory : null,
      );
      
      if (mounted) {
        setState(() {
          _searchResults = products;
          _isLoading = false;
        });
        
        print('✅ Búsqueda completada: ${products.length} productos encontrados');
      }
    } catch (e) {
      print('❌ Error en búsqueda: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar productos. Inténtalo de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToCart(WalmartProduct product) {
    if (!AuthGuardService.instance.checkServiceAccess(context)) {
      return;
    }

    // Add product with weight information
    _cartService.addAmazonProduct({
      'id': product.id,
      'title': product.title,
      'price': product.price,
      'imageUrl': product.imageUrl ?? '',
      'store': 'Walmart',
      'brand': product.brand,
      'weight': product.weight ?? '0.5 lb',
      'weightKg': product.getEstimatedWeightKg(),
      'rating': product.rating,
      'reviewsCount': product.reviewsCount,
      'category': product.category,
      'url': product.url,
      'quantity': 1,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('${product.title} agregado al carrito'),
            ),
          ],
        ),
        backgroundColor: walmartBlue,
        duration: Duration(seconds: 2),
      ),
    );
  }
}