import 'package:flutter/material.dart';
import '../models/property_filter.dart';

Future<PropertyFilter?> showFilterSheet(BuildContext context, PropertyFilter current) {
  return showModalBottomSheet<PropertyFilter>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Filters', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(context, PropertyFilter()), child: const Text('Reset')),
              ],
            ),
            TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city), border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Text('Max Price: ₹${priceRange.end.round()}', style: const TextStyle(fontWeight: FontWeight.w600)),
            RangeSlider(
              values: priceRange,
              min: 0, max: 500000, divisions: 100,
              onChanged: (v) => setState(() => priceRange = v),
            ),
            DropdownButtonFormField<int>(
              value: bedrooms == 0 ? null : bedrooms,
              decoration: const InputDecoration(labelText: 'Min Bedrooms', border: OutlineInputBorder()),
              items: [1, 2, 3, 4, 5].map((n) => DropdownMenuItem(value: n, child: Text('$n+'))).toList(),
              onChanged: (v) => setState(() => bedrooms = v ?? 0),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: 'Property Type', border: OutlineInputBorder()),
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
              width: double.infinity, height: 50,
              child: FilledButton(
                onPressed: () {
                  final out = PropertyFilter()
                    ..listingType = f.listingType 
                    ..searchQuery = f.searchQuery 
                    ..city = cityCtrl.text
                    ..maxPrice = priceRange.end < 500000 ? priceRange.end : null
                    ..minBedrooms = bedrooms > 0 ? bedrooms : null
                    ..propertyType = type;
                  Navigator.pop(context, out);
                },
                child: const Text('Apply Filters', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}