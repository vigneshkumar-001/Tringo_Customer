// smart_connect_details_response.dart

class SmartConnectDetailsResponse {
  final bool status;
  final SmartConnectDetailsData data;

  SmartConnectDetailsResponse({required this.status, required this.data});

  factory SmartConnectDetailsResponse.fromJson(Map<String, dynamic> json) {
    return SmartConnectDetailsResponse(
      status: json['status'] == true,
      data: SmartConnectDetailsData.fromJson(json['data'] ?? const {}),
    );
  }

  Map<String, dynamic> toJson() => {"status": status, "data": data.toJson()};
}

class SmartConnectDetailsData {
  final String id;

  final String title;
  final String description;
  final String categoryTrail;
  final int replyCount;
  final String replyCountLabel;
  final String createdAt;
  final List<SmartConnectShopResponse> responses;

  SmartConnectDetailsData({
    required this.id,

    required this.title,
    required this.description,
    required this.categoryTrail,
    required this.replyCount,
    required this.replyCountLabel,
    required this.createdAt,
    required this.responses,
  });

  factory SmartConnectDetailsData.fromJson(Map<String, dynamic> json) {
    return SmartConnectDetailsData(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),

      description: (json['description'] ?? '').toString(),
      categoryTrail: (json['categoryTrail'] ?? '').toString(),
      replyCount: (json['replyCount'] ?? 0) is int
          ? (json['replyCount'] ?? 0)
          : int.tryParse((json['replyCount'] ?? '0').toString()) ?? 0,
      replyCountLabel: (json['replyCountLabel'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      responses: ((json['responses'] as List?) ?? [])
          .map(
            (e) => SmartConnectShopResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,

    "description": description,
    "categoryTrail": categoryTrail,
    "replyCount": replyCount,
    "replyCountLabel": replyCountLabel,
    "createdAt": createdAt,
    "responses": responses.map((e) => e.toJson()).toList(),
  };
}

class SmartConnectShopResponse {
  final String id;
  final String title;
  final String productName;
  final String description;
  final num price;
  final List<String> images;
  final String repliedAt;
  final String repliedLabel;
  final SmartConnectShop shop;

  SmartConnectShopResponse({
    required this.id,
    required this.title,
    required this.productName,
    required this.description,
    required this.price,
    required this.images,
    required this.repliedAt,
    required this.repliedLabel,
    required this.shop,
  });

  factory SmartConnectShopResponse.fromJson(Map<String, dynamic> json) {
    return SmartConnectShopResponse(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] is num)
          ? (json['price'] as num)
          : num.tryParse((json['price'] ?? '0').toString()) ?? 0,
      images: ((json['images'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      repliedAt: (json['repliedAt'] ?? '').toString(),
      repliedLabel: (json['repliedLabel'] ?? '').toString(),
      shop: SmartConnectShop.fromJson(json['shop'] ?? const {}),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "productName": productName,
    "description": description,
    "price": price,
    "images": images,
    "repliedAt": repliedAt,
    "repliedLabel": repliedLabel,
    "shop": shop.toJson(),
  };
}

class SmartConnectShop {
  final String id;
  final String name;
  final String city;
  final String address;
  final String phone;
  final String alternatePhone;
  final String imageUrl;
  final num averageRating;
  final int reviewCount;
  final bool isTrusted;
  final num distanceKm;
  final bool openNow;
  final String openLabel;

  SmartConnectShop({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    required this.alternatePhone,
    required this.imageUrl,
    required this.averageRating,
    required this.reviewCount,
    required this.isTrusted,
    required this.distanceKm,
    required this.openNow,
    required this.openLabel,
  });

  factory SmartConnectShop.fromJson(Map<String, dynamic> json) {
    return SmartConnectShop(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      alternatePhone: (json['alternatePhone'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      averageRating: (json['averageRating'] is num)
          ? (json['averageRating'] as num)
          : num.tryParse((json['averageRating'] ?? '0').toString()) ?? 0,
      reviewCount: (json['reviewCount'] ?? 0) is int
          ? (json['reviewCount'] ?? 0)
          : int.tryParse((json['reviewCount'] ?? '0').toString()) ?? 0,
      isTrusted: json['isTrusted'] == true,
      distanceKm: (json['distanceKm'] is num)
          ? (json['distanceKm'] as num)
          : num.tryParse((json['distanceKm'] ?? '0').toString()) ?? 0,
      openNow: json['openNow'] == true,
      openLabel: (json['openLabel'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "city": city,
    "address": address,
    "phone": phone,
    "alternatePhone": alternatePhone,
    "imageUrl": imageUrl,
    "averageRating": averageRating,
    "reviewCount": reviewCount,
    "isTrusted": isTrusted,
    "distanceKm": distanceKm,
    "openNow": openNow,
    "openLabel": openLabel,
  };
}
