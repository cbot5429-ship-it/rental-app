import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property.dart';
import '../services/favorite_service.dart';
import '../services/message_service.dart';
import '../services/rental_request_service.dart';
import '../widgets/property_card.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isFavorite = false;
  bool _loadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    setState(() => _loadingFavorite = true);
    final isFav = await FavoriteService.isFavorite(widget.property.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _loadingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);
    try {
      await FavoriteService.toggle(widget.property.id);
    } catch (_) {
      if (mounted) setState(() => _isFavorite = !_isFavorite);
    }
  }

  Future<void> _messageOwner() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      _showSnackBar('Please sign in to message the owner');
      return;
    }
    if (widget.property.ownerId == uid) {
      _showSnackBar('You own this property!');
      return;
    }

    final convoId = await MessageService.getOrCreateConversation(
      propertyId: widget.property.id,
      ownerId: widget.property.ownerId,
    );

    if (convoId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: convoId,
            otherName: 'Property Owner',
          ),
        ),
      );
    }
  }

  Future<void> _shareProperty() async {
    final url = 'https://your-app.com/property/${widget.property.id}';
    await Share.share(
      'Check out this property: ${widget.property.title} - ${widget.property.formattedPrice}/month\n$url',
      subject: widget.property.title,
    );
  }

  Future<void> _openMap() async {
    final address = widget.property.address ?? '';
    final city = widget.property.city ?? '';
    final query = Uri.encodeComponent('$address, $city');
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not open map');
    }
  }

  Future<void> _requestRent() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Send Rental Request'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Message to owner (optional)',
            hintText: 'Introduce yourself...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
        ],
      ),
    );

    if (confirmed != true) return;

    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      _showSnackBar('Please sign in to send a request');
      return;
    }

    try {
      await RentalRequestService.submitRequest(
        propertyId: widget.property.id,
        ownerId: widget.property.ownerId,
        message: controller.text.trim().isEmpty ? null : controller.text.trim(),
      );
      if (mounted) _showSnackBar('Request sent!');
    } catch (e) {
      if (mounted) _showSnackBar('Could not send request: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final property = widget.property;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: property.hasImages
                  ? Image.network(
                      property.mainImageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(child: Icon(Icons.home_work, size: 64)),
                    ),
            ),
            actions: [
              IconButton(
                onPressed: _loadingFavorite ? null : _toggleFavorite,
                icon: _loadingFavorite
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : null),
              ),
              IconButton(onPressed: _shareProperty, icon: const Icon(Icons.share)),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: property.listingType == 'rent'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          property.listingTypeLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.formattedPrice,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.address ?? ''}, ${property.city ?? ''}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _FeatureChip(icon: Icons.bed_outlined, label: '${property.bedrooms ?? 0} Beds'),
                      const SizedBox(width: 16),
                      _FeatureChip(icon: Icons.bathtub_outlined, label: '${property.bathrooms ?? 0} Baths'),
                      const SizedBox(width: 16),
                      _FeatureChip(icon: Icons.category_outlined, label: property.propertyType ?? 'N/A'),
                      const SizedBox(width: 16),
                      _FeatureChip(icon: Icons.chair_outlined, label: property.furnishingLabel),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (property.amenities?.isNotEmpty == true) ...[
                    Text('Amenities', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.amenities!.map((amenity) => Chip(
                        label: Text(amenity),
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(property.description ?? 'No description available', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openMap,
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Open Map'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _messageOwner,
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Message Owner'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareProperty,
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share Property'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _requestRent,
                          icon: const Icon(Icons.assignment_turned_in),
                          label: const Text('Request to Rent'),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}