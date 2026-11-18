import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/app_button.dart';

/// Empty state illustration with action
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double iconSize;
  final EdgeInsetsGeometry? padding;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.onSurfaceVariant.withOpacity(0.5);

    return Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xxxl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize + 40,
              height: iconSize + 40,
              decoration: BoxDecoration(
                color: effectiveIconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, size: iconSize, color: effectiveIconColor),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                fullWidth: false,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states for common scenarios
class EmptyStates {
  static EmptyState noProperties({
    VoidCallback? onAction,
    String actionLabel = 'Add Property',
  }) {
    return EmptyState(
      icon: Icons.home_work_outlined,
      title: 'No Properties Found',
      subtitle: 'Start your property search or list your own property to get started.',
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static EmptyState noFavorites({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: 'No Favorites Yet',
      subtitle: 'Tap the heart icon on any property to save it here for quick access.',
      actionLabel: 'Explore Properties',
      onAction: onAction,
    );
  }

  static EmptyState noMessages({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'No Messages',
      subtitle: 'Start a conversation with a property owner or tenant.',
      actionLabel: 'Browse Properties',
      onAction: onAction,
    );
  }

  static EmptyState noRequests({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.assignment_outlined,
      title: 'No Requests',
      subtitle: 'You haven\'t sent any rental requests yet.',
      actionLabel: 'Find a Property',
      onAction: onAction,
    );
  }

  static EmptyState noResults({String? query, VoidCallback? onClear}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      subtitle: query != null
          ? 'No properties match "$query". Try adjusting your filters or search terms.'
          : 'Try adjusting your filters or search terms.',
      actionLabel: onClear != null ? 'Clear Filters' : null,
      onAction: onClear,
    );
  }

  static EmptyState noInternet({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      subtitle: 'Please check your connection and try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  static EmptyState error({String? message, VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Something Went Wrong',
      subtitle: message ?? 'An unexpected error occurred. Please try again.',
      actionLabel: 'Try Again',
      onAction: onRetry,
      iconColor: Colors.red,
    );
  }
}