import 'package:flutter/material.dart';
import 'package:cubalink23/screens/recharge/recharge_home_screen.dart';
import 'package:cubalink23/screens/travel/flight_booking_screen.dart';
import 'package:cubalink23/screens/travel/renta_car_screen.dart';
import 'package:cubalink23/services/cart_service.dart';
import 'package:cubalink23/services/store_service.dart';
import 'package:cubalink23/services/firebase_repository.dart';
import 'package:cubalink23/services/notification_manager.dart';
import 'package:cubalink23/services/firebase_messaging_service.dart';
import 'package:cubalink23/models/store_product.dart';
import 'package:cubalink23/screens/shopping/product_details_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _currentBalance = 0.0; // Balance inicial correcto
  bool _isLoading = true;
  int _unreadNotificationsCount = 0;
  int _cartItemsCount = 0;
  String? _currentUserId;
  List<String> _bannerUrls = [];
  List<String> _flightsBannerUrls = [];
  final CartService _cartService = CartService();
  final StoreService _storeService = StoreService();
  final FirebaseRepository _firebaseRepository = FirebaseRepository.instance;
  int _currentBannerIndex = 0;
  int _currentFlightsBannerIndex = 0;
  PageController _bannerController = PageController();
  PageController _flightsBannerController = PageController();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _bestSellers = [];
  List<StoreProduct> _realFoodProducts = [];
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    print('🎉 WelcomeScreen - INICIANDO CON PRODUCTOS REALES');
    
    // Agregar listener del carrito para actualizar contador
    _cartService.addListener(_updateCartCount);
    
    // Cargar solo lo básico para mostrar la UI inmediatamente
    setState(() {
      _isLoading = false; // Mostrar UI inmediatamente
      _currentBalance = 0.0; // Balance por defecto
      _cartItemsCount = _cartService.itemCount; // Inicializar contador del carrito
    });
    
    // Inicializar Firebase Messaging
    FirebaseMessagingService().initialize();
    
    // Inicializar el manager de notificaciones push
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationManager().initialize(context);
    });
    
    // Cargar productos reales de Supabase inmediatamente
    _loadRealProductsFromSupabase();
    _loadCategoriesAndBestSellers();
    _loadBannersFromSupabase();
    _loadFlightsBannersFromSupabase();
    
    print('✅ WelcomeScreen - INICIADO CON CARGA DE PRODUCTOS REALES');
  }
  

  @override
  void dispose() {
    _bannerController.dispose();
    _flightsBannerController.dispose();
    _cartService.removeListener(_updateCartCount);
    NotificationManager().dispose();
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






  Future<void> _loadNotificationsCount() async {
    if (_currentUserId == null) return;

    try {
      // Por ahora, usar 0 como placeholder hasta implementar notificaciones en Supabase
      final count = 0;
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = count;
        });
      }
      print('🔔 Unread notifications count: $count');
    } catch (e) {
      print('❌ Error loading notifications count: $e');
    }
  }

  Future<void> _loadCategoriesAndBestSellers() async {
    try {
      print('🔄 Cargando categorías y mejores productos...');
      
      // Initialize store service categories
      await _storeService.initializeDefaultCategories();
      
      // Load real categories from store service
      final categories = await _storeService.getCategories();
      print('📦 Categorías cargadas: ${categories.length}');
      
      // Load recent products as "best sellers"
      final recentProducts = await _storeService.getRecentProducts();
      print('🛍️ Productos recientes: ${recentProducts.length}');
      
      List<Map<String, dynamic>> categoriesMap = [];
      List<Map<String, dynamic>> bestSellersMap = [];
      
      // Si no hay categorías de Supabase, usar categorías por defecto
      if (categories.isEmpty) {
        print('⚠️ No hay categorías en Supabase, usando categorías por defecto');
        categoriesMap = _getDefaultCategoriesMap();
      } else {
        // Convert categories to map format for compatibility
        categoriesMap = categories.map((cat) => {
          'id': cat.id,
          'name': cat.name,
          'description': cat.description,
          'icon': cat.iconName,
          'color': _getCategoryColor(cat.iconName),
        }).toList();
      }
      
      // Convert recent products to map format
      if (recentProducts.isNotEmpty) {
        bestSellersMap = recentProducts.take(8).map((product) => {
          'id': product.id,
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'image': product.imageUrl,
          'unit': product.unit,
          'original_price': product.price * 1.2, // Simulate discount
          'discount': '15%',
        }).toList();
      } else {
        print('ℹ️ No hay productos recientes, usando productos de ejemplo');
        bestSellersMap = _getDefaultProductsMap();
      }

      if (mounted) {
        setState(() {
          _categories = categoriesMap;
          _bestSellers = bestSellersMap;
        });
      }
      
      print('✅ Categorías y productos cargados exitosamente');
    } catch (e) {
      print('❌ Error loading categories and best sellers: $e');
      
      // En caso de error, cargar categorías por defecto
      if (mounted) {
        setState(() {
          _categories = _getDefaultCategoriesMap();
          _bestSellers = _getDefaultProductsMap();
        });
      }
    }
  }
  
  /// Categorías por defecto como fallback
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
  
  /// Productos por defecto como fallback
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

  /// Carga productos reales de Supabase para mostrar en la pantalla de bienvenida
  Future<void> _loadRealProductsFromSupabase() async {
    try {
      print('🛍️ Cargando productos reales de Supabase...');
      setState(() {
        _loadingProducts = true;
      });

      // Cargar TODOS los productos reales de Supabase
      final allProducts = await _storeService.getAllProducts();
      print('📦 Productos obtenidos de Supabase: ${allProducts.length}');

      if (allProducts.isNotEmpty) {
        // Mostrar los primeros 8 productos reales
        final realProducts = allProducts.take(8).toList();

        if (mounted) {
          setState(() {
            _realFoodProducts = realProducts;
            _loadingProducts = false;
          });
        }

        print('✅ Productos reales cargados: ${realProducts.length}');
        for (var product in realProducts) {
          print('   - ${product.name}: \$${product.price}');
        }
      } else {
        print('⚠️ No hay productos en Supabase, usando productos por defecto');
        _loadDefaultProducts();
      }
    } catch (e) {
      print('❌ Error cargando productos reales: $e');
      _loadDefaultProducts();
    }
  }

  /// Carga banners reales de Supabase para mostrar en la pantalla de bienvenida
  Future<void> _loadBannersFromSupabase() async {
    try {
      print('🖼️ Cargando banners reales de Supabase...');
      
      // Cargar banners desde Supabase
      final banners = await _firebaseRepository.getBanners();
      print('📸 Banners obtenidos de Supabase: ${banners.length}');
      
      // Debug: mostrar todos los banners obtenidos
      for (var banner in banners) {
        print('🔍 Banner encontrado: ${banner.toString()}');
      }

      if (banners.isNotEmpty) {
        // Extraer URLs de los banners activos (usando los campos correctos)
        final bannerUrls = banners
            .where((banner) => 
                (banner['is_active'] == true || banner['active'] == true) && 
                banner['image_url'] != null &&
                (banner['banner_type'] == 'banner1' || banner['banner_type'] == 'welcome' || banner['banner_type'] == null))
            .map((banner) => banner['image_url'] as String)
            .toList();

        if (mounted) {
          setState(() {
            _bannerUrls = bannerUrls;
          });
        }

        print('✅ Banners reales cargados: ${bannerUrls.length}');
        for (var url in bannerUrls) {
          print('   - Banner: $url');
        }

        // Iniciar auto-scroll si hay múltiples banners
        if (bannerUrls.length > 1) {
          _startBannerAutoScroll();
        }
      } else {
        print('⚠️ No hay banners en Supabase, usando banner por defecto');
      }
    } catch (e) {
      print('❌ Error cargando banners reales: $e');
    }
  }

  /// Carga banners de tipo banner2 (vuelos) desde Supabase
  Future<void> _loadFlightsBannersFromSupabase() async {
    try {
      print('✈️ Cargando banners de vuelos desde Supabase...');
      
      // Cargar banners desde Supabase
      final banners = await _firebaseRepository.getBanners();
      print('📸 Banners obtenidos de Supabase: ${banners.length}');
      
      if (banners.isNotEmpty) {
        // Extraer URLs de los banners de tipo banner2 (vuelos)
        final flightsBannerUrls = banners
            .where((banner) => 
                (banner['is_active'] == true || banner['active'] == true) && 
                banner['image_url'] != null &&
                banner['banner_type'] == 'banner2')
            .map((banner) => banner['image_url'] as String)
            .toList();

        if (mounted) {
          setState(() {
            _flightsBannerUrls = flightsBannerUrls;
          });
        }

        print('✅ Banners de vuelos cargados: ${flightsBannerUrls.length}');
        for (var url in flightsBannerUrls) {
          print('   - Banner de vuelos: $url');
        }

        // Iniciar auto-scroll si hay múltiples banners de vuelos
        if (flightsBannerUrls.length > 1) {
          _startFlightsBannerAutoScroll();
        }
      } else {
        print('⚠️ No hay banners de vuelos en Supabase');
      }
    } catch (e) {
      print('❌ Error cargando banners de vuelos: $e');
    }
  }

  /// Carga productos por defecto como fallback
  void _loadDefaultProducts() {
    if (mounted) {
      setState(() {
        _realFoodProducts = [
          StoreProduct(
            id: 'default_1',
            name: 'Producto de Ejemplo',
            description: 'Producto de demostración',
            categoryId: 'alimentos',
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
        _loadingProducts = false;
      });
    }
  }

  /// Inicia el auto-scroll de banners
  void _startBannerAutoScroll() {
    if (_bannerUrls.length > 1) {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted && _bannerController.hasClients) {
          final nextIndex = (_currentBannerIndex + 1) % _bannerUrls.length;
          _bannerController.animateToPage(
            nextIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          _startBannerAutoScroll(); // Continuar el ciclo
        }
      });
    }
  }

  void _startFlightsBannerAutoScroll() {
    if (_flightsBannerUrls.length > 1) {
      Future.delayed(Duration(seconds: 4), () { // 4 segundos para banners de vuelos
        if (mounted && _flightsBannerController.hasClients) {
          final nextIndex = (_currentFlightsBannerIndex + 1) % _flightsBannerUrls.length;
          _flightsBannerController.animateToPage(
            nextIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          _startFlightsBannerAutoScroll(); // Continuar el ciclo
        }
      });
    }
  }

  int _getCategoryColor(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant': return 0xFFE57373; // Light red for food
      case 'construction': return 0xFFFF8A65; // Orange for construction materials
      case 'build': return 0xFFFF8F00; // Amber for tools/hardware
      case 'healing': return 0xFF26A69A; // Teal for pharmacy
      case 'local_pharmacy': return 0xFF26A69A; // Teal for pharmacy (alternative)
      case 'phone_android': return 0xFF42A5F5; // Blue for electronics
      case 'devices': return 0xFF42A5F5; // Blue for electronics (alternative)
      case 'shopping_bag': return 0xFFAB47BC; // Purple for clothing
      case 'home': return 0xFF66BB6A; // Green for home products
      case 'fitness_center': return 0xFFFF7043; // Orange for sports
      case 'spa': return 0xFFE91E63; // Pink for cosmetics
      default: return 0xFF9E9E9E; // Gray default
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
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/notifications');
              // Reload notifications count when coming back from notifications
              _loadNotificationsCount();
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
          // Shopping Cart Icon
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
          // Balance Display - moved to the far right
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
            // Banner publicitario dinámico
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
                  // Grid de botones con altura fija apropiada
                  Container(
                    height: 480, // Aumentado de 420 a 480 para más espacio
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(), // Desabilitar scroll interno del grid
                      crossAxisCount: 3,
                      childAspectRatio: 0.8, // Reducido de 0.9 a 0.8 para más altura
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
                        _buildOptionCard(
                          context,
                          icon: Icons.favorite,
                          title: 'Favoritos',
                          gradient: [Colors.red.shade400, Colors.red.shade600],
                          onTap: () {
                            Navigator.pushNamed(context, '/favorites');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40), // Aumentado de 24 a 40 para separar botonera del banner
                  // Segundo banner publicitario de vuelos (misma altura que el superior)
                  _buildFlightsBanner(),
                  SizedBox(height: 20),
                  // Sección de productos alimenticios
                  _buildFoodProductsSection(),
                  SizedBox(height: 20),
                  // Sección de categorías
                  _buildCategoriesSection(),
                  SizedBox(height: 20),
                  // Sección "Lo más vendido"
                  _buildBestSellersSection(),
                  SizedBox(height: 20),
                  // Sección "Renta Car"
                  _buildRentaCarSection(),
                  SizedBox(height: 30), // Espacio adicional al final
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
              // Ya estamos en inicio
              break;
            case 1:
              Navigator.pushNamed(context, '/news');
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
            icon: Icon(Icons.newspaper_outlined),
            label: 'Noticias',
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
              color: Colors.grey.withOpacity(0.15),
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
                    color: cardGradient.first.withOpacity(0.3),
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
            SizedBox(height: 10), // Reducido de 12 a 10
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6), // Reducido de 8 a 6
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11, // Reducido de 12 a 11 para mejor ajuste
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
            SizedBox(height: 10), // Reducido de 12 a 10
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6), // Reducido de 8 a 6
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11, // Reducido de 12 a 11 para mejor ajuste
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
        child: _flightsBannerUrls.isNotEmpty 
            ? _buildDynamicFlightsBanner()
            : _buildDefaultFlightsBanner(),
      ),
    );
  }

  Widget _buildDynamicFlightsBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          PageView.builder(
            controller: _flightsBannerController,
            itemCount: _flightsBannerUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentFlightsBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                _flightsBannerUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultFlightsBanner(),
              );
            },
          ),
          if (_flightsBannerUrls.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _flightsBannerUrls.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentFlightsBannerIndex == entry.key
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultFlightsBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E88E5), // Azul cielo
            Color(0xFF42A5F5), // Azul más claro
            Color(0xFF64B5F6), // Azul aún más claro
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decoración con aviones
          Positioned(
            right: 20,
            top: 15,
            child: Icon(
              Icons.flight_takeoff,
              size: 50,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          Positioned(
            right: 60,
            bottom: 15,
            child: Icon(
              Icons.flight,
              size: 30,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          // Contenido principal
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
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Botón de acción
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
                    color: Colors.black.withOpacity(0.1),
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
    );
  }

  Widget _buildFoodProductsSection() {
    if (_loadingProducts) {
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    
    if (_realFoodProducts.isEmpty) {
      return Container(
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
                'No hay productos disponibles',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
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
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4),
            itemCount: _realFoodProducts.length,
            itemBuilder: (context, index) {
              final product = _realFoodProducts[index];
              return GestureDetector(
                onTap: () {
                  // Convert StoreProduct to Map for ProductDetailsScreen compatibility
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
                      child: Container(
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
    IconData _getIconFromString(String iconName) {
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
        Container(
          height: 120,
          child: _categories.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final iconData = _getIconFromString(category['icon'] ?? 'category');
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
        Container(
          height: 220,
          child: _bestSellers.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : ListView.builder(
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
                              child: Container(
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

  Widget _buildRentaCarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Center(
            child: Text(
              'Renta Car',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 200, // Aumentado de 180 a 200 para más espacio
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _getRentaCarData().length,
            itemBuilder: (context, index) {
              final car = _getRentaCarData()[index];
              return _buildRentaCarCard(car);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRentaCarCard(Map<String, dynamic> car) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del auto
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              color: car['color'],
            ),
            child: Center(
              child: Icon(
                Icons.directions_car,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          // Información del auto
          Padding(
            padding: EdgeInsets.all(10), // Aumentado de 8 a 10
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car['price'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  car['type'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8), // Aumentado de 6 a 8
                SizedBox(
                  width: double.infinity,
                  height: 36, // Aumentado de 32 a 36
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RentaCarScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Agregado padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Aumentado de 6 a 8
                      ),
                      elevation: 2, // Agregada elevación
                    ),
                    child: Text(
                      'Reservar',
                      style: TextStyle(
                        fontSize: 12, // Aumentado de 11 a 12
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getRentaCarData() {
    return [
      {
        'price': '\$107.00 /día',
        'type': 'Económico Manual',
        'color': Colors.grey[400],
      },
      {
        'price': '\$113.00 /día',
        'type': 'Económico Automático',
        'color': Colors.white,
      },
      {
        'price': '\$105.00 /día',
        'type': 'Medio Automático',
        'color': Colors.grey[300],
      },
      {
        'price': '\$152.00 /día',
        'type': 'SUV Automático',
        'color': Colors.grey[500],
      },
    ];
  }
}
