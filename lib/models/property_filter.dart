class PropertyFilter {
  String? city;
  double? minPrice;
  double? maxPrice;
  int? minBedrooms;
  int? minBathrooms;
  String? propertyType;
  String? furnishing;

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
}