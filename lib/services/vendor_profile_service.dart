import 'package:flutter/foundation.dart';
import 'package:cubalink23/models/vendor_profile.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendorProfileService extends ChangeNotifier {
  static final VendorProfileService _instance = VendorProfileService._internal();
  factory VendorProfileService() => _instance;
  VendorProfileService._internal();

  final SupabaseClient? _client = SupabaseConfig.client;
  VendorProfile? _currentProfile;
  bool _isLoading = false;

  VendorProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _currentProfile != null;

  /// Cargar perfil de vendedor por user_id
  Future<VendorProfile?> getVendorProfile(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return null;
      }

      print('🏪 Cargando perfil de vendedor para usuario: $userId');

      final response = await _client
          .from('vendor_profiles')
          .select('*')
          .eq('user_id', userId)
          .single();

      _currentProfile = VendorProfile.fromJson(response);
      print('✅ Perfil de vendedor cargado: ${_currentProfile!.companyName}');
      return _currentProfile;
    
      return null;
    } catch (e) {
      print('❌ Error cargando perfil de vendedor: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear nuevo perfil de vendedor
  Future<bool> createVendorProfile(VendorProfile profile) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('🏪 Creando perfil de vendedor: ${profile.companyName}');

      final profileData = profile.toJson();
      // Remover campos que se generan automáticamente
      profileData.remove('id');
      profileData.remove('created_at');
      profileData.remove('updated_at');

      final response = await _client
          .from('vendor_profiles')
          .insert(profileData);

      print('✅ Perfil de vendedor creado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error creando perfil de vendedor: $e');
      return false;
    }
  }

  /// Actualizar perfil de vendedor
  Future<bool> updateVendorProfile(VendorProfile profile) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('🏪 Actualizando perfil de vendedor: ${profile.companyName}');

      final profileData = profile.toJson();
      // Remover campos que no se deben actualizar
      profileData.remove('id');
      profileData.remove('user_id');
      profileData.remove('created_at');
      profileData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('vendor_profiles')
          .update(profileData)
          .eq('id', profile.id);

      if (_currentProfile?.id == profile.id) {
        _currentProfile = profile;
        notifyListeners();
      }

      print('✅ Perfil de vendedor actualizado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando perfil de vendedor: $e');
      return false;
    }
  }

  /// Obtener todos los perfiles de vendedor (para admin)
  Future<List<VendorProfile>> getAllVendorProfiles() async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return [];
      }

      print('🏪 Cargando todos los perfiles de vendedor...');

      final response = await _client
          .from('vendor_profiles')
          .select('*')
          .order('created_at', ascending: false);

      final profiles = response.map<VendorProfile>((data) => 
          VendorProfile.fromJson(data)).toList();

      print('✅ ${profiles.length} perfiles de vendedor cargados');
      return profiles;
    } catch (e) {
      print('❌ Error cargando perfiles de vendedor: $e');
      return [];
    }
  }

  /// Obtener perfiles de vendedor verificados
  Future<List<VendorProfile>> getVerifiedVendorProfiles() async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return [];
      }

      print('🏪 Cargando vendedores verificados...');

      final response = await _client
          .from('vendor_profiles')
          .select('*')
          .eq('is_verified', true)
          .order('rating_average', ascending: false);

      final profiles = response.map<VendorProfile>((data) => 
          VendorProfile.fromJson(data)).toList();

      print('✅ ${profiles.length} vendedores verificados cargados');
      return profiles;
    } catch (e) {
      print('❌ Error cargando vendedores verificados: $e');
      return [];
    }
  }

  /// Verificar vendedor (admin only)
  Future<bool> verifyVendor(String vendorId) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('🏪 Verificando vendedor: $vendorId');

      final response = await _client
          .from('vendor_profiles')
          .update({
            'is_verified': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);

      print('✅ Vendedor verificado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error verificando vendedor: $e');
      return false;
    }
  }

  /// Actualizar calificación promedio del vendedor
  Future<bool> updateVendorRating(String vendorId, double newRating, int totalRatings) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('⭐ Actualizando calificación del vendedor: $vendorId');

      final response = await _client
          .from('vendor_profiles')
          .update({
            'rating_average': newRating,
            'total_ratings': totalRatings,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);

      print('✅ Calificación actualizada exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando calificación: $e');
      return false;
    }
  }

  /// Incrementar ventas del vendedor
  Future<bool> incrementVendorSales(String vendorId) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('📈 Incrementando ventas del vendedor: $vendorId');

      // Primero obtener el valor actual
      final currentResponse = await _client
          .from('vendor_profiles')
          .select('total_sales')
          .eq('id', vendorId)
          .single();

      final currentSales = currentResponse['total_sales'] ?? 0;
      final newSales = currentSales + 1;

      // Actualizar con el nuevo valor
      final response = await _client
          .from('vendor_profiles')
          .update({
            'total_sales': newSales,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);

      print('✅ Ventas incrementadas exitosamente');
      return true;
    } catch (e) {
      print('❌ Error incrementando ventas: $e');
      return false;
    }
  }

  /// Limpiar perfil actual
  void clearCurrentProfile() {
    _currentProfile = null;
    notifyListeners();
  }

  /// Verificar si un usuario tiene perfil de vendedor
  Future<bool> hasVendorProfile(String userId) async {
    try {
      if (_client == null) {
        return false;
      }

      final response = await _client
          .from('vendor_profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Error verificando perfil de vendedor: $e');
      return false;
    }
  }
}
