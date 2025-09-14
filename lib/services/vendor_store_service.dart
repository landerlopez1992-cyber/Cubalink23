import 'package:cubalink23/models/vendor_store.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendorStoreService {
  static final VendorStoreService _instance = VendorStoreService._internal();
  factory VendorStoreService() => _instance;
  VendorStoreService._internal();

  SupabaseClient? get _client => SupabaseConfig.safeClient;

  /// Obtener todas las tiendas de vendedores activas
  Future<List<VendorStore>> getAllVendorStores() async {
    try {
      if (_client == null) {
        print('❌ Supabase client no disponible');
        return [];
      }

      final response = await _client!
          .from('vendor_stores')
          .select('*')
          .eq('is_active', true)
          .order('rating', ascending: false);

      final List<VendorStore> stores = response
          .map<VendorStore>((json) => VendorStore.fromJson(json))
          .toList();

      print('✅ Tiendas de vendedores cargadas: ${stores.length}');
      return stores;
    } catch (e) {
      print('❌ Error cargando tiendas de vendedores: $e');
      return [];
    }
  }

  /// Obtener una tienda específica por ID
  Future<VendorStore?> getVendorStoreById(String storeId) async {
    try {
      if (_client == null) {
        print('❌ Supabase client no disponible');
        return null;
      }

      final response = await _client!
          .from('vendor_stores')
          .select('*')
          .eq('id', storeId)
          .eq('is_active', true)
          .single();

      final store = VendorStore.fromJson(response);
      print('✅ Tienda cargada: ${store.name}');
      return store;
    } catch (e) {
      print('❌ Error cargando tienda: $e');
      return null;
    }
  }

  /// Obtener tiendas por vendedor
  Future<List<VendorStore>> getStoresByVendor(String vendorId) async {
    try {
      if (_client == null) {
        print('❌ Supabase client no disponible');
        return [];
      }

      final response = await _client!
          .from('vendor_stores')
          .select('*')
          .eq('vendor_id', vendorId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final List<VendorStore> stores = response
          .map<VendorStore>((json) => VendorStore.fromJson(json))
          .toList();

      print('✅ Tiendas del vendedor cargadas: ${stores.length}');
      return stores;
    } catch (e) {
      print('❌ Error cargando tiendas del vendedor: $e');
      return [];
    }
  }

  /// Crear una nueva tienda
  Future<VendorStore?> createVendorStore(VendorStore store) async {
    try {
      if (_client == null) {
        print('❌ Supabase client no disponible');
        return null;
      }

      final response = await _client!
          .from('vendor_stores')
          .insert(store.toJson())
          .select()
          .single();

      final newStore = VendorStore.fromJson(response);
      print('✅ Tienda creada: ${newStore.name}');
      return newStore;
    } catch (e) {
      print('❌ Error creando tienda: $e');
      return null;
    }
  }

  /// Actualizar una tienda
  Future<VendorStore?> updateVendorStore(VendorStore store) async {
    try {
      if (_client == null) {
        print('❌ Supabase client no disponible');
        return null;
      }

      final response = await _client!
          .from('vendor_stores')
          .update(store.toJson())
          .eq('id', store.id)
          .select()
          .single();

      final updatedStore = VendorStore.fromJson(response);
      print('✅ Tienda actualizada: ${updatedStore.name}');
      return updatedStore;
    } catch (e) {
      print('❌ Error actualizando tienda: $e');
      return null;
    }
  }

  /// Eliminar una tienda (marcar como inactiva)
  Future<bool> deleteVendorStore(String storeId) async {
    try {
      if (_client == null) {
        print('❌ Supabase client no disponible');
        return false;
      }

      await _client!
          .from('vendor_stores')
          .update({'is_active': false})
          .eq('id', storeId);

      print('✅ Tienda eliminada: $storeId');
      return true;
    } catch (e) {
      print('❌ Error eliminando tienda: $e');
      return false;
    }
  }

  /// Buscar tiendas por nombre
  Future<List<VendorStore>> searchVendorStores(String query) async {
    try {
      if (_client == null) {
        print('❌ Supabase client no disponible');
        return [];
      }

      final response = await _client!
          .from('vendor_stores')
          .select('*')
          .eq('is_active', true)
          .ilike('name', '%$query%')
          .order('rating', ascending: false);

      final List<VendorStore> stores = response
          .map<VendorStore>((json) => VendorStore.fromJson(json))
          .toList();

      print('✅ Tiendas encontradas: ${stores.length}');
      return stores;
    } catch (e) {
      print('❌ Error buscando tiendas: $e');
      return [];
    }
  }

  /// Obtener tiendas por categoría
  Future<List<VendorStore>> getStoresByCategory(String category) async {
    try {
      if (_client == null) {
        print('❌ Supabase client no disponible');
        return [];
      }

      final response = await _client!
          .from('vendor_stores')
          .select('*')
          .eq('is_active', true)
          .contains('categories', [category])
          .order('rating', ascending: false);

      final List<VendorStore> stores = response
          .map<VendorStore>((json) => VendorStore.fromJson(json))
          .toList();

      print('✅ Tiendas por categoría cargadas: ${stores.length}');
      return stores;
    } catch (e) {
      print('❌ Error cargando tiendas por categoría: $e');
      return [];
    }
  }
}
