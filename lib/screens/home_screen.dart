import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../widgets/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Property>> _propertiesFuture;
  String _selectedListingType = 'rent';

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    setState(() {
      _propertiesFuture = PropertyService.getAll(
        listingType: _selectedListingType,
        limit: 10,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Home'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedListingType,
            onSelected: (value) {
              setState(() {
                _selectedListingType = value;
              });
              _loadProperties();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rent', child: Text('Rent')),
              const PopupMenuItem(value: 'sale', child: Text('Buy')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  _selectedListingType.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
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
                property: property.toJson(),
                onTap: () => _navigateToDetail(property),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_property'),
        child: const Icon(Icons.add),
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

class PropertyDetailScreen extends StatelessWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property.hasImages)
              Image.network(
                property.mainImageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.home_work, size: 64),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(property.formattedPrice, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${property.city ?? 'Unknown'}, ${property.address ?? ''}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _FeatureChip(icon: Icons.bed_outlined, label: '${property.bedrooms ?? 0} Beds'),
                      const SizedBox(width: 16),
                      _FeatureChip(icon: Icons.bathtub_outlined, label: '${property.bathrooms ?? 0} Baths'),
                      const SizedBox(width: 16),
                      _FeatureChip(icon: Icons.category_outlined, label: property.propertyType ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(property.description ?? 'No description available'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}