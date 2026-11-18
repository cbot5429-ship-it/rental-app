import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BaseService {
  static SupabaseClient get db => Supabase.instance.client;

  static String? get currentUserId => db.auth.currentUser?.id;

  static bool get isAuthenticated => currentUserId != null;

  static Future<void> signOut() async {
    await db.auth.signOut();
  }
}