import 'package:supabase_flutter/supabase_flutter.dart';

class MessageService {
  static final _db = Supabase.instance.client;

  // 1. Find an existing conversation or create a new one
  static Future<String> getOrCreateConversation({
    required String propertyId,
    required String ownerId,
  }) async {
    final uid = _db.auth.currentUser!.id;

    final existing = await _db
        .from('conversations')
        .select('id')
        .eq('property_id', propertyId)
        .eq('client_id', uid)
        .eq('owner_id', ownerId)
        .maybeSingle();
        
    if (existing != null) return existing['id'] as String;

    final created = await _db.from('conversations').insert({
      'property_id': propertyId,
      'client_id': uid,
      'owner_id': ownerId,
    }).select('id').single();
    
    return created['id'] as String;
  }

    // 2. Fetch all conversations for the Inbox screen
  static Future<List<Map<String, dynamic>>> myConversations() async {
    final uid = _db.auth.currentUser!.id;
    return await _db
        .from('conversations')
        // 👇 Added created_at here
        .select('id, property_id, client_id, owner_id, created_at, '
            'properties(title, images), '
            'client:profiles!conversations_client_id_fkey(full_name), '
            'owner:profiles!conversations_owner_id_fkey(full_name)')
        .or('client_id.eq.$uid,owner_id.eq.$uid')
        .order('created_at', ascending: false);
  }

  // 3. Send a message
  static Future<void> send(String convoId, String text) async {
    final uid = _db.auth.currentUser!.id;
    await _db.from('messages').insert({
      'conversation_id': convoId,
      'sender_id': uid,
      'body': text,
    });
  }
}