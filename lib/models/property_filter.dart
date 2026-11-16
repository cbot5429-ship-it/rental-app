class FilterItem {
  final String label;
  final String key;
  final dynamic value;
  final bool removable;
  final String? icon;

  const FilterItem({
    required this.label,
    required this.key,
    this.value,
    this.removable = true,
    this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FilterItem && other.key == key);

  @override
  int get hashCode => key.hashCode;
}

class PropertyFilter {
  String? city;
  double? minPrice;
  double? maxPrice;
  int? minBedrooms;
  int? minBathrooms;
  String? propertyType;
  String? furnishing;
  String? listingType; // 'buy', 'rent', 'commercial'
  String? searchQuery;
  String sortOrder = 'newest'; // 'newest', 'price_asc', 'price_desc'

  int get activeCount {
    int n = 0;
    if (city?.isNotEmpty ?? false) n++;
    if (minPrice != null) n++;
    if (maxPrice != null) n++;
    if (minBedrooms != null) n++;
    if (minBathrooms != null) n++;
    if (propertyType != null) n++;
    if (furnishing != null) n++;
    return n;
  }

  List<FilterItem> get activeFilters {
    final filters = <FilterItem>[];
    if (city?.isNotEmpty ?? false) {
      filters.add(FilterItem(label: 'City: $city', key: 'city', value: city, icon: '📍'));
    }
    if (minPrice != null) {
      filters.add(FilterItem(label: 'Min: ₹${minPrice!.round()}', key: 'minPrice', value: minPrice, icon: '💰'));
    }
    if (maxPrice != null) {
      filters.add(FilterItem(label: 'Max: ₹${maxPrice!.round()}', key: 'maxPrice', value: maxPrice, icon: '💰'));
    }
    if (minBedrooms != null) {
      filters.add(FilterItem(label: '$minBedrooms+ Beds', key: 'minBedrooms', value: minBedrooms, icon: '🛏️'));
    }
    if (minBathrooms != null) {
      filters.add(FilterItem(label: '$minBathrooms+ Baths', key: 'minBathrooms', value: minBathrooms, icon: '🚿'));
    }
    if (propertyType != null) {
      filters.add(FilterItem(label: propertyType!, key: 'propertyType', value: propertyType, icon: '🏠'));
    }
    if (furnishing != null) {
      filters.add(FilterItem(label: furnishing!, key: 'furnishing', value: furnishing, icon: '🪑'));
    }
    return filters;
  }

  void removeFilter(FilterItem item) {
    switch (item.key) {
      case 'city':
        city = null;
        break;
      case 'minPrice':
        minPrice = null;
        break;
      case 'maxPrice':
        maxPrice = null;
        break;
      case 'minBedrooms':
        minBedrooms = null;
        break;
      case 'minBathrooms':
        minBathrooms = null;
        break;
      case 'propertyType':
        propertyType = null;
        break;
      case 'furnishing':
        furnishing = null;
        break;
    }
  }

  void clear() {
    city = null;
    minPrice = null;
    maxPrice = null;
    minBedrooms = null;
    minBathrooms = null;
    propertyType = null;
    furnishing = null;
    searchQuery = null;
    sortOrder = 'newest';
  }
}