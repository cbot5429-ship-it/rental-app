import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/review_service.dart';

class ReviewsSection extends StatefulWidget {
  final String propertyId;
  const ReviewsSection({super.key, required this.propertyId});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  late Future<List<Map<String, dynamic>>> _future;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = ReviewService.fetch(widget.propertyId);
    ReviewService.summary(widget.propertyId)
        .then((s) { if (mounted) setState(() => _summary = s); });
  }

  Future<void> _openWriteDialog() async {
    int rating = 5;
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Write a Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 5, minRating: 1,
              itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (v) => rating = v.toInt(),
            ),
            TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Comment')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit')),
        ],
      ),
    );
    if (ok == true) {
      await ReviewService.submit(propertyId: widget.propertyId, rating: rating, comment: ctrl.text.trim());
      _reload();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (_summary != null && (_summary!['review_count'] ?? 0) > 0)
              Row(children: [
                const Icon(Icons.star, size: 18, color: Colors.amber),
                Text(' ${_summary!['avg_rating']} (${_summary!['review_count']})'),
              ]),
            const Spacer(),
            TextButton.icon(
              onPressed: _openWriteDialog,
              icon: const Icon(Icons.rate_review, size: 18),
              label: const Text('Write'),
            ),
          ],
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
            }
            final rows = snap.data ?? [];
            if (rows.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No reviews yet.'));
            
            return Column(
              children: rows.map((r) {
                final name = r['profiles']?['full_name'] ?? 'User';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RatingBarIndicator(
                        rating: (r['rating'] as num).toDouble(),
                        itemSize: 16,
                        itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                      ),
                      if ((r['comment'] ?? '').toString().isNotEmpty) Text(r['comment']),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}