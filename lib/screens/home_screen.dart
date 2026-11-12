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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 1; // 0: Buy, 1: Rent, 2: Commercial
  String _lastSearch = '';
  final _searchCtrl = TextEditingController();

  final List<String> _tabs = ['Buy', 'Rent', 'Commercial'];
  final List<String> _placeholders = [
    'Search properties to buy...',
    'Search by locality, landmark or pincode',
    'Search commercial spaces...'
  ];

  @override
  void initState() {
    super.initState();
    _loadLastSearch();
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

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final name = user?.email?.split('@').first ?? 'User';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            ),
            ListTile(
              leading: const Icon(Icons.add_home_work, color: Colors.blue),
              title: const Text('List a Property', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                final added = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
                if (added == true) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property listed successfully!')));
              },
            ),
            const Divider(),
            ListTile(leading: const Icon(Icons.inbox), title: const Text('Inbox'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxScreen()))),
            ListTile(leading: const Icon(Icons.assignment), title: const Text('My Rental Requests'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRequestsScreen()))),
            ListTile(leading: const Icon(Icons.dashboard), title: const Text('Owner Dashboard'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()))),
            ListTile(leading: const Icon(Icons.report_problem), title: const Text('Admin Reports'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminReportsScreen()))),
            const Divider(),
            ListTile(leading: const Icon(Icons.person), title: const Text('My Profile'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red)), onTap: () => supabase.auth.signOut()),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Rental App', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: -0.5)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👇 Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, $name 👋', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Find your perfect space in India.', style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
                  const SizedBox(height: 24),

                  // Segmented Tabs
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: List.generate(3, (index) {
                        final isActive = _selectedTab == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))] : [],
                              ),
                              child: Text(
                                _tabs[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (val) {
                      _navigateToSearch(val);
                      _searchCtrl.clear();
                    },
                    decoration: InputDecoration(
                      hintText: _placeholders[_selectedTab],
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  if (_lastSearch.isNotEmpty)
                    ActionChip(
                      avatar: const Icon(Icons.history, size: 16, color: Colors.blue),
                      label: Text('Continue last search: "$_lastSearch"'),
                      onPressed: () => _navigateToSearch(_lastSearch),
                      backgroundColor: Colors.blue.shade50,
                      side: BorderSide.none,
                    ),
                ],
              ),
            ),
            
            // 👇 Quick Filters Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Explore by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _quickFilter('Apartment'),
                      _quickFilter('Gated Society'),
                      _quickFilter('Independent House/Villa'),
                      _quickFilter('Gated Community Villa'),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
          if (added == true) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property listed successfully!')));
        },
        icon: const Icon(Icons.add_home_work),
        label: const Text('List Property'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _quickFilter(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        // Navigates to list screen with a pre-applied search query
        _navigateToSearch(label);
      },
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}