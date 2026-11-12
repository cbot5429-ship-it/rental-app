import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart' show supabase;
import '../services/maintenance_service.dart';
import 'incoming_requests_screen.dart';
import 'property_detail_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});
  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _myProperties = [];
  int _pendingRequests = 0;
  bool _loading = true;

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

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    final uid = supabase.auth.currentUser!.id;
    final props = await supabase.from('properties').select().eq('owner_id', uid).order('created_at', ascending: false);
    final reqs = await supabase.from('rental_requests').select('id').eq('owner_id', uid).eq('status', 'pending');

    if (mounted) {
      setState(() {
        _myProperties = List<Map<String, dynamic>>.from(props);
        _pendingRequests = reqs.length;
        _loading = false;
      });
    }
  }

  Future<void> _deleteProperty(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Property?'),
        content: const Text('This will permanently remove your listing.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await supabase.from('properties').delete().eq('id', id);
      _loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'My Properties'), Tab(text: 'Maintenance')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // --- TAB 1: PROPERTIES ---
                RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          Expanded(child: _statCard('Total Listings', '${_myProperties.length}', Icons.home_work, Colors.blue)),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard('Pending Requests', '$_pendingRequests', Icons.inbox, Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('Manage Listings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_myProperties.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('You have no listings yet.')))
                      else
                        ..._myProperties.map((p) {
                          final images = (p['images'] as List?)?.cast<String>() ?? [];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: images.isNotEmpty
                                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: images.first, width: 70, height: 70, fit: BoxFit.cover))
                                  : Container(width: 70, height: 70, color: Colors.grey.shade200, child: const Icon(Icons.home)),
                              title: Text(p['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('₹${p['price_per_month']}'),
                              trailing: PopupMenuButton<String>(
                                onSelected: (val) {
                                  if (val == 'delete') _deleteProperty(p['id']);
                                  if (val == 'requests') Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomingRequestsScreen()));
                                  if (val == 'view') Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)));
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'view', child: Text('View Listing')),
                                  const PopupMenuItem(value: 'requests', child: Text('View Requests')),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                
                // --- TAB 2: MAINTENANCE ---
                _MaintenanceTab(),
              ],
            ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// 👇 NEW WIDGET FOR MAINTENANCE TAB
class _MaintenanceTab extends StatefulWidget {
  @override
  State<_MaintenanceTab> createState() => _MaintenanceTabState();
}

class _MaintenanceTabState extends State<_MaintenanceTab> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = MaintenanceService.getOwnerRequests();
  }

  void _refresh() => setState(() => _future = MaintenanceService.getOwnerRequests());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data ?? [];
        if (items.isEmpty) return const Center(child: Text('No maintenance requests.'));

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final r = items[i];
            final isPending = r['status'] == 'pending';
            return Card(
              child: ListTile(
                title: Text(r['properties']?['title'] ?? 'Property', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From: ${r['profiles']?['full_name'] ?? 'Client'}'),
                    Text('Issue: "${r['issue']}"', style: const TextStyle(color: Colors.red)),
                  ],
                ),
                trailing: isPending 
                    ? FilledButton(
                        onPressed: () async {
                          await MaintenanceService.resolveRequest(r['id']);
                          _refresh();
                        }, 
                        child: const Text('Resolve')
                      )
                    : const Chip(label: Text('RESOLVED', style: TextStyle(color: Colors.green))),
              ),
            );
          },
        );
      },
    );
  }
}