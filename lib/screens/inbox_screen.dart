import 'package:flutter/material.dart';
import '../main.dart' show supabase; // 👈 Added this import
import '../services/message_service.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});
  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = MessageService.myConversations();
  }

  @override
  Widget build(BuildContext context) {
    final uid = supabase.auth.currentUser!.id; // 👈 Changed to use global supabase

    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No messages yet.'));

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final c = items[i];
              final isClient = c['client_id'] == uid;
              final otherName = isClient ? (c['owner']?['full_name'] ?? 'Owner') : (c['client']?['full_name'] ?? 'Client');
              final propertyTitle = c['properties']?['title'] ?? 'Property';

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(propertyTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ChatScreen(conversationId: c['id'], otherName: otherName),
                )),
              );
            },
          );
        },
      ),
    );
  }
}