import 'package:supabase_flutter/supabase_flutter.dart';

class RentalRequestService {
  static final _db = Supabase.instance.client;

  // 1. Client sends a request
  static Future<void> submitRequest({
    required String propertyId,
    required String ownerId,
    required String message,
  }) async {
    final uid = _db.auth.currentUser!.id;
    await _db.from('rental_requests').insert({
      'property_id': propertyId,
      'client_id': uid,
      'owner_id': ownerId,
      'message': message,
    });
  }

  // 2. Client views their sent requests
  static Future<List<Map<String, dynamic>>> mySentRequests() async {
    final uid = _db.auth.currentUser!.id;
    return await _db
        .from('rental_requests')
        .select('*, properties(title, images)')
        .eq('client_id', uid)
        .order('created_at', ascending: false);
  }

  // 3. Owner views incoming requests for their properties
  static Future<List<Map<String, dynamic>>> incomingRequests() async {
    final uid = _db.auth.currentUser!.id;
    return await _db
        .from('rental_requests')
        .select('*, properties(title), profiles!rental_requests_client_id_fkey(full_name)')
        .eq('owner_id', uid)
        .order('created_at', ascending: false);
  }

  // 4. Owner approves or rejects
  static Future<void> updateStatus(String requestId, String newStatus) async {
    await _db.from('rental_requests').update({'status': newStatus}).eq('id', requestId);
  }
}