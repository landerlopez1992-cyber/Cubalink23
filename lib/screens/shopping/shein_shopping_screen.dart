import 'package:flutter/material.dart';
import 'package:cubalink23/services/cart_service.dart';
import 'package:cubalink23/screens/shopping/cart_screen.dart';
import 'package:cubalink23/services/auth_guard_service.dart';

class SheinShoppingScreen extends StatefulWidget {
  const SheinShoppingScreen({super.key});

  @override
  _SheinShoppingScreenState createState() => _SheinShoppingScreenState();
}

class _SheinShoppingScreenState extends State<SheinShoppingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CartService _cartService = CartService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _selectedCategory = 'Todos';

  // Colores de Shein
  static const Color sheinOrange = Color(0xFFFF6B35);
  static const Color sheinBlack = Color(0xFF2C2C2C);
  static const Color sheinGrey = Color(0xFF4A4A4A);
  static const Color sheinBackground = Color(0xFFFAFAFA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sheinBackground,
      appBar: AppBar(
        backgroundColor: sheinBlack,
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
              hintText: 'Buscar en Shein',
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
                      color: sheinOrange,
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
          // Barra de categorías estilo Shein
          Container(
            height: 50,
            color: sheinGrey,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('Todos'),
                _buildCategoryChip('Ropa Mujer'),
                _buildCategoryChip('Ropa Hombre'),
                _buildCategoryChip('Accesorios'),
                _buildCategoryChip('Zapatos'),
                _buildCategoryChip('Hogar'),
                _buildCategoryChip('Niños'),
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
            color: isSelected ? sheinBlack : Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        backgroundColor: isSelected ? Colors.white : sheinGrey,
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
              valueColor: AlwaysStoppedAnimation<Color>(sheinOrange),
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
      return _buildSheinWelcome();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return _buildProductGrid();
  }

  Widget _buildSheinWelcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: sheinOrange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: sheinOrange.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.checkroom,
              size: 60,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Text(
            '¡Descubre la Moda en Shein!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: sheinBlack,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Busca ropa, accesorios y más\ncon los mejores precios',
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
              color: sheinOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: sheinOrange, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, color: sheinOrange, size: 20),
                SizedBox(width: 8),
                Text(
                  'Busca algo para empezar',
                  style: TextStyle(
                    color: sheinOrange,
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
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No se encontraron productos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product['imageUrl'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.checkroom,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
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
                    product['name'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: sheinOrange,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: sheinOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
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
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    // Check authentication first
    if (!AuthGuardService.instance.checkServiceAccess(context)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Simular búsqueda en Shein - en la práctica usarías la API de Shein
    _simulateSheinSearch(query);
  }

  void _simulateSheinSearch(String query) {
    // Simular productos de Shein
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _searchResults = [
            {
              'id': 'shein_001',
              'name': 'Vestido Casual de Verano - Shein',
              'price': 25.99,
              'imageUrl': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400',
              'store': 'Shein',
            },
            {
              'id': 'shein_002',
              'name': 'Top Crop Moderno - Shein',
              'price': 18.50,
              'imageUrl': 'https://images.unsplash.com/photo-1564584217132-2271feaeb3c5?w=400',
              'store': 'Shein',
            },
            {
              'id': 'shein_003',
              'name': 'Jeans Skinny Mujer - Shein',
              'price': 32.99,
              'imageUrl': 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400',
              'store': 'Shein',
            },
          ];
          _isLoading = false;
        });
      }
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    if (!AuthGuardService.instance.checkServiceAccess(context)) {
      return;
    }

    _cartService.addAmazonProduct({
      'id': product['id'],
      'title': product['name'],
      'price': product['price'],
      'imageUrl': product['imageUrl'],
      'store': 'Shein',
      'quantity': 1,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('Producto agregado al carrito'),
            ),
          ],
        ),
        backgroundColor: sheinOrange,
        duration: Duration(seconds: 2),
      ),
    );
  }
}