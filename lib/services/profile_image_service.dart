import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cubalink23/supabase/supabase_config.dart';

/// 🖼️ Servicio para manejar fotos de perfil de usuarios en Supabase Storage
class ProfileImageService {
  static ProfileImageService? _instance;
  static ProfileImageService get instance => _instance ??= ProfileImageService._();
  
  ProfileImageService._();
  
  final SupabaseClient _client = SupabaseConfig.client;
  final String _bucketName = 'user-profiles';
  
  /// Subir foto de perfil desde archivo
  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      print('📸 Subiendo foto de perfil para usuario: $userId');
      
      // Verificar que el usuario esté autenticado
      final currentUser = _client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        print('❌ Usuario no autenticado o IDs no coinciden');
        return null;
      }
      
      // Generar nombre de archivo único
      final fileName = 'profiles/$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Leer bytes del archivo
      final bytes = await imageFile.readAsBytes();
      
      // Subir archivo a Supabase Storage
      await _client.storage
          .from(_bucketName)
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true, // Permitir sobrescribir
          ));
      
      // Obtener URL pública
      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(fileName);
      
      print('✅ Foto de perfil subida exitosamente: $publicUrl');
      
      // Actualizar perfil del usuario en la base de datos
      await _updateUserProfilePhoto(userId, publicUrl);
      
      // Guardar en tabla profile_photos para backup
      await _saveProfilePhotoRecord(userId, publicUrl, fileName, bytes.length);
      
      return publicUrl;
      
    } catch (e) {
      print('❌ Error subiendo foto de perfil: $e');
      return null;
    }
  }
  
  /// Subir foto de perfil desde bytes (para web)
  Future<String?> uploadProfileImageFromBytes({
    required Uint8List bytes,
    required String userId,
  }) async {
    try {
      print('📸 Subiendo foto de perfil desde bytes para usuario: $userId');
      
      // Verificar que el usuario esté autenticado
      final currentUser = _client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        print('❌ Usuario no autenticado o IDs no coinciden');
        return null;
      }
      
      // Generar nombre de archivo único
      final fileName = 'profiles/$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Subir archivo a Supabase Storage
      await _client.storage
          .from(_bucketName)
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true, // Permitir sobrescribir
          ));
      
      // Obtener URL pública
      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(fileName);
      
      print('✅ Foto de perfil subida exitosamente: $publicUrl');
      
      // Actualizar perfil del usuario en la base de datos
      await _updateUserProfilePhoto(userId, publicUrl);
      
      // Guardar en tabla profile_photos para backup
      await _saveProfilePhotoRecord(userId, publicUrl, fileName, bytes.length);
      
      return publicUrl;
      
    } catch (e) {
      print('❌ Error subiendo foto de perfil: $e');
      return null;
    }
  }
  
  /// Eliminar foto de perfil actual
  Future<bool> deleteProfileImage(String userId) async {
    try {
      print('🗑️ Eliminando foto de perfil para usuario: $userId');
      
      // Verificar que el usuario esté autenticado
      final currentUser = _client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        print('❌ Usuario no autenticado o IDs no coinciden');
        return false;
      }
      
      // Obtener registro actual de foto
      final response = await _client
          .from('profile_photos')
          .select('filename')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null && response['filename'] != null) {
        // Eliminar archivo de Storage
        await _client.storage
            .from(_bucketName)
            .remove([response['filename']]);
        
        print('✅ Archivo eliminado de Storage');
      }
      
      // Limpiar URL del perfil del usuario
      await _client
          .from('users')
          .update({'profile_photo_url': null, 'profile_image_url': null})
          .eq('id', userId);
      
      // Eliminar registro de profile_photos
      await _client
          .from('profile_photos')
          .delete()
          .eq('user_id', userId);
      
      print('✅ Foto de perfil eliminada exitosamente');
      return true;
      
    } catch (e) {
      print('❌ Error eliminando foto de perfil: $e');
      return false;
    }
  }
  
  /// Obtener URL de foto de perfil actual
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('profile_photo_url, profile_image_url')
          .eq('id', userId)
          .maybeSingle();
      
      if (response != null) {
        return response['profile_photo_url'] ?? response['profile_image_url'];
      }
      
      return null;
    } catch (e) {
      print('❌ Error obteniendo URL de foto de perfil: $e');
      return null;
    }
  }
  
  /// Actualizar URL de foto en el perfil del usuario
  Future<void> _updateUserProfilePhoto(String userId, String photoUrl) async {
    try {
      await _client
          .from('users')
          .update({
            'profile_photo_url': photoUrl,
            'profile_image_url': photoUrl, // Mantener ambos campos por compatibilidad
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
      
      print('✅ Perfil de usuario actualizado con nueva foto');
    } catch (e) {
      print('❌ Error actualizando perfil de usuario: $e');
      rethrow;
    }
  }
  
  /// Guardar registro en tabla profile_photos
  Future<void> _saveProfilePhotoRecord(
    String userId,
    String supabaseUrl,
    String filename,
    int fileSize,
  ) async {
    try {
      await _client
          .from('profile_photos')
          .upsert({
            'user_id': userId,
            'supabase_url': supabaseUrl,
            'filename': filename,
            'file_size': fileSize,
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      print('✅ Registro de foto guardado en profile_photos');
    } catch (e) {
      print('❌ Error guardando registro de foto: $e');
      // No relanzar error ya que la foto se subió exitosamente
    }
  }
  
  /// Verificar si el bucket existe y está configurado
  Future<bool> checkBucketConfiguration() async {
    try {
      final buckets = await _client.storage.listBuckets();
      final profileBucket = buckets.firstWhere(
        (bucket) => bucket.name == _bucketName,
        orElse: () => throw Exception('Bucket no encontrado'),
      );
      
      print('✅ Bucket $_bucketName configurado correctamente');
      print('📊 Bucket público: ${profileBucket.public}');
      return true;
    } catch (e) {
      print('❌ Error verificando bucket $_bucketName: $e');
      return false;
    }
  }
  
  /// Obtener estadísticas de uso
  Future<Map<String, dynamic>> getUsageStats(String userId) async {
    try {
      final response = await _client
          .from('profile_photos')
          .select('file_size, created_at')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null) {
        return {
          'hasPhoto': true,
          'fileSize': response['file_size'] ?? 0,
          'uploadDate': response['created_at'],
        };
      }
      
      return {'hasPhoto': false};
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return {'hasPhoto': false};
    }
  }
}
