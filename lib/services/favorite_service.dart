import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  static final _db = Supabase.instance.client;

  static Future<bool> isFavorite(String propertyId) async {
    final uid = _db.auth.currentUser!.id;
    final row = await _db
        .from('favorites')
        .select('property_id')
        .eq('user_id', uid)
        .eq('property_id', propertyId)
        .maybeSingle();
    return row != null;
  }

  static Future<void> toggle(String propertyId) async {
    final uid = _db.auth.currentUser!.id;
    if (await isFavorite(propertyId)) {
      await _db.from('favorites').delete()
          .eq('user_id', uid).eq('property_id', propertyId);
    } else {
      await _db.from('favorites')
          .insert({'user_id': uid, 'property_id': propertyId});
    }
  }

  static Future<List<Map<String, dynamic>>> myFavorites() async {
    final uid = _db.auth.currentUser!.id;
    final rows = await _db
        .from('favorites')
        .select('created_at, properties(*)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return rows.map((r) => r['properties'] as Map<String, dynamic>).toList();
  }
}