import 'package:flutter/material.dart';
import '../main.dart' show supabase;

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    _future = supabase
        .from('reports')
        .select('*, properties(title), profiles!reports_reporter_id_fkey(full_name)')
        .order('created_at', ascending: false);
  }

  Future<void> _deleteListingAndReport(String propertyId, String reportId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('This will permanently remove the property and resolve this report.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      // 1. Delete the property (this cascades and deletes the report too)
      await supabase.from('properties').delete().eq('id', propertyId);
      // 2. Just in case, explicitly delete the report
      await supabase.from('reports').delete().eq('id', reportId);
      setState(() => _loadReports());
    }
  }

  Future<void> _dismissReport(String reportId) async {
    await supabase.from('reports').delete().eq('id', reportId);
    setState(() => _loadReports());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin: Reported Listings')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No active reports.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final r = items[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Property: ${r['properties']?['title'] ?? 'Deleted'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reported by: ${r['profiles']?['full_name'] ?? 'Unknown'}'),
                      Text('Reason: "${r['reason']}"', style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green), 
                        tooltip: 'Dismiss Report', 
                        onPressed: () => _dismissReport(r['id'])
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red), 
                        tooltip: 'Delete Listing', 
                        onPressed: () => _deleteListingAndReport(r['property_id'], r['id'])
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}