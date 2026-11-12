import 'package:supabase_flutter/supabase_flutter.dart';

class MaintenanceService {
  static final _db = Supabase.instance.client;

  static Future<void> submitRequest({
    required String propertyId,
    required String ownerId,
    required String issue,
  }) async {
    final uid = _db.auth.currentUser!.id;
    await _db.from('maintenance_requests').insert({
      'property_id': propertyId,
      'client_id': uid,
      'owner_id': ownerId,
      'issue': issue,
    });
  }

  static Future<List<Map<String, dynamic>>> getOwnerRequests() async {
    final uid = _db.auth.currentUser!.id;
    return await _db
        .from('maintenance_requests')
        .select('*, properties(title), profiles!maintenance_requests_client_id_fkey(full_name)')
        .eq('owner_id', uid)
        .order('created_at', ascending: false);
  }

  static Future<void> resolveRequest(String requestId) async {
    await _db.from('maintenance_requests').update({'status': 'resolved'}).eq('id', requestId);
  }
}