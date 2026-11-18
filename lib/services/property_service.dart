import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property.dart';
import 'base_service.dart';

class PropertyService {
  static Future<List<Property>> getAll({
    String? listingType,
    String? city,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? minBathrooms,
    String? propertyType,
    String? furnishing,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    var query = BaseService.db.from('properties').select();

    if (listingType != null) query = query.eq('listing_type', listingType);
    if (city != null) query = query.ilike('city', '%$city%');
    if (minPrice != null) query = query.gte('price_per_month', minPrice);
    if (maxPrice != null) query = query.lte('price_per_month', maxPrice);
    if (minBedrooms != null) query = query.gte('bedrooms', minBedrooms);
    if (minBathrooms != null) query = query.gte('bathrooms', minBathrooms);
    if (propertyType != null) query = query.eq('property_type', propertyType);
    if (furnishing != null) query = query.eq('furnishing', furnishing);

    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    } else {
      query = query.order('created_at', ascending: false);
    }

    if (limit != null) query = query.limit(limit);
    if (offset != null) query = query.range(offset, offset + (limit ?? 20) - 1);

    final response = await query;
    return (response as List).map((json) => Property.fromJson(json)).toList();
  }

  static Future<Property?> getById(String id) async {
    final response = await BaseService.db.from('properties').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return Property.fromJson(response);
  }

  static Future<List<Property>> getByOwner(String ownerId) async {
    final response = await BaseService.db
        .from('properties')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);
    return (response as List).map((json) => Property.fromJson(json)).toList();
  }

  static Future<Property> create(Property property) async {
    final uid = BaseService.currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    final response = await BaseService.db
        .from('properties')
        .insert({
          ...property.toJson(),
          'owner_id': uid,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    return Property.fromJson(response);
  }

  static Future<Property> update(String id, Map<String, dynamic> updates) async {
    final response = await BaseService.db
        .from('properties')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return Property.fromJson(response);
  }

  static Future<void> delete(String id) async {
    await BaseService.db.from('properties').delete().eq('id', id);
  }

  static Future<void> incrementViewCount(String id) async {
    await BaseService.db.rpc('increment_view_count', params: {'property_id': id});
  }

  static Future<List<Property>> search({
    required String query,
    String? listingType,
    int limit = 20,
  }) async {
    var q = BaseService.db.from('properties').select();

    if (listingType != null) q = q.eq('listing_type', listingType);

    q = q.or('title.ilike.%$query%,city.ilike.%$query%,description.ilike.%$query%');
    q = q.limit(limit).order('created_at', ascending: false);

    final response = await q;
    return (response as List).map((json) => Property.fromJson(json)).toList();
  }
}