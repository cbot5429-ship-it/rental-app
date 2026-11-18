import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_service.dart';

class ReviewService {
  static Future<void> submitReview({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    final uid = BaseService.currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    await BaseService.db.from('reviews').insert({
      'property_id': propertyId,
      'reviewer_id': uid,
      'rating': rating,
      'comment': comment,
    });
  }

  static Future<List<Map<String, dynamic>>> getForProperty(String propertyId) async {
    return await BaseService.db
        .from('reviews')
        .select('''
          id, property_id, reviewer_id, rating, comment, created_at,
          reviewer:profiles!reviews_reviewer_id_fkey(full_name, avatar_url)
        ''')
        .eq('property_id', propertyId)
        .order('created_at', ascending: false);
  }

  static Future<double> getAverageRating(String propertyId) async {
    final response = await BaseService.db
        .from('reviews')
        .select('rating')
        .eq('property_id', propertyId);

    if (response.isEmpty) return 0.0;

    final sum = response.fold<int>(0, (sum, item) => sum + (item['rating'] as int));
    return sum / response.length;
  }
}