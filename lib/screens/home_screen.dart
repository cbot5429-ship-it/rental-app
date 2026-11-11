import 'package:flutter/material.dart';
import '../main.dart' show supabase;
import '../models/property_filter.dart';
import '../services/property_query_service.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/property_card.dart';

// Screen imports
import 'add_property_screen.dart';
import 'compare_screen.dart';
import 'favorites_screen.dart';
import 'inbox_screen.dart';
import 'my_requests_screen.dart';
import 'owner_dashboard_screen.dart';
import 'profile_screen.dart';
import 'property_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _properties = [];
  bool _loading = true;
  PropertyFilter _filter = PropertyFilter();
  
  // State for the Property Comparison feature
  List<Map<String, dynamic>> _compareList = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await PropertyQueryService.search(_filter);
      if (mounted) {
        setState(() {
          _properties = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading properties: $e')));
      }
    }
  }

  Future<void> _openFilters() async {
    final result = await showFilterSheet(context, _filter);
    if (result != null) {
      setState(() => _filter = result);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rentals'),
        actions: [
          // 1. Filters
          IconButton(
            icon: Badge(
              isLabelVisible: _filter.activeCount > 0,
              label: Text('${_filter.activeCount}'),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _openFilters,
            tooltip: 'Filters',
          ),
          
          // 2. Favorites
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
            tooltip: 'Favorites',
          ),

          // 3. Inbox (Messages)
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxScreen())),
            tooltip: 'Inbox',
          ),

          // 4. Compare Properties
          IconButton(
            icon: Badge(
              isLabelVisible: _compareList.isNotEmpty,
              label: Text('${_compareList.length}'),
              child: const Icon(Icons.compare_arrows),
            ),
            onPressed: () {
              if (_compareList.length >= 2) {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => CompareScreen(properties: _compareList))
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select at least 2 properties to compare.')),
                );
              }
            },
            tooltip: 'Compare',
          ),

          // 5. Overflow Menu (Three dots)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'my_requests') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRequestsScreen()));
              } else if (value == 'dashboard') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()));
              } else if (value == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              } else if (value == 'logout') {
                supabase.auth.signOut();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: 'my_requests', child: Text('My Rental Requests')),
                const PopupMenuItem(value: 'dashboard', child: Text('Owner Dashboard')),
                const PopupMenuItem(value: 'profile', child: Text('My Profile')),
                const PopupMenuItem(
                  value: 'logout', 
                  child: Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ];
            },
          ),
        ],
      ),
      
      // --- BODY ---
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _properties.isEmpty
              ? const Center(child: Text('No properties match your filters.'))
              : RefreshIndicator(
                  onRefresh: _load,
                                    child: ListView.builder(
                    itemCount: _properties.length,
                    itemBuilder: (context, i) {
                      final p = _properties[i];
                      final isSelected = _compareList.any((e) => e['id'] == p['id']);
                      
                      return GestureDetector(
                        // 👇 Long press toggles comparison
                        onLongPress: () {
                          setState(() {
                            if (isSelected) {
                              _compareList.removeWhere((e) => e['id'] == p['id']);
                            } else {
                              if (_compareList.length < 3) {
                                _compareList.add(p);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('You can compare up to 3 properties.')),
                                );
                              }
                            }
                          });
                        },
                        child: Container(
                          // 👇 Shows a green border if selected
                          decoration: BoxDecoration(
                            border: isSelected ? Border.all(color: Colors.green, width: 3) : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: PropertyCard(
                            property: p,
                            onTap: () async {
                              await Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p))
                              );
                              _load(); 
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
      
      // --- ADD PROPERTY BUTTON ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
          );
          // If a property was successfully added, refresh the list!
          if (added == true) _load();
        },
        icon: const Icon(Icons.add_home_work),
        label: const Text('List Property'),
      ),
    );
  }
}