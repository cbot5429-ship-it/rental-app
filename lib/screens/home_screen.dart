import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart' show supabase;
import 'add_property_screen.dart';
import 'property_list_screen.dart';
import 'inbox_screen.dart';
import 'my_requests_screen.dart';
import 'profile_screen.dart';
import 'owner_dashboard_screen.dart';
import 'admin_reports_screen.dart';
import 'favorites_screen.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/image_carousel.dart';
import '../widgets/common/section_header.dart';
import '../widgets/common/loading_shimmer.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedTab = 1; // 0: Buy, 1: Rent, 2: Commercial
  String _lastSearch = '';
  final _searchCtrl = TextEditingController();
  late TabController _tabController;
  int _currentPage = 0;
  late PageController _pageController;

  final List<String> _tabs = ['Buy', 'Rent', 'Commercial'];
  final List<String> _placeholders = [
    'Search properties to buy...',
    'Search by locality, landmark or pincode',
    'Search commercial spaces...'
  ];

  // Featured properties (mock data - in real app would come from API)
  final List<Map<String, dynamic>> _featuredProperties = [
    {
      'id': 'featured_1',
      'title': 'Luxury 3BHK in Koramangala',
      'city': 'Bangalore',
      'price_per_month': 45000,
      'bedrooms': 3,
      'bathrooms': 2,
      'property_type': 'Apartment',
      'listing_type': 'rent',
      'images': [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
      ],
    },
    {
      'id': 'featured_2',
      'title': 'Modern Villa in Whitefield',
      'city': 'Bangalore',
      'price_per_month': 85000,
      'bedrooms': 4,
      'bathrooms': 3,
      'property_type': 'Independent House/Villa',
      'listing_type': 'rent',
      'images': [
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
        'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800',
      ],
    },
    {
      'id': 'featured_3',
      'title': 'Premium Office Space MG Road',
      'city': 'Bangalore',
      'price_per_month': 120000,
      'bedrooms': 0,
      'bathrooms': 2,
      'property_type': 'Commercial',
      'listing_type': 'commercial',
      'images': [
        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
        'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800',
      ],
    },
  ];

  // Categories for quick filters
  final List<CategoryChip> _categories = [
    const CategoryChip(label: 'Apartments', icon: Icons.apartment_outlined, query: 'Apartment'),
    const CategoryChip(label: 'Villas', icon: Icons.villa_outlined, query: 'Independent House/Villa'),
    const CategoryChip(label: 'PG/Co-living', icon: Icons.bed_outlined, query: 'PG'),
    const CategoryChip(label: 'Offices', icon: Icons.business_outlined, query: 'commercial'),
    const CategoryChip(label: 'Shops', icon: Icons.store_outlined, query: 'shop'),
    const CategoryChip(label: 'Land', icon: Icons.landscape_outlined, query: 'land'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController(viewportFraction: 0.85);
    _loadLastSearch();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _featuredProperties.length > 1) {
        final nextPage = (_currentPage + 1) % _featuredProperties.length;
        _pageController.animateToPage(
          nextPage,
          duration: AppDuration.slower,
          curve: AppCurves.decelerate,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLastSearch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _lastSearch = prefs.getString('last_search') ?? '');
  }

  void _navigateToSearch(String query) {
    String listingType = _selectedTab == 0 ? 'buy' : (_selectedTab == 1 ? 'rent' : 'commercial');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyListScreen(
          initialQuery: query,
          listingType: listingType,
        ),
      ),
    );
  }

  void _navigateToCategory(CategoryChip category) {
    _navigateToSearch(category.query ?? category.label);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyTheme = theme.extension<PropertyThemeExtension>()!;
    final user = supabase.auth.currentUser;
    final name = user?.email?.split('@').first ?? 'User';
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(Icons.home_work, color: theme.colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'RentalApp',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.onSurface),
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),

            // Hero Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      'Hello, $name 👋',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Find your perfect space in India',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Search Card
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        boxShadow: AppElevation.level2,
                      ),
                      child: Column(
                        children: [
                          // Segmented tabs
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              onTap: (index) => setState(() => _selectedTab = index),
                              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                              indicator: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                boxShadow: AppElevation.level1,
                              ),
                              labelColor: theme.colorScheme.primary,
                              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                              labelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                              unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                              dividerColor: Colors.transparent,
                              splashFactory: NoSplash.splashFactory,
                              overlayColor: WidgetStateProperty.all(Colors.transparent),
                            ),
                          ),

                          // Search field
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: AppSearchField(
                              controller: _searchCtrl,
                              hint: _placeholders[_selectedTab],
                              onSubmitted: (val) {
                                _navigateToSearch(val);
                                _searchCtrl.clear();
                              },
                              onChanged: (val) {},
                              onFilterTap: () {},
                              showFilter: true,
                              filterCount: 0,
                            ),
                          ),

                          // Last search chip
                          if (_lastSearch.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ActionChip(
                                      avatar: Icon(Icons.history, size: 16, color: theme.colorScheme.primary),
                                      label: Text(
                                        'Continue: "$_lastSearch"',
                                        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                                      ),
                                      onPressed: () => _navigateToSearch(_lastSearch),
                                      backgroundColor: propertyTheme.rentContainer,
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Categories Section
                    SectionHeader(
                      title: 'Explore by Category',
                      subtitle: 'Browse popular property types',
                      actionLabel: 'View All',
                      onActionTap: () {
                        _navigateToSearch('');
                      },
                    ),

                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _navigateToCategory(category),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              child: Container(
                                width: 100,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(AppRadius.xl),
                                  boxShadow: AppElevation.level1,
                                  border: Border.all(color: theme.dividerColor, width: 0.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.sm),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        category.icon,
                                        color: theme.colorScheme.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      category.label,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Featured Properties Section
                    SectionHeader(
                      title: 'Featured Properties',
                      subtitle: 'Handpicked listings for you',
                      actionLabel: 'See All',
                      onActionTap: () {
                        _navigateToSearch('');
                      },
                    ),

                    // Featured carousel
                    SizedBox(
                      height: 280,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _featuredProperties.length,
                        onPageChanged: (index) => setState(() => _currentPage = index),
                        itemBuilder: (context, index) {
                          final property = _featuredProperties[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == _featuredProperties.length - 1 ? AppSpacing.md : AppSpacing.sm,
                              left: index == 0 ? AppSpacing.md : 0,
                            ),
                            child: PropertyHorizontalCard(
                              property: property,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PropertyDetailScreen(property: property),
                                ),
                              ),
                              onFavorite: () {},
                              isFavorite: false,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Page indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_featuredProperties.length, (index) {
                        return AnimatedContainer(
                          duration: AppDuration.fast,
                          curve: AppCurves.standard,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentPage
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(AppRadius.round),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Quick Actions Section
                    SectionHeader(
                      title: 'Quick Actions',
                      subtitle: 'Common tasks at your fingertips',
                    ),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      childAspectRatio: 1.3,
                      children: [
                        _QuickActionCard(
                          icon: Icons.add_home_work,
                          label: 'List Property',
                          color: theme.colorScheme.primary,
                          onTap: () async {
                            final added = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
                            );
                            if (added == true && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Property listed successfully!'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                                ),
                              );
                            }
                          },
                        ),
                        _QuickActionCard(
                          icon: Icons.favorite_outline,
                          label: 'My Favorites',
                          color: Colors.red,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                          ),
                        ),
                        _QuickActionCard(
                          icon: Icons.chat_bubble_outline,
                          label: 'Messages',
                          color: Colors.blue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const InboxScreen()),
                          ),
                        ),
                        _QuickActionCard(
                          icon: Icons.dashboard_outlined,
                          label: 'Owner Dashboard',
                          color: Colors.orange,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AppFAB.extended(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
          );
          if (added == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Property listed successfully!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
            );
          }
        },
        icon: Icons.add_home_work,
        label: 'List Property',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppElevation.level1,
            border: Border.all(color: theme.dividerColor, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Import the PropertyDetailScreen
import 'property_detail_screen.dart';