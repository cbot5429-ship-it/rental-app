import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';

/// A full-screen image carousel with page indicator and navigation
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final int initialPage;
  final double? height;
  final BorderRadius? borderRadius;
  final bool showIndicator;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final VoidCallback? onImageTap;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ImageCarousel({
    super.key,
    required this.images,
    this.initialPage = 0,
    this.height,
    this.borderRadius,
    this.showIndicator = true,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.onImageTap,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentPage);
    if (widget.autoPlay && widget.images.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % widget.images.length;
      _pageController.animateToPage(
        nextPage,
        duration: AppDuration.slow,
        curve: AppCurves.decelerate,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.images.isEmpty) {
      return _buildPlaceholder();
    }

    return Stack(
      children: [
        // PageView
        Container(
          height: widget.height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final imageUrl = widget.images[index];
              return GestureDetector(
                onTap: widget.onImageTap,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  memCacheWidth: 1200,
                  placeholder: (context, url) => widget.placeholder ?? _buildLoadingPlaceholder(),
                  errorWidget: (context, url, error) => widget.errorWidget ?? _buildErrorPlaceholder(),
                ),
              );
            },
          ),
        ),

        // Navigation arrows
        if (widget.images.length > 1) ...[
          Positioned(
            left: AppSpacing.md,
            top: 0,
            bottom: 0,
            child: Center(
              child: _NavButton(
                icon: Icons.chevron_left,
                onPressed: _currentPage > 0
                    ? () => _pageController.previousPage(
                          duration: AppDuration.normal,
                          curve: AppCurves.decelerate,
                        )
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
                onPressed: _currentPage < widget.images.length - 1
                    ? () => _pageController.nextPage(
                          duration: AppDuration.normal,
                          curve: AppCurves.decelerate,
                        )
                    : null,
              ),
            ),
          ),
        ],

        // Page indicator
        if (widget.showIndicator && widget.images.length > 1)
          Positioned(
            bottom: AppSpacing.md,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: AppDuration.fast,
                  curve: AppCurves.standard,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primary
                        : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    final theme = Theme.of(context);
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No images available',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Failed to load image',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

/// Full-screen image gallery (for property detail)
class FullScreenImageGallery extends StatelessWidget {
  final List<String> images;
  final int initialIndex;
  final String? heroTag;

  const FullScreenImageGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.heroTag,
  });

  static void show(BuildContext context, List<String> images, {int initialIndex = 0, String? heroTag}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImageGallery(
          images: images,
          initialIndex: initialIndex,
          heroTag: heroTag,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: heroTag != null
                      ? Hero(
                          tag: '$heroTag-$index',
                          child: CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.contain,
                            memCacheWidth: 1920,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(color: theme.colorScheme.primary),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.contain,
                          memCacheWidth: 1920,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(color: theme.colorScheme.primary),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.white54,
                          ),
                        ),
                ),
              );
            },
          ),
          // Close button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Page indicator
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return AnimatedContainer(
                      duration: AppDuration.fast,
                      curve: AppCurves.standard,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thumbnail strip for image gallery
class ImageThumbnailStrip extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double thumbnailSize;

  const ImageThumbnailStrip({
    super.key,
    required this.images,
    required this.selectedIndex,
    required this.onTap,
    this.thumbnailSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (images.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: thumbnailSize + AppSpacing.md,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: AppDuration.fast,
              curve: AppCurves.standard,
              width: thumbnailSize,
              height: thumbnailSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  width: 3,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                memCacheWidth: 200,
                placeholder: (context, url) => Container(color: theme.colorScheme.surfaceContainerHighest),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.home, color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}