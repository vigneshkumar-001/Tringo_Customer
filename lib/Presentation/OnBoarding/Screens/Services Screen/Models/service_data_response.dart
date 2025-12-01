class  ServiceDataResponse  {
  final bool status;
  final ServiceDetailsData data;

  ServiceDataResponse({
    required this.status,
    required this.data,
  });

  factory ServiceDataResponse.fromJson(Map<String, dynamic> json) {
    return ServiceDataResponse(
      status: json['status'] ?? false,
      data: ServiceDetailsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
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
    return ServiceDetailsData(
      service: Service.fromJson(json['service'] ?? {}),
      shop: ServiceShop.fromJson(json['shop'] ?? {}),
      similarServices:
      SimilarServices.fromJson(json['similarServices'] ?? {}),
      peopleAlsoViewed: (json['peopleAlsoViewed'] as List? ?? [])
          .map((e) => SimilarServiceItem.fromJson(e ?? {}))
          .toList(),
      reviews: ServiceReviews.fromJson(json['reviews'] ?? {}),
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
  final double startsAt;
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
    return Service(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'],
      startsAt: (json['startsAt'] as num?)?.toDouble() ?? 0.0,
      offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['durationMinutes'] ?? 0,
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      keywords: (json['keywords'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      media: (json['media'] as List? ?? [])
          .map((e) => ServiceMedia.fromJson(e ?? {}))
          .toList(),
      highlights: (json['highlights'] as List? ?? [])
          .map((e) => ServiceHighlight.fromJson(e ?? {}))
          .toList(),
      rating: json['rating'] ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
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
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'displayOrder': displayOrder,
    };
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
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'value': value,
      'language': language,
    };
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
  });

  factory ServiceShop.fromJson(Map<String, dynamic> json) {
    return ServiceShop(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'],
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      isTrusted: json['isTrusted'] ?? false,
      doorDelivery: json['doorDelivery'] ?? false,
      shopKind: json['shopKind'] ?? '',
      primaryPhone: json['primaryPhone'] ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      distanceLabel: json['distanceLabel'],
      openLabel: json['openLabel'],
      isOpen: json['isOpen'] ?? false,
      primaryImageUrl: json['primaryImageUrl'] ?? '',
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
    };
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
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

class SimilarServices {
  final int total;
  final List<SimilarServiceItem> items;

  SimilarServices({
    required this.total,
    required this.items,
  });

  factory SimilarServices.fromJson(Map<String, dynamic> json) {
    return SimilarServices(
      total: json['total'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => SimilarServiceItem.fromJson(e ?? {}))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class SimilarServiceItem {
  final String id;
  final String englishName;
  final String? tamilName;
  final double startsAt;
  final double offerPrice;
  final int durationMinutes;
  final String? offerLabel;
  final String? offerValue;
  final String description;
  final String status;
  final String primaryImageUrl;
  final String category;
  final String subCategory;
  final int rating;
  final int ratingCount;

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
  });

  factory SimilarServiceItem.fromJson(Map<String, dynamic> json) {
    return SimilarServiceItem(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'],
      startsAt: (json['startsAt'] as num?)?.toDouble() ?? 0.0,
      offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['durationMinutes'] ?? 0,
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      primaryImageUrl: json['primaryImageUrl'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
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
    };
  }
}

class ServiceReviews {
  final ServiceReviewSummary summary;
  final List<ServiceReviewItem> items;

  ServiceReviews({
    required this.summary,
    required this.items,
  });

  factory ServiceReviews.fromJson(Map<String, dynamic> json) {
    return ServiceReviews(
      summary: ServiceReviewSummary.fromJson(json['summary'] ?? {}),
      items: (json['items'] as List? ?? [])
          .map((e) => ServiceReviewItem.fromJson(e ?? {}))
          .toList(),
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

  ServiceReviewSummary({
    required this.rating,
    required this.count,
  });

  factory ServiceReviewSummary.fromJson(Map<String, dynamic> json) {
    return ServiceReviewSummary(
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'count': count,
    };
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
