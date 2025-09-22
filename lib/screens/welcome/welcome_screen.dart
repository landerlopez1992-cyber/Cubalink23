import 'package:flutter/material.dart';
import 'package:cubalink23/screens/recharge/recharge_home_screen.dart';
import 'package:cubalink23/screens/travel/flight_booking_screen.dart';
import 'package:cubalink23/screens/travel/renta_car_screen.dart';
import 'package:cubalink23/services/cart_service.dart';
import 'package:cubalink23/services/store_service.dart';
import 'package:cubalink23/services/firebase_repository.dart';
import 'package:cubalink23/services/notification_manager.dart';
import 'package:cubalink23/services/firebase_messaging_service.dart';
import 'package:cubalink23/services/supabase_auth_service.dart';
import 'package:cubalink23/models/store_product.dart';
import 'package:cubalink23/screens/shopping/product_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _currentBalance = 0.0; // Balance inicial correcto
  bool _isLoading = true;
  int _unreadNotificationsCount = 0;
  int _cartItemsCount = 0;
  // String? _currentUserId;
  List<String> _bannerUrls = [];
  List<String> _flightsBannerUrls = [];
  final CartService _cartService = CartService();
  final StoreService _storeService = StoreService();
  final FirebaseRepository _firebaseRepository = FirebaseRepository.instance;
  int _currentBannerIndex = 0;
  int _currentFlightsBannerIndex = 0;
  final PageController _bannerController = PageController();
  final PageController _flightsBannerController = PageController();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _bestSellers = [];
  List<StoreProduct> _realFoodProducts = [];
  bool _loadingProducts = true;
  Timer? _maintenanceCheckTimer;
  Timer? _forceUpdateCheckTimer;

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
    
    print('🔥 === WELCOME SCREEN INIT - CARGANDO SALDO ===');
    
    // Cargar saldo del usuario INMEDIATAMENTE
    _loadUserBalance();
    
    // También cargar saldo cuando la pantalla se vuelve visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔥 === POST FRAME CALLBACK - CARGANDO SALDO ===');
      _loadUserBalance();
    });
    
    // Inicializar Firebase Messaging (opcional)
    try {
      FirebaseMessagingService().initialize();
    } catch (e) {
      print('⚠️ Firebase Messaging no disponible: $e');
    }
    
    // Inicializar el manager de notificaciones push
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationManager().initialize(context);
    });
    
    // Verificar modo mantenimiento primero
    _checkMaintenanceMode();
    
    // Iniciar timer para verificar mantenimiento continuamente
    _startMaintenanceCheckTimer();
    
    // Iniciar timer para verificar actualizaciones forzadas
    _startForceUpdateCheckTimer();
    
    // Cargar productos reales de Supabase inmediatamente
    _loadRealProductsFromSupabase();
    _loadCategoriesAndBestSellers();
    _loadNotificationsCount(); // Cargar contador de notificaciones
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
    _maintenanceCheckTimer?.cancel();
    _forceUpdateCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar saldo cuando se regrese a esta pantalla
    _loadUserBalance();
  }

  void _updateCartCount() {
    if (mounted) {
      setState(() {
        _cartItemsCount = _cartService.itemCount;
      });
    }
  }

  Future<void> _loadUserBalance() async {
    try {
      print('💰 === CARGANDO SALDO DEL USUARIO ===');
      print('💰 Estado de autenticación: ${SupabaseAuthService.instance.isUserLoggedIn}');

      // Forzar recarga del usuario
      await SupabaseAuthService.instance.loadCurrentUserData();
      final currentUser = SupabaseAuthService.instance.currentUser;

      print('💰 Usuario después de recarga: ${currentUser != null ? "ENCONTRADO" : "NO ENCONTRADO"}');

      if (currentUser != null) {
        print('💰 Usuario encontrado: ${currentUser.name} (${currentUser.email})');
        print('💰 Saldo actual: \$${currentUser.balance}');
        print('💰 Tipo de saldo: ${currentUser.balance.runtimeType}');

        if (mounted) {
          setState(() {
            _currentBalance = currentUser.balance;
          });
          print('💰 ✅ Saldo actualizado en la UI: \$$_currentBalance');
        }
      } else {
        print('💰 ❌ No se pudo cargar el usuario después de recarga');
        print('💰 ❌ Intentando cargar usuario directamente desde Supabase...');
        
        // No usar saldo de prueba, mantener en 0 hasta cargar datos reales
        if (mounted) {
          setState(() {
            _currentBalance = 0.0; // Saldo real, no de prueba
          });
          print('💰 ⚠️ Usando saldo real: \$$_currentBalance');
        }
      }
    } catch (e) {
      print('💰 ❌ Error cargando saldo del usuario: $e');
      print('💰 ❌ Stack trace: ${StackTrace.current}');
      
      // En caso de error, usar saldo de prueba
      if (mounted) {
        setState(() {
          _currentBalance = 100.0; // Saldo de prueba más visible
        });
        print('💰 ⚠️ Usando saldo de prueba por error: \$$_currentBalance');
      }
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






  Future<void> _checkMaintenanceMode() async {
    try {
      final response = await http.get(
        Uri.parse('https://cubalink23-backend.onrender.com/admin/api/maintenance/status'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isMaintenanceMode = data['maintenance_mode'] as bool? ?? false;
        
        print('🔧 Modo mantenimiento: $isMaintenanceMode');
        
        if (isMaintenanceMode && mounted) {
          print('🔧 ACTIVANDO pantalla de mantenimiento...');
          Navigator.of(context).pushReplacementNamed('/maintenance');
        }
      }
    } catch (e) {
      print('❌ Error verificando modo mantenimiento: $e');
    }
  }

  void _startMaintenanceCheckTimer() {
    // Verificar cada 5 segundos si el modo mantenimiento se activa
    _maintenanceCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      print('🔧 Timer verificando mantenimiento...');
      _checkMaintenanceMode();
    });
  }

  void _startForceUpdateCheckTimer() {
    // Verificar cada 10 segundos si hay actualizaciones forzadas
    _forceUpdateCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      print('🔄 Timer verificando actualizaciones forzadas...');
      _checkForceUpdateMode();
    });
  }

  Future<void> _checkForceUpdateMode() async {
    try {
      final response = await http.get(
        Uri.parse('https://cubalink23-backend.onrender.com/admin/api/force-update/status'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isForceUpdateMode = data['force_update_mode'] as bool? ?? false;
        
        print('🔄 Modo actualización forzada: $isForceUpdateMode');
        
        if (isForceUpdateMode && mounted) {
          print('🔄 ACTIVANDO pantalla de actualización forzada...');
          Navigator.of(context).pushReplacementNamed('/force-update');
        }
      }
    } catch (e) {
      print('❌ Error verificando modo actualización forzada: $e');
    }
  }

  Future<void> _loadNotificationsCount() async {
    // No necesitamos verificar _currentUserId para obtener notificaciones
    // ya que todas las notificaciones son para 'admin' por defecto

    try {
      // Obtener historial de notificaciones desde el backend
      final response = await http.get(
        Uri.parse('https://cubalink23-backend.onrender.com/admin/api/notifications/history'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notifications = data['notifications'] as List? ?? [];
        
        // Contar notificaciones no leídas
        final unreadCount = notifications.where((n) => n['read'] == false).length;
        
        if (mounted) {
          setState(() {
            _unreadNotificationsCount = unreadCount;
          });
        }
        print('🔔 Unread notifications count: $unreadCount');
      } else {
        print('❌ Error getting notifications: ${response.statusCode}');
      }
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
      var categories = await _storeService.getCategories();
      print('📦 Categorías cargadas: ${categories.length}');

      // Filtrar categorías no deseadas
      final disallowed = [
        'postres', 'panaderia', 'panadería', 'frutas y verdura', 'frutas y verduras',
        'comida rapida', 'comida rápida', 'carnes', 'bebidas'
      ];
      categories = categories.where((c) {
        final n = c.name.toLowerCase().trim();
        return !disallowed.any((bad) => n.contains(bad));
      }).toList();
      
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
        categoriesMap = categories.map((cat) {
          // Priorizar el NOMBRE visible para el mapeo de iconos
          final visibleNameRaw = cat.name.trim();
          final visibleName = visibleNameRaw.isNotEmpty
              ? visibleNameRaw
              : (cat.iconName ?? '').trim();
          final baseIcon = visibleName.toLowerCase();
          final customIcon = _getCustomCategoryIcon(visibleName);
          print('🔍 Categoría: ${cat.name} | iconName: ${cat.iconName} | visibleName: $visibleName | customIcon: $customIcon');
          return {
            'id': cat.id,
            'name': cat.name,
            'description': cat.description,
            'icon': baseIcon,
            'color': _getCategoryColor(baseIcon),
            'customIcon': customIcon,
          };
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
        'customIcon': 'assets/Untitled design 2/Alimentos.png',
      },
      {
        'id': 'materiales',
        'name': 'Materiales',
        'description': 'Materiales de construcción',
        'icon': 'construction',
        'color': 0xFFFF8A65,
        'customIcon': 'assets/Untitled design 2/Materiales.png',
      },
      {
        'id': 'ferreteria',
        'name': 'Ferretería',
        'description': 'Herramientas y accesorios',
        'icon': 'hardware',
        'color': 0xFFFF8F00,
        'customIcon': 'assets/Untitled design 2/Ferreteria.png',
      },
      {
        'id': 'farmacia',
        'name': 'Farmacia',
        'description': 'Medicinas y productos de salud',
        'icon': 'local_pharmacy',
        'color': 0xFF26A69A,
        'customIcon': 'assets/Untitled design 2/Farmacia.png',
      },
      {
        'id': 'electronicos',
        'name': 'Electrónicos',
        'description': 'Dispositivos y accesorios',
        'icon': 'devices',
        'color': 0xFF42A5F5,
        'customIcon': 'assets/Untitled design 2/Electronicos.png',
      },
      {
        'id': 'ropa',
        'name': 'Ropa',
        'description': 'Vestimenta y accesorios',
        'icon': 'shopping_bag',
        'color': 0xFFAB47BC,
        'customIcon': 'assets/Untitled design 2/Ropa.png',
      },
      {
        'id': 'restaurantes',
        'name': 'Restaurantes',
        'description': 'Comida preparada',
        'icon': 'restaurant_menu',
        'color': 0xFFFF5722,
        'customIcon': 'assets/Untitled design 2/Restaurantes.png',
      },
      {
        'id': 'deportes',
        'name': 'Deportes',
        'description': 'Artículos deportivos',
        'icon': 'sports',
        'color': 0xFF4CAF50,
        'customIcon': 'assets/Untitled design 2/Deportes.png',
      },
      {
        'id': 'hogar',
        'name': 'Hogar',
        'description': 'Productos para el hogar',
        'icon': 'home',
        'color': 0xFF9C27B0,
        'customIcon': 'assets/Untitled design 2/Hogar.png',
      },
      {
        'id': 'servicios',
        'name': 'Servicios',
        'description': 'Servicios profesionales',
        'icon': 'build',
        'color': 0xFF607D8B,
        'customIcon': 'assets/Untitled design 2/Servicios.png',
      },
      {
        'id': 'supermercado',
        'name': 'Supermercado',
        'description': 'Productos de supermercado',
        'icon': 'shopping_cart',
        'color': 0xFF795548,
        'customIcon': 'assets/Untitled design 2/SUPERMERCADO.png',
      },
    ];
  }

  /// Retorna la ruta del ícono personalizado en assets según el nombre del ícono
  String? _getCustomCategoryIcon(String? iconName) {
    if (iconName == null) return null;
    final lowerName = iconName.toLowerCase().trim();
    print('🔍 Buscando icono para: "$lowerName"');
    
    // Mapeo directo por nombre exacto
    switch (lowerName) {
      case 'supermercado':
        return 'assets/Untitled design 2/SUPERMERCADO.png';
      case 'servicios':
        return 'assets/Untitled design 2/Servicios.png';
      case 'restaurantes':
        return 'assets/Untitled design 2/Restaurantes.png';
      case 'ferreteria':
      case 'ferretería':
        return 'assets/Untitled design 2/Ferreteria.png';
      case 'deportes':
        return 'assets/Untitled design 2/Deportes.png';
      case 'alimentos':
        return 'assets/Untitled design 2/Alimentos.png';
      case 'materiales':
        return 'assets/Untitled design 2/Materiales.png';
      case 'farmacia':
        return 'assets/Untitled design 2/Farmacia.png';
      case 'electronicos':
      case 'electrónicos':
        return 'assets/Untitled design 2/Electronicos.png';
      case 'ropa':
        return 'assets/Untitled design 2/Ropa.png';
      case 'hogar':
        return 'assets/Untitled design 2/Hogar.png';
      // Fallbacks por iconName
      case 'restaurant':
      case 'restaurant_menu':
        return 'assets/Untitled design 2/Restaurantes.png';
      case 'construction':
        return 'assets/Untitled design 2/Materiales.png';
      case 'hardware':
        return 'assets/Untitled design 2/Ferreteria.png';
      case 'local_pharmacy':
      case 'healing':
        return 'assets/Untitled design 2/Farmacia.png';
      case 'devices':
      case 'phone_android':
        return 'assets/Untitled design 2/Electronicos.png';
      case 'shopping_bag':
        return 'assets/Untitled design 2/Ropa.png';
      case 'sports':
        return 'assets/Untitled design 2/Deportes.png';
      case 'home':
        return 'assets/Untitled design 2/Hogar.png';
      case 'build':
        return 'assets/Untitled design 2/Servicios.png';
      case 'shopping_cart':
        return 'assets/Untitled design 2/SUPERMERCADO.png';
      default:
        print('❌ No se encontró icono para: "$lowerName"');
        return null;
    }
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
      case 'restaurant_menu': return 0xFFE57373;
      case 'restaurantes': return 0xFFE57373;
      case 'construction': return 0xFFFF8A65; // Orange for construction materials
      case 'build': return 0xFF607D8B; // Services mapped to build
      case 'hardware': return 0xFFFF8F00; // Amber for tools/hardware (Ferretería)
      case 'healing': return 0xFF26A69A; // Teal for pharmacy
      case 'local_pharmacy': return 0xFF26A69A; // Teal for pharmacy (alternative)
      case 'phone_android': return 0xFF42A5F5; // Blue for electronics
      case 'devices': return 0xFF42A5F5; // Blue for electronics (alternative)
      case 'shopping_bag': return 0xFFAB47BC; // Purple for clothing
      case 'home': return 0xFF66BB6A; // Green for home products
      case 'fitness_center': return 0xFFFF7043; // Orange for sports
      case 'sports': return 0xFFFF7043;
      case 'spa': return 0xFFE91E63; // Pink for cosmetics
      case 'services': return 0xFF607D8B; // Services
      case 'shopping_cart': return 0xFF795548; // Supermarket
      case 'supermercado': return 0xFF795548;
      default: return 0xFF9E9E9E; // Gray default
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Fondo general Cubalink23
      appBar: AppBar(
        backgroundColor: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Inicio',
          style: TextStyle(
            color: Colors.white, // Texto blanco sobre fondo azul gris
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
                  SizedBox(
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
                          customIcon: 'assets/images/agregar balance.png',
                          onTap: () {
                            Navigator.pushNamed(context, '/add-balance');
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.analytics,
                          title: 'Actividad',
                          gradient: [Colors.blue.shade400, Colors.blue.shade600],
                          customIcon: 'assets/images/Actividad.png',
                          onTap: () {
                            Navigator.pushNamed(context, '/activity');
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.forum,
                          title: 'Mensajería',
                          gradient: [Colors.purple.shade400, Colors.purple.shade600],
                          customIcon: 'assets/images/Mensajeria.png',
                          onTap: () {
                            Navigator.pushNamed(context, '/communication');
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.compare_arrows,
                          title: 'Transferir Saldo',
                          gradient: [Colors.indigo.shade400, Colors.indigo.shade600],
                          customIcon: 'assets/images/Transfiere Saldo.png',
                          onTap: () {
                            Navigator.pushNamed(context, '/transfer');
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.smartphone,
                          title: 'Recarga',
                          gradient: [Colors.orange.shade400, Colors.orange.shade600],
                          customIcon: 'assets/images/Recarga.png',
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
                          customIcon: 'assets/images/Viajes.png',
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
                          customIcon: 'assets/images/Refiere y gana.png',
                          onTap: () {
                            Navigator.pushNamed(context, '/referral');
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.shopping_cart,
                          title: 'Amazon',
                          gradient: [Color(0xFFFF9900), Color(0xFFFF6600)],
                          customIcon: 'assets/images/Amazon.png',
                          onTap: () {
                            Navigator.pushNamed(context, '/amazon-shopping');
                          },
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.shopping_bag,
                          title: 'Tienda',
                          gradient: [Colors.teal.shade400, Colors.teal.shade600],
                          customIcon: 'assets/images/Tienda.png',
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
                  SizedBox(height: 20),
                  // Banner "Trabaja con nosotros"
                  _buildWorkWithUsBanner(),
                  SizedBox(height: 20),
                  // Sección de Términos y Condiciones
                  _buildTermsAndConditionsSection(),
                  SizedBox(height: 30), // Espacio adicional al final
                ],
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Ya estamos en inicio
              break;
            case 1:
              Navigator.pushNamed(context, '/favorite-flights');
              break;
            case 2:
              Navigator.pushNamed(context, '/settings');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Color(0xFFFF9800)), // Naranja oficial Cubalink23
            label: 'Favoritos',
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
    String? customIcon,
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
              width: 84,
              height: 84,
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
              child: customIcon != null
                  ? Image.asset(
                      customIcon,
                      width: 58,
                      height: 58,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      icon,
                      size: 52,
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
            Color(0xFF37474F), // Azul gris oscuro Cubalink23
            Color(0xFF4CAF50), // Verde secciones Cubalink23
            Color(0xFFFF9800), // Naranja botones principales Cubalink23
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
      return SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
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
                  Icon(Icons.restaurant, color: Color(0xFF4CAF50), size: 24), // Verde secciones Cubalink23
                  SizedBox(width: 8),
                  Text(
                    'Productos Alimenticios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C), // Texto principal Cubalink23
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
                                        color: Color(0xFF4CAF50), // Verde éxito Cubalink23
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
                                    color: Color(0xFFFF9800), // Naranja botones principales Cubalink23
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
          return Icons.restaurant_menu_rounded;
        case 'build':
          return Icons.construction_rounded;
        case 'hardware':
          return Icons.handyman_rounded;
        case 'local_pharmacy':
          return Icons.medication_rounded;
        case 'devices':
          return Icons.phone_android_rounded;
        case 'spa':
          return Icons.spa_rounded;
        case 'shopping_bag':
          return Icons.shopping_bag_rounded;
        case 'construction':
          return Icons.construction_rounded;
        case 'healing':
          return Icons.medication_rounded;
        case 'phone_android':
          return Icons.phone_android_rounded;
        case 'category':
          return Icons.category_rounded;
        default:
          return Icons.category_rounded;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.category, color: Color(0xFF4CAF50), size: 24), // Verde secciones Cubalink23
              SizedBox(width: 8),
              Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C), // Texto principal Cubalink23
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: _categories.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
                  ),
                )
              : ListView.builder(
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
                        width: 110,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: category['customIcon'] != null
                                  ? Image.asset(
                                      category['customIcon'],
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.contain,
                                    )
                                  : Icon(
                                      iconData,
                                      color: color,
                                      size: 40,
                                    ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              category['name'] ?? 'Categoría',
                              style: TextStyle(
                                fontSize: 13,
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
                  color: Color(0xFF2C2C2C), // Texto principal Cubalink23
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
          child: _bestSellers.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
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
                                            color: Color(0xFF4CAF50), // Verde éxito Cubalink23
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
                                        color: Color(0xFFFF9800), // Naranja botones principales Cubalink23
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
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Autos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RentaCarScreen(),
                    ),
                  );
                },
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RentaCarScreen(),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
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
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                color: car['color'],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  car['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: car['color'],
                      child: Center(
                        child: Icon(
                          Icons.directions_car,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Información del auto
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car['price'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    car['type'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getRentaCarData() {
    return [
      {
        'price': '\$107.00 /día',
        'type': 'Económico Manual',
        'color': Colors.grey[400],
        'image': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400&h=300&fit=crop&crop=center',
      },
      {
        'price': '\$113.00 /día',
        'type': 'Económico Automático',
        'color': Colors.white,
        'image': 'https://images.unsplash.com/photo-1549317336-206569e8475c?w=400&h=300&fit=crop&crop=center',
      },
      {
        'price': '\$105.00 /día',
        'type': 'Medio Automático',
        'color': Colors.grey[300],
        'image': 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=400&h=300&fit=crop&crop=center',
      },
      {
        'price': '\$152.00 /día',
        'type': 'SUV Automático',
        'color': Colors.grey[500],
        'image': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=400&h=300&fit=crop&crop=center',
      },
    ];
  }

  Widget _buildWorkWithUsBanner() {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de selección de trabajo
        Navigator.pushNamed(context, '/work_selection');
      },
      child: Container(
        height: 180,
        margin: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF37474F), // Azul gris oscuro Cubalink23
              Color(0xFF4CAF50), // Verde secciones Cubalink23
              Color(0xFFFF9800), // Naranja botones principales Cubalink23
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decoración con iconos de trabajo
            Positioned(
              right: 20,
              top: 15,
              child: Icon(
                Icons.work_outline,
                size: 60,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            Positioned(
              right: 60,
              bottom: 20,
              child: Icon(
                Icons.delivery_dining,
                size: 40,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Positioned(
              right: 100,
              top: 50,
              child: Icon(
                Icons.storefront,
                size: 35,
                color: Colors.white.withOpacity(0.25),
              ),
            ),
            // Contenido principal
            Positioned(
              left: 20,
              top: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '💼 OPORTUNIDADES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '🚀 Trabaja con Nosotros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Vendedor • Repartidor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '💰 Ingresos extras • Horarios flexibles',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '📱 Regístrate ahora y comienza',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Botón de acción
            Positioned(
              right: 20,
              bottom: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Aplicar Ahora',
                      style: TextStyle(
                        color: Color(0xFF37474F), // Azul gris oscuro Cubalink23
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF37474F), // Azul gris oscuro Cubalink23
                      size: 18,
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


  Widget _buildTermsAndConditionsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(12), // Reduced padding
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
        children: [
          // Primera fila: Términos y Contacto
          Row(
            children: [
              // Columna izquierda: Términos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF4CAF50), size: 16), // Verde secciones Cubalink23
                        SizedBox(width: 6),
                        Text('Legal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))), // Texto principal Cubalink23
                      ],
                    ),
                    SizedBox(height: 8),
                    _buildCompactLegalLink('Términos y Condiciones'),
                    _buildCompactLegalLink('Política de Privacidad'),
                    _buildCompactLegalLink('Términos Vendedores'),
                    _buildCompactLegalLink('Términos Repartidores'),
                  ],
                ),
              ),
              
              // Separador vertical
              Container(
                width: 1,
                height: 80,
                color: Colors.grey[300],
                margin: EdgeInsets.symmetric(horizontal: 12),
              ),
              
              // Columna derecha: Contacto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contact_phone, color: Color(0xFF4CAF50), size: 16), // Verde secciones Cubalink23
                        SizedBox(width: 6),
                        Text('Contacto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))), // Texto principal Cubalink23
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.grey[600], size: 14),
                        SizedBox(width: 6),
                        Expanded(child: Text('+1 561 593 6776', style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500))),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.grey[600], size: 14),
                        SizedBox(width: 6),
                        Expanded(child: Text('info@cubalink23.com', style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Divider horizontal
          Container(height: 1, color: Colors.grey[300]),
          
          SizedBox(height: 12),
          
          // Segunda fila: Acreditaciones y Copyright
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Acreditaciones
              Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF4CAF50), size: 16), // Verde secciones Cubalink23
                  SizedBox(width: 6),
                  Text('Miembro IATA', style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                ],
              ),
              
              // Copyright
              Text('© 2024 CubaLink23', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLegalLink(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () {
          // Navegar a la pantalla correspondiente
          String route = _getRouteForTitle(title);
          if (route.isNotEmpty) {
            Navigator.pushNamed(context, route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title - Próximamente disponible'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Text(
          '• $title',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getRouteForTitle(String title) {
    switch (title) {
      case 'Términos y Condiciones':
        return '/terms_conditions';
      case 'Política de Privacidad':
        return '/privacy_policy';
      case 'Términos Vendedores':
        return '/vendor_terms';
      case 'Términos Repartidores':
        return '/delivery_terms';
      default:
        return '';
    }
  }
}
