import 'package:flutter/material.dart';
import '../services/rental_request_service.dart';

class IncomingRequestsScreen extends StatefulWidget {
  const IncomingRequestsScreen({super.key});
  @override
  State<IncomingRequestsScreen> createState() => _IncomingRequestsScreenState();
}

class _IncomingRequestsScreenState extends State<IncomingRequestsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = RentalRequestService.incomingRequests();
  }

  void _refresh() {
    setState(() => _future = RentalRequestService.incomingRequests());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Requests')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No incoming requests yet.'));

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final req = items[i];
              final status = req['status'] ?? 'pending';
              final clientName = req['profiles']?['full_name'] ?? 'Client';

              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Property: ${req['properties']?['title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('From: $clientName'),
                      Text('Message: "${req['message']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 12),
                      if (status == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                await RentalRequestService.updateStatus(req['id'], 'rejected');
                                _refresh();
                              }, 
                              child: const Text('Reject', style: TextStyle(color: Colors.red))
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () async {
                                await RentalRequestService.updateStatus(req['id'], 'approved');
                                _refresh();
                              }, 
                              child: const Text('Approve')
                            ),
                          ],
                        )
                      else
                        Text('Status: ${status.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold, color: status == 'approved' ? Colors.green : Colors.red)),
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