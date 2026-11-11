import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CompareScreen extends StatelessWidget {
  final List<Map<String, dynamic>> properties;
  const CompareScreen({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Properties')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 20,
            columns: [
              const DataColumn(label: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold))),
              ...properties.map((p) => DataColumn(label: Text(p['title'], style: const TextStyle(fontWeight: FontWeight.bold)))),
            ],
            rows: [
              // Images
              DataRow(cells: [
                const DataCell(Text('Photo')),
                ...properties.map((p) {
                  final images = (p['images'] as List?)?.cast<String>() ?? [];
                  return DataCell(
                    images.isNotEmpty
                        ? CachedNetworkImage(imageUrl: images.first, width: 100, height: 80, fit: BoxFit.cover)
                        : const Icon(Icons.home),
                  );
                }),
              ]),
              // Price
              DataRow(cells: [
                const DataCell(Text('Price')),
                ...properties.map((p) => DataCell(Text('\$${p['price_per_month']}'))),
              ]),
              // City
              DataRow(cells: [
                const DataCell(Text('City')),
                ...properties.map((p) => DataCell(Text(p['city'] ?? ''))),
              ]),
              // Beds
              DataRow(cells: [
                const DataCell(Text('Bedrooms')),
                ...properties.map((p) => DataCell(Text('${p['bedrooms']}'))),
              ]),
              // Baths
              DataRow(cells: [
                const DataCell(Text('Bathrooms')),
                ...properties.map((p) => DataCell(Text('${p['bathrooms']}'))),
              ]),
              // Furnishing
              DataRow(cells: [
                const DataCell(Text('Furnishing')),
                ...properties.map((p) => DataCell(Text(p['furnishing'] ?? 'N/A'))),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}