class  ProductListResponse  {
  final bool status;
  final ProductListData data;

  ProductListResponse({
    required this.status,
    required this.data,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      status: json['status'],
      data: ProductListData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'data': data.toJson(),
  };
}
class ProductListData {
  final int page;
  final int limit;
  final int total;
  final List<ProductListItem> items;

  ProductListData({
    required this.page,
    required this.limit,
    required this.total,
    required this.items,
  });

  factory ProductListData.fromJson(Map<String, dynamic> json) {
    return ProductListData(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      items: (json['items'] as List)
          .map((e) => ProductListItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'items': items.map((e) => e.toJson()).toList(),
  };
}


class ProductListItem {
  final String id;
  final String? englishName;
  final String? tamilName;
  final int price;
  final String? offerLabel;
  final String? offerValue;
  final String? description;
  final Shop shop;
  final String? imageUrl;

  ProductListItem({
    required this.id,
    this.englishName,
    this.tamilName,
    required this.price,
    this.offerLabel,
    this.offerValue,
    this.description,
    required this.shop,
    this.imageUrl,
  });

  factory ProductListItem.fromJson(Map<String, dynamic> json) {
    return ProductListItem(
      id: json['id'],
      englishName: json['englishName'],
      tamilName: json['tamilName'],
      price: json['price'],
      offerLabel: json['offerLabel'],
      offerValue: json['offerValue'],
      description: json['description'],
      shop: Shop.fromJson(json['shop']),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'englishName': englishName,
    'tamilName': tamilName,
    'price': price,
    'offerLabel': offerLabel,
    'offerValue': offerValue,
    'description': description,
    'shop': shop.toJson(),
    'imageUrl': imageUrl,
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
  final String? gpsLatitude;
  final String? gpsLongitude;
  final int rating;
  final int ratingCount;
  final bool isTrusted;
  final bool doorDelivery;
  final String? shopKind;
  final String? primaryPhone;
  final double distanceKm;
  final String? distanceLabel;
  final String? openLabel;
  final bool isOpen;
  final String? primaryImageUrl;

  Shop({
    required this.id,
    this.englishName,
    this.tamilName,
    this.category,
    this.subCategory,
    this.city,
    this.state,
    this.country,
    this.gpsLatitude,
    this.gpsLongitude,
    required this.rating,
    required this.ratingCount,
    required this.isTrusted,
    required this.doorDelivery,
    this.shopKind,
    this.primaryPhone,
    required this.distanceKm,
    this.distanceLabel,
    this.openLabel,
    required this.isOpen,
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
      gpsLatitude: json['gpsLatitude'],
      gpsLongitude: json['gpsLongitude'],
      rating: json['rating'],
      ratingCount: json['ratingCount'],
      isTrusted: json['isTrusted'],
      doorDelivery: json['doorDelivery'],
      shopKind: json['shopKind'],
      primaryPhone: json['primaryPhone'],
      distanceKm: (json['distanceKm'] as num).toDouble(),
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
    'gpsLatitude': gpsLatitude,
    'gpsLongitude': gpsLongitude,
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

