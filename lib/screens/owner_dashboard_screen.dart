// Enhanced Owner Dashboard with trend indicators and improved visual hierarchy
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart' show supabase;
import 'incoming_requests_screen.dart';
import 'property_detail_screen.dart';
import 'add_property_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> with SingleTickerProviderStateMixin {
  bool get isTablet => MediaQuery.of(context).size.width > 600;
  late TabController _tabController;
  List<Map<String, dynamic>> _myProperties = [];
  int _pendingRequests = 0;
  bool _loading = true;
  List<Map<String, dynamic>> _previousStats = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDashboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard({bool refresh = false}) async {
    setState(() => _loading = true);
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _myProperties = [];
          _pendingRequests = 0;
          _loading = false;
        });
      }
      return;
    }
    try {
      final props = await supabase
          .from('properties')
          .select()
          .eq('owner_id', uid)
          .order('created_at', ascending: false);
      final reqs = await supabase
          .from('rental_requests')
          .select('id')
          .eq('owner_id', uid)
          .eq('status', 'pending');
      if (!mounted) return;
      setState(() {
        _myProperties = List<Map<String, dynamic>>.from(props);
        _pendingRequests = reqs.length;
        _loading = false;
        if (!refresh) _previousStats = [];
      });
    } catch (_) {
      // Without this the spinner would never stop on a failed fetch.
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteProperty(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Property?'),
        content: const Text('This will permanently remove your listing.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              )),
        ],
      ),
    );
    if (confirm == true) {
      await supabase.from('properties').delete().eq('id', id);
      _loadDashboard(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final propertyTheme = theme.extension<PropertyThemeExtension>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Listings')],
          indicatorColor: propertyTheme.rentColor,
          labelColor: propertyTheme.rentColor,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme, propertyTheme),
                _buildListingsTab(theme, propertyTheme),
              ],
            ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme, PropertyThemeExtension propertyTheme) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? AppSpacing.xl : AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSection(theme, propertyTheme),
            const SizedBox(height: AppSpacing.xl),
            _buildQuickActions(theme),
            const SizedBox(height: AppSpacing.xl),
            _buildRecentActivity(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, PropertyThemeExtension propertyTheme) {
    final total = _myProperties.length;
    final pending = _pendingRequests;
    final deletedCount = _previousStats.isNotEmpty ? (_previousStats.first['deleted'] ?? 0) : 0;
    final active = total - deletedCount;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Listings',
            value: '$total',
            icon: Icons.home_work,
            color: propertyTheme.rentColor,
            trend: total > (_previousStats.isEmpty ? 0 : _previousStats.first['total'] ?? 0) ? '↑' : '→',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            title: 'Active Listings',
            value: '$active',
            icon: Icons.check_circle,
            color: Colors.green,
            trend: active > (_previousStats.isEmpty ? 0 : _previousStats.first['active'] ?? 0) ? '↑' : '→',
          ),
        ),
        if (isTablet) const SizedBox(width: AppSpacing.md),
        if (isTablet)
          Expanded(
            child: _StatCard(
              title: 'Pending Requests',
              value: '$pending',
              icon: Icons.inbox,
              color: Colors.orange,
              trend: pending > (_previousStats.isEmpty ? 0 : _previousStats.first['pending'] ?? 0) ? '↑' : '→',
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppPrimaryButton(
                label: 'Add New Property',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
                ),
                icon: Icons.add_home_work,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppPrimaryButton(
                label: 'View Requests',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IncomingRequestsScreen()),
                ),
                icon: Icons.inbox,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppElevation.level1,
          ),
          child: Column(
            children: [
              _buildActivityItem(
                  theme, 'New rental request', 'Apartment 3BHK in Koramangala', Icons.request_page),
              _buildActivityItem(
                  theme, 'Property viewed 15 times', 'Modern Villa in Whitefield', Icons.visibility),
              _buildActivityItem(
                  theme, 'Favorite added', 'Premium Office Space', Icons.favorite),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      ThemeData theme, String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildListingsTab(ThemeData theme, PropertyThemeExtension propertyTheme) {
    return RefreshIndicator(
      onRefresh: () => _loadDashboard(refresh: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Manage Your Listings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_myProperties.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.search_off,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'You have no listings yet.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppPrimaryButton(
                      label: 'Add Your First Property',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddPropertyScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._myProperties.map((p) => _buildPropertyCard(theme, p)),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(ThemeData theme, Map<String, dynamic> property) {
    final propertyTheme = theme.extension<PropertyThemeExtension>()!;
    final images = (property['images'] as List?)?.cast<String>() ?? [];
    final price = property['price_per_month'] ?? 0;
    final bedrooms = property['bedrooms'] ?? 0;
    final bathrooms = property['bathrooms'] ?? 0;
    final area = property['area'] ?? 0;
    final views = property['view_count'] ?? 0;
    final status = property['status'] ?? 'active';
    final isFeatured = property['is_featured'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isFeatured ? 2 : 1,
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text(
                    property['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(property['city'] ?? '',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              if (isFeatured)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: propertyTheme.rentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'FEATURED',
                    style: TextStyle(
                      color: propertyTheme.rentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          // Image & Stats
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: images.isNotEmpty ? images.first : '',
                  fit: BoxFit.cover,
                  memCacheWidth: 400,
                  placeholder: (_, __) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  children: [
                    _buildStatusChip(theme, status),
                    const SizedBox(width: 8),
                    Text('$views views',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ],
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹$price/month',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: propertyTheme.priceColor)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailRow(theme, Icons.bed_outlined, '$bedrooms Beds'),
                    _buildDetailRow(theme, Icons.bathtub_outlined,
                        '${bathrooms ?? 0} Baths'),
                    _buildDetailRow(theme, Icons.square_foot,
                        '${area ?? 0} sqft'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                        label: 'View Details',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PropertyDetailScreen(
                                  property: property)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showPropertyMenu(
                          context, property),
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

  Widget _buildStatusChip(ThemeData theme, String status) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.8)
            : Colors.orange.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Pending',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text,
            style:
                TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
      ],
    );
  }

  void _showPropertyMenu(BuildContext context, Map<String, dynamic> property) {
    showModalBottomSheet(
        context: context,
        builder: (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Property'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddPropertyScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('View Analytics'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to analytics screen
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Property', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteProperty(property['id']);
                  },
                ),
              ],
            ));
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard.level1(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                trend,
                style: TextStyle(
                  color: trend == '↑' ? Colors.green : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}