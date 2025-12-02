class ProductListResponse {
  final bool status;
  final ProductListData? data;

  ProductListResponse({
    required this.status,
    required this.data,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? ProductListData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data?.toJson(),
  };
}

class ProductListData {
  final String? type;
  final String? page;
  final String? limit;
  final int? total;
  final List<ProductItem> items;

  ProductListData({
    this.type,
    this.page,
    this.limit,
    this.total,
    required this.items,
  });

  factory ProductListData.fromJson(Map<String, dynamic> json) {
    return ProductListData(
      type: json['type'],
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ProductItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'page': page,
    'limit': limit,
    'total': total,
    'items': items.map((x) => x.toJson()).toList(),
  };
}

class ProductItem {
  final String? kind;
  final String? id;
  final String? englishName;
  final String? tamilName;
  final num? price;
  final num? offerPrice;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final bool? doorDelivery;
  final int? rating;
  final int? ratingCount;
  final bool? isFeatured;
  final String? imageUrl;
  final String? category;
  final String? subCategory;
  final Shop? shop;

  ProductItem({
    this.kind,
    this.id,
    this.englishName,
    this.tamilName,
    this.price,
    this.offerPrice,
    this.offerLabel,
    this.offerValue,
    this.description,
    this.doorDelivery,
    this.rating,
    this.ratingCount,
    this.isFeatured,
    this.imageUrl,
    this.category,
    this.subCategory,
    this.shop,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      kind: json['kind'],
      id: json['id'],
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      price: json['price'],
      offerPrice: json['offerPrice'],
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'],
      doorDelivery: json['doorDelivery'],
      rating: json['rating'],
      ratingCount: json['ratingCount'],
      isFeatured: json['isFeatured'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      subCategory: json['subCategory'],
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'id': id,
    'englishName': englishName,
    'tamilName': tamilName,
    'price': price,
    'offerPrice': offerPrice,
    'offerLabel': offerLabel,
    'offerValue': offerValue,
    'description': description,
    'doorDelivery': doorDelivery,
    'rating': rating,
    'ratingCount': ratingCount,
    'isFeatured': isFeatured,
    'imageUrl': imageUrl,
    'category': category,
    'subCategory': subCategory,
    'shop': shop?.toJson(),
  };
}

class Shop {
  final String? id;
  final String? englishName;
  final String? tamilName;
  final String? category;
  final String? subCategory;
  final String? city;
  final String? state;
  final String? country;
  final String? ownershipType;
  final String? gpsLatitude;
  final String? gpsLongitude;
  final int? rating;
  final int? ratingCount;
  final bool? isTrusted;
  final bool? doorDelivery;
  final String? shopKind;
  final String? primaryPhone;
  final List<ShopWeeklyHours>? shopWeeklyHours;
  final num? distanceKm;
  final String? distanceLabel;
  final String? openLabel;
  final bool? isOpen;
  final String? primaryImageUrl;

  Shop({
    this.id,
    this.englishName,
    this.tamilName,
    this.category,
    this.subCategory,
    this.city,
    this.state,
    this.country,
    this.ownershipType,
    this.gpsLatitude,
    this.gpsLongitude,
    this.rating,
    this.ratingCount,
    this.isTrusted,
    this.doorDelivery,
    this.shopKind,
    this.primaryPhone,
    this.shopWeeklyHours,
    this.distanceKm,
    this.distanceLabel,
    this.openLabel,
    this.isOpen,
    this.primaryImageUrl,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      category: json['category'],
      subCategory: json['subCategory'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      ownershipType: json['ownershipType'],
      gpsLatitude: json['gpsLatitude'],
      gpsLongitude: json['gpsLongitude'],
      rating: json['rating'],
      ratingCount: json['ratingCount'],
      isTrusted: json['isTrusted'],
      doorDelivery: json['doorDelivery'],
      shopKind: json['shopKind'],
      primaryPhone: json['primaryPhone'],
      shopWeeklyHours: (json['shopWeeklyHours'] as List<dynamic>?)
          ?.map((e) => ShopWeeklyHours.fromJson(e))
          .toList() ??
          [],
      distanceKm: json['distanceKm'],
      distanceLabel: json['distanceLabel'],
      openLabel: json['openLabel'],
      isOpen: json['isOpen'],
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
    'ownershipType': ownershipType,
    'gpsLatitude': gpsLatitude,
    'gpsLongitude': gpsLongitude,
    'rating': rating,
    'ratingCount': ratingCount,
    'isTrusted': isTrusted,
    'doorDelivery': doorDelivery,
    'shopKind': shopKind,
    'primaryPhone': primaryPhone,
    'shopWeeklyHours':
    shopWeeklyHours?.map((x) => x.toJson()).toList(),
    'distanceKm': distanceKm,
    'distanceLabel': distanceLabel,
    'openLabel': openLabel,
    'isOpen': isOpen,
    'primaryImageUrl': primaryImageUrl,
  };
}

class ShopWeeklyHours {
  final String? day;
  final String? opensAt;
  final String? closesAt;
  final bool? closed;

  ShopWeeklyHours({
    this.day,
    this.opensAt,
    this.closesAt,
    this.closed,
  });

  factory ShopWeeklyHours.fromJson(Map<String, dynamic> json) {
    return ShopWeeklyHours(
      day: json['day'],
      opensAt: json['opensAt'],
      closesAt: json['closesAt'],
      closed: json['closed'],
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'opensAt': opensAt,
    'closesAt': closesAt,
    'closed': closed,
  };
}
