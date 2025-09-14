import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesService {
  static const String _favoritesKey = 'user_favorites';
  static FavoritesService? _instance;
  static FavoritesService get instance => _instance ??= FavoritesService._();
  
  FavoritesService._();
  
  List<Map<String, dynamic>> _favorites = [];
  
  // Getters
  List<Map<String, dynamic>> get favorites => List.unmodifiable(_favorites);
  int get favoritesCount => _favorites.length;
  bool get hasFavorites => _favorites.isNotEmpty;
  
  // Initialize favorites from storage
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = json.decode(favoritesJson);
        _favorites = favoritesList.cast<Map<String, dynamic>>();
        print('✅ Favoritos cargados: ${_favorites.length} productos');
      } else {
        _favorites = [];
        print('ℹ️ No hay favoritos guardados');
      }
    } catch (e) {
      print('❌ Error cargando favoritos: $e');
      _favorites = [];
    }
  }
  
  // Add product to favorites
  Future<bool> addToFavorites(Map<String, dynamic> product) async {
    try {
      // Check if product already exists
      final existingIndex = _favorites.indexWhere(
        (fav) => fav['id'] == product['id']
      );
      
      if (existingIndex != -1) {
        print('⚠️ Producto ya está en favoritos');
        return false;
      }
      
      // Add timestamp for sorting
      final productWithTimestamp = {
        ...product,
        'addedAt': DateTime.now().toIso8601String(),
      };
      
      _favorites.add(productWithTimestamp);
      await _saveToStorage();
      
      print('✅ Producto agregado a favoritos: ${product['name']}');
      return true;
    } catch (e) {
      print('❌ Error agregando a favoritos: $e');
      return false;
    }
  }
  
  // Remove product from favorites
  Future<bool> removeFromFavorites(String productId) async {
    try {
      final initialLength = _favorites.length;
      _favorites.removeWhere((fav) => fav['id'] == productId);
      
      if (_favorites.length < initialLength) {
        await _saveToStorage();
        print('✅ Producto removido de favoritos');
        return true;
      } else {
        print('⚠️ Producto no encontrado en favoritos');
        return false;
      }
    } catch (e) {
      print('❌ Error removiendo de favoritos: $e');
      return false;
    }
  }
  
  // Check if product is in favorites
  bool isFavorite(String productId) {
    return _favorites.any((fav) => fav['id'] == productId);
  }
  
  // Toggle favorite status
  Future<bool> toggleFavorite(Map<String, dynamic> product) async {
    if (isFavorite(product['id'])) {
      return await removeFromFavorites(product['id']);
    } else {
      return await addToFavorites(product);
    }
  }
  
  // Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      _favorites.clear();
      await _saveToStorage();
      print('✅ Todos los favoritos eliminados');
    } catch (e) {
      print('❌ Error eliminando favoritos: $e');
    }
  }
  
  // Get favorites by category
  List<Map<String, dynamic>> getFavoritesByCategory(String category) {
    return _favorites.where((fav) => fav['category'] == category).toList();
  }
  
  // Get recent favorites (last 10)
  List<Map<String, dynamic>> getRecentFavorites({int limit = 10}) {
    final sortedFavorites = List<Map<String, dynamic>>.from(_favorites);
    sortedFavorites.sort((a, b) {
      final dateA = DateTime.parse(a['addedAt'] ?? DateTime.now().toIso8601String());
      final dateB = DateTime.parse(b['addedAt'] ?? DateTime.now().toIso8601String());
      return dateB.compareTo(dateA); // Most recent first
    });
    
    return sortedFavorites.take(limit).toList();
  }
  
  // Save to storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(_favorites);
      await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      print('❌ Error guardando favoritos: $e');
    }
  }
  
  // Create product map from various product types
  static Map<String, dynamic> createProductMap({
    required String id,
    required String name,
    required double price,
    required String imageUrl,
    String? description,
    String? category,
    String? store,
    String? brand,
    String? unit,
    double? rating,
    int? reviewsCount,
  }) {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description ?? '',
      'category': category ?? 'General',
      'store': store ?? 'Tienda',
      'brand': brand ?? 'Desconocido',
      'unit': unit ?? 'unidad',
      'rating': rating ?? 0.0,
      'reviewsCount': reviewsCount ?? 0,
    };
  }
}
