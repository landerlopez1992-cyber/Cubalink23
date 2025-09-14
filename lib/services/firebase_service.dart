// MIGRATED TO SUPABASE: Firebase service no longer needed
// This file is kept for compatibility but unused
// All functionality moved to lib/services/supabase_database_service.dart

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();
  
  // All Firebase operations have been migrated to Supabase
  // Use SupabaseDatabaseService instead
}