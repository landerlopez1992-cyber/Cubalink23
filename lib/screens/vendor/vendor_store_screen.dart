import 'package:flutter/material.dart';
import 'package:cubalink23/services/cart_service.dart';
import 'package:cubalink23/services/store_service.dart';
import 'package:cubalink23/models/store_product.dart';

class VendorStoreScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  final String vendorImage;
  final double rating;
  final String deliveryTime;
  final double deliveryCost;

  const VendorStoreScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
    this.vendorImage = '',
    this.rating = 4.5,
    this.deliveryTime = '1 día',
    this.deliveryCost = 15.30,
  });

  @override
  _VendorStoreScreenState createState() => _VendorStoreScreenState();
}

class _VendorStoreScreenState extends State<VendorStoreScreen>
    with TickerProviderStateMixin {
  final CartService _cartService = CartService();
  final StoreService _storeService = StoreService();
  
  List<StoreProduct> _products = [];
  final List<String> _categories = ['Super Ofertas', 'Combos', 'Carnicería', 'Agro'];
  String _selectedCategory = 'Super Ofertas';
  bool _isLoading = true;
  bool _deliverySelected = true; // true = A domicilio, false = Recogida
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadVendorProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVendorProducts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Cargar productos del vendedor desde Supabase
      _products = await _storeService.getVendorProducts(widget.vendorId);
      
      print('✅ Productos del vendedor cargados: ${_products.length}');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando productos del vendedor: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addToCart(StoreProduct product) {
    final cartItem = {
      'id': 'vendor_${product.id}',
      'name': product.name,
      'price': product.price,
      'image': product.imageUrl,
      'type': 'vendor_product',
      'unit': product.unit,
      'quantity': 1,
      'weight': product.weight,
      'categoryId': product.categoryId,
      'vendorId': widget.vendorId,
      'vendorName': widget.vendorName,
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

  List<StoreProduct> _getFilteredProducts() {
    if (_selectedCategory == 'Super Ofertas') {
      return _products.where((p) => p.price < 10.0).toList();
    } else if (_selectedCategory == 'Combos') {
      return _products.where((p) => p.name.toLowerCase().contains('combo')).toList();
    } else if (_selectedCategory == 'Carnicería') {
      return _products.where((p) => p.categoryId == 'alimentos' && 
          (p.name.toLowerCase().contains('carne') || p.name.toLowerCase().contains('pollo'))).toList();
    } else if (_selectedCategory == 'Agro') {
      return _products.where((p) => p.categoryId == 'alimentos' && 
          (p.name.toLowerCase().contains('huevo') || p.name.toLowerCase().contains('verdura'))).toList();
    }
    return _products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar con banner
          _buildSliverAppBar(),
          
          // Información de la tienda
          _buildStoreInfo(),
          
          // Tabs de categorías
          _buildCategoryTabs(),
          
          // Lista de productos
          _buildProductsList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      backgroundColor: Colors.black,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // TODO: Implementar compartir
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    widget.vendorImage.isNotEmpty 
                        ? widget.vendorImage 
                        : 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=400&fit=crop&crop=center',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Overlay oscuro
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Texto del banner
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Text(
                widget.vendorName.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre de la tienda
            Text(
              widget.vendorName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            
            // Información de entrega
            Row(
              children: [
                Text(
                  '${widget.deliveryTime} • 🚚 \$${widget.deliveryCost.toStringAsFixed(2)} • ⭐ ${widget.rating.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Enlace de información
            GestureDetector(
              onTap: () {
                // TODO: Mostrar información detallada
              },
              child: Text(
                'Pulsa aquí para más información',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Opciones de entrega
            Row(
              children: [
                Expanded(
                  child: _buildDeliveryOption(
                    'A domicilio',
                    _deliverySelected,
                    () => setState(() => _deliverySelected = true),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDeliveryOption(
                    'Recogida',
                    !_deliverySelected,
                    () => setState(() => _deliverySelected = false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOption(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Buscar productos...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tabs de categorías
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: TextStyle(fontWeight: FontWeight.w600),
              onTap: (index) {
                setState(() {
                  _selectedCategory = _categories[index];
                });
              },
              tabs: _categories.map((category) => Tab(text: category)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final filteredProducts = _getFilteredProducts();

    if (filteredProducts.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                SizedBox(height: 16),
                Text(
                  'No hay productos en esta categoría',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = filteredProducts[index];
          return _buildProductCard(product);
        },
        childCount: filteredProducts.length,
      ),
    );
  }

  Widget _buildProductCard(StoreProduct product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen del producto
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: product.imageUrl.isNotEmpty 
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildProductPlaceholder(),
                    )
                  : _buildProductPlaceholder(),
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
                  ],
                ),
              ],
            ),
          ),
          
          // Botón agregar al carrito
          Container(
            width: 40,
            height: 40,
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
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store,
            size: 32,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 4),
          Text(
            'CubaLink23',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

