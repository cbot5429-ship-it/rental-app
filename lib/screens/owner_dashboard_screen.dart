import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart' show supabase;
import 'incoming_requests_screen.dart';
import 'property_detail_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});
  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  List<Map<String, dynamic>> _myProperties = [];
  int _pendingRequests = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    final uid = supabase.auth.currentUser!.id;

    // 1. Fetch my properties
    final props = await supabase.from('properties').select().eq('owner_id', uid).order('created_at', ascending: false);
    
    // 2. Fetch pending requests count
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
      appBar: AppBar(title: const Text('Owner Dashboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // --- STATS CARDS ---
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
                  
                  // --- LISTINGS ---
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
                          subtitle: Text('\$${p['price_per_month']} / month'),
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