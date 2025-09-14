import 'package:flutter/foundation.dart';
import 'package:cubalink23/models/delivery_profile.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryProfileService extends ChangeNotifier {
  static final DeliveryProfileService _instance = DeliveryProfileService._internal();
  factory DeliveryProfileService() => _instance;
  DeliveryProfileService._internal();

  final SupabaseClient? _client = SupabaseConfig.client;
  DeliveryProfile? _currentProfile;
  bool _isLoading = false;

  DeliveryProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _currentProfile != null;

  /// Cargar perfil de repartidor por user_id
  Future<DeliveryProfile?> getDeliveryProfile(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return null;
      }

      print('🚚 Cargando perfil de repartidor para usuario: $userId');

      final response = await _client
          .from('delivery_profiles')
          .select('*')
          .eq('user_id', userId)
          .single();

      _currentProfile = DeliveryProfile.fromJson(response);
      print('✅ Perfil de repartidor cargado: ${_currentProfile!.userId}');
      return _currentProfile;
    
      return null;
    } catch (e) {
      print('❌ Error cargando perfil de repartidor: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear nuevo perfil de repartidor
  Future<bool> createDeliveryProfile(DeliveryProfile profile) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('🚚 Creando perfil de repartidor para usuario: ${profile.userId}');

      final profileData = profile.toJson();
      // Remover campos que se generan automáticamente
      profileData.remove('id');
      profileData.remove('created_at');
      profileData.remove('updated_at');

      final response = await _client
          .from('delivery_profiles')
          .insert(profileData);

      print('✅ Perfil de repartidor creado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error creando perfil de repartidor: $e');
      return false;
    }
  }

  /// Actualizar perfil de repartidor
  Future<bool> updateDeliveryProfile(DeliveryProfile profile) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('🚚 Actualizando perfil de repartidor: ${profile.userId}');

      final profileData = profile.toJson();
      // Remover campos que no se deben actualizar
      profileData.remove('id');
      profileData.remove('user_id');
      profileData.remove('created_at');
      profileData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('delivery_profiles')
          .update(profileData)
          .eq('id', profile.id);

      if (_currentProfile?.id == profile.id) {
        _currentProfile = profile;
        notifyListeners();
      }

      print('✅ Perfil de repartidor actualizado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando perfil de repartidor: $e');
      return false;
    }
  }

  /// Obtener todos los perfiles de repartidor (para admin)
  Future<List<DeliveryProfile>> getAllDeliveryProfiles() async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return [];
      }

      print('🚚 Cargando todos los perfiles de repartidor...');

      final response = await _client
          .from('delivery_profiles')
          .select('*')
          .order('created_at', ascending: false);

      final profiles = response.map<DeliveryProfile>((data) => 
          DeliveryProfile.fromJson(data)).toList();

      print('✅ ${profiles.length} perfiles de repartidor cargados');
      return profiles;
    } catch (e) {
      print('❌ Error cargando perfiles de repartidor: $e');
      return [];
    }
  }

  /// Obtener repartidores activos
  Future<List<DeliveryProfile>> getActiveDeliveryProfiles() async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return [];
      }

      print('🚚 Cargando repartidores activos...');

      final response = await _client
          .from('delivery_profiles')
          .select('*')
          .eq('is_active', true)
          .order('rating_average', ascending: false);

      final profiles = response.map<DeliveryProfile>((data) => 
          DeliveryProfile.fromJson(data)).toList();

      print('✅ ${profiles.length} repartidores activos cargados');
      return profiles;
    } catch (e) {
      print('❌ Error cargando repartidores activos: $e');
      return [];
    }
  }

  /// Activar/desactivar repartidor
  Future<bool> setDeliveryStatus(String deliveryId, bool isActive) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('🚚 ${isActive ? 'Activando' : 'Desactivando'} repartidor: $deliveryId');

      final response = await _client
          .from('delivery_profiles')
          .update({
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', deliveryId);

      print('✅ Estado del repartidor actualizado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando estado del repartidor: $e');
      return false;
    }
  }

  /// Actualizar balance del repartidor
  Future<bool> updateDeliveryBalance(String deliveryId, double newBalance) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('💰 Actualizando balance del repartidor: $deliveryId');

      final response = await _client
          .from('delivery_profiles')
          .update({
            'balance': newBalance,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', deliveryId);

      if (_currentProfile?.id == deliveryId) {
        _currentProfile = _currentProfile!.copyWith(balance: newBalance);
        notifyListeners();
      }

      print('✅ Balance actualizado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando balance: $e');
      return false;
    }
  }

  /// Actualizar calificación promedio del repartidor
  Future<bool> updateDeliveryRating(String deliveryId, double newRating, int totalRatings) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('⭐ Actualizando calificación del repartidor: $deliveryId');

      final response = await _client
          .from('delivery_profiles')
          .update({
            'rating_average': newRating,
            'total_ratings': totalRatings,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', deliveryId);

      print('✅ Calificación actualizada exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando calificación: $e');
      return false;
    }
  }

  /// Incrementar entregas del repartidor
  Future<bool> incrementDeliveryCount(String deliveryId) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('📦 Incrementando entregas del repartidor: $deliveryId');

      // Primero obtener el valor actual
      final currentResponse = await _client
          .from('delivery_profiles')
          .select('total_deliveries')
          .eq('id', deliveryId)
          .single();

      final currentDeliveries = currentResponse['total_deliveries'] ?? 0;
      final newDeliveries = currentDeliveries + 1;

      // Actualizar con el nuevo valor
      final response = await _client
          .from('delivery_profiles')
          .update({
            'total_deliveries': newDeliveries,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', deliveryId);

      print('✅ Entregas incrementadas exitosamente');
      return true;
    } catch (e) {
      print('❌ Error incrementando entregas: $e');
      return false;
    }
  }

  /// Transferir dinero al repartidor
  Future<bool> transferToDelivery(String deliveryId, double amount) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('💰 Transfiriendo \$${amount.toStringAsFixed(2)} al repartidor: $deliveryId');

      // Primero obtener el balance actual
      final currentResponse = await _client
          .from('delivery_profiles')
          .select('balance')
          .eq('id', deliveryId)
          .single();

      final currentBalance = (currentResponse['balance'] ?? 0.0).toDouble();
      final newBalance = currentBalance + amount;

      // Actualizar con el nuevo balance
      final response = await _client
          .from('delivery_profiles')
          .update({
            'balance': newBalance,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', deliveryId);

      if (_currentProfile?.id == deliveryId) {
        _currentProfile = _currentProfile!.copyWith(balance: newBalance);
        notifyListeners();
      }

      print('✅ Transferencia completada exitosamente');
      return true;
    } catch (e) {
      print('❌ Error en transferencia: $e');
      return false;
    }
  }

  /// Retirar dinero del repartidor
  Future<bool> withdrawFromDelivery(String deliveryId, double amount) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('💰 Retirando \$${amount.toStringAsFixed(2)} del repartidor: $deliveryId');

      // Primero obtener el balance actual
      final currentResponse = await _client
          .from('delivery_profiles')
          .select('balance')
          .eq('id', deliveryId)
          .single();

      final currentBalance = (currentResponse['balance'] ?? 0.0).toDouble();
      
      if (currentBalance < amount) {
        print('❌ Balance insuficiente para retiro');
        return false;
      }

      final newBalance = currentBalance - amount;

      // Actualizar con el nuevo balance
      final response = await _client
          .from('delivery_profiles')
          .update({
            'balance': newBalance,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', deliveryId);

      if (_currentProfile?.id == deliveryId) {
        _currentProfile = _currentProfile!.copyWith(balance: newBalance);
        notifyListeners();
      }

      print('✅ Retiro completado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error en retiro: $e');
      return false;
    }
  }

  /// Limpiar perfil actual
  void clearCurrentProfile() {
    _currentProfile = null;
    notifyListeners();
  }

  /// Verificar si un usuario tiene perfil de repartidor
  Future<bool> hasDeliveryProfile(String userId) async {
    try {
      if (_client == null) {
        return false;
      }

      final response = await _client
          .from('delivery_profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Error verificando perfil de repartidor: $e');
      return false;
    }
  }
}
