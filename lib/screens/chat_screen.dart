import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart' show supabase;
import '../services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherName;
  const ChatScreen({super.key, required this.conversationId, required this.otherName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  late final StreamSubscription<List<Map<String, dynamic>>> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', widget.conversationId)
        .listen((rows) {
      _sortMessages(rows);
    });
  }

  void _sortMessages(List<Map<String, dynamic>> rows) {
    final sorted = List<Map<String, dynamic>>.from(rows);
    sorted.sort((a, b) {
      final timeA = DateTime.tryParse('${a['created_at']}') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = DateTime.tryParse('${b['created_at']}') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeA.compareTo(timeB);
    });

    if (!mounted) return;
    setState(() => _messages = sorted);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    try {
      await MessageService.send(widget.conversationId, text);
    } catch (e) {
      if (!mounted) return;
      _ctrl.text = text;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message not sent: $e')));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = supabase.auth.currentUser?.id;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.otherName), centerTitle: true),
        body: const Center(child: Text('Sign in to view this conversation.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherName), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final mine = m['sender_id'] == uid;
                final time = (DateTime.tryParse('${m['created_at']}') ?? DateTime.now()).toLocal();
                final timeString = DateFormat.jm().format(time);

                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: mine
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(mine ? 16 : 0),
                        bottomRight: Radius.circular(mine ? 0 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          m['body'] ?? '',
                          style: TextStyle(
                            color: mine ? Colors.white : (isDark ? Colors.white : Colors.black87),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeString,
                          style: TextStyle(
                            color: mine ? Colors.white70 : Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}