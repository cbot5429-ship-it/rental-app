import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService {
  static final _db = Supabase.instance.client;

  // Fetch all reviews for a property
  static Future<List<Map<String, dynamic>>> fetch(String propertyId) async {
    return await _db
        .from('reviews')
        .select('*, profiles(full_name, avatar_url)')
        .eq('property_id', propertyId)
        .order('created_at', ascending: false);
  }

  // Fetch the average rating summary
  static Future<Map<String, dynamic>?> summary(String propertyId) async {
    return await _db
        .from('property_ratings')
        .select()
        .eq('property_id', propertyId)
        .maybeSingle();
  }

  // Submit or update a review
  static Future<void> submit({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    final uid = _db.auth.currentUser!.id;
    await _db.from('reviews').upsert({
      'property_id': propertyId,
      'reviewer_id': uid,
      'rating': rating,
      'comment': comment,
    }, onConflict: 'property_id,reviewer_id');
  }
}