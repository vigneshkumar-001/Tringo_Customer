
class HomeResponse {
  final bool status;
  final HomeData data;

  const HomeResponse({required this.status, required this.data});

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      status: json['status'] ?? false,
      data: HomeData.fromJson(json['data'] ?? const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}

// -----------------------------------------------------------------------------
// HOME DATA
// -----------------------------------------------------------------------------
class HomeData {
  final AppUser user;
  final String? city;
  final GeoPoint coordinates;
  final List<ShopCategory> shopCategories;
  final List<CategoryItem> categories;
  final List<HomeBanner> banners;
  final List<dynamic> featuredOffers;
  final List<dynamic> surpriseOffers;
  final List<ListingItem> services;
  final List<ListingItem> trendingShops;
  final List<dynamic> foodOffers;

  const HomeData({
    required this.user,
    required this.city,
    required this.coordinates,
    required this.shopCategories,
    required this.categories,
    required this.banners,
    required this.featuredOffers,
    required this.surpriseOffers,
    required this.services,
    required this.trendingShops,
    required this.foodOffers,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      user: AppUser.fromJson(json['user'] ?? const {}),
      city: json['city'],
      coordinates: GeoPoint.fromJson(json['coordinates'] ?? const {}),
      shopCategories: (json['shopCategories'] as List<dynamic>? ?? [])
          .map((e) => ShopCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      banners: (json['banners'] as List<dynamic>? ?? [])
          .map((e) => HomeBanner.fromJson(e as Map<String, dynamic>))
          .toList(),
      featuredOffers: (json['featuredOffers'] as List<dynamic>? ?? []),
      surpriseOffers: (json['surpriseOffers'] as List<dynamic>? ?? []),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => ListingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      trendingShops: (json['trendingShops'] as List<dynamic>? ?? [])
          .map((e) => ListingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      foodOffers: (json['foodOffers'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'city': city,
      'coordinates': coordinates.toJson(),
      'shopCategories': shopCategories.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'banners': banners.map((e) => e.toJson()).toList(),
      'featuredOffers': featuredOffers,
      'surpriseOffers': surpriseOffers,
      'services': services.map((e) => e.toJson()).toList(),
      'trendingShops': trendingShops.map((e) => e.toJson()).toList(),
      'foodOffers': foodOffers,
    };
  }
}

// -----------------------------------------------------------------------------
// USER + GEO
// -----------------------------------------------------------------------------
class AppUser {
  final String id;
  final String name;
  final String email;
  final String dob;
  final String gender;
  final String phoneNumber;
  final String? avatarUrl;
  final int coins;
  final String referralCode;
  final String tier;
  final bool profileComplete;
  final GeoPoint location;

  const AppUser({
    required this.id,
    required this.name,
    required this. gender ,
    required this.  email  ,
    required this.  dob   ,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.coins,
    required this.referralCode,
    required this.tier,
    required this.location,
    required this.profileComplete,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
       dob : json['dob'] ?? '',
       email : json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
      coins: json['coins'] ?? 0,
      referralCode: json['referralCode'] ?? '',
      tier: json['tier'] ?? '',
      profileComplete: json['profileComplete'] ?? '',
      location: GeoPoint.fromJson(json['location'] ?? const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'dob': dob,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'coins': coins,
      'referralCode': referralCode,
      'profileComplete': profileComplete,
      'tier': tier,
      'location': location.toJson(),
    };
  }
}

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint({required this.latitude, required this.longitude});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}

// -----------------------------------------------------------------------------
// SHOP CATEGORIES + CATEGORIES
// -----------------------------------------------------------------------------
class ShopCategory {
  final String slug;
  final String name;
  final int count;

  const ShopCategory({
    required this.slug,
    required this.name,
    required this.count,
  });

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    return ShopCategory(
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'slug': slug, 'name': name, 'count': count};
  }
}

/// `categories` in the response have SAME shape as `shopCategories`
class CategoryItem {
  final String slug;
  final String name;
  final int count;

  const CategoryItem({
    required this.slug,
    required this.name,
    required this.count,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'slug': slug, 'name': name, 'count': count};
  }
}

// -----------------------------------------------------------------------------
// BANNERS
// -----------------------------------------------------------------------------
class HomeBanner {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? ctaLabel;
  final String? ctaLink;
  final String? city;
  final bool isActive;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HomeBanner({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.ctaLabel,
    this.ctaLink,
    this.city,
    required this.isActive,
    required this.displayOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      imageUrl: json['imageUrl'] ?? '',
      ctaLabel: json['ctaLabel'],
      ctaLink: json['ctaLink'],
      city: json['city'],
      isActive: json['isActive'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'ctaLabel': ctaLabel,
      'ctaLink': ctaLink,
      'city': city,
      'isActive': isActive,
      'displayOrder': displayOrder,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// -----------------------------------------------------------------------------
// LISTINGS (services + trendingShops)
// -----------------------------------------------------------------------------
class ListingItem {
  final String id;
  final String englishName;
  final String tamilName;
  final String category;
  final String subCategory;
  final String addressEn;
  final String addressTa;
  final String city;
  final String state;
  final String country;
  final num rating;
  final int ratingCount;
  final bool isTrusted;
  final bool doorDelivery;
  final String shopKind;
  final String primaryPhone;
  final double distanceKm;
  final String distanceLabel;
  final String? openLabel;
  final bool isOpen;
  final String? primaryImageUrl;
  final String ownershipType;
  final String? closeTime;

  /// new: from JSON strings "9.9144640"
  final double gpsLatitude;
  final double gpsLongitude;

  /// parsed from `shopWeeklyHours` in JSON
  final List<ShopWeeklyHour> weeklyHours;

  const ListingItem({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.category,
    required this.subCategory,
    required this.addressEn,
    required this.addressTa,
    required this.city,
    required this.state,
    required this.country,
    required this.rating,
    required this.ratingCount,
    required this.isTrusted,
    required this.doorDelivery,
    required this.shopKind,
    required this.primaryPhone,
    required this.distanceKm,
    required this.distanceLabel,
    required this.openLabel,
    required this.isOpen,
    required this.primaryImageUrl,
    required this.ownershipType,
    this.closeTime,
    required this.gpsLatitude,
    required this.gpsLongitude,
    this.weeklyHours = const [],
  });

  factory ListingItem.fromJson(Map<String, dynamic> json) {
    final latStr = json['gpsLatitude']?.toString();
    final lngStr = json['gpsLongitude']?.toString();

    return ListingItem(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      addressEn: json['addressEn'] ?? '',
      addressTa: json['addressTa'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      isTrusted: json['isTrusted'] ?? false,
      doorDelivery: json['doorDelivery'] ?? false,
      shopKind: json['shopKind'] ?? '',
      primaryPhone: json['primaryPhone'] ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      distanceLabel: json['distanceLabel'] ?? '',
      openLabel: json['openLabel'],
      isOpen: json['isOpen'] ?? false,
      primaryImageUrl: json['primaryImageUrl'],
      ownershipType: json['ownershipType'] as String? ?? '',
      closeTime: json['closeTime'] as String? ?? '',
      gpsLatitude: latStr != null ? double.tryParse(latStr) ?? 0.0 : 0.0,
      gpsLongitude: lngStr != null ? double.tryParse(lngStr) ?? 0.0 : 0.0,
      weeklyHours:
          (json['shopWeeklyHours'] as List<dynamic>?)
              ?.map((e) => ShopWeeklyHour.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'englishName': englishName,
      'tamilName': tamilName,
      'category': category,
      'subCategory': subCategory,
      'addressEn': addressEn,
      'addressTa': addressTa,
      'city': city,
      'state': state,
      'country': country,
      'rating': rating,
      'ratingCount': ratingCount,
      'isTrusted': isTrusted,
      'doorDelivery': doorDelivery,
      'shopKind': shopKind,
      'primaryPhone': primaryPhone,
      'distanceKm': distanceKm,
      'distanceLabel': distanceLabel,
      'openLabel': openLabel,
      'isOpen': isOpen,
      'primaryImageUrl': primaryImageUrl,
      'ownershipType': ownershipType,
      'closeTime': closeTime,
      'gpsLatitude': gpsLatitude,
      'gpsLongitude': gpsLongitude,
      'shopWeeklyHours': weeklyHours.map((e) => e.toJson()).toList(),
    };
  }

  String get ownershipTypeLabel {
    if (ownershipType == 'COMPANY') return 'Company';
    if (ownershipType == 'INDIVIDUAL') return 'Individual';
    return ownershipType;
  }
}

// -----------------------------------------------------------------------------
// WEEKLY HOURS
// -----------------------------------------------------------------------------
class ShopWeeklyHour {
  final String? day;
  final String? opensAt;
  final String? closesAt;
  final bool? closed;

  const ShopWeeklyHour({this.day, this.opensAt, this.closesAt, this.closed});

  factory ShopWeeklyHour.fromJson(Map<String, dynamic> json) {
    return ShopWeeklyHour(
      day: json['day'],
      opensAt: json['opensAt'],
      closesAt: json['closesAt'],
      closed: _parseBool(json['closed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'opensAt': opensAt,
      'closesAt': closesAt,
      'closed': closed,
    };
  }
}

// -----------------------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------------------
bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;

  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }

  if (value is String) {
    final lower = value.toLowerCase().trim();
    if (lower == 'true' || lower == 'yes' || lower == '1') return true;
    if (lower == 'false' || lower == 'no' || lower == '0') return false;
  }

  return null;
}
