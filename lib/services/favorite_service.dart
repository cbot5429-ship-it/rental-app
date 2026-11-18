import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property.dart';
import 'base_service.dart';

class FavoriteService {
  static Future<bool> isFavorite(String propertyId) async {
    final uid = BaseService.currentUserId;
    if (uid == null) return false;
    final row = await BaseService.db
        .from('favorites')
        .select('property_id')
        .eq('user_id', uid)
        .eq('property_id', propertyId)
        .maybeSingle();
    return row != null;
  }

  static Future<void> toggle(String propertyId) async {
    final uid = BaseService.currentUserId;
    if (uid == null) return;

    final exists = await isFavorite(propertyId);
    if (exists) {
      await BaseService.db.from('favorites').delete().eq('user_id', uid).eq('property_id', propertyId);
    } else {
      await BaseService.db.from('favorites').insert({'user_id': uid, 'property_id': propertyId});
    }
  }

  static Future<List<Property>> myFavorites() async {
    final uid = BaseService.currentUserId;
    if (uid == null) return [];

    final response = await BaseService.db
        .from('favorites')
        .select('created_at, properties(*)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    final List<Property> properties = [];
    for (final row in response) {
      final propertyJson = row['properties'];
      if (propertyJson != null) {
        properties.add(Property.fromJson(propertyJson));
      }
    }
    return properties;
  }
}