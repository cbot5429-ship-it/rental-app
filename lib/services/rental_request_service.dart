import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_service.dart';

class RentalRequestService {
  static Future<void> submitRequest({
    required String propertyId,
    required String ownerId,
    String? message,
  }) async {
    final uid = BaseService.currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    await BaseService.db.from('rental_requests').insert({
      'property_id': propertyId,
      'client_id': uid,
      'owner_id': ownerId,
      'message': message,
      'status': 'pending',
    });
  }

  static Future<List<Map<String, dynamic>>> myRequests() async {
    final uid = BaseService.currentUserId;
    if (uid == null) return [];

    return await BaseService.db
        .from('rental_requests')
        .select('''
          id, property_id, client_id, owner_id, message, status, created_at,
          properties(title, city, price_per_month, images)
        ''')
        .eq('client_id', uid)
        .order('created_at', ascending: false);
  }

  static Future<List<Map<String, dynamic>>> incomingRequests() async {
    final uid = BaseService.currentUserId;
    if (uid == null) return [];

    return await BaseService.db
        .from('rental_requests')
        .select('''
          id, property_id, client_id, owner_id, message, status, created_at,
          properties(title, city, price_per_month, images),
          client:profiles!rental_requests_client_id_fkey(full_name)
        ''')
        .eq('owner_id', uid)
        .order('created_at', ascending: false);
  }

  static Future<void> updateStatus(String requestId, String status) async {
    final uid = BaseService.currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    await BaseService.db
        .from('rental_requests')
        .update({'status': status})
        .eq('id', requestId)
        .eq('owner_id', uid);
  }
}