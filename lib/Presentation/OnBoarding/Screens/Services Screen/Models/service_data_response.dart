// ✅ Helpers (keep at TOP of this file)
int _toInt(dynamic v, {int def = 0}) {
  if (v == null) return def;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  if (v is String) {
    final i = int.tryParse(v);
    if (i != null) return i;
    final d = double.tryParse(v);
    if (d != null) return d.toInt();
  }
  return def;
}

double _toDouble(dynamic v, {double def = 0.0}) {
  if (v == null) return def;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? def;
  return def;
}

class ServiceDataResponse {
  final bool status;
  final ServiceDetailsData data;

  ServiceDataResponse({required this.status, required this.data});

  factory ServiceDataResponse.fromJson(Map<String, dynamic> json) {
    return ServiceDataResponse(
      status: json['status'] == true,
      data: ServiceDetailsData.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}

class ServiceDetailsData {
  final Service service;
  final ServiceShop shop;
  final SimilarServices similarServices;
  final List<SimilarServiceItem> peopleAlsoViewed;
  final ServiceReviews reviews;

  ServiceDetailsData({
    required this.service,
    required this.shop,
    required this.similarServices,
    required this.peopleAlsoViewed,
    required this.reviews,
  });

  factory ServiceDetailsData.fromJson(Map<String, dynamic> json) {
    final pav = json['peopleAlsoViewed'];
    final pavList = (pav is List) ? pav : const [];

    return ServiceDetailsData(
      service: Service.fromJson(
        (json['service'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      shop: ServiceShop.fromJson(
        (json['shop'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      similarServices: SimilarServices.fromJson(
        (json['similarServices'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      peopleAlsoViewed: pavList
          .map(
            (e) => SimilarServiceItem.fromJson(
              (e as Map?)?.cast<String, dynamic>() ?? {},
            ),
          )
          .toList(),
      reviews: ServiceReviews.fromJson(
        (json['reviews'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service': service.toJson(),
      'shop': shop.toJson(),
      'similarServices': similarServices.toJson(),
      'peopleAlsoViewed': peopleAlsoViewed.map((e) => e.toJson()).toList(),
      'reviews': reviews.toJson(),
    };
  }
}

class Service {
  final String id;
  final String englishName;
  final String? tamilName;
  final double startsAt; // from price
  final double offerPrice;
  final int durationMinutes;
  final String? offerLabel;
  final String? offerValue;
  final String description;
  final String status;
  final List<String> keywords;
  final List<ServiceMedia> media;
  final List<ServiceHighlight> highlights;
  final int rating;
  final int reviewCount;

  Service({
    required this.id,
    required this.englishName,
    this.tamilName,
    required this.startsAt,
    required this.offerPrice,
    required this.durationMinutes,
    this.offerLabel,
    this.offerValue,
    required this.description,
    required this.status,
    required this.keywords,
    required this.media,
    required this.highlights,
    required this.rating,
    required this.reviewCount,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    final keywordsRaw = json['keywords'];
    final mediaRaw = json['media'];
    final highlightsRaw = json['highlights'];

    return Service(
      id: (json['id'] ?? '').toString(),
      englishName: (json['englishName'] ?? '').toString(),
      tamilName: json['tamilName']?.toString(),

      // ✅ price sometimes int/double/string
      startsAt: _toDouble(json['price'], def: _toDouble(json['startsAt'])),
      offerPrice: _toDouble(json['offerPrice']),
      durationMinutes: _toInt(json['durationMinutes']),

      offerLabel: json['offerLabel']?.toString(),
      offerValue: json['offerValue']?.toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),

      keywords: (keywordsRaw is List)
          ? keywordsRaw.map((e) => e.toString()).toList()
          : <String>[],

      media: (mediaRaw is List)
          ? mediaRaw
                .map(
                  (e) => ServiceMedia.fromJson(
                    (e as Map?)?.cast<String, dynamic>() ?? {},
                  ),
                )
                .toList()
          : <ServiceMedia>[],

      highlights: (highlightsRaw is List)
          ? highlightsRaw
                .map(
                  (e) => ServiceHighlight.fromJson(
                    (e as Map?)?.cast<String, dynamic>() ?? {},
                  ),
                )
                .toList()
          : <ServiceHighlight>[],

      // ✅ rating sometimes 0.0
      rating: _toInt(json['rating']),
      reviewCount: _toInt(json['reviewCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'englishName': englishName,
      'tamilName': tamilName,
      'startsAt': startsAt,
      'offerPrice': offerPrice,
      'durationMinutes': durationMinutes,
      'offerLabel': offerLabel,
      'offerValue': offerValue,
      'description': description,
      'status': status,
      'keywords': keywords,
      'media': media.map((e) => e.toJson()).toList(),
      'highlights': highlights.map((e) => e.toJson()).toList(),
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}

class ServiceMedia {
  final String id;
  final String url;
  final int displayOrder;

  ServiceMedia({
    required this.id,
    required this.url,
    required this.displayOrder,
  });

  factory ServiceMedia.fromJson(Map<String, dynamic> json) {
    return ServiceMedia(
      id: (json['id'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      // ✅ displayOrder sometimes double
      displayOrder: _toInt(json['displayOrder']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'displayOrder': displayOrder};
  }
}

class ServiceHighlight {
  final String id;
  final String label;
  final String value;
  final String? language;

  ServiceHighlight({
    required this.id,
    required this.label,
    required this.value,
    this.language,
  });

  factory ServiceHighlight.fromJson(Map<String, dynamic> json) {
    return ServiceHighlight(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      language: json['language']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'value': value, 'language': language};
  }
}

class ServiceShop {
  final String id;
  final String englishName;
  final String? tamilName;
  final String category;
  final String subCategory;
  final String city;
  final String state;
  final String country;
  final Coordinates coordinates;
  final int rating;
  final int ratingCount;
  final bool isTrusted;
  final bool doorDelivery;
  final String shopKind;
  final String primaryPhone;
  final double? distanceKm;
  final String? distanceLabel;
  final String? openLabel;
  final bool isOpen;
  final String primaryImageUrl;
  final String? closeTime;

  ServiceShop({
    required this.id,
    required this.englishName,
    this.tamilName,
    required this.category,
    required this.subCategory,
    required this.city,
    required this.state,
    required this.country,
    required this.coordinates,
    required this.rating,
    required this.ratingCount,
    required this.isTrusted,
    required this.doorDelivery,
    required this.shopKind,
    required this.primaryPhone,
    this.distanceKm,
    this.distanceLabel,
    this.openLabel,
    required this.isOpen,
    required this.primaryImageUrl,
    this.closeTime,
  });

  factory ServiceShop.fromJson(Map<String, dynamic> json) {
    // ✅ Support both gpsLatitude/gpsLongitude and nested coordinates object
    final gpsLat = (json['gpsLatitude'] is String)
        ? double.tryParse(json['gpsLatitude']) ?? 0.0
        : _toDouble(json['gpsLatitude']);

    final gpsLng = (json['gpsLongitude'] is String)
        ? double.tryParse(json['gpsLongitude']) ?? 0.0
        : _toDouble(json['gpsLongitude']);

    final coordsJson = (json['coordinates'] as Map?)?.cast<String, dynamic>();

    // ✅ distance can come as int/double/string
    double? dist;
    final d = json['distanceKm'];
    if (d != null) {
      dist = _toDouble(d);
    }

    return ServiceShop(
      id: (json['id'] ?? '').toString(),
      englishName: (json['englishName'] ?? '').toString(),
      tamilName: json['tamilName']?.toString(),
      category: (json['category'] ?? '').toString(),
      subCategory: (json['subCategory'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),

      coordinates: (coordsJson != null && coordsJson.isNotEmpty)
          ? Coordinates.fromJson(coordsJson)
          : Coordinates(latitude: gpsLat, longitude: gpsLng),

      // ✅ rating sometimes 0.0
      rating: _toInt(json['rating']),
      ratingCount: _toInt(json['ratingCount']),

      isTrusted: json['isTrusted'] == true,
      doorDelivery: json['doorDelivery'] == true,
      shopKind: (json['shopKind'] ?? '').toString(),
      primaryPhone: (json['primaryPhone'] ?? '').toString(),

      distanceKm: dist,
      distanceLabel: json['distanceLabel']?.toString(),
      openLabel: json['openLabel']?.toString(),
      isOpen: json['isOpen'] == true,
      primaryImageUrl: (json['primaryImageUrl'] ?? '').toString(),
      closeTime: json['closeTime']?.toString(),
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
      'coordinates': coordinates.toJson(),
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
      'closeTime': closeTime,
    };
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}

class SimilarServices {
  final int total;
  final List<SimilarServiceItem> items;

  SimilarServices({required this.total, required this.items});

  factory SimilarServices.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    return SimilarServices(
      // ✅ total sometimes 0.0
      total: _toInt(json['total']),
      items: (itemsRaw is List)
          ? itemsRaw
                .map(
                  (e) => SimilarServiceItem.fromJson(
                    (e as Map?)?.cast<String, dynamic>() ?? {},
                  ),
                )
                .toList()
          : <SimilarServiceItem>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'items': items.map((e) => e.toJson()).toList()};
  }
}

class SimilarServiceItem {
  final String id;
  final String englishName;
  final String? tamilName;
  final double startsAt; // from price
  final double offerPrice;
  final int durationMinutes;
  final String? offerLabel;
  final String? offerValue;
  final String description;
  final String status;
  final String primaryImageUrl; // from imageUrl
  final String category;
  final String subCategory;
  final int rating;
  final int ratingCount;
  final String? distanceLabel;
  final String? shopName;

  SimilarServiceItem({
    required this.id,
    required this.englishName,
    this.tamilName,
    required this.startsAt,
    required this.offerPrice,
    required this.durationMinutes,
    this.offerLabel,
    this.offerValue,
    required this.description,
    required this.status,
    required this.primaryImageUrl,
    required this.category,
    required this.subCategory,
    required this.rating,
    required this.ratingCount,
    this.distanceLabel,
    this.shopName,
  });

  factory SimilarServiceItem.fromJson(Map<String, dynamic> json) {
    return SimilarServiceItem(
      id: (json['id'] ?? '').toString(),
      englishName: (json['englishName'] ?? '').toString(),
      tamilName: json['tamilName']?.toString(),

      startsAt: _toDouble(json['price'], def: _toDouble(json['startsAt'])),
      offerPrice: _toDouble(json['offerPrice']),
      // ✅ THIS CAUSED YOUR CRASH: sometimes 60.0
      durationMinutes: _toInt(json['durationMinutes']),

      offerLabel: json['offerLabel']?.toString(),
      offerValue: json['offerValue']?.toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'ACTIVE').toString(),

      primaryImageUrl: (json['imageUrl'] ?? json['primaryImageUrl'] ?? '')
          .toString(),
      category: (json['category'] ?? '').toString(),
      subCategory: (json['subCategory'] ?? '').toString(),

      // ✅ rating sometimes 0.0
      rating: _toInt(json['rating']),
      ratingCount: _toInt(json['ratingCount']),

      distanceLabel: json['distanceLabel']?.toString(),
      shopName:
          (json['shopName'] ??
                  (json['shop'] is Map ? (json['shop']['englishName']) : null))
              ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'englishName': englishName,
      'tamilName': tamilName,
      'startsAt': startsAt,
      'offerPrice': offerPrice,
      'durationMinutes': durationMinutes,
      'offerLabel': offerLabel,
      'offerValue': offerValue,
      'description': description,
      'status': status,
      'primaryImageUrl': primaryImageUrl,
      'category': category,
      'subCategory': subCategory,
      'rating': rating,
      'ratingCount': ratingCount,
      'distanceLabel': distanceLabel,
      'shopName': shopName,
    };
  }
}

class ServiceReviews {
  final ServiceReviewSummary summary;
  final List<ServiceReviewItem> items;

  ServiceReviews({required this.summary, required this.items});

  factory ServiceReviews.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    return ServiceReviews(
      summary: ServiceReviewSummary.fromJson(
        (json['summary'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      items: (itemsRaw is List)
          ? itemsRaw
                .map(
                  (e) => ServiceReviewItem.fromJson(
                    (e as Map?)?.cast<String, dynamic>() ?? {},
                  ),
                )
                .toList()
          : <ServiceReviewItem>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class ServiceReviewSummary {
  final double rating;
  final int count;

  ServiceReviewSummary({required this.rating, required this.count});

  factory ServiceReviewSummary.fromJson(Map<String, dynamic> json) {
    return ServiceReviewSummary(
      rating: _toDouble(json['rating']),
      // ✅ count sometimes 0.0
      count: _toInt(json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'rating': rating, 'count': count};
  }
}

class ServiceReviewItem {
  // Placeholder – extend later when backend sends real fields
  ServiceReviewItem();

  factory ServiceReviewItem.fromJson(Map<String, dynamic> json) {
    return ServiceReviewItem();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
