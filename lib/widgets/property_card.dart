import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../theme/app_theme.dart';
import 'common/app_card.dart';
import 'common/app_button.dart';

class PropertyCard extends StatefulWidget {
  final Map<String, dynamic> property;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool showFavorite;
  final bool isSelected;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onFavorite,
    this.showFavorite = true,
    this.isSelected = false,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    if (widget.showFavorite) {
      _checkFav();
    }
  }

  Future<void> _checkFav() async {
    final fav = await FavoriteService.isFavorite(widget.property['id']);
    if (mounted) setState(() => _isFav = fav);
  }

  Future<void> _toggleFav() async {
    setState(() => _isFav = !_isFav);
    try {
      await FavoriteService.toggle(widget.property['id']);
    } catch (_) {
      if (mounted) setState(() => _isFav = !_isFav);
    }
    widget.onFavorite?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyTheme = theme.extension<PropertyThemeExtension>()!;
    final images = (widget.property['images'] as List?)?.cast<String>() ?? [];
    final imageUrl = images.isNotEmpty ? images.first : null;
    final listingType = widget.property['listing_type'] ?? 'rent';
    final isRent = listingType == 'rent';

    return PropertyListCard(
      property: widget.property,
      onTap: widget.onTap,
      onFavorite: _toggleFav,
      isFavorite: _isFav,
      isSelected: widget.isSelected,
    );
  }
}

/// Compact property card for horizontal lists
class PropertyHorizontalCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const PropertyHorizontalCard({
    super.key,
    required this.property,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyTheme = theme.extension<PropertyThemeExtension>()!;
    final images = (property['images'] as List?)?.cast<String>() ?? [];
    final imageUrl = images.isNotEmpty ? images.first : null;
    final listingType = property['listing_type'] ?? 'rent';
    final isRent = listingType == 'rent';

    return _PropertyHorizontalCard(
      property: property,
      imageUrl: imageUrl,
      isRent: isRent,
      onTap: onTap,
      onFavorite: onFavorite,
      isFavorite: isFavorite,
      propertyTheme: propertyTheme,
    );
  }
}

class _PropertyHorizontalCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final String? imageUrl;
  final bool isRent;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final PropertyThemeExtension propertyTheme;

  const _PropertyHorizontalCard({
    required this.property,
    required this.imageUrl,
    required this.isRent,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    required this.propertyTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 280,
      child: AppCard.level2(
        padding: EdgeInsets.zero,
        clipped: true,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with badges
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          memCacheWidth: 800,
                          placeholder: (_, __) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.home_work, size: 48, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.home_work, size: 48, color: theme.colorScheme.onSurfaceVariant),
                        ),
                ),
                // Type Badge
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: isRent ? propertyTheme.rentColor : propertyTheme.saleColor,
                      borderRadius: BorderRadius.circular(AppRadius.round),
                    ),
                    child: Text(
                      isRent ? 'RENT' : 'SALE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onFavorite,
                      borderRadius: BorderRadius.circular(AppRadius.circle),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: AppElevation.level1,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : theme.colorScheme.onSurface,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                // Image count indicator
                if ((property['images'] as List?)?.length ?? 0 > 1)
                  Positioned(
                    bottom: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(AppRadius.round),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${(property['images'] as List).length}',
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['title'] ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property['city'] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _formatPrice(property['price_per_month']),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: propertyTheme.priceColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _FeatureChip(icon: Icons.bed_outlined, label: '${property['bedrooms'] ?? 0} Beds'),
                      const SizedBox(width: AppSpacing.md),
                      _FeatureChip(icon: Icons.bathtub_outlined, label: '${property['bathrooms'] ?? 0} Baths'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '₹0';
    final numPrice = price is num ? price : num.tryParse(price.toString()) ?? 0;
    return '₹${numPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}