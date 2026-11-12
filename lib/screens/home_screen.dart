import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart' show supabase;
import 'add_property_screen.dart'; // 👈 Added this import
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
      backgroundColor: Colors.white,
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
            // 👇 Added List Property here 👇
            ListTile(
              leading: const Icon(Icons.add_home_work, color: Colors.blue),
              title: const Text('List a Property', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                final added = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
                if (added == true) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property listed successfully!')));
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.inbox),
              title: const Text('Inbox'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('My Rental Requests'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRequestsScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Owner Dashboard'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerDashboardScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Admin Reports'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminReportsScreen())),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => supabase.auth.signOut(),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Rental App', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      // 👇 Added Floating Action Button here 👇
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyScreen()));
          if (added == true) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property listed successfully!')));
          }
        },
        icon: const Icon(Icons.add_home_work),
        label: const Text('List Property'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text('Hello, $name 👋', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Find your perfect space in India.', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),

            // Segmented Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: List.generate(3, (index) {
                  final isActive = _selectedTab == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                        ),
                        child: Text(
                          _tabs[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey,
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
            GestureDetector(
              onTap: () => _navigateToSearch(''),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _placeholders[_selectedTab],
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Continue Last Search Chip
            if (_lastSearch.isNotEmpty)
              ActionChip(
                avatar: const Icon(Icons.history, size: 16, color: Colors.blue),
                label: Text('Continue last search: "$_lastSearch"'),
                onPressed: () => _navigateToSearch(_lastSearch),
                backgroundColor: Colors.blue.shade50,
              ),
          ],
        ),
      ),
    );
  }
}