import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_service.dart';

class MessageService {
  static Future<String?> getOrCreateConversation({
    required String propertyId,
    required String ownerId,
  }) async {
    final uid = BaseService.currentUserId;
    if (uid == null) return null;

    final existing = await BaseService.db
        .from('conversations')
        .select('id')
        .eq('property_id', propertyId)
        .eq('client_id', uid)
        .eq('owner_id', ownerId)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    final created = await BaseService.db.from('conversations').insert({
      'property_id': propertyId,
      'client_id': uid,
      'owner_id': ownerId,
    }).select('id').single();

    return created['id'] as String;
  }

  static Future<List<Map<String, dynamic>>> myConversations() async {
    final uid = BaseService.currentUserId;
    if (uid == null) return [];

    return await BaseService.db
        .from('conversations')
        .select('''
          id, property_id, client_id, owner_id, created_at,
          properties(title, images),
          client:profiles!conversations_client_id_fkey(full_name),
          owner:profiles!conversations_owner_id_fkey(full_name)
        ''')
        .or('client_id.eq.$uid,owner_id.eq.$uid')
        .order('created_at', ascending: false);
  }

  static Future<void> send(String conversationId, String text) async {
    final uid = BaseService.currentUserId;
    if (uid == null) return;
    await BaseService.db.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': uid,
      'body': text,
    });
  }

  static Future<void> markRead(String conversationId) async {
    final uid = BaseService.currentUserId;
    if (uid == null) return;
    await BaseService.db
        .from('messages')
        .update({'read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', uid);
  }
}