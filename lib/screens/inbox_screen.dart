import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart' show supabase;
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
    final uid = supabase.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No messages yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = items[i];
              final isClient = c['client_id'] == uid;
              final otherName = isClient 
                  ? (c['owner']?['full_name'] ?? 'Owner') 
                  : (c['client']?['full_name'] ?? 'Client');
              final propertyTitle = c['properties']?['title'] ?? 'Property';
              
              // Format the conversation start time
              final time = DateTime.parse(c['created_at']).toLocal();
              final timeString = DateFormat.MMMd().add_jm().format(time); // e.g., "Oct 24, 10:30 AM"

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        otherName, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      timeString,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Regarding: $propertyTitle', 
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13),
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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