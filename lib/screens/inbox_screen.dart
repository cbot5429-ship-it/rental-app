// Enhanced Inbox Screen with modern chat UI, avatars, and message grouping
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart' show supabase;
import '../services/message_service.dart';
import 'chat_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_avatar.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  final Map<String, bool> _unreadCounts = {};

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _setupRealTimeUpdates();
  }

  Future<void> _loadConversations() async {
    final conversations = await MessageService.myConversations();
    if (mounted) {
      setState(() {
        _future = Future.value(conversations);
        for (final conv of conversations) {
          _unreadCounts[conv['id']] = (conv['unread_count'] ?? 0) > 0;
        }
      });
    }
  }

  void _setupRealTimeUpdates() {
    // Listen for new messages and updates
    supabase.channel('messages').on('INSERT', (payload) {
      if (mounted) {
        final conversationId = payload['conversation_id'];
        setState(() {
          _unreadCounts[conversationId] = true;
        });
      }
    }).subscribe();
  }

  Future<void> _markAsRead(String conversationId) async {
    await MessageService.markRead(conversationId);
    if (mounted) {
      setState(() {
        _unreadCounts[conversationId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyTheme = theme.extension<PropertyThemeExtension>()!;
    final uid = supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => _showSearch(),
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No messages yet.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16)),
                ],
              ),
            );
          }
          return Column(
            children: [
              // Filter tabs
              _buildFilterTabs(theme),
              const SizedBox(height: AppSpacing.sm),
              // Conversations list
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final conversation = items[i];
                    return _buildConversationItem(theme, conversation, uid);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: AppFAB.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewMessageScreen()),
        ),
        icon: Icons.edit,
        label: 'New Message',
        backgroundColor: propertyTheme.primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFilterTabs(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          _buildFilterChip(theme, 'All', true, () {}),
          const SizedBox(width: AppSpacing.md),
          _buildFilterChip(theme, 'Unread', false, () {}),
          const SizedBox(width: AppSpacing.md),
          _buildFilterChip(theme, 'Requests', false, () {}),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem(ThemeData theme, Map<String, dynamic> conversation, String uid) {
    final isClient = conversation['client_id'] == uid;
    final otherUser = isClient ? conversation['owner'] : conversation['client'];
    final otherName = otherUser?['full_name'] ?? 'User';
    final propertyTitle = conversation['properties']?['title'] ?? 'Property';
    final lastMessage = conversation['last_message'] ?? '';
    final lastMessageTime = DateTime.parse(conversation['updated_at']).toLocal();
    final timeString = DateFormat.Hm().format(lastMessageTime);
    final isUnread = _unreadCounts[conversation['id']] ?? false;
    final messagePreview = lastMessage.isNotEmpty ? lastMessage : 'No messages yet';
    final avatarColor = isClient ? Colors.blue : Colors.green;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversation['id'],
              otherName: otherName,
              otherUser: otherUser,
              property: conversation['properties'],
            ),
          ),
        ).then((_) => _markAsRead(conversation['id']));
      },
      child: AppCard.level1(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Avatar with status indicator
            Stack(
              children: [
                AppAvatar(
                  text: otherName.isNotEmpty ? otherName[0] : '?',
                  size: 48,
                  backgroundColor: avatarColor.withOpacity(0.1),
                  textColor: avatarColor,
                ),
                if (isUnread)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          otherName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NEW',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    propertyTitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    messagePreview,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUnread ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              children: [
                Text(
                  timeString,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                if (conversation['unread_count'] > 0)
                  Text(
                    '${conversation['unread_count']} new',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSearch() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: TextEditingController(),
              label: 'Search conversations',
              hint: 'Search by name or property...',
              prefixIcon: Icons.search_outlined,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: 'Search',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
