import 'package:flutter/material.dart';
import 'package:cubalink23/models/amazon_product.dart';
import 'package:cubalink23/models/walmart_product.dart';
import 'package:cubalink23/services/amazon_api_service.dart';
import 'package:cubalink23/services/walmart_api_service.dart';
import 'package:cubalink23/services/cart_service.dart';
import 'package:cubalink23/screens/shopping/cart_screen.dart';
import 'package:cubalink23/services/auth_guard_service.dart';

class AmazonShoppingScreen extends StatefulWidget {
  const AmazonShoppingScreen({super.key});

  @override
  _AmazonShoppingScreenState createState() => _AmazonShoppingScreenState();
}

class _AmazonShoppingScreenState extends State<AmazonShoppingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AmazonApiService _apiService = AmazonApiService();
  final WalmartApiService _walmartApiService = WalmartApiService();
  final CartService _cartService = CartService();
  List<AmazonProduct> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  final String _selectedCategory = 'Todos';
  String _selectedStore = 'Amazon'; // New store selector
  
  // Available stores
  final List<Map<String, dynamic>> _availableStores = [
    {
      'name': 'Amazon',
      'color': Color(0xFF146EB4),
      'backgroundColor': Color(0xFF232F3E),
      'icon': Icons.shopping_cart,
    },
    {
      'name': 'Shein',
      'color': Color(0xFFFF6B35),
      'backgroundColor': Color(0xFF2C2C2C),
      'icon': Icons.checkroom,
    },
    {
      'name': 'Home Depot',
      'color': Color(0xFFF96302),
      'backgroundColor': Color(0xFFFFFFFF),
      'icon': Icons.home_repair_service,
    },
    {
      'name': 'Walmart',
      'color': Color(0xFF004C91),
      'backgroundColor': Color(0xFFFFC220),
      'icon': Icons.store,
    },
  ];

  // Dynamic colors based on selected store
  Color get currentStoreColor => _availableStores.firstWhere((store) => store['name'] == _selectedStore)['color'];
  Color get currentStoreBackgroundColor => _availableStores.firstWhere((store) => store['name'] == _selectedStore)['backgroundColor'];
  IconData get currentStoreIcon => _availableStores.firstWhere((store) => store['name'] == _selectedStore)['icon'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header simple y limpio
            Container(
              color: currentStoreColor,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Compras $_selectedStore',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Encuentra millones de productos',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.shopping_cart, color: Colors.white, size: 24),
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
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${_cartService.itemCount}',
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
                  ],
                ),
              ),
            ),
            // Store Selector simple
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        color: currentStoreColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Selecciona la tienda:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _availableStores.map((store) => _buildStoreSelector(store)).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar limpio y simple
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar en $_selectedStore',
                    hintStyle: TextStyle(
                      color: Colors.grey[500], 
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(Icons.search, color: currentStoreColor, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 4),
                                child: Material(
                                  color: currentStoreColor,
                                  borderRadius: BorderRadius.circular(6),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () {
                                      if (_searchController.text.isNotEmpty) {
                                        _performSearch(_searchController.text);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Text(
                                        'Ir',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[600], size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults.clear();
                                    _hasSearched = false;
                                  });
                                },
                              ),
                            ],
                          )
                        : Container(
                            margin: EdgeInsets.only(right: 4),
                            child: Material(
                              color: currentStoreColor,
                              borderRadius: BorderRadius.circular(6),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () {
                                  if (_searchController.text.isNotEmpty) {
                                    _performSearch(_searchController.text);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Text(
                                    'Ir',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  ),
                  onSubmitted: _performSearch,
                  onChanged: (value) {
                    setState(() {}); // Para actualizar el botón clear
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSelector(Map<String, dynamic> store) {
    bool isSelected = _selectedStore == store['name'];
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStore = store['name'];
            _searchResults.clear();
            _hasSearched = false;
            _searchController.clear();
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? store['color'] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? store['color'] : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                store['icon'],
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                store['name'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
              valueColor: AlwaysStoppedAnimation<Color>(currentStoreColor),
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
      return _buildWelcomeContent();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsContent();
    }

    return _buildSearchResults();
  }

  Widget _buildWelcomeContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 40), // Padding inferior para Motorola
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner principal simple
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: currentStoreColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Compras $_selectedStore',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Encuentra millones de productos',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Envío a Cuba en 48-72h',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Título de categorías
          Text(
            'Categorías populares',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Grid de categorías optimizado
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildCategoryCard(
                  'Electrónicos', Icons.devices, 'iPhone, TV, Laptops'),
              _buildCategoryCard(
                  'Moda', Icons.shopping_bag, 'Ropa, Zapatos, Accesorios'),
              _buildCategoryCard('Casa', Icons.home, 'Muebles, Decoración'),
              _buildCategoryCard('Libros', Icons.book, 'Físicos y digitales'),
              _buildCategoryCard(
                  'Deportes', Icons.sports_soccer, 'Equipos y ropa deportiva'),
              _buildCategoryCard('Belleza', Icons.face, 'Cosmética y cuidado'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _searchController.text = title.toLowerCase();
            _performSearch(title.toLowerCase());
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: currentStoreColor,
                  size: 28,
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsContent() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: currentStoreColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 60,
                color: currentStoreColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No encontramos resultados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Intenta con otras palabras clave o revisa la ortografía',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _hasSearched = false;
                  _searchResults.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStoreColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Nueva Búsqueda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        // Información de resultados
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Text(
            '${_searchResults.length} productos encontrados',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(AmazonProduct product) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del producto
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.mainImage.isNotEmpty
                        ? Image.network(
                            product.mainImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image,
                                color: Colors.grey[400],
                                size: 32,
                              );
                            },
                          )
                        : Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 32,
                          ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.brand != null) ...[
                        SizedBox(height: 2),
                        Text(
                          'Por ${product.brand}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      SizedBox(height: 4),
                      if (product.rating != null) ...[
                        Row(
                          children: [
                            ...List.generate(
                                5,
                                (index) => Icon(
                                      index < product.rating!.floor()
                                          ? Icons.star
                                          : (index < product.rating!
                                              ? Icons.star_half
                                              : Icons.star_border),
                                      color: currentStoreColor,
                                      size: 14,
                                    )),
                            SizedBox(width: 4),
                            Text(
                              '${product.rating!.toStringAsFixed(1)} (${product.reviewCount ?? 0})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            product.formattedPrice,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB12704),
                            ),
                          ),
                          if (product.hasDiscount) ...[
                            SizedBox(width: 8),
                            Text(
                              product.formattedOriginalPrice!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFFB12704),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${product.discountPercentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (product.weight != null) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.scale,
                                size: 12, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              'Peso: ${product.formattedWeight}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showProductDetails(product);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Ver detalles'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _addToCart(product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentStoreColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Agregar al carrito'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    // Verificar autenticación solo para Amazon
    if (_selectedStore == 'Amazon') {
      final hasAuth = await AuthGuardService.instance.requireAuthForAmazon(context, action: 'search');
      if (!hasAuth) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchResults.clear();
    });

    try {
      List<AmazonProduct> results = [];
      
      // Usar diferentes APIs según la tienda seleccionada
      switch (_selectedStore) {
        case 'Amazon':
          // Mapear categorías locales a categorías de Amazon
          String? apiCategory;
          if (_selectedCategory != 'Todos') {
            switch (_selectedCategory) {
              case 'Electrónicos':
                apiCategory = 'Electronics';
                break;
              case 'Moda':
                apiCategory = 'Clothing, Shoes & Jewelry';
                break;
              case 'Casa y Jardín':
                apiCategory = 'Garden & Outdoor';
                break;
              case 'Deportes':
                apiCategory = 'Sports & Outdoors';
                break;
              case 'Libros':
                apiCategory = 'Books';
                break;
              case 'Juguetes':
                apiCategory = 'Toys & Games';
                break;
            }
          }

          results = await _apiService.searchProducts(
            query: query,
            country: 'US',
            category: apiCategory,
          );
          break;
          
        case 'Shein':
          // Aquí irá la API de Shein
          results = await _getSheinProducts(query);
          break;
          
        case 'Home Depot':
          // Aquí irá la API de Home Depot
          results = await _getHomeDepotProducts(query);
          break;
          
        case 'Walmart':
          // Aquí irá la API de Walmart
          results = await _getWalmartProducts(query);
          break;
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

      // Mostrar mensaje si no hay resultados
      if (results.isEmpty) {
        _showNoResultsSnackBar(query);
      } else {
        _showSearchSuccessSnackBar(results.length);
      }
    } catch (e) {
      print('❌ Error en la búsqueda de $_selectedStore: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });

      _showErrorSnackBar('Error al buscar productos en $_selectedStore: ${e.toString()}');
    }
  }

  void _showProductDetails(AmazonProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Detalles del producto',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Galería de imágenes del producto
                          _buildImageGallery(product),
                          SizedBox(height: 20),

                          // Título
                          Text(
                            product.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),

                          // Marca
                          if (product.brand != null) ...[
                            SizedBox(height: 6),
                            Text(
                              'Por ${product.brand}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],

                          SizedBox(height: 12),

                          // Rating
                          if (product.rating != null) ...[
                            Row(
                              children: [
                                ...List.generate(
                                    5,
                                    (index) => Icon(
                                          index < product.rating!.floor()
                                              ? Icons.star
                                              : (index < product.rating!
                                                  ? Icons.star_half
                                                  : Icons.star_border),
                                          color: currentStoreColor,
                                          size: 18,
                                        )),
                                SizedBox(width: 8),
                                Text(
                                  '${product.rating!.toStringAsFixed(1)} (${product.reviewCount ?? 0} reseñas)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                          ],

                          // Precio
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.formattedPrice,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB12704),
                                ),
                              ),
                              if (product.hasDiscount) ...[
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.formattedOriginalPrice!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFB12704),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'AHORRA ${product.discountPercentage.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),

                          SizedBox(height: 24),

                          // Información adicional
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.weight != null) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.scale,
                                          size: 16, color: Colors.grey[600]),
                                      SizedBox(width: 8),
                                      Text(
                                        'Peso: ${product.formattedWeight}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                ],
                                if (product.color != null) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.palette,
                                          size: 16, color: Colors.grey[600]),
                                      SizedBox(width: 8),
                                      Text(
                                        'Color: ${product.color}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                ],
                                Row(
                                  children: [
                                    Icon(Icons.local_shipping,
                                        size: 16, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text(
                                      'Envío a Cuba en 48-72h',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Descripción
                          if (product.description != null && product.description!.isNotEmpty) ...[
                            Text(
                              'Descripción:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              product.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                          
                          // Características
                          Text(
                            'Características principales:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 12),

                          if (product.features != null &&
                              product.features!.isNotEmpty)
                            ...product.features!.map((feature) => Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 6, right: 8),
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: currentStoreColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                          else
                            Column(
                              children: [
                                '✓ Envío rápido a Cuba',
                                '✓ Producto original y nuevo',
                                '✓ Empaque seguro y protegido',
                                '✓ Seguimiento del envío incluido',
                                '✓ Garantía de entrega'
                              ]
                                  .map((feature) => Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle,
                                                size: 16,
                                                color: Colors.green[600]),
                                            SizedBox(width: 8),
                                            Text(
                                              feature.substring(
                                                  2), // Quitar el "✓ "
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),

                          SizedBox(height: 100), // Espacio para el botón fijo
                        ],
                      ),
                    ),
                  ),

                  // Botón fijo en la parte inferior
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _addToCart(product);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentStoreColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Agregar al carrito - ${product.formattedPrice}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) => setState(() {})); // Actualizar el badge del carrito
  }

  Future<void> _addToCart(AmazonProduct product) async {
    // Verificar autenticación solo para Amazon
    if (_selectedStore == 'Amazon') {
      final hasAuth = await AuthGuardService.instance.requireAuthForAmazon(context, action: 'add_to_cart');
      if (!hasAuth) {
        return;
      }
    }
    
    _cartService.addAmazonProduct(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '${product.title} agregado al carrito',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF067D62),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'VER CARRITO',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CartScreen(),
              ),
            );
          },
        ),
      ),
    );

    // Actualizar el UI
    setState(() {});
  }

  void _showNoResultsSnackBar(String query) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No se encontraron productos para "$query"'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSearchSuccessSnackBar(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Encontrados $count productos'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 4),
      ),
    );
  }
  
  Widget _buildImageGallery(AmazonProduct product) {
    final List<String> availableImages = product.images.where((img) => img.isNotEmpty).toList();
    
    if (availableImages.isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Icon(
            Icons.image,
            color: Colors.grey[400],
            size: 64,
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen principal
        GestureDetector(
          onTap: () => _showImageModal(availableImages, 0),
          child: Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                availableImages.first,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[400],
                      size: 64,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Imágenes adicionales
        if (availableImages.length > 1) ...[
          SizedBox(height: 12),
          Text(
            'Más fotos (${availableImages.length}):',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableImages.length.clamp(1, 5), // Máximo 5 imágenes adicionales
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showImageModal(availableImages, index),
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Image.network(
                            availableImages[index],
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                              );
                            },
                          ),
                          // Ícono de maximizar
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
  
  void _showImageModal(List<String> images, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black.withOpacity(0.9),
        child: Stack(
          children: [
            // Visor de imágenes
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Image.network(
                        images[index],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Error al cargar imagen',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Botón cerrar
            Positioned(
              top: 40,
              right: 20,
              child: SafeArea(
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            
            // Indicador de página
            if (images.length > 1)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${initialIndex + 1} / ${images.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Instrucción de zoom
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Toca dos veces para hacer zoom',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos simulados para otras tiendas (aquí se integrarían las APIs reales)
  Future<List<AmazonProduct>> _getSheinProducts(String query) async {
    // Simular delay de API
    await Future.delayed(Duration(seconds: 1));
    
    // Productos simulados para Shein (moda y accesorios)
    return [
      AmazonProduct(
        asin: 'shein_001',
        title: 'SHEIN Vestido Casual de Manga Corta para Mujer',
        price: 12.99,
        originalPrice: 19.99,
        images: ['https://img.shein.com/images3_akamai/women/2023/0724/90bda1cf7d6a4e7c8e8f7c8e8f7c8e8f.jpg'],
        description: 'Vestido casual perfecto para el día a día, fabricado en algodón suave y cómodo.',
        rating: 4.2,
        reviewCount: 1847,
        weight: '0.3 kg',
        weightKg: 0.3,
        brand: 'SHEIN',
        color: 'Azul',
        features: ['Material: 100% Algodón', 'Manga corta', 'Cuello redondo', 'Fit regular'],
      ),
      AmazonProduct(
        asin: 'shein_002',
        title: 'SHEIN Bolso de Hombro Estilo Vintage para Mujer',
        price: 8.99,
        originalPrice: 14.99,
        images: ['https://img.shein.com/images3_akamai/bags/2023/0724/bag_vintage_style.jpg'],
        description: 'Elegante bolso de hombro con diseño vintage, perfecto para cualquier ocasión.',
        rating: 4.5,
        reviewCount: 923,
        weight: '0.5 kg',
        weightKg: 0.5,
        brand: 'SHEIN',
        color: 'Negro',
        features: ['Material: Cuero sintético', 'Diseño vintage', 'Asa ajustable', 'Compartimento principal'],
      ),
    ];
  }
  
  Future<List<AmazonProduct>> _getHomeDepotProducts(String query) async {
    await Future.delayed(Duration(seconds: 1));
    
    // Productos simulados para Home Depot (hogar y herramientas)
    return [
      AmazonProduct(
        asin: 'homedepot_001',
        title: 'BLACK+DECKER Taladro Inalámbrico 20V MAX',
        price: 49.99,
        originalPrice: 79.99,
        images: ['https://images.homedepot-static.com/productImages/drill_20v_max.jpg'],
        description: 'Taladro inalámbrico potente y versátil, perfecto para proyectos de hogar.',
        rating: 4.4,
        reviewCount: 2341,
        weight: '1.8 kg',
        weightKg: 1.8,
        brand: 'BLACK+DECKER',
        features: ['Batería 20V MAX', 'Chuck de 3/8"', 'LED incorporado', 'Gatillo de velocidad variable'],
      ),
      AmazonProduct(
        asin: 'homedepot_002',
        title: 'Pintura Interior Premium Sherwin-Williams',
        price: 32.99,
        images: ['https://images.homedepot-static.com/productImages/paint_interior_premium.jpg'],
        description: 'Pintura interior de alta calidad con acabado sedoso y gran cobertura.',
        rating: 4.7,
        reviewCount: 1567,
        weight: '4.5 kg',
        weightKg: 4.5,
        brand: 'Sherwin-Williams',
        color: 'Blanco',
        features: ['1 Galón', 'Cobertura premium', 'Secado rápido', 'Bajo olor'],
      ),
    ];
  }
  
  Future<List<AmazonProduct>> _getWalmartProducts(String query) async {
    print('🛒 Buscando productos en Walmart API: $query');
    
    try {
      // Usar la API real de Walmart
      List<WalmartProduct> walmartProducts = await _walmartApiService.searchProducts(
        query: query,
        page: 1,
        country: 'US',
      );
      
      print('✅ Productos Walmart encontrados: ${walmartProducts.length}');
      
      // Convertir WalmartProduct a AmazonProduct para compatibilidad con la UI
      List<AmazonProduct> convertedProducts = walmartProducts.map((walmartProduct) {
        return AmazonProduct(
          asin: walmartProduct.productId,
          title: walmartProduct.title,
          description: walmartProduct.description,
          price: walmartProduct.price,
          originalPrice: walmartProduct.originalPrice,
          currency: walmartProduct.currency,
          rating: walmartProduct.rating,
          reviewCount: walmartProduct.reviewCount,
          images: walmartProduct.images,
          weight: walmartProduct.weight,
          weightKg: walmartProduct.weightKg,
          dimensions: walmartProduct.dimensions,
          category: walmartProduct.category,
          isAvailable: walmartProduct.isAvailable,
          brand: walmartProduct.brand,
          features: walmartProduct.features,
          color: walmartProduct.color,
          size: walmartProduct.size,
        );
      }).toList();
      
      return convertedProducts;
      
    } catch (e) {
      print('❌ Error buscando productos en Walmart: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
