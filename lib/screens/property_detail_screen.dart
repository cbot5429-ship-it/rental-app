import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../widgets/reviews_section.dart';
import '../main.dart' show supabase;
import '../services/message_service.dart';
import '../services/rental_request_service.dart'
import '../services/maintenance_service.dart';
import 'chat_screen.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_button.dart'
import '../widgets/common/image_carousel.dart'
import '../theme/app_theme.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _currentPage = 0;
  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyTheme = theme.extension<PropertyThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;
    final images = (widget.property['images'] as List?)?.cast<String>() ?? [];
    final listingType = widget.property['listing_type'] ?? 'rent';
    final priceLabel = listingType == 'buy' ? 'Price' : 'Rent / month';
    final isRent = listingType == 'rent';
    final amenities = _getAmenities();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Image Gallery with Hero
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? Colors.black : theme.colorScheme.primary,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: images.isEmpty
                  ? Container(
                      color: Colors.grey.shade800,
                      child: Center(
                        child: Icon(Icons.home_work, size: 80, color: Colors.white54),
                      ),
                    )
                  : Stack(
                      children: [
                        // PageView for images
                        PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          itemBuilder: (_, i) => Container(
                            color: Colors.black,
                            child: CachedNetworkImage(
                              imageUrl: images[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              memCacheWidth: 1200,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(color: theme.colorScheme.primary),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade800,
                                child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                        // Navigation arrows
                        if (images.length > 1) ...[
                          Positioned(
                            left: AppSpacing.md,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: _NavButton(
                                icon: Icons.chevron_left,
                                onPressed: _currentPage > 0
                                    ? () {}
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            right: AppSpacing.md,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: _NavButton(
                                icon: Icons.chevron_right,
                                onPressed: _currentPage < images.length - 1
                                    ? () {}
                                    : null,
                              ),
                            ),
                          ),
                        ],
                        // Page indicator
                        if (images.length > 1)
                          Positioned(
                            bottom: AppSpacing.lg,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(images.length, (index) {
                                return AnimatedContainer(
                                  duration: AppDuration.fast,
                                  curve: AppCurves.standard,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentPage == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentPage == index ? Colors.white : Colors.white54,
                                    borderRadius: BorderRadius.circular(AppRadius.round),
                                  ),
                                );
                              }),
                            ),
                          ),
                        // Type badge
                        Positioned(
                          top: AppSpacing.lg + MediaQuery.of(context).padding.top,
                          left: AppSpacing.lg,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isRent ? propertyTheme.rentColor : propertyTheme.saleColor,
                              borderRadius: BorderRadius.circular(AppRadius.round),
                              boxShadow: AppElevation.level2,
                            ),
                            child: Text(
                              listingType.toUpperCase(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and listing type
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.property['title'] ?? '',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.round),
                        ),
                        child: Text(
                          listingType.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: theme.colorScheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${widget.property['city'] ?? ''}${widget.property['pincode'] != null ? ' - ${widget.property['pincode']}' : ''}',
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatPrice(widget.property['price_per_month']),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: propertyTheme.priceColor,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        priceLabel,
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Feature Grid
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: AppElevation.level1,
                      border: Border.all(color: theme.dividerColor, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _FeatureItem(icon: Icons.bed_outlined, value: '${widget.property['bedrooms'] ?? 0}', label: 'Bedrooms'),
                        _VerticalDivider(),
                        _FeatureItem(icon: Icons.bathtub_outlined, value: '${widget.property['bathrooms'] ?? 0}', label: 'Bathrooms'),
                        _VerticalDivider(),
                        _FeatureItem(
                          icon: Icons.apartment_outlined,
                          value: widget.property['property_type'] ?? 'N/A',
                          label: 'Type',
                        ),
                        _VerticalDivider(),
                        _FeatureItem(
                          icon: Icons.chair_outlined,
                          value: _formatFurnishing(widget.property['furnishing']),
                          label: 'Furnishing',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Amenities
                  if (amenities.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amenities', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        TextButton(
                          onPressed: () {},
                          child: Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: amenities.map((amenity) => _AmenityChip(icon: amenity.icon, label: amenity.label)).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Description
                  Text('Description', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.md),
                  AnimatedCrossFade(
                    firstChild: Text(
                      widget.property['description'] ?? 'No description provided.',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, color: theme.colorScheme.onSurface),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    secondChild: Text(
                      widget.property['description'] ?? 'No description provided.',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, color: theme.colorScheme.onSurface),
                    ),
                    crossFadeState: _showFullDescription ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: AppDuration.normal,
                  ),
                  if ((widget.property['description'] ?? '').length > 200) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () => setState(() => _showFullDescription = !_showFullDescription),
                      child: Text(_showFullDescription ? 'Show Less' : 'Read More'),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Map placeholder
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: theme.dividerColor, width: 0.5),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Map View',
                                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${widget.property['city'] ?? ''}, ${widget.property['pincode'] ?? ''}',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: AppSpacing.md,
                          right: AppSpacing.md,
                          child: AppOutlineButton(
                            label: 'Open Map',
                            onPressed: () {},
                            fullWidth: false,
                            icon: Icons.open_in_new,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Owner Contact Card
                  _OwnerContactCard(property: widget.property),

                  const SizedBox(height: AppSpacing.xl),

                  // Action Buttons (Sticky on scroll)
                  _ActionButtons(property: widget.property, listingType: listingType),

                  const SizedBox(height: AppSpacing.xl),

                  // Reviews
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.xl),
                  ReviewsSection(propertyId: widget.property['id']),

                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
      // Sticky bottom action bar for rent properties
      bottomNavigationBar: listingType != 'buy'
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: AppOutlineButton(
                        label: 'Message Owner',
                        onPressed: () async {
                          final ownerId = widget.property['owner_id'];
                          final uid = supabase.auth.currentUser!.id;
                          if (ownerId == uid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: const Text('You own this property!')),
                            );
                            return;
                          }
                          final convoId = await MessageService.getOrCreateConversation(
                            propertyId: widget.property['id'],
                            ownerId: ownerId,
                          );
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ChatScreen(conversationId: convoId, otherName: 'Owner')),
                          );
                        },
                        icon: Icons.chat_bubble_outline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppPrimaryButton(
                        label: 'Request to Rent',
                        onPressed: () => _showRentRequestDialog(),
                        icon: Icons.assignment_turned_in,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  List<Amenity> _getAmenities() {
    // Mock amenities - in real app, fetch from property data
    return [
      Amenity(Icons.wifi, 'WiFi'),
      Amenity(Icons.ac_unit, 'AC'),
      Amenity(Icons.local_parking, 'Parking'),
      Amenity(Icons.kitchen, 'Kitchen'),
      Amenity(Icons.washer, 'Washer'),
      Amenity(Icons.pool, 'Pool'),
      Amenity(Icons.fitness_center, 'Gym'),
      Amenity(Icons.security, 'Security'),
      Amenity(Icons.elevator, 'Elevator'),
      Amenity(Icons.balcony, 'Balcony'),
    ];
  }

  String _formatFurnishing(String? furnishing) {
    switch (furnishing?.toLowerCase()) {
      case 'furnished':
        return 'Furnished';
      case 'semi':
        return 'Semi';
      case 'unfurnished':
        return 'Unfurnished';
      default:
        return 'N/A';
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '₹0';
    final numPrice = price is num ? price : num.tryParse(price.toString()) ?? 0;
    return '₹${numPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  Future<void> _showRentRequestDialog() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Send Rental Request'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Message to owner (optional)',
            hintText: 'Introduce yourself and mention your requirements...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
        ],
      ),
    );
    if (ok == true) {
      final uid = supabase.auth.currentUser!.id;
      if (widget.property['owner_id'] == uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('You own this property!')),
        );
        return;
      }
      await RentalRequestService.submitRequest(
        propertyId: widget.property['id'],
        ownerId: widget.property['owner_id'],
        message: ctrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Request sent!')),
        );
      }
    }
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.circle),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: enabled ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _FeatureItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(height: 48, width: 1, color: theme.dividerColor);
  }
}

class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.round),
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class Amenity {
  final IconData icon;
  final String label;
  const Amenity(this.icon, this.label);
}

class _OwnerContactCard extends StatelessWidget {
  final Map<String, dynamic> property;

  const _OwnerContactCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ownerName = property['owner_name'] ?? 'Property Owner';
    final ownerPhone = property['owner_phone'] ?? '+91 XXXXX XXXXX';

    return AppCardWithHeader(
      header: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, color: theme.colorScheme.onPrimaryContainer, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Listed by', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Text(ownerName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _ContactRow(icon: Icons.phone_outlined, label: 'Call', value: ownerPhone, onTap: () {}),
          const Divider(height: 1),
          _ContactRow(icon: Icons.message_outlined, label: 'Message', value: 'Chat with owner', onTap: () {}),
          const Divider(height: 1),
          _ContactRow(icon: Icons.schedule_outlined, label: 'Availability', value: 'Mon-Sat, 9AM-6PM', onTap: () {}),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 22),
      ),
      title: Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      subtitle: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Map<String, dynamic> property;
  final String listingType;

  const _ActionButtons({required this.property, required this.listingType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRent = listingType == 'rent';

    return Column(
      children: [
        if (isRent)
          AppPrimaryButton(
            label: 'Request to Rent',
            onPressed: () {
              // This will be handled by the bottom navigation bar
            },
            icon: Icons.assignment_turned_in,
            fullWidth: true,
          ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppOutlineButton(
                label: 'Message Owner',
                onPressed: () {},
                icon: Icons.chat_bubble_outline,
                fullWidth: true,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppOutlineButton(
                label: 'Share',
                onPressed: () {},
                icon: Icons.share_outlined,
                fullWidth: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppOutlineButton(
                label: 'Report Maintenance',
                onPressed: () => _showMaintenanceDialog(context),
                icon: Icons.build_outlined,
                fullWidth: true,
                borderColor: Colors.orange,
                textColor: Colors.orange,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppOutlineButton(
                label: 'Report Listing',
                onPressed: () => _showReportDialog(context),
                icon: Icons.flag_outlined,
                fullWidth: true,
                borderColor: Colors.red,
                textColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMaintenanceDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Maintenance Issue'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Describe the issue...', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              await MaintenanceService.submitRequest(
                propertyId: property['id'],
                ownerId: property['owner_id'],
                issue: ctrl.text.trim(),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Maintenance request sent!')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Listing'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Why are you reporting this?', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(context, true);
              await supabase.from('reports').insert({
                'property_id': property['id'],
                'reporter_id': supabase.auth.currentUser!.id,
                'reason': ctrl.text.trim(),
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Report submitted.')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}