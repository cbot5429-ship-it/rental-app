import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/favorite_service.dart';
import '../widgets/property_card.dart';
import 'property_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Property>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _future = FavoriteService.myFavorites();
    });
  }

  Future<void> _openDetail(Property property) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: property)),
    );
    // The property may have been unfavorited on the detail screen.
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: FutureBuilder<List<Property>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Could not load your favorites.'),
                    const SizedBox(height: 12),
                    TextButton(onPressed: _reload, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('You haven\'t saved any properties yet.')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, i) => PropertyCard(
                property: items[i].toJson(),
                onTap: () => _openDetail(items[i]),
                onFavorite: _reload,
              ),
            ),
          );
        },
      ),
    );
  }
}