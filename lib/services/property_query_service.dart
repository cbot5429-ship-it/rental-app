import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_filter.dart';

class PropertyQueryService {
  static final _db = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> search(PropertyFilter f) async {
    var q = _db.from('properties').select().eq('is_available', true);

    if (f.city != null && f.city!.trim().isNotEmpty) {
      q = q.ilike('city', '%${f.city!.trim()}%');
    }
    if (f.minPrice != null) q = q.gte('price_per_month', f.minPrice!);
    if (f.maxPrice != null) q = q.lte('price_per_month', f.maxPrice!);
    if (f.minBedrooms != null) q = q.gte('bedrooms', f.minBedrooms!);
    if (f.minBathrooms != null) q = q.gte('bathrooms', f.minBathrooms!);
    if (f.propertyType != null) q = q.eq('property_type', f.propertyType!);
    if (f.furnishing != null) q = q.eq('furnishing', f.furnishing!);

    return await q.order('created_at', ascending: false);
  }
}