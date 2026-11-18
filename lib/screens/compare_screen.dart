// Enhanced Compare Screen with side-by-side property cards and modern UI
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/property_filter.dart';
import '../services/property_query_service.dart';
import '../theme/app_theme.dart';
import 'property_detail_screen.dart';
import 'compare_results_screen.dart';
import 'property_list_screen.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_text_field.dart';

class CompareScreen extends StatefulWidget {
  final List<Map<String, dynamic>> properties;
  final String initialQuery;
  final String listingType;
  const CompareScreen({super.key, this.properties = const [], required this.initialQuery, required this.listingType});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  late List<Map<String, dynamic>> _properties;
  late PropertyFilter _filter;
  int _currentImageIndex = 0;
  final PageController _imageController = PageController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Limit to max 3 properties for meaningful comparison
    _properties = widget.properties.take(3).toList();
    _filter = PropertyFilter()
      ..listingType = widget.listingType
      ..searchQuery = widget.initialQuery;
    _searchCtrl.text = widget.initialQuery;
    // Initialize with first property images if available
    if (_properties.isNotEmpty) {
      final images = (_properties.first['images'] as List?)?.cast<String>() ?? [];
      if (images.isNotEmpty) {
        _currentImageIndex = 0;
      }
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _navigateToDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(property: _properties[index]),
      ),
    );
  }

  Future<void> _loadProperties() async {
    try {
      final data = await PropertyQueryService.search(_filter);
      if (!mounted) return;
      setState(() => _properties = data.take(3).toList());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load properties: $e')),
      );
    }
  }

  Future<void> _openFilters() async {
    final result = await FilterSheet.show(context, _filter);
    if (result != null) {
      setState(() => _filter = result);
      _loadProperties();
    }
  }

  void _addToCompare() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyListScreen(
          initialQuery: _filter.searchQuery ?? '',
          listingType: _filter.listingType ?? 'rent',
        ),
      ),
    ).then((selected) {
      if (!mounted || selected is! List) return;
      setState(() {
        for (final item in selected) {
          if (_properties.length >= 3) break;
          if (item is! Map<String, dynamic>) continue;
          if (_properties.any((p) => p['id'] == item['id'])) continue;
          _properties = [..._properties, item];
        }
      });
    });
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTwoItems = _properties.length == 2;
    final isThreeItems = _properties.length == 3;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Compare Properties'),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_properties.length < 3)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addToCompare,
              tooltip: 'Add another property to compare',
            ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _openFilters,
            tooltip: 'Filter properties before comparing',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar for adding more properties
          if (_properties.length < 3)
            _buildSearchBar(theme),

          // Shared image carousel (visible when comparing 2+ properties)
          if (_properties.length > 1)
            _buildSharedImageCarousel(theme),

          // Main comparison area
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: _buildComparisonLayout(theme, isMobile, isTwoItems, isThreeItems),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionBar(theme),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppSearchField(
              controller: _searchCtrl,
              hint: 'Search for properties to add...',
              onSubmitted: (val) {
                setState(() => _filter.searchQuery = val);
                _loadProperties();
              },
              showFilter: false,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          AppPrimaryButton(
            label: 'Search',
            onPressed: () => _loadProperties(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedImageCarousel(ThemeData theme) {
    // Find the current property based on index
    // The carousel pages through the first property's images, so index it by the
    // first property rather than by the image page (which can exceed the list).
    final currentProperty = _properties.first;
    final images = (currentProperty['images'] as List?)?.cast<String>() ?? [];
    final imageCount = images.length;

    if (imageCount == 0) return const SizedBox.shrink();

    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _imageController,
              itemCount: imageCount,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  placeholder: (_, __) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.home_work, size: 48, color: theme.colorScheme.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imageCount, (index) {
              return AnimatedContainer(
                duration: AppDuration.fast,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentImageIndex ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _currentImageIndex
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonLayout(ThemeData theme, bool isMobile, bool isTwoItems, bool isThreeItems) {
    if (_properties.isEmpty) {
      return const Center(child: Text('No properties to compare'));
    }

    final propertyTheme = theme.extension<PropertyThemeExtension>()!;

    // Responsive layout based on device and number of properties
    if (isMobile || isTwoItems) {
      // Vertical stack for mobile or 2 items
      return ListView.builder(
        itemCount: _properties.length,
        itemBuilder: (context, index) {
          return _buildPropertyCard(theme, propertyTheme, isMobile, _properties[index], index);
        },
      );
    } else {
      // Horizontal side-by-side for tablet with 3 items
      return Row(
        children: _properties.map((property) {
          final index = _properties.indexOf(property);
          return Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _buildPropertyCard(theme, propertyTheme, isMobile, property, index),
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildPropertyCard(ThemeData theme, PropertyThemeExtension propertyTheme, bool isMobile, Map<String, dynamic> property, int index) {
    final images = (property['images'] as List?)?.cast<String>() ?? [];
    final isRent = property['listing_type'] == 'rent';
    final propertyType = property['property_type'] ?? '';
    final price = property['price_per_month'] ?? 0;
    final bedrooms = property['bedrooms'] ?? 0;
    final bathrooms = property['bathrooms'] ?? 0;
    final city = property['city'] ?? '';
    final title = property['title'] ?? '';
    final furnishing = property['furnishing'] ?? 'N/A';
    final area = property['area'] ?? '';
    final rating = property['rating']?.toDouble() ?? 0;
    final reviews = property['review_count'] ?? 0;

    return AppCard.level2(
      margin: isMobile ? const EdgeInsets.only(bottom: AppSpacing.md) : const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with index and property info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${index + 1}. $title',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  if (rating > 0)
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () => _navigateToDetail(index),
                    color: theme.colorScheme.primary,
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Image section with type badge
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: images.first,
                        fit: BoxFit.cover,
                        memCacheWidth: 600,
                        placeholder: (_, __) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
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
              if (images.length > 1)
                Positioned(
                  bottom: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
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
                          '${images.length} photos',
                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Price and rating row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatPrice(price),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: propertyTheme.priceColor,
                ),
              ),
              if (reviews > 0)
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '$reviews reviews',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Features grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeatureChip(theme, '$bedrooms Beds', Icons.bed_outlined),
              _buildFeatureChip(theme, '$bathrooms Baths', Icons.bathtub_outlined),
              if (!isMobile)
                _buildFeatureChip(theme, '$area', Icons.square_foot),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Additional details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      city,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Furnishing: $furnishing | Type: $propertyType',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(ThemeData theme, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_properties.length} properties selected',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              AppPrimaryButton(
                label: 'Clear Selection',
                onPressed: _properties.isEmpty
                    ? null
                    : () => setState(() => _properties = []),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              ),
              const SizedBox(width: AppSpacing.md),
              AppPrimaryButton(
                label: 'Compare',
                // Comparing needs at least two properties to be meaningful.
                onPressed: _properties.length >= 2
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompareResultsScreen(properties: _properties),
                          ),
                        )
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              ),
            ],
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
