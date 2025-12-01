class HomeResponse {
  final bool status;
  final HomeData data;

  const HomeResponse({
    required this.status,
    required this.data,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      status: json['status'] ?? false,
      data: HomeData.fromJson(json['data'] ?? const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class HomeData {
  final AppUser user;
  final String? city;
  final GeoPoint coordinates;
  final List<ShopCategory> shopCategories;
  final List<CategoryItem> categories;
  final List<dynamic> banners;
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
      banners: (json['banners'] as List<dynamic>? ?? []),
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
      'banners': banners,
      'featuredOffers': featuredOffers,
      'surpriseOffers': surpriseOffers,
      'services': services.map((e) => e.toJson()).toList(),
      'trendingShops': trendingShops.map((e) => e.toJson()).toList(),
      'foodOffers': foodOffers,
    };
  }
}

class AppUser {
  final String id;
  final String name;
  final String phoneNumber;
  final String? avatarUrl;
  final int coins;
  final String referralCode;
  final String tier;
  final GeoPoint location;

  const AppUser({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.coins,
    required this.referralCode,
    required this.tier,
    required this.location,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
      coins: json['coins'] ?? 0,
      referralCode: json['referralCode'] ?? '',
      tier: json['tier'] ?? '',
      location: GeoPoint.fromJson(json['location'] ?? const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'coins': coins,
      'referralCode': referralCode,
      'tier': tier,
      'location': location.toJson(),
    };
  }
}

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class ShopCategory {
  final String slug;
  final String name;
  final int count;
  final String type;

  const ShopCategory({
    required this.slug,
    required this.name,
    required this.count,
    required this.type,
  });

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    return ShopCategory(
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'count': count,
      'type': type,
    };
  }
}

class CategoryItem {
  final String id;
  final String name;
  final String slug;
  final String type;
  final int displayOrder;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.displayOrder,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      type: json['type'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'type': type,
      'displayOrder': displayOrder,
    };
  }
}

/// Used for both `services` and `trendingShops`
class ListingItem {
  final String id;
  final String englishName;
  final String tamilName;
  final String category;
  final String subCategory;
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

  const ListingItem({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.category,
    required this.subCategory,
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
  });

  factory ListingItem.fromJson(Map<String, dynamic> json) {
    return ListingItem(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'englishName': englishName,
      'tamilName': tamilName,
      'category': category,
      'subCategory': subCategory,
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
    };
  }
}
