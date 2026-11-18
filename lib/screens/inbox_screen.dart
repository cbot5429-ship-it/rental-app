import 'package:flutter/material.dart';
import '../services/message_service.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late Future<List<Map<String, dynamic>>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    setState(() {
      _conversationsFuture = MessageService.myConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadConversations, child: const Text('Retry')),
                ],
              ),
            );
          }
          final conversations = snapshot.data ?? [];
          if (conversations.isEmpty) {
            return const Center(child: Text('No conversations yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final convo = conversations[index];
              final property = convo['properties'] as Map<String, dynamic>?;
              final client = convo['client'] as Map<String, dynamic>?;
              final owner = convo['owner'] as Map<String, dynamic>?;

              final currentUserId = supabase.auth.currentUser?.id;
              final isClient = convo['client_id'] == currentUserId;
              final otherName = isClient ? owner?['full_name'] ?? 'Owner' : client?['full_name'] ?? 'Client';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: property?['images'] != null && (property!['images'] as List).isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            (property['images'] as List).first,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(Icons.home, color: theme.colorScheme.onPrimaryContainer),
                        ),
                  title: Text(property?['title'] ?? 'Property'),
                  subtitle: Text(otherName),
                  trailing: Text(
                    _formatTime(convo['created_at']),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          conversationId: convo['id'],
                          otherName: otherName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.tryParse(timestamp.toString());
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }
}