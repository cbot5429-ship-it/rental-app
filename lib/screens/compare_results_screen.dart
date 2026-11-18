// Compare Results Screen - final comparison view with detailed side-by-side analysis
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'property_detail_screen.dart';

class CompareResultsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> properties;
  const CompareResultsScreen({super.key, required this.properties});

  @override
  State<CompareResultsScreen> createState() => _CompareResultsScreenState();
}

class _CompareResultsScreenState extends State<CompareResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final properties = widget.properties;

    // Without this guard the summary below calls reduce() on an empty list.
    if (properties.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Property Comparison'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Select at least two properties to compare.')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Property Comparison'),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Summary section
          _buildSummary(theme, properties),
          const SizedBox(height: AppSpacing.lg),
          // Detailed comparison table
          Expanded(
            child: _buildComparisonTable(theme, properties, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(ThemeData theme, List<Map<String, dynamic>> properties) {
    final propertyTheme = theme.extension<PropertyThemeExtension>()!;
    final totalPrice = properties.fold<int>(0, (sum, p) => sum + (p['price_per_month'] as num? ?? 0).toInt());
    final avgBeds = properties.map((p) => p['bedrooms'] ?? 0).reduce((a, b) => a + b) / properties.length;
    final avgBaths = properties.map((p) => p['bathrooms'] ?? 0).reduce((a, b) => a + b) / properties.length;
    final bestRated = properties.reduce((best, current) {
      final bestRating = best['rating']?.toDouble() ?? 0;
      final currentRating = current['rating']?.toDouble() ?? 0;
      return currentRating > bestRating ? current : best;
    });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppElevation.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparison Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard(theme, 'Total Monthly', '₹${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}', Icons.currency_rupee, propertyTheme.priceColor),
              _buildSummaryCard(theme, 'Avg. Bedrooms', '${avgBeds.toStringAsFixed(1)}', Icons.bed_outlined, theme.colorScheme.primary),
              _buildSummaryCard(theme, 'Avg. Baths', '${avgBaths.toStringAsFixed(1)}', Icons.bathtub_outlined, theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildSummaryCard(theme, 'Best Rated', '${bestRated['rating']?.toStringAsFixed(1) ?? 'N/A'}★', Icons.star, propertyTheme.featuredColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildSummaryCard(theme, 'Total Properties', '${properties.length}', Icons.home_work, theme.colorScheme.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonTable(ThemeData theme, List<Map<String, dynamic>> properties, bool isMobile) {
    if (isMobile) {
      return ListView.builder(
        itemCount: properties.length,
        itemBuilder: (context, index) {
          return _buildMobileRow(theme, properties[index], index);
        },
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          columns: [
            const DataColumn(label: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold))),
            ...properties.map((p) => DataColumn(
              label: Column(
                children: [
                  Text(p['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(p['city'] ?? '', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            )),
          ],
          rows: [
            _buildDataRow(theme, 'Price', properties, (p) => '₹${p['price_per_month'] ?? 0}'),
            _buildDataRow(theme, 'Bedrooms', properties, (p) => '${p['bedrooms'] ?? 0}'),
            _buildDataRow(theme, 'Bathrooms', properties, (p) => '${p['bathrooms'] ?? 0}'),
            _buildDataRow(theme, 'Area', properties, (p) => '${p['area'] ?? 0} sqft'),
            _buildDataRow(theme, 'Rating', properties, (p) => p['rating']?.toStringAsFixed(1) ?? 'N/A'),
            _buildDataRow(theme, 'Furnishing', properties, (p) => p['furnishing'] ?? 'N/A'),
            _buildDataRow(theme, 'Type', properties, (p) => p['property_type'] ?? ''),
          ],
        ),
      );
    }
  }

  DataRow _buildDataRow(ThemeData theme, String feature, List<Map<String, dynamic>> properties, Function getValue) {
    return DataRow(
      cells: [
        DataCell(Text(feature, style: TextStyle(fontWeight: FontWeight.w600))),
        ...properties.map((p) => DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              getValue(p),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildMobileRow(ThemeData theme, Map<String, dynamic> property, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          property['title'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('₹${property['price_per_month'] ?? 0}/month'),
            Text('${property['bedrooms'] ?? 0} Beds, ${property['bathrooms'] ?? 0} Baths'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailScreen(property: property),
            ),
          ),
        ),
      ),
    );
  }
}