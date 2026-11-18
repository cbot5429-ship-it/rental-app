import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../widgets/property_card.dart';

class PropertyListScreen extends StatefulWidget {
  final String initialQuery;
  final String listingType;

  const PropertyListScreen({
    super.key,
    required this.initialQuery,
    required this.listingType,
  });

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  late Future<List<Property>> _propertiesFuture;
  String _query = '';
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _loadProperties();
  }

  void _loadProperties() {
    setState(() {
      _propertiesFuture = PropertyService.getAll(
        listingType: widget.listingType,
        limit: 20,
        orderBy: _getSortField(),
        ascending: _getSortAscending(),
      );
    });
  }

  String _getSortField() {
    switch (_sortBy) {
      case 'price_low':
        return 'price_per_month';
      case 'price_high':
        return 'price_per_month';
      case 'newest':
      default:
        return 'created_at';
    }
  }

  bool _getSortAscending() {
    return _sortBy == 'price_low';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listingType == 'rent' ? 'Properties for Rent' : 'Properties for Sale'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search properties...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                _query = value;
                // TODO: Implement search
              },
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _sortBy,
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
              _loadProperties();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('Newest First')),
              const PopupMenuItem(value: 'price_low', child: Text('Price: Low to High')),
              const PopupMenuItem(value: 'price_high', child: Text('Price: High to Low')),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  _sortBy == 'newest'
                      ? 'Newest'
                      : _sortBy == 'price_low'
                          ? 'Price ↑'
                          : 'Price ↓',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Property>>(
        future: _propertiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadProperties, child: const Text('Retry')),
                ],
              ),
            );
          }
          final properties = snapshot.data ?? [];
          if (properties.isEmpty) {
            return const Center(child: Text('No properties found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return PropertyCard(
                property: property,
                onTap: () => _navigateToDetail(property),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToDetail(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(property: property),
      ),
    );
  }
}