// home_response.dart
// NOTE: Do NOT add `part` or `part of` here.

class HomeResponse {
  final bool status;
  final HomeData data;

  const HomeResponse({required this.status, required this.data});

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      status: json['status'] == true,
      data: HomeData.fromJson(
        (json['data'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'data': data.toJson()};
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

  final List<Offer> featuredOffers;
  final List<Offer> surpriseOffers;

  final List<ListingItem> services;
  final List<ListingItem> trendingShops;

  final List<dynamic> foodOffers;
  final TCoin? tcoin;

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
    required this.tcoin,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      user: AppUser.fromJson(_asMap(json['user'])),
      city: json['city'] as String?,
      coordinates: GeoPoint.fromJson(_asMap(json['coordinates'])),

      shopCategories: (_asList(
        json['shopCategories'],
      )).map((e) => ShopCategory.fromJson(_asMap(e))).toList(),

      categories: (_asList(
        json['categories'],
      )).map((e) => CategoryItem.fromJson(_asMap(e))).toList(),

      banners: (_asList(
        json['banners'],
      )).map((e) => HomeBanner.fromJson(_asMap(e))).toList(),

      featuredOffers: (_asList(
        json['featuredOffers'],
      )).map((e) => Offer.fromJson(_asMap(e))).toList(),

      surpriseOffers: (_asList(
        json['surpriseOffers'],
      )).map((e) => Offer.fromJson(_asMap(e))).toList(),

      services: (_asList(
        json['services'],
      )).map((e) => ListingItem.fromJson(_asMap(e))).toList(),

      trendingShops: (_asList(
        json['trendingShops'],
      )).map((e) => ListingItem.fromJson(_asMap(e))).toList(),

      foodOffers: _asList(json['foodOffers']),
      tcoin: json['tcoin'] is Map
          ? TCoin.fromJson(_asMap(json['tcoin']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'city': city,
    'coordinates': coordinates.toJson(),
    'shopCategories': shopCategories.map((e) => e.toJson()).toList(),
    'categories': categories.map((e) => e.toJson()).toList(),
    'banners': banners.map((e) => e.toJson()).toList(),
    'featuredOffers': featuredOffers.map((e) => e.toJson()).toList(),
    'surpriseOffers': surpriseOffers.map((e) => e.toJson()).toList(),
    'services': services.map((e) => e.toJson()).toList(),
    'trendingShops': trendingShops.map((e) => e.toJson()).toList(),
    'foodOffers': foodOffers,
    'tcoin': tcoin?.toJson(),
  };
}

// -----------------------------------------------------------------------------
// USER + GEO
// -----------------------------------------------------------------------------
class AppUser {
  final String id;
  final String? name;
  final String? email;
  final String? dob;
  final String? gender;
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
    required this.gender,
    required this.email,
    required this.dob,
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
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      avatarUrl: json['avatarUrl'] as String?,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      referralCode: (json['referralCode'] ?? '').toString(),
      tier: (json['tier'] ?? '').toString(),
      profileComplete: _parseBool(json['profileComplete']) ?? false,
      location: GeoPoint.fromJson(_asMap(json['location'])),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'dob': dob,
    'gender': gender,
    'phoneNumber': phoneNumber,
    'avatarUrl': avatarUrl,
    'coins': coins,
    'referralCode': referralCode,
    'tier': tier,
    'profileComplete': profileComplete,
    'location': location.toJson(),
  };
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

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
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
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'slug': slug, 'name': name, 'count': count};
}

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
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'slug': slug, 'name': name, 'count': count};
}


// -----------------------------------------------------------------------------
// BANNERS
// -----------------------------------------------------------------------------
class HomeBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? ctaLabel;
  final String? ctaLink;
  final String? city;
  final bool isActive;
  final int displayOrder;
  final String? shopId;
  final String type; // RETAIL / PRODUCT / SERVICE
  final DateTime createdAt;
  final DateTime updatedAt;

  const HomeBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.ctaLabel,
    this.ctaLink,
    this.city,
    required this.isActive,
    required this.displayOrder,
    this.shopId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: _sanitizeUrl(json['imageUrl']),
      ctaLabel: json['ctaLabel'] as String?,
      ctaLink: json['ctaLink'] as String?,
      city: json['city'] as String?,
      isActive: json['isActive'] == true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      shopId: json['shopId'] as String?,
      type: (json['type'] ?? '').toString().toUpperCase(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'imageUrl': imageUrl,
    'ctaLabel': ctaLabel,
    'ctaLink': ctaLink,
    'city': city,
    'isActive': isActive,
    'displayOrder': displayOrder,
    'shopId': shopId,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}


// class HomeBanner {
//   final String id;
//   final String title;
//   final String? subtitle;
//   final String imageUrl; // sanitized
//   final String? ctaLabel;
//   final String? ctaLink;
//   final String? city;
//   final bool isActive;
//   final int displayOrder;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   const HomeBanner({
//     required this.id,
//     required this.title,
//     this.subtitle,
//     required this.imageUrl,
//     this.ctaLabel,
//     this.ctaLink,
//     this.city,
//     required this.isActive,
//     required this.displayOrder,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory HomeBanner.fromJson(Map<String, dynamic> json) {
//     return HomeBanner(
//       id: (json['id'] ?? '').toString(),
//       title: (json['title'] ?? '').toString(),
//       subtitle: json['subtitle'] as String?,
//       imageUrl: _sanitizeUrl(json['imageUrl']?.toString()),
//       ctaLabel: json['ctaLabel'] as String?,
//       ctaLink: json['ctaLink'] as String?,
//       city: json['city'] as String?,
//       isActive: json['isActive'] == true,
//       displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
//       createdAt: json['createdAt'] != null
//           ? DateTime.tryParse(json['createdAt'].toString())
//           : null,
//       updatedAt: json['updatedAt'] != null
//           ? DateTime.tryParse(json['updatedAt'].toString())
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'title': title,
//     'subtitle': subtitle,
//     'imageUrl': imageUrl,
//     'ctaLabel': ctaLabel,
//     'ctaLink': ctaLink,
//     'city': city,
//     'isActive': isActive,
//     'displayOrder': displayOrder,
//     'createdAt': createdAt?.toIso8601String(),
//     'updatedAt': updatedAt?.toIso8601String(),
//   };
// }

class Offer {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? branchId;
  final String? bannerUrl; // sanitized

  final OfferShop? shop;

  final String type; // APP / SURPRISE
  final String title;
  final String description;

  final num? discountPercentage;

  final DateTime? availableFrom;
  final DateTime? availableTo;
  final DateTime? announcementAt;

  final String? campaignId;
  final int? maxCoupons;

  final String status; // ACTIVE / DRAFT / EXPIRED
  final bool autoApply;
  final dynamic targetSegment;

  // ✅ NEW (only present for surpriseOffers sometimes)
  final double? distanceKm;
  final String? distanceLabel;
  final String? closeTime;

  const Offer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.branchId,
    required this.bannerUrl,
    required this.shop,
    required this.type,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.availableFrom,
    required this.availableTo,
    required this.announcementAt,
    required this.campaignId,
    required this.maxCoupons,
    required this.status,
    required this.autoApply,
    required this.targetSegment,
    this.distanceKm,
    this.distanceLabel,
    this.closeTime,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: (json['id'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,

      branchId: json['branchId']?.toString(),
      bannerUrl: _sanitizeUrl(json['bannerUrl']?.toString()),

      shop: json['shop'] is Map
          ? OfferShop.fromJson(_asMap(json['shop']))
          : null,

      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),

      discountPercentage: json['discountPercentage'] as num?,

      availableFrom: json['availableFrom'] != null
          ? DateTime.tryParse(json['availableFrom'].toString())
          : null,
      availableTo: json['availableTo'] != null
          ? DateTime.tryParse(json['availableTo'].toString())
          : null,
      announcementAt: json['announcementAt'] != null
          ? DateTime.tryParse(json['announcementAt'].toString())
          : null,

      campaignId: json['campaignId']?.toString(),
      maxCoupons: (json['maxCoupons'] as num?)?.toInt(),

      status: (json['status'] ?? '').toString(),
      autoApply: _parseBool(json['autoApply']) ?? false,
      targetSegment: json['targetSegment'],

      // ✅ NEW fields
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      distanceLabel: json['distanceLabel']?.toString(),
      closeTime: json['closeTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'branchId': branchId,
    'bannerUrl': bannerUrl,
    'shop': shop?.toJson(),
    'type': type,
    'title': title,
    'description': description,
    'discountPercentage': discountPercentage,
    'availableFrom': availableFrom?.toIso8601String(),
    'availableTo': availableTo?.toIso8601String(),
    'announcementAt': announcementAt?.toIso8601String(),
    'campaignId': campaignId,
    'maxCoupons': maxCoupons,
    'status': status,
    'autoApply': autoApply,
    'targetSegment': targetSegment,

    // ✅ NEW fields
    'distanceKm': distanceKm,
    'distanceLabel': distanceLabel,
    'closeTime': closeTime,
  };
}

class OfferShop {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String category;
  final String subCategory;
  final String shopKind;

  final String englishName;
  final String tamilName;

  final String? descriptionEn;
  final String? descriptionTa;

  final String addressEn;
  final String addressTa;

  final double gpsLatitude;
  final double gpsLongitude;

  final String primaryPhone;
  final String? alternatePhone;
  final String? contactEmail;
  final String? ownerImageUrl;

  final bool doorDelivery;
  final bool isTrusted;

  final String city;
  final String state;
  final String country;
  final String? postalCode;

  final List<ShopWeeklyHour> weeklyHours;

  final String? averageRating;

  final double? distanceKm;
  final String? distanceLabel;
  final String? closeTime;

  final int reviewCount;
  final String status;

  const OfferShop({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.subCategory,
    required this.shopKind,
    required this.englishName,
    required this.tamilName,
    required this.descriptionEn,
    required this.descriptionTa,
    required this.addressEn,
    required this.addressTa,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.primaryPhone,
    required this.alternatePhone,
    required this.contactEmail,
    required this.ownerImageUrl,
    required this.doorDelivery,
    required this.isTrusted,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.weeklyHours,
    required this.averageRating,
    required this.reviewCount,
    required this.status,
    this.distanceKm,
    this.distanceLabel,
    this.closeTime,
  });

  factory OfferShop.fromJson(Map<String, dynamic> json) {
    final latStr = json['gpsLatitude']?.toString();
    final lngStr = json['gpsLongitude']?.toString();

    return OfferShop(
      id: (json['id'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      category: (json['category'] ?? '').toString(),
      subCategory: (json['subCategory'] ?? '').toString(),
      shopKind: (json['shopKind'] ?? '').toString(),
      englishName: (json['englishName'] ?? '').toString(),
      tamilName: (json['tamilName'] ?? '').toString(),
      descriptionEn: json['descriptionEn']?.toString(),
      descriptionTa: json['descriptionTa']?.toString(),
      addressEn: (json['addressEn'] ?? '').toString(),
      addressTa: (json['addressTa'] ?? '').toString(),
      gpsLatitude: latStr != null ? double.tryParse(latStr) ?? 0.0 : 0.0,
      gpsLongitude: lngStr != null ? double.tryParse(lngStr) ?? 0.0 : 0.0,
      primaryPhone: (json['primaryPhone'] ?? '').toString(),
      alternatePhone: json['alternatePhone']?.toString(),
      contactEmail: json['contactEmail']?.toString(),
      ownerImageUrl: _sanitizeUrl(json['ownerImageUrl']?.toString()),
      doorDelivery: _parseBool(json['doorDelivery']) ?? false,
      isTrusted: _parseBool(json['isTrusted']) ?? false,
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      postalCode: json['postalCode']?.toString(),
      weeklyHours: (_asList(
        json['weeklyHours'],
      )).map((e) => ShopWeeklyHour.fromJson(_asMap(e))).toList(),
      averageRating: json['averageRating']?.toString(),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      distanceLabel: json['distanceLabel'] ?? ''.toString(),
      closeTime: json['closeTime'] ?? ''.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'category': category,
    'subCategory': subCategory,
    'shopKind': shopKind,
    'englishName': englishName,
    'tamilName': tamilName,
    'descriptionEn': descriptionEn,
    'descriptionTa': descriptionTa,
    'addressEn': addressEn,
    'addressTa': addressTa,
    'gpsLatitude': gpsLatitude.toString(),
    'gpsLongitude': gpsLongitude.toString(),
    'primaryPhone': primaryPhone,
    'alternatePhone': alternatePhone,
    'contactEmail': contactEmail,
    'ownerImageUrl': ownerImageUrl,
    'doorDelivery': doorDelivery,
    'isTrusted': isTrusted,
    'city': city,
    'state': state,
    'country': country,
    'postalCode': postalCode,
    'weeklyHours': weeklyHours.map((e) => e.toJson()).toList(),
    'averageRating': averageRating,
    'reviewCount': reviewCount,
    'status': status,
    'distanceKm': distanceKm,
    'distanceLabel': distanceLabel,
    'closeTime': closeTime,
  };
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

  final String? primaryImageUrl; // sanitized

  final String ownershipType;

  final String? closeTime;
  final String? opensAt;
  final String? closesAt;

  final double gpsLatitude;
  final double gpsLongitude;

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
    required this.closeTime,
    required this.opensAt,
    required this.closesAt,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.weeklyHours,
  });

  factory ListingItem.fromJson(Map<String, dynamic> json) {
    final latStr = json['gpsLatitude']?.toString();
    final lngStr = json['gpsLongitude']?.toString();

    return ListingItem(
      id: (json['id'] ?? '').toString(),
      englishName: (json['englishName'] ?? '').toString(),
      tamilName: (json['tamilName'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      subCategory: (json['subCategory'] ?? '').toString(),
      addressEn: (json['addressEn'] ?? '').toString(),
      addressTa: (json['addressTa'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      rating: (json['rating'] as num?) ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      isTrusted: _parseBool(json['isTrusted']) ?? false,
      doorDelivery: _parseBool(json['doorDelivery']) ?? false,
      shopKind: (json['shopKind'] ?? '').toString(),
      primaryPhone: (json['primaryPhone'] ?? '').toString(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      distanceLabel: (json['distanceLabel'] ?? '').toString(),
      openLabel: json['openLabel']?.toString(),
      isOpen: _parseBool(json['isOpen']) ?? false,
      primaryImageUrl: _sanitizeUrl(json['primaryImageUrl']?.toString()),
      ownershipType: (json['ownershipType'] ?? '').toString(),
      closeTime: json['closeTime']?.toString(),
      opensAt: json['opensAt']?.toString(),
      closesAt: json['closesAt']?.toString(),
      gpsLatitude: latStr != null ? double.tryParse(latStr) ?? 0.0 : 0.0,
      gpsLongitude: lngStr != null ? double.tryParse(lngStr) ?? 0.0 : 0.0,
      weeklyHours: (_asList(
        json['shopWeeklyHours'],
      )).map((e) => ShopWeeklyHour.fromJson(_asMap(e))).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
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
    'opensAt': opensAt,
    'closesAt': closesAt,
    'gpsLatitude': gpsLatitude,
    'gpsLongitude': gpsLongitude,
    'shopWeeklyHours': weeklyHours.map((e) => e.toJson()).toList(),
  };
}

// -----------------------------------------------------------------------------
// TCOIN
// -----------------------------------------------------------------------------
class TCoin {
  final int balance;
  final String uid;
  final num rate;

  const TCoin({required this.balance, required this.uid, required this.rate});

  factory TCoin.fromJson(Map<String, dynamic> json) {
    return TCoin(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      uid: (json['uid'] ?? '').toString(),
      rate: (json['rate'] as num?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "balance": balance,
    "uid": uid,
    "rate": rate,
  };
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
      day: json['day']?.toString(),
      opensAt: json['opensAt']?.toString(),
      closesAt: json['closesAt']?.toString(),
      closed: _parseBool(json['closed']),
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'opensAt': opensAt,
    'closesAt': closesAt,
    'closed': closed,
  };
}

// -----------------------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------------------
Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.cast<String, dynamic>();
  return const {};
}

List<dynamic> _asList(dynamic v) {
  if (v is List) return v;
  return const [];
}

/// Fixes urls like:
/// - null -> null
/// - "https:////next...." -> "https://next...."
/// - "http:////..." -> "http://..."
///
///
// String _sanitizeUrl(String? url) {
//   final u = url?.trim();
//   if (u == null || u.isEmpty) return "";
//   return u;
// }
String _sanitizeUrl(dynamic value) {
  if (value == null) return '';
  final url = value.toString().trim();
  return url.startsWith('http') ? url : '';
}

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


