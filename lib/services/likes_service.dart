import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cubalink23/supabase/supabase_config.dart';

class LikesService {
  static LikesService? _instance;
  static LikesService get instance => _instance ??= LikesService._();
  
  LikesService._();
  
  final _supabase = SupabaseConfig.client;

  /// Agregar o quitar un producto de los favoritos del usuario
  Future<bool> toggleLike(String productId, String productName, String productImage, double productPrice) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ Usuario no autenticado para toggle like');
        return false;
      }

      // Verificar si ya existe el like
      final existingLike = await _supabase
          .from('user_likes')
          .select('id')
          .eq('user_id', user.id)
          .eq('product_id', productId)
          .maybeSingle();

      if (existingLike != null) {
        // Quitar like
        await _supabase
            .from('user_likes')
            .delete()
            .eq('user_id', user.id)
            .eq('product_id', productId);
        
        print('✅ Like removido para producto: $productName');
        return false; // Ya no está en favoritos
      } else {
        // Agregar like
        await _supabase
            .from('user_likes')
            .insert({
              'user_id': user.id,
              'product_id': productId,
              'product_name': productName,
              'product_image_url': productImage,
              'product_price': productPrice,
              'created_at': DateTime.now().toIso8601String(),
            });
        
        print('✅ Like agregado para producto: $productName');
        return true; // Está en favoritos
      }
    } catch (e) {
      print('❌ Error en toggleLike: $e');
      return false;
    }
  }

  /// Verificar si un producto está en favoritos del usuario
  Future<bool> isLiked(String productId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final like = await _supabase
          .from('user_likes')
          .select('id')
          .eq('user_id', user.id)
          .eq('product_id', productId)
          .maybeSingle();

      return like != null;
    } catch (e) {
      print('❌ Error en isLiked: $e');
      return false;
    }
  }

  /// Obtener todos los productos favoritos del usuario
  Future<List<Map<String, dynamic>>> getUserLikes() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final likes = await _supabase
          .from('user_likes')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(likes);
    } catch (e) {
      print('❌ Error en getUserLikes: $e');
      return [];
    }
  }

  /// Obtener el número total de likes de un producto
  Future<int> getProductLikesCount(String productId) async {
    try {
      final response = await _supabase
          .from('user_likes')
          .select('id')
          .eq('product_id', productId);

      return response.length;
    } catch (e) {
      print('❌ Error en getProductLikesCount: $e');
      return 0;
    }
  }
}
