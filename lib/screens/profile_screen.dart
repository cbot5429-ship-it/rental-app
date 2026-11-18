import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../models/property.dart';
import '../services/base_service.dart';
import '../services/property_service.dart';
import '../widgets/property_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  List<Property> _myProperties = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final uid = BaseService.currentUserId;
      if (uid != null) {
        final profileResponse = await BaseService.db
            .from('profiles')
            .select()
            .eq('id', uid)
            .maybeSingle();

        final propertiesResponse = await PropertyService.getByOwner(uid);

        if (mounted) {
          setState(() {
            _profile = profileResponse != null ? UserProfile.fromJson(profileResponse) : null;
            _myProperties = propertiesResponse;
            _loading = false;
          });
        }
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await BaseService.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _profile == null
          ? const Center(child: Text('Please sign in to view your profile'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: _profile!.avatarUrl != null
                          ? NetworkImage(_profile!.avatarUrl!)
                          : null,
                      child: _profile!.avatarUrl == null
                          ? Text(
                              _profile!.fullName?.isNotEmpty == true
                                  ? _profile!.fullName![0].toUpperCase()
                                  : 'U',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile!.fullName ?? 'No name',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (_profile!.phone != null)
                            Text(_profile!.phone!, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Member since ${_formatDate(_profile!.createdAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // My Properties Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Properties', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/add_property'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Property'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_myProperties.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.home_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text('No properties listed yet', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'Tap "Add Property" to list your first property',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _myProperties.length,
                    itemBuilder: (context, index) {
                      final property = _myProperties[index];
                      return PropertyCard(
                        property: property,
                        onTap: () => _navigateToDetail(property),
                        onFavorite: _loadData, // Refresh on favorite toggle
                      );
                    },
                  ),
              ],
            ),
    );
  }

  void _navigateToDetail(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(property: property),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}