import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A consistent card widget with elevation variants
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final List<BoxShadow>? shadows;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final bool clipped;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.shadows,
    this.borderRadius,
    this.border,
    this.onTap,
    this.clipped = false,
  });

  /// Level 0 - No shadow (flat)
  factory AppCard.level0({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    VoidCallback? onTap,
    bool clipped = false,
  }) {
    return AppCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      color: color,
      shadows: AppElevation.level0,
      borderRadius: borderRadius,
      border: border,
      onTap: onTap,
      clipped: clipped,
    );
  }

  /// Level 1 - Subtle shadow
  factory AppCard.level1({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    VoidCallback? onTap,
    bool clipped = false,
  }) {
    return AppCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      color: color,
      shadows: AppElevation.level1,
      borderRadius: borderRadius,
      border: border,
      onTap: onTap,
      clipped: clipped,
    );
  }

  /// Level 2 - Standard card shadow (default)
  factory AppCard.level2({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    VoidCallback? onTap,
    bool clipped = false,
  }) {
    return AppCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      color: color,
      shadows: AppElevation.level2,
      borderRadius: borderRadius,
      border: border,
      onTap: onTap,
      clipped: clipped,
    );
  }

  /// Level 3 - Elevated shadow
  factory AppCard.level3({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    VoidCallback? onTap,
    bool clipped = false,
  }) {
    return AppCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      color: color,
      shadows: AppElevation.level3,
      borderRadius: borderRadius,
      border: border,
      onTap: onTap,
      clipped: clipped,
    );
  }

  /// Level 4 - High elevation shadow
  factory AppCard.level4({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    VoidCallback? onTap,
    bool clipped = false,
  }) {
    return AppCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      color: color,
      shadows: AppElevation.level4,
      borderRadius: borderRadius,
      border: border,
      onTap: onTap,
      clipped: clipped,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.cardColor;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppRadius.xl);
    final effectiveShadows = shadows ?? AppElevation.level2;
    final effectiveBorder = border ?? Border.all(color: theme.dividerColor, width: 0.5);

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveRadius,
        boxShadow: effectiveShadows,
        border: effectiveBorder,
      ),
      clipBehavior: clipped ? Clip.antiAlias : Clip.none,
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// A card with a header section
class AppCardWithHeader extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Widget? footer;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? bodyPadding;
  final EdgeInsetsGeometry? footerPadding;
  final List<BoxShadow>? shadows;
  final BorderRadius? borderRadius;
  final Color? color;
  final Border? border;

  const AppCardWithHeader({
    super.key,
    required this.header,
    required this.body,
    this.footer,
    this.headerPadding,
    this.bodyPadding,
    this.footerPadding,
    this.shadows,
    this.borderRadius,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppRadius.xl);
    final effectiveShadows = shadows ?? AppElevation.level2;
    final effectiveBorder = border ?? Border.all(color: theme.dividerColor, width: 0.5);

    return Container(
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        borderRadius: effectiveRadius,
        boxShadow: effectiveShadows,
        border: effectiveBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: headerPadding ?? const EdgeInsets.all(AppSpacing.lg),
            child: header,
          ),
          Padding(
            padding: bodyPadding ?? const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: body,
          ),
          if (footer != null)
            Padding(
              padding: footerPadding ?? const EdgeInsets.all(AppSpacing.lg),
              child: footer!,
            ),
        ],
      ),
    );
  }
}

/// A statistic card for dashboards
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool trendPositive;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard.level1(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trendPositive ? Colors.green : Colors.red).withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendPositive ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: trendPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: trendPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A card for property listing (compact version for lists)
class PropertyListCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool isSelected;

  const PropertyListCard({
    super.key,
    required this.property,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyTheme = theme.extension<PropertyThemeExtension>()!;
    final images = (property['images'] as List?)?.cast<String>() ?? [];
    final imageUrl = images.isNotEmpty ? images.first : null;
    final listingType = property['listing_type'] ?? 'rent';
    final isRent = listingType == 'rent';

    return AppCard.level2(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.home_work, size: 48, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.home_work, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      ),
              ),
              // Badges
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
                    isRent ? 'FOR RENT' : 'FOR SALE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // Favorite button
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
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              // Selection indicator
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 3),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        property['title'] ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _formatPrice(property['price_per_month']),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: propertyTheme.priceColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property['city'] ?? ''}${property['pincode'] != null ? ' - ${property['pincode']}' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(height: 1, color: theme.dividerColor),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _FeatureChip(icon: Icons.bed_outlined, label: '${property['bedrooms'] ?? 0} Beds'),
                    const SizedBox(width: AppSpacing.md),
                    _FeatureChip(icon: Icons.bathtub_outlined, label: '${property['bathrooms'] ?? 0} Baths'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.round),
                      ),
                      child: Text(
                        property['property_type'] ?? '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

/// A horizontal property card for featured/carousel views
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

    return SizedBox(
      width: 280,
      child: AppCard.level2(
        padding: EdgeInsets.zero,
        clipped: true,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.home_work, size: 48, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.home_work, size: 48, color: theme.colorScheme.onSurfaceVariant),
                        ),
                ),
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['title'] ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(property['price_per_month']),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: propertyTheme.priceColor,
                    ),
                  ),
                  const SizedBox(height: 8),
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