import 'package:flutter/material.dart';
import '../models/property_filter.dart';
import '../widgets/common/app_text_field.dart';
import '../widgets/common/app_button.dart';
import '../theme/app_theme.dart';

class FilterSheet {
  static Future<PropertyFilter?> show(BuildContext context, PropertyFilter current) {
    return showModalBottomSheet<PropertyFilter>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FilterSheet(initial: current),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final PropertyFilter initial;
  const _FilterSheet({required this.initial});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final PropertyFilter f;
  late final TextEditingController cityCtrl;
  late final TextEditingController bedsCtrl;
  late final TextEditingController typeCtrl;
  late RangeValues priceRange;
  int bedrooms = 0;
  String? propertyType;

  void saveState() {
    final city = cityCtrl.text.trim();
    // Carry over everything this sheet does not edit (sort order, furnishing,
    // min bathrooms) so applying filters does not silently reset them.
    final output = PropertyFilter()
      ..listingType = f.listingType
      ..searchQuery = f.searchQuery
      ..sortOrder = f.sortOrder
      ..city = city.isEmpty ? null : city
      ..minPrice = priceRange.start > 0 ? priceRange.start : null
      ..maxPrice = priceRange.end < 500000 ? priceRange.end : null
      ..minBedrooms = bedrooms > 0 ? bedrooms : null
      ..minBathrooms = f.minBathrooms
      ..furnishing = f.furnishing
      ..propertyType = propertyType;
    Navigator.pop(context, output);
  }

  void reset() {
    setState(() {
      cityCtrl.clear();
      priceRange = const RangeValues(0, 500000);
      bedrooms = 0;
      propertyType = null;
      _syncDisplay();
    });
  }

  /// Keeps the read-only display fields in step with the selected values.
  void _syncDisplay() {
    bedsCtrl.text = bedrooms > 0 ? 'At least $bedrooms bedrooms' : '';
    typeCtrl.text = propertyType ?? 'Any type';
  }

  @override
  void initState() {
    super.initState();
    f = widget.initial;
    cityCtrl = TextEditingController(text: f.city ?? '');
    bedsCtrl = TextEditingController();
    typeCtrl = TextEditingController();
    priceRange = RangeValues(f.minPrice ?? 0, f.maxPrice ?? 500000);
    bedrooms = f.minBedrooms ?? 0;
    propertyType = f.propertyType;
    _syncDisplay();
  }

  @override
  void dispose() {
    cityCtrl.dispose();
    bedsCtrl.dispose();
    typeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: AppSpacing.lg),

          // Title & Actions
          Row(
            children: [
              Text('Filters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: reset,
                child: Text('Reset', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // City Input
          AppTextField(
            controller: cityCtrl,
            label: 'City',
            hint: 'Enter city name',
            prefixIcon: Icons.location_city,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Price Range
          Text('Max Price', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: theme.dividerColor, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '₹${priceRange.end.round()}',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => priceRange = const RangeValues(0, 500000));
                  },
                  icon: const Icon(Icons.restore, size: 16),
                  label: Text('Reset'),
                ),
              ],
            ),
          ),
          RangeSlider(
            values: priceRange,
            min: 0,
            max: 500000,
            divisions: 100,
            activeColor: theme.colorScheme.primary,
            onChanged: (v) => setState(() => priceRange = v),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Bedrooms
          AppTextField(
            controller: bedsCtrl,
            label: 'Min Bedrooms',
            hint: 'No minimum',
            prefixIcon: Icons.bed_outlined,
            readOnly: true,
            onTap: () => _showBedroomOptions(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Property Type
          AppTextField(
            controller: typeCtrl,
            label: 'Property Type',
            hint: 'Select type',
            prefixIcon: Icons.apartment_outlined,
            readOnly: true,
            onTap: () => _showTypeOptions(),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AppPrimaryButton(
              label: 'Apply Filters',
              onPressed: saveState,
              icon: Icons.tune,
            ),
          ),
        ],
      ),
    );
  }

  void _showBedroomOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select Minimum Bedrooms', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [0, 1, 2, 3, 4, 5].map((n) {
                final isSelected = bedrooms == n;
                return AppPillBadge(
                  label: n == 0 ? 'Any' : '$n+',
                  icon: Icons.bed_outlined,
                  selected: isSelected,
                  onTap: () {
                    setState(() => bedrooms = n);
                    _syncDisplay();
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: AppPrimaryButton(
                label: 'Done',
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select Property Type', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: const [
                Segmented<String>(value: 'Apartment', label: 'Apartment', icon: Icons.build_circle_outlined),
                Segmented<String>(value: 'Gated Society', label: 'Gated Society', icon: Icons.home_work_outlined),
                Segmented<String>(value: 'Gated Community Villa', label: 'Gated Community Villa', icon: Icons.villa_outlined),
                Segmented<String>(value: 'Independent House/Villa', label: 'Independent House/Villa', icon: Icons.house_outlined),
              ].map((segment) {
                final isSelected = propertyType == segment.value;
                return AppPillBadge(
                  label: segment.label,
                  icon: segment.icon,
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      propertyType = propertyType == segment.value ? null : segment.value;
                    });
                    _syncDisplay();
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: AppPrimaryButton(
                label: 'Done',
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Segmented<T> {
  final T value;
  final String label;
  final IconData icon;
  const Segmented({required this.value, required this.label, required this.icon});
}