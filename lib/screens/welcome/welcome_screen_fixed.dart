import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:cubalink23/screens/recharge/recharge_home_screen.dart';
import 'package:cubalink23/screens/travel/flight_booking_screen.dart';
import 'package:cubalink23/services/auth_service_bypass.dart';
import 'package:cubalink23/services/database_service.dart';
import 'package:cubalink23/services/cart_service.dart';
import 'package:cubalink23/services/store_service.dart';
import 'package:cubalink23/models/user.dart';
import 'package:cubalink23/supabase/supabase_config_fixed.dart';
import 'package:cubalink23/models/store_product.dart';
import 'package:cubalink23/screens/shopping/product_details_screen.dart';

/// VERSIÓN CORREGIDA DE WELCOME_SCREEN QUE USA CONFIGURACIÓN NO BLOQUEANTE
class WelcomeScreenFixed extends StatefulWidget {
  const WelcomeScreenFixed({super.key});

  @override
  _WelcomeScreenFixedState createState() => _WelcomeScreenFixedState();
}

class _WelcomeScreenFixedState extends State<WelcomeScreenFixed> {
  double _currentBalance = 0.0;
  bool _isLoading = false; // Empezar sin loading para mostrar UI inmediatamente
  int _unreadNotificationsCount = 0;
  int _cartItemsCount = 0;
  String? _currentUserId;
  List<String> _bannerUrls = [];
  final CartService _cartService = CartService();
  final StoreService _storeService = StoreService();
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _bestSellers = [];
  List<StoreProduct> _realFoodProducts = [];
  bool _loadingProducts = false; // No cargar automáticamente

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
    
    // Cargar datos en background SIN BLOQUEAR la UI
    _loadDataInBackground();
    
    print('✅ WelcomeScreenFixed - UI MOSTRADA INMEDIATAMENTE');
  }

  /// Carga datos en background de forma NO BLOQUEANTE
  void _loadDataInBackground() async {
    print('🔄 Iniciando carga de datos en background...');
    
    try {
      // Pequeña pausa para permitir que la UI se renderice
      await Future.delayed(Duration(milliseconds: 100));
      
      // Verificar si Supabase está disponible (sin bloquear)
      if (SupabaseConfigFixed.isAvailable) {
        print('✅ Supabase disponible, cargando datos completos...');
        await _loadAllDataSafely();
      } else {
        print('🔶 Supabase no disponible, usando datos por defecto');
        _loadOfflineData();
      }
      
    } catch (e) {
      print('🔶 Error en carga de background, usando datos por defecto: $e');
      _loadOfflineData();
    }
  }

  /// Carga todos los datos de forma segura (con timeout y manejo de errores)
  Future<void> _loadAllDataSafely() async {
    try {
      // Cargar en paralelo con timeouts individuales
      await Future.wait([
        _loadUserDataSafely(),
        _loadCartItemsCount(),
        _loadCategoriesAndBestSellersSafely(),
        _loadRealProductsSafely(),
      ], eagerError: false);
      
    } catch (e) {
      print('🔶 Error en carga completa: $e');
    }
  }

  /// Carga datos offline/por defecto
  void _loadOfflineData() {
    setState(() {
      _currentBalance = 0.0;
      _cartItemsCount = _cartService.itemCount;
      _categories = _getDefaultCategoriesMap();
      _bestSellers = _getDefaultProductsMap();
      _realFoodProducts = [];
      _loadingProducts = false;
    });
  }

  /// Carga datos de usuario de forma segura
  Future<void> _loadUserDataSafely() async {
    try {
      final timeout = Future.delayed(Duration(seconds: 3), () => throw TimeoutException('User data timeout'));
      
      await Future.any([
        _loadUserDataInternal(),
        timeout,
      ]);
      
    } catch (e) {
      print('🔶 Timeout o error en carga de usuario: $e');
      // Usar datos por defecto
      if (mounted) {
        setState(() {
          _currentBalance = 0.0;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserDataInternal() async {
    await AuthServiceBypass.instance.loadCurrentUserFromLocal();
    final user = AuthServiceBypass.instance.currentUser;
    if (user != null) {
      _currentUserId = user.id;
      _loadNotificationsCountSafely();
    }
    if (mounted) {
      setState(() {
        _currentBalance = AuthServiceBypass.instance.userBalance;
        _isLoading = false;
      });
    }
  }

  /// Carga categorías y productos de forma segura
  Future<void> _loadCategoriesAndBestSellersSafely() async {
    try {
      final timeout = Future.delayed(Duration(seconds: 5), () => throw TimeoutException('Categories timeout'));
      
      await Future.any([
        _loadCategoriesAndBestSellersInternal(),
        timeout,
      ]);
      
    } catch (e) {
      print('🔶 Timeout o error en carga de categorías: $e');
      // Mantener datos por defecto
    }
  }

  Future<void> _loadCategoriesAndBestSellersInternal() async {
    print('🔄 Cargando categorías y mejores productos...');
    
    await _storeService.initializeDefaultCategories();
    
    final categories = await _storeService.getCategories();
    final recentProducts = await _storeService.getRecentProducts();
    
    List<Map<String, dynamic>> categoriesMap = [];
    List<Map<String, dynamic>> bestSellersMap = [];
    
    if (categories.isEmpty) {
      categoriesMap = _getDefaultCategoriesMap();
    } else {
      categoriesMap = categories.map((cat) => {
        'id': cat.id,
        'name': cat.name,
        'description': cat.description,
        'icon': cat.iconName,
        'color': _getCategoryColor(cat.iconName),
      }).toList();
    }
    
    if (recentProducts.isNotEmpty) {
      bestSellersMap = recentProducts.take(8).map((product) => {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'image': product.imageUrl,
        'unit': product.unit,
        'original_price': product.price * 1.2,
        'discount': '15%',
      }).toList();
    } else {
      bestSellersMap = _getDefaultProductsMap();
    }

    if (mounted) {
      setState(() {
        _categories = categoriesMap;
        _bestSellers = bestSellersMap;
      });
    }
    
    print('✅ Categorías y productos actualizados');
  }

  /// Carga productos reales de forma segura
  Future<void> _loadRealProductsSafely() async {
    try {
      setState(() {
        _loadingProducts = true;
      });

      final timeout = Future.delayed(Duration(seconds: 5), () => throw TimeoutException('Products timeout'));
      
      await Future.any([
        _loadRealProductsInternal(),
        timeout,
      ]);
      
    } catch (e) {
      print('🔶 Timeout o error en carga de productos: $e');
      if (mounted) {
        setState(() {
          _loadingProducts = false;
        });
      }
    }
  }

  Future<void> _loadRealProductsInternal() async {
    final products = await _storeService.getAllProducts();
    
    final foodProducts = products.where((product) => 
      product.categoryId == 'alimentos' || 
      product.name.toLowerCase().contains('cerdo') ||
      product.name.toLowerCase().contains('arroz') ||
      product.name.toLowerCase().contains('carne')
    ).take(5).toList();

    if (mounted) {
      setState(() {
        _realFoodProducts = foodProducts;
        _loadingProducts = false;
      });
    }
  }

  /// Carga notificaciones de forma segura
  Future<void> _loadNotificationsCountSafely() async {
    if (_currentUserId == null) return;

    try {
      // Timeout de 3 segundos para notificaciones
      final count = await Future.any([
        Future.value(0), // Por ahora usar 0, implementar en Supabase después
        Future.delayed(Duration(seconds: 3), () => 0),
      ]);
      
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = count;
        });
      }
    } catch (e) {
      print('🔶 Error en carga de notificaciones: $e');
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _cartService.removeListener(_updateCartCount);
    super.dispose();
  }

  void _updateCartCount() {
    if (mounted) {
      setState(() {
        _cartItemsCount = _cartService.itemCount;
      });
    }
  }

  void _addFoodProductToCart(dynamic product) {
    String productId;
    String productName;
    double productPrice;
    String productImage;
    String productUnit;
    
    if (product is StoreProduct) {
      productId = 'store_${product.id}';
      productName = product.name;
      productPrice = product.price;
      productImage = product.imageUrl;
      productUnit = product.unit;
    } else if (product is Map<String, dynamic>) {
      productId = 'food_${product['name'].replaceAll(' ', '_').toLowerCase()}';
      productName = product['name'];
      productPrice = product['price'];
      productImage = product['image'];
      productUnit = product['unit'];
    } else {
      return;
    }
    
    final cartItem = {
      'id': productId,
      'name': productName,
      'price': productPrice,
      'image': productImage,
      'type': 'food_product',
      'unit': productUnit,
      'quantity': 1,
    };

    _cartService.addFoodProduct(cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName añadido al carrito'),
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

  Future<void> _loadCartItemsCount() async {
    setState(() {
      _cartItemsCount = _cartService.itemCount;
    });
  }

  Future<void> _checkForceUpdate() async {
    try {
      final shouldUpdate = false; // Implementar en Supabase después
      if (shouldUpdate) {
        _showForceUpdateDialog();
      }
    } catch (e) {
      print('Error checking force update: $e');
    }
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.update, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Actualización Requerida'),
          ],
        ),
        content: Text(
          'Hay una nueva versión de CubaLink23 disponible. Por favor actualiza la app para continuar.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _redirectToStore,
            icon: Icon(Icons.download),
            label: Text('Actualizar Ahora'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _redirectToStore() async {
    try {
      final settings = null; // Implementar en Supabase después
      String storeUrl;

      if (Platform.isAndroid) {
        storeUrl = settings['googlePlayUrl'] ?? 'https://play.google.com/store';
      } else if (Platform.isIOS) {
        storeUrl = settings['appStoreUrl'] ?? 'https://apps.apple.com';
      } else {
        storeUrl = 'https://play.google.com/store';
      }

      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error redirecting to store: $e');
    }
  }

  Future<void> _loadBanners() async {
    try {
      // Implementar banners en Supabase después
      final banners = <dynamic>[];
      if (mounted) {
        setState(() {
          _bannerUrls = banners.cast<String>();
        });

        if (_bannerUrls.length > 1) {
          _startBannerAutoScroll();
        }
      }
    } catch (e) {
      print('Error loading banners: $e');
    }
  }

  void _startBannerAutoScroll() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _bannerUrls.length > 1) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _bannerUrls.length;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  /// Categorías por defecto
  List<Map<String, dynamic>> _getDefaultCategoriesMap() {
    return [
      {
        'id': 'alimentos',
        'name': 'Alimentos',
        'description': 'Comida y productos básicos',
        'icon': 'restaurant',
        'color': 0xFFE57373,
      },
      {
        'id': 'materiales',
        'name': 'Materiales',
        'description': 'Materiales de construcción',
        'icon': 'construction',
        'color': 0xFFFF8A65,
      },
      {
        'id': 'ferreteria',
        'name': 'Ferretería',
        'description': 'Herramientas y accesorios',
        'icon': 'build',
        'color': 0xFFFF8F00,
      },
      {
        'id': 'farmacia',
        'name': 'Farmacia',
        'description': 'Medicinas y productos de salud',
        'icon': 'healing',
        'color': 0xFF26A69A,
      },
      {
        'id': 'electronicos',
        'name': 'Electrónicos',
        'description': 'Dispositivos y accesorios',
        'icon': 'phone_android',
        'color': 0xFF42A5F5,
      },
      {
        'id': 'ropa',
        'name': 'Ropa',
        'description': 'Vestimenta y accesorios',
        'icon': 'shopping_bag',
        'color': 0xFFAB47BC,
      },
    ];
  }
  
  /// Productos por defecto
  List<Map<String, dynamic>> _getDefaultProductsMap() {
    return [
      {
        'id': 'arroz_demo',
        'name': 'Arroz Premium',
        'description': 'Arroz de alta calidad',
        'price': 3.50,
        'image': 'https://via.placeholder.com/200x200/FFE0B2/000000?text=Arroz',
        'unit': 'lb',
        'original_price': 4.00,
        'discount': '12%',
      },
      {
        'id': 'aceite_demo',
        'name': 'Aceite de Cocina',
        'description': 'Aceite vegetal premium',
        'price': 5.99,
        'image': 'https://via.placeholder.com/200x200/E1F5FE/000000?text=Aceite',
        'unit': 'botella',
        'original_price': 6.99,
        'discount': '14%',
      },
    ];
  }

  int _getCategoryColor(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant': return 0xFFE57373;
      case 'construction': return 0xFFFF8A65;
      case 'build': return 0xFFFF8F00;
      case 'healing': return 0xFF26A69A;
      case 'local_pharmacy': return 0xFF26A69A;
      case 'phone_android': return 0xFF42A5F5;
      case 'devices': return 0xFF42A5F5;
      case 'shopping_bag': return 0xFFAB47BC;
      case 'home': return 0xFF66BB6A;
      case 'fitness_center': return 0xFFFF7043;
      case 'spa': return 0xFFE91E63;
      default: return 0xFF9E9E9E;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Inicio',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          // Estado de Supabase (solo en debug)
          if (SupabaseConfigFixed.status != SupabaseStatus.initialized)
            Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity( 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                SupabaseConfigFixed.status.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/notifications');
              _loadNotificationsCountSafely();
            },
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 26,
                ),
                if (_unreadNotificationsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _unreadNotificationsCount > 9
                            ? '9+'
                            : _unreadNotificationsCount.toString(),
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
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            icon: Stack(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 26,
                ),
                if (_cartItemsCount > 0)
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
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _cartItemsCount > 9 ? '9+' : _cartItemsCount.toString(),
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
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/add-balance');
            },
            child: Container(
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity( 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          '\$${_currentBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.add_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // Banner publicitario
            Container(
              height: 200,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .shadow
                        .withOpacity( 0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _bannerUrls.isEmpty
                  ? _buildDefaultBanner()
                  : _buildDynamicBanner(),
            ),
            // Grid de opciones
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(
                    height: 420,
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 0.9,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 16,
                      children: [
                        _buildOptionCard(
                          context,
                          icon: Icons.account_balance_wallet,
                          title: 'Agregar Balance',
                          gradient: [Colors.green.shade400, Colors.green.shade600],
                          onTap: () {
                            Navigator.pushNamed(context, '/add-balance');
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.analytics,
                          title: 'Actividad',
                          gradient: [Colors.blue.shade400, Colors.blue.shade600],
                          onTap: () {
                            Navigator.pushNamed(context, '/activity');
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.forum,
                          title: 'Mensajería',
                          gradient: [Colors.purple.shade400, Colors.purple.shade600],
                          onTap: () {
                            Navigator.pushNamed(context, '/communication');
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.compare_arrows,
                          title: 'Transferir Saldo',
                          gradient: [Colors.indigo.shade400, Colors.indigo.shade600],
                          onTap: () {
                            Navigator.pushNamed(context, '/transfer');
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.smartphone,
                          title: 'Recarga',
                          gradient: [Colors.orange.shade400, Colors.orange.shade600],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RechargeHomeScreen(),
                              ),
                            );
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.luggage,
                          title: 'Viajes',
                          gradient: [Colors.cyan.shade400, Colors.cyan.shade600],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlightBookingScreen(),
                              ),
                            );
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.campaign,
                          title: 'Refiere y Gana',
                          gradient: [Colors.pink.shade400, Colors.pink.shade600],
                          onTap: () {
                            Navigator.pushNamed(context, '/referral');
                          },
                        ),
                        _buildAmazonCard(
                          context,
                          title: 'Amazon',
                          onTap: () {
                            Navigator.pushNamed(context, '/amazon-shopping');
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.shopping_bag,
                          title: 'Tienda',
                          gradient: [Colors.teal.shade400, Colors.teal.shade600],
                          onTap: () {
                            Navigator.pushNamed(context, '/store');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildFlightsBanner(),
                  SizedBox(height: 20),
                  _buildFoodProductsSection(),
                  SizedBox(height: 20),
                  _buildCategoriesSection(),
                  SizedBox(height: 20),
                  _buildBestSellersSection(),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/help');
              break;
            case 2:
              Navigator.pushNamed(context, '/settings');
              break;
            case 3:
              Navigator.pushNamed(context, '/account');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Ayuda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mi Cuenta',
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    List<Color>? gradient,
  }) {
    final cardGradient = gradient ?? [Colors.grey.shade100, Colors.grey.shade200];
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity( 0.15),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: cardGradient,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: cardGradient.first.withOpacity( 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmazonCard(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity( 0.15),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF9900), Color(0xFFFF6600)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF9900).withOpacity( 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_cart,
                size: 28,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 15,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'CubaLink23',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recarga con',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '500',
                      style: TextStyle(
                        color: Colors.yellow[300],
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        height: 0.9,
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CUP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'de saldo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '+10',
                        style: TextStyle(
                          color: Colors.yellow[300],
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: ' días',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'INTERNET\nILIMITADO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                Text(
                  '24horas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity( 0.2),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.person,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _bannerUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                _bannerUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultBanner(),
              );
            },
          ),
          if (_bannerUrls.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _bannerUrls.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentBannerIndex == entry.key
                          ? Colors.white
                          : Colors.white.withOpacity( 0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFlightsBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightBookingScreen(),
          ),
        );
      },
      child: Container(
        height: 200,
        margin: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E88E5),
              Color(0xFF42A5F5),
              Color(0xFF64B5F6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity( 0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 20,
              top: 15,
              child: Icon(
                Icons.flight_takeoff,
                size: 50,
                color: Colors.white.withOpacity( 0.3),
              ),
            ),
            Positioned(
              right: 60,
              bottom: 15,
              child: Icon(
                Icons.flight,
                size: 30,
                color: Colors.white.withOpacity( 0.2),
              ),
            ),
            Positioned(
              left: 20,
              top: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🔥 OFERTAS ESPECIALES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '✈️ Los Mejores Precios',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'en Pasajes Aéreos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '🌍 Para todo el mundo • Desde USA',
                    style: TextStyle(
                      color: Colors.white.withOpacity( 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 15,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity( 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Reservar Ahora',
                      style: TextStyle(
                        color: Color(0xFF1E88E5),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF1E88E5),
                      size: 16,
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

  Widget _buildFoodProductsSection() {
    if (_loadingProducts) {
      return SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    
    if (_realFoodProducts.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'Cargando productos...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _loadRealProductsSafely();
                },
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.restaurant, color: Theme.of(context).colorScheme.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Productos Alimenticios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4),
            itemCount: _realFoodProducts.length,
            itemBuilder: (context, index) {
              final product = _realFoodProducts[index];
              return GestureDetector(
                onTap: () {
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
                  width: 150,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity( 0.2),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 14,
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      Text(
                                        'por ${product.unit}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _addFoodProductToCart(product);
                                      },
                                      icon: Icon(
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    IconData getIconFromString(String iconName) {
      switch (iconName) {
        case 'restaurant':
          return Icons.restaurant;
        case 'build':
          return Icons.build;
        case 'hardware':
          return Icons.hardware;
        case 'local_pharmacy':
          return Icons.local_pharmacy;
        case 'devices':
          return Icons.devices;
        case 'spa':
          return Icons.spa;
        default:
          return Icons.category;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.category, color: Theme.of(context).colorScheme.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final iconData = getIconFromString(category['icon'] ?? 'category');
              final colorValue = category['color'] ?? 0xFF9E9E9E;
              final color = Color(colorValue);

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/store');
                },
                child: Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity( 0.15),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color.withOpacity( 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          color: color,
                          size: 28,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        category['name'] ?? 'Categoría',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBestSellersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                'Lo Más Vendido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'HOT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4),
            itemCount: _bestSellers.length,
            itemBuilder: (context, index) {
              final product = _bestSellers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity( 0.2),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                child: SizedBox(
                                  height: 110,
                                  width: double.infinity,
                                  child: Image.network(
                                    product['image'] ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          color: Colors.grey.shade200,
                                          child: Icon(
                                            Icons.restaurant,
                                            size: 40,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '-${product['discount'] ?? '0%'}',
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
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product['name'],
                                    style: TextStyle(
                                      fontSize: 14,
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
                                          if (product['original_price'] != null)
                                            Text(
                                              '\$${(product['original_price'] as double).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                decoration: TextDecoration.lineThrough,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          Text(
                                            '\$${(product['price'] as double).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                          Text(
                                            'por ${product['unit'] ?? 'unidad'}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            _addFoodProductToCart(product);
                                          },
                                          icon: Icon(
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}