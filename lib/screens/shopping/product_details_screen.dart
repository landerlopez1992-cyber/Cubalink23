import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cubalink23/services/cart_service.dart';
import 'package:cubalink23/services/likes_service.dart';
import 'package:cubalink23/models/amazon_product.dart';
import 'package:cubalink23/models/walmart_product.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? productId;
  final String? productTitle;
  final double? productPrice;
  final String? productImage;
  final String? productDescription;
  final double? productRating;
  final int? productReviews;
  final String? productBrand;
  final bool isFromAmazon;
  final bool isFromWalmart;
  final AmazonProduct? amazonProduct;
  final WalmartProduct? walmartProduct;
  final Map<String, dynamic>? product; // Legacy support

  const ProductDetailsScreen({
    Key? key,
    this.productId,
    this.productTitle,
    this.productPrice,
    this.productImage,
    this.productDescription,
    this.productRating,
    this.productReviews,
    this.productBrand,
    this.isFromAmazon = false,
    this.isFromWalmart = false,
    this.amazonProduct,
    this.walmartProduct,
    this.product,
  }) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final CartService _cartService = CartService();
  final LikesService _likesService = LikesService.instance;
  int _quantity = 1;
  int _selectedImageIndex = 0;
  bool _isLiked = false;
  bool _isLoadingLike = false;

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    final productId = widget.productId ?? widget.product?['id'] ?? '';
    if (productId.isNotEmpty) {
      final isLiked = await _likesService.isLiked(productId);
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_isLoadingLike) return;
    
    setState(() {
      _isLoadingLike = true;
    });

    try {
      final productId = widget.productId ?? widget.product?['id'] ?? '';
      final productName = widget.productTitle ?? widget.product?['title'] ?? widget.product?['name'] ?? 'Producto';
      final productImage = widget.productImage ?? widget.product?['image'] ?? widget.product?['imageUrl'] ?? '';
      final productPrice = widget.productPrice ?? widget.product?['price']?.toDouble() ?? 0.0;

      if (productId.isNotEmpty) {
        final newLikeStatus = await _likesService.toggleLike(
          productId,
          productName,
          productImage,
          productPrice,
        );

        setState(() {
          _isLiked = newLikeStatus;
        });

        // Mostrar mensaje
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isLiked 
                  ? 'Agregado a favoritos ❤️' 
                  : 'Removido de favoritos 💔',
              ),
              backgroundColor: _isLiked ? Colors.red : Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error en toggleLike: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar favoritos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLike = false;
      });
    }
  }

  Future<void> _shareProduct() async {
    try {
      final productName = widget.productTitle ?? widget.product?['title'] ?? widget.product?['name'] ?? 'Producto';
      final productPrice = widget.productPrice ?? widget.product?['price']?.toDouble() ?? 0.0;
      // final productImage = widget.productImage ?? widget.product?['image'] ?? widget.product?['imageUrl'] ?? '';
      
      final shareText = '''
🛍️ ¡Mira este producto en CubaLink23!

📦 $productName
💰 \$${productPrice.toStringAsFixed(2)}

Descarga la app CubaLink23 para ver más productos increíbles! 🚀
      ''';

      await Clipboard.setData(ClipboardData(text: shareText));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Información del producto copiada al portapapeles 📋'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error compartiendo producto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir producto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Support both new and legacy formats
    final String title = widget.productTitle ?? widget.product?['title'] ?? widget.product?['name'] ?? 'Producto';
    final double price = widget.productPrice ?? widget.product?['price']?.toDouble() ?? 0.0;
    final String imageUrl = widget.productImage ?? widget.product?['image'] ?? widget.product?['imageUrl'] ?? '';
    final String description = widget.productDescription ?? widget.product?['description'] ?? 'Sin descripción disponible';
    final double rating = widget.productRating ?? widget.product?['rating']?.toDouble() ?? 0.0;
    final int reviews = widget.productReviews ?? widget.product?['reviewsCount'] ?? 0;
    final String brand = widget.productBrand ?? widget.product?['brand'] ?? 'Desconocido';
    final String? weight = widget.walmartProduct?.weight ?? widget.amazonProduct?.weight;
    
    // Get images from different product types
    List<String> images = [];
    if (widget.walmartProduct != null) {
      images = widget.walmartProduct!.images.isNotEmpty ? widget.walmartProduct!.images : [imageUrl];
    } else if (widget.amazonProduct != null) {
      images = widget.amazonProduct!.images.isNotEmpty ? widget.amazonProduct!.images : [imageUrl];
    } else {
      images = [imageUrl];
    }
    images = images.where((img) => img.isNotEmpty).toList();
    if (images.isEmpty) images = [imageUrl];
    
    // Get store colors
    Color primaryColor;
    String storeName;
    
    if (widget.isFromWalmart) {
      primaryColor = Color(0xFF004C91);
      storeName = 'Walmart';
    } else if (widget.isFromAmazon) {
      primaryColor = Color(0xFFFF9900);
      storeName = 'Amazon';
    } else {
      primaryColor = Theme.of(context).colorScheme.primary;
      storeName = widget.product?['store'] ?? 'Tienda';
    }

    // Calculate discount
    double? originalPrice;
    String? discountText;
    if (widget.walmartProduct?.originalPrice != null && widget.walmartProduct!.originalPrice! > price) {
      originalPrice = widget.walmartProduct!.originalPrice;
      final discount = widget.walmartProduct!.getDiscountPercentage();
      if (discount != null) discountText = '-${discount.toInt()}%';
    } else if (widget.amazonProduct?.originalPrice != null && widget.amazonProduct!.originalPrice! > price) {
      originalPrice = widget.amazonProduct!.originalPrice;
      // Calculate discount for Amazon if needed
      final discount = ((widget.amazonProduct!.originalPrice! - price) / widget.amazonProduct!.originalPrice!) * 100;
      if (discount > 0) discountText = '-${discount.toInt()}%';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.share, color: Colors.white, size: 22),
                  onPressed: _shareProduct,
                  tooltip: 'Compartir producto',
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: _isLiked 
                    ? Colors.red.withOpacity(0.8)
                    : Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (_isLiked ? Colors.red : Colors.black).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: _isLoadingLike
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                          size: 22,
                        ),
                  onPressed: _toggleLike,
                  tooltip: _isLiked ? 'Quitar de favoritos' : 'Agregar a favoritos',
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Product Image with modern overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Hero(
                          tag: 'product-${widget.productId ?? title}',
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.grey.shade200,
                                          Colors.grey.shade300,
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 10,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 60,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Imagen no disponible',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Modern gradient overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Modern page indicators
                  if (images.length > 1)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images.asMap().entries.map((entry) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: _selectedImageIndex == entry.key ? 24 : 8,
                            height: 8,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _selectedImageIndex == entry.key
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Product Details Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name and Store Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Store and brand info
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity( 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      storeName,
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  if (brand != 'Desconocido')
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        brand,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              // Vendor Information
                              SizedBox(height: 12),
                              _buildVendorInfo(),
                              // Weight indicator
                              if (weight != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.fitness_center,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Peso: $weight',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Discount Badge
                        if (discountText != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              discountText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Rating Section
                    if (rating > 0 || reviews > 0)
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < rating.floor() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                          SizedBox(width: 8),
                          Text(
                            '${rating.toStringAsFixed(1)} (${reviews} reseñas)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    
                    if (rating > 0 || reviews > 0) SizedBox(height: 20),
                    
                    // Price Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (originalPrice != null) ...[
                          Text(
                            '\$${originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Stock Status
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'En Stock',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Quantity Selector
                    Row(
                      children: [
                        Text(
                          'Cantidad:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _quantity > 1 ? () {
                                  setState(() {
                                    _quantity--;
                                  });
                                } : null,
                                icon: Icon(Icons.remove),
                                iconSize: 20,
                              ),
                              Container(
                                width: 40,
                                alignment: Alignment.center,
                                child: Text(
                                  _quantity.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _quantity++;
                                  });
                                },
                                icon: Icon(Icons.add),
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Description
                    Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Modern Add to Cart Button
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor,
                            primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _addToCart(),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Agregar al carrito',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '\$${(price * _quantity).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    // Bottom padding for Android navigation bar
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    Map<String, dynamic> cartItem = {
      'id': widget.productId ?? widget.product?['id'] ?? 'unknown',
      'title': widget.productTitle ?? widget.product?['title'] ?? widget.product?['name'] ?? 'Producto',
      'price': widget.productPrice ?? widget.product?['price']?.toDouble() ?? 0.0,
      'imageUrl': widget.productImage ?? widget.product?['image'] ?? widget.product?['imageUrl'] ?? '',
      'store': widget.isFromWalmart ? 'Walmart' : widget.isFromAmazon ? 'Amazon' : widget.product?['store'] ?? 'Tienda',
      'brand': widget.productBrand ?? widget.product?['brand'] ?? 'Desconocido',
      'quantity': _quantity,
    };

    // Add weight information if available
    if (widget.walmartProduct?.weight != null) {
      cartItem['weight'] = widget.walmartProduct!.weight;
      cartItem['weightKg'] = widget.walmartProduct!.getEstimatedWeightKg();
    } else if (widget.amazonProduct?.weight != null) {
      cartItem['weight'] = widget.amazonProduct!.weight;
      cartItem['weightKg'] = 0.5; // Default weight for Amazon products
    }

    // Add rating and reviews if available
    if (widget.productRating != null) cartItem['rating'] = widget.productRating;
    if (widget.productReviews != null) cartItem['reviewsCount'] = widget.productReviews;

    for (int i = 0; i < _quantity; i++) {
      _cartService.addAmazonProduct(cartItem);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('$_quantity producto(s) agregado(s) al carrito'),
            ),
          ],
        ),
        backgroundColor: widget.isFromWalmart ? Color(0xFF004C91) : widget.isFromAmazon ? Color(0xFFFF9900) : Theme.of(context).colorScheme.primary,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back or show success
    Navigator.pop(context);
  }

  Widget _buildVendorInfo() {
    // Obtener información del vendedor del producto
    final String vendorName = widget.product?['vendor_name'] ?? 'Vendedor Local';
    final String vendorId = widget.product?['vendor_id'] ?? 'vendor_001';
    
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de detalles del vendedor
        Navigator.pushNamed(
          context,
          '/vendor_detail',
          arguments: {
            'vendorId': vendorId,
            'vendorName': vendorName,
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue[200]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.store,
              size: 16,
              color: Colors.blue[700],
            ),
            SizedBox(width: 6),
            Text(
              'Vendedor: ',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              vendorName,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.blue[700],
            ),
          ],
        ),
      ),
    );
  }
}