import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CredentialsStorageService {
  static const String _savedCredentialsKey = 'saved_credentials';
  static const String _saveCredentialsEnabledKey = 'save_credentials_enabled';
  
  // Guardar credenciales del usuario
  static Future<void> saveCredentials({
    required String identifier,
    required String password,
    required bool isEmailLogin,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Crear objeto con las credenciales
      final credentials = {
        'identifier': identifier,
        'password': password,
        'isEmailLogin': isEmailLogin,
        'savedAt': DateTime.now().toIso8601String(),
      };
      
      // Guardar como JSON
      await prefs.setString(_savedCredentialsKey, jsonEncode(credentials));
      await prefs.setBool(_saveCredentialsEnabledKey, true);
      
      print('✅ Credenciales guardadas exitosamente');
    } catch (e) {
      print('❌ Error guardando credenciales: $e');
    }
  }
  
  // Obtener credenciales guardadas
  static Future<Map<String, dynamic>?> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentialsJson = prefs.getString(_savedCredentialsKey);
      
      if (credentialsJson != null) {
        final credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
        print('✅ Credenciales recuperadas: ${credentials['identifier']}');
        return credentials;
      }
      
      return null;
    } catch (e) {
      print('❌ Error obteniendo credenciales: $e');
      return null;
    }
  }
  
  // Verificar si hay credenciales guardadas
  static Future<bool> hasSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_savedCredentialsKey);
    } catch (e) {
      print('❌ Error verificando credenciales: $e');
      return false;
    }
  }
  
  // Eliminar credenciales guardadas
  static Future<void> clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedCredentialsKey);
      await prefs.setBool(_saveCredentialsEnabledKey, false);
      print('✅ Credenciales eliminadas');
    } catch (e) {
      print('❌ Error eliminando credenciales: $e');
    }
  }
  
  // Verificar si el guardado está habilitado
  static Future<bool> isSaveCredentialsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_saveCredentialsEnabledKey) ?? false;
    } catch (e) {
      print('❌ Error verificando configuración: $e');
      return false;
    }
  }
  
  // Habilitar/deshabilitar guardado de credenciales
  static Future<void> setSaveCredentialsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_saveCredentialsEnabledKey, enabled);
      
      if (!enabled) {
        // Si se deshabilita, también eliminar las credenciales guardadas
        await clearSavedCredentials();
      }
      
      print('✅ Guardado de credenciales ${enabled ? 'habilitado' : 'deshabilitado'}');
    } catch (e) {
      print('❌ Error configurando guardado: $e');
    }
  }
}





