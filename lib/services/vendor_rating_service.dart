import 'package:flutter/foundation.dart';
import 'package:cubalink23/models/vendor_rating.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendorRatingService extends ChangeNotifier {
  static final VendorRatingService _instance = VendorRatingService._internal();
  factory VendorRatingService() => _instance;
  VendorRatingService._internal();

  final SupabaseClient? _client = SupabaseConfig.client;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Obtener calificaciones de un vendedor
  Future<List<VendorRating>> getVendorRatings(String vendorId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return [];
      }

      print('⭐ Cargando calificaciones del vendedor: $vendorId');

      final response = await _client
          .from('vendor_ratings')
          .select('*')
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);

      final ratings = response.map<VendorRating>((data) => 
          VendorRating.fromJson(data)).toList();

      print('✅ ${ratings.length} calificaciones cargadas');
      return ratings;
    } catch (e) {
      print('❌ Error cargando calificaciones: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear nueva calificación
  Future<bool> createRating(VendorRating rating) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('⭐ Creando calificación para vendedor: ${rating.vendorId}');

      final ratingData = rating.toJson();
      // Remover campos que se generan automáticamente
      ratingData.remove('id');
      ratingData.remove('created_at');
      ratingData.remove('updated_at');

      final response = await _client
          .from('vendor_ratings')
          .insert(ratingData);

      print('✅ Calificación creada exitosamente');
      
      // Actualizar promedio del vendedor
      await _updateVendorAverageRating(rating.vendorId);
      
      return true;
    } catch (e) {
      print('❌ Error creando calificación: $e');
      return false;
    }
  }

  /// Actualizar calificación existente
  Future<bool> updateRating(VendorRating rating) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('⭐ Actualizando calificación: ${rating.id}');

      final ratingData = rating.toJson();
      // Remover campos que no se deben actualizar
      ratingData.remove('id');
      ratingData.remove('vendor_id');
      ratingData.remove('user_id');
      ratingData.remove('created_at');
      ratingData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('vendor_ratings')
          .update(ratingData)
          .eq('id', rating.id);

      print('✅ Calificación actualizada exitosamente');
      
      // Actualizar promedio del vendedor
      await _updateVendorAverageRating(rating.vendorId);
      
      return true;
    } catch (e) {
      print('❌ Error actualizando calificación: $e');
      return false;
    }
  }

  /// Eliminar calificación
  Future<bool> deleteRating(String ratingId) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('⭐ Eliminando calificación: $ratingId');

      // Primero obtener el vendor_id para actualizar el promedio después
      final ratingResponse = await _client
          .from('vendor_ratings')
          .select('vendor_id')
          .eq('id', ratingId)
          .single();

      final vendorId = ratingResponse['vendor_id'];

      // Eliminar la calificación
      final response = await _client
          .from('vendor_ratings')
          .delete()
          .eq('id', ratingId);

      print('✅ Calificación eliminada exitosamente');
      
      // Actualizar promedio del vendedor
      await _updateVendorAverageRating(vendorId);
      
      return true;
    } catch (e) {
      print('❌ Error eliminando calificación: $e');
      return false;
    }
  }

  /// Obtener calificación de un usuario específico para un vendedor
  Future<VendorRating?> getUserRatingForVendor(String userId, String vendorId) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return null;
      }

      print('⭐ Obteniendo calificación del usuario $userId para vendedor $vendorId');

      final response = await _client
          .from('vendor_ratings')
          .select('*')
          .eq('user_id', userId)
          .eq('vendor_id', vendorId)
          .maybeSingle();

      if (response != null) {
        final rating = VendorRating.fromJson(response);
        print('✅ Calificación encontrada: ${rating.rating}/5');
        return rating;
      }

      print('ℹ️ Usuario no ha calificado este vendedor');
      return null;
    } catch (e) {
      print('❌ Error obteniendo calificación del usuario: $e');
      return null;
    }
  }

  /// Verificar si un usuario puede calificar a un vendedor
  Future<bool> canUserRateVendor(String userId, String vendorId) async {
    try {
      if (_client == null) {
        return false;
      }

      // Verificar si ya existe una calificación
      final existingRating = await getUserRatingForVendor(userId, vendorId);
      return existingRating == null;
    } catch (e) {
      print('❌ Error verificando si puede calificar: $e');
      return false;
    }
  }

  /// Obtener estadísticas de calificaciones de un vendedor
  Future<Map<String, dynamic>> getVendorRatingStats(String vendorId) async {
    try {
      if (_client == null) {
        return {};
      }

      print('📊 Obteniendo estadísticas de calificaciones para vendedor: $vendorId');

      final ratings = await getVendorRatings(vendorId);
      
      if (ratings.isEmpty) {
        return {
          'average': 0.0,
          'total': 0,
          'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      // Calcular promedio
      final total = ratings.fold(0, (sum, rating) => sum + rating.rating);
      final average = total / ratings.length;

      // Calcular distribución
      final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final rating in ratings) {
        distribution[rating.rating] = (distribution[rating.rating] ?? 0) + 1;
      }

      final stats = {
        'average': average,
        'total': ratings.length,
        'distribution': distribution,
      };

      print('✅ Estadísticas calculadas: promedio ${average.toStringAsFixed(1)}, total ${ratings.length}');
      return stats;
    } catch (e) {
      print('❌ Error calculando estadísticas: $e');
      return {};
    }
  }

  /// Actualizar promedio de calificaciones del vendedor
  Future<void> _updateVendorAverageRating(String vendorId) async {
    try {
      if (_client == null) return;

      print('📊 Actualizando promedio de calificaciones para vendedor: $vendorId');

      final stats = await getVendorRatingStats(vendorId);
      final average = stats['average'] as double;
      final total = stats['total'] as int;

      // Actualizar en la tabla vendor_profiles
      await _client
          .from('vendor_profiles')
          .update({
            'rating_average': average,
            'total_ratings': total,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);

      print('✅ Promedio de calificaciones actualizado: ${average.toStringAsFixed(1)}');
    } catch (e) {
      print('❌ Error actualizando promedio: $e');
    }
  }

  /// Obtener calificaciones recientes (para admin)
  Future<List<VendorRating>> getRecentRatings({int limit = 50}) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return [];
      }

      print('⭐ Cargando calificaciones recientes...');

      final response = await _client
          .from('vendor_ratings')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);

      final ratings = response.map<VendorRating>((data) => 
          VendorRating.fromJson(data)).toList();

      print('✅ ${ratings.length} calificaciones recientes cargadas');
      return ratings;
    } catch (e) {
      print('❌ Error cargando calificaciones recientes: $e');
      return [];
    }
  }
}
