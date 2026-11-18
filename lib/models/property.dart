import 'package:supabase_flutter/supabase_flutter.dart';

class Property {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String? address;
  final String? city;
  final double pricePerMonth;
  final int? bedrooms;
  final int? bathrooms;
  final String? propertyType;
  final String? furnishing;
  final List<String>? amenities;
  final List<String>? images;
  final bool? isAvailable;
  final DateTime createdAt;
  final String? listingType;
  final String? pincode;
  final int? viewCount;
  final bool? isFeatured;
  final String? status;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.address,
    this.city,
    required this.pricePerMonth,
    this.bedrooms,
    this.bathrooms,
    this.propertyType,
    this.furnishing,
    this.amenities,
    this.images,
    this.isAvailable,
    required this.createdAt,
    this.listingType,
    this.pincode,
    this.viewCount,
    this.isFeatured,
    this.status,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      pricePerMonth: (json['price_per_month'] as num).toDouble(),
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      propertyType: json['property_type'] as String?,
      furnishing: json['furnishing'] as String?,
      amenities: (json['amenities'] as List?)?.cast<String>(),
      images: (json['images'] as List?)?.cast<String>(),
      isAvailable: json['is_available'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
      listingType: json['listing_type'] as String?,
      pincode: json['pincode'] as String?,
      viewCount: json['view_count'] as int?,
      isFeatured: json['is_featured'] as bool?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'address': address,
      'city': city,
      'price_per_month': pricePerMonth,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'property_type': propertyType,
      'furnishing': furnishing,
      'amenities': amenities,
      'images': images,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'listing_type': listingType,
      'pincode': pincode,
      'view_count': viewCount,
      'is_featured': isFeatured,
      'status': status,
    };
  }

  Property copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? address,
    String? city,
    double? pricePerMonth,
    int? bedrooms,
    int? bathrooms,
    String? propertyType,
    String? furnishing,
    List<String>? amenities,
    List<String>? images,
    bool? isAvailable,
    DateTime? createdAt,
    String? listingType,
    String? pincode,
    int? viewCount,
    bool? isFeatured,
    String? status,
  }) {
    return Property(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      propertyType: propertyType ?? this.propertyType,
      furnishing: furnishing ?? this.furnishing,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      listingType: listingType ?? this.listingType,
      pincode: pincode ?? this.pincode,
      viewCount: viewCount ?? this.viewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
    );
  }

  String get formattedPrice {
    return '₹${pricePerMonth.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  String get listingTypeLabel {
    switch (listingType?.toLowerCase()) {
      case 'rent':
        return 'RENT';
      case 'sale':
        return 'SALE';
      default:
        return listingType?.toUpperCase() ?? 'N/A';
    }
  }

  String get furnishingLabel {
    switch (furnishing?.toLowerCase()) {
      case 'furnished':
        return 'Furnished';
      case 'semi':
        return 'Semi-Furnished';
      case 'unfurnished':
        return 'Unfurnished';
      default:
        return 'N/A';
    }
  }

  String get mainImageUrl {
    return images?.isNotEmpty == true ? images!.first : '';
  }

  bool get hasImages => images?.isNotEmpty == true;
}