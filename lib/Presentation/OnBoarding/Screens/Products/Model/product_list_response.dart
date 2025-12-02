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
  final int total;
  final List<ProductItem> items;

  ProductListData({
    required this.type,
    required this.page,
    required this.limit,
    required this.total,
    required this.items,
  });

  factory ProductListData.fromJson(Map<String, dynamic> json) {
    return ProductListData(
      type: json['type'],
      page: json['page'],
      limit: json['limit'],
      total: json['total'] ?? 0,
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
    'items': items.map((e) => e.toJson()).toList(),
  };
}



class ProductItem {
  final String id;
  final String? englishName;
  final String? tamilName;
  final double price;
  final double offerPrice;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final bool doorDelivery;
  final double rating;
  final int ratingCount;
  final bool isFeatured;
  final String? imageUrl;
  final String? category;
  final String? subCategory;
  final Shop shop;
  final String? kind;

  ProductItem({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.price,
    required this.offerPrice,
    required this.offerLabel,
    required this.offerValue,
    required this.description,
    required this.doorDelivery,
    required this.rating,
    required this.ratingCount,
    required this.isFeatured,
    required this.imageUrl,
    required this.category,
    required this.subCategory,
    required this.shop,
    required this.kind,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'],
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      price: (json['price'] ?? 0).toDouble(),
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'],
      doorDelivery: json['doorDelivery'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      imageUrl: json['imageUrl'],
      category: json['category'],
      subCategory: json['subCategory'],
      shop: Shop.fromJson(json['shop']),
      kind: json['kind'],
    );
  }

  Map<String, dynamic> toJson() => {
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
    'shop': shop.toJson(),
    'kind': kind,
  };
}


class Shop {
  final String id;
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
  final double rating;
  final int ratingCount;
  final bool isTrusted;
  final bool doorDelivery;
  final String? shopKind;
  final String? primaryPhone;
  final List<ShopWeeklyHours> shopWeeklyHours;
  final String? distanceKm;
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
    required this.ownershipType,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.rating,
    required this.ratingCount,
    required this.isTrusted,
    required this.doorDelivery,
    required this.shopKind,
    required this.primaryPhone,
    required this.shopWeeklyHours,
    required this.distanceKm,
    required this.distanceLabel,
    required this.openLabel,
    required this.isOpen,
    required this.primaryImageUrl,
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
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      isTrusted: json['isTrusted'] ?? false,
      doorDelivery: json['doorDelivery'] ?? false,
      shopKind: json['shopKind'],
      primaryPhone: json['primaryPhone'],
      shopWeeklyHours: (json['shopWeeklyHours'] as List<dynamic>? ?? [])
          .map((e) => ShopWeeklyHours.fromJson(e))
          .toList(),
      distanceKm: json['distanceKm']?.toString(),
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
    'ownershipType': ownershipType,
    'gpsLatitude': gpsLatitude,
    'gpsLongitude': gpsLongitude,
    'rating': rating,
    'ratingCount': ratingCount,
    'isTrusted': isTrusted,
    'doorDelivery': doorDelivery,
    'shopKind': shopKind,
    'primaryPhone': primaryPhone,
    'shopWeeklyHours': shopWeeklyHours.map((e) => e.toJson()).toList(),
    'distanceKm': distanceKm,
    'distanceLabel': distanceLabel,
    'openLabel': openLabel,
    'isOpen': isOpen,
    'primaryImageUrl': primaryImageUrl,
  };
}
class ShopWeeklyHours {
  final String day;
  final String opensAt;
  final String closesAt;
  final bool closed;

  ShopWeeklyHours({
    required this.day,
    required this.opensAt,
    required this.closesAt,
    required this.closed,
  });

  factory ShopWeeklyHours.fromJson(Map<String, dynamic> json) {
    return ShopWeeklyHours(
      day: json['day'] ?? '',
      opensAt: json['opensAt'] ?? '',
      closesAt: json['closesAt'] ?? '',
      closed: json['closed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'opensAt': opensAt,
    'closesAt': closesAt,
    'closed': closed,
  };
}


