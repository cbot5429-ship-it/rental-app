import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A shimmer loading placeholder
class LoadingShimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final bool enabled;

  const LoadingShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.enabled = true,
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = widget.baseColor ?? (isDark ? Colors.grey.shade800 : Colors.grey.shade200);
    final highlightColor = widget.highlightColor ?? (isDark ? Colors.grey.shade700 : Colors.grey.shade100);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Property card shimmer
class PropertyCardShimmer extends StatelessWidget {
  const PropertyCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return LoadingShimmer(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppElevation.level2,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              color: baseColor,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: double.infinity,
                    color: baseColor,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 120,
                    color: baseColor,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: theme.dividerColor,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(height: 20, width: 80, color: baseColor),
                      const SizedBox(width: 16),
                      Container(height: 20, width: 80, color: baseColor),
                      const Spacer(),
                      Container(height: 16, width: 100, color: baseColor),
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
}

/// Horizontal property card shimmer
class PropertyHorizontalCardShimmer extends StatelessWidget {
  const PropertyHorizontalCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return LoadingShimmer(
      child: SizedBox(
        width: 280,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppElevation.level2,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                color: baseColor,
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 20, width: 200, color: baseColor),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 150, color: baseColor),
                    const SizedBox(height: 12),
                    Container(height: 22, width: 100, color: baseColor),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(height: 18, width: 70, color: baseColor),
                        const SizedBox(width: 16),
                        Container(height: 18, width: 70, color: baseColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Property detail shimmer
class PropertyDetailShimmer extends StatelessWidget {
  const PropertyDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return LoadingShimmer(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: baseColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 32, width: 200, color: baseColor),
                  const SizedBox(height: 8),
                  Container(height: 20, width: 150, color: baseColor),
                  const SizedBox(height: 16),
                  Container(height: 36, width: 120, color: baseColor),
                  const SizedBox(height: 24),
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(4, (_) => Column(
                        children: [
                          Container(height: 32, width: 32, decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle)),
                          const SizedBox(height: 8),
                          Container(height: 16, width: 50, color: baseColor),
                          Container(height: 12, width: 40, color: baseColor),
                        ],
                      )),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(height: 24, width: 120, color: baseColor),
                  const SizedBox(height: 8),
                  Container(height: 60, width: double.infinity, color: baseColor),
                  const SizedBox(height: 32),
                  Container(
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Container(height: 56, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(AppRadius.lg)))),
                      const SizedBox(width: 12),
                      Expanded(child: Container(height: 56, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(AppRadius.lg)))),
                    ],
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

/// List tile shimmer
class ListTileShimmer extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final int subtitleLines;

  const ListTileShimmer({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.subtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return LoadingShimmer(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        leading: hasLeading
            ? Container(width: 48, height: 48, decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle))
            : null,
        title: Container(height: 20, width: 150, color: baseColor),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(subtitleLines, (index) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(height: 14, width: 120, color: baseColor),
          )),
        ),
        trailing: hasTrailing ? Container(width: 24, height: 24, color: baseColor) : null,
      ),
    );
  }
}

/// Stat card shimmer
class StatCardShimmer extends StatelessWidget {
  const StatCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return LoadingShimmer(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppElevation.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(AppRadius.md))),
                Container(width: 60, height: 24, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(AppRadius.round))),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(height: 32, width: 80, color: baseColor),
            const SizedBox(height: 4),
            Container(height: 14, width: 100, color: baseColor),
          ],
        ),
      ),
    );
  }
}