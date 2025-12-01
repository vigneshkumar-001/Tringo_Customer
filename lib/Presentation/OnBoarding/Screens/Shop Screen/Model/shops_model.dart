class ShopsResponse {
  final bool status;
  final List<Shop> data;

  ShopsResponse({
    required this.status,
    required this.data,
  });

  factory ShopsResponse.fromJson(Map<String, dynamic> json) {
    return ShopsResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Shop.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class Shop {
  final String id;
  final String englishName;
  final String tamilName;
  final String category;
  final String subCategory;
  final String city;
  final String state;
  final String country;
  final double rating;
  final int ratingCount;
  final bool isTrusted;
  final bool doorDelivery;
  final String shopKind;
  final String primaryPhone;
  final double? distanceKm;
  final String? distanceLabel;
  final String? openLabel;
  final bool isOpen;
  final String? primaryImageUrl;

  Shop({
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
    this.distanceKm,
    this.distanceLabel,
    this.openLabel,
    required this.isOpen,
    this.primaryImageUrl,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      rating: (json['rating'] != null)
          ? double.tryParse(json['rating'].toString()) ?? 0
          : 0,
      ratingCount: json['ratingCount'] ?? 0,
      isTrusted: json['isTrusted'] ?? false,
      doorDelivery: json['doorDelivery'] ?? false,
      shopKind: json['shopKind'] ?? '',
      primaryPhone: json['primaryPhone'] ?? '',
      distanceKm: (json['distanceKm'] != null)
          ? double.tryParse(json['distanceKm'].toString())
          : null,
      distanceLabel: json['distanceLabel'],
      openLabel: json['openLabel'],
      isOpen: json['isOpen'] ?? false,
      primaryImageUrl: json['primaryImageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
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
