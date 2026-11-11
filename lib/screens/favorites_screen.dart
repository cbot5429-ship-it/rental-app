import 'property_detail_screen.dart';
import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../widgets/property_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = FavoriteService.myFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('You haven\'t saved any properties yet.'));
          }
            return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) => PropertyCard(
              property: items[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: items[i])),
              ),
            ),
          );
        },
      ),
    );
  }
}