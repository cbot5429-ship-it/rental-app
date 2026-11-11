import 'package:flutter/material.dart';
import '../services/rental_request_service.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});
  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = RentalRequestService.mySentRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Rental Requests')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('You have not made any requests yet.'));

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final req = items[i];
              final status = req['status'] ?? 'pending';
              Color statusColor = status == 'approved' ? Colors.green : status == 'rejected' ? Colors.red : Colors.orange;

              return ListTile(
                title: Text(req['properties']?['title'] ?? 'Property'),
                subtitle: Text('Status: ${status.toUpperCase()}', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
    );
  }
}