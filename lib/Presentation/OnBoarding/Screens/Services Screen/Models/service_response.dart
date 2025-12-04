class ServiceResponse {
  final bool status;
  final List<ServiceItem> data;

  ServiceResponse({required this.status, required this.data});

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ServiceItem.fromJson(e))
          .toList(),
    );
  }
}

class ServiceItem {
  final String id;
  final String? englishName;
  final String? tamilName;
  final String? category;
  final String? subCategory;
  final String? city;
  final String? state;
  final String? country;
  final double rating;
  final int ratingCount;
  final bool isTrusted;
  final bool doorDelivery;
  final String? shopKind;
  final String? primaryPhone;
  final double? distanceKm;
  final String? distanceLabel;
  final String? openLabel;
  final bool isOpen;
  final String? primaryImageUrl;
  final String? closeTime;

  ServiceItem({
    required this.id,
    this.englishName,
    this.tamilName,
    this.category,
    this.subCategory,
    this.city,
    this.state,
    this.country,
    required this.rating,
    required this.ratingCount,
    required this.isTrusted,
    required this.doorDelivery,
    this.shopKind,
    this.primaryPhone,
    this.distanceKm,
    this.distanceLabel,
    this.openLabel,
    required this.isOpen,
    this.primaryImageUrl,
    this.closeTime,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] ?? '',
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      category: json['category'],
      subCategory: json['subCategory'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      isTrusted: json['isTrusted'] ?? false,
      doorDelivery: json['doorDelivery'] ?? false,
      shopKind: json['shopKind'],
      primaryPhone: json['primaryPhone'],
      distanceKm: json['distanceKm'] != null
          ? (json['distanceKm']).toDouble()
          : null,
      distanceLabel: json['distanceLabel'],
      openLabel: json['openLabel'],
      isOpen: json['isOpen'] ?? false,
      primaryImageUrl: json['primaryImageUrl'],
      closeTime: json['closeTime']?? '',
    );
  }
}
