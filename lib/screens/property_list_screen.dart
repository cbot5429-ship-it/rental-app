import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_filter.dart';
import '../services/property_query_service.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_text_field.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/property_card.dart';
import '../widgets/property_horizontal_card.dart';
import 'compare_screen.dart';
import 'property_detail_screen.dart';

class PropertyListScreen extends StatefulWidget {
  final String initialQuery;
  final String listingType;
  const PropertyListScreen({super.key, required this.initialQuery, required this.listingType});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  List<Map<String, dynamic>> _properties = [];
  bool _loading = true;
  late PropertyFilter _filter;
  List<Map<String, dynamic>> _compareList = [];
  final _searchCtrl = TextEditingController();
  bool _isGrid = false;
  final _scrollController = ScrollController();
  bool _showFAB = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.initialQuery;
    _filter = PropertyFilter()
      ..listingType = widget.listingType
      ..searchQuery = widget.initialQuery;
    _load();
    _saveSearch(widget.initialQuery);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 300 && !_showFAB) {
      setState(() => _showFAB = true);
    } else if (_scrollController.offset <= 300 && _showFAB) {
      setState(() => _showFAB = false);
    }
  }

  Future<void> _saveSearch(String query) async {
    if (query.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_search', query);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _filter.searchQuery = _searchCtrl.text;
    try {
      final data = await PropertyQueryService.search(_filter);
      if (mounted) setState(() { _properties = data; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showError('Failed to load properties: $e');
      }
    }
  }

  Future<void> _openFilters() async {
    final result = await FilterSheet.show(context, _filter);
    if (result != null) {
      setState(() => _filter = result);
      _load();
    }
  }

  void _toggleView() {
    setState(() => _isGrid = !_isGrid);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Column(
        children: [
          // Search Header
          _buildSearchHeader(theme, isDark),
          // Filter Bar
          _buildFilterBar(theme, isDark),
          // Property List
          Expanded(
            child: _isGrid
                ? _buildGridList(theme, isDark, isGrid: true)
                : _buildGridList(theme, isDark, isGrid: false),
          ),
          // Floating Action Button
          if (_showFAB) _buildFAB(theme),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppSearchField(
              controller: _searchCtrl,
              hint: 'Search locality, name or pincode...',
              onSubmitted: (value) {
                _load();
                _saveSearch(value);
              },
              showFilter: false,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          AppIconButton(
            icon: Icons.filter_alt,
            tooltip: 'Filter',
            onPressed: _openFilters,
            size: 44,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      child: Row(
        children: [
          // Active Filters
          Expanded(
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _filter.activeFilters.map((filter) {
                return AppPillBadge(
                  label: filter.label,
                  icon: filter.icon,
                  color: theme.colorScheme.primary,
                  onTap: () => _removeFilter(filter),
                );
              }).toList(),
            ),
          ),
          // Sort & View Toggle
          AppSegmentedControl(
            selectedValue: _filter.sortOrder,
            segments: const [
              Segment(value: 'newest', label: 'Newest'),
              Segment(value: 'price_asc', label: 'Price ↑'),
              Segment(value: 'price_desc', label: 'Price ↓'),
            ],
            onChanged: (value) {
              setState(() => _filter.sortOrder = value);
              _load();
            },
          ),
          const SizedBox(width: AppSpacing.md),
          AppIconButton(
            icon: _isGrid ? Icons.list : Icons.grid_view,
            tooltip: _isGrid ? 'List View' : 'Grid View',
            onPressed: _toggleView,
            size: 36,
            color: theme.colorScheme.onSurface,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  Widget _buildGridList(ThemeData theme, bool isDark, {required bool isGrid}) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No properties match your search',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: 'Clear Filters',
              onPressed: () {
                _filter.clear();
                _load();
              },
            ),
          ],
        ),
      );
    }

    if (isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        controller: _scrollController,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: _properties.length,
        itemBuilder: (context, index) {
          final p = _properties[index];
          final isSelected = _compareList.any((e) => e['id'] == p['id']);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () {
              setState(() {
                if (isSelected) {
                  _compareList.removeWhere((e) => e['id'] == p['id']);
                } else {
                  if (_compareList.length < 3) _compareList.add(p);
                }
              });
            },
            child: AnimatedContainer(
              duration: AppDuration.normal,
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: PropertyCard(
                property: p,
                onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)),
                ),
                onFavorite: () {},
              ),
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        itemCount: _properties.length,
        itemBuilder: (context, index) {
          final p = _properties[index];
          final isSelected = _compareList.any((e) => e['id'] == p['id']);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () {
              setState(() {
                if (isSelected) {
                  _compareList.removeWhere((e) => e['id'] == p['id']);
                } else {
                  if (_compareList.length < 3) _compareList.add(p);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: isSelected ? Border.all(color: Colors.green, width: 3) : null,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: PropertyHorizontalCard(
                property: p,
                onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)),
                ),
                onFavorite: () {},
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildFAB(ThemeData theme) {
    return Positioned(
      bottom: AppSpacing.xl,
      right: AppSpacing.xl,
      child: AppFAB.extended(
        label: 'Compare (${_compareList.length})',
        onPressed: _compareList.length >= 2
            ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompareScreen(properties: _compareList)))
            : null,
        icon: Icons.compare_arrows,
        backgroundColor: _compareList.length >= 2 ? null : theme.colorScheme.surfaceContainerHighest,
        foregroundColor: _compareList.length >= 2 ? null : theme.colorScheme.onSurface,
      ),
    );
  }

  void _removeFilter(FilterItem filter) {
    setState(() {
      _filter.removeFilter(filter);
    });
    _load();
  }
}