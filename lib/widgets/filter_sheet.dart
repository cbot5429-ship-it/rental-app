import 'package:flutter/material.dart';
import '../models/property_filter.dart';

Future<PropertyFilter?> showFilterSheet(BuildContext context, PropertyFilter current) {
  return showModalBottomSheet<PropertyFilter>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FilterSheet(initial: current),
  );
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
  late RangeValues priceRange;
  int bedrooms = 0;
  String? type;

  @override
  void initState() {
    super.initState();
    f = widget.initial;
    cityCtrl = TextEditingController(text: f.city ?? '');
    priceRange = RangeValues(f.minPrice ?? 0, f.maxPrice ?? 500000);
    bedrooms = f.minBedrooms ?? 0;
    type = f.propertyType;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(context, PropertyFilter()), child: const Text('Reset')),
              ],
            ),
            TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city))),
            const SizedBox(height: 16),
            Text('Max Price: \$${priceRange.end.round()}'),
            RangeSlider(
              values: priceRange,
              min: 0, max: 500000, divisions: 100,
              onChanged: (v) => setState(() => priceRange = v),
            ),
            DropdownButtonFormField<int>(
              value: bedrooms == 0 ? null : bedrooms,
              decoration: const InputDecoration(labelText: 'Min Bedrooms'),
              items: [1, 2, 3, 4, 5].map((n) => DropdownMenuItem(value: n, child: Text('$n+'))).toList(),
              onChanged: (v) => setState(() => bedrooms = v ?? 0),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: 'Property Type'),
              items: const [
                DropdownMenuItem(value: 'Apartment', child: Text('Apartment')),
                DropdownMenuItem(value: 'Gated Society', child: Text('Gated Society')),
                DropdownMenuItem(value: 'Gated Community Villa', child: Text('Gated Community Villa')),
                DropdownMenuItem(value: 'Independent House/Villa', child: Text('Independent House/Villa')),
              ],
              onChanged: (v) => setState(() => type = v),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final out = PropertyFilter()
                    ..listingType = f.listingType // Keep the Buy/Rent/Commercial type
                    ..searchQuery = f.searchQuery // Keep the search query
                    ..city = cityCtrl.text
                    ..maxPrice = priceRange.end < 500000 ? priceRange.end : null
                    ..minBedrooms = bedrooms > 0 ? bedrooms : null
                    ..propertyType = type;
                  Navigator.pop(context, out);
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}