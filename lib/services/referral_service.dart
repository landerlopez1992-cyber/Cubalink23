import 'package:cubalink23/models/user.dart' as app_user;
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class ReferralService {
  static ReferralService? _instance;
  static ReferralService get instance => _instance ??= ReferralService._();
  
  ReferralService._();
  
  final SupabaseClient _client = SupabaseConfig.client;
  static const double REFERRAL_REWARD = 5.0; // $5 USD de recompensa
  
  // Generar código de referido único para un usuario
  String _generateReferralCode(String userName) {
    final random = Random();
    final suffix = random.nextInt(9999).toString().padLeft(4, '0');
    final prefix = userName.length >= 3 
        ? userName.substring(0, 3).toUpperCase()
        : userName.toUpperCase().padRight(3, 'X');
    return '\$prefix\$suffix';
  }
  
  // Crear código de referido para usuario existente si no tiene uno
  Future<String> createReferralCode(String userId, String userName) async {
    try {
      // Verificar si ya tiene código
      final userResponse = await _client
          .from('users')
          .select('referral_code')
          .eq('id', userId)
          .maybeSingle();
      
      if (userResponse != null && userResponse['referral_code'] != null && userResponse['referral_code'].toString().isNotEmpty) {
        return userResponse['referral_code'];
      }
      
      // Generar código único
      String referralCode;
      bool isUnique = false;
      int attempts = 0;
      
      do {
        referralCode = _generateReferralCode(userName);
        
        // Verificar si ya existe
        final existingUserResponse = await _client
            .from('users')
            .select('id')
            .eq('referral_code', referralCode);
            
        isUnique = existingUserResponse.isEmpty;
        attempts++;
        
        if (attempts > 20) { // Failsafe
          referralCode = '\${userName.toUpperCase()}\${DateTime.now().millisecondsSinceEpoch}';
          break;
        }
      } while (!isUnique);
      
      // Actualizar el usuario con el código
      await _client.from('users').update({
        'referral_code': referralCode,
        'has_used_service': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      print('✅ Código de referido creado: \$referralCode para usuario \$userId');
      return referralCode;
      
    } catch (e) {
      print('❌ Error creando código de referido: \$e');
      throw Exception('Error al generar código de referido');
    }
  }
  
  // TODO: Migrate all other methods to use Supabase
  // For now, add basic stub methods to fix compilation
  
  Future<app_user.User?> findUserByReferralCode(String referralCode) async {
    // TODO: Implement Supabase search
    return null;
  }
  
  Future<void> processReferral(String referralCode, String newUserId) async {
    // TODO: Implement referral processing
    print('Processing referral: \$referralCode for user \$newUserId');
  }
  
  Future<Map<String, dynamic>> getReferralStats(String userId) async {
    try {
      print('📊 Obteniendo estadísticas de referidos para usuario: $userId');
      
      // Get user's referral data
      final userResponse = await _client
          .from('users')
          .select('referral_code, id, name')
          .eq('id', userId)
          .maybeSingle();
      
      if (userResponse == null) {
        print('❌ Usuario no encontrado');
        return {
          'totalReferred': 0,
          'totalRewards': 0.0,
          'referralCode': '',
          'referredUsers': [],
          'rewardHistory': [],
        };
      }
      
      String referralCode = userResponse['referral_code'] ?? '';
      
      // If user doesn't have referral code, create one
      if (referralCode.isEmpty) {
        print('📝 Creando código de referido para usuario...');
        referralCode = await createReferralCode(userId, userResponse['name'] ?? 'Usuario');
      }
      
      // Get users referred by this user
      final referredUsersResponse = await _client
          .from('users')
          .select('id, name, email, created_at, has_used_service')
          .eq('referred_by', userId);
      
      final referredUsers = referredUsersResponse;
      final totalReferred = referredUsers.length;
      
      // Get reward history
      final rewardHistoryResponse = await _client
          .from('referral_rewards')
          .select('amount, created_at, referred_user_name')
          .eq('referrer_user_id', userId)
          .order('created_at', ascending: false);
      
      final rewardHistory = rewardHistoryResponse;
      final totalRewards = rewardHistory.fold<double>(0.0, (sum, reward) => sum + (reward['amount']?.toDouble() ?? 0.0));
      
      print('✅ Estadísticas obtenidas: $totalReferred referidos, \$${totalRewards.toStringAsFixed(2)} ganados');
      
      return {
        'totalReferred': totalReferred,
        'totalRewards': totalRewards,
        'referralCode': referralCode,
        'referredUsers': referredUsers.map((user) => {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'registrationDate': user['created_at'],
          'hasUsedService': user['has_used_service'] ?? false,
        }).toList(),
        'rewardHistory': rewardHistory.map((reward) => {
          'amount': reward['amount']?.toDouble() ?? 0.0,
          'date': reward['created_at'],
          'referredUserName': reward['referred_user_name'],
        }).toList(),
      };
      
    } catch (e) {
      print('❌ Error obteniendo estadísticas de referidos: $e');
      return {
        'totalReferred': 0,
        'totalRewards': 0.0,
        'referralCode': '',
        'referredUsers': [],
        'rewardHistory': [],
      };
    }
  }
}